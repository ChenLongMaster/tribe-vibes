class_name TaskEat
extends Task
## Đói thì đi ăn: vừa đi tới bếp (lửa trại, Bếp, hay hang đá cất thức ăn thô) vừa nghĩ tới
## đồ ăn, lấy một phần
## rồi ăn tại chỗ. Ăn xong no căng, vui lên chút và đỡ mệt chút. Không quan tâm nguồn là
## gì — FoodSource lo phần đó.

enum Step { GO, ENTER, FETCH, SEAT, EAT, EXIT }

const THOUGHT_ICON: String = "icons/res_food"

var _source: FoodSource
var _restore: float = 0.0
var _kitchen: KitchenInterior


func _init(source: FoodSource) -> void:
	_source = source
	kind = &"eat"
	priority = Priority.NEED


func start() -> void:
	if _source == null:
		fail()
		return
	_source.reserve(villager, world().reservations)
	if _source.target is Building:
		_kitchen = (_source.target as Building).kitchen
		if _kitchen != null and not _kitchen.seats.has(villager.id):
			fail()
			return
	if _kitchen != null and villager.interior == _kitchen.building:
		if not _kitchen.move_inside(villager, KitchenLayout.fetch_point(_kitchen.building.level)):
			fail()
		step = Step.ENTER
		return
	var stand: Vector2i = World.INVALID_CELL
	if _source.target is Building:
		stand = world().finder.find_building_stand_cell(_source.target as Building, villager)
	else:
		stand = world().finder.find_stand_cell(_source.target_cell, villager)
	if stand == World.INVALID_CELL or not villager.move_to_cell(stand):
		fail()
		return
	villager.think(THOUGHT_ICON, Villager.UNTIL_CLEARED)
	step = Step.GO


func tick(delta: float) -> Status:
	if _failed:
		return Status.FAILED
	if _kitchen != null and not _kitchen.building.is_built():
		return Status.FAILED
	match step:
		Step.GO:
			if villager.is_moving():
				return Status.RUNNING
			if not _source.is_available(villager):
				return Status.FAILED
			if _kitchen != null:
				if not _kitchen.move_inside(villager, KitchenLayout.fetch_point(_kitchen.building.level)):
					return Status.FAILED
				step = Step.ENTER
			else:
				_begin_fetch()
		Step.ENTER:
			if not villager.is_moving():
				if not _source.is_available(villager):
					return Status.FAILED
				_begin_fetch()
		Step.FETCH:
			timer -= delta
			if timer > 0.0:
				return Status.RUNNING
			_restore = _source.take()
			if _restore <= 0.0:
				return Status.FAILED
			villager.rig.set_held_item(_source.taken_icon)
			if _kitchen != null:
				if not _kitchen.move_inside(villager, _kitchen.seat(villager)):
					return Status.FAILED
				step = Step.SEAT
			else:
				_begin_eat()
		Step.SEAT:
			if not villager.is_moving():
				_begin_eat()
		Step.EAT:
			timer -= delta
			if timer > 0.0:
				return Status.RUNNING
			villager.status.add_hunger(_restore)
			villager.status.add_fun((Balance.FUN_EAT + _source.taken_fun) * Traits.modifier(villager.data.traits, "eat_joy"))
			villager.status.add_energy(Balance.EAT_ENERGY)
			villager.emote("icons/happy")
			if _kitchen != null:
				villager.rig.seated_eating = false
				villager.rig.eating_seat_lift = 0.0
				villager.rig.set_held_item("")
				if not villager.move_to_cell(_kitchen.entry_cell()):
					return Status.FAILED
				step = Step.EXIT
			else:
				return Status.DONE
		Step.EXIT:
			if not villager.is_moving():
				return Status.DONE
	return Status.RUNNING


func _begin_fetch() -> void:
	villager.clear_bubble()
	villager.face_towards(_kitchen.point(KitchenLayout.serving_center(_kitchen.building.level)) if _kitchen != null else _source.target.position)
	villager.rig.play(_source.fetch_anim())
	villager.state = Villager.State.WORKING
	timer = _source.fetch_seconds(villager)
	step = Step.FETCH


func refresh_layout() -> void:
	if villager.interior != _kitchen.building:
		return
	if step == Step.EAT or step == Step.SEAT:
		villager.rig.seated_eating = false
		villager.rig.eating_seat_lift = 0.0
		if not _kitchen.move_inside(villager, _kitchen.seat(villager)):
			fail()
		step = Step.SEAT
	elif step == Step.ENTER or step == Step.FETCH:
		if not _kitchen.move_inside(villager, KitchenLayout.fetch_point(_kitchen.building.level)):
			fail()
		step = Step.ENTER
	elif step == Step.EXIT:
		if not villager.move_to_cell(_kitchen.entry_cell()):
			fail()


func _begin_eat() -> void:
	villager.rig.eating_seat_lift = 0.0
	if _kitchen != null and _kitchen.building.level > 1:
		var surface: Vector2 = KitchenLayout.seat_surface_raw(_kitchen.building.level, _kitchen.seats[villager.id])
		var height: float = _kitchen.point(_kitchen.seat(villager)).y - _kitchen.point(surface).y
		# Tính theo cỡ thật cả người lớn/trẻ con; hông ngồi bệt ở Y=-5 trong rig.
		villager.rig.eating_seat_lift = maxf(0.0, height / villager.rig.global_scale.y - 5.0)
	villager.rig.seated_eating = _kitchen != null
	if _kitchen != null:
		villager.rig.set_facing(1.0 if _kitchen.seats[villager.id] % 2 == 0 else -1.0)
	villager.rig.play(VillagerRig.ANIM_EAT)
	villager.state = Villager.State.EATING
	timer = Balance.EAT_SECONDS
	step = Step.EAT


func stop() -> void:
	villager.rig.seated_eating = false
	villager.rig.eating_seat_lift = 0.0
	if step == Step.GO:
		villager.clear_bubble()
	if _source != null:
		_source.release(villager, world().reservations)
	villager.rig.set_held_item("")


func activity_key() -> String:
	return "UI_ACTIVITY_EAT"


func icon_key() -> String:
	return "icons/res_food"
