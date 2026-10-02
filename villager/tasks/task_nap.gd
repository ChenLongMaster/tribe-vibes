class_name TaskNap
extends Task
## Đứng chờ lâu quá thì chán, nằm phịch xuống ngủ gật ngay tại chỗ một lúc (hồi chút sức như
## ngủ đất) rồi vươn vai dậy. Khác TaskSleep: không đi tìm lều, và giao việc là dậy ngay.

enum Step { LIE, WAKE }

const WAKE_SECONDS: float = 1.3


func _init() -> void:
	kind = &"nap"
	timer = randf_range(Balance.NAP_MIN_SECONDS, Balance.NAP_MAX_SECONDS)


func start() -> void:
	villager.rig.play(VillagerRig.ANIM_SLEEP)
	villager.rig.squash(0.18)
	villager.state = Villager.State.SLEEPING
	step = Step.LIE


func tick(delta: float) -> Status:
	timer -= delta
	if timer > 0.0:
		return Status.RUNNING
	if step == Step.LIE:
		villager.state = Villager.State.IDLE
		villager.rig.play(VillagerRig.ANIM_STRETCH)
		timer = WAKE_SECONDS
		step = Step.WAKE
		return Status.RUNNING
	return Status.DONE


func stop() -> void:
	villager.state = Villager.State.IDLE


func activity_key() -> String:
	return "UI_ACTIVITY_NAP"
