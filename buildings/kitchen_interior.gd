class_name KitchenInterior
extends RefCounted
## Hình tách lớp và chỗ đứng trong sân bếp. Ghế/cọc nấu được giữ riêng từng người.

var building: Building
var seats: Dictionary[int, int] = {}
var cooks: Dictionary[int, int] = {}
var _layers: Array[Sprite2D] = []
var _art_level: int = -1
var _meals: Node2D

func _init(owner: Building) -> void:
	building = owner
	building.stock_changed.connect(_refresh_meals)

func entry_cell() -> Vector2i:
	return KitchenLayout.entry_cell(building.origin_cell)

func point(raw: Vector2) -> Vector2:
	return building.position + KitchenLayout.local_point(raw, building.level)

func raw_point(at: Vector2) -> Vector2:
	return Vector2(192, 192) + ((at - building.position) / ArtLibrary.ART_SCALE + KitchenLayout.PIVOT - Vector2(192, 192)) / KitchenLayout.YARD_SCALE[building.level - 1]

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
	else:
		if seats.erase(person.id):
			building.changed.emit(building)

func seat(person: Villager) -> Vector2:
	return KitchenLayout.seat_raw(building.level, seats[person.id])

func cooking_spot(person: Villager) -> Vector2:
	return KitchenLayout.cook_raw(building.level, cooks[person.id])

func move_inside(person: Villager, destination: Vector2) -> bool:
	var entrance: Vector2 = Vector2(138, 318)
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
	var entrance: Vector2 = Vector2(138, 318)
	for at: Vector2 in KitchenLayout.route(raw_point(person.position), entrance, building.level):
		result.append(point(at))
	result.append(WorldGrid.cell_to_world(entry_cell()))
	return result

func refresh() -> void:
	if _art_level == building.level:
		return
	_art_level = building.level
	for picture: Sprite2D in _layers:
		picture.queue_free()
	_layers.clear()
	if _meals != null:
		_meals.queue_free()
		_meals = null
	if not building.is_built():
		return
	var key: String = str(building.level)
	_layer("floor_" + key, Vector2(192, 64))
	_layer("fence_back_" + key, Vector2(192, 90))
	_layer("cook_" + key, Vector2(88, 176))
	_layer("roof_" + key, Vector2(88, 235))
	_layer("steam_" + key, Vector2(88, 236))
	_layer("pole_" + key, Vector2(60, 229))
	_layer("serving_" + key, Vector2(58, 276))
	_layer("seats_" + key, Vector2(192, 100))
	for index: int in KitchenLayout.CENTERS[building.level - 1].size():
		var center: Vector2 = KitchenLayout.CENTERS[building.level - 1][index]
		_layer("dining_" + key + "_" + str(index), center + Vector2(0, 27))
	_layer("fence_front_" + key, Vector2(192, 308))
	_meals = Node2D.new()
	_meals.position = KitchenLayout.local_point(Vector2(58, 277), building.level)
	building.add_child(_meals)
	for index: int in 6:
		var meal: Sprite2D = Sprite2D.new()
		ArtLibrary.setup_sprite(meal, ResourceDefs.icon(ResourceDefs.MEAL))
		meal.scale *= 0.22
		meal.position = KitchenLayout.local_point(Vector2(43 + (index % 3) * 14, 248 + floori(index / 3.0) * 9), building.level) - _meals.position
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

func _layer(name: String, sort_at: Vector2, depth: int = 0) -> void:
	var picture: Sprite2D = Sprite2D.new()
	ArtLibrary.setup_sprite(picture, "buildings/kitchen/" + name)
	picture.position = KitchenLayout.local_point(sort_at, building.level)
	picture.offset -= picture.position / ArtLibrary.ART_SCALE
	picture.z_index = depth
	building.add_child(picture)
	_layers.append(picture)
