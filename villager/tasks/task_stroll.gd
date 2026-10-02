class_name TaskStroll
extends Task
## Rảnh thì dạo vài bước trong vùng nhỏ quanh điểm neo rồi đứng ngó nghiêng một lát.
## (Chế độ Normal: thổ dân nghe lời không tự đi lung tung.)

enum Step { GO, PAUSE }

const PAUSE_MIN: float = 1.0
const PAUSE_MAX: float = 3.0


func _init() -> void:
	kind = &"stroll"


func start() -> void:
	var target: Vector2i = world().finder.random_idle_cell(villager)
	if target == World.INVALID_CELL or not villager.move_to_cell(target):
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
			villager.rig.play(VillagerRig.ANIM_IDLE)
			timer = randf_range(PAUSE_MIN, PAUSE_MAX)
			step = Step.PAUSE
		Step.PAUSE:
			timer -= delta
			if timer <= 0.0:
				return Status.DONE
	return Status.RUNNING


func activity_key() -> String:
	return "UI_ACTIVITY_STROLL"
