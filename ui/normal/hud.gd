extends Control
## HUD riêng của chế độ Normal: góc trên-phải có thanh tài nguyên (chỉ tính đồ đã vào kho),
## ngày, và nút tạm dừng / ×1 / ×2 / ×3 (phím Space, 1–3 do controller lo).
## Đợt 3 thêm menu xây; Đợt 6 thêm thẻ nhiệm vụ. Chế độ Thần Linh sau này có HUD riêng
## trong ui/god/. Phần dùng chung mọi chế độ (bảng thông tin, toast) nằm ở ui/common/.
## Mọi bố cục dùng container tự giãn theo độ dài chữ, không đặt chiều rộng cứng.

const MARGIN: int = 12
const RESOURCE_ICON_SIZE: float = 26.0
const SPEED_BUTTON_SIZE: float = 44.0 # đủ to để chạm trên điện thoại
const SPEED_ICON_KEYS: Array[String] = ["ui/speed_pause", "ui/speed_1", "ui/speed_2", "ui/speed_3"]
const SPEED_TOOLTIP_KEYS: Array[String] = ["UI_SPEED_PAUSE", "UI_SPEED_1", "UI_SPEED_2", "UI_SPEED_3"]
const ACTIVE_SPEED_COLOR: Color = Color("#FFD54F")
const IDLE_SPEED_COLOR: Color = Color("#D7CCC8")
const BUMP_SCALE: float = 1.25

var _amount_labels: Dictionary[StringName, Label] = {}
var _resource_cells: Dictionary[StringName, Control] = {}
var _day_label: Label
var _speed_buttons: Array[Button] = []
var _speed_styles: Array[StyleBoxFlat] = []


func _ready() -> void:
	# Phủ toàn màn hình nhưng không chặn chạm vào thế giới ở chỗ trống.
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build()
	EventBus.resource_changed.connect(_on_resource_changed)
	EventBus.game_speed_changed.connect(_on_speed_changed)
	EventBus.day_changed.connect(_on_day_changed)
	Loc.language_changed.connect(_on_language_changed)
	_refresh_all()


func get_amount_text(resource_id: StringName) -> String:
	return _amount_labels[resource_id].text


func _build() -> void:
	var corner: MarginContainer = MarginContainer.new()
	corner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for side: String in ["margin_top", "margin_right"]:
		corner.add_theme_constant_override(side, MARGIN)
	add_child(corner)
	corner.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE)
	corner.grow_horizontal = Control.GROW_DIRECTION_BEGIN

	var panel: PanelContainer = PanelContainer.new()
	# Chặn chạm vào thế giới phía sau thanh HUD.
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	corner.add_child(panel)
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	panel.add_child(row)

	for resource_id: StringName in ResourceDefs.ORDER:
		row.add_child(_make_resource_cell(resource_id))
	row.add_child(VSeparator.new())
	_day_label = Label.new()
	_day_label.theme_type_variation = &"TitleLabel"
	_day_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(_day_label)
	row.add_child(VSeparator.new())

	var speeds: HBoxContainer = HBoxContainer.new()
	speeds.add_theme_constant_override("separation", 4)
	row.add_child(speeds)
	for speed: int in SPEED_ICON_KEYS.size():
		speeds.add_child(_make_speed_button(speed))


func _make_resource_cell(resource_id: StringName) -> Control:
	var cell: HBoxContainer = HBoxContainer.new()
	cell.add_theme_constant_override("separation", 4)
	cell.mouse_filter = Control.MOUSE_FILTER_PASS
	var icon: TextureRect = TextureRect.new()
	icon.texture = ArtLibrary.get_texture(ResourceDefs.icon(resource_id))
	icon.custom_minimum_size = Vector2(RESOURCE_ICON_SIZE, RESOURCE_ICON_SIZE)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon.mouse_filter = Control.MOUSE_FILTER_PASS
	cell.add_child(icon)
	var label: Label = Label.new()
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cell.add_child(label)
	_amount_labels[resource_id] = label
	_resource_cells[resource_id] = cell
	return cell


func _make_speed_button(speed: int) -> Button:
	var button: Button = Button.new()
	button.icon = ArtLibrary.get_texture(SPEED_ICON_KEYS[speed])
	button.expand_icon = true
	button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.custom_minimum_size = Vector2(SPEED_BUTTON_SIZE, SPEED_BUTTON_SIZE)
	# Không giữ focus — để phím Space không "bấm lại" nút vừa click.
	button.focus_mode = Control.FOCUS_NONE
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.set_corner_radius_all(10)
	style.border_color = Color("#4E342E")
	style.set_border_width_all(2)
	style.set_content_margin_all(6)
	for state: String in ["normal", "hover", "pressed"]:
		button.add_theme_stylebox_override(state, style)
	button.pressed.connect(func() -> void: Commands.set_game_speed(speed))
	_speed_buttons.append(button)
	_speed_styles.append(style)
	return button


func _refresh_all() -> void:
	for resource_id: StringName in ResourceDefs.ORDER:
		_amount_labels[resource_id].text = Loc.number(GameState.get_amount(resource_id))
		_resource_cells[resource_id].tooltip_text = Loc.t(ResourceDefs.name_key(resource_id))
	_day_label.text = Loc.t("UI_DAY", {"day": Loc.number(GameState.day)})
	for speed: int in _speed_buttons.size():
		_speed_buttons[speed].tooltip_text = Loc.t(SPEED_TOOLTIP_KEYS[speed])
	_on_speed_changed(GameState.speed)


func _on_resource_changed(resource_id: StringName, amount: int) -> void:
	if not _amount_labels.has(resource_id):
		return
	var label: Label = _amount_labels[resource_id]
	var grew: bool = amount > label.text.replace(".", "").replace(",", "").to_int()
	label.text = Loc.number(amount)
	if grew:
		# Số nảy lên một chút khi có đồ mới vào kho.
		label.pivot_offset = label.size * 0.5
		label.scale = Vector2(BUMP_SCALE, BUMP_SCALE)
		label.create_tween().tween_property(label, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_speed_changed(speed: int) -> void:
	for i: int in _speed_styles.size():
		_speed_styles[i].bg_color = ACTIVE_SPEED_COLOR if i == speed else IDLE_SPEED_COLOR


func _on_day_changed(day: int) -> void:
	_day_label.text = Loc.t("UI_DAY", {"day": Loc.number(day)})


func _on_language_changed(_code: String) -> void:
	_refresh_all()
