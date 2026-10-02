class_name TaskHunt
extends TaskWork
## Một lượt đi săn: đuổi theo con thú (nó thấy người tới gần thì giật mình đứng im) →
## vung giáo một lúc → thú ngất, "bụp" → khuân thịt về chỗ cất đồ ăn.
## Thú di chuyển nên đường đi được tính lại, nhưng chỉ khi nó đã đi xa khỏi đích cũ và
## không quá mỗi REPATH_SECONDS một lần (AStar tốn công).

enum Step { CHASE, ATTACK, CARRY }

const REPATH_SECONDS: float = 1.0
const ATTACK_RANGE: float = 60.0 # px — đứng gần chừng này thì bắt đầu vung giáo
const STAND_OFFSET: float = 44.0 # px — đứng lệch sang một bên con thú
const REPATH_DRIFT_CELLS: int = 1

var _animal: Animal
var _goal_cell: Vector2i = World.INVALID_CELL
var _repath_timer: float = 0.0


func _init(owner_job: Job, animal: Animal) -> void:
	super(owner_job)
	_animal = animal
	kind = &"hunt"


func start() -> void:
	if not world().reservations.reserve(_animal, villager) or not _repath():
		fail()
		return
	step = Step.CHASE


func tick(delta: float) -> Status:
	if _failed:
		return Status.FAILED
	match step:
		Step.CHASE:
			if not _animal.is_huntable():
				return Status.DONE
			var distance: float = villager.position.distance_to(_animal.position)
			if distance <= Balance.ANIMAL_ALERT_CELLS * Balance.TILE_SIZE:
				_animal.alert(villager.position)
			if distance <= ATTACK_RANGE:
				villager.stop_moving()
				villager.face_towards(_animal.position)
				begin_work(float(job.def()["seconds"]))
				step = Step.ATTACK
				return Status.RUNNING
			_repath_timer -= delta
			var drifted: bool = (_animal.current_cell() - _goal_cell).length() > REPATH_DRIFT_CELLS
			if _repath_timer <= 0.0 and (drifted or not villager.is_moving()):
				if not _repath():
					return Status.FAILED
		Step.ATTACK:
			if not _animal.is_huntable():
				return Status.DONE
			_animal.alert(villager.position)
			if not tick_work(delta):
				return Status.RUNNING
			if not _animal.knock_out():
				return Status.DONE
			world().reservations.release(_animal, villager)
			villager.emote("icons/happy")
			begin_carry(job.def()["resource"], int(job.def()["amount"]))
			step = Step.CARRY
		Step.CARRY:
			return tick_carry(delta)
	return Status.RUNNING


func stop() -> void:
	super.stop()
	world().reservations.release(_animal, villager)


func _repath() -> bool:
	_repath_timer = REPATH_SECONDS
	_goal_cell = _animal.current_cell()
	var side: float = -1.0 if villager.position.x < _animal.position.x else 1.0
	return villager.move_to_cell(_goal_cell, _animal.position + Vector2(side * STAND_OFFSET, 0))
