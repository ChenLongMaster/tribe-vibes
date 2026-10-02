class_name Villager
extends Node2D
## Một thổ dân trong thế giới: giữ dữ liệu, trạng thái, việc đang làm, di chuyển.
## Việc gì làm thế nào nằm ở các Task; chọn việc gì nằm ở VillagerBrain; hình ảnh ở
## VillagerRig và Overhead. File này chỉ nối chúng lại.
##
## Thổ dân không nói chữ, chỉ "nói" bằng hình: emote()/chatter() (bong bóng nói), think()
## (bong bóng nghĩ — muốn gì đó), hold_sign() (giơ biển — cần người chơi ra tay), show_heart().
## Villager phát signal, Overhead / VillagerRig tự lo hiển thị.

enum State { IDLE, MOVING, WORKING, CARRYING, EATING, SLEEPING, SOCIAL, FLEEING, FIGHTING, KNOCKED_OUT, STRIKING }
## SPEECH = bong bóng nói (cảm xúc, tán gẫu); THOUGHT = mây suy nghĩ (đang muốn gì đó).
enum Bubble { SPEECH, THOUGHT }

signal task_changed(villager: Villager)
## Muốn hiện bong bóng chứa các icon, trong `seconds` giây (<=0 = mặc định, INF = tới khi xoá).
signal bubble_requested(style: Bubble, icon_keys: Array[String], seconds: float)
signal bubble_cleared
signal heart_requested
## Vừa lên cấp một kỹ năng (Overhead hiện bong bóng, FxLayer bung sao qua EventBus).
signal leveled_up(skill: StringName, level: int)

## Vùng chạm hình tròn quanh thân — đường kính 56 px, lớn hơn hình để dễ chạm trên điện thoại.
const PICK_CENTER: Vector2 = Vector2(0, -34)
const PICK_RADIUS: float = 28.0
const OVERHEAD_STANDING: Vector2 = Vector2(0, -78)
const OVERHEAD_LYING: Vector2 = Vector2(-34, -30)
## Đang giơ biển thì đẩy bong bóng/icon trên đầu lên cao hơn tấm biển.
const OVERHEAD_SIGN_LIFT: float = 38.0
## Giữ bong bóng / biển tới khi tự xoá (clear_bubble / lower_sign).
const UNTIL_CLEARED: float = INF
const SIGN_SECONDS: float = 3.5
const AGE_SCALES: Dictionary[VillagerData.AgeStage, float] = {
	VillagerData.AgeStage.BABY: 0.55,
	VillagerData.AgeStage.CHILD: 0.75,
	VillagerData.AgeStage.ADULT: 1.0,
}
const ARRIVE_DISTANCE: float = 1.0
const STUCK_SECONDS: float = 4.0
const IDLE_ACTIVITY_KEY: String = "UI_ACTIVITY_IDLE"

## Tổng số lần watchdog cảnh báo (mọi thổ dân) — test đọc để biết có ai đứng đơ.
static var watchdog_alerts: int = 0

## Mã số do lõi cấp lúc spawn, dùng cho Commands (vd assign_job(villager_id, …)).
var id: int = 0
var data: VillagerData
var status: VillagerStatus
var world: World
var state: State = State.IDLE
var task: Task
var speed_multiplier: float = 1.0
## Điểm neo: rảnh thì chỉ dạo trong bán kính nhỏ quanh ô này (GAME_DESIGN mục 5.2).
## Đặt khi chui ra khỏi hang; người chơi bảo đi tới đâu thì neo ở đó; hết việc thì neo tại chỗ.
var anchor_cell: Vector2i = Vector2i.ZERO
## Hệ số hồi thể lực của chỗ đang ngủ (ngủ đất ×1; Đợt 3 lều cao hơn).
var sleep_rate_multiplier: float = 1.0
## Việc người chơi giao (null = chưa giao gì). Ghi nhớ qua mọi lần bị ngắt — xem Job.
var job: Job
## Đang đình công: từ chối mọi việc, chỉ đứng chơi tới khi giải trí hồi lại.
var on_strike: bool = false
## Đang ở trong công trình nào (ngủ trong lều) — null = ở ngoài.
var inside: Building
## Đồ nghề đang giữ (lưu trong VillagerStatus). Đổi bằng set_tool().
var tool: StringName:
	get:
		return status.tool

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


## Chỉ World.spawn_villager() gọi hàm này — đó là cách duy nhất tạo thổ dân.
func setup(villager_id: int, villager_data: VillagerData, villager_status: VillagerStatus,
		owner_world: World, cell: Vector2i) -> void:
	id = villager_id
	data = villager_data
	status = villager_status
	world = owner_world
	position = WorldGrid.cell_to_world(cell)
	anchor_cell = cell
	_lane_offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * Balance.LANE_JITTER
	# Lệch giờ suy nghĩ để không ai nghĩ cùng một frame.
	_think_timer = randf_range(0.0, Balance.THINK_INTERVAL_MAX)


func _ready() -> void:
	rig.setup(data)
	rig.set_back_item(ToolDefs.icon(status.tool))
	scale = age_scale()
	ArtLibrary.setup_sprite(_selection_ring, "ui/selection_ring")
	_selection_ring.visible = false
	_last_position = position


func age_scale() -> Vector2:
	var factor: float = AGE_SCALES.get(data.age_stage, 1.0)
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
		var task_status: Task.Status = task.tick(delta)
		if task_status != Task.Status.RUNNING:
			_finish_task(task_status)
	rig.set_mood_face(status.mood() >= Balance.MOOD_SAD)
	overhead.position = OVERHEAD_LYING * Vector2(rig.facing, 1) if rig.is_lying() else OVERHEAD_STANDING
	if rig.is_sign_raised():
		overhead.position.y -= OVERHEAD_SIGN_LIFT
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
	notify_task_changed()


## Key dịch + tham số mô tả việc đang làm — UI tự dịch khi hiển thị.
func activity_key() -> String:
	return IDLE_ACTIVITY_KEY if task == null else task.activity_key()


func activity_args() -> Dictionary:
	return {} if task == null else task.activity_args()


## Kỹ năng của việc đang làm (&"" nếu không phải việc lao động) — hệ nhu cầu cần biết.
func current_skill() -> StringName:
	return &"" if task == null else task.skill


func activity_icon() -> String:
	if on_strike:
		return "icons/angry"
	return "" if task == null else task.icon_key()


## Cấp hiện tại của một kỹ năng (cấp khởi đầu + đã lên lúc chơi).
func skill_level(skill: StringName) -> int:
	return status.skill_level(skill, data)


## Báo phần hiển thị (icon trên đầu…) rằng việc đang làm vừa đổi bước.
func notify_task_changed() -> void:
	_refresh_gear()
	task_changed.emit(self)


## Nhảy nhẹ sang chỗ khác (vd vừa có móng nhà đặt đè lên chỗ đang đứng).
## Vị trí đổi ngay (lõi coi như đã ở chỗ mới), chỉ hình nhảy theo cho mượt.
func hop_to(point: Vector2) -> void:
	stop_moving()
	var offset: Vector2 = position - point
	position = point
	anchor_cell = WorldGrid.world_to_cell(point)
	rig.position = offset
	rig.create_tween().tween_property(rig, "position", Vector2.ZERO, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	rig.squash(-0.2)


## Chui vào trong công trình (ngủ trong lều): ẩn hẳn, không chạm được; null = chui ra.
func set_inside(building: Building) -> void:
	inside = building
	visible = building == null
	if building == null:
		rig.squash(-0.15)


# Thợ xây đội mũ công trường suốt lúc còn nhận việc xây.
func _refresh_gear() -> void:
	if rig != null:
		rig.set_hard_hat(job != null and job.job_id == JobDefs.BUILD)


# --- Lệnh của người chơi (chỉ Commands gọi) ---

## Nhận việc mới. Đang rảnh/đang làm việc khác thì đổi ngay; đang ăn/ngủ thì làm xong đã;
## đang đình công thì nhớ việc nhưng từ chối tới khi hết giận.
func assign_job(new_job: Job) -> void:
	var old_job: Job = job
	job = new_job
	if on_strike:
		emote("icons/angry")
		notify_task_changed()
		return
	if task != null and task.priority >= Task.Priority.NEED:
		# "Lát nữa nhé": nghĩ về việc mới, làm xong việc đang dở (ăn, ngủ…) rồi đi.
		think(new_job.icon_key())
		notify_task_changed()
		return
	lower_sign()
	start_task(null)
	# Đang khuân dở đồ của việc cũ thì việc mới khuân nốt về kho trước.
	if old_job != null and old_job.carried_count > 0:
		new_job.carried_item = old_job.carried_item
		new_job.carried_count = old_job.carried_count
	_acknowledge()
	_think_timer = 0.0


## Đi tới ô `cell` và đứng chơi quanh đó (bỏ việc đang giao).
func order_move(cell: Vector2i) -> void:
	job = null
	anchor_cell = cell
	if not on_strike:
		lower_sign()
	if task != null and task.priority >= Task.Priority.NEED:
		think("icons/dots")
		notify_task_changed()
		return
	start_task(TaskReturn.new(true))
	_acknowledge()


## Đi ngủ ngay ở chỗ này (người chơi thả vào lều). Việc đang giao vẫn nhớ, ngủ dậy làm tiếp.
func order_sleep(spot: SleepSpot) -> void:
	lower_sign()
	if task != null and task.priority >= Task.Priority.NEED:
		world.reservations.release(spot.reservation_key, self)
		think("icons/sleepy")
		notify_task_changed()
		return
	start_task(TaskSleep.new(spot))
	_acknowledge()


## "Ugh!" không lời: nhún một cái, mặt tươi lên.
func _acknowledge() -> void:
	rig.squash(-0.15)
	rig.flash_face(VillagerRig.FACE_HAPPY, 0.6)


## Thôi việc đang giao: đứng chờ lệnh ngay tại chỗ. Hết thứ để làm thì giơ biển vẽ việc đó
## gạch chéo ("Hết cây rồi!"), thiếu đồ nghề thì vẽ món đó gạch chéo, kho đầy thì vẽ cái kho
## gạch chéo; không tới được thì nghĩ dấu "?". Xây xong công trình thì ăn mừng.
func stop_job() -> void:
	if job == null:
		return
	var icon_key: String = job.stop_sign_icon()
	var gave_up: bool = job.gave_up()
	var celebrate: bool = job.finished_building
	job = null
	anchor_cell = world.cell_of(self)
	if celebrate:
		# Xây xong rồi, không còn công trình dở nào gần đây: ăn mừng, không giơ biển.
		start_task(TaskCelebrate.new())
	elif gave_up:
		think("icons/question")
	else:
		hold_sign(icon_key, true)
	notify_task_changed()


# --- Đình công & lên cấp ---

func begin_strike() -> void:
	on_strike = true
	# Giận dỗi ngay tại chỗ đang làm, không lững thững đi về.
	anchor_cell = world.cell_of(self)
	var tool_key: String = "" if job == null else JobDefs.held_art(job.job_id)
	var sign_key: String = "icons/angry" if job == null else job.icon_key()
	start_task(TaskStrike.new(tool_key, sign_key))
	EventBus.village_event.emit("TOAST_STRIKE", {"name": data.display_name}, "icons/angry")


func end_strike() -> void:
	on_strike = false
	lower_sign()
	if job != null:
		emote(job.icon_key())
		rig.squash(-0.15)
	EventBus.village_event.emit("TOAST_STRIKE_END", {"name": data.display_name}, "icons/happy")
	notify_task_changed()


func on_skill_level_up(skill: StringName, level: int) -> void:
	emote(SkillDefs.icon(skill))
	leveled_up.emit(skill, level)
	EventBus.skill_leveled_up.emit(self, skill, level)
	EventBus.village_event.emit("TOAST_LEVEL_UP",
			{"name": data.display_name, "job_key": SkillDefs.name_key(skill), "level": level}, SkillDefs.icon(skill))


## Cầm lấy món đồ nghề mới (món cũ đã cất lại chỗ cũ). Không dùng thì đeo sau lưng.
func set_tool(new_tool: StringName) -> void:
	status.tool = new_tool
	rig.set_back_item(ToolDefs.icon(new_tool))
	notify_task_changed()


## Bong bóng nói chứa một icon cảm xúc (vui ♪, giận 💢…).
func emote(icon_key: String, seconds: float = -1.0) -> void:
	bubble_requested.emit(Bubble.SPEECH, [icon_key] as Array[String], seconds)


## "Nói chuyện" bằng hình khi tán gẫu (1–2 icon vô nghĩa).
func chatter(icon_keys: Array[String], seconds: float = -1.0) -> void:
	bubble_requested.emit(Bubble.SPEECH, icon_keys, seconds)


## Mây suy nghĩ: đang muốn gì đó (đồ ăn, ngủ, việc sắp làm…).
func think(icon_key: String, seconds: float = -1.0) -> void:
	bubble_requested.emit(Bubble.THOUGHT, [icon_key] as Array[String], seconds)


func clear_bubble() -> void:
	bubble_cleared.emit()


## Giơ tấm biển vẽ `icon_key` (gạch chéo nếu `crossed`): có chuyện cần người chơi ra tay.
## Đang rảnh thì đứng yên cạnh biển cho tới khi hạ biển (không đi dạo mất).
func hold_sign(icon_key: String, crossed: bool = false, seconds: float = SIGN_SECONDS) -> void:
	rig.show_sign(icon_key, crossed, seconds)
	if seconds < UNTIL_CLEARED and (task == null or task.priority == Task.Priority.IDLE):
		start_task(TaskWait.new(seconds))


func lower_sign() -> void:
	rig.lower_sign()


func show_heart() -> void:
	heart_requested.emit()


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


## Phần đường còn phải đi, bắt đầu từ chỗ đang đứng (rỗng nếu không đi đâu) — để vẽ
## đường chấm chấm. Chỉ đọc.
func remaining_path() -> PackedVector2Array:
	var points: PackedVector2Array = PackedVector2Array()
	if not _moving:
		return points
	points.append(position)
	for i: int in range(_path_index, _path.size()):
		points.append(_path[i])
	return points


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
	if not visible:
		return false
	return (position + PICK_CENTER * scale).distance_to(world_point) <= PICK_RADIUS * scale.y


func set_selected(on: bool) -> void:
	_selection_ring.visible = on
	overhead.set_name_visible(on)


func set_hovered(on: bool) -> void:
	overhead.set_name_visible(on or _selection_ring.visible)


func _finish_task(result: Task.Status) -> void:
	# Một lượt việc được giao kết thúc: báo Job để lần sau bỏ qua mục tiêu không tới được.
	if task is TaskWork and (task as TaskWork).job == job and job != null:
		job.report(result)
	start_task(null)
	# Xong việc thì nghĩ ngay việc tiếp theo, không đứng ngẩn ra; việc hỏng thì chờ
	# một nhịp ngắn để không thử đi thử lại liên tục trong cùng một frame.
	_think_timer = 0.0 if result == Task.Status.DONE else Balance.THINK_INTERVAL_MIN


# Cảnh báo khi có gì đó kẹt: một việc kéo quá lâu, hoặc đang đi mà không nhúc nhích.
func _update_watchdog(delta: float) -> void:
	if _moving and position.distance_to(_last_position) < 0.01:
		_stuck_time += delta
	else:
		_stuck_time = 0.0
	_last_position = position
	if _watchdog_warned or not OS.is_debug_build():
		return
	var long_task_ok: bool = task is TaskSleep or task is TaskKnockedOut or task is TaskSulk
	var too_long: bool = task != null and not long_task_ok and _task_time > Balance.WATCHDOG_SECONDS
	if too_long or _stuck_time > STUCK_SECONDS:
		_watchdog_warned = true
		watchdog_alerts += 1
		push_warning("Watchdog: %s kẹt ở việc '%s' (%.0f giây, đứng yên %.1f giây)" % [
			data.display_name, task.kind if task != null else &"-", _task_time, _stuck_time])
