extends TestCase
## Soát kho ảo DEV, kho thật/save và điều khiển bật/tắt ngay trong ván.

const NORMAL_MODE: GameModeConfig = preload("res://modes/normal_mode.tres")
const MAIN_SCENE: PackedScene = preload("res://main.tscn")


func test_dev_mode_virtual_resources_and_save() -> void:
	GameState.set_dev_mode(false)
	GameState.new_game(NORMAL_MODE)
	GameState.set_capacity(ResourceDefs.WOOD, 5)
	GameState.add_resource(ResourceDefs.WOOD, 3)
	var original: Dictionary = GameState.to_dict()
	Commands.toggle_dev_mode()
	check(GameState.is_dev_mode(), "Bật DEV qua Commands")
	for resource_id: StringName in ResourceDefs.ORDER:
		check(GameState.get_amount(resource_id) > 1000000, "Cả ba tài nguyên có sẵn khi kho thật trống")
		check(GameState.take_resource(resource_id, 2000000000), "Lấy lượng lớn không làm hết tài nguyên DEV")
	check_eq(GameState.take_one(ResourceDefs.FOOD), ResourceDefs.ITEM_BERRIES, "Ăn/nấu có món cụ thể để vẽ")
	check(not GameState.take_resource(ResourceDefs.WOOD, 0), "Không nhận yêu cầu lấy0")
	check(not GameState.take_resource(ResourceDefs.MEAL), "Món chín riêng không thành tài nguyên chung")
	check_eq(GameState.to_dict(), original, "Lượng ảo/cờ DEV không ghi vào save và không trừ kho thật")
	check_eq(GameState.add_resource(ResourceDefs.WOOD, 100), 2, "Nhặt vẫn cất vào kho thật theo sức chứa")
	GameState.apply_saved_resources(original)
	check(GameState.is_dev_mode(), "Load không đổi cờ của phiên chạy")
	Commands.toggle_dev_mode()
	check_eq(GameState.get_amount(ResourceDefs.WOOD), 3, "Tắt DEV thấy lại lượng thật đã load")
	check(not GameState.take_resource(ResourceDefs.WOOD, 4), "Normal vẫn thiếu tài nguyên")
	check(GameState.take_resource(ResourceDefs.WOOD, 2), "Normal lấy đúng lượng có")
	check_eq(GameState.get_amount(ResourceDefs.WOOD), 1, "Normal trừ tài nguyên như trước")
	GameState.new_game(NORMAL_MODE)


func test_dev_mode_hud_button_and_paused_shortcut() -> void:
	GameState.set_dev_mode(false)
	var language_connections: int = Loc.language_changed.get_connections().size()
	var main: Node = MAIN_SCENE.instantiate()
	host.add_child(main)
	await host.get_tree().process_frame
	var hud: Control = main.call("get_hud")
	var button: Button = hud.find_child("DevButton", true, false) as Button
	check(button != null and button.visible and not button.button_pressed, "Bản debug có nút DEV mặc định tắt")
	if button != null:
		button.pressed.emit()
		check(GameState.is_dev_mode() and button.button_pressed, "Nút bật DEV và cập nhật ngay")
		for resource_id: StringName in ResourceDefs.ORDER:
			check_eq(hud.call("get_amount_text", resource_id), Loc.t("UI_DEV_RESOURCE_AMOUNT"), "HUD hiện∞")
		check(not Loc.t("UI_DEV_RESOURCE_TOOLTIP", {"resource_key": ResourceDefs.name_key(ResourceDefs.WOOD)}).contains("{"), "Tooltip DEV thay tên tài nguyên đã dịch")
		Commands.set_game_speed(0)
		var event: InputEventKey = InputEventKey.new()
		event.physical_keycode = KEY_F8
		event.pressed = true
		Input.parse_input_event(event)
		await host.get_tree().process_frame
		check(not GameState.is_dev_mode() and not button.button_pressed, "F8 vẫn tắt được DEV khi tạm dừng")
		check_eq(hud.call("get_amount_text", ResourceDefs.WOOD), Loc.number(GameState.get_amount(ResourceDefs.WOOD)), "HUD trở lại số thật")
	GameState.set_dev_mode(false)
	Commands.set_game_speed(1)
	main.queue_free()
	await host.get_tree().process_frame
	check_eq(Loc.language_changed.get_connections().size(), language_connections, "Dọn cảnh không để callback UI cũ khi tải lại ván")
