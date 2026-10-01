extends TestCase
## Thổ dân: tạo ngẫu nhiên hợp lệ, lưu/đọc lại được, và làng "sống" được 5 phút trong
## game mà không ai chết đói khi còn quả, không ai đứng đơ.

const WORLD_SCENE: PackedScene = preload("res://world/world.tscn")
const PANEL_SCENE: PackedScene = preload("res://ui/villager_panel.tscn")
const SIM_SECONDS: float = 300.0 # 5 phút trong game
const SIM_TIME_SCALE: float = 20.0
const MIN_DISTINCT_ACTIVITIES: int = 5


func test_factory_makes_valid_villagers() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 123
	for i: int in 40:
		var gender: VillagerData.Gender = VillagerData.Gender.MALE if i % 2 == 0 else VillagerData.Gender.FEMALE
		var data: VillagerData = VillagerFactory.create(rng, i + 1, gender, "vi")
		check(not data.display_name.is_empty(), "Thổ dân phải có tên")
		check(data.traits.size() >= 1 and data.traits.size() <= 2, "Có 1–2 tính cách")
		check(not (data.traits.has(Traits.LAZY) and data.traits.has(Traits.DILIGENT)), "Không vừa Lười vừa Siêng năng")
		check(VillagerData.JOBS.has(data.best_job), "Việc giỏi nhất hợp lệ")
		for key: String in ["head", "hair", "body", "accessory", "skin", "fur", "hair_color"]:
			check(data.appearance.has(key), "Thiếu ngoại hình '%s'" % key)
		for trait_id: StringName in data.traits:
			check(Loc.t(Traits.name_key(trait_id)) != Traits.name_key(trait_id), "Thiếu chữ cho tính cách %s" % trait_id)


func test_save_round_trip() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 7
	var data: VillagerData = VillagerFactory.create(rng, 5, VillagerData.Gender.FEMALE, "vi")
	# Đi qua JSON thật như khi lưu game.
	var json: String = JSON.stringify(data.to_dict())
	var restored: VillagerData = VillagerData.from_dict(JSON.parse_string(json))
	check_eq(JSON.stringify(restored.to_dict()), json, "Lưu rồi đọc lại phải ra y hệt")


func test_trait_modifiers() -> void:
	var lazy: Array[StringName] = [Traits.LAZY]
	check(is_equal_approx(Traits.modifier(lazy, "work_speed"), 0.8), "Lười làm chậm 20%")
	check(Traits.idle_weight(lazy, &"sit") > 1.0, "Lười hay ngồi hơn")
	check(not Traits.compatible(lazy, Traits.DILIGENT), "Lười không đi với Siêng năng")
	var none: Array[StringName] = []
	check(is_equal_approx(Traits.modifier(none, "work_speed"), 1.0), "Không tính cách thì hệ số 1")


func test_village_lives_for_five_minutes() -> void:
	var world: World = WORLD_SCENE.instantiate()
	host.add_child(world)
	world.build(42)
	world.start_intro()
	Villager.watchdog_alerts = 0
	var activities: Dictionary[StringName, bool] = {}
	var starved_with_food: PackedStringArray = []
	var in_wall: PackedStringArray = []
	var elapsed: float = 0.0
	Engine.time_scale = SIM_TIME_SCALE
	while elapsed < SIM_SECONDS:
		await host.get_tree().process_frame
		elapsed += host.get_process_delta_time()
		var berries_left: bool = _any_berries(world)
		for villager: Villager in world.villagers:
			if villager.task != null:
				activities[villager.task.kind] = true
			if villager.data.hunger <= 0.0 and berries_left and not starved_with_food.has(villager.data.display_name):
				starved_with_food.append(villager.data.display_name)
			if villager.task == null or villager.task.kind != &"emerge":
				if world.grid.is_blocked(world.cell_of(villager)) and not in_wall.has(villager.data.display_name):
					in_wall.append(villager.data.display_name)
	Engine.time_scale = 1.0

	check_eq(world.villagers.size(), Balance.START_VILLAGERS, "Cả bộ lạc phải chui ra khỏi hang")
	check(starved_with_food.is_empty(), "Chết đói dù còn quả: %s" % ", ".join(starved_with_food))
	check(in_wall.is_empty(), "Đứng lọt vào ô bị chặn: %s" % ", ".join(in_wall))
	check_eq(Villager.watchdog_alerts, 0, "Watchdog báo có người đứng đơ")
	check(activities.size() >= MIN_DISTINCT_ACTIVITIES, "Làng ít hoạt động quá: %s" % str(activities.keys()))
	check(activities.has(&"chat"), "Phải có người tán gẫu")
	print("        (hoạt động đã thấy: %s)" % ", ".join(PackedStringArray(activities.keys())))

	# Chạm vào một thổ dân thì chọn được người đó.
	var first: Villager = world.villagers[0]
	check(world.pick_villager(first.position + Villager.PICK_CENTER) == first, "Chạm vào thổ dân phải chọn đúng người")
	check(world.pick_villager(first.position + Vector2(300, 300)) != first, "Chạm chỗ trống không chọn ai")

	# Bảng thông tin hiện đủ chữ khi chọn.
	var panel: Control = PANEL_SCENE.instantiate()
	host.add_child(panel)
	EventBus.villager_selected.emit(first)
	await host.get_tree().process_frame
	check(panel.visible, "Chọn thổ dân thì bảng thông tin phải hiện")
	EventBus.villager_selected.emit(null)
	check(not panel.visible, "Bỏ chọn thì bảng thông tin phải ẩn")
	panel.queue_free()
	world.queue_free()
	await host.get_tree().process_frame


func _any_berries(world: World) -> bool:
	for node: ResourceNode in world.resource_nodes:
		if node.has_berries():
			return true
	return false
