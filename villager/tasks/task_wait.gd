class_name TaskWait
extends Task
## Đứng yên tại chỗ một lúc — vd vừa cắm biển "hết cây rồi" thì đứng cạnh biển cho người
## chơi kịp thấy, không lững thững đi dạo mất. Việc rảnh: được giao việc là thôi ngay.


func _init(seconds: float) -> void:
	timer = seconds
	kind = &"wait"


func start() -> void:
	villager.state = Villager.State.IDLE
	villager.rig.play(VillagerRig.ANIM_IDLE)


func tick(delta: float) -> Status:
	timer -= delta
	return Status.DONE if timer <= 0.0 else Status.RUNNING
