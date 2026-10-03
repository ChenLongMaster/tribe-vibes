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
