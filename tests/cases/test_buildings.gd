extends TestCase
## Đợt 3 — Xây dựng, công trình chức năng, ngày đêm, lưu game: đặt móng (luật chỗ đặt), thợ
## xây khuân vật liệu rồi mới xây, nâng cấp vẫn chạy cấp cũ, huỷ móng trả vật liệu, lều, bếp,
## kho (sức chứa), lò rèn (đơn rèn), cảnh báo thiếu người, ngày đêm + bóng đổ, lưu/tải.

const WORLD_SCENE: PackedScene = preload("res://world/world.tscn")
const NORMAL_MODE: GameModeConfig = preload("res://modes/normal_mode.tres")
const SIM_TIME_SCALE: float = 20.0
const TEST_SAVE_PATH: String = "user://test_save.json"
const OBJECT_PANEL: GDScript = preload("res://ui/common/object_panel.gd")


func test_building_defs_complete() -> void:
	for building_id: StringName in BuildingDefs.MENU_ORDER:
		check(BuildingDefs.is_buildable(building_id), "%s xây được" % building_id)
		check_eq(BuildingDefs.max_level(building_id), 3, "%s có 3 cấp" % building_id)
		for level: int in range(1, 4):
			check(ArtLibrary.has_texture(BuildingDefs.art(building_id, level)), "Thiếu hình %s cấp %d" % [building_id, level])
			check(not BuildingDefs.cost(building_id, level).is_empty(), "%s cấp %d phải tốn vật liệu" % [building_id, level])
		check(ArtLibrary.has_texture(BuildingDefs.foundation_art(building_id)), "Thiếu hình móng %s" % building_id)
		for key: String in [BuildingDefs.name_key(building_id), BuildingDefs.desc_key(building_id)]:
			check(Loc.t(key) != key, "Thiếu chữ %s" % key)
	for tool: StringName in ToolDefs.ORDER:
		check(Loc.t(ToolDefs.name_key(tool)) != ToolDefs.name_key(tool), "Thiếu tên đồ nghề %s" % tool)
		check(not ToolDefs.cost(tool).is_empty(), "Rèn %s phải tốn vật liệu" % tool)
	for key: String in ["villager/hard_hat", "icons/warning", "icons/storage", "icons/upgrade", "icons/check",
			"icons/save", "icons/load", "ui/sun", "ui/moon", "fx/confetti"]:
		check(ArtLibrary.has_texture(key), "Thiếu hình %s" % key)
	check_eq(BuildingDefs.max_builders(BuildingDefs.TENT), 2, "2×2 → tối đa 2 thợ")
	check_eq(BuildingDefs.max_builders(BuildingDefs.STORAGE), 4, "3×3 → tối đa 4 thợ")
	check_eq(BuildingDefs.max_builders(BuildingDefs.FORGE), 3, "3×2 → tối đa 3 thợ")


func test_place_rules() -> void:
	var world: World = await _make_world(42)
	var data: MapData = world.map_data
	check(not Commands.can_place_building(BuildingDefs.TENT, data.campfire_cell), "Không đè lên lửa trại")
	check(not Commands.can_place_building(BuildingDefs.TENT, data.cave_entrance_cell), "Không bịt cửa hang")
	var water: Vector2i = _first_water(data)
	check(not Commands.can_place_building(BuildingDefs.TENT, water), "Không đặt trên nước")
	check(not Commands.can_place_building(&"cave", data.campfire_cell + Vector2i(4, 0)), "Hang đá không xây được")
	var origin: Vector2i = _free_origin(world, BuildingDefs.TENT)
	check(origin != World.INVALID_CELL, "Có chỗ trống để đặt lều")
	world.nature.spawn_twig()
	var uid: int = Commands.place_building(BuildingDefs.TENT, origin)
	check(uid != Commands.INVALID_ID, "Đặt móng được")
	var tent: Building = Commands.get_building(uid)
	check(tent.is_foundation() and tent.is_constructing(), "Đặt xong là móng, chờ xây")
	check(world.grid.is_blocked(origin) and world.grid.is_blocked(origin + Vector2i(1, 1)), "Móng chặn ô")
	check(not Commands.can_place_building(BuildingDefs.TENT, origin + Vector2i(1, 0)), "Không đè lên móng khác")
	var floor_origin: Vector2i = _free_origin(world, BuildingDefs.DANCE_FLOOR)
	var dance: Building = Commands.get_building(Commands.place_building(BuildingDefs.DANCE_FLOOR, floor_origin))
	check(dance != null and not world.grid.is_blocked(floor_origin + Vector2i(1, 1)), "Sân nhảy đi lên được")
	check(world.building_at_cell(floor_origin + Vector2i(1, 1)) == dance, "Sân nhảy vẫn chiếm chỗ")
	await _free_world(world)


func test_builders_haul_then_build() -> void:
	var world: World = await _make_world(42)
	var builders: Array[Villager] = _spawn(world, 3)
	GameState.add_resource(ResourceDefs.WOOD, 30)
	var wood_before: int = GameState.get_amount(ResourceDefs.WOOD)
	var tent: Building = Commands.get_building(Commands.place_building(BuildingDefs.TENT, _free_origin(world, BuildingDefs.TENT)))
	check(Commands.assign_job(builders[0].id, tent), "Giao thợ xây thứ nhất")
	check(Commands.assign_job(builders[1].id, tent), "Giao thợ xây thứ hai")
	check(not Commands.assign_job(builders[2].id, tent), "Lều 2×2 chỉ cho 2 thợ")
	check(builders[0].rig.has_hard_hat(), "Thợ xây đội mũ công trường")
	var state: Dictionary = {"hauled": false, "built_before_materials": false}
	var completed: Array[int] = []
	var on_done: Callable = func(_building: Node, level: int) -> void: completed.append(level)
	EventBus.building_completed.connect(on_done)
	await _simulate(150.0, func(_elapsed: float) -> bool:
		if builders[0].rig.is_carrying():
			state["hauled"] = true
		if tent.build_progress() > 0.0 and not tent.materials_complete() and tent.is_constructing():
			state["built_before_materials"] = true
		return tent.is_built())
	EventBus.building_completed.disconnect(on_done)
	check(state["hauled"], "Thợ xây khuân vật liệu từ kho tới")
	check(not state["built_before_materials"], "Đủ vật liệu rồi mới bắt đầu xây")
	check(tent.is_built() and tent.level == 1, "Lều xây xong")
	check_eq(completed, [1] as Array[int], "Báo xây xong một lần")
	check_eq(GameState.get_amount(ResourceDefs.WOOD), wood_before - 20, "Tốn đúng 20 gỗ")
	await _simulate(5.0)
	check(builders[0].job == null, "Xây xong, không còn móng nào thì thôi việc")
	check(not builders[0].rig.has_hard_hat(), "Thôi xây thì bỏ mũ")
	check(not builders[0].rig.has_sign(), "Xây xong thì không giơ biển")
	await _free_world(world)


func test_builder_waits_for_materials() -> void:
	var world: World = await _make_world(42)
	var builder: Villager = _spawn(world, 1)[0]
	var tent: Building = Commands.get_building(Commands.place_building(BuildingDefs.TENT, _free_origin(world, BuildingDefs.TENT)))
	Commands.assign_job(builder.id, tent)
	await _simulate(20.0, func(_elapsed: float) -> bool: return builder.rig.has_sign())
	check(builder.rig.has_sign(), "Kho hết gỗ: thợ cắm biển gỗ gạch chéo")
	check(builder.job != null, "Vẫn giữ việc xây")
	GameState.add_resource(ResourceDefs.WOOD, 25)
	await _simulate(200.0, func(_elapsed: float) -> bool: return tent.is_built())
	check(tent.is_built(), "Có gỗ thì xây tiếp tới xong")
	await _free_world(world)


func test_cancel_foundation_refunds() -> void:
	var world: World = await _make_world(42)
	var origin: Vector2i = _free_origin(world, BuildingDefs.KITCHEN)
	var uid: int = Commands.place_building(BuildingDefs.KITCHEN, origin)
	var kitchen: Building = Commands.get_building(uid)
	kitchen.deliver_material(ResourceDefs.WOOD, 12)
	var wood_before: int = GameState.get_amount(ResourceDefs.WOOD)
	check(Commands.cancel_construction(uid), "Huỷ móng được")
	check_eq(GameState.get_amount(ResourceDefs.WOOD), wood_before + 12, "Vật liệu đã đổ được cất lại kho")
	check(not world.grid.is_blocked(origin), "Huỷ móng thì mở lại ô")
	check(Commands.get_building(uid) == null and not world.buildings.has(kitchen), "Móng biến mất")
	await _free_world(world)


func test_upgrade_keeps_old_level_working() -> void:
	var world: World = await _make_world(42)
	var villagers: Array[Villager] = _spawn(world, 2)
	var cook: Villager = villagers[0]
	var builder: Villager = villagers[1]
	var kitchen: Building = _add_built(world, BuildingDefs.KITCHEN, 1)
	check(Commands.assign_job(cook.id, kitchen), "Giao đầu bếp")
	GameState.add_resource(ResourceDefs.WOOD, 30)
	GameState.add_resource(ResourceDefs.STONE, 30)
	check(Commands.upgrade_building(kitchen.uid), "Nâng cấp bếp")
	# Hang đá chỉ chứa 30 gỗ mà nâng bếp cần 40: coi như đã khuân sẵn một phần.
	kitchen.deliver_material(ResourceDefs.WOOD, 15)
	check(kitchen.is_built() and kitchen.level == 1 and kitchen.is_constructing(), "Đang nâng cấp vẫn là bếp cấp 1")
	check(JobDefs.building_accepts_job(kitchen, JobDefs.COOK), "Đang nâng cấp vẫn nấu được")
	check(Commands.assign_job(builder.id, kitchen), "Chạm bếp đang nâng cấp = giao việc xây")
	await _simulate(240.0, func(_elapsed: float) -> bool: return kitchen.level == 2)
	check_eq(kitchen.level, 2, "Lên cấp 2")
	check_eq(kitchen.staff_capacity(), 2, "Cấp 2 có 2 đầu bếp")
	check(cook.job != null and cook.job.target == kitchen, "Đầu bếp vẫn ở bếp suốt lúc nâng cấp")
	check(not kitchen.can_upgrade() or kitchen.level < 3, "Còn nâng được lên cấp 3")
	await _free_world(world)


func test_tent_sleep() -> void:
	var world: World = await _make_world(42)
	var sleepers: Array[Villager] = _spawn(world, 3)
	var tent: Building = _add_built(world, BuildingDefs.TENT, 1)
	for villager: Villager in sleepers:
		villager.status.hunger = 100.0
		villager.status.fun = 100.0
		villager.status.energy = 40.0
	await _simulate(30.0, func(_elapsed: float) -> bool: return tent.sleepers.size() >= 2)
	check_eq(tent.sleepers.size(), 2, "Lều cấp 1 có 2 chỗ ngủ")
	var inside: Array[Villager] = []
	for villager: Villager in sleepers:
		if villager.inside == tent:
			inside.append(villager)
	check_eq(inside.size(), 2, "Hai người chui vào lều")
	check(not inside.is_empty() and not inside[0].visible, "Ngủ trong lều thì ẩn đi")
	check(not inside.is_empty() and is_equal_approx(inside[0].sleep_rate_multiplier, 1.5), "Lều cấp 1 hồi sức ×1.5")
	var outside: Villager = null
	for villager: Villager in sleepers:
		if not inside.has(villager):
			outside = villager
	check(outside != null and outside.task is TaskSleep and outside.inside == null, "Hết chỗ thì ngủ đất")
	await _simulate(120.0, func(_elapsed: float) -> bool: return tent.sleepers.is_empty())
	check(tent.sleepers.is_empty(), "Ngủ đủ thì ra khỏi lều")
	check(not inside.is_empty() and inside[0].visible, "Ra khỏi lều thì hiện lại")
	await _free_world(world)


func test_kitchen_cooks_and_villagers_eat_there() -> void:
	var world: World = await _make_world(42)
	var villagers: Array[Villager] = _spawn(world, 2)
	var cook: Villager = villagers[0]
	var eater: Villager = villagers[1]
	_fill_needs(cook)
	_fill_needs(eater)
	var kitchen: Building = _add_built(world, BuildingDefs.KITCHEN, 1)
	check(kitchen.needs_staff(), "Bếp không ai phụ trách thì cần người (ngừng)")
	check(GameState.capacity(ResourceDefs.FOOD) > Balance.CAVE_FOOD_CAPACITY, "Bếp cất thêm thức ăn")
	check(Commands.assign_job(cook.id, kitchen), "Giao đầu bếp")
	world.refresh_staff()
	check(not kitchen.needs_staff(), "Có đầu bếp thì hết cảnh báo")
	GameState.add_resource(ResourceDefs.FOOD, 5, ResourceDefs.ITEM_FISH)
	await _simulate(60.0, func(_elapsed: float) -> bool: return kitchen.stock_of(ResourceDefs.MEAL) >= 2)
	check(kitchen.stock_of(ResourceDefs.MEAL) >= 2, "Đầu bếp nấu món chín, cất ở bếp")
	eater.status.hunger = 30.0
	var meals: int = kitchen.stock_of(ResourceDefs.MEAL)
	await _simulate(40.0, func(_elapsed: float) -> bool: return eater.status.hunger > 90.0)
	check(eater.status.hunger > 90.0, "Đói thì đi ăn")
	check(kitchen.stock_of(ResourceDefs.MEAL) < meals + 2, "Ăn món chín ở bếp (không chỉ ăn đồ thô)")
	await _free_world(world)


func test_storage_capacity() -> void:
	var world: World = await _make_world(42)
	check_eq(GameState.capacity(ResourceDefs.WOOD), Balance.CAVE_WOOD_CAPACITY, "Lúc đầu chỉ có hang đá chứa gỗ")
	check_eq(GameState.capacity(ResourceDefs.FOOD), Balance.CAVE_FOOD_CAPACITY, "Hang đá chứa ít thức ăn")
	check_eq(GameState.add_resource(ResourceDefs.WOOD, 100), Balance.CAVE_WOOD_CAPACITY, "Đầy kho thì phần dư không vào")
	var worker: Villager = _spawn(world, 1)[0]
	_fill_needs(worker)
	world.nature.spawn_twig()
	var twig: ResourceNode = _nearest(world, MapData.KIND_TWIGS)
	Commands.assign_job(worker.id, twig)
	await _simulate(10.0, func(_elapsed: float) -> bool: return worker.job == null)
	check(worker.job == null, "Kho đầy thì thôi việc")
	await host.get_tree().process_frame
	check(worker.rig.has_sign(), "Kho đầy thì giơ biển vẽ cái kho")
	_add_built(world, BuildingDefs.STORAGE, 1)
	check_eq(GameState.capacity(ResourceDefs.WOOD), Balance.CAVE_WOOD_CAPACITY + 100, "Kho cấp 1 cộng thêm 100")
	await _free_world(world)


func test_forge_orders_then_tool_used() -> void:
	var world: World = await _make_world(42)
	var villagers: Array[Villager] = _spawn(world, 2)
	var smith: Villager = villagers[0]
	var chopper: Villager = villagers[1]
	_fill_needs(smith)
	_fill_needs(chopper)
	var forge: Building = _add_built(world, BuildingDefs.FORGE, 1)
	GameState.add_resource(ResourceDefs.WOOD, 20)
	GameState.add_resource(ResourceDefs.STONE, 20)
	check(Commands.set_forge_order(forge.uid, ToolDefs.AXE, 1), "Đặt rèn 1 rìu")
	check(Commands.assign_job(smith.id, forge), "Giao thợ rèn")
	check_eq(smith.job.job_id, JobDefs.SMITH, "Chạm lò rèn = rèn")
	await _simulate(90.0, func(_elapsed: float) -> bool: return forge.stock_of(ToolDefs.AXE) > 0)
	check_eq(forge.stock_of(ToolDefs.AXE), 1, "Rèn xong 1 rìu, dựng cạnh lò")
	check_eq(forge.order_count(ToolDefs.AXE), 0, "Hết đơn")
	check(Commands.assign_job(chopper.id, _nearest(world, MapData.KIND_TREE)), "Có rìu ở lò rèn thì giao chặt cây được")
	await _simulate(60.0, func(_elapsed: float) -> bool: return chopper.tool == ToolDefs.AXE)
	check_eq(chopper.tool, ToolDefs.AXE, "Tự tới lò rèn lấy rìu")
	check_eq(forge.stock_of(ToolDefs.AXE), 0, "Rìu ra khỏi lò")
	await _free_world(world)


func test_day_night_and_shadows() -> void:
	var world: World = await _make_world(42)
	var morning: Dictionary = DayNight.sun_state(Balance.SUNRISE + 0.08)
	var noon: Dictionary = DayNight.sun_state(0.5)
	var evening: Dictionary = DayNight.sun_state(Balance.SUNSET - 0.08)
	var night: Dictionary = DayNight.sun_state(0.02)
	check((morning["shadow_vec"] as Vector2).x < 0.0, "Sáng: bóng đổ về phía tây (trái)")
	check((evening["shadow_vec"] as Vector2).x > 0.0, "Chiều: bóng đổ về phía đông (phải)")
	check((noon["shadow_vec"] as Vector2).length() < (morning["shadow_vec"] as Vector2).length(), "Trưa bóng ngắn nhất")
	check(float(night["alpha"]) == 0.0 and float(noon["alpha"]) > 0.0, "Đêm không có bóng")
	var noon_color: Color = DayNight.light_color(0.5)
	var night_color: Color = DayNight.light_color(0.02)
	check(noon_color.v > 0.95 and night_color.v < noon_color.v and night_color.b > night_color.r, "Trưa sáng trắng, đêm xanh tím")
	check(not DayNight.light_color(0.3).is_equal_approx(DayNight.light_color(0.31)), "Ánh sáng đổi liên tục, không nhảy bậc")
	check(world.shadows.static_count() > 50, "Cây, đá, nhà có bóng")
	world.spawn_villager(VillagerFactory.create(RandomNumberGenerator.new(), VillagerData.Gender.MALE, "vi"),
			world.finder.find_free_cell_near(world.map_data.campfire_cell, 2.0, 3.0))
	check(world.shadows.dynamic_count() >= world.animals.size() + 1, "Thổ dân và thú có bóng")
	await _free_world(world)


func test_save_and_load_roundtrip() -> void:
	SaveSystem.save_path = TEST_SAVE_PATH
	var world: World = await _make_world(77)
	var villagers: Array[Villager] = _spawn(world, 2)
	Commands.debug_give_tools(1)
	GameState.add_resource(ResourceDefs.WOOD, 12)
	var tree: ResourceNode = _nearest(world, MapData.KIND_TREE)
	tree.harvest(1)
	Commands.assign_job(villagers[0].id, tree)
	villagers[1].set_tool(ToolDefs.SPEAR)
	var tent: Building = Commands.get_building(Commands.place_building(BuildingDefs.TENT, _free_origin(world, BuildingDefs.TENT)))
	tent.deliver_material(ResourceDefs.WOOD, 8)
	var forge: Building = _add_built(world, BuildingDefs.FORGE, 2)
	forge.set_order(ToolDefs.PICKAXE, 3)
	forge.add_stock(ToolDefs.SPEAR, 1)
	GameState.time_of_day = 0.6
	check(Commands.save_game(), "Lưu được")
	var tree_index: int = world.resource_nodes.find(tree)
	var tent_cell: Vector2i = tent.origin_cell
	var forge_cell: Vector2i = forge.origin_cell
	var wood: int = GameState.get_amount(ResourceDefs.WOOD)
	var ids: Array[int] = [villagers[0].id, villagers[1].id]
	await _free_world(world)

	var save: Dictionary = SaveSystem.read_save()
	check(not save.is_empty(), "Đọc lại được file save")
	GameState.new_game(NORMAL_MODE)
	GameState.apply_dict(save.get("game", {}))
	var loaded: World = WORLD_SCENE.instantiate()
	host.add_child(loaded)
	loaded.build(GameState.world_seed)
	SaveGame.restore(loaded, save)
	await host.get_tree().process_frame
	check_eq(GameState.world_seed, 77, "Đúng seed")
	check(absf(GameState.time_of_day - 0.6) < 0.01, "Đúng giờ trong ngày")
	check_eq(GameState.get_amount(ResourceDefs.WOOD), wood, "Đúng số gỗ trong kho")
	check_eq(loaded.resource_nodes[tree_index].uses_left, Balance.TREE_USES - 1, "Cây đã chặt bớt vẫn nhớ")
	var loaded_tent: Building = loaded.building_at_cell(tent_cell)
	check(loaded_tent != null and loaded_tent.is_foundation(), "Móng lều còn đó")
	if loaded_tent != null:
		check_eq(loaded_tent.delivered(ResourceDefs.WOOD), 8, "Nhớ vật liệu đã đổ vào móng")
	var loaded_forge: Building = loaded.building_at_cell(forge_cell)
	check(loaded_forge != null and loaded_forge.level == 2, "Lò rèn cấp 2")
	if loaded_forge != null:
		check_eq(loaded_forge.order_count(ToolDefs.PICKAXE), 3, "Nhớ đơn rèn")
		check_eq(loaded_forge.stock_of(ToolDefs.SPEAR), 1, "Nhớ đồ cất ở lò rèn")
	check_eq(loaded.villagers.size(), 2, "Đủ thổ dân")
	var first: Villager = loaded.get_villager(ids[0])
	var second: Villager = loaded.get_villager(ids[1])
	check(first != null and first.job != null and first.job.job_id == JobDefs.CHOP, "Nhớ việc được giao")
	check(second != null and second.tool == ToolDefs.SPEAR, "Nhớ đồ nghề đang giữ")
	check(GameState.next_villager_id() > maxi(ids[0], ids[1]), "Mã số mới không trùng người cũ")
	await _free_world(loaded)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE_PATH))
	SaveSystem.save_path = SaveSystem.SAVE_PATH


func test_controller_places_and_selects_building() -> void:
	var world: World = await _make_world(42)
	var controller: NormalController = NormalController.new()
	host.add_child(controller)
	controller.setup(world, NORMAL_MODE)
	await host.get_tree().process_frame
	var origin: Vector2i = _free_origin(world, BuildingDefs.TENT)
	var selected: Array[Node] = []
	var on_selected: Callable = func(building: Node) -> void: selected.append(building)
	EventBus.building_selected.connect(on_selected)
	controller.begin_placement(BuildingDefs.TENT)
	check_eq(controller.placing, BuildingDefs.TENT, "Vào chế độ đặt")
	# Ô gốc = ô dưới con trỏ lùi về trên-trái nửa diện tích (2×2 thì đúng ô trên-trái).
	InputRouter.mode = InputRouter.Mode.MOUSE
	controller._on_tapped(_to_screen(WorldGrid.cell_to_world(origin)))
	check_eq(controller.placing, &"", "Đặt xong thì thôi chế độ đặt")
	var tent: Building = world.building_at_cell(origin)
	check(tent != null and tent.is_foundation(), "Click là đặt móng ngay chỗ đó")
	check(not selected.is_empty() and selected[-1] == tent, "Đặt xong thì mở bảng công trình của móng")
	controller.deselect()
	controller._on_tapped(_to_screen(tent.position + Vector2(0, -20)))
	check(controller.selected_building == tent, "Không chọn ai mà chạm công trình thì chọn công trình")
	EventBus.building_selected.disconnect(on_selected)
	controller.queue_free()
	await _free_world(world)


## Không chọn ai mà chạm cây / bụi / đá / thú thì mở bảng thông tin vật đó; chạm lại thì đóng.
func test_tap_object_shows_info() -> void:
	var world: World = await _make_world(42)
	var controller: NormalController = NormalController.new()
	host.add_child(controller)
	controller.setup(world, NORMAL_MODE)
	var panel: Control = OBJECT_PANEL.new()
	host.add_child(panel)
	EventBus.world_ready.emit(world)
	await host.get_tree().process_frame
	var bush: ResourceNode = _nearest(world, MapData.KIND_BUSH)
	controller._on_tapped(_to_screen(bush.position + Vector2(0, -20)))
	check(controller.selected_object == bush, "Chạm bụi quả thì chọn bụi")
	await host.get_tree().process_frame
	check(panel.visible, "Bảng thông tin vật thể hiện ra")
	var texts: String = _all_text(panel)
	check(texts.contains(Loc.t("OBJECT_BUSH_NAME")), "Bảng có tên bụi quả: %s" % texts)
	check(texts.contains(Loc.t("UI_OBJECT_BY_HAND")), "Bảng nói hái bằng tay")
	var tree: ResourceNode = _nearest(world, MapData.KIND_TREE)
	controller._on_tapped(_to_screen(tree.position + Vector2(0, -90)))
	check(controller.selected_object == tree, "Chạm cây thì chuyển sang cây")
	await host.get_tree().process_frame
	texts = _all_text(panel)
	check(texts.contains(Loc.t("UI_OBJECT_TOOL_NONE")), "Cây: báo cần rìu mà làng chưa có")
	var animal: Animal = world.animals[0]
	controller.select_object(animal)
	await host.get_tree().process_frame
	check(_all_text(panel).contains(Loc.t("ANIMAL_DESC")), "Bảng thông tin thú")
	controller._on_tapped(_to_screen(animal.position + Vector2(0, -20)))
	await host.get_tree().process_frame
	check(controller.selected_object == null and not panel.visible, "Chạm lại thì đóng bảng")
	panel.queue_free()
	controller.queue_free()
	await _free_world(world)


func _all_text(node: Node) -> String:
	var out: String = ""
	if node is Label:
		out += (node as Label).text + " | "
	for child: Node in node.get_children():
		out += _all_text(child)
	return out


# --- Hỗ trợ ---

func _make_world(seed_value: int) -> World:
	GameState.new_game(NORMAL_MODE)
	GameState.world_seed = seed_value
	var world: World = WORLD_SCENE.instantiate()
	host.add_child(world)
	world.build(seed_value)
	await host.get_tree().process_frame
	return world


func _free_world(world: World) -> void:
	Engine.time_scale = 1.0
	world.queue_free()
	await host.get_tree().process_frame


func _spawn(world: World, count: int) -> Array[Villager]:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 4321
	var result: Array[Villager] = []
	while result.size() < count:
		var gender: VillagerData.Gender = VillagerData.Gender.MALE if result.size() % 2 == 0 else VillagerData.Gender.FEMALE
		var cell: Vector2i = world.finder.find_free_cell_near(world.map_data.campfire_cell, 1.5, 3.5)
		if cell == World.INVALID_CELL:
			continue
		var villager: Villager = Commands.get_villager(Commands.spawn_villager(VillagerFactory.create(rng, gender, "vi"), cell))
		if villager != null:
			_fill_needs(villager)
			result.append(villager)
	return result


func _fill_needs(villager: Villager) -> void:
	villager.status.hunger = 100.0
	villager.status.energy = 100.0
	villager.status.fun = 100.0


# Ô gốc trống gần làng (nhưng không sát lửa trại) đặt được công trình này.
func _free_origin(world: World, building_id: StringName) -> Vector2i:
	var center: Vector2i = world.map_data.campfire_cell
	for radius: int in range(3, 14):
		for y: int in range(-radius, radius + 1):
			for x: int in range(-radius, radius + 1):
				var origin: Vector2i = center + Vector2i(x, y)
				if world.placer.can_place(building_id, origin):
					return origin
	return World.INVALID_CELL


func _add_built(world: World, building_id: StringName, level: int) -> Building:
	var origin: Vector2i = _free_origin(world, building_id)
	if origin == World.INVALID_CELL:
		return null
	var building: Building = world.placer.place(building_id, origin, level)
	world.refresh_storage_capacity()
	world.day_night.refresh_glows()
	return building


func _first_water(data: MapData) -> Vector2i:
	for y: int in data.size.y:
		for x: int in data.size.x:
			if data.is_water(Vector2i(x, y)):
				return Vector2i(x, y)
	return Vector2i.ZERO


func _nearest(world: World, kind: StringName) -> ResourceNode:
	var campfire: Vector2 = WorldGrid.cell_to_world(world.map_data.campfire_cell)
	var best: ResourceNode = null
	for node: ResourceNode in world.resource_nodes:
		if node.kind == kind and node.visible and node.can_harvest():
			if best == null or node.position.distance_to(campfire) < best.position.distance_to(campfire):
				best = node
	return best


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
