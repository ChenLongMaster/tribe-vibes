class_name TaskWork
extends Task
## Lớp gốc của các lượt lao động (chặt, đập, hái, câu, săn, nấu). Gom phần dùng chung:
## - Làm việc: đếm thời gian theo tốc độ làm (tính cách + cấp kỹ năng), tích kinh nghiệm,
##   mỗi nhát thì vật rung + tung bụi, Lười thì nghỉ tay giữa chừng rồi tự làm tiếp.
## - Cầm đúng đồ trên tay (rìu, giỏ, xô, cần câu…) từ lúc đi tới chỗ làm.
## - Khuân MÓN về kho gần nhất (giơ trên đầu: khúc gỗ, giỏ quả, xác thú…), tới nơi quy ra
##   tài nguyên chung, số bay "+10 gỗ".
## Bị ngắt lúc đang khuân thì món được ghi vào Job để lượt sau khuân nốt.

enum CarryStep { NONE, GO, DROP }

const DROP_SECONDS: float = 0.35
## Nhát đầu tiên rơi vào lúc rìu bổ xuống trong hoạt họa (tỉ lệ của một nhịp vung).
const FIRST_SWING_FRACTION: float = 0.72
const FLOAT_TEXT_LIFT: Vector2 = Vector2(0, -56)
const IMPACT_LIFT: Vector2 = Vector2(0, -24)

var job: Job

var _work_left: float = 0.0
var _work_anim: StringName = VillagerRig.ANIM_IDLE
var _swing_timer: float = 0.0
var _break_at: float = -1.0
var _break_left: float = 0.0
var _carry_step: CarryStep = CarryStep.NONE
var _carry_item: StringName = &""
var _carry_count: int = 0
var _storage: Building


func _init(owner_job: Job) -> void:
	job = owner_job
	skill = owner_job.skill
	kind = &"work"
	priority = Priority.WORK


func stop() -> void:
	villager.rig.set_held_item("")
	villager.rig.set_carry_item("")


func is_carrying() -> bool:
	return _carry_step != CarryStep.NONE


func activity_key() -> String:
	if is_carrying():
		return "UI_ACTIVITY_CARRY"
	if _break_left > 0.0:
		return "UI_ACTIVITY_LAZY_BREAK"
	return str(job.def().get("activity_key", "UI_ACTIVITY_IDLE"))


func activity_args() -> Dictionary:
	if is_carrying():
		return {"resource_key": ResourceDefs.item_noun_key(_carry_item)}
	return {}


## Đang khuân thì đồ đã giơ trên đầu, khỏi hiện icon việc chồng lên.
func icon_key() -> String:
	return "" if is_carrying() else job.icon_key()


# --- Làm việc ---

## Vật đang làm (để rung khi trúng nhát). Lớp con trả về cây/đá…
func impact_target() -> Node2D:
	return null


## Cầm đồ của việc này lên tay (rìu, giỏ, xô, cần câu…) — gọi từ lúc bắt đầu đi tới chỗ làm.
func hold_job_item() -> void:
	villager.rig.set_held_item(JobDefs.held_art(job.job_id), JobDefs.held_tilts(job.job_id))


## Bắt đầu làm một lượt dài `seconds` (ở cấp 1, tốc độ thường).
func begin_work(seconds: float) -> void:
	var def: Dictionary = job.def()
	_work_left = seconds
	_work_anim = def.get("anim", VillagerRig.ANIM_GATHER)
	villager.rig.play(_work_anim)
	hold_job_item()
	villager.state = Villager.State.WORKING
	_swing_timer = float(def.get("swing", 0.0)) * FIRST_SWING_FRACTION
	_break_at = -1.0
	_break_left = 0.0
	# Lười: thỉnh thoảng nghỉ tay ở đâu đó giữa lượt làm.
	if Traits.has_flag(villager.data.traits, &"takes_breaks") and randf() < Balance.LAZY_BREAK_CHANCE:
		_break_at = seconds * randf_range(0.3, 0.7)


## Chạy mỗi frame lúc đang làm. Trả về true khi làm xong lượt này.
func tick_work(delta: float) -> bool:
	if _break_left > 0.0:
		_break_left -= delta
		if _break_left <= 0.0:
			villager.rig.play(_work_anim)
			villager.state = Villager.State.WORKING
			villager.notify_task_changed()
		return false
	_work_left -= delta * work_speed(skill)
	VillagerSkills.add_work(villager, skill, delta)
	_tick_swing(delta)
	if _break_at > 0.0 and _work_left <= _break_at:
		_break_at = -1.0
		_break_left = Balance.LAZY_BREAK_SECONDS
		villager.rig.play(VillagerRig.ANIM_SIT)
		villager.state = Villager.State.IDLE
		villager.think("icons/sleepy")
		villager.notify_task_changed()
	return _work_left <= 0.0


func _tick_swing(delta: float) -> void:
	var swing: float = float(job.def().get("swing", 0.0))
	if swing <= 0.0:
		return
	_swing_timer -= delta
	if _swing_timer > 0.0:
		return
	_swing_timer += swing
	var target: Node2D = impact_target()
	if target is ResourceNode:
		(target as ResourceNode).shake()
	if target != null:
		EventBus.work_impact.emit(target.position + IMPACT_LIFT, job.def().get("impact", &""))


# --- Khuân về kho ---

## Bắt đầu khuân `count` món `item` về kho gần nhất nhận loại đồ này. `carry_art` thay hình
## giơ trên đầu (vd xác đúng con thú vừa săn), `upside_down` = vác ngửa (thú chổng vó).
func begin_carry(item: StringName, count: int, carry_art: String = "", upside_down: bool = false) -> void:
	_carry_item = item
	_carry_count = count
	job.carried_item = item
	job.carried_count = count
	villager.rig.set_held_item("")
	var art: String = carry_art if not carry_art.is_empty() else ResourceDefs.item_carry_art(item)
	villager.rig.set_carry_item(art, upside_down)
	villager.rig.squash(-0.1)
	villager.state = Villager.State.CARRYING
	_carry_step = CarryStep.GO
	villager.notify_task_changed()
	_storage = world().finder.find_storage_for(ResourceDefs.item_resource(item), villager)
	if _storage == null:
		# Không có kho nào (không nên xảy ra vì lửa trại luôn là kho) — cất thẳng.
		_deliver()
		return
	var stand: Vector2i = world().finder.find_building_stand_cell(_storage, villager)
	if stand == World.INVALID_CELL or not villager.move_to_cell(stand):
		_deliver()


## Chạy mỗi frame lúc đang khuân. DONE khi đã đặt đồ vào kho.
func tick_carry(delta: float) -> Status:
	match _carry_step:
		CarryStep.GO:
			if villager.is_moving():
				return Status.RUNNING
			if _storage != null:
				villager.face_towards(_storage.position)
			_deliver()
		CarryStep.DROP:
			timer -= delta
			if timer <= 0.0:
				return Status.DONE
	return Status.RUNNING


func _deliver() -> void:
	var resource: StringName = ResourceDefs.item_resource(_carry_item)
	var amount: int = ResourceDefs.item_value(_carry_item, _carry_count)
	# Thức ăn nhớ là quả / cá / thịt để lúc lấy ra ăn cầm đúng món.
	GameState.add_resource(resource, amount, _carry_item if ResourceDefs.is_food(resource) else &"")
	var drop_at: Vector2 = _storage.position if _storage != null else villager.position
	EventBus.resource_delivered.emit(resource, amount, drop_at + FLOAT_TEXT_LIFT)
	job.carried_item = &""
	job.carried_count = 0
	villager.rig.set_carry_item("")
	villager.rig.play(VillagerRig.ANIM_IDLE)
	villager.rig.squash(0.18)
	villager.state = Villager.State.WORKING
	_carry_step = CarryStep.DROP
	timer = DROP_SECONDS
