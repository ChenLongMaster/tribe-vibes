extends Node
## Chụp màn hình game ở vài góc để xem nhanh hình ảnh mà không cần ngồi bấm.
## Cần cửa sổ thật (không chạy được với --headless):
##   godot --path . res://tools/screenshot.tscn -- --out=C:/thu_muc --seed=42 --lang=en
## Tuỳ chọn thêm:
##   --wait=20    chờ 20 giây game trước khi chụp (để làng kịp sinh hoạt)
##   --speed=4    tua nhanh lúc chờ
##   --select     chọn thổ dân đầu tiên để chụp cả bảng thông tin
##   --jobs       ra khỏi hang xong thì cấp đồ nghề (như phím F10) rồi giao việc: chặt cây,
##                câu cá, nhặt đá cuội, hái quả — để chụp cảnh lao động; chụp thêm work.png
##                quanh người đầu tiên
##   --hungry     ra khỏi hang xong thì dọn sạch bếp, cho cả làng đói (người đầu đói lả) để
##                chụp cảnh ngồi dỗi + bong bóng nghĩ + giơ biển; chụp thêm hungry.png
##   --buildings  dựng sẵn lều cấp 1/2/3, lò rèn bày đồ, bếp, kho, sân nhảy, một móng bếp có thợ
##                xây đang khuân/gõ; chụp thêm buildings.png, levels.png, forge.png, construction.png
##   --ui         (cùng --buildings) chụp bảng công trình (lò rèn, móng), bảng thông tin vật thể
##                (bụi, cây, đá), menu xây, bóng mờ khi đặt nhà: panel_forge.png, panel_site.png,
##                panel_bush.png, panel_tree.png, panel_rock.png, build_menu.png, placing.png
##   --times      chụp làng lúc sáng / trưa / hoàng hôn / đêm: morning.png, day.png, sunset.png, night.png

const MAIN_SCENE: PackedScene = preload("res://main.tscn")
const SETTLE_FRAMES: int = 30


func _ready() -> void:
	var out_dir: String = OS.get_user_data_dir()
	var wait_seconds: float = 0.0
	var speed: float = 1.0
	var select_first: bool = false
	var give_jobs: bool = false
	var make_hungry: bool = false
	var with_buildings: bool = false
	var with_times: bool = false
	var with_ui: bool = false
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out_dir = arg.trim_prefix("--out=")
		elif arg.begins_with("--lang="):
			# Không lưu vào setting để không đổi ngôn ngữ của người chơi.
			Loc.set_language(arg.trim_prefix("--lang="), false)
		elif arg.begins_with("--wait="):
			wait_seconds = arg.trim_prefix("--wait=").to_float()
		elif arg.begins_with("--speed="):
			speed = arg.trim_prefix("--speed=").to_float()
		elif arg == "--select":
			select_first = true
		elif arg == "--jobs":
			give_jobs = true
		elif arg == "--hungry":
			make_hungry = true
		elif arg == "--buildings":
			with_buildings = true
		elif arg == "--times":
			with_times = true
		elif arg == "--ui":
			with_ui = true
	var main: Node = MAIN_SCENE.instantiate()
	add_child(main)
	var world: World = main.get_node("World")
	var camera: CameraController = world.get_camera()
	var village: Vector2 = camera.position

	Engine.time_scale = speed
	if give_jobs or make_hungry or with_buildings:
		while world.villagers.size() < Balance.START_VILLAGERS or _anyone_emerging(world):
			await get_tree().process_frame
	if give_jobs:
		_give_jobs(world)
	if make_hungry:
		_make_hungry(world)
	var site: Building = null
	var spots: Dictionary = {}
	if with_buildings:
		site = _build_village(world, spots)
	var waited: float = 0.0
	while waited < wait_seconds:
		await get_tree().process_frame
		waited += get_process_delta_time()
	Engine.time_scale = 1.0
	if select_first and not world.villagers.is_empty():
		(main.get_controller() as NormalController).select(world.villagers[0])

	# Zoom nhỏ hơn mức tối thiểu sẽ bị camera kẹp lại.
	await _shot(camera, village, 1.0, out_dir.path_join("village_zoom_1.png"))
	await _shot(camera, village, 0.1, out_dir.path_join("overview.png"))
	await _shot(camera, village + Vector2(0, 60), 2.0, out_dir.path_join("close_zoom_2.png"))
	await _shot(camera, _lake_center(world.map_data), 1.0, out_dir.path_join("lake.png"))
	if give_jobs and not world.villagers.is_empty():
		await _shot(camera, world.villagers[0].position, 1.4, out_dir.path_join("work.png"))
	if make_hungry and not world.villagers.is_empty():
		await _shot(camera, world.villagers[0].position, 1.8, out_dir.path_join("hungry.png"))
		if world.villagers.size() >= 4:
			await _shot(camera, world.villagers[2].position + Vector2(0, -30), 2.0, out_dir.path_join("sign_planted.png"))
			await _shot(camera, world.villagers[3].position + Vector2(0, -40), 2.0, out_dir.path_join("carcass.png"))
	if with_buildings:
		await _shot(camera, village + Vector2(0, 40), 0.55, out_dir.path_join("buildings.png"))
		if spots.has("tents"):
			await _shot(camera, spots["tents"], 0.9, out_dir.path_join("levels.png"))
		if spots.has("forge"):
			await _shot(camera, spots["forge"], 1.6, out_dir.path_join("forge.png"))
		if site != null:
			await _shot(camera, site.position + Vector2(0, -40), 1.5, out_dir.path_join("construction.png"))
	if with_buildings and with_ui:
		var controller: NormalController = main.get_controller() as NormalController
		if spots.has("forge_building"):
			controller.select_building(spots["forge_building"])
			await _shot(camera, (spots["forge_building"] as Building).position + Vector2(-220, -60), 1.2, out_dir.path_join("panel_forge.png"))
		if site != null:
			controller.select_building(site)
			await _shot(camera, site.position + Vector2(-220, -60), 1.2, out_dir.path_join("panel_site.png"))
		controller.deselect()
		for entry: Array in [[MapData.KIND_BUSH, "panel_bush.png"], [MapData.KIND_TREE, "panel_tree.png"], [MapData.KIND_ROCK, "panel_rock.png"]]:
			var node: ResourceNode = _nearest_node(world, entry[0])
			if node != null:
				controller.select_object(node)
				await _shot(camera, node.position + Vector2(-220, -60), 1.2, out_dir.path_join(entry[1]))
		controller.deselect()
		(main.get_hud().call("get_build_menu") as BuildMenu).visible = true
		await _shot(camera, village, 1.0, out_dir.path_join("build_menu.png"))
		(main.get_hud().call("get_build_menu") as BuildMenu).visible = false
		controller.begin_placement(BuildingDefs.STORAGE)
		await _shot(camera, village + Vector2(0, 60), 1.0, out_dir.path_join("placing.png"))
		controller.cancel_placement()
	if with_times:
		for entry: Array in [[0.2, "morning.png"], [0.5, "day.png"], [0.84, "sunset.png"], [0.97, "night.png"]]:
			GameState.time_of_day = entry[0]
			await _shot(camera, village + Vector2(0, 40), 0.7, out_dir.path_join(entry[1]))
	get_tree().quit()


# Dựng sẵn một làng có đủ công trình để soi hình (đi qua placer như người chơi đặt móng,
# rồi cho xây xong luôn). Trả về móng bếp đang có thợ xây.
func _build_village(world: World, spots: Dictionary) -> Building:
	GameState.set_capacity(ResourceDefs.WOOD, 500)
	GameState.set_capacity(ResourceDefs.STONE, 500)
	GameState.add_resource(ResourceDefs.WOOD, 200)
	GameState.add_resource(ResourceDefs.STONE, 120)
	var tents: Array[Building] = []
	for level: int in [1, 2, 3]:
		var tent: Building = _place(world, BuildingDefs.TENT, level)
		if tent != null:
			tents.append(tent)
	if not tents.is_empty():
		spots["tents"] = tents[1 if tents.size() > 1 else 0].position + Vector2(0, -40)
	var forge: Building = _place(world, BuildingDefs.FORGE, 2)
	if forge != null:
		forge.add_stock(ToolDefs.AXE, 2)
		forge.add_stock(ToolDefs.PICKAXE, 3)
		forge.add_stock(ToolDefs.SPEAR, 2)
		spots["forge"] = forge.position + Vector2(0, -40)
		spots["forge_building"] = forge
		forge.set_order(ToolDefs.SPEAR, 2)
	var kitchen: Building = _place(world, BuildingDefs.KITCHEN, 1)
	if kitchen != null:
		kitchen.add_stock(ResourceDefs.MEAL, 4)
	_place(world, BuildingDefs.STORAGE, 1)
	_place(world, BuildingDefs.DANCE_FLOOR, 2)
	var site: Building = _place(world, BuildingDefs.KITCHEN, 0)
	if site != null:
		for i: int in mini(2, world.villagers.size()):
			Commands.assign_job(world.villagers[i].id, site)
	return site


func _place(world: World, building_id: StringName, level: int) -> Building:
	var center: Vector2i = world.map_data.campfire_cell
	for radius: int in range(3, 16):
		for y: int in range(-radius, radius + 1):
			for x: int in range(-radius, radius + 1):
				var origin: Vector2i = center + Vector2i(x, y)
				if world.placer.can_place(building_id, origin):
					var building: Building = world.placer.place(building_id, origin, level)
					world.refresh_storage_capacity()
					world.day_night.refresh_glows()
					return building
	return null


func _shot(camera: CameraController, focus: Vector2, zoom_level: float, path: String) -> void:
	camera.position = focus
	camera._on_zoom_requested(zoom_level / camera.zoom.x, get_viewport().get_visible_rect().size * 0.5)
	for i: int in SETTLE_FRAMES:
		await get_tree().process_frame
	get_viewport().get_texture().get_image().save_png(path)
	print("Đã lưu ", path)


func _anyone_emerging(world: World) -> bool:
	for villager: Villager in world.villagers:
		if villager.task != null and villager.task.kind == &"emerge":
			return true
	return false


# Giao việc qua Commands như người chơi: chặt cây, câu cá, nhặt đá cuội, hái quả (gần lửa trại nhất).
func _give_jobs(world: World) -> void:
	Commands.debug_give_tools()
	var kinds: Array[StringName] = [MapData.KIND_TREE, MapData.KIND_FISH_SPOT, MapData.KIND_PEBBLES, MapData.KIND_BUSH]
	var campfire: Vector2 = WorldGrid.cell_to_world(world.map_data.campfire_cell)
	for i: int in mini(kinds.size(), world.villagers.size()):
		var best: ResourceNode = null
		for node: ResourceNode in world.resource_nodes:
			if node.kind == kinds[i] and node.visible and node.can_harvest():
				if best == null or node.position.distance_to(campfire) < best.position.distance_to(campfire):
					best = node
		if best != null:
			Commands.assign_job(world.villagers[i].id, best)


# Người 1 đói lả (ngồi giơ biển), người 2 ngồi dỗi; người 3 đứng cắm biển "thiếu rìu",
# người 4 vác xác thú — để soi hình biển cắm đất / giơ tay và cảnh vác thú.
func _make_hungry(world: World) -> void:
	GameState.take_resource(ResourceDefs.FOOD, GameState.get_amount(ResourceDefs.FOOD))
	for i: int in world.villagers.size():
		var villager: Villager = world.villagers[i]
		villager.status.energy = 90.0
		villager.status.hunger = [0.0, 30.0, 100.0, 100.0][mini(i, 3)]
		if i == 2:
			villager.start_task(TaskWait.new(Balance.DAY_LENGTH_SECONDS))
			villager.hold_sign(ToolDefs.icon(ToolDefs.AXE), false, Villager.UNTIL_CLEARED)
		elif i == 3:
			villager.rig.set_carry_item("animals/boar", true)


func _lake_center(data: MapData) -> Vector2:
	var total: Vector2 = Vector2.ZERO
	var count: int = 0
	for y: int in data.size.y:
		for x: int in data.size.x:
			if data.is_water(Vector2i(x, y)):
				total += WorldGrid.cell_to_world(Vector2i(x, y))
				count += 1
	return total / maxi(count, 1)


func _nearest_node(world: World, kind: StringName) -> ResourceNode:
	var campfire: Vector2 = WorldGrid.cell_to_world(world.map_data.campfire_cell)
	var best: ResourceNode = null
	for node: ResourceNode in world.resource_nodes:
		if node.kind == kind and node.visible and node.can_harvest():
			if best == null or node.position.distance_to(campfire) < best.position.distance_to(campfire):
				best = node
	return best
