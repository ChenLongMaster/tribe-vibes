class_name WorldFinder
extends RefCounted
## Các câu hỏi "tìm chỗ" của thổ dân: đi ăn ở đâu, ngủ ở đâu, chỗ đứng cạnh một vật,
## chỗ dạo chơi quanh điểm neo, bông hoa, bạn tán gẫu… Tách khỏi World để World chỉ
## lo dựng và giữ thế giới.
##
## Đồ ăn và chỗ ngủ đi qua FoodSource / SleepSpot: Đợt 3 thêm Bếp, Lều chỉ cần thêm
## nguồn vào find_food_for() / find_bed_for(), các Task không phải sửa.

const IDLE_ATTEMPTS: int = 12
const FREE_CELL_ATTEMPTS: int = 24
## Việc rảnh có thể bị ngắt để tán gẫu.
const CHATTABLE_KINDS: Array[StringName] = [&"stroll", &"sit", &"scratch"]
## Chỉ kiểm tra đường đi (AStar) cho chừng này mục tiêu gần nhất — đỡ tốn công.
const JOB_TARGET_PATH_CHECKS: int = 6
## Đứng ngay trên/dưới vật bị tính xa thêm chừng này px (ưu tiên đứng hai bên).
const SIDE_PREFERENCE_PX: float = 160.0

var _world: World
var _flowers: Array[Dictionary] = []


func _init(world: World) -> void:
	_world = world
	for item: Dictionary in world.map_data.decor:
		if item["kind"] == MapData.DECOR_FLOWER:
			_flowers.append(item)


# --- Đồ ăn & chỗ ngủ ---

## Chỗ ăn tốt nhất cho thổ dân đang đói: ưu tiên đồ có sẵn (lửa trại; Đợt 3 Bếp), không
## có thì bụi quả gần nhất còn quả. Trả về null nếu không còn gì ăn được.
func find_food_for(villager: Villager) -> FoodSource:
	var candidates: Array[FoodSource] = []
	for building: Building in _world.buildings:
		if building.def.get("food_storage", false):
			candidates.append(StoredFoodSource.new(building))
	for node: ResourceNode in _world.resource_nodes:
		if node.has_berries():
			candidates.append(BushFoodSource.new(node))
	candidates.sort_custom(func(a: FoodSource, b: FoodSource) -> bool:
		if a.priority() != b.priority():
			return a.priority() < b.priority()
		return a.target.position.distance_squared_to(villager.position) < b.target.position.distance_squared_to(villager.position))
	for source: FoodSource in candidates:
		if source.is_available(villager) and find_stand_cell(source.target_cell, villager) != World.INVALID_CELL:
			return source
	return null


## Chỗ ngủ cho thổ dân mệt. Chưa có lều nên là ngủ đất quanh lửa trại (Đợt 3: lều còn
## chỗ trước, hết lều mới ngủ đất). Đặt chỗ luôn để hai người không nằm đè lên nhau.
func find_bed_for(villager: Villager) -> SleepSpot:
	var cell: Vector2i = _find_ground_spot(villager)
	if cell == World.INVALID_CELL:
		return null
	_world.reservations.reserve(cell, villager)
	return SleepSpot.new(cell, 1.0, cell)


# --- Việc được giao & kho ---

## Mục tiêu tương tự gần nhất cho một việc (cây khác, tảng đá khác, con thú khác…) trong
## bán kính tìm của việc đó quanh `around`. Bỏ qua cái đã có người nhận và cái trong `skip`.
## Ưu tiên cái gần thổ dân nhất mà đi tới được. null nếu không còn gì.
func find_job_target(skill: StringName, around: Vector2i, villager: Villager, skip: Array[Node2D] = []) -> Node2D:
	var def: Dictionary = JobDefs.get_def(skill)
	if def.is_empty():
		return null
	var radius: float = float(def.get("search_radius", Balance.JOB_SEARCH_RADIUS_CELLS))
	var candidates: Array[Node2D] = []
	match def["target"]:
		JobDefs.TARGET_ANIMAL:
			for animal: Animal in _world.animals:
				candidates.append(animal)
		JobDefs.TARGET_COOK_STATION:
			for building: Building in _world.buildings:
				if building.def.get("cook_station", false):
					candidates.append(building)
		_:
			for node: ResourceNode in _world.resource_nodes:
				if node.kind == def["target"]:
					candidates.append(node)
	var nearby: Array[Node2D] = []
	for node: Node2D in candidates:
		if skip.has(node) or not Job.is_workable(node, villager):
			continue
		if Vector2(Job.target_cell(node) - around).length() <= radius:
			nearby.append(node)
	nearby.sort_custom(func(a: Node2D, b: Node2D) -> bool:
		return a.position.distance_squared_to(villager.position) < b.position.distance_squared_to(villager.position))
	for node: Node2D in nearby.slice(0, JOB_TARGET_PATH_CHECKS):
		if _can_reach_target(node, villager):
			return node
	return null


## Công trình gần nhất nhận cất loại tài nguyên này (lửa trại; Đợt 3 Kho, Bếp).
func find_storage_for(resource_id: StringName, villager: Villager) -> Building:
	var flag: String = ResourceDefs.storage_flag(resource_id)
	var best: Building = null
	var best_distance: float = INF
	for building: Building in _world.buildings:
		if not building.def.get(flag, false):
			continue
		var distance: float = building.position.distance_squared_to(villager.position)
		if distance < best_distance:
			best = building
			best_distance = distance
	return best


## Ô trống sát mép một công trình (mọi cỡ) mà thổ dân đi tới được, gần thổ dân nhất.
func find_building_stand_cell(building: Building, villager: Villager) -> Vector2i:
	var footprint: Array[Vector2i] = building.footprint_cells()
	var options: Array[Vector2i] = []
	for cell: Vector2i in footprint:
		for offset: Vector2i in WorldGrid.NEIGHBORS_8:
			var around: Vector2i = cell + offset
			if not footprint.has(around) and not options.has(around) and not _world.grid.is_blocked(around):
				options.append(around)
	return _closest_reachable(options, villager)


## Ô trống ngẫu nhiên trên đồng cỏ (chỗ thú mới xuất hiện).
func random_meadow_cell() -> Vector2i:
	var rect: Rect2i = _world.map_data.meadow_rect
	for attempt: int in FREE_CELL_ATTEMPTS:
		var cell: Vector2i = rect.position + Vector2i(randi_range(0, rect.size.x - 1), randi_range(0, rect.size.y - 1))
		if not _world.grid.is_blocked(cell):
			return cell
	return World.INVALID_CELL


func _can_reach_target(node: Node2D, villager: Villager) -> bool:
	if node is Building:
		return find_building_stand_cell(node as Building, villager) != World.INVALID_CELL
	if node is Animal:
		return _world.grid.has_path(_world.cell_of(villager), (node as Animal).current_cell())
	return find_stand_cell(Job.target_cell(node), villager) != World.INVALID_CELL


# --- Vùng dạo chơi quanh điểm neo ---

## Một ô trong bán kính dạo chơi quanh điểm neo (rảnh thì chỉ đi trong vùng này).
func random_idle_cell(villager: Villager) -> Vector2i:
	var from_cell: Vector2i = _world.cell_of(villager)
	var anchor: Vector2i = villager.anchor_cell
	var reach: int = floori(Balance.IDLE_RADIUS_CELLS)
	for attempt: int in IDLE_ATTEMPTS:
		var cell: Vector2i = anchor + Vector2i(randi_range(-reach, reach), randi_range(-reach, reach))
		if cell == from_cell or not is_in_idle_area(villager, cell):
			continue
		if not _world.grid.is_blocked(cell) and _world.grid.has_path(from_cell, cell):
			return cell
	return World.INVALID_CELL


func is_in_idle_area(villager: Villager, cell: Vector2i) -> bool:
	return Vector2(cell - villager.anchor_cell).length() <= Balance.IDLE_RADIUS_CELLS


## Một bông hoa trong vùng dạo chơi: {pos, variant}, hoặc {} nếu không có.
func find_flower_near(villager: Villager) -> Dictionary:
	var nearby: Array[Dictionary] = []
	for flower: Dictionary in _flowers:
		if is_in_idle_area(villager, WorldGrid.world_to_cell(flower["pos"])):
			nearby.append(flower)
	if nearby.is_empty():
		return {}
	return nearby[randi() % nearby.size()]


## Người lớn đang rảnh, đứng gần, cũng ở trong vùng dạo chơi của mình — để tán gẫu tại chỗ.
func find_chat_partner(villager: Villager) -> Villager:
	var reach: float = Balance.IDLE_CHAT_RANGE_CELLS * Balance.TILE_SIZE
	var best: Villager = null
	var best_distance: float = INF
	for other: Villager in _world.villagers:
		if other == villager or not other.data.is_adult():
			continue
		if other.task != null and not CHATTABLE_KINDS.has(other.task.kind):
			continue
		if not is_in_idle_area(villager, _world.cell_of(other)):
			continue
		var distance: float = other.position.distance_to(villager.position)
		if distance <= reach and distance < best_distance:
			best = other
			best_distance = distance
	return best


# --- Ô trống ---

## Ô trống cạnh `target_cell` (8 hướng) mà thổ dân đi tới được, gần thổ dân nhất.
## `prefer_sides` = ưu tiên đứng bên trái/phải (để vung rìu, cuốc vào vật trông cho đúng —
## đứng ngay trên/dưới thì người bị cây che hoặc vung vào khoảng không).
func find_stand_cell(target_cell: Vector2i, villager: Villager, prefer_sides: bool = false) -> Vector2i:
	var options: Array[Vector2i] = []
	for offset: Vector2i in WorldGrid.NEIGHBORS_8:
		var cell: Vector2i = target_cell + offset
		if not _world.grid.is_blocked(cell):
			options.append(cell)
	var penalty: Dictionary[Vector2i, float] = {}
	if prefer_sides:
		for cell: Vector2i in options:
			if cell.x == target_cell.x:
				penalty[cell] = SIDE_PREFERENCE_PX
	return _closest_reachable(options, villager, penalty)


# Trong các ô cho sẵn, ô gần thổ dân nhất mà đi tới được. `penalty` (px) cộng thêm vào
# khoảng cách của ô kém ưu tiên.
func _closest_reachable(options: Array[Vector2i], villager: Villager, penalty: Dictionary[Vector2i, float] = {}) -> Vector2i:
	var from_cell: Vector2i = _world.cell_of(villager)
	var score: Dictionary[Vector2i, float] = {}
	for cell: Vector2i in options:
		score[cell] = WorldGrid.cell_to_world(cell).distance_to(villager.position) + penalty.get(cell, 0.0)
	options.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return score[a] < score[b])
	for cell: Vector2i in options:
		if _world.grid.has_path(from_cell, cell):
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


func _find_ground_spot(villager: Villager) -> Vector2i:
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
	# Gần lửa trước, nhưng xáo nhẹ để mỗi lần nằm một kiểu. Bốc số ngẫu nhiên trước khi
	# sắp xếp — gọi randf() ngay trong hàm so sánh làm thứ tự mâu thuẫn, sort bị hỏng.
	var score: Dictionary[Vector2i, float] = {}
	for cell: Vector2i in options:
		score[cell] = Vector2(cell).distance_to(campfire) + randf()
	options.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return score[a] < score[b])
	for cell: Vector2i in options:
		if _world.grid.has_path(from_cell, cell):
			return cell
	return World.INVALID_CELL
