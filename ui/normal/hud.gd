extends Control
## HUD riêng của chế độ Normal:
## - Góc trên-phải: thanh tài nguyên (đang có / sức chứa — đầy thì chữ đỏ), ngày + đồng hồ
##   mặt trời, nút tạm dừng / ×1 / ×2 / ×3 (phím Space, 1–3 do controller lo), nút lưu / tải.
## - Góc dưới-phải: nút Xây mở menu xây.
## - Dưới-giữa: khi đang đặt công trình thì hiện gợi ý + nút ✓ (cảm ứng) / ✕.
## - Icon nhún nhún cạnh con trỏ cho biết click phải sẽ làm gì (CommandCursor).
## Đợt 6 thêm thẻ nhiệm vụ. Chế độ Thần Linh sau này có HUD riêng trong ui/god/. Phần dùng
## chung mọi chế độ (bảng thông tin, bảng công trình, toast) nằm ở ui/common/.
## Mọi bố cục dùng container tự giãn theo độ dài chữ, không đặt chiều rộng cứng.

const MARGIN: int = 12
const RESOURCE_ICON_SIZE: float = 26.0
const SPEED_BUTTON_SIZE: float = 44.0 # đủ to để chạm trên điện thoại
const SPEED_ICON_KEYS: Array[String] = ["ui/speed_pause", "ui/speed_1", "ui/speed_2", "ui/speed_3"]
const SPEED_TOOLTIP_KEYS: Array[String] = ["UI_SPEED_PAUSE", "UI_SPEED_1", "UI_SPEED_2", "UI_SPEED_3"]
const ACTIVE_SPEED_COLOR: Color = Color("#FFD54F")
const IDLE_SPEED_COLOR: Color = Color("#D7CCC8")
const FULL_COLOR: Color = Color("#C62828")
const BUMP_SCALE: float = 1.25
const BUILD_BUTTON_SIZE: Vector2 = Vector2(64, 64)
## Bấm Tải lần hai trong chừng này giây mới tải thật (tránh lỡ tay mất ván đang chơi).
const LOAD_CONFIRM_SECONDS: float = 3.0

var _amount_labels: Dictionary[StringName, Label] = {}
var _capacity_labels: Dictionary[StringName, Label] = {}
var _resource_cells: Dictionary[StringName, Control] = {}
var _day_label: Label
var _speed_buttons: Array[Button] = []
var _speed_styles: Array[StyleBoxFlat] = []
var _save_button: Button
var _load_button: Button
var _load_armed: float = 0.0
var _build_button: Button
var _build_menu: BuildMenu
var _placement_bar: PanelContainer
var _placement_label: Label
var _confirm_button: Button
var _cancel_button: Button


func _ready() -> void:
	# Phủ toàn màn hình nhưng không chặn chạm vào thế giới ở chỗ trống.
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build()
	EventBus.resource_changed.connect(_on_resource_changed)
	EventBus.storage_capacity_changed.connect(_on_capacity_changed)
	EventBus.game_speed_changed.connect(_on_speed_changed)
	EventBus.day_changed.connect(_on_day_changed)
	EventBus.placement_state_changed.connect(_on_placement_state_changed)
	EventBus.villager_selected.connect(func(_villager: Node) -> void: _build_menu.visible = false)
	EventBus.building_selected.connect(func(_building: Node) -> void: _build_menu.visible = false)
	Loc.language_changed.connect(_on_language_changed)
	_refresh_all()


func _process(delta: float) -> void:
	if _load_armed > 0.0:
		_load_armed -= delta / maxf(Engine.time_scale, 0.001)
		if _load_armed <= 0.0:
			_load_button.text = ""


func get_amount_text(resource_id: StringName) -> String:
	return _amount_labels[resource_id].text


func get_build_menu() -> BuildMenu:
	return _build_menu


func _build() -> void:
	var corner: MarginContainer = MarginContainer.new()
	corner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for side: String in ["margin_top", "margin_right"]:
		corner.add_theme_constant_override(side, MARGIN)
	add_child(corner)
	corner.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE)
	corner.grow_horizontal = Control.GROW_DIRECTION_BEGIN

	var stack: VBoxContainer = VBoxContainer.new()
	stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_theme_constant_override("separation", 6)
	corner.add_child(stack)
	var panel: PanelContainer = PanelContainer.new()
	# Chặn chạm vào thế giới phía sau thanh HUD.
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	stack.add_child(panel)
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	panel.add_child(row)

	for resource_id: StringName in ResourceDefs.ORDER:
		row.add_child(_make_resource_cell(resource_id))
	row.add_child(VSeparator.new())
	var day_box: HBoxContainer = HBoxContainer.new()
	day_box.add_theme_constant_override("separation", 6)
	row.add_child(day_box)
	day_box.add_child(SunDial.new())
	_day_label = Label.new()
	_day_label.theme_type_variation = &"TitleLabel"
	_day_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	day_box.add_child(_day_label)
	row.add_child(VSeparator.new())

	var speeds: HBoxContainer = HBoxContainer.new()
	speeds.add_theme_constant_override("separation", 4)
	row.add_child(speeds)
	for speed: int in SPEED_ICON_KEYS.size():
		speeds.add_child(_make_speed_button(speed))
	# Lưu / tải ở hàng dưới cho thanh trên khỏi quá dài (màn hình điện thoại).
	var files: HBoxContainer = HBoxContainer.new()
	files.add_theme_constant_override("separation", 4)
	files.size_flags_horizontal = Control.SIZE_SHRINK_END
	files.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(files)
	_save_button = _make_icon_button("icons/save")
	_save_button.pressed.connect(func() -> void: Commands.save_game())
	files.add_child(_save_button)
	_load_button = _make_icon_button("icons/load")
	_load_button.pressed.connect(_on_load_pressed)
	files.add_child(_load_button)

	_build_bottom_right()
	_build_placement_bar()
	add_child(CommandCursor.new())


# Nút Xây to ở góc dưới-phải, menu bật lên ngay phía trên.
func _build_bottom_right() -> void:
	var corner: MarginContainer = MarginContainer.new()
	corner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for side: String in ["margin_bottom", "margin_right"]:
		corner.add_theme_constant_override(side, MARGIN)
	add_child(corner)
	corner.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT, Control.PRESET_MODE_MINSIZE)
	corner.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	corner.grow_vertical = Control.GROW_DIRECTION_BEGIN
	var column: VBoxContainer = VBoxContainer.new()
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.alignment = BoxContainer.ALIGNMENT_END
	column.add_theme_constant_override("separation", 8)
	corner.add_child(column)
	_build_menu = BuildMenu.new()
	_build_menu.size_flags_horizontal = Control.SIZE_SHRINK_END
	column.add_child(_build_menu)
	_build_button = Button.new()
	_build_button.icon = ArtLibrary.get_texture("icons/skill_build")
	_build_button.expand_icon = true
	_build_button.custom_minimum_size = BUILD_BUTTON_SIZE
	_build_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	_build_button.focus_mode = Control.FOCUS_NONE
	_build_button.pressed.connect(func() -> void:
		EventBus.placement_cancel_requested.emit()
		_build_menu.toggle())
	column.add_child(_build_button)


func _build_placement_bar() -> void:
	var holder: MarginContainer = MarginContainer.new()
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_theme_constant_override("margin_bottom", MARGIN)
	add_child(holder)
	holder.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM, Control.PRESET_MODE_MINSIZE)
	holder.grow_horizontal = Control.GROW_DIRECTION_BOTH
	holder.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_placement_bar = PanelContainer.new()
	_placement_bar.mouse_filter = Control.MOUSE_FILTER_STOP
	holder.add_child(_placement_bar)
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	_placement_bar.add_child(row)
	_placement_label = Label.new()
	_placement_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(_placement_label)
	_confirm_button = _make_icon_button("icons/check")
	_confirm_button.pressed.connect(func() -> void: EventBus.placement_confirm_requested.emit())
	row.add_child(_confirm_button)
	_cancel_button = _make_icon_button("icons/close")
	_cancel_button.pressed.connect(func() -> void: EventBus.placement_cancel_requested.emit())
	row.add_child(_cancel_button)
	_placement_bar.visible = false


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
	var capacity: Label = Label.new()
	capacity.theme_type_variation = &"SmallLabel"
	capacity.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cell.add_child(capacity)
	_amount_labels[resource_id] = label
	_capacity_labels[resource_id] = capacity
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


func _make_icon_button(icon_key: String) -> Button:
	var button: Button = Button.new()
	button.icon = ArtLibrary.get_texture(icon_key)
	button.expand_icon = true
	button.custom_minimum_size = Vector2(SPEED_BUTTON_SIZE, SPEED_BUTTON_SIZE)
	button.focus_mode = Control.FOCUS_NONE
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color("#FFF8E1")
	style.set_corner_radius_all(10)
	style.border_color = Color("#4E342E")
	style.set_border_width_all(2)
	style.set_content_margin_all(6)
	var pressed: StyleBoxFlat = style.duplicate()
	pressed.bg_color = ACTIVE_SPEED_COLOR
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", style)
	button.add_theme_stylebox_override("pressed", pressed)
	return button


func _refresh_all() -> void:
	for resource_id: StringName in ResourceDefs.ORDER:
		_resource_cells[resource_id].tooltip_text = Loc.t(ResourceDefs.name_key(resource_id))
		_refresh_resource(resource_id)
	_day_label.text = Loc.t("UI_DAY", {"day": Loc.number(GameState.day)})
	for speed: int in _speed_buttons.size():
		_speed_buttons[speed].tooltip_text = Loc.t(SPEED_TOOLTIP_KEYS[speed])
	_save_button.tooltip_text = Loc.t("UI_SAVE")
	_load_button.tooltip_text = Loc.t("UI_LOAD")
	_build_button.tooltip_text = Loc.t("UI_BUILD")
	_cancel_button.tooltip_text = Loc.t("UI_CANCEL")
	_confirm_button.tooltip_text = Loc.t("UI_PLACE_CONFIRM")
	_on_speed_changed(GameState.speed)


func _refresh_resource(resource_id: StringName) -> void:
	var amount: int = GameState.get_amount(resource_id)
	var capacity: int = GameState.capacity(resource_id)
	_amount_labels[resource_id].text = Loc.number(amount)
	var capacity_label: Label = _capacity_labels[resource_id]
	capacity_label.visible = capacity >= 0
	capacity_label.text = Loc.t("UI_CAPACITY", {"capacity": Loc.number(capacity)})
	# Đầy kho thì chữ đỏ — nhắc người chơi xây thêm Kho / Bếp.
	var full: bool = capacity >= 0 and amount >= capacity
	if full:
		_amount_labels[resource_id].add_theme_color_override("font_color", FULL_COLOR)
	else:
		_amount_labels[resource_id].remove_theme_color_override("font_color")
	_resource_cells[resource_id].tooltip_text = Loc.t("UI_RES_FULL_TOOLTIP" if full else ResourceDefs.name_key(resource_id),
			{"resource_key": ResourceDefs.name_key(resource_id)})


func _on_resource_changed(resource_id: StringName, amount: int) -> void:
	if not _amount_labels.has(resource_id):
		return
	var label: Label = _amount_labels[resource_id]
	var grew: bool = amount > label.text.replace(".", "").replace(",", "").to_int()
	_refresh_resource(resource_id)
	if grew:
		# Số nảy lên một chút khi có đồ mới vào kho.
		label.pivot_offset = label.size * 0.5
		label.scale = Vector2(BUMP_SCALE, BUMP_SCALE)
		label.create_tween().tween_property(label, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_capacity_changed(resource_id: StringName, _capacity: int) -> void:
	if _amount_labels.has(resource_id):
		_refresh_resource(resource_id)


func _on_speed_changed(speed: int) -> void:
	for i: int in _speed_styles.size():
		_speed_styles[i].bg_color = ACTIVE_SPEED_COLOR if i == speed else IDLE_SPEED_COLOR


func _on_day_changed(day: int) -> void:
	_day_label.text = Loc.t("UI_DAY", {"day": Loc.number(day)})


func _on_placement_state_changed(active: bool, building_id: StringName, can_confirm: bool) -> void:
	_placement_bar.visible = active
	if not active:
		return
	_build_menu.visible = false
	_confirm_button.visible = can_confirm
	var hint_key: String = "UI_PLACE_HINT_TOUCH" if can_confirm else "UI_PLACE_HINT_MOUSE"
	_placement_label.text = Loc.t(hint_key, {"building_key": BuildingDefs.name_key(building_id)})


# Bấm một lần: nút đổi chữ "Chắc chưa?"; bấm lần nữa trong vài giây mới tải thật.
func _on_load_pressed() -> void:
	if not SaveSystem.has_save():
		EventBus.village_event.emit("TOAST_NO_SAVE", {}, "icons/load")
		return
	if _load_armed > 0.0:
		_load_armed = 0.0
		Commands.load_game()
		return
	_load_armed = LOAD_CONFIRM_SECONDS
	_load_button.text = Loc.t("UI_LOAD_CONFIRM")


func _on_language_changed(_code: String) -> void:
	_refresh_all()
