class_name TaskScratch
extends Task
## Đứng gãi mông. Tinh nghịch, nhanh, thỉnh thoảng kèm bong bóng "Gãi gãi...".

const SECONDS_MIN: float = 1.8
const SECONDS_MAX: float = 3.2
const BUBBLE_CHANCE: float = 0.5


func _init() -> void:
	kind = &"scratch"


func start() -> void:
	villager.rig.play(VillagerRig.ANIM_SCRATCH)
	timer = randf_range(SECONDS_MIN, SECONDS_MAX)
	if randf() < BUBBLE_CHANCE:
		villager.overhead.show_bubble(Loc.t("BUBBLE_SCRATCH"))


func tick(delta: float) -> Status:
	timer -= delta
	if timer > 0.0:
		return Status.RUNNING
	villager.data.fun = minf(villager.data.fun + Balance.FUN_SCRATCH, VillagerData.MAX_NEED)
	return Status.DONE


func activity_key() -> String:
	return "UI_ACTIVITY_SCRATCH"
