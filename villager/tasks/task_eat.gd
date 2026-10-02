class_name TaskEat
extends Task
## Đói thì đi ăn: vừa đi tới bếp (lửa trại; Đợt 3 Bếp) vừa nghĩ tới đồ ăn, lấy một phần
## rồi ăn tại chỗ. Ăn xong no căng, vui lên chút và đỡ mệt chút. Không quan tâm nguồn là
## gì — FoodSource lo phần đó.

enum Step { GO, FETCH, EAT }

const THOUGHT_ICON: String = "icons/res_food"

var _source: FoodSource
var _restore: float = 0.0


func _init(source: FoodSource) -> void:
	_source = source
	kind = &"eat"
	priority = Priority.NEED


func start() -> void:
	if _source == null:
		fail()
		return
	_source.reserve(villager, world().reservations)
	var stand: Vector2i = world().finder.find_stand_cell(_source.target_cell, villager)
	if stand == World.INVALID_CELL or not villager.move_to_cell(stand):
		fail()
		return
	villager.think(THOUGHT_ICON, Villager.UNTIL_CLEARED)
	step = Step.GO


func tick(delta: float) -> Status:
	if _failed:
		return Status.FAILED
	match step:
		Step.GO:
			if villager.is_moving():
				return Status.RUNNING
			if not _source.is_available(villager):
				return Status.FAILED
			villager.clear_bubble()
			villager.face_towards(_source.target.position)
			villager.rig.play(_source.fetch_anim())
			villager.state = Villager.State.WORKING
			timer = _source.fetch_seconds(villager)
			step = Step.FETCH
		Step.FETCH:
			timer -= delta
			if timer > 0.0:
				return Status.RUNNING
			_restore = _source.take()
			if _restore <= 0.0:
				return Status.FAILED
			villager.rig.set_held_item(_source.taken_icon)
			villager.rig.play(VillagerRig.ANIM_EAT)
			villager.state = Villager.State.EATING
			timer = Balance.EAT_SECONDS
			step = Step.EAT
		Step.EAT:
			timer -= delta
			if timer > 0.0:
				return Status.RUNNING
			villager.status.add_hunger(_restore)
			villager.status.add_fun((Balance.FUN_EAT + _source.taken_fun) * Traits.modifier(villager.data.traits, "eat_joy"))
			villager.status.add_energy(Balance.EAT_ENERGY)
			villager.emote("icons/happy")
			return Status.DONE
	return Status.RUNNING


func stop() -> void:
	if step == Step.GO:
		villager.clear_bubble()
	if _source != null:
		_source.release(villager, world().reservations)
	villager.rig.set_held_item("")


func activity_key() -> String:
	return "UI_ACTIVITY_EAT"


func icon_key() -> String:
	return "icons/res_food"
