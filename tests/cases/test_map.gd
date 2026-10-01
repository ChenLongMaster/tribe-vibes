extends TestCase
## Sinh map: lặp lại được theo seed, đủ tài nguyên, đúng bố cục, mọi thứ tới được.

const SEEDS: Array[int] = [1, 2, 3, 7, 42, 99, 1234, 31337, 65535, 2024, 777, 5]


func test_same_seed_same_map() -> void:
	for seed_value: int in [1, 42, 31337]:
		var first: String = MapGenerator.new().generate(seed_value).fingerprint()
		var second: String = MapGenerator.new().generate(seed_value).fingerprint()
		check(first == second, "Seed %d sinh hai lần ra hai map khác nhau" % seed_value)


func test_different_seeds_differ() -> void:
	var a: String = MapGenerator.new().generate(1).fingerprint()
	var b: String = MapGenerator.new().generate(2).fingerprint()
	check(a != b, "Seed 1 và 2 ra cùng một map")


func test_enough_resources() -> void:
	for seed_value: int in SEEDS:
		var data: MapData = MapGenerator.new().generate(seed_value)
		var trees: int = data.objects_of_kind(MapData.KIND_TREE).size()
		var rocks: int = data.objects_of_kind(MapData.KIND_ROCK).size()
		var bushes: int = data.objects_of_kind(MapData.KIND_BUSH).size()
		var spots: int = data.objects_of_kind(MapData.KIND_FISH_SPOT).size()
		var water: int = data.water.count(1)
		check(trees >= 60, "Seed %d: ít cây quá (%d)" % [seed_value, trees])
		check(rocks >= 10, "Seed %d: ít đá quá (%d)" % [seed_value, rocks])
		check(bushes >= 8, "Seed %d: ít bụi quả quá (%d)" % [seed_value, bushes])
		check(spots >= 3, "Seed %d: ít chỗ câu cá quá (%d)" % [seed_value, spots])
		check(water >= 25, "Seed %d: hồ nhỏ quá (%d ô)" % [seed_value, water])


func test_everything_reachable_from_cave() -> void:
	for seed_value: int in SEEDS:
		var data: MapData = MapGenerator.new().generate(seed_value)
		var grid: WorldGrid = data.make_grid()
		check(not grid.is_blocked(data.cave_entrance_cell), "Seed %d: cửa hang bị chặn" % seed_value)
		var reached: PackedByteArray = grid.flood_fill(data.cave_entrance_cell)
		var stuck: int = 0
		for object: Dictionary in data.objects:
			if not grid.has_reachable_neighbor(object["cell"], reached):
				stuck += 1
		check(stuck == 0, "Seed %d: %d vật thể không đi tới được" % [seed_value, stuck])
		check(grid.has_reachable_neighbor(data.campfire_cell, reached), "Seed %d: không tới được lửa trại" % seed_value)


func test_layout() -> void:
	for seed_value: int in SEEDS:
		var data: MapData = MapGenerator.new().generate(seed_value)
		var center: Vector2 = Vector2(data.village_center)
		check(center.distance_to(Vector2(data.size) * 0.5) <= 1.5, "Seed %d: làng không ở giữa map" % seed_value)
		var forest_x: float = _average_x(data.objects_of_kind(MapData.KIND_TREE)) - center.x
		var rock_x: float = _average_x(data.objects_of_kind(MapData.KIND_ROCK)) - center.x
		var forest_west: bool = data.forest_side == MapData.Edge.WEST
		check(forest_x < 0.0 if forest_west else forest_x > 0.0, "Seed %d: rừng không nằm đúng phía" % seed_value)
		check(rock_x > 0.0 if forest_west else rock_x < 0.0, "Seed %d: bãi đá không nằm đúng phía" % seed_value)
		var water_y: float = _average_water_y(data) - center.y
		var lake_north: bool = data.lake_side == MapData.Edge.NORTH
		check(water_y < 0.0 if lake_north else water_y > 0.0, "Seed %d: hồ không nằm đúng phía" % seed_value)
		check(data.raid_side != data.lake_side, "Seed %d: cannibal đến từ phía hồ" % seed_value)


func test_village_is_clear() -> void:
	for seed_value: int in SEEDS:
		var data: MapData = MapGenerator.new().generate(seed_value)
		var center: Vector2 = Vector2(data.village_center)
		for object: Dictionary in data.objects:
			var kind: StringName = object["kind"]
			if kind == MapData.KIND_TREE or kind == MapData.KIND_ROCK:
				var distance: float = Vector2(object["cell"]).distance_to(center)
				check(distance >= Balance.VILLAGE_CLEAR_RADIUS, "Seed %d: %s mọc giữa làng" % [seed_value, kind])


func test_no_overlaps() -> void:
	for seed_value: int in SEEDS:
		var data: MapData = MapGenerator.new().generate(seed_value)
		var used: Dictionary[Vector2i, bool] = {}
		for building: Dictionary in data.buildings:
			for cell: Vector2i in BuildingDefs.footprint_cells(building["id"], building["cell"]):
				check(not data.is_water(cell), "Seed %d: công trình nằm trên nước" % seed_value)
				used[cell] = true
		for object: Dictionary in data.objects:
			var cell: Vector2i = object["cell"]
			check(not used.has(cell), "Seed %d: hai vật thể chồng nhau ở %s" % [seed_value, cell])
			used[cell] = true
			var on_water: bool = data.is_water(cell)
			if object["kind"] == MapData.KIND_FISH_SPOT:
				check(on_water, "Seed %d: chỗ câu cá không nằm trên nước" % seed_value)
			else:
				check(not on_water, "Seed %d: %s mọc dưới nước" % [seed_value, object["kind"]])


func _average_x(objects: Array[Dictionary]) -> float:
	if objects.is_empty():
		return 0.0
	var total: float = 0.0
	for object: Dictionary in objects:
		total += Vector2i(object["cell"]).x
	return total / objects.size()


func _average_water_y(data: MapData) -> float:
	var total: float = 0.0
	var count: int = 0
	for y: int in data.size.y:
		for x: int in data.size.x:
			if data.is_water(Vector2i(x, y)):
				total += y
				count += 1
	return total / maxi(count, 1)
