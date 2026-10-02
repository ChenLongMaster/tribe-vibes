class_name TaskHarvest
extends TaskWork
## Một lượt chặt cây / đập đá / hái quả / câu cá: đi tới cạnh vật → làm → khuân về kho.
## Cách làm từng loại (thời gian, sản lượng, hoạt họa, đồ nghề) đọc từ JobDefs.

enum Step { GO, WORK, CARRY }

const STAND_CLOSER: float = 0.3 # 0 = giữa ô đứng, 1 = ngay chỗ vật

var _node: ResourceNode


func _init(owner_job: Job, node: ResourceNode) -> void:
	super(owner_job)
	_node = node
	kind = &"harvest"


func start() -> void:
	if not world().reservations.reserve(_node, villager):
		fail()
		return
	var stand: Vector2i = world().finder.find_stand_cell(_node.cell, villager, true)
	# Đứng nhích lại gần vật một chút cho nhát rìu/cuốc chạm tới.
	var close_point: Vector2 = WorldGrid.cell_to_world(stand).lerp(_node.position, STAND_CLOSER)
	if stand == World.INVALID_CELL or not villager.move_to_cell(stand, close_point):
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
			# Tới nơi mà đã hết (vd bụi vừa bị hái để ăn) — không tính là hỏng, lượt sau tìm cái khác.
			if not _node.can_harvest():
				return Status.DONE
			villager.face_towards(_node.position)
			begin_work(float(job.def()["seconds"]))
			step = Step.WORK
		Step.WORK:
			if not tick_work(delta):
				return Status.RUNNING
			var amount: int = _node.harvest(int(job.def()["amount"]))
			world().reservations.release(_node, villager)
			if amount <= 0:
				return Status.DONE
			begin_carry(job.def()["resource"], amount)
			step = Step.CARRY
		Step.CARRY:
			return tick_carry(delta)
	return Status.RUNNING


func stop() -> void:
	super.stop()
	world().reservations.release(_node, villager)


func impact_target() -> Node2D:
	return _node
