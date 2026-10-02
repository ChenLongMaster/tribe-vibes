class_name TaskStrike
extends Task
## Giải trí = 0 → đình công: quăng đồ nghề, dậm chân, bong bóng 💢, rồi giơ biển vẽ việc
## đang làm bị gạch chéo. Biển giữ suốt lúc đình công; thổ dân chỉ đứng chơi quanh chỗ
## (Villager.on_strike chặn mọi việc được giao) cho tới khi giải trí hồi lại
## STRIKE_RESUME_FUN — bộ não lo phần đó, Villager.end_strike() hạ biển.

var _tool: String = ""
var _sign: String = ""


## `tool_key` = đồ nghề đang cầm để quăng đi ("" = tay không); `sign_key` = hình vẽ trên biển.
func _init(tool_key: String, sign_key: String) -> void:
	_tool = tool_key
	_sign = sign_key
	kind = &"strike"
	priority = Priority.NEED


func start() -> void:
	villager.state = Villager.State.STRIKING
	villager.rig.play(VillagerRig.ANIM_STRIKE)
	if not _tool.is_empty():
		villager.rig.throw_item(_tool)
	villager.emote("icons/angry")
	timer = Balance.STRIKE_STOMP_SECONDS


func tick(delta: float) -> Status:
	timer -= delta
	if timer > 0.0:
		return Status.RUNNING
	if villager.on_strike:
		villager.hold_sign(_sign, true, Villager.UNTIL_CLEARED)
	return Status.DONE


func stop() -> void:
	villager.state = Villager.State.IDLE


func activity_key() -> String:
	return "UI_ACTIVITY_STRIKE"


func icon_key() -> String:
	return "icons/angry"
