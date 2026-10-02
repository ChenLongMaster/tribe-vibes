class_name TaskHarvest
extends TaskWork
## Một lượt chặt cây / đập đá tảng / hái quả / câu cá / nhặt củi / nhặt đá cuội: đi tới cạnh
## vật → làm → khuân về kho. Cách làm từng loại (thời gian, sản lượng, hoạt họa, đồ cầm tay)
## đọc từ JobDefs. Việc có `batch` (nhặt củi, đá cuội) thì nhặt thêm vài cái nằm sát bên
## cho đầy bó / đầy xô rồi mới khuân về một thể.

enum Step { GO, WORK, CARRY }

const STAND_CLOSER: float = 0.3 # 0 = giữa ô đứng, 1 = ngay chỗ vật
## Nhặt thêm củi / đá cuội nằm trong chừng này ô quanh cái vừa nhặt.
const BATCH_RADIUS_CELLS: float = 3.0
## Đồ nằm trên đất: đứng lệch sang bên một chút để cúi xuống nhặt cho tự nhiên.
const LOOSE_STAND_OFFSET: float = 18.0

var _node: ResourceNode
var _collected: int = 0


func _init(owner_job: Job, node: ResourceNode) -> void:
	super(owner_job)
	_node = node
	kind = &"harvest"


func start() -> void:
	hold_job_item()
	if not _go_to(_node):
		fail()


func tick(delta: float) -> Status:
	if _failed:
		return Status.FAILED
	match step:
		Step.GO:
			if villager.is_moving():
				return Status.RUNNING
			# Tới nơi mà đã hết (vd người khác vừa nhặt) — không tính là hỏng, lượt sau tìm cái khác.
			if not _node.can_harvest():
				return _finish_batch()
			villager.face_towards(_node.position)
			begin_work(float(job.def()["seconds"]))
			step = Step.WORK
		Step.WORK:
			if not tick_work(delta):
				return Status.RUNNING
			var amount: int = _node.harvest(int(job.def().get("amount", 1)))
			world().reservations.release(_node, villager)
			_collected += amount
			if amount <= 0:
				return _finish_batch()
			if _collected < int(job.def().get("batch", 0)) and _next_in_batch():
				return Status.RUNNING
			begin_carry(job.def()["item"], _collected)
			step = Step.CARRY
		Step.CARRY:
			return tick_carry(delta)
	return Status.RUNNING


func stop() -> void:
	super.stop()
	world().reservations.release(_node, villager)
	# Bị ngắt giữa lúc đang nhặt dở một xô: số đã nhặt vẫn còn, lượt sau khuân nốt.
	if not is_carrying() and _collected > 0:
		job.carried_item = job.def()["item"]
		job.carried_count = _collected


func impact_target() -> Node2D:
	return _node


func _go_to(node: ResourceNode) -> bool:
	if not world().reservations.reserve(node, villager):
		return false
	_node = node
	step = Step.GO
	if node.is_loose():
		var side: float = -1.0 if villager.position.x < node.position.x else 1.0
		return villager.move_to_cell(node.cell, node.position + Vector2(side * LOOSE_STAND_OFFSET, 2.0))
	var stand: Vector2i = world().finder.find_stand_cell(node.cell, villager, true)
	if stand == World.INVALID_CELL:
		return false
	# Đứng nhích lại gần vật một chút cho nhát rìu/cuốc chạm tới.
	var close_point: Vector2 = WorldGrid.cell_to_world(stand).lerp(node.position, STAND_CLOSER)
	return villager.move_to_cell(stand, close_point)


# Còn chỗ trong bó/xô: sang cái gần bên. Trả về false nếu quanh đây không còn cái nào.
func _next_in_batch() -> bool:
	var next: Node2D = world().finder.find_job_target(job.job_id, _node.cell, villager, [], BATCH_RADIUS_CELLS)
	if next == null:
		return false
	villager.rig.play(VillagerRig.ANIM_IDLE)
	villager.state = Villager.State.MOVING
	return _go_to(next as ResourceNode)


# Hết thứ để làm giữa chừng: đã nhặt được gì thì khuân về, không thì xong lượt.
func _finish_batch() -> Status:
	world().reservations.release(_node, villager)
	if _collected <= 0:
		return Status.DONE
	begin_carry(job.def()["item"], _collected)
	step = Step.CARRY
	return Status.RUNNING
