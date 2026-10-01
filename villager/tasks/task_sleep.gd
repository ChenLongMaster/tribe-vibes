class_name TaskSleep
extends Task
## Đi tới một chỗ trống quanh lửa trại, nằm ngủ tới khi lại sức rồi vươn vai dậy.
## (Đợt 3 có lều thì ưu tiên ngủ trong lều.)

enum Step { GO, SLEEP, WAKE }

const WAKE_SECONDS: float = 1.3

var _spot: Vector2i = World.INVALID_CELL


func _init() -> void:
	kind = &"sleep"
	priority = Priority.NEED


func start() -> void:
	_spot = world().finder.find_sleep_spot(villager)
	if _spot == World.INVALID_CELL:
		# Hết chỗ quanh lửa trại thì ngủ luôn tại chỗ — vẫn hơn đứng gật gù.
		step = Step.GO
		return
	villager.move_to_cell(_spot)
	step = Step.GO


func tick(delta: float) -> Status:
	match step:
		Step.GO:
			if villager.is_moving():
				return Status.RUNNING
			villager.rig.play(VillagerRig.ANIM_SLEEP)
			villager.state = Villager.State.SLEEPING
			villager.overhead.set_sleeping(true)
			step = Step.SLEEP
		Step.SLEEP:
			if villager.data.energy < Balance.ENERGY_WAKE:
				return Status.RUNNING
			villager.overhead.set_sleeping(false)
			villager.state = Villager.State.IDLE
			villager.rig.play(VillagerRig.ANIM_STRETCH)
			timer = WAKE_SECONDS
			step = Step.WAKE
		Step.WAKE:
			timer -= delta
			if timer <= 0.0:
				return Status.DONE
	return Status.RUNNING


func stop() -> void:
	world().reservations.release(_spot, villager)
	villager.overhead.set_sleeping(false)


func is_asleep() -> bool:
	return step == Step.SLEEP


func activity_key() -> String:
	return "UI_ACTIVITY_SLEEP"
