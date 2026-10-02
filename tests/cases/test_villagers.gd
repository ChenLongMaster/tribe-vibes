extends TestCase
## Thổ dân: tạo ngẫu nhiên hợp lệ (kỹ năng, việc thích), lưu/đọc lại được, và làng "sống"
## được 5 phút trong game theo kiểu "nghe lời": rảnh chỉ quanh điểm neo, đói thì tự đi ăn,
## không ai chết đói khi còn quả, không ai đứng đơ.

const WORLD_SCENE: PackedScene = preload("res://world/world.tscn")
const PANEL_SCENE: PackedScene = preload("res://ui/common/villager_panel.tscn")
const SIM_SECONDS: float = 300.0 # 5 phút trong game
const SIM_TIME_SCALE: float = 20.0
const MIN_DISTINCT_ACTIVITIES: int = 5
## Hoạt cảnh rảnh rỗi tại chỗ — lúc làm mấy việc này phải ở trong vùng dạo chơi.
const IDLE_KINDS: Array[StringName] = [&"stroll", &"sit", &"scratch", &"chat", &"pick_flower"]
## Dư cho người đứng cạnh bạn tán gẫu / bông hoa ở mép vùng.
const IDLE_TOLERANCE_CELLS: float = 1.5


func test_factory_makes_valid_villagers() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 123
	for i: int in 40:
		var gender: VillagerData.Gender = VillagerData.Gender.MALE if i % 2 == 0 else VillagerData.Gender.FEMALE
		var data: VillagerData = VillagerFactory.create(rng, gender, "vi")
		check(not data.display_name.is_empty(), "Thổ dân phải có tên")
		check(data.traits.size() >= 1 and data.traits.size() <= 2, "Có 1–2 tính cách")
		check(not (data.traits.has(Traits.LAZY) and data.traits.has(Traits.DILIGENT)), "Không vừa Lười vừa Siêng năng")
		check(SkillDefs.ORDER.has(data.favorite_job), "Việc thích hợp lệ")
		for skill_id: StringName in SkillDefs.ORDER:
			var level: int = data.skill_level(skill_id)
			check(data.skills.has(skill_id), "Thiếu kỹ năng %s" % skill_id)
			check(level >= Balance.SKILL_MIN_LEVEL and level <= Balance.SKILL_START_CAP, "Cấp khởi đầu %s ngoài khoảng: %d" % [skill_id, level])
		if data.traits.has(Traits.STRONG):
			check(data.skill_level(SkillDefs.CHOP) >= 2, "Khoẻ như trâu thì Chặt cây khởi đầu ≥ 2")
		for key: String in VillagerData.DEFAULT_APPEARANCE:
			check(data.appearance.has(key), "Thiếu ngoại hình '%s'" % key)
		for trait_id: StringName in data.traits:
			check(Loc.t(Traits.name_key(trait_id)) != Traits.name_key(trait_id), "Thiếu chữ cho tính cách %s" % trait_id)


func test_save_round_trip() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 7
	var data: VillagerData = VillagerFactory.create(rng, VillagerData.Gender.FEMALE, "vi")
	# Đi qua JSON thật như khi lưu game.
	var json: String = JSON.stringify(data.to_dict())
	var restored: VillagerData = VillagerData.from_dict(JSON.parse_string(json))
	check_eq(JSON.stringify(restored.to_dict()), json, "VillagerData lưu rồi đọc lại phải ra y hệt")
	var status: VillagerStatus = VillagerStatus.starting(rng)
	var status_json: String = JSON.stringify(status.to_dict())
	var restored_status: VillagerStatus = VillagerStatus.from_dict(JSON.parse_string(status_json))
	check_eq(JSON.stringify(restored_status.to_dict()), status_json, "VillagerStatus lưu rồi đọc lại phải ra y hệt")


func test_appearance_uses_piece_ids() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 99
	for i: int in 20:
		var data: VillagerData = VillagerFactory.create(rng, VillagerData.Gender.MALE, "vi")
		for slot: String in VillagerData.PIECE_SLOTS:
			var piece: String = data.look(slot)
			if slot == "accessory" and piece.is_empty():
				continue
			check(piece.begins_with(slot + "_"), "Ô '%s' phải là ID mảnh, nhận '%s'" % [slot, piece])
			check(not piece.contains("/") and not piece.contains("."), "Ô '%s' không được là đường dẫn ảnh" % slot)
			if slot == "face":
				check(ArtLibrary.has_texture("villager/%s_happy" % piece), "Thiếu hình mặt cho '%s'" % piece)
			else:
				check(ArtLibrary.has_texture("villager/" + piece), "Thiếu hình cho mảnh '%s'" % piece)
		for slot: String in VillagerData.COLOR_SLOTS:
			check(data.look(slot).begins_with("#") and Color.html_is_valid(data.look(slot)), "Ô màu '%s' phải là mã màu" % slot)


func test_trait_modifiers() -> void:
	var lazy: Array[StringName] = [Traits.LAZY]
	check(is_equal_approx(Traits.modifier(lazy, "work_speed"), 0.8), "Lười làm chậm 20%")
	check(Traits.idle_weight(lazy, &"sit") > 1.0, "Lười hay ngồi hơn")
	check(not Traits.compatible(lazy, Traits.DILIGENT), "Lười không đi với Siêng năng")
	var none: Array[StringName] = []
	check(is_equal_approx(Traits.modifier(none, "work_speed"), 1.0), "Không tính cách thì hệ số 1")


func test_village_lives_for_five_minutes() -> void:
	# Ván mới: lửa trại có sẵn START_FOOD phần thức ăn, không còn đồ thừa của test trước.
	GameState.new_game(preload("res://modes/normal_mode.tres"))
	var world: World = WORLD_SCENE.instantiate()
	host.add_child(world)
	world.build(42)
	world.start_intro()
	Villager.watchdog_alerts = 0
	var activities: Dictionary[StringName, bool] = {}
	var starved_with_food: PackedStringArray = []
	var in_wall: PackedStringArray = []
	var strayed: PackedStringArray = []
	var elapsed: float = 0.0
	Engine.time_scale = SIM_TIME_SCALE
	while elapsed < SIM_SECONDS:
		await host.get_tree().process_frame
		elapsed += host.get_process_delta_time()
		var food_left: bool = _kitchen_has_food()
		for villager: Villager in world.villagers:
			if villager.task != null:
				activities[villager.task.kind] = true
			# Nghe lời: đang rảnh (hoạt cảnh tại chỗ) thì không được ra xa điểm neo.
			if villager.task != null and IDLE_KINDS.has(villager.task.kind):
				var away: float = Vector2(world.cell_of(villager) - villager.anchor_cell).length()
				if away > Balance.IDLE_RADIUS_CELLS + IDLE_TOLERANCE_CELLS and not strayed.has(villager.data.display_name):
					strayed.append("%s (%s, %.1f ô)" % [villager.data.display_name, villager.task.kind, away])
			if villager.status.hunger <= 0.0 and food_left and not starved_with_food.has(villager.data.display_name):
				starved_with_food.append(villager.data.display_name)
			if villager.task == null or villager.task.kind != &"emerge":
				if world.grid.is_blocked(world.cell_of(villager)) and not in_wall.has(villager.data.display_name):
					in_wall.append(villager.data.display_name)
	Engine.time_scale = 1.0

	check_eq(world.villagers.size(), Balance.START_VILLAGERS, "Cả bộ lạc phải chui ra khỏi hang")
	check(starved_with_food.is_empty(), "Đói lả dù bếp còn đồ ăn: %s" % ", ".join(starved_with_food))
	check(in_wall.is_empty(), "Đứng lọt vào ô bị chặn: %s" % ", ".join(in_wall))
	check_eq(Villager.watchdog_alerts, 0, "Watchdog báo có người đứng đơ")
	check(activities.size() >= MIN_DISTINCT_ACTIVITIES, "Làng ít hoạt động quá: %s" % str(activities.keys()))
	check(activities.has(&"chat"), "Phải có người tán gẫu")
	check(activities.has(&"eat"), "Đói < 50 thì phải tự đi ăn")
	check(not activities.has(&"snack"), "Không còn ăn vặt khi rảnh")
	check(strayed.is_empty(), "Rảnh mà đi xa điểm neo: %s" % ", ".join(strayed))
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


func _kitchen_has_food() -> bool:
	return GameState.get_amount(ResourceDefs.FOOD) > 0
