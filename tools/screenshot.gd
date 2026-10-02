extends Node
## Chụp màn hình game ở vài góc để xem nhanh hình ảnh mà không cần ngồi bấm.
## Cần cửa sổ thật (không chạy được với --headless):
##   godot --path . res://tools/screenshot.tscn -- --out=C:/thu_muc --seed=42 --lang=en
## Tuỳ chọn thêm:
##   --wait=20    chờ 20 giây game trước khi chụp (để làng kịp sinh hoạt)
##   --speed=4    tua nhanh lúc chờ
##   --select     chọn thổ dân đầu tiên để chụp cả bảng thông tin
##   --jobs       ra khỏi hang xong thì giao việc (2 chặt cây, 1 đập đá, 1 hái quả) để chụp
##                cảnh lao động; chụp thêm work.png quanh người đầu tiên

const MAIN_SCENE: PackedScene = preload("res://main.tscn")
const SETTLE_FRAMES: int = 30


func _ready() -> void:
	var out_dir: String = OS.get_user_data_dir()
	var wait_seconds: float = 0.0
	var speed: float = 1.0
	var select_first: bool = false
	var give_jobs: bool = false
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
	var main: Node = MAIN_SCENE.instantiate()
	add_child(main)
	var world: World = main.get_node("World")
	var camera: CameraController = world.get_camera()
	var village: Vector2 = camera.position

	Engine.time_scale = speed
	if give_jobs:
		while world.villagers.size() < Balance.START_VILLAGERS or _anyone_emerging(world):
			await get_tree().process_frame
		_give_jobs(world)
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
	get_tree().quit()


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


# Giao việc qua Commands như người chơi: 2 chặt cây, 1 đập đá, 1 hái quả (gần lửa trại nhất).
func _give_jobs(world: World) -> void:
	var kinds: Array[StringName] = [MapData.KIND_TREE, MapData.KIND_TREE, MapData.KIND_ROCK, MapData.KIND_BUSH]
	var campfire: Vector2 = WorldGrid.cell_to_world(world.map_data.campfire_cell)
	for i: int in mini(kinds.size(), world.villagers.size()):
		var best: ResourceNode = null
		for node: ResourceNode in world.resource_nodes:
			if node.kind == kinds[i] and node.can_harvest():
				if best == null or node.position.distance_to(campfire) < best.position.distance_to(campfire):
					best = node
		if best != null:
			Commands.assign_job(world.villagers[i].id, best)


func _lake_center(data: MapData) -> Vector2:
	var total: Vector2 = Vector2.ZERO
	var count: int = 0
	for y: int in data.size.y:
		for x: int in data.size.x:
			if data.is_water(Vector2i(x, y)):
				total += WorldGrid.cell_to_world(Vector2i(x, y))
				count += 1
	return total / maxi(count, 1)
