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
		check(rocks >= 5 and rocks <= 24, "Seed %d: số mỏ lớn ngoài khoảng5–24 (%d)" % [seed_value, rocks])
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
			var reachable: bool = false
			for at: Vector2i in MapData.resource_cells(object["kind"], object["cell"], int(object.get("variant", 0))):
				reachable = reachable or grid.has_reachable_neighbor(at, reached)
			if not reachable:
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


## Map rộng kiểu RTS: có dãy vách đá (không đi qua được, có đá tảng dưới chân), gần làng có
## sẵn một cụm nhỏ mỗi loại tài nguyên, cây mọc thành cụm chứ không rải đều.
func test_rts_layout() -> void:
	for seed_value: int in SEEDS:
		var data: MapData = MapGenerator.new().generate(seed_value)
		check_eq(data.size, Vector2i(Balance.MAP_WIDTH, Balance.MAP_HEIGHT), "Seed %d: cỡ map" % seed_value)
		check(data.cliffs.size() >= Balance.CLIFF_RIDGE_MIN_LENGTH * 3, "Seed %d: ít vách đá quá (%d ô)" % [seed_value, data.cliffs.size()])
		var grid: WorldGrid = data.make_grid()
		var blocked: bool = true
		for cell: Vector2i in data.cliffs:
			blocked = blocked and grid.is_blocked(cell)
		check(blocked, "Seed %d: vách đá phải chặn đường" % seed_value)
		var center: Vector2 = Vector2(data.village_center)
		# Gần làng đủ mỗi thứ một cụm nhỏ (bụi quả giờ là bụi to, 2–3 bụi một vạt).
		var wanted: Dictionary[StringName, int] = {
			MapData.KIND_TREE: 3, MapData.KIND_ROCK: 1, MapData.KIND_BUSH: Balance.BERRY_GROVE_MIN,
			MapData.KIND_PEBBLES: 1, MapData.KIND_TWIGS: 1,
		}
		for kind: StringName in wanted:
			var near: int = 0
			for object: Dictionary in data.objects_of_kind(kind):
				if Vector2(object["cell"]).distance_to(center) <= 13.0:
					near += 1
			check(near >= wanted[kind], "Seed %d: gần làng thiếu cụm %s (%d)" % [seed_value, kind, near])
		# Cây mọc thành cụm: phần lớn cây có cây khác ngay sát bên.
		var trees: Dictionary[Vector2i, bool] = {}
		for object: Dictionary in data.objects_of_kind(MapData.KIND_TREE):
			trees[object["cell"]] = true
		var clustered: int = 0
		for cell: Vector2i in trees:
			for offset: Vector2i in WorldGrid.NEIGHBORS_8:
				if trees.has(cell + offset):
					clustered += 1
					break
		check(clustered >= trees.size() * 0.8, "Seed %d: cây rải lẻ tẻ quá (%d/%d có cây bên cạnh)" % [seed_value, clustered, trees.size()])


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
