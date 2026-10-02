class_name TaskCook
extends TaskWork
## Một lượt nấu ăn ở lửa trại hoặc Bếp: lấy một phần thức ăn thô trong kho chung, nấu,
## ra một món chín cất ngay ở bếp (đồ RIÊNG của bếp, tối đa theo sức chứa — bày quanh bếp
## cho thấy). Chưa có gì để nấu thì đứng chờ cạnh bếp, thỉnh thoảng giơ biển đùi thịt gạch
## chéo; bếp đầy món chín thì đứng chờ người ăn bớt. Mỗi lượt chờ ngắn để watchdog không
## tưởng là bị kẹt.

enum Step { GO, WAIT, COOK }

const WAIT_SECONDS: float = 6.0
const NAG_SECONDS: float = 15.0 # nhắc "Chưa có gì để nấu…" thưa thưa thôi

const NO_FOOD_SIGN: String = "icons/res_food"

var _station: Building
## Món thô đang nấu dở (quả / cá / thịt) — bị ngắt thì trả lại kho đúng món.
var _raw: StringName = &""


func _init(owner_job: Job, station: Building) -> void:
	super(owner_job)
	_station = station
	kind = &"cook"


func start() -> void:
	hold_job_item()
	var stand: Vector2i = world().finder.find_building_stand_cell(_station, villager)
	if stand == World.INVALID_CELL or not villager.move_to_cell(stand):
		fail()
		return
	step = Step.GO


func tick(delta: float) -> Status:
	if _failed:
		return Status.FAILED
	job.nag_cooldown -= delta
	match step:
		Step.GO:
			if villager.is_moving():
				return Status.RUNNING
			villager.face_towards(_station.position)
			timer = WAIT_SECONDS
			step = Step.WAIT
		Step.WAIT:
			if _try_take_raw():
				begin_work(float(_station.prop("cook_seconds", job.def()["seconds"])))
				step = Step.COOK
				villager.notify_task_changed()
				return Status.RUNNING
			villager.state = Villager.State.IDLE
			villager.rig.play(VillagerRig.ANIM_IDLE)
			if job.nag_cooldown <= 0.0 and _station.has_room_for(ResourceDefs.MEAL):
				job.nag_cooldown = NAG_SECONDS
				villager.hold_sign(NO_FOOD_SIGN, true)
			timer -= delta
			if timer <= 0.0:
				return Status.DONE
		Step.COOK:
			if not tick_work(delta):
				return Status.RUNNING
			_raw = &""
			_station.add_stock(ResourceDefs.MEAL)
			EventBus.resource_delivered.emit(ResourceDefs.MEAL, 1, _station.position + FLOAT_TEXT_LIFT)
			villager.emote("icons/happy")
			return Status.DONE
	return Status.RUNNING


func stop() -> void:
	super.stop()
	# Bị ngắt giữa chừng thì trả phần đồ thô lại kho, không làm mất.
	if _raw != &"":
		# Kho đầy thì vẫn trả (không làm mất phần đã lấy ra).
		GameState.add_resource(ResourceDefs.FOOD, 1, _raw if _raw != ResourceDefs.FOOD else &"")
		_raw = &""


func activity_key() -> String:
	return "UI_ACTIVITY_COOK_WAIT" if step != Step.COOK else super.activity_key()


# Bếp còn chỗ cất món chín và kho còn thức ăn thô thì lấy một phần ra nấu.
func _try_take_raw() -> bool:
	if not _station.has_room_for(ResourceDefs.MEAL):
		return false
	_raw = GameState.take_one(ResourceDefs.FOOD)
	return _raw != &""
