extends TestCase
## Sinh đầy là luật dữ liệu; không ép đầy lại khi nạp mỏ đã bị khai thác.

func test_initial_resources_and_bamboo() -> void:
	var twig_amounts: Dictionary[int, bool] = {}
	var pebble_amounts: Dictionary[int, bool] = {}
	var bamboo_count: int = 0
	for seed_value: int in [1, 7, 42, 99]:
		var data: MapData = MapGenerator.new().generate(seed_value)
		for object: Dictionary in data.objects:
			var kind: StringName = object["kind"]
			if kind == MapData.KIND_BUSH:
				check_eq(int(object.get("amount", Balance.BUSH_FOOD)), Balance.BUSH_FOOD, "Bụi mới sinh đầy")
			elif kind == MapData.KIND_ROCK:
				check_eq(int(object.get("amount", Balance.ROCK_CLUSTER_STONE)), Balance.ROCK_CLUSTER_STONE, "Đá tảng mới sinh đầy")
			elif kind == MapData.KIND_TWIGS:
				twig_amounts[int(object["amount"])] = true
			elif kind == MapData.KIND_PEBBLES:
				pebble_amounts[int(object["amount"])] = true
			elif kind == MapData.KIND_TREE and int(object["variant"]) == 2:
				bamboo_count += 1
	check(twig_amounts.size() > 1, "Đống củi còn khác lượng lúc sinh")
	check(pebble_amounts.size() > 1, "Bãi sỏi còn khác lượng lúc sinh")
	check(bamboo_count > 0, "Map có biến thể tre cho gỗ")


func test_berries_save_and_bamboo_stump() -> void:
	var scene: PackedScene = preload("res://world/resource_node.tscn")
	var bush: ResourceNode = scene.instantiate()
	bush.setup(MapData.KIND_BUSH, Vector2i(10, 10), 0)
	host.add_child(bush)
	check_eq(bush.amount, bush.capacity, "Spawn trực tiếp đầy")
	bush.harvest(bush.capacity - 5)
	var saved: Dictionary = bush.to_dict()
	var loaded: ResourceNode = scene.instantiate()
	loaded.setup(MapData.KIND_BUSH, Vector2i(10, 10), 0)
	host.add_child(loaded)
	check(loaded.apply_dict(saved), "Khôi phục cùng loại bụi quả")
	check_eq(loaded.amount, 5, "Nạp save giữ lượng quả đã hái")
	check_eq(loaded.art_key(), "env/bush_20", "Save ít quả dùng hình ít")
	var bamboo: ResourceNode = scene.instantiate()
	bamboo.setup(MapData.KIND_TREE, Vector2i(12, 10), 2)
	host.add_child(bamboo)
	check_eq(bamboo.art_key(), "env/tree_03", "Tre dùng hình riêng")
	bamboo.harvest(bamboo.capacity)
	check_eq(bamboo.art_key(), "env/bamboo_stump", "Chặt tre còn gốc tre")
	bamboo.regrow()
	check_eq(bamboo.art_key(), "env/tree_03", "Tre mọc lại đúng ngoại hình")
	for node: ResourceNode in [bush, loaded, bamboo]:
		node.queue_free()
	await host.get_tree().process_frame
