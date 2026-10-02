extends TestCase
## InputRouter: chuột kiểu AoE (trái chọn / kéo khung, phải ra lệnh, giữa kéo bản đồ), cảm ứng
## (chạm, kéo bản đồ, kéo-thả giao việc, nhấn giữ rồi kéo = khung chọn); chuột giả lập bị bỏ qua.

var _taps: Array[Vector2] = []
var _pans: Array[Vector2] = []
var _zooms: Array[float] = []
var _cancels: int = 0
var _long_presses: int = 0
var _drag_events: Array[String] = []
var _secondary: Array[Vector2] = []
var _boxes: Array[String] = []


func test_mouse_click_is_tap() -> void:
	_begin()
	_mouse_button(MOUSE_BUTTON_LEFT, true, Vector2(100, 100))
	_mouse_button(MOUSE_BUTTON_LEFT, false, Vector2(103, 101))
	check_eq(_taps.size(), 1, "Click phải ra đúng một lần chạm")
	check(_pans.is_empty(), "Click không được kéo camera")
	_end()


func test_mouse_left_drag_is_box_select() -> void:
	_begin()
	_mouse_button(MOUSE_BUTTON_LEFT, true, Vector2(100, 100))
	_mouse_motion(Vector2(130, 100), MOUSE_BUTTON_MASK_LEFT)
	_mouse_motion(Vector2(150, 110), MOUSE_BUTTON_MASK_LEFT)
	_mouse_button(MOUSE_BUTTON_LEFT, false, Vector2(150, 110))
	check(_pans.is_empty(), "Kéo chuột trái KHÔNG kéo bản đồ")
	check(not _boxes.is_empty() and _boxes[0] == "start" and _boxes[-1] == "end", "Kéo chuột trái = khung chọn: %s" % str(_boxes))
	check(_taps.is_empty(), "Kéo xong không được tính là chạm")
	_end()


func test_middle_drag_pans() -> void:
	_begin()
	_mouse_button(MOUSE_BUTTON_MIDDLE, true, Vector2(100, 100))
	_mouse_motion_relative(Vector2(130, 110), Vector2(30, 10), MOUSE_BUTTON_MASK_MIDDLE)
	_mouse_button(MOUSE_BUTTON_MIDDLE, false, Vector2(130, 110))
	check_eq(_sum(_pans), Vector2(30, 10), "Kéo chuột giữa = kéo bản đồ")
	_end()


func test_wheel_zooms_and_right_click_commands() -> void:
	_begin()
	_mouse_button(MOUSE_BUTTON_WHEEL_UP, true, Vector2(10, 10))
	_mouse_button(MOUSE_BUTTON_WHEEL_DOWN, true, Vector2(10, 10))
	_mouse_button(MOUSE_BUTTON_RIGHT, true, Vector2(10, 10))
	_mouse_button(MOUSE_BUTTON_RIGHT, false, Vector2(12, 11))
	check(_zooms.size() == 2 and _zooms[0] > 1.0 and _zooms[1] < 1.0, "Lăn lên phóng to, lăn xuống thu nhỏ")
	check_eq(_secondary.size(), 1, "Click phải = ra lệnh")
	check_eq(_cancels, 0, "Click phải không còn là huỷ")
	check(_taps.is_empty(), "Click phải không phải là chọn")
	_end()


func test_emulated_mouse_is_ignored() -> void:
	_begin()
	_mouse_button(MOUSE_BUTTON_LEFT, true, Vector2(100, 100), InputEvent.DEVICE_ID_EMULATION)
	_mouse_button(MOUSE_BUTTON_LEFT, false, Vector2(100, 100), InputEvent.DEVICE_ID_EMULATION)
	check(_taps.is_empty(), "Chuột giả lập từ cảm ứng không được tính")
	_end()


func test_touch_tap_and_mode() -> void:
	_begin()
	_touch(0, true, Vector2(200, 200))
	_touch(0, false, Vector2(204, 202))
	check_eq(_taps.size(), 1, "Chạm ngón tay ra đúng một lần chạm")
	check_eq(InputRouter.mode, InputRouter.Mode.TOUCH, "Chuyển sang chế độ cảm ứng")
	_end()


func test_pinch_zooms() -> void:
	_begin()
	_touch(0, true, Vector2(100, 100))
	_touch(1, true, Vector2(200, 100))
	_drag(1, Vector2(300, 100))
	_touch(1, false, Vector2(300, 100))
	_touch(0, false, Vector2(100, 100))
	check(_zooms.size() == 1 and is_equal_approx(_zooms[0], 2.0), "Hai ngón xa gấp đôi thì zoom ×2")
	check(_taps.is_empty(), "Chụm xong nhấc tay không được tính là chạm")
	_end()


func test_long_press_then_no_tap() -> void:
	_begin()
	_touch(0, true, Vector2(50, 50))
	# Giả như ngón tay đã giữ được 1 giây.
	InputRouter._press_time_ms -= 1000
	InputRouter._process(0.0)
	_touch(0, false, Vector2(50, 50))
	check_eq(_long_presses, 1, "Nhấn giữ phải ra lệnh xem nhanh")
	check(_taps.is_empty(), "Nhấn giữ xong nhấc tay không tính là chạm")
	_end()


func test_touch_drag_from_pickable_assigns() -> void:
	_begin()
	var target: Node = Node.new()
	InputRouter.drag_picker = func(_pos: Vector2) -> Node: return target
	_touch(0, true, Vector2(100, 100))
	_drag(0, Vector2(140, 100))
	_touch(0, false, Vector2(140, 100))
	var expected: Array[String] = ["start", "move", "end"]
	check_eq(_drag_events, expected, "Cảm ứng: kéo từ thổ dân = kéo-giao-việc")
	check(_pans.is_empty(), "Kéo-giao-việc không được kéo camera")
	_drag_events.clear()
	# Chuột kéo từ thổ dân thì là khung chọn, không phải kéo-giao-việc.
	_mouse_button(MOUSE_BUTTON_LEFT, true, Vector2(100, 100))
	_mouse_motion(Vector2(140, 100), MOUSE_BUTTON_MASK_LEFT)
	_mouse_button(MOUSE_BUTTON_LEFT, false, Vector2(140, 100))
	check(_drag_events.is_empty(), "Chuột không kéo-thả giao việc")
	target.free()
	_end()


func test_touch_drag_pans_and_long_press_drag_boxes() -> void:
	_begin()
	_touch(0, true, Vector2(100, 100))
	_drag(0, Vector2(130, 100))
	_touch(0, false, Vector2(130, 100))
	check_eq(_sum(_pans), Vector2(30, 0), "Cảm ứng: kéo một ngón = kéo bản đồ")
	_pans.clear()
	_touch(0, true, Vector2(50, 50))
	InputRouter._press_time_ms -= 1000
	InputRouter._process(0.0)
	_drag(0, Vector2(120, 90))
	_touch(0, false, Vector2(120, 90))
	check(_pans.is_empty(), "Nhấn giữ rồi kéo không kéo bản đồ")
	check(not _boxes.is_empty() and _boxes[-1] == "end", "Nhấn giữ rồi kéo = khung chọn")
	_end()


# --- Hỗ trợ ---

func _begin() -> void:
	_taps.clear()
	_pans.clear()
	_zooms.clear()
	_drag_events.clear()
	_secondary.clear()
	_boxes.clear()
	_cancels = 0
	_long_presses = 0
	InputRouter.tapped.connect(_on_tapped)
	InputRouter.pan_requested.connect(_on_pan)
	InputRouter.zoom_requested.connect(_on_zoom)
	InputRouter.cancel_requested.connect(_on_cancel)
	InputRouter.long_pressed.connect(_on_long_press)
	InputRouter.drag_assign_started.connect(_on_drag_started)
	InputRouter.drag_assign_moved.connect(_on_drag_moved)
	InputRouter.drag_assign_ended.connect(_on_drag_ended)
	InputRouter.secondary_tapped.connect(_on_secondary)
	InputRouter.box_select_started.connect(_on_box_started)
	InputRouter.box_select_ended.connect(_on_box_ended)


func _end() -> void:
	InputRouter.secondary_tapped.disconnect(_on_secondary)
	InputRouter.box_select_started.disconnect(_on_box_started)
	InputRouter.box_select_ended.disconnect(_on_box_ended)
	InputRouter.tapped.disconnect(_on_tapped)
	InputRouter.pan_requested.disconnect(_on_pan)
	InputRouter.zoom_requested.disconnect(_on_zoom)
	InputRouter.cancel_requested.disconnect(_on_cancel)
	InputRouter.long_pressed.disconnect(_on_long_press)
	InputRouter.drag_assign_started.disconnect(_on_drag_started)
	InputRouter.drag_assign_moved.disconnect(_on_drag_moved)
	InputRouter.drag_assign_ended.disconnect(_on_drag_ended)
	InputRouter.drag_picker = Callable()
	InputRouter.mode = InputRouter.Mode.MOUSE


# Gửi sự kiện theo đúng thứ tự Godot: _input trước, _unhandled_input sau.
func _send(event: InputEvent) -> void:
	InputRouter._input(event)
	InputRouter._unhandled_input(event)


func _mouse_button(button: MouseButton, pressed: bool, pos: Vector2, device: int = 0) -> void:
	var event: InputEventMouseButton = InputEventMouseButton.new()
	event.button_index = button
	event.pressed = pressed
	event.position = pos
	event.device = device
	_send(event)


func _mouse_motion(pos: Vector2, mask: MouseButtonMask) -> void:
	var event: InputEventMouseMotion = InputEventMouseMotion.new()
	event.position = pos
	event.button_mask = mask
	_send(event)


func _mouse_motion_relative(pos: Vector2, relative: Vector2, mask: MouseButtonMask) -> void:
	var event: InputEventMouseMotion = InputEventMouseMotion.new()
	event.position = pos
	event.relative = relative
	event.button_mask = mask
	_send(event)


func _touch(index: int, pressed: bool, pos: Vector2) -> void:
	var event: InputEventScreenTouch = InputEventScreenTouch.new()
	event.index = index
	event.pressed = pressed
	event.position = pos
	_send(event)


func _drag(index: int, pos: Vector2) -> void:
	var event: InputEventScreenDrag = InputEventScreenDrag.new()
	event.index = index
	event.position = pos
	_send(event)


func _sum(vectors: Array[Vector2]) -> Vector2:
	var total: Vector2 = Vector2.ZERO
	for vector: Vector2 in vectors:
		total += vector
	return total


func _on_tapped(pos: Vector2) -> void:
	_taps.append(pos)


func _on_pan(delta: Vector2) -> void:
	_pans.append(delta)


func _on_zoom(factor: float, _pos: Vector2) -> void:
	_zooms.append(factor)


func _on_cancel() -> void:
	_cancels += 1


func _on_long_press(_pos: Vector2) -> void:
	_long_presses += 1


func _on_drag_started(_pos: Vector2, _target: Node) -> void:
	_drag_events.append("start")


func _on_drag_moved(_pos: Vector2) -> void:
	_drag_events.append("move")


func _on_drag_ended(_pos: Vector2) -> void:
	_drag_events.append("end")


func _on_secondary(pos: Vector2) -> void:
	_secondary.append(pos)


func _on_box_started(_pos: Vector2) -> void:
	_boxes.append("start")


func _on_box_ended(_from: Vector2, _to: Vector2) -> void:
	_boxes.append("end")
