extends Node
## Gom chuột + cảm ứng thành lệnh chung (chạm, kéo, zoom, huỷ…) để phần còn lại
## của game không cần biết người chơi đang dùng gì.
##
## - Bắt đầu cử chỉ ở `_unhandled_input`: UI được ăn sự kiện trước, bấm nút không
##   làm camera chạy.
## - Theo dõi/kết thúc cử chỉ ở `_input`: đã kéo từ thế giới thì lướt qua UI vẫn
##   không bị đứt.
## - Chuột giả lập từ cảm ứng (device = DEVICE_ID_EMULATION) bị bỏ qua, vì cảm ứng
##   đã được xử lý trực tiếp — tránh nhận đôi.

enum Mode { MOUSE, TOUCH }

signal input_mode_changed(mode: Mode)
## Chạm/click nhanh (không kéo). Ai nhận sẽ tự quyết là "chọn" hay "giao việc".
signal tapped(screen_pos: Vector2)
## Nhấn giữ trên cảm ứng — dùng để xem thông tin nhanh.
signal long_pressed(screen_pos: Vector2)
## Chuột di chuyển không bấm — dùng để xem thông tin nhanh bằng rê chuột.
signal hovered(screen_pos: Vector2)
signal drag_assign_started(screen_pos: Vector2, target: Node)
signal drag_assign_moved(screen_pos: Vector2)
signal drag_assign_ended(screen_pos: Vector2)
signal pan_requested(screen_delta: Vector2)
signal zoom_requested(factor: float, screen_pos: Vector2)
signal cancel_requested

## Di chuyển quá ngưỡng này (px) thì là kéo, không phải chạm.
const DRAG_THRESHOLD: float = 10.0
const LONG_PRESS_SECONDS: float = 0.4
const WHEEL_ZOOM_STEP: float = 1.12
const PAN_GESTURE_SPEED: float = 12.0

enum Gesture { NONE, PENDING, PAN, DRAG_ASSIGN, PINCH, CONSUMED }

var mode: Mode = Mode.MOUSE
## Hàm (screen_pos: Vector2) -> Node do World đăng ký: trả về vật kéo-giao-việc được
## (thổ dân) dưới ngón tay, hoặc null. Để trống thì mọi cú kéo đều là pan.
var drag_picker: Callable = Callable()

var _gesture: Gesture = Gesture.NONE
var _press_pos: Vector2 = Vector2.ZERO
var _last_pos: Vector2 = Vector2.ZERO
var _press_time_ms: int = 0
var _long_press_fired: bool = false
var _drag_target: Node = null
var _middle_panning: bool = false
var _touches: Dictionary[int, Vector2] = {}
var _pinch_distance: float = 0.0
var _pinch_center: Vector2 = Vector2.ZERO


func _ready() -> void:
	# Vẫn kéo/zoom được khi game tạm dừng.
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(_delta: float) -> void:
	# Đo bằng thời gian thật để nhấn giữ vẫn đúng 0.4 s khi game chạy ×3 hay đang dừng.
	if mode != Mode.TOUCH or _gesture != Gesture.PENDING or _long_press_fired:
		return
	if Time.get_ticks_msec() - _press_time_ms >= int(LONG_PRESS_SECONDS * 1000.0):
		_long_press_fired = true
		long_pressed.emit(_press_pos)


## Đổi toạ độ màn hình sang toạ độ thế giới (đã tính camera).
func screen_to_world(screen_pos: Vector2) -> Vector2:
	return get_viewport().get_canvas_transform().affine_inverse() * screen_pos


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel"):
		cancel_requested.emit()
	elif event is InputEventScreenTouch:
		var touch: InputEventScreenTouch = event
		if touch.pressed:
			_on_touch_pressed(touch.index, touch.position)
	elif event is InputEventMouseButton:
		var button: InputEventMouseButton = event
		if button.device != InputEvent.DEVICE_ID_EMULATION and button.pressed:
			_on_mouse_pressed(button)
	elif event is InputEventMouseMotion:
		var motion: InputEventMouseMotion = event
		if motion.device != InputEvent.DEVICE_ID_EMULATION and motion.button_mask == 0:
			hovered.emit(motion.position)
	elif event is InputEventMagnifyGesture:
		var magnify: InputEventMagnifyGesture = event
		zoom_requested.emit(magnify.factor, magnify.position)
	elif event is InputEventPanGesture:
		var pan_gesture: InputEventPanGesture = event
		pan_requested.emit(-pan_gesture.delta * PAN_GESTURE_SPEED)


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_set_mode(Mode.TOUCH)
		var touch: InputEventScreenTouch = event
		if not touch.pressed:
			_on_touch_released(touch.index, touch.position, touch.canceled)
	elif event is InputEventScreenDrag:
		_set_mode(Mode.TOUCH)
		var drag: InputEventScreenDrag = event
		_on_touch_dragged(drag.index, drag.position)
	elif event is InputEventMouseButton:
		var button: InputEventMouseButton = event
		if button.device == InputEvent.DEVICE_ID_EMULATION:
			return
		_set_mode(Mode.MOUSE)
		if not button.pressed:
			_on_mouse_released(button)
	elif event is InputEventMouseMotion:
		var motion: InputEventMouseMotion = event
		if motion.device == InputEvent.DEVICE_ID_EMULATION:
			return
		_set_mode(Mode.MOUSE)
		_on_mouse_moved(motion)


# --- Chuột ---

func _on_mouse_pressed(event: InputEventMouseButton) -> void:
	match event.button_index:
		MOUSE_BUTTON_LEFT:
			_begin_press(event.position)
		MOUSE_BUTTON_MIDDLE:
			_middle_panning = true
		MOUSE_BUTTON_RIGHT:
			cancel_requested.emit()
		MOUSE_BUTTON_WHEEL_UP:
			zoom_requested.emit(WHEEL_ZOOM_STEP, event.position)
		MOUSE_BUTTON_WHEEL_DOWN:
			zoom_requested.emit(1.0 / WHEEL_ZOOM_STEP, event.position)


func _on_mouse_released(event: InputEventMouseButton) -> void:
	match event.button_index:
		MOUSE_BUTTON_LEFT:
			_end_press(event.position, false)
		MOUSE_BUTTON_MIDDLE:
			_middle_panning = false


func _on_mouse_moved(event: InputEventMouseMotion) -> void:
	if _middle_panning:
		pan_requested.emit(event.relative)
	elif _gesture != Gesture.NONE and (event.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
		_move_press(event.position)


# --- Cảm ứng ---

func _on_touch_pressed(index: int, pos: Vector2) -> void:
	_touches[index] = pos
	if _touches.size() == 1:
		_begin_press(pos)
	elif _touches.size() == 2:
		# Ngón thứ hai chạm vào: bỏ cú kéo đang dở, chuyển sang chụm để zoom.
		if _gesture == Gesture.DRAG_ASSIGN:
			drag_assign_ended.emit(_last_pos)
		_gesture = Gesture.PINCH
		_pinch_distance = _touch_distance()
		_pinch_center = _touch_center()


func _on_touch_dragged(index: int, pos: Vector2) -> void:
	if not _touches.has(index):
		return
	_touches[index] = pos
	if _gesture == Gesture.PINCH and _touches.size() >= 2:
		var distance: float = _touch_distance()
		var center: Vector2 = _touch_center()
		if _pinch_distance > 0.0 and distance > 0.0:
			zoom_requested.emit(distance / _pinch_distance, center)
		pan_requested.emit(center - _pinch_center)
		_pinch_distance = distance
		_pinch_center = center
	elif _touches.size() == 1:
		_move_press(pos)


func _on_touch_released(index: int, pos: Vector2, canceled: bool) -> void:
	if not _touches.has(index):
		return
	_touches.erase(index)
	if _gesture == Gesture.PINCH:
		# Nhấc một ngón sau khi chụm thì không tính là chạm; đợi nhấc hết.
		_gesture = Gesture.NONE if _touches.is_empty() else Gesture.CONSUMED
	elif _touches.is_empty():
		_end_press(pos, canceled)


func _touch_distance() -> float:
	var points: Array[Vector2] = _first_two_touches()
	return points[0].distance_to(points[1])


func _touch_center() -> Vector2:
	var points: Array[Vector2] = _first_two_touches()
	return (points[0] + points[1]) * 0.5


func _first_two_touches() -> Array[Vector2]:
	var points: Array[Vector2] = []
	for index: int in _touches:
		points.append(_touches[index])
		if points.size() == 2:
			break
	return points


# --- Cử chỉ một điểm (dùng chung cho chuột trái và một ngón) ---

func _begin_press(pos: Vector2) -> void:
	_gesture = Gesture.PENDING
	_press_pos = pos
	_last_pos = pos
	_press_time_ms = Time.get_ticks_msec()
	_long_press_fired = false
	_drag_target = drag_picker.call(pos) as Node if drag_picker.is_valid() else null


func _move_press(pos: Vector2) -> void:
	match _gesture:
		Gesture.PENDING:
			if pos.distance_to(_press_pos) > DRAG_THRESHOLD:
				if is_instance_valid(_drag_target):
					_gesture = Gesture.DRAG_ASSIGN
					drag_assign_started.emit(_press_pos, _drag_target)
					drag_assign_moved.emit(pos)
				else:
					_gesture = Gesture.PAN
					pan_requested.emit(pos - _press_pos)
		Gesture.PAN:
			pan_requested.emit(pos - _last_pos)
		Gesture.DRAG_ASSIGN:
			drag_assign_moved.emit(pos)
	_last_pos = pos


func _end_press(pos: Vector2, canceled: bool) -> void:
	match _gesture:
		Gesture.PENDING:
			# Đã nhấn giữ để xem thông tin thì nhấc tay ra không tính là chạm nữa.
			if not canceled and not _long_press_fired:
				tapped.emit(pos)
		Gesture.DRAG_ASSIGN:
			drag_assign_ended.emit(pos)
	_gesture = Gesture.NONE
	_drag_target = null


func _set_mode(new_mode: Mode) -> void:
	if mode != new_mode:
		mode = new_mode
		input_mode_changed.emit(mode)
