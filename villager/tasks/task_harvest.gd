class_name TaskHarvest
extends TaskWork
## Một lượt chặt cây / đập đá tảng / hái quả / câu cá / nhặt củi / nhặt sỏi: đi tới cạnh mỏ →
## làm → khuân về kho. Cách làm từng loại (thời gian, sản lượng, hoạt họa, đồ cầm tay) đọc từ
## JobDefs. Việc có `batch` (hái quả, nhặt củi, nhặt sỏi) thì làm liền nhiều lần ở cùng mỏ cho
## đầy giỏ / bó / xô rồi mới khuân về một thể (mỏ hết giữa chừng thì sang mỏ sát bên).
## Nhiều người làm chung một mỏ: mỗi người giữ một chỗ (Reservations theo max_workers) và đứng
## một chỗ riêng quanh mỏ.

enum Step { GO, WORK, CARRY }

const STAND_CLOSER: float = 0.3 # 0 = giữa ô đứng, 1 = ngay chỗ vật
## Mỏ hết giữa lượt: nhặt / hái tiếp ở mỏ cùng loại trong chừng này ô.
const BATCH_RADIUS_CELLS: float = 3.0
## Đồ nằm trên đất (bãi sỏi, đống củi): đứng lệch sang bên để cúi xuống nhặt cho tự nhiên.
const LOOSE_STAND_OFFSET: float = 30.0
## Hai người nhặt chung một đống: người thứ hai đứng phía bên kia.
const LOOSE_SIDES: Array[Vector2i] = [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(0, -1)]

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
			# Tới nơi mà đã hết (vd người khác vừa nhặt nốt) — không tính là hỏng, lượt sau tìm cái khác.
			if not _node.can_harvest():
				return _finish_batch()
			_begin_round()
		Step.WORK:
			if not tick_work(delta):
				return Status.RUNNING
			var amount: int = _node.harvest(int(job.def().get("amount", 1)))
			_collected += amount
			if amount <= 0:
				return _finish_batch()
			if _collected < _batch_size():
				# Còn chỗ trong giỏ / xô: làm tiếp ngay tại mỏ này, hết thì sang mỏ sát bên.
				if _node.can_harvest():
					_begin_round()
					return Status.RUNNING
				if _next_in_batch():
					return Status.RUNNING
			_leave_node()
			begin_carry(job.def()["item"], _collected)
			step = Step.CARRY
		Step.CARRY:
			return tick_carry(delta)
	return Status.RUNNING


func stop() -> void:
	super.stop()
	_leave_node()
	# Bị ngắt giữa lúc đang nhặt dở một xô: số đã nhặt vẫn còn, lượt sau khuân nốt.
	if not is_carrying() and _collected > 0:
		job.carried_item = job.def()["item"]
		job.carried_count = _collected


func impact_target() -> Node2D:
	return _node


func _begin_round() -> void:
	villager.face_towards(_node.position)
	begin_work(float(job.def()["seconds"]))
	step = Step.WORK


func _batch_size() -> int:
	return int(job.def().get("batch", 0))


func _go_to(node: ResourceNode) -> bool:
	if not world().reservations.reserve(node, villager, node.max_workers()):
		return false
	_node = node
	step = Step.GO
	var taken: Array[Vector2i] = node.stands_taken_by_others(villager)
	if node.is_loose():
		# Đứng một phía của đống (trái / phải trước, rồi dưới / trên) chưa ai đứng.
		var side: Vector2i = Vector2i(-1, 0) if villager.position.x < node.position.x else Vector2i(1, 0)
		if taken.has(side):
			for option: Vector2i in LOOSE_SIDES:
				if not taken.has(option):
					side = option
					break
		node.claim_stand(villager, side)
		var offset: Vector2 = Vector2(side) * Vector2(LOOSE_STAND_OFFSET, LOOSE_STAND_OFFSET * 0.5)
		return villager.move_to_cell(node.cell, node.position + offset + Vector2(0, 2))
	var stand: Vector2i = world().finder.find_stand_cell(node.cell, villager, true, taken)
	if stand == World.INVALID_CELL:
		return false
	node.claim_stand(villager, stand)
	# Đứng nhích lại gần vật một chút cho nhát rìu/cuốc chạm tới.
	var close_point: Vector2 = WorldGrid.cell_to_world(stand).lerp(node.position, STAND_CLOSER)
	return villager.move_to_cell(stand, close_point)


func _leave_node() -> void:
	if _node == null:
		return
	world().reservations.release(_node, villager)
	_node.release_stand(villager)


# Mỏ vừa hết mà giỏ / xô chưa đầy: sang mỏ cùng loại sát bên. false nếu quanh đây không còn.
func _next_in_batch() -> bool:
	var next: Node2D = world().finder.find_job_target(job.job_id, _node.cell, villager, [], BATCH_RADIUS_CELLS)
	if next == null:
		return false
	_leave_node()
	villager.rig.play(VillagerRig.ANIM_IDLE)
	villager.state = Villager.State.MOVING
	return _go_to(next as ResourceNode)


# Hết thứ để làm giữa chừng: đã nhặt được gì thì khuân về, không thì xong lượt.
func _finish_batch() -> Status:
	_leave_node()
	if _collected <= 0:
		return Status.DONE
	begin_carry(job.def()["item"], _collected)
	step = Step.CARRY
	return Status.RUNNING
