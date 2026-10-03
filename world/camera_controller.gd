class_name CameraController
extends Camera2D
## Camera kéo/zoom mượt và luôn nằm trong map. Nhận lệnh từ InputRouter nên không
## cần biết người chơi dùng chuột hay cảm ứng. Chạy cả khi game tạm dừng.
## Trượt bằng phím WASD / mũi tên, kéo chuột giữa, hoặc đưa chuột sát mép màn hình (kiểu AoE).

var _map_rect: Rect2 = Rect2()
var _target_zoom: float = 1.0
## Khi zoom bằng lăn chuột/chụm tay: giữ điểm thế giới dưới con trỏ đứng yên.
var _has_zoom_anchor: bool = false
var _zoom_anchor_screen: Vector2 = Vector2.ZERO
var _zoom_anchor_world: Vector2 = Vector2.ZERO


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	InputRouter.pan_requested.connect(_on_pan_requested)
	InputRouter.zoom_requested.connect(_on_zoom_requested)


func setup(map_rect: Rect2, focus: Vector2) -> void:
	_map_rect = map_rect
	position = focus
	_target_zoom = clampf(Balance.CAMERA_ZOOM_DEFAULT, _min_zoom(), Balance.CAMERA_ZOOM_MAX)
	zoom = Vector2(_target_zoom, _target_zoom)
	_clamp_position()


func _process(delta: float) -> void:
	# delta đã bị nhân tốc độ game; camera cần thời gian thật để mượt như nhau ở ×1 lẫn ×3.
	var real_delta: float = delta / maxf(Engine.time_scale, 0.001)
	var key_direction: Vector2 = Input.get_vector("cam_left", "cam_right", "cam_up", "cam_down")
	if key_direction == Vector2.ZERO:
		key_direction = _edge_direction()
	if key_direction != Vector2.ZERO:
		_has_zoom_anchor = false
		position += key_direction * Balance.CAMERA_KEY_PAN_SPEED * real_delta / zoom.x

	_target_zoom = clampf(_target_zoom, _min_zoom(), Balance.CAMERA_ZOOM_MAX)
	var current: float = zoom.x
	if not is_equal_approx(current, _target_zoom):
		current = lerpf(current, _target_zoom, 1.0 - exp(-Balance.CAMERA_ZOOM_SMOOTHING * real_delta))
		if absf(current - _target_zoom) < 0.001:
			current = _target_zoom
		zoom = Vector2(current, current)
		if _has_zoom_anchor:
			position = _zoom_anchor_world - (_zoom_anchor_screen - _screen_center()) / current
	elif _has_zoom_anchor:
		_has_zoom_anchor = false
	_clamp_position()


func _on_pan_requested(screen_delta: Vector2) -> void:
	# Kéo bản đồ theo ngón tay: nội dung đi theo tay nên camera đi ngược lại.
	var world_delta: Vector2 = screen_delta / zoom.x
	position -= world_delta
	_zoom_anchor_world -= world_delta
	_clamp_position()


func _on_zoom_requested(factor: float, screen_pos: Vector2) -> void:
	# Neo lại mỗi lần, vì giữa hai nấc lăn chuột con trỏ có thể đã đi chỗ khác.
	_zoom_anchor_world = position + (screen_pos - _screen_center()) / zoom.x
	_zoom_anchor_screen = screen_pos
	_has_zoom_anchor = true
	_target_zoom = clampf(_target_zoom * factor, _min_zoom(), Balance.CAMERA_ZOOM_MAX)


# Chuột sát mép màn hình thì trượt về phía đó (chỉ khi đang dùng chuột và chuột trong cửa sổ).
func _edge_direction() -> Vector2:
	if InputRouter.mode != InputRouter.Mode.MOUSE or not InputRouter.mouse_on_screen:
		return Vector2.ZERO
	var view: Vector2 = get_viewport_rect().size
	var pos: Vector2 = InputRouter.mouse_position
	var margin: float = Balance.CAMERA_EDGE_SCROLL_PX
	var direction: Vector2 = Vector2.ZERO
	if pos.x <= margin:
		direction.x = -1.0
	elif pos.x >= view.x - margin:
		direction.x = 1.0
	if pos.y <= margin:
		direction.y = -1.0
	elif pos.y >= view.y - margin:
		direction.y = 1.0
	return direction.normalized()


func _screen_center() -> Vector2:
	return get_viewport_rect().size * 0.5


# Zoom nhỏ nhất sao cho khung hình không bao giờ rộng hơn map (không thấy khoảng trống).
func _min_zoom() -> float:
	if _map_rect.size.x <= 0.0 or _map_rect.size.y <= 0.0:
		return Balance.CAMERA_ZOOM_MIN
	var view: Vector2 = get_viewport_rect().size
	var fit: float = maxf(view.x / _map_rect.size.x, view.y / _map_rect.size.y)
	return minf(maxf(Balance.CAMERA_ZOOM_MIN, fit), Balance.CAMERA_ZOOM_MAX)


func _clamp_position() -> void:
	if _map_rect.size.x <= 0.0:
		return
	var half_view: Vector2 = get_viewport_rect().size * 0.5 / zoom.x
	var min_pos: Vector2 = _map_rect.position + half_view
	var max_pos: Vector2 = _map_rect.end - half_view
	position.x = clampf(position.x, min_pos.x, max_pos.x) if min_pos.x <= max_pos.x else _map_rect.get_center().x
	position.y = clampf(position.y, min_pos.y, max_pos.y) if min_pos.y <= max_pos.y else _map_rect.get_center().y
