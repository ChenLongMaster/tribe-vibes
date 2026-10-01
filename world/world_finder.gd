class_name WorldFinder
extends RefCounted
## Các câu hỏi "tìm chỗ" của thổ dân: bụi quả gần nhất còn quả, chỗ đứng cạnh một vật,
## chỗ ngủ quanh lửa trại, chỗ đi dạo, bông hoa, bạn tán gẫu… Tách khỏi World để
## World chỉ lo dựng và giữ thế giới.

const WANDER_ATTEMPTS: int = 12
const FREE_CELL_ATTEMPTS: int = 24
## Việc rảnh có thể bị ngắt để đi tán gẫu.
const CHATTABLE_KINDS: Array[StringName] = [&"wander", &"sit", &"scratch"]

var _world: World
var _flowers: Array[Dictionary] = []


func _init(world: World) -> void:
	_world = world
	for item: Dictionary in world.map_data.decor:
		if item["kind"] == MapData.DECOR_FLOWER:
			_flowers.append(item)


## Bụi còn quả, chưa ai nhận, gần nhất và đứng hái được.
func find_bush_for(villager: Villager) -> ResourceNode:
	var candidates: Array[ResourceNode] = []
	for node: ResourceNode in _world.resource_nodes:
		if node.has_berries() and not _world.reservations.is_taken_by_other(node, villager):
			candidates.append(node)
	candidates.sort_custom(func(a: ResourceNode, b: ResourceNode) -> bool:
		return a.position.distance_squared_to(villager.position) < b.position.distance_squared_to(villager.position))
	for node: ResourceNode in candidates:
		if find_stand_cell(node.cell, villager) != World.INVALID_CELL:
			return node
	return null


## Ô trống cạnh `target_cell` (8 hướng) mà thổ dân đi tới được, gần thổ dân nhất.
func find_stand_cell(target_cell: Vector2i, villager: Villager) -> Vector2i:
	var from_cell: Vector2i = _world.cell_of(villager)
	var options: Array[Vector2i] = []
	for offset: Vector2i in WorldGrid.NEIGHBORS_8:
		var cell: Vector2i = target_cell + offset
		if not _world.grid.is_blocked(cell):
			options.append(cell)
	options.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		return WorldGrid.cell_to_world(a).distance_squared_to(villager.position) < WorldGrid.cell_to_world(b).distance_squared_to(villager.position))
	for cell: Vector2i in options:
		if _world.grid.has_path(from_cell, cell):
			return cell
	return World.INVALID_CELL


## Chỗ ngủ ngoài trời quanh lửa trại; đặt chỗ luôn để hai người không nằm đè lên nhau.
func find_sleep_spot(villager: Villager) -> Vector2i:
	var campfire: Vector2 = Vector2(_world.map_data.campfire_cell)
	var from_cell: Vector2i = _world.cell_of(villager)
	var options: Array[Vector2i] = []
	var ring: int = ceili(Balance.SLEEP_SPOT_MAX_RING)
	for y: int in range(-ring, ring + 1):
		for x: int in range(-ring, ring + 1):
			var cell: Vector2i = _world.map_data.campfire_cell + Vector2i(x, y)
			var distance: float = Vector2(cell).distance_to(campfire)
			if distance < Balance.SLEEP_SPOT_MIN_RING or distance > Balance.SLEEP_SPOT_MAX_RING:
				continue
			if _world.grid.is_blocked(cell) or _world.reservations.is_taken_by_other(cell, villager):
				continue
			options.append(cell)
	# Gần lửa trước, nhưng xáo nhẹ để mỗi đêm nằm một kiểu. Bốc số ngẫu nhiên trước khi
	# sắp xếp — gọi randf() ngay trong hàm so sánh làm thứ tự mâu thuẫn, sort bị hỏng.
	var score: Dictionary[Vector2i, float] = {}
	for cell: Vector2i in options:
		score[cell] = Vector2(cell).distance_to(campfire) + randf()
	options.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return score[a] < score[b])
	for cell: Vector2i in options:
		if _world.grid.has_path(from_cell, cell):
			_world.reservations.reserve(cell, villager)
			return cell
	return World.INVALID_CELL


## Một ô gần đó để đi dạo; lạc xa làng thì dạo dần về phía làng.
func random_wander_cell(villager: Villager) -> Vector2i:
	var from_cell: Vector2i = _world.cell_of(villager)
	var center: Vector2 = Vector2(from_cell)
	var village: Vector2 = Vector2(_world.map_data.village_center)
	if center.distance_to(village) > Balance.VILLAGE_ROAM_RADIUS:
		center = center.lerp(village, 0.5)
	var reach: int = Balance.WANDER_RANGE_CELLS
	for attempt: int in WANDER_ATTEMPTS:
		var cell: Vector2i = Vector2i(center.round()) + Vector2i(randi_range(-reach, reach), randi_range(-reach, reach))
		if cell != from_cell and not _world.grid.is_blocked(cell) and _world.grid.has_path(from_cell, cell):
			return cell
	return World.INVALID_CELL


## Ô trống ngẫu nhiên trong vành khăn quanh `around` (tính bằng ô).
func find_free_cell_near(around: Vector2i, min_ring: float, max_ring: float) -> Vector2i:
	var reach: int = ceili(max_ring)
	for attempt: int in FREE_CELL_ATTEMPTS:
		var cell: Vector2i = around + Vector2i(randi_range(-reach, reach), randi_range(-reach, reach))
		var distance: float = Vector2(cell - around).length()
		if distance >= min_ring and distance <= max_ring and not _world.grid.is_blocked(cell):
			return cell
	return World.INVALID_CELL


## Một bông hoa ngẫu nhiên trong tầm đi bộ: {pos, variant}, hoặc {} nếu không có.
func find_flower_near(villager: Villager) -> Dictionary:
	var reach: float = Balance.FLOWER_RANGE_CELLS * Balance.TILE_SIZE
	var nearby: Array[Dictionary] = []
	for flower: Dictionary in _flowers:
		if Vector2(flower["pos"]).distance_to(villager.position) <= reach:
			nearby.append(flower)
	if nearby.is_empty():
		return {}
	return nearby[randi() % nearby.size()]


## Người lớn gần nhất đang rảnh (đi dạo, ngồi, gãi…) và không đói/mệt gấp.
func find_chat_partner(villager: Villager) -> Villager:
	var reach: float = Balance.CHAT_RANGE_CELLS * Balance.TILE_SIZE
	var best: Villager = null
	var best_distance: float = INF
	for other: Villager in _world.villagers:
		if other == villager or not other.data.is_adult():
			continue
		if other.task != null and not CHATTABLE_KINDS.has(other.task.kind):
			continue
		if other.data.hunger < Balance.HUNGER_URGENT or other.data.energy < Balance.ENERGY_URGENT:
			continue
		var distance: float = other.position.distance_to(villager.position)
		if distance <= reach and distance < best_distance:
			best = other
			best_distance = distance
	return best


## Người gần nhất đang thức (vd để tặng hoa).
func find_villager_near(villager: Villager, range_cells: float) -> Villager:
	var reach: float = range_cells * Balance.TILE_SIZE
	var best: Villager = null
	var best_distance: float = INF
	for other: Villager in _world.villagers:
		if other == villager or other.state == Villager.State.SLEEPING:
			continue
		var distance: float = other.position.distance_to(villager.position)
		if distance <= reach and distance < best_distance:
			best = other
			best_distance = distance
	return best
