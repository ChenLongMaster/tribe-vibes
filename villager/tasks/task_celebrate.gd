class_name TaskCelebrate
extends Task
## Nhảy cẫng lên ăn mừng (xây xong công trình) rồi đứng chơi tại chỗ. Việc rảnh: giao việc
## mới là thôi ngay.

const SECONDS: float = 2.0


func _init() -> void:
	kind = &"celebrate"
	timer = SECONDS


func start() -> void:
	villager.state = Villager.State.IDLE
	villager.rig.play(VillagerRig.ANIM_CELEBRATE)
	villager.emote("icons/happy")


func tick(delta: float) -> Status:
	timer -= delta
	return Status.DONE if timer <= 0.0 else Status.RUNNING


func activity_key() -> String:
	return "UI_ACTIVITY_CELEBRATE"
