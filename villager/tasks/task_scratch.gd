class_name TaskScratch
extends Task
## Đứng gãi mông. Tinh nghịch, nhanh.

const SECONDS_MIN: float = 1.8
const SECONDS_MAX: float = 3.2


func _init() -> void:
	kind = &"scratch"


func start() -> void:
	villager.rig.play(VillagerRig.ANIM_SCRATCH)
	timer = randf_range(SECONDS_MIN, SECONDS_MAX)


func tick(delta: float) -> Status:
	timer -= delta
	if timer > 0.0:
		return Status.RUNNING
	villager.status.add_fun(Balance.FUN_SCRATCH)
	return Status.DONE


func activity_key() -> String:
	return "UI_ACTIVITY_SCRATCH"
