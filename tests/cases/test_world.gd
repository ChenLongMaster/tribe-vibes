extends TestCase
## Dựng scene World thật: lưới, lớp nền, nước, vật thể khớp với MapData; camera nằm trong map.

const WORLD_SCENE: PackedScene = preload("res://world/world.tscn")


func test_world_builds_from_map_data() -> void:
	var world: World = WORLD_SCENE.instantiate()
	host.add_child(world)
	world.build(42)
	await host.get_tree().process_frame
	var data: MapData = world.map_data
	var ground: TileMapLayer = world.get_node("Ground")
	var water: TileMapLayer = world.get_node("Water")
	var entities: Node2D = world.get_node("Entities")
	check_eq(ground.get_used_cells().size(), data.size.x * data.size.y, "Mỗi ô có một ô cỏ")
	check(water.get_used_cells().size() > data.water.count(1), "Lớp nước dual-grid phủ hồ")
	var cliff_columns: int = 0
	for ridge: CliffRidge in world.cliff_ridges:
		cliff_columns += ridge.columns.size()
	check_eq(entities.get_child_count(), world.resource_nodes.size() + data.buildings.size() + world.animals.size() + cliff_columns,
			"Mỗi vật thể/công trình/con thú/cột vách đá một node")
	var cliff_cells: int = 0
	for ridge: CliffRidge in world.cliff_ridges:
		for column: int in ridge.columns:
			var span: Vector2i = ridge.columns[column]
			cliff_cells += span.y - span.x + 1
	check_eq(cliff_cells, data.cliffs.size(), "Mỗi cột vách đá là một đoạn ô liền (CliffRidge vẽ đúng)")
	check_eq(world.resource_nodes.size(), data.objects.size(), "Mỗi vật thể của map một mỏ (bãi sỏi, đống củi sinh cùng map)")
	check(not data.objects_of_kind(MapData.KIND_PEBBLES).is_empty() and not data.objects_of_kind(MapData.KIND_TWIGS).is_empty(),
			"Có bãi sỏi và đống củi")
	for cell: Vector2i in [data.objects_of_kind(MapData.KIND_PEBBLES)[0]["cell"], data.objects_of_kind(MapData.KIND_TWIGS)[0]["cell"]]:
		check(not world.grid.is_blocked(cell), "Bãi sỏi / đống củi không chặn đường")
	check_eq(world.animals.size(), Balance.ANIMAL_COUNT, "Đủ thú trên đồng cỏ")
	check(world.grid.is_blocked(data.campfire_cell), "Lửa trại chặn ô của nó")
	check(not world.grid.is_blocked(data.cave_entrance_cell), "Cửa hang đi qua được")
	var path: PackedVector2Array = world.grid.find_path(data.cave_entrance_cell, data.campfire_cell + Vector2i(0, 1))
	check(path.size() >= 2, "Tìm được đường từ cửa hang vòng ra trước lửa trại")
	var camera: CameraController = world.get_camera()
	var map_rect: Rect2 = Rect2(Vector2.ZERO, world.grid.pixel_size())
	check(map_rect.has_point(camera.position), "Camera nằm trong map")
	world.queue_free()
	await host.get_tree().process_frame


func test_art_lookup() -> void:
	check(not ArtLibrary.has_texture("khong/ton/tai"), "Key lạ không được coi là có hình")
	check(ArtLibrary.has_texture("env/tree_01"), "Hình tạm của cây phải có")
	for mask: int in range(1, 16):
		check(ArtLibrary.has_texture(WaterLayer.TILE_KEY_FORMAT % mask), "Thiếu hình nước %d" % mask)


## Cảm giác Prehistoric Tribes: người nhỏ so với nhà, sân đất + vòng đá quanh công trình (cây
## cỏ trong sân bị giấu), cây cỏ trang trí phủ map, lối mòn có sẵn, đi nhiều thì cỏ mòn thành đường.
func test_prehistoric_look() -> void:
	GameState.new_game(load("res://modes/normal_mode.tres"))
	var world: World = WORLD_SCENE.instantiate()
	host.add_child(world)
	world.build(42)
	await host.get_tree().process_frame
	var data: MapData = world.map_data
	check(data.decor.size() > data.size.x * data.size.y * 0.25, "Cây cỏ trang trí phủ khắp map (%d)" % data.decor.size())
	check(not data.trails.is_empty(), "Có lối mòn từ làng ra các cụm gần làng")
	check(world.wear_at(data.trails[0]) >= Balance.TRAIL_FLOOR, "Lối mòn có sẵn đã mòn")

	var cell: Vector2i = world.finder.find_free_cell_near(data.campfire_cell, 2.0, 4.0)
	var villager: Villager = world.spawn_villager(VillagerFactory.create(RandomNumberGenerator.new(), VillagerData.Gender.MALE, "vi"), cell)
	await host.get_tree().process_frame
	check(absf(villager.scale.x - Balance.VILLAGER_SCALE) < 0.01, "Thổ dân thu nhỏ so với nhà")
	check(villager.hit_test(villager.position + Villager.PICK_CENTER * villager.scale + Vector2(Balance.MIN_PICK_RADIUS - 2.0, 0)),
			"Vùng chạm vẫn đủ to cho điện thoại")

	# Đặt một cái lều ở bãi trống có cây cỏ: thành sân, cây cỏ trong sân bị giấu.
	var origin: Vector2i = World.INVALID_CELL
	for decor: Dictionary in data.decor:
		var candidate: Vector2i = WorldGrid.world_to_cell(decor["pos"])
		if world.placer.can_place(BuildingDefs.TENT, candidate):
			origin = candidate
			break
	check(origin != World.INVALID_CELL, "Có chỗ đặt lều trên bãi cỏ")
	var tent: Building = world.placer.place(BuildingDefs.TENT, origin)
	check(world.is_decor_hidden(origin), "Cây cỏ trong sân bị giấu")
	check(world.is_decor_hidden(origin + Vector2i(-1, 0)), "Sân rộng hơn chân lều một vòng")

	# Giẫm qua lại một ô thì mòn dần; lưu / tải giữ nguyên đường mòn.
	var path_cell: Vector2i = origin + Vector2i(4, 4)
	for i: int in 10:
		world.trample(path_cell)
	check(world.wear_at(path_cell) >= Balance.WEAR_PER_STEP * 9.5, "Đi qua nhiều thì mòn thành đường")
	var saved: Array = world.wear_to_save()
	world.apply_saved_wear([])
	check(world.wear_at(path_cell) < 0.01, "Xoá mòn (trừ lối mòn có sẵn)")
	world.apply_saved_wear(saved)
	check(world.wear_at(path_cell) >= Balance.WEAR_PER_STEP * 9.5, "Tải lại thì đường mòn còn nguyên")
	check(tent != null, "Đặt được lều")
	world.queue_free()
	await host.get_tree().process_frame
