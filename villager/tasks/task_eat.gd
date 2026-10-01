class_name TaskEat
extends Task
## Đi tới bụi quả gần nhất còn quả, hái rồi ăn ngay tại chỗ.
## `urgent` = đói lắm rồi (ưu tiên cao, có bong bóng "Đói quá!"); không thì là ăn vặt.

enum Step { GO, PICK, EAT }

var urgent: bool = false
var _bush: ResourceNode
var _berries: int = 0


func _init(is_urgent: bool) -> void:
	urgent = is_urgent
	kind = &"eat" if urgent else &"snack"
	priority = Priority.NEED if urgent else Priority.IDLE


func start() -> void:
	_bush = world().finder.find_bush_for(villager)
	if _bush == null:
		fail()
		return
	world().reservations.reserve(_bush, villager)
	var stand: Vector2i = world().finder.find_stand_cell(_bush.cell, villager)
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
			if _bush.is_depleted():
				return Status.FAILED
			villager.face_towards(_bush.position)
			villager.rig.play(VillagerRig.ANIM_GATHER)
			villager.state = Villager.State.WORKING
			timer = Balance.PICK_SECONDS / work_speed(&"GATHER")
			step = Step.PICK
		Step.PICK:
			timer -= delta
			if timer > 0.0:
				return Status.RUNNING
			_berries = _bush.take_berries()
			if _berries <= 0:
				return Status.FAILED
			villager.rig.set_held_item("icons/berry")
			villager.rig.play(VillagerRig.ANIM_EAT)
			villager.state = Villager.State.EATING
			timer = Balance.EAT_SECONDS
			step = Step.EAT
		Step.EAT:
			timer -= delta
			if timer > 0.0:
				return Status.RUNNING
			var data: VillagerData = villager.data
			data.hunger = minf(data.hunger + _berries * Balance.BERRY_HUNGER, VillagerData.MAX_NEED)
			data.fun = minf(data.fun + Balance.FUN_EAT * Traits.modifier(data.traits, "eat_joy"), VillagerData.MAX_NEED)
			villager.overhead.show_emote("icons/happy")
			return Status.DONE
	return Status.RUNNING


func stop() -> void:
	if _bush != null:
		world().reservations.release(_bush, villager)
	villager.rig.set_held_item("")


func activity_key() -> String:
	return "UI_ACTIVITY_EAT" if urgent else "UI_ACTIVITY_SNACK"


func icon_key() -> String:
	return "icons/berry"
