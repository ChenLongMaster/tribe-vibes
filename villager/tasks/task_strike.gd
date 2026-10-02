class_name TaskStrike
extends Task
## Giải trí = 0 → đình công: quăng đồ nghề, dậm chân, bong bóng 💢. Xong màn giận dỗi thì
## chỉ đứng chơi quanh chỗ (Villager.on_strike chặn mọi việc được giao) cho tới khi giải
## trí hồi lại STRIKE_RESUME_FUN — bộ não lo phần đó.

var _tool: String = ""


## `tool_key` = đồ nghề đang cầm để quăng đi ("" = tay không).
func _init(tool_key: String) -> void:
	_tool = tool_key
	kind = &"strike"
	priority = Priority.NEED


func start() -> void:
	villager.state = Villager.State.STRIKING
	villager.rig.play(VillagerRig.ANIM_STRIKE)
	if not _tool.is_empty():
		villager.rig.throw_item(_tool)
	villager.say("BUBBLE_STRIKE", {}, "icons/angry")
	timer = Balance.STRIKE_STOMP_SECONDS


func tick(delta: float) -> Status:
	timer -= delta
	return Status.DONE if timer <= 0.0 else Status.RUNNING


func stop() -> void:
	villager.state = Villager.State.IDLE


func activity_key() -> String:
	return "UI_ACTIVITY_STRIKE"


func icon_key() -> String:
	return "icons/angry"
