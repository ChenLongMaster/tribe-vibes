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
	for job_id: StringName in JobDefs.DEFS:
		var def: Dictionary = JobDefs.get_def(job_id)
		var key: String = def["activity_key"]
		check(Loc.t(key) != key, "Thiếu chữ '%s' cho việc %s" % [key, job_id])
		check(SkillDefs.DEFS.has(JobDefs.skill_of(job_id)), "Việc %s phải gắn một kỹ năng" % job_id)
		var held: String = JobDefs.held_art(job_id)
		check(held.is_empty() or ArtLibrary.has_texture(held), "Thiếu hình đồ cầm tay %s" % job_id)
		check(ArtLibrary.has_texture(JobDefs.icon(job_id)), "Thiếu icon việc %s" % job_id)
		if def.has("item"):
			check(ResourceDefs.ITEMS.has(def["item"]), "Việc %s ra món lạ" % job_id)
	for item: StringName in ResourceDefs.ITEMS:
		check(ArtLibrary.has_texture(ResourceDefs.item_carry_art(item)), "Thiếu hình khuân %s" % item)
		check(ArtLibrary.has_texture(ResourceDefs.item_eat_art(item)), "Thiếu hình ăn %s" % item)
		var noun: String = ResourceDefs.item_noun_key(item)
		check(Loc.t(noun) != noun, "Thiếu tên món %s" % item)
	for tool: StringName in ToolDefs.ORDER:
		check(ArtLibrary.has_texture(ToolDefs.icon(tool)), "Thiếu hình đồ nghề %s" % tool)
	for resource_id: StringName in ResourceDefs.ORDER:
		check(ArtLibrary.has_texture(ResourceDefs.icon(resource_id)), "Thiếu icon tài nguyên %s" % resource_id)
		check(Loc.t(ResourceDefs.name_key(resource_id)) != ResourceDefs.name_key(resource_id), "Thiếu tên %s" % resource_id)
		check(Loc.t(ResourceDefs.noun_key(resource_id)) != ResourceDefs.noun_key(resource_id), "Thiếu tên viết thường %s" % resource_id)
		check(not Loc.plural(ResourceDefs.count_key(resource_id), 3).contains("RES_"), "Thiếu số nhiều %s" % resource_id)
	for key: String in ["animals/boar", "animals/deer", "icons/angry", "fx/dust", "ui/target_ring", "ui/move_marker",
			"props/sign", "ui/thought_bubble", "icons/cross", "icons/question", "icons/dots",
			"env/twigs", "env/pebbles", "env/cliff", "icons/res_meal",
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
	# Hang đá chỉ chứa 30 gỗ / 30 đá — có sẵn một Kho cấp 3 để đo sản lượng 5 phút.
	check(_add_built(world, BuildingDefs.STORAGE, 3, 7) != null, "Có chỗ dựng Kho")
	Commands.debug_give_tools(3)
	var tree: ResourceNode = _nearest(world, MapData.KIND_TREE)
	var rock: ResourceNode = _nearest_rock(world, false)
	for i: int in 3:
		check(Commands.assign_job(villagers[i].id, tree), "Giao chặt cây cho người %d" % i)
	for i: int in range(3, 5):
		check(Commands.assign_job(villagers[i].id, rock), "Giao đập đá cho người %d" % i)
	var idler: Villager = villagers[5]
	var idle_anchor: Vector2i = idler.anchor_cell
	Villager.watchdog_alerts = 0

	var samples: Array[Vector2i] = []
	var quits: Array[String] = []
	var last_jobs: Dictionary[int, String] = {}
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
		for i: int in villagers.size():
			var villager: Villager = villagers[i]
			if villager.task != null:
				kinds[villager.task.kind] = true
			if villager.job != null:
				last_jobs[i] = "%s, cầm %s, %d lần không tới được" % [villager.job.job_id, villager.tool, villager.job._failures]
			elif i < 5 and not quits.any(func(entry: String) -> bool: return entry.begins_with(villager.data.display_name)):
				quits.append("%s ở giây %.0f — việc %s" % [villager.data.display_name, elapsed, last_jobs.get(i, "?")])
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
		check(villager.job != null, "%s bỏ việc giữa chừng (%s)" % [villager.data.display_name, ", ".join(quits)])
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
	Commands.debug_give_tools(1)
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
	var berries_before: int = GameState.item_amount(ResourceDefs.FOOD, ResourceDefs.ITEM_BERRIES)
	Commands.assign_job(worker.id, bush)
	await _simulate(90.0, func(_elapsed: float) -> bool: return worker.job == null)
	check(worker.job == null, "Hết bụi quả thì thôi việc")
	await host.get_tree().process_frame
	check(worker.rig.has_sign(), "Thôi việc vì hết quả thì phải giơ biển (quả gạch chéo)")
	check(GameState.item_amount(ResourceDefs.FOOD, ResourceDefs.ITEM_BERRIES) > berries_before, "Quả hái được vào kho thức ăn (nhớ là quả)")
	check_eq(worker.anchor_cell, world.cell_of(worker), "Dừng việc thì đứng chờ tại chỗ")
	await _free_world(world)


func test_strike_and_resume() -> void:
	var world: World = await _make_world(5)
	var worker: Villager = _spawn(world, 1)[0]
	_fill_needs(worker)
	var toasts: Array[String] = []
	var on_event: Callable = func(key: String, _args: Dictionary, _icon: String) -> void: toasts.append(key)
	EventBus.village_event.connect(on_event)
	Commands.debug_give_tools(1)
	Commands.assign_job(worker.id, _nearest_rock(world, false))
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
	await _simulate(30.0, func(_elapsed: float) -> bool: return worker.task is TaskWork)
	check(not worker.on_strike, "Giải trí hồi đủ thì hết đình công")
	check_eq(worker.tool, ToolDefs.AXE, "Đổi cuốc lấy rìu để chặt cây")
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
	Commands.debug_give_tools(1)
	var campfire: Building = _campfire(world)
	var meals_before: int = campfire.stock_of(ResourceDefs.MEAL)
	var delivered: Array[StringName] = []
	var state: Dictionary = {"carcass": false}
	var on_delivered: Callable = func(resource_id: StringName, _amount: int, _pos: Vector2) -> void: delivered.append(resource_id)
	EventBus.resource_delivered.connect(on_delivered)
	var animal: Animal = world.animals[0]
	check(Commands.assign_job(hunter.id, animal), "Giao đi săn")
	check(Commands.assign_job(cook.id, campfire), "Giao nấu ăn ở lửa trại")
	check_eq(cook.job.skill, SkillDefs.COOK, "Chạm lửa trại = nấu ăn")
	await _simulate(240.0, func(_elapsed: float) -> bool:
		if hunter.rig.is_carrying() and hunter.task is TaskHunt:
			state["carcass"] = true
		return delivered.has(ResourceDefs.FOOD) and campfire.stock_of(ResourceDefs.MEAL) > meals_before)
	check_eq(hunter.tool, ToolDefs.SPEAR, "Thợ săn lấy giáo")
	check(state["carcass"], "Săn xong vác nguyên con thú về")
	check(delivered.has(ResourceDefs.FOOD), "Thợ săn mang thức ăn về")
	check(campfire.stock_of(ResourceDefs.MEAL) > meals_before, "Đầu bếp nấu ra món chín, cất ở lửa trại")
	check(GameState.get_amount(ResourceDefs.MEAL) == 0, "Món chín không phải tài nguyên chung")
	check(hunter.job != null and hunter.job.skill == SkillDefs.HUNT, "Thợ săn vẫn đi săn tiếp")
	EventBus.resource_delivered.disconnect(on_delivered)
	await _free_world(world)


func test_fishing() -> void:
	var world: World = await _make_world(42)
	var fisher: Villager = _spawn(world, 1)[0]
	_fill_needs(fisher)
	var fish_before: int = GameState.item_amount(ResourceDefs.FOOD, ResourceDefs.ITEM_FISH)
	check(Commands.assign_job(fisher.id, _nearest(world, MapData.KIND_FISH_SPOT)), "Giao câu cá (không cần đồ nghề rèn)")
	await _simulate(120.0, func(_elapsed: float) -> bool:
		return GameState.item_amount(ResourceDefs.FOOD, ResourceDefs.ITEM_FISH) > fish_before)
	check(GameState.item_amount(ResourceDefs.FOOD, ResourceDefs.ITEM_FISH) > fish_before, "Câu được cá về kho thức ăn")
	await _free_world(world)


func test_hungry_sulks_then_eats_at_kitchen() -> void:
	var world: World = await _make_world(42)
	var villager: Villager = _spawn(world, 1)[0]
	_fill_needs(villager)
	GameState.take_resource(ResourceDefs.FOOD, GameState.get_amount(ResourceDefs.FOOD))
	villager.status.hunger = 40.0
	villager.status.energy = 70.0
	await _simulate(3.0, func(_elapsed: float) -> bool: return villager.task is TaskSulk)
	check(villager.task is TaskSulk, "Đói mà bếp hết đồ thì ngồi dỗi")
	villager.status.hunger = 0.0
	await _simulate(2.0, func(_elapsed: float) -> bool: return villager.rig.has_sign())
	check(villager.rig.has_sign(), "Đói lả thì giơ biển vẽ đồ ăn")

	GameState.add_resource(ResourceDefs.FOOD, 1, ResourceDefs.ITEM_FISH)
	villager.status.health = 100.0
	var energy_before: float = villager.status.energy
	var state: Dictionary = {"ate": false}
	await _simulate(30.0, func(_elapsed: float) -> bool:
		if villager.task != null and villager.task.kind == &"eat":
			state["ate"] = true
		return state["ate"] and (villager.task == null or villager.task.kind != &"eat"))
	check(state["ate"], "Bếp có đồ thì đứng dậy đi ăn")
	check(not villager.rig.has_sign(), "Đi ăn thì hạ biển")
	check(villager.status.hunger > 95.0, "Ăn ở bếp là no căng (đói = %.0f)" % villager.status.hunger)
	check(villager.status.energy > energy_before + Balance.EAT_ENERGY * 0.5, "Ăn xong đỡ mệt chút")
	check(villager.status.energy < energy_before + Balance.EAT_ENERGY * 1.5, "Nhưng không thay được giấc ngủ")
	await _free_world(world)


func test_worker_keeps_working_when_kitchen_empty() -> void:
	var world: World = await _make_world(42)
	var worker: Villager = _spawn(world, 1)[0]
	_fill_needs(worker)
	GameState.take_resource(ResourceDefs.FOOD, GameState.get_amount(ResourceDefs.FOOD))
	Commands.debug_give_tools(1)
	Commands.assign_job(worker.id, _nearest(world, MapData.KIND_TREE))
	worker.status.hunger = 40.0
	await _simulate(20.0)
	check(not (worker.task is TaskSulk), "Đang được giao việc thì làm tiếp, không ngồi dỗi")
	check(worker.job != null and worker.job.skill == SkillDefs.CHOP, "Vẫn nhớ việc chặt cây")
	await _free_world(world)


## Không có rìu / cuốc / giáo thì không chặt cây, đập đá tảng, săn được: giơ biển vẽ món
## thiếu. Có rồi thì tự đi lấy, giữ luôn; việc không cần đồ nghề thì đeo sau lưng.
func test_tools_needed_and_kept() -> void:
	var world: World = await _make_world(42)
	var worker: Villager = _spawn(world, 1)[0]
	_fill_needs(worker)
	var tree: ResourceNode = _nearest(world, MapData.KIND_TREE)
	check(not Commands.assign_job(worker.id, tree), "Chưa có rìu thì không giao chặt cây được")
	await host.get_tree().process_frame
	check(worker.rig.has_sign(), "Thiếu rìu thì giơ biển")
	check(not Commands.assign_job(worker.id, world.animals[0]), "Chưa có giáo thì không săn được")

	Commands.debug_give_tools(1)
	var rack: Building = _building(world, BuildingDefs.CAVE)
	check(Commands.assign_job(worker.id, tree), "Có rìu trong kho thì giao được")
	await _simulate(40.0, func(_elapsed: float) -> bool: return worker.tool == ToolDefs.AXE)
	check_eq(worker.tool, ToolDefs.AXE, "Tự đi lấy rìu")
	check_eq(rack.stock_of(ToolDefs.AXE), 0, "Rìu ra khỏi kho")

	# Nhặt đá cuội không cần đồ nghề: giữ rìu (đeo sau lưng), cầm xô.
	world.nature.spawn_pebble()
	var pebble: ResourceNode = _nearest(world, MapData.KIND_PEBBLES)
	check(pebble != null, "Có đá cuội trên map")
	if pebble != null:
		check(Commands.assign_job(worker.id, pebble), "Nhặt đá cuội bằng tay")
		await _simulate(40.0, func(_elapsed: float) -> bool: return worker.task is TaskHarvest)
		check_eq(worker.tool, ToolDefs.AXE, "Nhặt đá cuội vẫn giữ rìu")
		check_eq(rack.stock_of(ToolDefs.AXE), 0, "Không cất rìu khi làm việc tay không")

	# Sang việc cần món khác: về kho đổi rìu lấy cuốc.
	check(Commands.assign_job(worker.id, _nearest_rock(world, false)), "Giao đập đá tảng")
	await _simulate(60.0, func(_elapsed: float) -> bool: return worker.tool == ToolDefs.PICKAXE)
	check_eq(worker.tool, ToolDefs.PICKAXE, "Đổi lấy cuốc")
	check_eq(rack.stock_of(ToolDefs.AXE), 1, "Rìu được cất lại")
	await _free_world(world)


## Đá nhỏ nhặt bằng tay (không cần cuốc), đá tảng to thì vẫn cần cuốc. Biển "thiếu đồ nghề"
## chỉ vẽ món cần, không gạch chéo; biển "hết rồi" thì gạch chéo.
func test_small_rock_by_hand_and_sign_cross() -> void:
	var world: World = await _make_world(42)
	var worker: Villager = _spawn(world, 1)[0]
	_fill_needs(worker)
	var big: ResourceNode = _nearest_rock(world, false)
	var small: ResourceNode = _nearest_rock(world, true)
	check(big != null and small != null, "Map có cả đá to lẫn đá nhỏ")
	check_eq(JobDefs.job_for_target(big), JobDefs.MINE, "Đá to = đập đá (cần cuốc)")
	check_eq(JobDefs.job_for_target(small), JobDefs.PICK_ROCK, "Đá nhỏ = nhặt tay")
	check(not Commands.assign_job(worker.id, big), "Chưa có cuốc thì không đập được đá to")
	await host.get_tree().process_frame
	check(worker.rig.has_sign() and not worker.rig.is_sign_crossed(), "Thiếu cuốc: biển vẽ cuốc, không gạch chéo")
	var stone_before: int = GameState.get_amount(ResourceDefs.STONE)
	check(Commands.assign_job(worker.id, small), "Đá nhỏ giao được khi chưa có cuốc")
	check_eq(worker.job.skill, SkillDefs.GATHER, "Nhặt đá nhỏ luyện Hái lượm")
	await _simulate(60.0, func(_elapsed: float) -> bool: return GameState.get_amount(ResourceDefs.STONE) > stone_before)
	check(GameState.get_amount(ResourceDefs.STONE) > stone_before, "Nhặt đá nhỏ về kho")
	check_eq(worker.tool, &"", "Không cần cầm cuốc")
	# Nhặt hết đá nhỏ quanh đó thì thôi việc, giơ biển gạch chéo ("hết rồi").
	for node: ResourceNode in world.resource_nodes:
		if node.is_small_rock() and node != small:
			while node.can_harvest():
				node.harvest(1)
	await _simulate(90.0, func(_elapsed: float) -> bool: return worker.job == null)
	await host.get_tree().process_frame
	check(worker.job == null and worker.rig.has_sign() and worker.rig.is_sign_crossed(), "Hết đá nhỏ: biển gạch chéo")
	await _free_world(world)


## Củi và đá cuội nhặt tay theo mẻ: nhặt đủ một bó/xô rồi mới khuân về; 1 khúc gỗ = 10 củi.
func test_loose_pickup_and_nature() -> void:
	var world: World = await _make_world(42)
	var worker: Villager = _spawn(world, 1)[0]
	_fill_needs(worker)
	check(_count_active(world, MapData.KIND_TWIGS) > 0, "Có củi dưới tán cây lúc đầu")
	check(_count_active(world, MapData.KIND_PEBBLES) > 0, "Có đá cuội quanh đá tảng lúc đầu")
	check(not world.map_data.cliffs.is_empty(), "Có vách đá")
	var twig: ResourceNode = _nearest(world, MapData.KIND_TWIGS)
	var wood_before: int = GameState.get_amount(ResourceDefs.WOOD)
	var delivered: Array[int] = []
	var on_delivered: Callable = func(resource_id: StringName, amount: int, _pos: Vector2) -> void:
		if resource_id == ResourceDefs.WOOD:
			delivered.append(amount)
	EventBus.resource_delivered.connect(on_delivered)
	check(Commands.assign_job(worker.id, twig), "Nhặt củi bằng tay")
	await _simulate(90.0, func(_elapsed: float) -> bool: return not delivered.is_empty())
	EventBus.resource_delivered.disconnect(on_delivered)
	check(GameState.get_amount(ResourceDefs.WOOD) > wood_before, "Củi về kho thành gỗ")
	check(not delivered.is_empty() and delivered[0] > 1, "Nhặt đủ mẻ rồi mới khuân về: %s" % str(delivered))
	check_eq(ResourceDefs.item_value(ResourceDefs.ITEM_LOG, 1), 10, "1 khúc gỗ = 10 gỗ")

	# Thiên nhiên có giới hạn: không mọc quá số tối đa.
	for i: int in Balance.TWIG_MAX * 2:
		world.nature.spawn_twig()
	check(_count_active(world, MapData.KIND_TWIGS) <= Balance.TWIG_MAX, "Củi không mọc tràn map")
	var boulders: int = _count_active(world, MapData.KIND_ROCK)
	check(not world.nature.spawn_boulder(), "Đá tảng đủ số lúc đầu thì vách đá không lăn thêm")
	check_eq(_count_active(world, MapData.KIND_ROCK), boulders, "Số đá tảng giữ nguyên")
	await _free_world(world)


## Tấm biển: đứng thì cắm xuống đất (không lơ lửng), ngồi thì hai tay giơ lên.
func test_sign_planted_or_raised() -> void:
	var world: World = await _make_world(42)
	var villager: Villager = _spawn(world, 1)[0]
	_fill_needs(villager)
	# Đứng yên một chỗ để bộ não không chen hoạt cảnh rảnh rỗi vào giữa chừng.
	villager.start_task(TaskWait.new(100.0))
	villager.hold_sign("icons/res_food", true, Villager.UNTIL_CLEARED)
	villager.rig.play(VillagerRig.ANIM_IDLE)
	await host.get_tree().process_frame
	check(villager.rig.has_sign() and not villager.rig.is_sign_raised(), "Đứng thì cắm biển xuống đất")
	villager.rig.play(VillagerRig.ANIM_POUT)
	await host.get_tree().process_frame
	check(villager.rig.is_sign_raised(), "Ngồi thì giơ biển lên")
	villager.rig.play(VillagerRig.ANIM_WALK)
	await host.get_tree().process_frame
	check(not villager.rig.has_sign(), "Đi thì cất biển")
	await _free_world(world)


func test_controller_tap_assigns_and_moves() -> void:
	var world: World = await _make_world(42)
	var villager: Villager = _spawn(world, 1)[0]
	_fill_needs(villager)
	var controller: NormalController = NormalController.new()
	host.add_child(controller)
	controller.setup(world, NORMAL_MODE)
	await host.get_tree().process_frame
	Commands.debug_give_tools(1)
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


func _count_active(world: World, kind: StringName) -> int:
	var count: int = 0
	for node: ResourceNode in world.resource_nodes:
		if node.kind == kind and not node.is_cleared and not node.is_depleted():
			count += 1
	return count


func _fill_needs(villager: Villager) -> void:
	villager.status.hunger = 100.0
	villager.status.energy = 100.0
	villager.status.fun = 100.0


func _nearest(world: World, kind: StringName) -> ResourceNode:
	var campfire: Vector2 = WorldGrid.cell_to_world(world.map_data.campfire_cell)
	var best: ResourceNode = null
	for node: ResourceNode in world.resource_nodes:
		if node.kind == kind and node.visible and node.can_harvest():
			if best == null or node.position.distance_to(campfire) < best.position.distance_to(campfire):
				best = node
	return best


## Đá gần lửa trại nhất: `small` = đá nhỏ (nhặt tay), không thì đá tảng to (cần cuốc).
func _nearest_rock(world: World, small: bool) -> ResourceNode:
	var campfire: Vector2 = WorldGrid.cell_to_world(world.map_data.campfire_cell)
	var best: ResourceNode = null
	for node: ResourceNode in world.resource_nodes:
		if node.kind == MapData.KIND_ROCK and node.is_small_rock() == small and node.visible and node.can_harvest():
			if best == null or node.position.distance_to(campfire) < best.position.distance_to(campfire):
				best = node
	return best


func _campfire(world: World) -> Building:
	return _building(world, BuildingDefs.CAMPFIRE)


func _building(world: World, building_id: StringName) -> Building:
	for building: Building in world.buildings:
		if building.building_id == building_id:
			return building
	return null


## Dựng sẵn một công trình đã xây xong (cấp `level`) ở chỗ trống cách lửa trại ít nhất
## `min_radius` ô (để khỏi chắn đường dạo chơi của người đứng quanh lửa trại).
func _add_built(world: World, building_id: StringName, level: int, min_radius: int = 3) -> Building:
	var center: Vector2i = world.map_data.campfire_cell
	for radius: int in range(min_radius, 16):
		for y: int in range(-radius, radius + 1):
			for x: int in range(-radius, radius + 1):
				var origin: Vector2i = center + Vector2i(x, y)
				if world.placer.can_place(building_id, origin):
					var building: Building = world.placer.place(building_id, origin, level)
					world.refresh_storage_capacity()
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
