class_name MapGenerator
extends RefCounted
## Sinh bản đồ theo seed. Cùng seed luôn ra cùng map — nên test lặp lại được và
## save game không cần lưu từng cái cây.
##
## Bố cục luôn đảm bảo: hang + lửa trại ở giữa, rừng một phía, bãi đá phía đối
## diện, hồ ở trên hoặc dưới, đồng cỏ phía còn lại (cũng là hướng cannibal đến).
## Mọi thứ đều đi tới được từ cửa hang.
##
## Lưu ý: chỉ dùng `_rng` của generator, không dùng randf()/shuffle() toàn cục,
## nếu không thì cùng seed sẽ ra map khác nhau.

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _noise: FastNoiseLite = FastNoiseLite.new()
var _data: MapData
## 1 byte mỗi ô: 1 = đã có nước/vật thể/công trình.
var _occupied: PackedByteArray = PackedByteArray()


func generate(seed_value: int) -> MapData:
	_rng.seed = seed_value
	_noise.seed = seed_value
	_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	_noise.frequency = Balance.MAP_NOISE_FREQUENCY
	_data = MapData.new()
	_data.map_seed = seed_value
	_data.init_arrays(Vector2i(Balance.MAP_WIDTH, Balance.MAP_HEIGHT))
	_occupied.resize(_data.size.x * _data.size.y)
	_occupied.fill(0)

	_choose_layout()
	_place_village()
	_carve_lake()
	_place_cliffs()
	_place_forest()
	_place_rocks()
	_place_bushes()
	_remove_unreachable_objects()
	_place_fishing_spots()
	_pick_ground_variants()
	_place_patches()
	_scatter_decor()
	return _data


func _choose_layout() -> void:
	_data.forest_side = MapData.Edge.WEST if _rng.randf() < 0.5 else MapData.Edge.EAST
	_data.rock_side = MapData.Edge.EAST if _data.forest_side == MapData.Edge.WEST else MapData.Edge.WEST
	_data.lake_side = MapData.Edge.NORTH if _rng.randf() < 0.5 else MapData.Edge.SOUTH
	# Cannibal đi qua đồng cỏ trống trải nên người chơi dễ thấy chúng tới.
	_data.raid_side = MapData.Edge.SOUTH if _data.lake_side == MapData.Edge.NORTH else MapData.Edge.NORTH
	var center_x: int = floori(_data.size.x / 2.0)
	var meadow_width: int = Balance.MEADOW_HALF_WIDTH * 2
	var meadow_height: int = Balance.MEADOW_DEPTH - 1
	var meadow_y: int = _data.size.y - Balance.MEADOW_DEPTH if _data.raid_side == MapData.Edge.SOUTH else 1
	_data.meadow_rect = Rect2i(center_x - Balance.MEADOW_HALF_WIDTH, meadow_y, meadow_width, meadow_height)


func _place_village() -> void:
	var center: Vector2i = Vector2i(floori(_data.size.x / 2.0), floori(_data.size.y / 2.0))
	_data.village_center = center
	_data.cave_cell = center + Vector2i(-1, -3)
	_data.cave_entrance_cell = center + Vector2i(0, -1)
	_data.campfire_cell = center + Vector2i(0, 1)
	_add_building(&"cave", _data.cave_cell)
	_add_building(&"campfire", _data.campfire_cell)


func _carve_lake() -> void:
	var lake_y: int = Balance.LAKE_EDGE_MARGIN
	if _data.lake_side == MapData.Edge.SOUTH:
		lake_y = _data.size.y - 1 - Balance.LAKE_EDGE_MARGIN
	var lake_x: int = _data.village_center.x + _rng.randi_range(-Balance.LAKE_CENTER_JITTER, Balance.LAKE_CENTER_JITTER)
	var main_center: Vector2 = Vector2(lake_x, lake_y)
	var main_radius: Vector2 = Vector2(
		_rng.randi_range(Balance.LAKE_RADIUS_X_MIN, Balance.LAKE_RADIUS_X_MAX),
		_rng.randi_range(Balance.LAKE_RADIUS_Y_MIN, Balance.LAKE_RADIUS_Y_MAX))
	# Thêm một "vũng" nhỏ dính vào hồ chính để hồ có hình hạt đậu, không phải elip đều.
	var side_center: Vector2 = main_center + Vector2(
		main_radius.x * _rng.randf_range(0.5, 0.8) * (1.0 if _rng.randf() < 0.5 else -1.0),
		main_radius.y * _rng.randf_range(0.2, 0.6) * (1.0 if _rng.randf() < 0.5 else -1.0))
	var side_radius: Vector2 = main_radius * _rng.randf_range(0.5, 0.75)
	var reach: Vector2i = Vector2i(ceili(main_radius.x * 1.8) + 2, ceili(main_radius.y * 1.6) + 2)
	var bounds: Rect2i = Rect2i(Vector2i(main_center) - reach, reach * 2 + Vector2i.ONE).intersection(Rect2i(Vector2i.ZERO, _data.size))

	for y: int in range(bounds.position.y, bounds.end.y):
		for x: int in range(bounds.position.x, bounds.end.x):
			var cell: Vector2 = Vector2(x, y)
			# Nhiễu làm bờ hồ cong queo tự nhiên thay vì hình elip tròn trịa.
			var wobble: float = _noise.get_noise_2d(x * 3.0, y * 3.0) * Balance.LAKE_WOBBLE
			if _in_ellipse(cell, main_center, main_radius, wobble) or _in_ellipse(cell, side_center, side_radius, wobble):
				_data.water[_data.index(Vector2i(x, y))] = 1

	_smooth_water(bounds)
	for y: int in range(bounds.position.y, bounds.end.y):
		for x: int in range(bounds.position.x, bounds.end.x):
			if _data.water[_data.index(Vector2i(x, y))] == 1:
				_occupied[_data.index(Vector2i(x, y))] = 1


# Bỏ các mỏm nước lẻ một ô và lấp lỗ nhỏ để bờ hồ trông mềm, dễ vẽ.
func _smooth_water(bounds: Rect2i) -> void:
	var result: PackedByteArray = _data.water.duplicate()
	for y: int in range(bounds.position.y, bounds.end.y):
		for x: int in range(bounds.position.x, bounds.end.x):
			var count: int = 0
			for oy: int in range(-1, 2):
				for ox: int in range(-1, 2):
					if _data.is_water(Vector2i(x + ox, y + oy)):
						count += 1
			result[_data.index(Vector2i(x, y))] = 1 if count >= 5 else 0
	_data.water = result


# Vách đá lớn sâu trong phía bãi đá, mỗi cái có sẵn vài đá tảng sát chân.
func _place_cliffs() -> void:
	var footprint: Vector2i = BuildingDefs.footprint(&"cliff")
	var candidates: Array[Vector2i] = []
	for y: int in range(1, _data.size.y - footprint.y - 1):
		for x: int in range(1, _data.size.x - footprint.x - 1):
			var cell: Vector2i = Vector2i(x, y)
			if _side_factor(Vector2i(Vector2(cell) + Vector2(footprint) * 0.5), _data.rock_side) >= Balance.CLIFF_SIDE_START and _area_free(cell, footprint):
				candidates.append(cell)
	_shuffle(candidates)
	var chosen: Array[Vector2i] = []
	_pick_spaced(candidates, Balance.CLIFF_COUNT, Balance.CLIFF_MIN_SPACING, chosen)
	for cell: Vector2i in chosen:
		_add_building(&"cliff", cell)
		_data.cliffs.append(cell)
		var ring: Array[Vector2i] = cells_around(cell, footprint)
		_shuffle(ring)
		var placed: int = 0
		for around: Vector2i in ring:
			if placed >= Balance.BOULDERS_PER_CLIFF:
				break
			if _data.in_bounds(around) and _occupied[_data.index(around)] == 0:
				_add_object(MapData.KIND_ROCK, around, 0 if _rng.randf() < Balance.ROCK_BIG_CHANCE else 1)
				placed += 1


func _area_free(origin: Vector2i, size: Vector2i) -> bool:
	for y: int in size.y:
		for x: int in size.x:
			var cell: Vector2i = origin + Vector2i(x, y)
			if not _data.in_bounds(cell) or _occupied[_data.index(cell)] == 1 or _data.meadow_rect.has_point(cell):
				return false
	return true


## Các ô ngay sát quanh một khối ô (không tính góc chéo).
static func cells_around(origin: Vector2i, size: Vector2i) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for x: int in size.x:
		cells.append(origin + Vector2i(x, -1))
		cells.append(origin + Vector2i(x, size.y))
	for y: int in size.y:
		cells.append(origin + Vector2i(-1, y))
		cells.append(origin + Vector2i(size.x, y))
	return cells


func _place_forest() -> void:
	for y: int in _data.size.y:
		for x: int in _data.size.x:
			var cell: Vector2i = Vector2i(x, y)
			var roll: float = _rng.randf()
			var variant_roll: float = _rng.randf()
			if not _can_place_nature(cell):
				continue
			var side: float = _side_factor(cell, _data.forest_side)
			var density: float = 0.0
			if side > Balance.FOREST_START:
				var wobble: float = _noise.get_noise_2d(x, y) * 0.35
				density = clampf((side - Balance.FOREST_START) * 1.4 + wobble, 0.0, Balance.FOREST_MAX_DENSITY)
			if roll < density or roll < Balance.LONE_TREE_CHANCE:
				# Sâu trong rừng nhiều cây lá kim hơn.
				var variant: int = 1 if variant_roll < 0.3 + maxf(side, 0.0) * 0.4 else 0
				_add_object(MapData.KIND_TREE, cell, variant)


func _place_rocks() -> void:
	for y: int in _data.size.y:
		for x: int in _data.size.x:
			var cell: Vector2i = Vector2i(x, y)
			var roll: float = _rng.randf()
			var size_roll: float = _rng.randf()
			if not _can_place_nature(cell):
				continue
			var side: float = _side_factor(cell, _data.rock_side)
			# Lệch toạ độ nhiễu để cụm đá không trùng hình với cụm cây.
			var cluster: float = _noise.get_noise_2d(x + 500.0, y + 500.0)
			if side > Balance.ROCK_START and cluster > Balance.ROCK_NOISE_THRESHOLD and roll < Balance.ROCK_CHANCE:
				var variant: int = 0 if size_roll < Balance.ROCK_BIG_CHANCE else 1
				_add_object(MapData.KIND_ROCK, cell, variant)


func _place_bushes() -> void:
	var center: Vector2 = Vector2(_data.village_center)
	var village_candidates: Array[Vector2i] = []
	var meadow_candidates: Array[Vector2i] = []
	for y: int in _data.size.y:
		for x: int in _data.size.x:
			var cell: Vector2i = Vector2i(x, y)
			if _occupied[_data.index(cell)] == 1:
				continue
			var distance: float = Vector2(cell).distance_to(center)
			if _data.meadow_rect.has_point(cell):
				meadow_candidates.append(cell)
			elif distance >= Balance.BUSH_RING_MIN and distance <= Balance.BUSH_RING_MAX:
				village_candidates.append(cell)
	_shuffle(village_candidates)
	_shuffle(meadow_candidates)
	var chosen: Array[Vector2i] = []
	_pick_spaced(village_candidates, Balance.BUSH_COUNT_VILLAGE, Balance.BUSH_MIN_SPACING, chosen)
	_pick_spaced(meadow_candidates, Balance.BUSH_COUNT_MEADOW, Balance.BUSH_MIN_SPACING, chosen)
	for cell: Vector2i in chosen:
		_add_object(MapData.KIND_BUSH, cell, 0)


func _pick_spaced(candidates: Array[Vector2i], count: int, spacing: float, chosen: Array[Vector2i]) -> void:
	var added: int = 0
	for cell: Vector2i in candidates:
		if added >= count:
			return
		var too_close: bool = false
		for other: Vector2i in chosen:
			if Vector2(cell).distance_to(Vector2(other)) < spacing:
				too_close = true
				break
		if not too_close:
			chosen.append(cell)
			added += 1


# Cây/đá/bụi nằm kẹt (vd giữa rừng rậm) thì bỏ, để người chơi giao việc nào cũng làm được.
func _remove_unreachable_objects() -> void:
	var grid: WorldGrid = _data.make_grid()
	var reached: PackedByteArray = grid.flood_fill(_data.cave_entrance_cell)
	var kept: Array[Dictionary] = []
	for object: Dictionary in _data.objects:
		var cell: Vector2i = object["cell"]
		if grid.has_reachable_neighbor(cell, reached):
			kept.append(object)
		else:
			_occupied[_data.index(cell)] = 0
	_data.objects = kept


func _place_fishing_spots() -> void:
	var grid: WorldGrid = _data.make_grid()
	var reached: PackedByteArray = grid.flood_fill(_data.cave_entrance_cell)
	var candidates: Array[Vector2i] = []
	for y: int in _data.size.y:
		for x: int in _data.size.x:
			var cell: Vector2i = Vector2i(x, y)
			if not _data.is_water(cell):
				continue
			for offset: Vector2i in WorldGrid.NEIGHBORS_4:
				if grid.is_reached(cell + offset, reached):
					candidates.append(cell)
					break
	# Ưu tiên chỗ câu gần làng cho đỡ phải đi xa.
	var center: Vector2 = Vector2(_data.village_center)
	candidates.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		return Vector2(a).distance_squared_to(center) < Vector2(b).distance_squared_to(center))
	var chosen: Array[Vector2i] = []
	_pick_spaced(candidates, Balance.FISHING_SPOT_COUNT, Balance.FISHING_SPOT_MIN_SPACING, chosen)
	for cell: Vector2i in chosen:
		_data.objects.append({"kind": MapData.KIND_FISH_SPOT, "cell": cell, "variant": 0})


func _pick_ground_variants() -> void:
	# Ô trơn (biến thể 2) chiếm nhiều nhất để hoa văn cỏ không lặp thành lưới khi zoom gần.
	for i: int in _data.ground_variant.size():
		var roll: float = _rng.randf()
		_data.ground_variant[i] = 0 if roll < 0.3 else (1 if roll < 0.55 else 2)


func _place_patches() -> void:
	# Mảng cỏ sáng/tối lớn, mờ — phá thế đồng màu của nền ô vuông.
	var map_pixels: Vector2 = Vector2(_data.size * Balance.TILE_SIZE)
	for i: int in Balance.GRASS_PATCH_COUNT:
		var pos: Vector2 = Vector2(_rng.randf() * map_pixels.x, _rng.randf() * map_pixels.y)
		_data.patches.append({"kind": MapData.PATCH_GRASS, "pos": pos, "variant": _rng.randi_range(0, 1)})
	# Bãi đất lớn giữa hang và lửa trại — "sân làng".
	var village_pos: Vector2 = WorldGrid.cell_to_world(_data.campfire_cell) + Vector2(0, -24)
	_data.patches.append({"kind": MapData.PATCH_DIRT, "pos": village_pos, "variant": 0})
	var center: Vector2 = Vector2(_data.village_center)
	var placed: int = 0
	var attempts: int = 0
	while placed < Balance.DIRT_PATCH_COUNT and attempts < 200:
		attempts += 1
		var cell: Vector2i = Vector2i(_rng.randi_range(0, _data.size.x - 1), _rng.randi_range(0, _data.size.y - 1))
		var distance: float = Vector2(cell).distance_to(center)
		if distance < 4.0 or distance > 12.0 or _data.is_water(cell):
			continue
		var jitter: Vector2 = Vector2(_rng.randf_range(-16, 16), _rng.randf_range(-16, 16))
		_data.patches.append({"kind": MapData.PATCH_DIRT, "pos": WorldGrid.cell_to_world(cell) + jitter, "variant": 1})
		placed += 1


func _scatter_decor() -> void:
	var campfire: Vector2 = Vector2(_data.campfire_cell)
	for y: int in _data.size.y:
		for x: int in _data.size.x:
			var cell: Vector2i = Vector2i(x, y)
			var roll: float = _rng.randf()
			var jitter: Vector2 = Vector2(_rng.randf_range(-22, 22), _rng.randf_range(-18, 22))
			var variant_roll: float = _rng.randf()
			if _occupied[_data.index(cell)] == 1 or Vector2(cell).distance_to(campfire) < 3.0:
				continue
			var flower_chance: float = Balance.DECOR_FLOWER_CHANCE
			var tuft_chance: float = Balance.DECOR_TUFT_CHANCE
			if _data.meadow_rect.has_point(cell):
				flower_chance = Balance.MEADOW_FLOWER_CHANCE
				tuft_chance = Balance.MEADOW_TUFT_CHANCE
			var pos: Vector2 = WorldGrid.cell_to_world(cell) + jitter
			if roll < flower_chance:
				_data.decor.append({"kind": MapData.DECOR_FLOWER, "pos": pos, "variant": int(variant_roll * 3.0)})
			elif roll < flower_chance + tuft_chance:
				_data.decor.append({"kind": MapData.DECOR_TUFT, "pos": pos, "variant": int(variant_roll * 2.0)})


func _can_place_nature(cell: Vector2i) -> bool:
	if _occupied[_data.index(cell)] == 1:
		return false
	if _data.meadow_rect.has_point(cell):
		return false
	return Vector2(cell).distance_to(Vector2(_data.village_center)) >= Balance.VILLAGE_CLEAR_RADIUS


func _in_ellipse(cell: Vector2, center: Vector2, radius: Vector2, wobble: float) -> bool:
	var d: Vector2 = (cell - center) / radius
	return d.length_squared() + wobble < 1.0


## 0 ở giữa map, 1 ở mép phía `side`, âm ở nửa đối diện.
func _side_factor(cell: Vector2i, side: MapData.Edge) -> float:
	var nx: float = (cell.x + 0.5) / _data.size.x * 2.0 - 1.0
	var ny: float = (cell.y + 0.5) / _data.size.y * 2.0 - 1.0
	match side:
		MapData.Edge.WEST:
			return -nx
		MapData.Edge.EAST:
			return nx
		MapData.Edge.NORTH:
			return -ny
		_:
			return ny


func _add_object(kind: StringName, cell: Vector2i, variant: int) -> void:
	_data.objects.append({"kind": kind, "cell": cell, "variant": variant})
	_occupied[_data.index(cell)] = 1


func _add_building(id: StringName, cell: Vector2i) -> void:
	_data.buildings.append({"id": id, "cell": cell})
	for footprint_cell: Vector2i in BuildingDefs.footprint_cells(id, cell):
		_occupied[_data.index(footprint_cell)] = 1


# Fisher–Yates bằng _rng riêng (Array.shuffle() dùng RNG toàn cục → mất tính lặp lại).
func _shuffle(cells: Array[Vector2i]) -> void:
	for i: int in range(cells.size() - 1, 0, -1):
		var j: int = _rng.randi_range(0, i)
		var temp: Vector2i = cells[i]
		cells[i] = cells[j]
		cells[j] = temp
