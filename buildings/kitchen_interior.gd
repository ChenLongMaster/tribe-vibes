class_name KitchenInterior
extends RefCounted
## Hình tách lớp và chỗ đứng trong sân bếp. Ghế/cọc nấu được giữ riêng từng người.

var building: Building
var seats: Dictionary[int, int] = {}
var cooks: Dictionary[int, int] = {}
var _visual: Node2D
var _layers: Array[Sprite2D] = []
var _art_level: int = -1
var _meals: Node2D
var _canopy: Node2D
var _roast: KitchenRoastDecor

func _init(owner: Building) -> void:
	building = owner
	building.stock_changed.connect(_refresh_meals)

func entry_cell() -> Vector2i:
	return KitchenLayout.entry_cell(building.origin_cell)

func point(raw: Vector2) -> Vector2:
	return building.position + KitchenLayout.local_point(raw, building.level)

func raw_point(at: Vector2) -> Vector2:
	return Vector2(192, 192) + (((at - building.position) / ArtLibrary.ART_SCALE + KitchenLayout.PIVOT - KitchenLayout.FRAME_PADDING) / KitchenLayout.EXPANSION - Vector2(192, 192)) / KitchenLayout.YARD_SCALE[building.level - 1]

func has_seat(person: Villager) -> bool:
	return building.is_built() and (seats.has(person.id) or seats.size() < KitchenLayout.seat_count(building.level))

func reserve(person: Villager, cooking: bool = false) -> bool:
	var slots: Dictionary[int, int] = cooks if cooking else seats
	if slots.has(person.id):
		return true
	var capacity: int = building.staff_capacity() if cooking else KitchenLayout.seat_count(building.level)
	for slot: int in capacity:
		if not slots.values().has(slot):
			slots[person.id] = slot
			if not cooking:
				building.changed.emit(building)
			return true
	return false

func release(person: Villager, cooking: bool = false) -> void:
	if cooking:
		cooks.erase(person.id)
		# Còn một người thì trở về nồi chính, không bỏ người duy nhất ở giá quay.
		if cooks.size() == 1:
			var remaining_id: int = cooks.keys()[0]
			if cooks[remaining_id] != 0:
				cooks[remaining_id] = 0
				var remaining: Villager = Commands.get_villager(remaining_id)
				if remaining != null and remaining.task is TaskCook:
					(remaining.task as TaskCook).refresh_layout()
	else:
		if seats.erase(person.id):
			building.changed.emit(building)

func seat(person: Villager) -> Vector2:
	return KitchenLayout.seat_raw(building.level, seats[person.id])

func cooking_spot(person: Villager) -> Vector2:
	return KitchenLayout.cook_raw(building.level, cooks[person.id])

func move_inside(person: Villager, destination: Vector2) -> bool:
	var entrance: Vector2 = KitchenLayout.marker_raw("Entry", building.level)
	var start: Vector2 = raw_point(person.position) if person.interior == building else entrance
	var raw_path: PackedVector2Array = KitchenLayout.route(start, destination, building.level)
	if raw_path.is_empty():
		return false
	var path: PackedVector2Array = PackedVector2Array()
	if person.interior != building:
		path.append(point(entrance))
	for at: Vector2 in raw_path:
		path.append(point(at))
	person.interior = building
	person.follow_path(path)
	return true

func exit_path(person: Villager) -> PackedVector2Array:
	var result: PackedVector2Array = PackedVector2Array()
	var entrance: Vector2 = KitchenLayout.marker_raw("Entry", building.level)
	for at: Vector2 in KitchenLayout.route(raw_point(person.position), entrance, building.level):
		result.append(point(at))
	result.append(WorldGrid.cell_to_world(entry_cell()))
	return result

func refresh() -> void:
	if _art_level == building.level:
		return
	_art_level = building.level
	_layers.clear()
	if _visual != null:
		building.remove_child(_visual)
		_visual.queue_free()
		_visual = null
	_canopy = null
	_roast = null
	_meals = null
	if not building.is_built():
		return
	_visual = KitchenLayout.SCENES[building.level - 1].instantiate() as Node2D
	_visual.name = "KitchenVisuals"
	building.add_child(_visual)
	_collect_sprites(_visual)
	_canopy = _visual.get_node("CookingCanopy") as Node2D
	var roast_group: Node2D = _visual.get_node("RoastFire") as Node2D
	_roast = KitchenRoastDecor.new()
	roast_group.add_child(_roast)
	_roast.setup(roast_group.get_node("Chicken") as Sprite2D, roast_group.get_node("Fire") as Sprite2D, (roast_group.get_node("Smoke") as Node2D).position, KitchenLayout.YARD_SCALE[building.level - 1])
	var serving: Node2D = _visual.get_node("Serving") as Node2D
	_meals = Node2D.new()
	serving.add_child(_meals)
	for index: int in 6:
		var meal: Sprite2D = Sprite2D.new()
		ArtLibrary.setup_sprite(meal, ResourceDefs.icon(ResourceDefs.MEAL))
		meal.scale *= 0.22
		meal.position = (serving.get_node("Meal" + str(index)) as Node2D).position
		_meals.add_child(meal)
	_refresh_meals(building)
	# Nâng cấp đổi cỡ sân/bàn: khách và đầu bếp đi sang điểm mới, vẫn giữ phần đang làm.
	for person_id: int in seats:
		var person: Villager = Commands.get_villager(person_id)
		if person != null and person.task is TaskEat:
			(person.task as TaskEat).refresh_layout()
	for person_id: int in cooks:
		var person: Villager = Commands.get_villager(person_id)
		if person != null and person.task is TaskCook:
			(person.task as TaskCook).refresh_layout()

func _refresh_meals(_owner: Building) -> void:
	if _meals == null:
		return
	for index: int in _meals.get_child_count():
		(_meals.get_child(index) as Sprite2D).visible = index < building.stock_of(ResourceDefs.MEAL)

func selection_sprites() -> Array[Sprite2D]:
	return _layers.duplicate()

func _collect_sprites(node: Node) -> void:
	if node is Sprite2D:
		_layers.append(node as Sprite2D)
	for child: Node in node.get_children():
		_collect_sprites(child)

func sync_shadow(sprite: Sprite2D) -> void:
	if _visual == null:
		return
	var roof: Sprite2D = _visual.get_node("CookingCanopy/Roof") as Sprite2D
	sprite.texture = roof.texture
	sprite.offset = roof.get("art_offset")
	sprite.centered = false
	sprite.region_enabled = false
	sprite.transform = building.global_transform.affine_inverse() * roof.global_transform
