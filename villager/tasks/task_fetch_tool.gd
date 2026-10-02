class_name TaskFetchTool
extends Task
## Được giao việc cần đồ nghề (rìu, cuốc, giáo) mà trên tay chưa có: đi tới chỗ cất đồ nghề
## (lò rèn — Đợt 3), cất lại món đang giữ (nếu có) rồi lấy món cần dùng. Lấy xong thì giữ
## luôn — làm việc khác không cần đồ nghề thì đeo sau lưng.
## Không kế thừa TaskWork: lượt này không làm hỏng Job nếu tới nơi mà món đã bị người khác
## lấy mất — lượt sau Job tự tìm chỗ khác hoặc dừng việc, giơ biển "thiếu đồ nghề".

enum Step { GO, SWAP }

const SWAP_SECONDS: float = 0.8

var job: Job
var _rack: Building
var _tool: StringName


func _init(owner_job: Job, rack: Building, tool: StringName) -> void:
	job = owner_job
	_rack = rack
	_tool = tool
	kind = &"fetch_tool"
	priority = Priority.WORK


func start() -> void:
	var stand: Vector2i = world().finder.find_building_stand_cell(_rack, villager)
	if stand == World.INVALID_CELL or not villager.move_to_cell(stand):
		fail()
		return
	step = Step.GO


func tick(delta: float) -> Status:
	if _failed:
		return Status.FAILED
	match step:
		Step.GO:
			if villager.is_moving():
				return Status.RUNNING
			villager.face_towards(_rack.position)
			villager.rig.play(VillagerRig.ANIM_GATHER)
			timer = SWAP_SECONDS
			step = Step.SWAP
		Step.SWAP:
			timer -= delta
			if timer > 0.0:
				return Status.RUNNING
			villager.rig.play(VillagerRig.ANIM_IDLE)
			if not _rack.take_stock(_tool):
				return Status.DONE
			if villager.tool != &"":
				_rack.add_stock(villager.tool)
			villager.set_tool(_tool)
			villager.rig.squash(-0.12)
			villager.emote(ToolDefs.icon(_tool))
			return Status.DONE
	return Status.RUNNING


func activity_key() -> String:
	return "UI_ACTIVITY_FETCH_TOOL"


func icon_key() -> String:
	return ToolDefs.icon(_tool)
