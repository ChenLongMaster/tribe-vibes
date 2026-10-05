class_name MapGenerator
extends RefCounted
## Sinh bản đồ theo seed. Cùng seed luôn ra cùng map — nên test lặp lại được và
## save game không cần lưu từng cái cây.
##
## Bố cục kiểu RTS — tài nguyên dồn thành CỤM chứ không rải đều:
## - Hang + lửa trại ở giữa; quanh làng có sẵn một cụm nhỏ mỗi thứ (vài cây, vài đá tảng,
##   một vạt bụi quả) để người chơi bắt đầu, cụm lớn và giàu hơn nằm xa.
## - Rừng thành từng cánh rừng đặc (dồn về một phía), có bìa rừng và lối đi.
## - Phía đối diện là các DÃY VÁCH ĐÁ (địa hình dài, không đi qua được) với một bãi đá tảng liền
##   dọc chân, cộng vài bãi đá lẻ gom chặt. Thêm vài lùm cây lẻ trên bãi cỏ.
## - Cây, đá lệch nhẹ khỏi tâm ô (jitter) cho đỡ thẳng hàng như lưới.
## - Bụi quả mọc thành từng vạt. Hồ ở trên hoặc dưới; đồng cỏ (có thú) phía còn lại — cũng là
##   hướng cannibal đến.
## Mọi thứ đều đi tới được từ cửa hang.
##
## Lưu ý: chỉ dùng `_rng` của generator, không dùng randf()/shuffle() toàn cục,
## nếu không thì cùng seed sẽ ra map khác nhau.

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _noise: FastNoiseLite = FastNoiseLite.new()
var _data: MapData
## 1 byte mỗi ô: 1 = đã có nước/vật thể/công trình.
var _occupied: PackedByteArray = PackedByteArray()
## Ô vách đá (tra nhanh khi giữ khoảng cách giữa các dãy).
var _cliff_set: Dictionary[Vector2i, bool] = {}
var _tree_species: Dictionary[Vector2i, int] = {}


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
	_place_cliff_ridges()
	_place_forests()
	_place_bamboo_groves()
	_place_lone_copses()
	_place_rock_fields()
	_place_berry_groves()
	_remove_unreachable_objects()
	_place_piles()
	_place_fishing_spots()
	_place_trails()
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
	_cliff_set.clear()
	_tree_species.clear()
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


# --- Dãy vách đá ---

# Mấy dãy vách đá dài (dồn về phía bãi đá), dày 1–2 ô, cách nhau đủ xa để luôn có lối đi.
# Dưới chân (phía trước) mỗi dãy có một bãi đá tảng.
func _place_cliff_ridges() -> void:
	var made: int = 0
	var attempts: int = 0
	var ridges: Array[Array] = []
	while made < Balance.CLIFF_RIDGE_COUNT and attempts < Balance.CLIFF_RIDGE_COUNT * 30:
		attempts += 1
		var on_rock_side: bool = made < Balance.CLIFF_RIDGE_COUNT - Balance.CLIFF_RIDGES_ELSEWHERE
		var start: Vector2i = _random_cell(Balance.CLIFF_EDGE_MARGIN)
		if on_rock_side and _side_factor(start, _data.rock_side) < Balance.CLIFF_SIDE_START:
			continue
		var ridge: Array[Vector2i] = _walk_ridge(start)
		var columns: Dictionary[int, bool] = {}
		for cell: Vector2i in ridge:
			columns[cell.x] = true
		if columns.size() < Balance.CLIFF_RIDGE_MIN_LENGTH:
			continue
		for cell: Vector2i in ridge:
			_data.cliffs.append(cell)
			_cliff_set[cell] = true
			_occupied[_data.index(cell)] = 1
		ridges.append(ridge)
		made += 1
	# Bãi đá đặt sau khi có đủ các dãy, để biết tránh chân dãy khác (giữ lối đi giữa hai dãy).
	for ridge_cells: Array in ridges:
		var cells: Array[Vector2i] = []
		cells.assign(ridge_cells)
		_place_ridge_scree(cells)


# Dãy vách chạy NGANG là chính (mặt đứng quay về phía người nhìn nên nhìn ra một bức vách
# dài), trôi lên / xuống dần theo một hướng nghiêng. Mỗi cột ô là một đoạn liền dày 1–2 ô
# (CliffRidge cần vậy để vẽ). Chỗ chân vách dịch hàng thì cột đó dày thêm để hai cột luôn
# chạm cạnh nhau (không có khe chéo).
func _walk_ridge(start: Vector2i) -> Array[Vector2i]:
	var step_x: int = 1 if _rng.randf() < 0.5 else -1
	var drift: int = _rng.randi_range(-1, 1)
	var length: int = _rng.randi_range(Balance.CLIFF_RIDGE_MIN_LENGTH, Balance.CLIFF_RIDGE_MAX_LENGTH)
	var depth: int = _rng.randi_range(1, 2)
	var base: int = start.y
	var previous: Vector2i = Vector2i.ZERO # (hàng trên, hàng dưới) của cột trước
	var cells: Array[Vector2i] = []
	for step: int in length:
		var x: int = start.x + step * step_x
		var top: int = base - depth + 1
		if step > 0:
			if top > previous.y:
				# Chân đi xuống: cột này kéo lên cho chạm cột trước.
				top = previous.y
			elif base < previous.x:
				# Chân đi lên: cột trước kéo lên một ô cho chạm cột này; không được thì thôi không lên.
				var extra: Vector2i = Vector2i(x - step_x, base)
				if _ridge_cell_ok(extra, cells):
					cells.append(extra)
				else:
					base = previous.x
					top = mini(top, base)
		var column: Array[Vector2i] = []
		for y: int in range(top, base + 1):
			column.append(Vector2i(x, y))
		if not column.all(func(cell: Vector2i) -> bool: return _ridge_cell_ok(cell, cells)):
			break
		cells.append_array(column)
		previous = Vector2i(top, base)
		if _rng.randf() < Balance.CLIFF_TURN_CHANCE:
			if drift == 0 or _rng.randf() < 0.25:
				base += 1 if _rng.randf() < 0.5 else -1
			else:
				base += drift
		if _rng.randf() < Balance.CLIFF_THICK_CHANCE * 0.5:
			depth = 3 - depth
	return cells


# Ô làm vách được: trong map (chừa mép), trống, không sát nước / làng / đồng cỏ, và cách các dãy
# vách khác đủ xa (để giữa hai dãy luôn có lối đi).
func _ridge_cell_ok(cell: Vector2i, own: Array[Vector2i]) -> bool:
	var margin: int = Balance.CLIFF_EDGE_MARGIN
	if cell.x < margin or cell.y < margin or cell.x >= _data.size.x - margin or cell.y >= _data.size.y - margin:
		return false
	if _occupied[_data.index(cell)] == 1 or _data.meadow_rect.grow(2).has_point(cell):
		return false
	if Vector2(cell).distance_to(Vector2(_data.village_center)) < Balance.CLIFF_VILLAGE_CLEARANCE:
		return false
	var gap: int = Balance.CLIFF_RIDGE_GAP
	for y: int in range(-gap, gap + 1):
		for x: int in range(-gap, gap + 1):
			var near: Vector2i = cell + Vector2i(x, y)
			if not _data.in_bounds(near):
				continue
			if _data.is_water(near) and absi(x) <= 2 and absi(y) <= 2:
				return false
			if _cliff_set.has(near) and not own.has(near):
				return false
	return true


# --- Rừng ---

# Rừng thành từng cánh: đa số cánh ở phía rừng, vài cánh lẻ chỗ khác, một lùm nhỏ gần làng.
# Trong cánh rừng cây dày ở lõi, thưa ở bìa; nhiễu tạo khoảng trống và lối đi.
func _place_forests() -> void:
	var near: Vector2i = _cell_toward(_data.forest_side, _rng.randf_range(8.0, 11.0))
	_grow_forest(near, Balance.STARTER_GROVE_RADIUS, 0)
	var made: int = 0
	var attempts: int = 0
	while made < Balance.FOREST_CLUSTERS and attempts < Balance.FOREST_CLUSTERS * 30:
		attempts += 1
		var center: Vector2i = _random_cell(3)
		var on_side: bool = made < Balance.FOREST_CLUSTERS - Balance.FOREST_CLUSTERS_ELSEWHERE
		if on_side and _side_factor(center, _data.forest_side) < Balance.FOREST_SIDE_START:
			continue
		if not on_side and _side_factor(center, _data.rock_side) > 0.1:
			continue
		if Vector2(center).distance_to(Vector2(_data.village_center)) < Balance.FOREST_VILLAGE_CLEARANCE:
			continue
		_grow_forest(center, _rng.randf_range(Balance.FOREST_RADIUS_MIN, Balance.FOREST_RADIUS_MAX), made % 2)
		made += 1


# Cánh rừng ghép từ một khối chính + vài khối phụ lệch ra (hình méo như rừng thật), bìa rừng
# gợn theo nhiễu, cây thưa dần ra bìa và vài cây lẻ mọc lấn ra ngoài. Loại cây theo từng mảng
# riêng cho cả cánh, không xen kẽ ngẫu nhiên từng cây.
func _grow_forest(center: Vector2i, radius: float, species: int) -> void:
	var blobs: Array[Vector3] = [Vector3(center.x, center.y, radius)]
	for i: int in _rng.randi_range(0, Balance.FOREST_BLOBS_MAX):
		var offset: Vector2 = Vector2.RIGHT.rotated(_rng.randf() * TAU) * radius * _rng.randf_range(0.5, 0.95)
		blobs.append(Vector3(center.x + offset.x, center.y + offset.y, radius * _rng.randf_range(0.4, 0.7)))
	var reach: int = ceili(radius * 2.2)
	for y: int in range(center.y - reach, center.y + reach + 1):
		for x: int in range(center.x - reach, center.x + reach + 1):
			var cell: Vector2i = Vector2i(x, y)
			var roll: float = _rng.randf()
			if not _data.in_bounds(cell) or not _can_place_nature(cell):
				continue
			var t: float = 99.0
			for blob: Vector3 in blobs:
				t = minf(t, Vector2(cell).distance_to(Vector2(blob.x, blob.y)) / blob.z)
			t += _noise.get_noise_2d(x * 2.3 + 300.0, y * 2.3) * Balance.FOREST_EDGE_WOBBLE
			var density: float = 0.0
			if t <= 1.0:
				var gaps: float = _noise.get_noise_2d(x * 1.7, y * 1.7) * 0.3
				density = clampf(Balance.FOREST_CORE_DENSITY * (1.0 - t * t) + gaps, 0.0, Balance.FOREST_MAX_DENSITY)
			elif t < 1.6:
				density = Balance.FOREST_STRAY_CHANCE * (1.6 - t) / 0.6
			if roll < density:
				_add_tree(cell, species, t)


# Lùm 1–3 cây lẻ rải trên bãi cỏ (ngoài thực tế cây không chỉ mọc trong rừng).
func _place_lone_copses() -> void:
	var made: int = 0
	var attempts: int = 0
	while made < Balance.LONE_COPSES and attempts < Balance.LONE_COPSES * 20:
		attempts += 1
		var center: Vector2i = _random_cell(3)
		if not _can_place_nature(center) or Vector2(center).distance_to(Vector2(_data.village_center)) < Balance.BUSH_RING_MAX:
			continue
		var species: int = 0 if _rng.randf() < 0.7 else 1
		_add_tree(center, species, 1.0)
		for i: int in _rng.randi_range(0, 2):
			var cell: Vector2i = center + WorldGrid.NEIGHBORS_8[_rng.randi_range(0, WorldGrid.NEIGHBORS_8.size() - 1)] \
					* _rng.randi_range(1, 2)
			if _data.in_bounds(cell) and _can_place_nature(cell):
				_add_tree(cell, species, 1.0)
		made += 1


# Mỗi cánh/lùm một loại; chừa khoảng giữa hai loại và dành dải ven hồ cho tre.
func _add_tree(cell: Vector2i, variant: int, t: float) -> void:
	if variant != 2 and _near_water(cell, Balance.BAMBOO_SHORE_DISTANCE):
		return
	for y: int in range(-Balance.FOREST_SPECIES_GAP, Balance.FOREST_SPECIES_GAP + 1):
		for x: int in range(-Balance.FOREST_SPECIES_GAP, Balance.FOREST_SPECIES_GAP + 1):
			var nearby: Vector2i = cell + Vector2i(x, y)
			if _tree_species.has(nearby) and _tree_species[nearby] != variant:
				return
	_tree_species[cell] = variant
	# Cây non hay mọc ở bìa rừng (rừng đang lan ra).
	var extra: Dictionary = {}
	if _rng.randf() < Balance.YOUNG_TREE_CHANCE * (0.4 + clampf(t, 0.0, 1.5)):
		extra["growth"] = _rng.randf_range(0.1, 0.85)
	_add_object(MapData.KIND_TREE, cell, variant, _jitter(Balance.TREE_JITTER), extra)


# --- Đá ---

# Bãi đá tảng lẻ phía bãi đá + một bãi nhỏ gần làng cho người chơi bắt đầu.
func _place_rock_fields() -> void:
	var near: Vector2i = _cell_toward(_data.rock_side, _rng.randf_range(8.0, 11.0))
	_place_boulders_around(near, Balance.STARTER_ROCKS, 2.0)
	var made: int = 0
	var attempts: int = 0
	while made < Balance.ROCK_FIELD_COUNT and attempts < Balance.ROCK_FIELD_COUNT * 30:
		attempts += 1
		var center: Vector2i = _random_cell(3)
		if _side_factor(center, _data.rock_side) < Balance.ROCK_START:
			continue
		if _occupied[_data.index(center)] == 1:
			continue
		_place_boulders_around(center, _rng.randi_range(Balance.ROCK_FIELD_MIN, Balance.ROCK_FIELD_MAX), 2.5)
		made += 1


# Một bãi đá gom chặt quanh `center`: ô càng gần tâm càng dễ có đá (cộng chút ngẫu nhiên cho
# hình bãi méo), đá to nằm giữa, đá nhỏ ở rìa.
func _place_boulders_around(center: Vector2i, count: int, radius: float) -> void:
	var cells: Array[Vector2i] = []
	var reach: int = ceili(radius) + 1
	for y: int in range(-reach, reach + 1):
		for x: int in range(-reach, reach + 1):
			cells.append(center + Vector2i(x, y))
	cells.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		return Vector2(a - center).length_squared() < Vector2(b - center).length_squared())
	var placed: int = 0
	for at: Vector2i in cells:
		if _place_rock_cluster(at):
			placed += 1
			if placed >= count:
				return

func _place_rock_cluster(origin: Vector2i) -> bool:
	for at: Vector2i in MapData.resource_cells(MapData.KIND_ROCK, origin, 2):
		if not _data.in_bounds(at) or not _can_place_nature(at) or _behind_cliff(at):
			return false
	# Không ghép mỏ kề sát mỏ thành tường; dành vành ngoài cho dân và sỏi.
	for object: Dictionary in _data.objects:
		if object["kind"] == MapData.KIND_ROCK and Vector2(Vector2i(object["cell"]) - origin).length() < Balance.ROCK_CLUSTER_GAP:
			return false
	_add_object(MapData.KIND_ROCK, origin, 2, Vector2.ZERO, {"amount": Balance.ROCK_CLUSTER_STONE})
	return true


# Bãi đá tảng LIỀN dọc chân một dãy vách — chỉ ở PHÍA TRƯỚC (nam, dưới mặt đứng), như đá lở
# lăn xuống chân vách ngoài thực tế. Chọn một đoạn dãy: hàng sát chân dày đá (đá to), hàng
# thứ hai, thứ ba thưa dần (đá nhỏ), hai đầu đoạn thưa dần. Không đặt sát dãy khác để lối đi luôn còn.
func _place_ridge_scree(ridge: Array[Vector2i]) -> void:
	var bases: Dictionary[int, int] = {}
	var own: Dictionary[Vector2i, bool] = {}
	for cell: Vector2i in ridge:
		own[cell] = true
		bases[cell.x] = maxi(bases.get(cell.x, cell.y), cell.y)
	var xs: Array[int] = bases.keys()
	xs.sort()
	var middle: float = lerpf(xs[0], xs[xs.size() - 1], _rng.randf_range(0.3, 0.7))
	var half: float = maxf(2.0, xs.size() * _rng.randf_range(Balance.RIDGE_SCREE_SPAN_MIN, Balance.RIDGE_SCREE_SPAN_MAX) / 2.0)
	var options: Array[Vector2i] = []
	var chances: Dictionary[Vector2i, float] = {}
	for x: int in xs:
		var along: float = absf(x - middle) / half
		if along > 1.0:
			continue
		for row: int in range(1, 4):
			var cell: Vector2i = Vector2i(x, bases[x] + row)
			if not _data.in_bounds(cell) or not _can_place_nature(cell) or _near_other_ridge(cell, own) or _cliff_set.has(cell):
				continue
			var chance: float = [0.0, Balance.RIDGE_SCREE_NEAR, Balance.RIDGE_SCREE_FAR, Balance.RIDGE_SCREE_FAR * 0.4][row]
			chances[cell] = chance * (1.0 - along * along * 0.7)
			options.append(cell)
	_shuffle(options)
	var placed: int = 0
	for cell: Vector2i in options:
		if placed >= Balance.RIDGE_BOULDERS_MAX:
			return
		if _rng.randf() >= chances[cell]:
			continue
		if _place_rock_cluster(cell):
			placed += 1



## Ô nằm ngay sau lưng (phía bắc) một dãy vách: đá tảng / đá cuội không nằm ở đây.
func _behind_cliff(cell: Vector2i) -> bool:
	for row: int in range(1, 4):
		if _cliff_set.has(cell + Vector2i(0, row)):
			return true
	return _cliff_set.has(cell + Vector2i(-1, 1)) or _cliff_set.has(cell + Vector2i(1, 1))


# Ô nằm trong 2 ô quanh một dãy vách KHÁC.
func _near_other_ridge(cell: Vector2i, own: Dictionary[Vector2i, bool]) -> bool:
	for y: int in range(-2, 3):
		for x: int in range(-2, 3):
			var near: Vector2i = cell + Vector2i(x, y)
			if _cliff_set.has(near) and not own.has(near):
				return true
	return false


func _jitter(amount: Vector2) -> Vector2:
	return Vector2(_rng.randf_range(-amount.x, amount.x), _rng.randf_range(-amount.y, amount.y))


# --- Bụi quả ---

# Bụi quả mọc thành vạt: một vạt gần làng, một vạt ở đồng cỏ, còn lại rải quanh map.
func _place_berry_groves() -> void:
	var centers: Array[Vector2i] = [_cell_toward(_random_edge(), _rng.randf_range(Balance.BUSH_RING_MIN, Balance.BUSH_RING_MAX))]
	var meadow: Rect2i = _data.meadow_rect
	centers.append(meadow.position + Vector2i(_rng.randi_range(2, meadow.size.x - 3), _rng.randi_range(2, meadow.size.y - 3)))
	var attempts: int = 0
	while centers.size() < Balance.BERRY_GROVES + 2 and attempts < 200:
		attempts += 1
		var center: Vector2i = _random_cell(3)
		if Vector2(center).distance_to(Vector2(_data.village_center)) < Balance.BUSH_RING_MAX:
			continue
		if _occupied[_data.index(center)] == 1:
			continue
		var far_enough: bool = true
		for other: Vector2i in centers:
			if Vector2(other).distance_to(Vector2(center)) < Balance.BERRY_GROVE_SPACING:
				far_enough = false
				break
		if far_enough:
			centers.append(center)
	for i: int in centers.size():
		var count: int = _rng.randi_range(Balance.BERRY_GROVE_MIN, Balance.BERRY_GROVE_MAX)
		_place_bushes_around(centers[i], count, i == 1)


func _place_bushes_around(center: Vector2i, count: int, in_meadow: bool) -> void:
	var shape: Vector2i = Vector2i(2, 2) if count < 6 else Vector2i(3, 2)
	var grid: WorldGrid = _data.make_grid()
	var before: PackedByteArray = grid.flood_fill(_data.cave_entrance_cell)
	var options: Array[Vector2i] = []
	for y: int in range(-4, 5):
		for x: int in range(-4, 5):
			options.append(center + Vector2i(x, y))
	options.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		return Vector2(a - center).length_squared() < Vector2(b - center).length_squared())
	for origin: Vector2i in options:
		var cells: Array[Vector2i] = []
		var valid: bool = true
		for y: int in shape.y:
			for x: int in shape.x:
				var at: Vector2i = origin + Vector2i(x, y)
				if not _data.in_bounds(at) or _occupied[_data.index(at)] == 1 or _data.is_water(at) or (not in_meadow and _data.meadow_rect.has_point(at)) or Vector2(at - _data.village_center).length() < Balance.BUSH_RING_MIN:
					valid = false
				cells.append(at)
		if not valid:
			continue
		var extra: Dictionary[Vector2i, bool] = {}
		for at: Vector2i in cells:
			extra[at] = true
		var reached: PackedByteArray = grid.flood_fill(_data.cave_entrance_cell, extra)
		# Không bịt đường khiến bước lọc sau phải bỏ lẻ một bụi khỏi hình chữ nhật.
		if before.count(1) - reached.count(1) != cells.size():
			continue
		for at: Vector2i in cells:
			valid = valid and grid.has_reachable_neighbor(at, reached)
		if not valid:
			continue
		for at: Vector2i in cells:
			_add_object(MapData.KIND_BUSH, at, 0, _jitter(Vector2(3, 2)), {"amount": Balance.BUSH_FOOD, "grove": origin, "grove_size": shape})
		return


# --- Tiện ích vị trí ---

func _random_cell(margin: int) -> Vector2i:
	return Vector2i(_rng.randi_range(margin, _data.size.x - 1 - margin), _rng.randi_range(margin, _data.size.y - 1 - margin))


func _random_edge() -> MapData.Edge:
	var edges: Array[MapData.Edge] = [MapData.Edge.NORTH, MapData.Edge.SOUTH, MapData.Edge.EAST, MapData.Edge.WEST]
	return edges[_rng.randi_range(0, edges.size() - 1)]


# Ô cách giữa làng `distance` ô về phía `side` (lệch ngẫu nhiên một chút sang hai bên).
func _cell_toward(side: MapData.Edge, distance: float) -> Vector2i:
	var direction: Vector2 = Vector2.ZERO
	match side:
		MapData.Edge.WEST:
			direction = Vector2.LEFT
		MapData.Edge.EAST:
			direction = Vector2.RIGHT
		MapData.Edge.NORTH:
			direction = Vector2.UP
		_:
			direction = Vector2.DOWN
	direction = direction.rotated(_rng.randf_range(-0.6, 0.6))
	var cell: Vector2i = _data.village_center + Vector2i((direction * distance).round())
	return cell.clamp(Vector2i(2, 2), _data.size - Vector2i(3, 3))


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
		var accessible: bool = false
		for at: Vector2i in MapData.resource_cells(object["kind"], cell, int(object.get("variant", 0))):
			accessible = accessible or grid.has_reachable_neighbor(at, reached)
		if accessible:
			kept.append(object)
		else:
			for at: Vector2i in MapData.resource_cells(object["kind"], cell, int(object.get("variant", 0))):
				_occupied[_data.index(at)] = 0
	_data.objects = kept


# --- Bãi sỏi, đống củi (nằm trên đất, đi qua được) ---

# Bãi sỏi cạnh các bãi đá tảng (chân vách nhiều nhất), đống củi dưới tán rừng rậm; bãi đá và
# lùm cây gần làng có sẵn vài cái để ván mới tay trắng vẫn có đồ nhặt gần nhà.
func _place_piles() -> void:
	var grid: WorldGrid = _data.make_grid()
	var reached: PackedByteArray = grid.flood_fill(_data.cave_entrance_cell)
	var rocks: Dictionary[Vector2i, bool] = _cells_of_kind(MapData.KIND_ROCK)
	var trees: Dictionary[Vector2i, bool] = {}
	for object: Dictionary in _data.objects:
		if object["kind"] == MapData.KIND_TREE and float(object.get("growth", 1.0)) >= 1.0:
			trees[object["cell"]] = true
	_place_pile_kind(MapData.KIND_PEBBLES, rocks, Balance.PEBBLE_PATCHES, Balance.PEBBLE_PATCH_SPACING,
			Balance.PEBBLE_PATCH_STONE, grid, reached, true)
	_place_pile_kind(MapData.KIND_TWIGS, trees, Balance.TWIG_PILES, Balance.TWIG_PILE_SPACING,
			Balance.TWIG_PILE_WOOD, grid, reached, false)


func _place_pile_kind(kind: StringName, sources: Dictionary[Vector2i, bool], count: int, spacing: float,
		capacity: int, grid: WorldGrid, reached: PackedByteArray, cliff_bonus: bool) -> void:
	var candidates: Array[Vector2i] = []
	var scores: Dictionary[Vector2i, float] = {}
	for source: Vector2i in sources:
		var offsets: Array[Vector2i] = WorldGrid.NEIGHBORS_8.duplicate()
		if cliff_bonus:
			for y: int in range(-2, 3):
				for x: int in range(-2, 3):
					if absi(x) == 2 or absi(y) == 2:
						offsets.append(Vector2i(x, y))
		for offset: Vector2i in offsets:
			var cell: Vector2i = source + offset
			if scores.has(cell) or not _data.in_bounds(cell) or _occupied[_data.index(cell)] == 1 					or _data.meadow_rect.has_point(cell) or not grid.is_reached(cell, reached) or _behind_cliff(cell):
				continue
			var score: float = _count_cells_near(cell, sources, 2) + _rng.randf() * 2.0
			if cliff_bonus and (_cliff_set.has(cell + Vector2i.UP) or _cliff_set.has(cell + Vector2i(0, -2)) 					or _cliff_set.has(cell + Vector2i(0, -3))):
				score += 4.0
			scores[cell] = score
			candidates.append(cell)
	var chosen: Array[Vector2i] = []
	# Gần làng trước (cụm nhỏ cạnh làng), rồi tới chỗ có nhiều nguồn quanh nhất.
	var village: Vector2 = Vector2(_data.village_center)
	candidates.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		return Vector2(a).distance_squared_to(village) < Vector2(b).distance_squared_to(village))
	_pick_spaced(candidates, Balance.STARTER_PILES, spacing * 0.6, chosen)
	candidates.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return scores[a] > scores[b])
	_pick_spaced(candidates, count - chosen.size(), spacing, chosen)
	for cell: Vector2i in chosen:
		_add_object(kind, cell, 0, _jitter(Balance.ROCK_JITTER), _start_amount(capacity, Balance.START_AMOUNT_MIN))


func _cells_of_kind(kind: StringName) -> Dictionary[Vector2i, bool]:
	var cells: Dictionary[Vector2i, bool] = {}
	for object: Dictionary in _data.objects:
		if object["kind"] == kind:
			for at: Vector2i in MapData.resource_cells(object["kind"], object["cell"], int(object.get("variant", 0))):
				cells[at] = true
	return cells


func _count_cells_near(cell: Vector2i, cells: Dictionary[Vector2i, bool], reach: int) -> int:
	var count: int = 0
	for y: int in range(-reach, reach + 1):
		for x: int in range(-reach, reach + 1):
			if cells.has(cell + Vector2i(x, y)):
				count += 1
	return count


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
	# Sân làng giữa hang và lửa trại do GroundMask vẽ (World.refresh_yards), không còn là một mảng.
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


# Cây cỏ trang trí phủ kín map (kiểu Prehistoric Tribes), rậm thưa theo nhiễu: gần rừng nhiều
# dương xỉ, bụi lá, nấm; ven hồ lau sậy; chỗ trống cỏ cao, khóm cỏ, hoa; đồng cỏ chủ yếu hoa.
# Không đặt trên vật thể, nước, sân làng, lối mòn.
func _scatter_decor() -> void:
	var trees: Dictionary[Vector2i, bool] = _cells_of_kind(MapData.KIND_TREE)
	var trail_cells: Dictionary[Vector2i, bool] = {}
	for cell: Vector2i in _data.trails:
		trail_cells[cell] = true
	var village: Vector2 = _village_yard_center()
	for y: int in _data.size.y:
		for x: int in _data.size.x:
			var cell: Vector2i = Vector2i(x, y)
			var roll: float = _rng.randf()
			if _occupied[_data.index(cell)] == 1 or trail_cells.has(cell):
				continue
			if Vector2(cell).distance_to(village) < Balance.VILLAGE_DECOR_CLEAR:
				continue
			var near_tree: int = _count_cells_near(cell, trees, 1)
			var near_water: bool = false
			for offset: Vector2i in WorldGrid.NEIGHBORS_8:
				near_water = near_water or _data.is_water(cell + offset)
			# Nhiễu đẩy về hai đầu (smoothstep) để cây cỏ mọc thành đám rậm xen bãi trống, không rải đều.
			var lush: float = smoothstep(0.35, 0.65, _noise.get_noise_2d(x * 2.1 + 500.0, y * 2.1) * 0.9 + 0.5)
			lush = clampf(lush + near_tree * 0.12 + (0.3 if near_water else 0.0), 0.0, 1.0)
			var expected: float = lerpf(Balance.DECOR_SPARSE, Balance.DECOR_DENSITY, lush)
			var in_meadow: bool = _data.meadow_rect.has_point(cell)
			if in_meadow:
				expected = Balance.MEADOW_DECOR
			var count: int = floori(expected) + (1 if roll < expected - floori(expected) else 0)
			for i: int in count:
				var pos: Vector2 = WorldGrid.cell_to_world(cell) + Vector2(_rng.randf_range(-26, 26), _rng.randf_range(-22, 24))
				var kind: StringName = _decor_kind(in_meadow, near_water, near_tree > 0)
				_data.decor.append({"kind": kind, "pos": pos, "variant": _rng.randi_range(0, MapData.DECOR_VARIANTS[kind] - 1),
						"scale": _rng.randf_range(0.85, 1.15)})


func _decor_kind(in_meadow: bool, near_water: bool, near_tree: bool) -> StringName:
	var weights: Dictionary[StringName, float]
	if in_meadow:
		weights = {MapData.DECOR_FLOWER: 0.45, MapData.DECOR_TUFT: 0.35, MapData.DECOR_TALL_GRASS: 0.2}
	elif near_water:
		weights = {MapData.DECOR_REEDS: 0.55, MapData.DECOR_TALL_GRASS: 0.3, MapData.DECOR_TUFT: 0.15}
	elif near_tree:
		weights = {MapData.DECOR_FERN: 0.38, MapData.DECOR_SHRUB: 0.18, MapData.DECOR_MUSHROOM: 0.08,
				MapData.DECOR_TALL_GRASS: 0.2, MapData.DECOR_TUFT: 0.1, MapData.DECOR_FLOWER: 0.06}
	else:
		weights = {MapData.DECOR_TALL_GRASS: 0.32, MapData.DECOR_TUFT: 0.34, MapData.DECOR_SHRUB: 0.16,
				MapData.DECOR_FERN: 0.12, MapData.DECOR_FLOWER: 0.06}
	var roll: float = _rng.randf()
	for kind: StringName in weights:
		roll -= weights[kind]
		if roll <= 0.0:
			return kind
	return MapData.DECOR_TUFT


## Giữa hang và lửa trại — tâm sân làng (tính bằng ô, có thể lẻ).
func _village_yard_center() -> Vector2:
	return (Vector2(_data.cave_entrance_cell) + Vector2(_data.campfire_cell)) * 0.5


# --- Lối mòn có sẵn ---

# Lối mòn từ sân làng ra từng loại tài nguyên gần làng nhất (cây, đá tảng, bụi quả, bãi sỏi,
# đống củi, chỗ câu cá) — như người trong làng đã đi lại nhiều năm. Đi theo đường tìm được trên
# lưới nên không xuyên qua cây, đá.
func _place_trails() -> void:
	var grid: WorldGrid = _data.make_grid()
	var village: Vector2 = _village_yard_center()
	var seen: Dictionary[Vector2i, bool] = {}
	for kind: StringName in [MapData.KIND_TREE, MapData.KIND_ROCK, MapData.KIND_BUSH, MapData.KIND_PEBBLES,
			MapData.KIND_TWIGS, MapData.KIND_FISH_SPOT]:
		var nearest: Vector2i = Vector2i(-1, -1)
		for object: Dictionary in _data.objects_of_kind(kind):
			var cell: Vector2i = object["cell"]
			if nearest == Vector2i(-1, -1) or Vector2(cell).distance_to(village) < Vector2(nearest).distance_to(village):
				nearest = cell
		if nearest == Vector2i(-1, -1):
			continue
		var goal: Vector2i = _walkable_beside(grid, nearest)
		if goal == Vector2i(-1, -1):
			continue
		for cell: Vector2i in grid.astar.get_id_path(_data.cave_entrance_cell, goal, true):
			if Vector2(cell).distance_to(village) > Balance.VILLAGE_YARD_RADIUS - 0.5 and not seen.has(cell):
				seen[cell] = true
				_data.trails.append(cell)


func _walkable_beside(grid: WorldGrid, cell: Vector2i) -> Vector2i:
	if not grid.is_blocked(cell):
		return cell
	for offset: Vector2i in WorldGrid.NEIGHBORS_8:
		if grid.in_bounds(cell + offset) and not grid.is_blocked(cell + offset):
			return cell + offset
	return Vector2i(-1, -1)


func _can_place_nature(cell: Vector2i) -> bool:
	if _occupied[_data.index(cell)] == 1 or _data.is_water(cell):
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


## `extra`: thêm khoá cho vật (amount = lượng lúc đầu, growth = cây non lớn tới đâu).
func _add_object(kind: StringName, cell: Vector2i, variant: int, jitter: Vector2 = Vector2.ZERO, extra: Dictionary = {}) -> void:
	var object: Dictionary = {"kind": kind, "cell": cell, "variant": variant, "jitter": jitter}
	object.merge(extra)
	_data.objects.append(object)
	for at: Vector2i in MapData.resource_cells(kind, cell, variant):
		_occupied[_data.index(at)] = 1


## Chỉ sỏi/củi khác lượng; bụi quả/đá đầy, giữ lượt RNG để bố cục cùng seed ổn định.
func _start_amount(capacity: int, min_fraction: float, full: bool = false) -> Dictionary:
	# Giữ lượt RNG để đổi lượng không làm lệch vị trí tài nguyên của cùng seed.
	var rolled: int = _rng.randi_range(ceili(capacity * min_fraction), capacity)
	return {"amount": capacity if full else rolled}


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


func _near_water(at: Vector2i, radius: int) -> bool:
	for y: int in range(-radius, radius + 1):
		for x: int in range(-radius, radius + 1):
			if _data.is_water(at + Vector2i(x, y)):
				return true
	return false

func _place_bamboo_groves() -> void:
	var shore: Array[Vector2i] = []
	for y: int in _data.size.y:
		for x: int in _data.size.x:
			var at: Vector2i = Vector2i(x, y)
			if _can_place_nature(at) and _near_water(at, 3) and not _near_water(at, 1):
				shore.append(at)
	_shuffle(shore)
	var centers: Array[Vector2i] = []
	_pick_spaced(shore, Balance.BAMBOO_GROVES, Balance.BAMBOO_GROVE_SPACING, centers)
	for center: Vector2i in centers:
		for y: int in range(-2, 3):
			for x: int in range(-2, 3):
				var at: Vector2i = center + Vector2i(x, y)
				if _data.in_bounds(at) and _can_place_nature(at) and _near_water(at, Balance.BAMBOO_SHORE_DISTANCE) and not _near_water(at, 1) and _rng.randf() < Balance.BAMBOO_DENSITY:
					_add_tree(at, 2, 0.8)
