class_name TaskCook
extends TaskWork
## Một lượt nấu ăn ở lửa trại (Đợt 3: bếp): lấy một phần thịt/cá sống trong kho, nấu, ra
## một món chín cất luôn tại chỗ. Chưa có gì để nấu thì đứng chờ cạnh bếp một lúc (thợ săn,
## thợ câu sẽ mang về) — mỗi lượt chờ ngắn để watchdog không tưởng là bị kẹt.

enum Step { GO, WAIT, COOK }

const WAIT_SECONDS: float = 6.0
const NAG_SECONDS: float = 15.0 # nhắc "Chưa có gì để nấu…" thưa thưa thôi

var _station: Building
var _raw: StringName = &""


func _init(owner_job: Job, station: Building) -> void:
	super(owner_job)
	_station = station
	kind = &"cook"


func start() -> void:
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
				begin_work(float(_station.def.get("cook_seconds", job.def()["seconds"])))
				step = Step.COOK
				villager.notify_task_changed()
				return Status.RUNNING
			villager.state = Villager.State.IDLE
			villager.rig.play(VillagerRig.ANIM_IDLE)
			if job.nag_cooldown <= 0.0:
				job.nag_cooldown = NAG_SECONDS
				villager.say("BUBBLE_NOTHING_TO_COOK", {}, "icons/res_meat")
			timer -= delta
			if timer <= 0.0:
				return Status.DONE
		Step.COOK:
			if not tick_work(delta):
				return Status.RUNNING
			_raw = &""
			GameState.add_resource(ResourceDefs.COOKED_MEAL, 1)
			EventBus.resource_delivered.emit(ResourceDefs.COOKED_MEAL, 1, _station.position + FLOAT_TEXT_LIFT)
			villager.emote("icons/happy")
			return Status.DONE
	return Status.RUNNING


func stop() -> void:
	super.stop()
	# Bị ngắt giữa chừng thì trả phần đồ sống lại kho, không làm mất.
	if _raw != &"":
		GameState.add_resource(_raw, 1)
		_raw = &""


func activity_key() -> String:
	return "UI_ACTIVITY_COOK_WAIT" if step != Step.COOK else super.activity_key()


func _try_take_raw() -> bool:
	for raw: StringName in ResourceDefs.COOKABLE:
		if GameState.take_resource(raw):
			_raw = raw
			return true
	return false
