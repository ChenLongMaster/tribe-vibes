class_name TaskSmith
extends TaskWork
## Một lượt của thợ rèn ở lò rèn: nhận món kế tiếp trong đơn người chơi đặt (rìu, cuốc,
## giáo — lần lượt từng loại), lấy gỗ + đá trong kho chung, gõ búa, xong thì món đó dựng
## cạnh lò (đồ RIÊNG của lò rèn). Không có đơn thì đứng chờ cạnh lò; thiếu vật liệu thì cắm
## biển vẽ gỗ/đá gạch chéo; lò đầy chỗ cất thì chờ người lấy bớt. Mỗi lượt chờ ngắn để
## watchdog không tưởng là bị kẹt.

enum Step { GO, WAIT, FORGE }

const WAIT_SECONDS: float = 6.0

var _forge: Building
## Món đang rèn dở — bị ngắt thì trả đơn + vật liệu lại.
var _tool: StringName = &""


func _init(owner_job: Job, forge: Building) -> void:
	super(owner_job)
	_forge = forge
	kind = &"smith"


func start() -> void:
	hold_job_item()
	var stand: Vector2i = world().finder.find_building_stand_cell(_forge, villager)
	if stand == World.INVALID_CELL or not villager.move_to_cell(stand):
		fail()
		return
	step = Step.GO


func tick(delta: float) -> Status:
	if _failed:
		return Status.FAILED
	job.nag_cooldown -= delta
	match step:
		Step.GO:
			if villager.is_moving():
				return Status.RUNNING
			villager.face_towards(_forge.position)
			timer = WAIT_SECONDS
			step = Step.WAIT
		Step.WAIT:
			if _try_start():
				begin_work(float(job.def()["seconds"]))
				step = Step.FORGE
				villager.notify_task_changed()
				return Status.RUNNING
			villager.state = Villager.State.IDLE
			villager.rig.play(VillagerRig.ANIM_IDLE)
			timer -= delta
			if timer <= 0.0:
				return Status.DONE
		Step.FORGE:
			if not _forge.is_built():
				return Status.DONE
			if not tick_work(delta):
				return Status.RUNNING
			_forge.add_stock(_tool, 1, true)
			villager.emote(ToolDefs.icon(_tool))
			EventBus.work_impact.emit(_forge.position + IMPACT_LIFT, JobDefs.IMPACT_POOF)
			_tool = &""
			return Status.DONE
	return Status.RUNNING


func stop() -> void:
	super.stop()
	if _tool != &"":
		_forge.return_order(_tool)
		for resource_id: StringName in ToolDefs.cost(_tool):
			GameState.add_resource(resource_id, int(ToolDefs.cost(_tool)[resource_id]))
		_tool = &""


func impact_target() -> Node2D:
	return _forge


func activity_key() -> String:
	if step == Step.FORGE:
		return "UI_ACTIVITY_SMITH"
	return "UI_ACTIVITY_SMITH_WAIT"


func icon_key() -> String:
	if step == Step.FORGE and _tool != &"":
		return ToolDefs.icon(_tool)
	return super.icon_key()


# Có đơn và đủ vật liệu thì nhận món đó (trừ đơn, lấy vật liệu). Thiếu vật liệu thì cắm biển.
func _try_start() -> bool:
	var tool: StringName = _forge.next_order()
	if tool == &"":
		return false
	var cost: Dictionary = ToolDefs.cost(tool)
	for resource_id: StringName in cost:
		if GameState.get_amount(resource_id) < int(cost[resource_id]):
			if job.nag_cooldown <= 0.0:
				job.nag_cooldown = TaskCook.NAG_SECONDS
				villager.hold_sign(ResourceDefs.icon(resource_id), true)
			return false
	for resource_id: StringName in cost:
		GameState.take_resource(resource_id, int(cost[resource_id]))
	_forge.take_order(tool)
	_tool = tool
	return true
