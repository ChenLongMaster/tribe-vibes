class_name CommandCursor
extends Control
## Icon nhỏ nhún nhún cạnh con trỏ chuột, cho biết click phải sẽ làm gì với những người đang
## chọn (bụi quả → đồ ăn, cây → rìu, đá → cuốc, móng → búa, mặt đất → dấu chân…). Controller quyết
## định icon (EventBus.command_cursor_changed), ở đây chỉ vẽ. Cảm ứng không có con trỏ nên ẩn.

const ICON_SIZE: float = 30.0
const OFFSET: Vector2 = Vector2(18, 12)
const BOUNCE_HEIGHT: float = 4.0
const BOUNCE_SPEED: float = 9.0

var _icon: TextureRect
var _time: float = 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_level = true
	_icon = TextureRect.new()
	_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_icon.size = Vector2(ICON_SIZE, ICON_SIZE)
	add_child(_icon)
	visible = false
	EventBus.command_cursor_changed.connect(_on_cursor_changed)


func _process(delta: float) -> void:
	if not visible:
		return
	_time += delta / maxf(Engine.time_scale, 0.001)
	if InputRouter.mode != InputRouter.Mode.MOUSE or not InputRouter.mouse_on_screen:
		_icon.visible = false
		return
	_icon.visible = true
	position = InputRouter.mouse_position + OFFSET + Vector2(0, -absf(sin(_time * BOUNCE_SPEED)) * BOUNCE_HEIGHT)


func _on_cursor_changed(icon_key: String) -> void:
	visible = not icon_key.is_empty()
	if visible:
		_icon.texture = ArtLibrary.get_texture(icon_key)
		_icon.scale = Vector2(0.6, 0.6)
		_icon.pivot_offset = _icon.size * 0.5
		_icon.create_tween().tween_property(_icon, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
