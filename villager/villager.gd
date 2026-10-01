class_name Villager
extends Node2D
## Một thổ dân trong thế giới: giữ dữ liệu, việc đang làm, di chuyển theo đường đi.
## Việc gì làm thế nào nằm ở các Task; chọn việc gì nằm ở VillagerBrain; hình ảnh ở
## VillagerRig và Overhead. File này chỉ nối chúng lại.

enum State { IDLE, MOVING, WORKING, CARRYING, EATING, SLEEPING, SOCIAL, FLEEING, FIGHTING, KNOCKED_OUT }

signal task_changed(villager: Villager)

## Vùng chạm hình tròn quanh thân — đường kính 56 px, lớn hơn hình để dễ chạm trên điện thoại.
const PICK_CENTER: Vector2 = Vector2(0, -34)
const PICK_RADIUS: float = 28.0
const OVERHEAD_STANDING: Vector2 = Vector2(0, -78)
const OVERHEAD_LYING: Vector2 = Vector2(-34, -30)
const STAGE_SCALES: Dictionary[VillagerData.Stage, float] = {
	VillagerData.Stage.BABY: 0.55,
	VillagerData.Stage.CHILD: 0.75,
	VillagerData.Stage.ADULT: 1.0,
}
const ARRIVE_DISTANCE: float = 1.0
const STUCK_SECONDS: float = 4.0

## Tổng số lần watchdog cảnh báo (mọi thổ dân) — test đọc để biết có ai đứng đơ.
static var watchdog_alerts: int = 0

var data: VillagerData
var world: World
var state: State = State.IDLE
var task: Task
var speed_multiplier: float = 1.0

var _brain: VillagerBrain = VillagerBrain.new()
var _think_timer: float = 0.0
var _since_think: float = 0.0
var _path: PackedVector2Array = PackedVector2Array()
var _path_index: int = 0
var _moving: bool = false
## Lệch nhẹ khỏi tâm ô, riêng mỗi người, để cả làng không đi chồng lên một đường.
var _lane_offset: Vector2 = Vector2.ZERO
var _task_time: float = 0.0
var _watchdog_warned: bool = false
var _stuck_time: float = 0.0
var _last_position: Vector2 = Vector2.ZERO

@onready var rig: VillagerRig = $Rig
@onready var overhead: Overhead = $Overhead
@onready var _selection_ring: Sprite2D = $SelectionRing


func setup(villager_data: VillagerData, owner_world: World, spawn_position: Vector2) -> void:
	data = villager_data
	world = owner_world
	position = spawn_position
	_lane_offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * Balance.LANE_JITTER
	# Lệch giờ suy nghĩ để không ai nghĩ cùng một frame.
	_think_timer = randf_range(0.0, Balance.THINK_INTERVAL_MAX)


func _ready() -> void:
	rig.setup(data.appearance)
	scale = stage_scale()
	overhead.set_display_name(data.display_name)
	ArtLibrary.setup_sprite(_selection_ring, "ui/selection_ring")
	_selection_ring.visible = false
	_last_position = position


func stage_scale() -> Vector2:
	var factor: float = STAGE_SCALES.get(data.stage, 1.0)
	return Vector2(factor, factor)


func _process(delta: float) -> void:
	VillagerNeeds.tick(self, delta)
	_update_movement(delta)
	_think_timer -= delta
	_since_think += delta
	if _think_timer <= 0.0:
		var elapsed: float = _since_think
		_since_think = 0.0
		_think_timer = randf_range(Balance.THINK_INTERVAL_MIN, Balance.THINK_INTERVAL_MAX)
		_brain.think(self, elapsed)
	if task != null:
		_task_time += delta
		var status: Task.Status = task.tick(delta)
		if status != Task.Status.RUNNING:
			_finish_task(status)
	rig.set_mood_face(data.mood() >= Balance.MOOD_SAD)
	overhead.position = OVERHEAD_LYING * Vector2(rig.facing, 1) if rig.anim == VillagerRig.ANIM_SLEEP else OVERHEAD_STANDING
	_update_watchdog(delta)


## Giao việc mới. Việc cũ (nếu có) bị dừng và trả lại chỗ đã đặt.
func start_task(new_task: Task) -> void:
	if task != null:
		var old: Task = task
		task = null
		old.stop()
	stop_moving()
	state = State.IDLE
	rig.play(VillagerRig.ANIM_IDLE)
	task = new_task
	_task_time = 0.0
	_watchdog_warned = false
	if task != null:
		task.villager = self
		task.start()
		overhead.set_activity_icon(task.icon_key())
	else:
		overhead.set_activity_icon("")
	task_changed.emit(self)


func activity_text() -> String:
	if task == null:
		return Loc.t("UI_ACTIVITY_IDLE")
	return task.activity_text()


# --- Di chuyển ---

## Đi tới ô `cell` (theo AStar). `final_point` để dừng đúng một điểm cụ thể trong ô.
## Trả về false nếu không có đường.
func move_to_cell(cell: Vector2i, final_point: Vector2 = Vector2.INF) -> bool:
	var from_cell: Vector2i = world.cell_of(self)
	var points: PackedVector2Array = world.grid.find_path(from_cell, cell)
	if points.is_empty() or WorldGrid.world_to_cell(points[points.size() - 1]) != cell:
		_moving = false
		return false
	for i: int in points.size():
		points[i] += _lane_offset
	if final_point != Vector2.INF:
		points[points.size() - 1] = final_point
	_path = points
	# Điểm đầu là tâm ô đang đứng — bỏ qua để không quay lại giật lùi.
	_path_index = 1 if points.size() > 1 else 0
	_moving = true
	_stuck_time = 0.0
	return true


func stop_moving() -> void:
	if _moving:
		_moving = false
		rig.move_speed = 0.0


func is_moving() -> bool:
	return _moving


func face_towards(point: Vector2) -> void:
	rig.set_facing(point.x - position.x)


func _update_movement(delta: float) -> void:
	if not _moving:
		return
	var target: Vector2 = _path[_path_index]
	var speed: float = Balance.WALK_SPEED * speed_multiplier
	var step: float = speed * delta
	var to_target: Vector2 = target - position
	rig.play(VillagerRig.ANIM_RUN if speed_multiplier > 1.0 else VillagerRig.ANIM_WALK)
	rig.move_speed = speed
	if absf(to_target.x) > 0.5:
		rig.set_facing(to_target.x)
	if to_target.length() <= maxf(step, ARRIVE_DISTANCE):
		position = target
		_path_index += 1
		if _path_index >= _path.size():
			_moving = false
			rig.move_speed = 0.0
			rig.play(VillagerRig.ANIM_IDLE)
			rig.squash()
	else:
		position += to_target.normalized() * step


# --- Chọn / xem thông tin ---

func hit_test(world_point: Vector2) -> bool:
	return (position + PICK_CENTER * scale).distance_to(world_point) <= PICK_RADIUS * scale.y


func set_selected(on: bool) -> void:
	_selection_ring.visible = on
	overhead.set_name_visible(on)


func set_hovered(on: bool) -> void:
	overhead.set_name_visible(on or _selection_ring.visible)


func _finish_task(status: Task.Status) -> void:
	start_task(null)
	# Xong việc thì nghĩ ngay việc tiếp theo, không đứng ngẩn ra; việc hỏng thì chờ
	# một nhịp ngắn để không thử đi thử lại liên tục trong cùng một frame.
	_think_timer = 0.0 if status == Task.Status.DONE else Balance.THINK_INTERVAL_MIN


# Cảnh báo khi có gì đó kẹt: một việc kéo quá lâu, hoặc đang đi mà không nhúc nhích.
func _update_watchdog(delta: float) -> void:
	if _moving and position.distance_to(_last_position) < 0.01:
		_stuck_time += delta
	else:
		_stuck_time = 0.0
	_last_position = position
	if _watchdog_warned or not OS.is_debug_build():
		return
	var too_long: bool = task != null and not task is TaskSleep and _task_time > Balance.WATCHDOG_SECONDS
	if too_long or _stuck_time > STUCK_SECONDS:
		_watchdog_warned = true
		watchdog_alerts += 1
		push_warning("Watchdog: %s kẹt ở việc '%s' (%.0f giây, đứng yên %.1f giây)" % [
			data.display_name, task.kind if task != null else &"-", _task_time, _stuck_time])
