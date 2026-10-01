class_name Overhead
extends Node2D
## Mọi thứ hiện trên đầu thổ dân: bong bóng thoại/cảm xúc, icon việc đang làm, tên,
## chữ Z khi ngủ, tim bay. Đây là kênh "phản hồi rõ ràng" để người chơi luôn biết
## thổ dân đang làm gì và vì sao.

const BUBBLE_SECONDS: float = 2.6
const BUBBLE_FONT_SIZE: int = 14
const BUBBLE_ICON_SIZE: float = 22.0
const BUBBLE_GAP_ABOVE_NAME: float = 18.0
const NAME_FONT_SIZE: int = 13
const ACTIVITY_BOB: float = 2.0
const ZZZ_INTERVAL: float = 0.9
const ZZZ_LIFE: float = 1.6
const HEART_LIFE: float = 1.2

var _bubble: PanelContainer
var _bubble_icon: TextureRect
var _bubble_label: Label
var _bubble_time: float = 0.0
var _activity: Sprite2D
var _name_label: Label
var _sleeping: bool = false
var _zzz_timer: float = 0.0
var _time: float = 0.0


func _ready() -> void:
	_activity = Sprite2D.new()
	_activity.visible = false
	add_child(_activity)
	_name_label = _make_name_label()
	add_child(_name_label)
	_bubble = _make_bubble()
	add_child(_bubble)


## Bong bóng có chữ và/hoặc icon. Chữ đã dịch sẵn (gọi Loc trước khi truyền vào).
func show_bubble(text: String, icon_key: String = "", seconds: float = BUBBLE_SECONDS) -> void:
	_bubble_label.text = text
	_bubble_label.visible = not text.is_empty()
	_bubble_icon.visible = not icon_key.is_empty()
	if _bubble_icon.visible:
		_bubble_icon.texture = ArtLibrary.get_texture(icon_key)
	_bubble.reset_size()
	_bubble.visible = true
	_bubble_time = seconds
	_bubble.scale = Vector2(0.6, 0.6)
	var tween: Tween = _bubble.create_tween()
	tween.tween_property(_bubble, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Bong bóng chỉ có icon cảm xúc (vui ♪, đói, buồn ngủ…).
func show_emote(icon_key: String, seconds: float = 1.6) -> void:
	show_bubble("", icon_key, seconds)


func set_activity_icon(icon_key: String) -> void:
	_activity.visible = not icon_key.is_empty()
	if _activity.visible:
		ArtLibrary.setup_sprite(_activity, icon_key)


func set_display_name(text: String) -> void:
	_name_label.text = text
	_name_label.reset_size()


func set_name_visible(on: bool) -> void:
	_name_label.visible = on


func set_sleeping(on: bool) -> void:
	_sleeping = on
	_zzz_timer = 0.0


func pop_heart() -> void:
	_float_sprite("fx/heart", Vector2(0, 4), Vector2(0, -34), HEART_LIFE, 1.0)


func _process(delta: float) -> void:
	_time += delta
	if _bubble.visible:
		_bubble_time -= delta
		if _bubble_time <= 0.0:
			_bubble.visible = false
	# Đặt bong bóng sao cho mép dưới ở giữa đầu, phía trên tên (nếu tên đang hiện).
	var lift: float = BUBBLE_GAP_ABOVE_NAME if _name_label.visible else 0.0
	_bubble.position = Vector2(-_bubble.size.x * 0.5, -_bubble.size.y - lift)
	_bubble.pivot_offset = Vector2(_bubble.size.x * 0.5, _bubble.size.y)
	_name_label.position = Vector2(-_name_label.size.x * 0.5, -_name_label.size.y + 4.0)
	_activity.position = Vector2(0, -6 - lift + sin(_time * 3.0) * ACTIVITY_BOB)
	# Bong bóng đang hiện thì giấu icon việc cho đỡ rối.
	_activity.modulate.a = 0.0 if _bubble.visible else 1.0
	if _sleeping:
		_zzz_timer -= delta
		if _zzz_timer <= 0.0:
			_zzz_timer = ZZZ_INTERVAL
			_float_sprite("fx/zzz", Vector2(10, 22), Vector2(26, -10), ZZZ_LIFE, 0.5, 1.1)


func _float_sprite(key: String, from: Vector2, to: Vector2, life: float, start_scale: float, end_scale: float = -1.0) -> void:
	var sprite: Sprite2D = Sprite2D.new()
	ArtLibrary.setup_sprite(sprite, key)
	var base: Vector2 = sprite.scale
	sprite.position = from
	sprite.scale = base * start_scale
	add_child(sprite)
	var final_scale: float = end_scale if end_scale > 0.0 else start_scale
	var tween: Tween = sprite.create_tween().set_parallel(true)
	tween.tween_property(sprite, "position", to, life).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "scale", base * final_scale, life)
	tween.tween_property(sprite, "modulate:a", 0.0, life * 0.5).set_delay(life * 0.5)
	tween.finished.connect(sprite.queue_free)


func _make_bubble() -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(1, 1, 1, 0.95)
	style.border_color = Color("#4E342E")
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	style.content_margin_left = 7
	style.content_margin_right = 7
	style.content_margin_top = 3
	style.content_margin_bottom = 3
	panel.add_theme_stylebox_override("panel", style)
	var row: HBoxContainer = HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 4)
	panel.add_child(row)
	_bubble_icon = TextureRect.new()
	_bubble_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bubble_icon.custom_minimum_size = Vector2(BUBBLE_ICON_SIZE, BUBBLE_ICON_SIZE)
	_bubble_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_bubble_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	row.add_child(_bubble_icon)
	_bubble_label = Label.new()
	_bubble_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bubble_label.add_theme_font_size_override("font_size", BUBBLE_FONT_SIZE)
	_bubble_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(_bubble_label)
	panel.visible = false
	return panel


func _make_name_label() -> Label:
	var label: Label = Label.new()
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", NAME_FONT_SIZE)
	label.add_theme_color_override("font_outline_color", Color(1, 0.97, 0.9))
	label.add_theme_constant_override("outline_size", 5)
	label.visible = false
	return label
