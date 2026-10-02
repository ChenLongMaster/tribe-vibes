class_name TaskSit
extends Task
## Ngồi bệt xuống phơi nắng, hồi chút sức và vui lên. Mệt thì ngáp một cái giữa chừng.

const YAWN_SECONDS: float = 1.3
const YAWN_IF_ENERGY_BELOW: float = 60.0

var _yawn_at: float = -1.0
var _yawn_left: float = 0.0


func _init() -> void:
	kind = &"sit"


func start() -> void:
	villager.rig.play(VillagerRig.ANIM_SIT)
	villager.rig.squash(0.12)
	timer = randf_range(Balance.IDLE_MIN_SECONDS + 1.0, Balance.IDLE_MAX_SECONDS)
	if villager.status.energy < YAWN_IF_ENERGY_BELOW:
		_yawn_at = timer * 0.5


func tick(delta: float) -> Status:
	villager.status.add_fun(Balance.FUN_SIT * delta)
	villager.status.add_energy(Balance.ENERGY_RESTORE_SIT * delta)
	var before: float = timer
	timer -= delta
	if before > _yawn_at and timer <= _yawn_at:
		villager.rig.play(VillagerRig.ANIM_YAWN)
		_yawn_left = YAWN_SECONDS
	if _yawn_left > 0.0:
		_yawn_left -= delta
		if _yawn_left <= 0.0:
			villager.rig.play(VillagerRig.ANIM_SIT)
	return Status.RUNNING if timer > 0.0 else Status.DONE


func activity_key() -> String:
	return "UI_ACTIVITY_SIT"
