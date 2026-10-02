class_name TaskPickFlower
extends Task
## Hái một bông hoa dưới chân (trong vùng dạo chơi), đứng ngắm một lát rồi thả xuống.
## Mang hoa đi tặng là một phần hoạt cảnh tìm bạn đời (Đợt 4), không nằm ở đây.

enum Step { GO, PICK, ADMIRE }

const PICK_SECONDS: float = 1.5
const ADMIRE_SECONDS: float = 2.5
## Đứng lệch sang trái bông hoa một chút để không giẫm lên nó.
const STAND_OFFSET: Vector2 = Vector2(-14, 4)

var _flower_key: String = ""


func _init() -> void:
	kind = &"pick_flower"


func start() -> void:
	var flower: Dictionary = world().finder.find_flower_near(villager)
	if flower.is_empty():
		fail()
		return
	var pos: Vector2 = flower["pos"]
	_flower_key = "env/flower_%02d" % (int(flower["variant"]) + 1)
	if not villager.move_to_cell(WorldGrid.world_to_cell(pos), pos + STAND_OFFSET):
		fail()


func tick(delta: float) -> Status:
	if _failed:
		return Status.FAILED
	match step:
		Step.GO:
			if villager.is_moving():
				return Status.RUNNING
			villager.rig.play(VillagerRig.ANIM_GATHER)
			timer = PICK_SECONDS
			step = Step.PICK
		Step.PICK:
			timer -= delta
			if timer > 0.0:
				return Status.RUNNING
			villager.rig.set_held_item(_flower_key)
			villager.rig.play(VillagerRig.ANIM_HOLD)
			villager.rig.squash(-0.1)
			villager.status.add_fun(Balance.FUN_FLOWER)
			villager.emote("icons/happy")
			timer = ADMIRE_SECONDS
			step = Step.ADMIRE
		Step.ADMIRE:
			timer -= delta
			if timer <= 0.0:
				return Status.DONE
	return Status.RUNNING


func stop() -> void:
	villager.rig.set_held_item("")


func activity_key() -> String:
	return "UI_ACTIVITY_FLOWER"
