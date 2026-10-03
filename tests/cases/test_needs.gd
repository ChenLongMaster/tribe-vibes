extends TestCase
## 4 chỉ số dạng dữ liệu (GAME_DESIGN mục 5.3): tốc độ theo hoạt động, bật/tắt theo chế
## độ, việc nặng, việc thích; và hành vi khi chỉ số chạm đáy (gục ngủ, ngất).

const WORLD_SCENE: PackedScene = preload("res://world/world.tscn")
const ALL_NEEDS: Array[StringName] = [&"health", &"hunger", &"energy", &"fun"]


func test_need_defs_complete() -> void:
	check_eq(NeedDefs.ORDER.size(), 4, "Có đúng 4 chỉ số")
	for need_id: StringName in NeedDefs.ORDER:
		check(ArtLibrary.has_texture(NeedDefs.icon(need_id)), "Thiếu icon chỉ số %s" % need_id)
		var key: String = NeedDefs.DEFS[need_id]["name_key"]
		check(Loc.t(key) != key, "Thiếu chữ tooltip cho %s" % need_id)
	for skill_id: StringName in SkillDefs.ORDER:
		check(ArtLibrary.has_texture(SkillDefs.icon(skill_id)), "Thiếu icon kỹ năng %s" % skill_id)
		check(Loc.t(SkillDefs.name_key(skill_id)) != SkillDefs.name_key(skill_id), "Thiếu tên việc %s" % skill_id)


func test_rates_by_activity() -> void:
	var data: VillagerData = VillagerData.new()
	var idle: VillagerStatus = _half_status()
	VillagerNeeds.step(idle, data, ALL_NEEDS, {"activity": "idle"}, 10.0)
	check(idle.hunger < 50.0, "Rảnh vẫn đói dần")
	check(idle.fun > 50.0, "Rảnh thì giải trí hồi")
	check(idle.energy > 49.0, "Rảnh gần như không mất thể lực")

	var working: VillagerStatus = _half_status()
	VillagerNeeds.step(working, data, ALL_NEEDS, {"activity": "work", "skill": SkillDefs.GATHER}, 10.0)
	check(working.energy < idle.energy, "Làm việc mất thể lực nhiều hơn rảnh")
	check(working.fun < 50.0, "Làm việc thì giải trí giảm")

	var sleeping: VillagerStatus = _half_status()
	VillagerNeeds.step(sleeping, data, ALL_NEEDS, {"activity": "sleep", "sleep_rate": 2.0}, 10.0)
	var ground: VillagerStatus = _half_status()
	VillagerNeeds.step(ground, data, ALL_NEEDS, {"activity": "sleep", "sleep_rate": 1.0}, 10.0)
	check(sleeping.energy > ground.energy and ground.energy > 50.0, "Ngủ hồi thể lực, chỗ ngủ tốt hồi nhanh hơn")


func test_heavy_work_and_favorite() -> void:
	var data: VillagerData = VillagerData.new()
	data.favorite_job = SkillDefs.FISH
	var heavy: VillagerStatus = _half_status()
	VillagerNeeds.step(heavy, data, ALL_NEEDS, {"activity": "work", "skill": SkillDefs.CHOP}, 10.0)
	var light: VillagerStatus = _half_status()
	VillagerNeeds.step(light, data, ALL_NEEDS, {"activity": "work", "skill": SkillDefs.GATHER}, 10.0)
	check(heavy.hunger < light.hunger, "Việc nặng làm đói nhanh hơn")
	var favorite: VillagerStatus = _half_status()
	VillagerNeeds.step(favorite, data, ALL_NEEDS, {"activity": "work", "skill": SkillDefs.FISH}, 10.0)
	check(favorite.fun > light.fun, "Làm việc thích thì giải trí giảm chậm hơn")
	check(is_equal_approx(light.fun, heavy.fun), "Việc không thích không bị phạt thêm")


func test_disabled_needs_stay_still() -> void:
	var data: VillagerData = VillagerData.new()
	var status: VillagerStatus = _half_status()
	var only_hunger: Array[StringName] = [&"hunger"]
	VillagerNeeds.step(status, data, only_hunger, {"activity": "work", "skill": SkillDefs.CHOP}, 10.0)
	check(status.hunger < 50.0, "Chỉ số đang bật vẫn chạy")
	check(is_equal_approx(status.energy, 50.0) and is_equal_approx(status.fun, 50.0), "Chỉ số tắt thì đứng yên")


func test_starving_drains_health() -> void:
	var status: VillagerStatus = _half_status()
	status.hunger = 0.0
	VillagerNeeds.step(status, VillagerData.new(), ALL_NEEDS, {"activity": "idle"}, 10.0)
	check(status.health < 50.0, "Đói = 0 thì mất máu")


func test_mode_flags() -> void:
	var mode: GameModeConfig = GameModeConfig.new()
	check_eq(mode.villager_autonomy, GameModeConfig.Autonomy.OBEDIENT, "Mặc định thổ dân nghe lời")
	for need_id: StringName in ALL_NEEDS:
		check(mode.need_enabled(need_id), "Mặc định bật chỉ số %s" % need_id)
	var normal: GameModeConfig = load("res://modes/normal_mode.tres")
	check_eq(normal.villager_autonomy, GameModeConfig.Autonomy.OBEDIENT, "Normal: nghe lời")
	check_eq(normal.enabled_needs.size(), 4, "Normal: bật đủ 4 chỉ số")


func test_collapse_and_knockout() -> void:
	var world: World = WORLD_SCENE.instantiate()
	host.add_child(world)
	world.build(42)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	var cell: Vector2i = world.finder.find_free_cell_near(world.map_data.campfire_cell, 2.0, 4.0)
	var tired: Villager = Commands.get_villager(Commands.spawn_villager(VillagerFactory.create(rng, VillagerData.Gender.MALE, "vi"), cell))
	var weak: Villager = Commands.get_villager(Commands.spawn_villager(VillagerFactory.create(rng, VillagerData.Gender.FEMALE, "vi"), cell))
	tired.status.energy = 0.0
	tired.status.hunger = 90.0
	weak.status.health = 0.0
	weak.status.hunger = 0.0
	weak.status.energy = 90.0
	# Chờ hơn một nhịp suy nghĩ (0.3–0.6 giây).
	var waited: float = 0.0
	while waited < 1.0:
		await host.get_tree().process_frame
		waited += host.get_process_delta_time()
	check(tired.task is TaskSleep and (tired.task as TaskSleep).collapsed, "Thể lực = 0 thì gục ngủ tại chỗ")
	check(weak.task is TaskKnockedOut, "Máu = 0 thì ngất")

	Engine.time_scale = 20.0
	var elapsed: float = 0.0
	var woke_from_collapse: bool = false
	var weak_woke: bool = false
	var weak_health: float = 0.0
	# Dừng ngay khi cả hai đã dậy (giới hạn rộng: máy chạy nặng thì mỗi frame tua được ít hơn).
	while elapsed < Balance.KNOCKOUT_SECONDS + 30.0 and not (woke_from_collapse and weak_woke):
		await host.get_tree().process_frame
		elapsed += host.get_process_delta_time()
		if not (tired.task is TaskSleep and (tired.task as TaskSleep).collapsed) and tired.status.energy >= Balance.ENERGY_COLLAPSE_WAKE:
			woke_from_collapse = true
		if not weak_woke and not (weak.task is TaskKnockedOut):
			weak_woke = true
			weak_health = weak.status.health
	Engine.time_scale = 1.0
	check(woke_from_collapse, "Gục ngủ xong thì dậy khi đủ ~30% thể lực")
	check(weak_woke, "Ngất một lúc rồi tỉnh (độ khó Dễ)")
	check(weak_health > 0.0, "Tỉnh dậy còn chút máu")
	world.queue_free()
	await host.get_tree().process_frame


func _half_status() -> VillagerStatus:
	var status: VillagerStatus = VillagerStatus.new()
	status.health = 50.0
	status.hunger = 50.0
	status.energy = 50.0
	status.fun = 50.0
	return status
