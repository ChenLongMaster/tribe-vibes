class_name TaskPickFlower
extends Task
## Đi tới một bông hoa gần đó, cúi xuống hái, đứng ngắm. Người Lãng mạn thì mang
## hoa tặng ai đó gần nhất — cả hai bật tim và vui hơn.

enum Step { GO, PICK, ADMIRE, GIVE_GO, GIVE }

const PICK_SECONDS: float = 1.5
const ADMIRE_SECONDS: float = 2.5
const GIVE_SECONDS: float = 1.6
const GIVE_RANGE_CELLS: float = 8.0
## Đứng lệch sang trái bông hoa một chút để không giẫm lên nó.
const STAND_OFFSET: Vector2 = Vector2(-14, 4)

var _flower_key: String = ""
var _receiver: Villager


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
			villager.data.fun = minf(villager.data.fun + Balance.FUN_FLOWER, VillagerData.MAX_NEED)
			villager.overhead.show_emote("icons/happy")
			_receiver = _find_receiver()
			if _receiver != null:
				var stand: Vector2i = world().finder.find_stand_cell(world().cell_of(_receiver), villager)
				if stand != World.INVALID_CELL and villager.move_to_cell(stand):
					step = Step.GIVE_GO
					return Status.RUNNING
			timer = ADMIRE_SECONDS
			step = Step.ADMIRE
		Step.ADMIRE:
			timer -= delta
			if timer <= 0.0:
				return Status.DONE
		Step.GIVE_GO:
			if villager.is_moving():
				return Status.RUNNING
			villager.face_towards(_receiver.position)
			_receiver.face_towards(villager.position)
			villager.overhead.pop_heart()
			_receiver.overhead.pop_heart()
			_receiver.data.fun = minf(_receiver.data.fun + Balance.FUN_GIVE_FLOWER, VillagerData.MAX_NEED)
			villager.data.fun = minf(villager.data.fun + Balance.FUN_GIVE_FLOWER, VillagerData.MAX_NEED)
			timer = GIVE_SECONDS
			step = Step.GIVE
		Step.GIVE:
			timer -= delta
			if timer <= 0.0:
				return Status.DONE
	return Status.RUNNING


func stop() -> void:
	villager.rig.set_held_item("")


func _find_receiver() -> Villager:
	# Chỉ người Lãng mạn mới mang hoa đi tặng.
	if Traits.modifier(villager.data.traits, "romance") <= 1.0:
		return null
	return world().finder.find_villager_near(villager, GIVE_RANGE_CELLS)


func activity_key() -> String:
	return "UI_ACTIVITY_GIVE_FLOWER" if step >= Step.GIVE_GO and _receiver != null else "UI_ACTIVITY_FLOWER"


func activity_args() -> Dictionary:
	return {"name": _receiver.data.display_name} if _receiver != null else {}
