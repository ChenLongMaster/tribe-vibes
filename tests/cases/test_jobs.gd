extends TestCase
## Đợt 2 — Lao động & tài nguyên: giao việc qua Commands, việc tự lặp lại, khuân về kho,
## bị ngắt thì quay lại, hết tài nguyên thì dừng + nói vì sao, kỹ năng lên cấp, đình công,
## săn + nấu, câu cá, controller chạm để giao việc, HUD hiện số trong kho.

const WORLD_SCENE: PackedScene = preload("res://world/world.tscn")
const HUD_SCENE: PackedScene = preload("res://ui/normal/hud.tscn")
const NORMAL_MODE: GameModeConfig = preload("res://modes/normal_mode.tres")
const SIM_TIME_SCALE: float = 20.0
const WORK_SIM_SECONDS: float = 300.0 # 5 phút trong game
const SAMPLE_SECONDS: float = 60.0
const IDLE_KINDS: Array[StringName] = [&"stroll", &"sit", &"scratch", &"chat", &"pick_flower"]
const IDLE_TOLERANCE_CELLS: float = 1.5


func test_job_defs_complete() -> void:
	for skill: StringName in JobDefs.DEFS:
		var def: Dictionary = JobDefs.get_def(skill)
		for key_name: String in ["activity_key", "none_bubble"]:
			var key: String = def[key_name]
			check(Loc.t(key) != key, "Thiếu chữ '%s' cho việc %s" % [key, skill])
		var tool_key: String = def["tool"]
		check(tool_key.is_empty() or ArtLibrary.has_texture(tool_key), "Thiếu hình đồ nghề %s" % skill)
	for resource_id: StringName in ResourceDefs.ORDER:
		check(ArtLibrary.has_texture(ResourceDefs.icon(resource_id)), "Thiếu icon tài nguyên %s" % resource_id)
		check(Loc.t(ResourceDefs.name_key(resource_id)) != ResourceDefs.name_key(resource_id), "Thiếu tên %s" % resource_id)
		check(Loc.t(ResourceDefs.noun_key(resource_id)) != ResourceDefs.noun_key(resource_id), "Thiếu tên viết thường %s" % resource_id)
		check(not Loc.plural(ResourceDefs.count_key(resource_id), 3).contains("RES_"), "Thiếu số nhiều %s" % resource_id)
	for key: String in ["animals/boar", "animals/deer", "icons/angry", "fx/dust", "ui/target_ring", "ui/move_marker",
			"ui/speed_pause", "ui/speed_1", "ui/speed_2", "ui/speed_3"]:
		check(ArtLibrary.has_texture(key), "Thiếu hình %s" % key)


func test_key_args_are_translated() -> void:
	var text: String = Loc.t("TOAST_LEVEL_UP", {"name": "Bạp", "job_key": "JOB_CHOP", "level": 2})
	check(text.contains(Loc.t("JOB_CHOP")) and text.contains("Bạp"), "Tham số *_key được dịch: '%s'" % text)
	check(not text.contains("JOB_CHOP") and not text.contains("{"), "Không còn key/chỗ giữ chỗ thô: '%s'" % text)


func test_skill_xp_and_favorite() -> void:
	var data: VillagerData = VillagerData.new()
	data.favorite_job = SkillDefs.CHOP
	data.skills[SkillDefs.CHOP] = 1
	data.skills[SkillDefs.MINE] = 1
	var status: VillagerStatus = VillagerStatus.new()
	var half: float = Balance.SKILL_XP_TO_NEXT[0] * 0.5
	check_eq(VillagerSkills.gain(status, data, SkillDefs.MINE, half), 0, "Việc thường: nửa số kinh nghiệm chưa lên cấp")
	check_eq(VillagerSkills.gain(status, data, SkillDefs.CHOP, half), 2, "Việc thích nhận ×2 kinh nghiệm → lên cấp 2")
	check_eq(status.skill_level(SkillDefs.CHOP, data), 2, "Cấp hiện tại đọc từ VillagerStatus")
	check_eq(data.skill_level(SkillDefs.CHOP), 1, "Cấp khởi đầu trong VillagerData không đổi")
	status.skill_levels[SkillDefs.MINE] = Balance.SKILL_MAX_LEVEL
	check_eq(VillagerSkills.gain(status, data, SkillDefs.MINE, 99999.0), 0, "Cấp tối đa thì không lên nữa")
	check(SkillDefs.speed_for_level(3) > SkillDefs.speed_for_level(1), "Cấp cao làm nhanh hơn")
	var restored: VillagerStatus = VillagerStatus.from_dict(JSON.parse_string(JSON.stringify(status.to_dict())))
	check_eq(restored.skill_level(SkillDefs.CHOP, data), 2, "Cấp đã lên được lưu lại")


## Tiêu chí "xong" của Đợt 2: 3 người chặt gỗ, 2 người đập đá, số trong kho tăng đều,
## không ai đứng đơ; người không được giao việc vẫn đứng chơi quanh chỗ cũ.
func test_three_choppers_two_miners() -> void:
	var world: World = await _make_world(42)
	var villagers: Array[Villager] = _spawn(world, 6)
	var tree: ResourceNode = _nearest(world, MapData.KIND_TREE)
	var rock: ResourceNode = _nearest(world, MapData.KIND_ROCK)
	for i: int in 3:
		check(Commands.assign_job(villagers[i].id, tree), "Giao chặt cây cho người %d" % i)
	for i: int in range(3, 5):
		check(Commands.assign_job(villagers[i].id, rock), "Giao đập đá cho người %d" % i)
	var idler: Villager = villagers[5]
	var idle_anchor: Vector2i = idler.anchor_cell
	Villager.watchdog_alerts = 0

	var samples: Array[Vector2i] = []
	var strayed: Array[String] = []
	var kinds: Dictionary[StringName, bool] = {}
	var next_sample: float = SAMPLE_SECONDS
	var elapsed: float = 0.0
	Engine.time_scale = SIM_TIME_SCALE
	while elapsed < WORK_SIM_SECONDS:
		await host.get_tree().process_frame
		elapsed += host.get_process_delta_time()
		if elapsed >= next_sample:
			next_sample += SAMPLE_SECONDS
			samples.append(Vector2i(GameState.get_amount(ResourceDefs.WOOD), GameState.get_amount(ResourceDefs.STONE)))
		for villager: Villager in villagers:
			if villager.task != null:
				kinds[villager.task.kind] = true
		if idler.task != null and IDLE_KINDS.has(idler.task.kind):
			var away: float = Vector2(world.cell_of(idler) - idler.anchor_cell).length()
			if away > Balance.IDLE_RADIUS_CELLS + IDLE_TOLERANCE_CELLS and strayed.size() < 3:
				strayed.append("%s %.1f ô" % [idler.task.kind, away])
	Engine.time_scale = 1.0

	print("        (gỗ/đá mỗi phút: %s; việc đã thấy: %s)" % [str(samples), ", ".join(PackedStringArray(kinds.keys()))])
	var previous: Vector2i = Vector2i.ZERO
	for sample: Vector2i in samples:
		check(sample.x > previous.x, "Gỗ phải tăng mỗi phút: %s" % str(samples))
		check(sample.y > previous.y, "Đá phải tăng mỗi phút: %s" % str(samples))
		previous = sample
	check_eq(Villager.watchdog_alerts, 0, "Watchdog báo có người đứng đơ")
	for i: int in 5:
		var villager: Villager = villagers[i]
		check(villager.job != null, "%s bỏ việc giữa chừng" % villager.data.display_name)
		var skill: StringName = SkillDefs.CHOP if i < 3 else SkillDefs.MINE
		var learned: bool = villager.status.skill_xp.get(skill, 0.0) > 0.0 or villager.status.skill_levels.has(skill)
		check(learned, "%s làm việc phải có kinh nghiệm" % villager.data.display_name)
	check(idler.job == null and idler.anchor_cell == idle_anchor, "Người không được giao việc giữ nguyên điểm neo")
	check(strayed.is_empty(), "Người không được giao việc đi xa điểm neo: %s" % ", ".join(strayed))
	check(kinds.has(&"harvest"), "Phải thấy làm việc")
	await _free_world(world)


func test_job_resumes_after_eating() -> void:
	var world: World = await _make_world(7)
	var worker: Villager = _spawn(world, 1)[0]
	_fill_needs(worker)
	Commands.assign_job(worker.id, _nearest(world, MapData.KIND_TREE))
	var job: Job = worker.job
	var state: Dictionary = {"made_hungry": false, "ate": false, "resumed": false}
	await _simulate(120.0, func(_elapsed: float) -> bool:
		if not state["made_hungry"] and worker.task is TaskHarvest and worker.state == Villager.State.WORKING:
			state["made_hungry"] = true
			worker.status.hunger = 30.0
		elif state["made_hungry"] and not state["ate"] and worker.task != null and worker.task.kind == &"eat":
			state["ate"] = true
		elif state["ate"] and worker.task is TaskWork:
			state["resumed"] = true
		return state["resumed"])
	check(state["made_hungry"], "Phải bắt đầu chặt cây")
	check(state["ate"], "Đói < 50 thì bỏ việc đi ăn")
	check(state["resumed"], "Ăn xong tự quay lại làm tiếp")
	check(worker.job == job, "Vẫn nhớ đúng việc cũ")
	await _free_world(world)


func test_job_stops_when_nothing_left() -> void:
	var world: World = await _make_world(11)
	var worker: Villager = _spawn(world, 1)[0]
	_fill_needs(worker)
	var bush: ResourceNode = _nearest(world, MapData.KIND_BUSH)
	# Hái sạch mọi bụi khác: hái xong bụi này là hết quả quanh đó.
	for node: ResourceNode in world.resource_nodes:
		if node.kind == MapData.KIND_BUSH and node != bush:
			node.take_berries()
	var bubbles: Array[String] = []
	worker.speech_requested.connect(func(key: String, _args: Dictionary, _icon: String, _seconds: float) -> void:
		bubbles.append(key))
	var berries_before: int = GameState.get_amount(ResourceDefs.BERRY)
	Commands.assign_job(worker.id, bush)
	await _simulate(90.0, func(_elapsed: float) -> bool: return worker.job == null)
	check(worker.job == null, "Hết bụi quả thì thôi việc")
	check(bubbles.has("BUBBLE_NO_BERRIES"), "Thôi việc phải nói 'Hết quả rồi!' — nghe được: %s" % str(bubbles))
	check(GameState.get_amount(ResourceDefs.BERRY) > berries_before, "Quả hái được phải vào kho")
	check_eq(worker.anchor_cell, world.cell_of(worker), "Dừng việc thì đứng chờ tại chỗ")
	await _free_world(world)


func test_strike_and_resume() -> void:
	var world: World = await _make_world(5)
	var worker: Villager = _spawn(world, 1)[0]
	_fill_needs(worker)
	var toasts: Array[String] = []
	var on_event: Callable = func(key: String, _args: Dictionary, _icon: String) -> void: toasts.append(key)
	EventBus.village_event.connect(on_event)
	Commands.assign_job(worker.id, _nearest(world, MapData.KIND_ROCK))
	var job: Job = worker.job
	# Đặt giải trí = 0 đúng lúc đang làm (đang đi thì giải trí còn hồi chút ít).
	await _simulate(60.0, func(_elapsed: float) -> bool:
		return worker.task is TaskHarvest and worker.state == Villager.State.WORKING)
	worker.status.fun = 0.0
	await _simulate(5.0, func(_elapsed: float) -> bool: return worker.on_strike)
	check(worker.on_strike, "Giải trí = 0 thì đình công")
	check(worker.task is TaskStrike, "Đình công: quăng đồ nghề, dậm chân")
	check(toasts.has("TOAST_STRIKE"), "Có thông báo đình công")
	check(worker.activity_icon() == "icons/angry", "Trên đầu hiện 💢")
	Commands.assign_job(worker.id, _nearest(world, MapData.KIND_TREE))
	await _simulate(10.0)
	check(not (worker.task is TaskWork), "Đang đình công thì từ chối làm việc")
	worker.status.fun = Balance.STRIKE_RESUME_FUN + 5.0
	await _simulate(10.0, func(_elapsed: float) -> bool: return worker.task is TaskWork)
	check(not worker.on_strike, "Giải trí hồi đủ thì hết đình công")
	check(worker.task is TaskWork, "Hết giận thì tự làm lại việc")
	check(worker.job != null and worker.job != job and worker.job.skill == SkillDefs.CHOP, "Làm việc được giao gần nhất")
	check(toasts.has("TOAST_STRIKE_END"), "Có thông báo hết đình công")
	EventBus.village_event.disconnect(on_event)
	await _free_world(world)


func test_hunt_then_cook() -> void:
	var world: World = await _make_world(42)
	var villagers: Array[Villager] = _spawn(world, 2)
	var hunter: Villager = villagers[0]
	var cook: Villager = villagers[1]
	_fill_needs(hunter)
	_fill_needs(cook)
	var meat_before: int = GameState.get_amount(ResourceDefs.RAW_MEAT)
	var meals_before: int = GameState.get_amount(ResourceDefs.COOKED_MEAL)
	var delivered: Array[StringName] = []
	var on_delivered: Callable = func(resource_id: StringName, _amount: int, _pos: Vector2) -> void: delivered.append(resource_id)
	EventBus.resource_delivered.connect(on_delivered)
	var animal: Animal = world.animals[0]
	check(Commands.assign_job(hunter.id, animal), "Giao đi săn")
	var campfire: Building = _campfire(world)
	check(Commands.assign_job(cook.id, campfire), "Giao nấu ăn ở lửa trại")
	check_eq(cook.job.skill, SkillDefs.COOK, "Chạm lửa trại = nấu ăn")
	await _simulate(240.0, func(_elapsed: float) -> bool:
		return GameState.get_amount(ResourceDefs.COOKED_MEAL) > meals_before)
	check(delivered.has(ResourceDefs.RAW_MEAT), "Thợ săn mang thịt về")
	check(GameState.get_amount(ResourceDefs.COOKED_MEAL) > meals_before, "Đầu bếp nấu ra món chín")
	check(GameState.get_amount(ResourceDefs.RAW_MEAT) < meat_before + Balance.MEAT_PER_HUNT * 3, "Thịt sống được đem nấu")
	check(hunter.job != null and hunter.job.skill == SkillDefs.HUNT, "Thợ săn vẫn đi săn tiếp")
	EventBus.resource_delivered.disconnect(on_delivered)
	await _free_world(world)


func test_fishing() -> void:
	var world: World = await _make_world(42)
	var fisher: Villager = _spawn(world, 1)[0]
	_fill_needs(fisher)
	var fish_before: int = GameState.get_amount(ResourceDefs.RAW_FISH)
	check(Commands.assign_job(fisher.id, _nearest(world, MapData.KIND_FISH_SPOT)), "Giao câu cá")
	await _simulate(120.0, func(_elapsed: float) -> bool:
		return GameState.get_amount(ResourceDefs.RAW_FISH) > fish_before)
	check(GameState.get_amount(ResourceDefs.RAW_FISH) > fish_before, "Câu được cá về kho")
	await _free_world(world)


func test_controller_tap_assigns_and_moves() -> void:
	var world: World = await _make_world(42)
	var villager: Villager = _spawn(world, 1)[0]
	_fill_needs(villager)
	var controller: NormalController = NormalController.new()
	host.add_child(controller)
	controller.setup(world, NORMAL_MODE)
	await host.get_tree().process_frame
	var tree: ResourceNode = _nearest(world, MapData.KIND_TREE)

	controller._on_tapped(_to_screen(villager.position + Villager.PICK_CENTER))
	check(controller.selected == villager, "Chạm thổ dân thì chọn")
	controller._on_tapped(_to_screen(tree.position + Vector2(0, -40)))
	check(villager.job != null and villager.job.skill == SkillDefs.CHOP, "Đang chọn mà chạm cây → giao chặt cây")
	check(controller.selected == null, "Ra lệnh xong thì bỏ chọn")

	var ground: Vector2i = world.finder.find_free_cell_near(world.map_data.campfire_cell, 2.0, 3.0)
	controller._on_tapped(_to_screen(villager.position + Villager.PICK_CENTER))
	controller._on_tapped(_to_screen(WorldGrid.cell_to_world(ground)))
	check(villager.job == null, "Chạm mặt đất trống → bỏ việc")
	check_eq(villager.anchor_cell, ground, "Chạm mặt đất trống → đặt điểm neo mới")
	check(villager.task != null and villager.task.kind == &"goto", "Đi tới chỗ mới")

	controller._on_drag_started(Vector2.ZERO, villager)
	controller._on_drag_ended(_to_screen(tree.position + Vector2(0, -40)))
	check(villager.job != null and villager.job.skill == SkillDefs.CHOP, "Kéo thổ dân thả vào cây → giao chặt cây")
	controller.queue_free()
	await _free_world(world)
	check(not InputRouter.drag_picker.is_valid(), "Bỏ controller thì trả lại drag_picker")


func test_hud_resources_and_speed() -> void:
	var hud: Control = HUD_SCENE.instantiate()
	host.add_child(hud)
	await host.get_tree().process_frame
	GameState.add_resource(ResourceDefs.WOOD, 1250)
	check_eq(hud.call("get_amount_text", ResourceDefs.WOOD), Loc.number(GameState.get_amount(ResourceDefs.WOOD)), "Thanh tài nguyên hiện đúng số gỗ trong kho")
	Commands.set_game_speed(3)
	check_eq(GameState.speed, 3, "Tốc độ ×3")
	Commands.toggle_pause()
	check_eq(GameState.speed, 0, "Space tạm dừng")
	Commands.toggle_pause()
	check_eq(GameState.speed, 3, "Space lần nữa chạy lại đúng tốc độ cũ")
	Commands.set_game_speed(1)
	hud.queue_free()
	await host.get_tree().process_frame


# --- Hỗ trợ ---

func _make_world(seed_value: int) -> World:
	GameState.new_game(NORMAL_MODE)
	var world: World = WORLD_SCENE.instantiate()
	host.add_child(world)
	world.build(seed_value)
	await host.get_tree().process_frame
	return world


func _free_world(world: World) -> void:
	Engine.time_scale = 1.0
	world.queue_free()
	await host.get_tree().process_frame


# Người lớn đứng quanh lửa trại (không cần hoạt cảnh chui ra khỏi hang).
func _spawn(world: World, count: int) -> Array[Villager]:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 1234
	var result: Array[Villager] = []
	while result.size() < count:
		var gender: VillagerData.Gender = VillagerData.Gender.MALE if result.size() % 2 == 0 else VillagerData.Gender.FEMALE
		var cell: Vector2i = world.finder.find_free_cell_near(world.map_data.campfire_cell, 1.5, 3.5)
		if cell == World.INVALID_CELL:
			continue
		var villager_id: int = Commands.spawn_villager(VillagerFactory.create(rng, gender, "vi"), cell)
		var villager: Villager = Commands.get_villager(villager_id)
		if villager != null:
			result.append(villager)
	return result


func _fill_needs(villager: Villager) -> void:
	villager.status.hunger = 100.0
	villager.status.energy = 100.0
	villager.status.fun = 100.0


func _nearest(world: World, kind: StringName) -> ResourceNode:
	var campfire: Vector2 = WorldGrid.cell_to_world(world.map_data.campfire_cell)
	var best: ResourceNode = null
	for node: ResourceNode in world.resource_nodes:
		if node.kind == kind and node.can_harvest():
			if best == null or node.position.distance_to(campfire) < best.position.distance_to(campfire):
				best = node
	return best


func _campfire(world: World) -> Building:
	for building: Building in world.buildings:
		if building.building_id == &"campfire":
			return building
	return null


func _to_screen(world_point: Vector2) -> Vector2:
	return host.get_viewport().get_canvas_transform() * world_point


## Tua nhanh `seconds` giây game. `until` (tuỳ chọn) trả true thì dừng sớm.
func _simulate(seconds: float, until: Callable = Callable()) -> void:
	var elapsed: float = 0.0
	Engine.time_scale = SIM_TIME_SCALE
	while elapsed < seconds:
		await host.get_tree().process_frame
		elapsed += host.get_process_delta_time()
		if until.is_valid() and until.call(elapsed):
			break
	Engine.time_scale = 1.0
