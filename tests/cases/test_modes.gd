extends TestCase
## Kiến trúc đa chế độ (MVP_PROMPT mục 3.2): khởi động nạp chế độ qua GameModeConfig,
## gắn đúng controller + HUD, và lệnh tạo thổ dân đi qua Commands.

const MAIN_SCENE: PackedScene = preload("res://main.tscn")
const NORMAL_MODE: GameModeConfig = preload("res://modes/normal_mode.tres")


func test_normal_mode_flags() -> void:
	check(NORMAL_MODE.allow_direct_commands, "Normal: được giao việc trực tiếp")
	check(NORMAL_MODE.goals_enabled, "Normal: có nhiệm vụ")
	check(NORMAL_MODE.raids_auto, "Normal: cannibal tự đến")
	check(NORMAL_MODE.can_lose, "Normal: có thể thua")
	check(not NORMAL_MODE.god_powers_enabled, "Normal: chưa có phép thần")
	check(not NORMAL_MODE.god_powers_unlimited, "Normal: phép thần không vô hạn")
	check(not NORMAL_MODE.character_creator_enabled, "Normal: không có trình tạo nhân vật")
	check(NORMAL_MODE.controller_scene != null and NORMAL_MODE.hud_scene != null, "Normal: có controller và HUD")


func test_boot_loads_mode() -> void:
	var main: Node = MAIN_SCENE.instantiate()
	host.add_child(main)
	await host.get_tree().process_frame
	check(GameState.mode == NORMAL_MODE, "GameState phải giữ chế độ đã nạp")
	check(main.call("get_controller") is NormalController, "Chế độ Normal phải gắn NormalController")
	var hud: Control = main.call("get_hud")
	check(hud != null and hud.get_parent() == main.get_node("UI"), "HUD của chế độ phải nằm trong lớp UI")

	# Tạo thổ dân qua API chung, đúng ô được yêu cầu.
	var world: World = main.get_node("World")
	var cell: Vector2i = world.finder.find_free_cell_near(world.map_data.campfire_cell, 2.0, 4.0)
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	var data: VillagerData = VillagerFactory.create(rng, VillagerData.Gender.FEMALE, "vi")
	var villager_id: int = Commands.spawn_villager(data, cell)
	check(villager_id != Commands.INVALID_ID, "Commands.spawn_villager phải trả mã số")
	var villager: Villager = Commands.get_villager(villager_id)
	check(villager != null and villager.data == data, "Lấy lại đúng thổ dân theo mã số")
	if villager != null:
		check_eq(world.cell_of(villager), cell, "Thổ dân xuất hiện đúng ô")
	var blocked: Vector2i = world.map_data.campfire_cell
	check_eq(Commands.spawn_villager(data, blocked), Commands.INVALID_ID, "Không tạo thổ dân trên ô bị chặn")

	main.queue_free()
	await host.get_tree().process_frame
