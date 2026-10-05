extends TestCase
## Các luật phân bố mới phải đúng qua nhiều seed, không chỉ ảnh đẹp ở42.

func test_resource_grouping_and_shore_species() -> void:
	for seed_value: int in [1, 7, 42, 99, 1234]:
		var data: MapData = MapGenerator.new().generate(seed_value)
		var trees: Dictionary[Vector2i, int] = {}
		var groves: Dictionary[Vector2i, Array] = {}
		var occupied: Dictionary[Vector2i, bool] = {}
		var bamboo: int = 0
		var cliff_rocks: int = 0
		var rocks: int = 0
		for object: Dictionary in data.objects:
			var at: Vector2i = object["cell"]
			var species: int = int(object.get("variant", 0))
			for used: Vector2i in MapData.resource_cells(object["kind"], at, species):
				check(not occupied.has(used), "Seed%d: footprint tài nguyên không chồng" % seed_value)
				occupied[used] = true
				if object["kind"] != MapData.KIND_FISH_SPOT:
					check(not data.is_water(used), "Footprint không lấn nước")
			if object["kind"] == MapData.KIND_TREE:
				trees[at] = species
				if species == 2:
					bamboo += 1
					var shore: bool = false
					for y: int in range(-4, 5):
						for x: int in range(-4, 5):
							shore = shore or data.is_water(at + Vector2i(x, y))
					check(shore, "Tre chỉ trong dải ven hồ")
			elif object["kind"] == MapData.KIND_BUSH:
				var origin: Vector2i = object["grove"]
				if not groves.has(origin):
					groves[origin] = []
				groves[origin].append(at)
			elif object["kind"] == MapData.KIND_ROCK:
				rocks += 1
				check(species == 2 and MapData.resource_cells(object["kind"], at, species).size() == 4, "Map dùng mỏ đá liền2×2")
				var near_cliff: bool = false
				for y: int in range(-4, 1):
					for x: int in range(-2, 4):
						near_cliff = near_cliff or data.cliffs.has(at + Vector2i(x, y))
				if near_cliff:
					cliff_rocks += 1
		for at: Vector2i in trees:
			for offset: Vector2i in WorldGrid.NEIGHBORS_8:
				if trees.has(at + offset):
					check(trees[at] == trees[at + offset], "Hai loại cây không mọc xen sát nhau")
		for origin: Vector2i in groves:
			var cells: Array = groves[origin]
			check(cells.size() == 4 or cells.size() == 6, "Mỗi cụm dâu đủ4 hoặc6 bụi")
			var end: Vector2i = origin
			for at: Vector2i in cells:
				end = end.max(at)
			check((end.x - origin.x + 1) * (end.y - origin.y + 1) == cells.size(), "Cụm dâu chữ nhật không lỗ")
		check(bamboo > 0, "Có cụm tre ven hồ mỗi seed")
		check(cliff_rocks >= rocks * 0.6, "Phần lớn mỏ đá ở chân vách")

func test_large_rock_clear_and_save_footprint() -> void:
	GameState.new_game(preload("res://modes/normal_mode.tres"))
	var world: World = preload("res://world/world.tscn").instantiate()
	host.add_child(world)
	world.build(42)
	var rock: ResourceNode = null
	for node: ResourceNode in world.resource_nodes:
		if node.kind == MapData.KIND_ROCK:
			rock = node
			break
	check(rock != null, "Có mỏ đá để khai thác")
	var footprint: Array[Vector2i] = rock.footprint_cells()
	for at: Vector2i in footprint:
		check(world.grid.is_blocked(at), "Đá chặn đủ bốn ô")
	rock.harvest(floori(rock.capacity * 0.5))
	check(rock.art_key() == "env/rock_cluster_50", "Nửa mỏ dùng hình50")
	rock.harvest(ceili(rock.capacity * 0.2))
	check(rock.art_key() == "env/rock_cluster_30", "Dưới30% dùng hình30")
	var save: Dictionary = SaveGame.capture(world)
	rock.harvest(rock.amount)
	for at: Vector2i in footprint:
		check(not world.grid.is_blocked(at), "Đập hết mở đủ bốn ô")
	SaveGame.restore(world, save)
	for at: Vector2i in footprint:
		check(world.grid.is_blocked(at), "Nạp mỏ còn đá chặn lại đủ bốn ô")
	world.queue_free()
	await host.get_tree().process_frame
