class_name TaskFidget
extends Task
## Đứng yên tại chỗ làm trò nho nhỏ (đứng chờ lệnh, vẫy vẫy người chơi, ngó nghiêng, vươn vai)
## — không bước đi đâu cả. Thả thổ dân ở đâu thì họ đứng đó cho người chơi dễ tìm.
## Việc rảnh: giao việc là thôi ngay.

const ACTIVITY_KEYS: Dictionary[StringName, String] = {
	VillagerRig.ANIM_IDLE: "UI_ACTIVITY_WAIT_ORDER",
	VillagerRig.ANIM_WAVE: "UI_ACTIVITY_WAVE",
	VillagerRig.ANIM_LOOK: "UI_ACTIVITY_LOOK",
	VillagerRig.ANIM_STRETCH: "UI_ACTIVITY_STRETCH",
}
## Ngó nghiêng thì quay sang hướng kia giữa chừng.
const LOOK_TURN_FRACTION: float = 0.5

var _anim: StringName
var _seconds: float = 0.0
var _turned: bool = false


func _init(anim: StringName, seconds: float) -> void:
	_anim = anim
	_seconds = seconds
	timer = seconds
	kind = &"fidget"


func start() -> void:
	villager.state = Villager.State.IDLE
	villager.rig.play(_anim)
	if _anim == VillagerRig.ANIM_WAVE:
		villager.rig.flash_face(VillagerRig.FACE_HAPPY, _seconds)


func tick(delta: float) -> Status:
	timer -= delta
	if _anim == VillagerRig.ANIM_LOOK and not _turned and timer <= _seconds * LOOK_TURN_FRACTION:
		_turned = true
		villager.rig.set_facing(-villager.rig.facing)
	return Status.DONE if timer <= 0.0 else Status.RUNNING


func activity_key() -> String:
	return ACTIVITY_KEYS.get(_anim, "UI_ACTIVITY_WAIT_ORDER")
