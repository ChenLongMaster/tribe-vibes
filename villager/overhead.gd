class_name Overhead
extends Node2D
## Mọi thứ hiện trên đầu thổ dân: bong bóng nói / bong bóng nghĩ (chỉ có HÌNH, thổ dân
## không nói chữ — giống game gốc), icon việc đang làm, tên, chữ Z khi ngủ, tim bay. Đây là
## kênh "phản hồi rõ ràng" để người chơi luôn biết thổ dân đang làm gì và muốn gì.
## (Tấm biển giơ trên tay nằm ở VillagerRig vì nó đi theo động tác tay.)
##
## Chỉ NGHE thổ dân (signal + đọc trạng thái) — lõi mô phỏng không biết hình hiện ra sao.

const SPEECH_SECONDS: float = 1.6
const THOUGHT_SECONDS: float = 2.6
const BUBBLE_ICON_SIZE: float = 22.0
## Icon nằm giữa phần mây (tính từ mép dưới đuôi mây, px hiển thị).
const THOUGHT_ICON_POS: Vector2 = Vector2(0, -26)
const THOUGHT_ICON_SCALE: float = 1.1
const MAX_SPEECH_ICONS: int = 2
const BUBBLE_GAP_ABOVE_NAME: float = 18.0
const NAME_FONT_SIZE: int = 13
const ACTIVITY_BOB: float = 2.0
const ZZZ_INTERVAL: float = 0.9
const ZZZ_LIFE: float = 1.6
const HEART_LIFE: float = 1.2
const ALERT_OFFSET: Vector2 = Vector2(18, -4) # icon chỉ số thấp đứng lệch sang bên
const ALERT_BLINK_SPEED: float = 6.0
const KNOCKOUT_STAR_COUNT: int = 3
const KNOCKOUT_STAR_RADIUS: Vector2 = Vector2(16, 6)
const KNOCKOUT_STAR_SPEED: float = 3.0
const KNOCKOUT_STAR_SCALE: float = 0.3

var _villager: Villager
var _bubble: PanelContainer
var _bubble_icons: Array[TextureRect] = []
var _thought: Node2D
var _thought_icon: Sprite2D
## Bong bóng đang hiện (_bubble, _thought hoặc null) và thời gian còn lại (INF = tới khi xoá).
var _shown: CanvasItem
var _bubble_time: float = 0.0
var _activity: Sprite2D
var _name_label: Label
var _zzz_timer: float = 0.0
var _alert: Sprite2D
var _alert_need: StringName = &""
var _stars: Array[Sprite2D] = []
var _time: float = 0.0


func _ready() -> void:
	_activity = Sprite2D.new()
	_activity.visible = false
	add_child(_activity)
	_name_label = _make_name_label()
	add_child(_name_label)
	_bubble = _make_bubble()
	add_child(_bubble)
	_thought = _make_thought()
	add_child(_thought)
	_alert = Sprite2D.new()
	_alert.visible = false
	add_child(_alert)
	for i: int in KNOCKOUT_STAR_COUNT:
		var star: Sprite2D = Sprite2D.new()
		ArtLibrary.setup_sprite(star, "icons/star")
		star.scale *= KNOCKOUT_STAR_SCALE * 2.0
		star.visible = false
		add_child(star)
		_stars.append(star)
	_villager = get_parent() as Villager
	if _villager != null:
		_villager.bubble_requested.connect(_on_bubble_requested)
		_villager.bubble_cleared.connect(_hide_bubble)
		_villager.heart_requested.connect(_on_heart_requested)
		_villager.task_changed.connect(_on_task_changed)
		_name_label.text = _villager.data.display_name


func set_name_visible(on: bool) -> void:
	_name_label.visible = on
	_name_label.reset_size()


func _on_bubble_requested(style: Villager.Bubble, icon_keys: Array[String], seconds: float) -> void:
	if icon_keys.is_empty():
		return
	_hide_bubble()
	if style == Villager.Bubble.THOUGHT:
		ArtLibrary.setup_sprite(_thought_icon, icon_keys[0])
		_thought_icon.scale *= THOUGHT_ICON_SCALE
		_pop_in(_thought, seconds if seconds > 0.0 else THOUGHT_SECONDS)
		return
	for i: int in _bubble_icons.size():
		var rect: TextureRect = _bubble_icons[i]
		rect.visible = i < icon_keys.size()
		if rect.visible:
			rect.texture = ArtLibrary.get_texture(icon_keys[i])
	_bubble.reset_size()
	_pop_in(_bubble, seconds if seconds > 0.0 else SPEECH_SECONDS)


func _on_heart_requested() -> void:
	_float_sprite("fx/heart", Vector2(0, 4), Vector2(0, -34), HEART_LIFE, 1.0)


func _on_task_changed(villager: Villager) -> void:
	var icon_key: String = villager.activity_icon()
	_activity.visible = not icon_key.is_empty()
	if _activity.visible:
		ArtLibrary.setup_sprite(_activity, icon_key)


func _pop_in(item: CanvasItem, seconds: float) -> void:
	_shown = item
	_bubble_time = seconds
	item.visible = true
	# Control và Node2D đều có `scale` nhưng không chung lớp cha có thuộc tính này.
	item.set("scale", Vector2(0.6, 0.6))
	var tween: Tween = item.create_tween()
	tween.tween_property(item, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _hide_bubble() -> void:
	_bubble.visible = false
	_thought.visible = false
	_shown = null


func _process(delta: float) -> void:
	_time += delta
	if _shown != null:
		_bubble_time -= delta
		if _bubble_time <= 0.0:
			_hide_bubble()
	# Đặt bong bóng sao cho mép dưới ở giữa đầu, phía trên tên (nếu tên đang hiện).
	var lift: float = BUBBLE_GAP_ABOVE_NAME if _name_label.visible else 0.0
	_bubble.position = Vector2(-_bubble.size.x * 0.5, -_bubble.size.y - lift)
	_bubble.pivot_offset = Vector2(_bubble.size.x * 0.5, _bubble.size.y)
	_thought.position = Vector2(0, -lift)
	_name_label.position = Vector2(-_name_label.size.x * 0.5, -_name_label.size.y + 4.0)
	_activity.position = Vector2(0, -6 - lift + sin(_time * 3.0) * ACTIVITY_BOB)
	# Bong bóng đang hiện thì giấu icon việc cho đỡ rối.
	_activity.modulate.a = 0.0 if _shown != null else 1.0
	# Chữ Z bay lên khi đang ngủ — đọc thẳng trạng thái, lõi không phải báo riêng.
	if _villager != null and _villager.state == Villager.State.SLEEPING:
		_zzz_timer -= delta
		if _zzz_timer <= 0.0:
			_zzz_timer = ZZZ_INTERVAL
			_float_sprite("fx/zzz", Vector2(10, 22), Vector2(26, -10), ZZZ_LIFE, 0.5, 1.1)
	else:
		_zzz_timer = 0.0
	_update_alert(lift)
	_update_stars()


# Chỉ số dưới ngưỡng thì icon của nó nhấp nháy cạnh đầu (máu trước, rồi đói, thể lực…).
func _update_alert(lift: float) -> void:
	var need_id: StringName = _lowest_alert_need()
	_alert.visible = need_id != &""
	if not _alert.visible:
		return
	if need_id != _alert_need:
		_alert_need = need_id
		ArtLibrary.setup_sprite(_alert, NeedDefs.icon_for(need_id, _villager.status.get_need(need_id)))
	_alert.position = ALERT_OFFSET + Vector2(0, -lift)
	_alert.modulate.a = 0.55 + 0.45 * sin(_time * ALERT_BLINK_SPEED)


func _lowest_alert_need() -> StringName:
	# Đang ngủ/ngất đã có chữ Z/sao, không nhấp nháy thêm cho rối.
	if _villager == null or _villager.state in [Villager.State.SLEEPING, Villager.State.KNOCKED_OUT]:
		return &""
	var mode: GameModeConfig = GameState.get_mode()
	for need_id: StringName in NeedDefs.ORDER:
		if mode.need_enabled(need_id) and _villager.status.get_need(need_id) < NeedDefs.alert_below(need_id):
			return need_id
	return &""


# Ngất thì vài ngôi sao quay quanh đầu.
func _update_stars() -> void:
	var dizzy: bool = _villager != null and _villager.state == Villager.State.KNOCKED_OUT
	for i: int in _stars.size():
		var star: Sprite2D = _stars[i]
		star.visible = dizzy
		if dizzy:
			var angle: float = _time * KNOCKOUT_STAR_SPEED + TAU * i / _stars.size()
			star.position = Vector2(cos(angle) * KNOCKOUT_STAR_RADIUS.x, sin(angle) * KNOCKOUT_STAR_RADIUS.y + 10.0)


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
	for i: int in MAX_SPEECH_ICONS:
		var icon: TextureRect = TextureRect.new()
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.custom_minimum_size = Vector2(BUBBLE_ICON_SIZE, BUBBLE_ICON_SIZE)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		row.add_child(icon)
		_bubble_icons.append(icon)
	panel.visible = false
	return panel


func _make_thought() -> Node2D:
	var root: Node2D = Node2D.new()
	var cloud: Sprite2D = Sprite2D.new()
	ArtLibrary.setup_sprite(cloud, "ui/thought_bubble")
	root.add_child(cloud)
	_thought_icon = Sprite2D.new()
	_thought_icon.position = THOUGHT_ICON_POS
	root.add_child(_thought_icon)
	root.visible = false
	return root


func _make_name_label() -> Label:
	var label: Label = Label.new()
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", NAME_FONT_SIZE)
	label.add_theme_color_override("font_outline_color", Color(1, 0.97, 0.9))
	label.add_theme_constant_override("outline_size", 5)
	label.visible = false
	return label
