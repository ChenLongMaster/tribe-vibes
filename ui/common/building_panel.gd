extends MarginContainer
## Bảng công trình khi chạm vào một công trình (không chọn thổ dân): tên, cấp (sao), đang xây
## tới đâu (vật liệu + thanh tiến độ + số thợ), người phụ trách (hoặc cảnh báo thiếu người),
## chỗ ngủ, sức chứa, đồ đang cất, đơn rèn (−/+), nút nâng cấp và nút huỷ móng / huỷ nâng cấp.
## Chỉ ĐỌC công trình; mọi nút bấm đi qua Commands. Nằm góc dưới-trái (cùng chỗ bảng thổ dân,
## hai bảng không bao giờ mở cùng lúc), tự giãn theo độ dài chữ.

const REFRESH_SECONDS: float = 0.4
const THUMB_SIZE: Vector2 = Vector2(84, 84)
const NAME_FONT_SIZE: int = 24
const ICON_SIZE: float = 22.0
const STAR_SIZE: float = 16.0
const BUTTON_MIN_HEIGHT: float = 44.0 # đủ to để chạm trên điện thoại
const CLOSE_BUTTON_SIZE: float = 44.0
const BAR_MIN_SIZE: Vector2 = Vector2(150, 12)
const INFO_MIN_WIDTH: float = 240.0
const WARNING_COLOR: Color = Color("#C62828")
const HINT_COLOR: Color = Color("#6D4C41")
const MATERIAL_COLOR: Color = Color("#A1887F")
const BUILD_COLOR: Color = Color("#FFD54F")

var _building: Building
var _refresh_timer: float = 0.0
var _thumb: TextureRect
var _name_label: Label
var _stars: HBoxContainer
var _status_label: Label
var _body: VBoxContainer
var _buttons: HBoxContainer
## Chỉ dựng lại phần nào thật sự đổi — dựng lại nút đang bấm dở thì cú bấm bị mất.
var _body_signature: String = ""
var _buttons_signature: String = ""


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build()
	visible = false
	EventBus.building_selected.connect(_on_building_selected)
	Loc.language_changed.connect(func(_code: String) -> void: _refresh())


func _process(delta: float) -> void:
	if not visible:
		return
	if not is_instance_valid(_building) or _building.demolished:
		_show(null)
		return
	_refresh_timer -= delta
	if _refresh_timer <= 0.0:
		_refresh()


func _on_building_selected(building: Node) -> void:
	_show(building as Building)


func _show(building: Building) -> void:
	if is_instance_valid(_building) and _building.changed.is_connected(_on_building_changed):
		_building.changed.disconnect(_on_building_changed)
		_building.stock_changed.disconnect(_on_building_changed)
	_building = building
	_body_signature = ""
	_buttons_signature = ""
	visible = building != null
	if building == null:
		return
	building.changed.connect(_on_building_changed)
	building.stock_changed.connect(_on_building_changed)
	_refresh()


func _on_building_changed(_changed: Building) -> void:
	_refresh_timer = 0.0


# Vẽ lại toàn bộ — bảng nhỏ, vẽ lại vài lần mỗi giây không đáng kể.
func _refresh() -> void:
	_refresh_timer = REFRESH_SECONDS
	if not is_instance_valid(_building):
		return
	var b: Building = _building
	var art_level: int = maxi(b.level, 1) if not b.is_foundation() else b.target_level()
	_thumb.texture = ArtLibrary.get_texture(BuildingDefs.art(b.building_id, art_level))
	_thumb.modulate.a = 0.55 if b.is_foundation() else 1.0
	_name_label.text = Loc.t(b.name_key())
	_refresh_stars(b)
	_status_label.text = _status_text(b)
	var body_signature: String = _signature_body(b)
	if body_signature != _body_signature:
		_body_signature = body_signature
		_rebuild_body(b)
	var buttons_signature: String = var_to_str([b.level, b.can_upgrade(), b.is_constructing(), b.is_foundation(), Loc.get_language()])
	if buttons_signature != _buttons_signature:
		_buttons_signature = buttons_signature
		_refresh_buttons(b)


func _signature_body(b: Building) -> String:
	var staff_names: PackedStringArray = []
	for villager: Villager in b.staff:
		if is_instance_valid(villager):
			staff_names.append(villager.data.display_name)
	var sleeper_names: PackedStringArray = []
	for villager: Villager in b.sleepers:
		sleeper_names.append(villager.data.display_name)
	var have: Array[bool] = []
	for resource_id: StringName in ResourceDefs.ORDER:
		have.append(GameState.get_amount(resource_id) > 0)
	return var_to_str([b.level, b.construction, b.builders.size(), staff_names, sleeper_names, b.stock, b.orders,
			have, Loc.get_language()])


func _rebuild_body(b: Building) -> void:
	for child: Node in _body.get_children():
		_body.remove_child(child)
		child.queue_free()
	if b.is_constructing():
		_add_construction(b)
	if b.is_built():
		_add_staff(b)
		_add_sleep(b)
		_add_storage(b)
		_add_stock(b)
		_add_forge(b)
		_add_dance(b)


func _status_text(b: Building) -> String:
	if b.is_foundation():
		return Loc.t("UI_BUILDING_FOUNDATION" if b.builders.is_empty() else "UI_BUILDING_BUILDING")
	if b.is_constructing():
		return Loc.t("UI_BUILDING_UPGRADING", {"level": Loc.number(b.target_level())})
	var desc: String = BuildingDefs.desc_key(b.building_id)
	return Loc.t(desc) if not desc.is_empty() else ""


func _refresh_stars(b: Building) -> void:
	for child: Node in _stars.get_children():
		child.queue_free()
	if b.max_level() <= 1:
		return
	for i: int in b.max_level():
		var star: TextureRect = _make_icon("icons/star", STAR_SIZE)
		star.modulate = Color.WHITE if i < b.level else Color(0.35, 0.3, 0.3, 0.35)
		_stars.add_child(star)
	_stars.tooltip_text = Loc.t("UI_BUILDING_LEVEL", {"level": Loc.number(b.level), "max": Loc.number(b.max_level())})


# Vật liệu đã đổ / cần, thanh gõ búa, số thợ xây.
func _add_construction(b: Building) -> void:
	var cost: Dictionary = b.construction_cost()
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	for resource_id: StringName in ResourceDefs.ORDER:
		if not cost.has(resource_id):
			continue
		row.add_child(_icon_text(ResourceDefs.icon(resource_id),
				Loc.t("UI_AMOUNT_OF", {"amount": Loc.number(b.delivered(resource_id)), "total": Loc.number(int(cost[resource_id]))})))
	_body.add_child(row)
	_body.add_child(_bar_row("icons/res_wood", b.materials_fraction(), MATERIAL_COLOR, "UI_BUILDING_MATERIALS"))
	_body.add_child(_bar_row("icons/skill_build", b.build_progress(), BUILD_COLOR, "UI_BUILDING_PROGRESS"))
	var builders: Label = Label.new()
	builders.text = Loc.t("UI_BUILDING_BUILDERS", {
		"count": Loc.number(b.builders.size()), "max": Loc.number(BuildingDefs.max_builders(b.building_id))})
	_body.add_child(builders)
	if b.builders.is_empty():
		_body.add_child(_hint("UI_BUILDING_HINT_BUILD"))
	elif not b.materials_complete():
		for resource_id: StringName in cost:
			if b.material_missing(resource_id) > 0 and GameState.get_amount(resource_id) <= 0:
				_body.add_child(_warning(Loc.t("UI_BUILDING_NEED_MATERIAL", {"resource_key": ResourceDefs.noun_key(resource_id)})))
				break


func _add_staff(b: Building) -> void:
	if b.staff_job() == &"":
		return
	var names: PackedStringArray = []
	for villager: Villager in b.staff:
		if is_instance_valid(villager):
			names.append(villager.data.display_name)
	var label: Label = Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size.x = INFO_MIN_WIDTH
	label.text = Loc.t("UI_BUILDING_STAFF", {
		"job_key": SkillDefs.name_key(JobDefs.skill_of(b.staff_job())),
		"names": ", ".join(names) if not names.is_empty() else "—",
		"count": Loc.number(names.size()), "max": Loc.number(b.staff_capacity())})
	_body.add_child(label)
	if b.needs_staff():
		_body.add_child(_warning(Loc.t("UI_BUILDING_NO_STAFF")))
	if names.is_empty():
		_body.add_child(_hint("UI_BUILDING_HINT_STAFF"))


func _add_sleep(b: Building) -> void:
	if b.sleep_slots() <= 0:
		return
	var names: PackedStringArray = []
	for villager: Villager in b.sleepers:
		names.append(villager.data.display_name)
	_body.add_child(_icon_text("icons/sleepy", Loc.t("UI_BUILDING_BEDS", {
		"used": Loc.number(b.sleepers.size()), "max": Loc.number(b.sleep_slots()),
		"rate": Loc.number(float(b.prop("sleep_rate", 1.0)))})))
	if not names.is_empty():
		var label: Label = Label.new()
		label.theme_type_variation = &"SmallLabel"
		label.text = Loc.t("UI_BUILDING_SLEEPING", {"names": ", ".join(names)})
		_body.add_child(label)
	_body.add_child(_hint("UI_BUILDING_HINT_SLEEP"))


# Kho chung: công trình này góp bao nhiêu chỗ, cả làng đang có bao nhiêu / sức chứa.
func _add_storage(b: Building) -> void:
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	for resource_id: StringName in ResourceDefs.ORDER:
		var own: int = b.storage_capacity(resource_id)
		if own <= 0:
			continue
		row.add_child(_icon_text(ResourceDefs.icon(resource_id), Loc.t("UI_BUILDING_HOLDS", {"amount": Loc.number(own)})))
	if row.get_child_count() == 0:
		row.queue_free()
		return
	var title: Label = Label.new()
	title.theme_type_variation = &"SmallLabel"
	title.text = Loc.t("UI_BUILDING_STORAGE")
	_body.add_child(title)
	_body.add_child(row)


func _add_stock(b: Building) -> void:
	var capacity: int = b.stock_capacity(ResourceDefs.MEAL)
	if capacity <= 0:
		return
	_body.add_child(_icon_text(ResourceDefs.icon(ResourceDefs.MEAL), Loc.t("UI_BUILDING_MEALS", {
		"amount": Loc.number(b.stock_of(ResourceDefs.MEAL)), "max": Loc.number(capacity)})))


# Lò rèn: mỗi món một hàng — icon, tên, đang có / chứa tối đa, giá, nút −/+ đặt số muốn rèn.
func _add_forge(b: Building) -> void:
	if not b.def.get("forge", false):
		return
	var title: Label = Label.new()
	title.theme_type_variation = &"SmallLabel"
	title.text = Loc.t("UI_FORGE_ORDERS")
	_body.add_child(title)
	for tool: StringName in ToolDefs.ORDER:
		var row: HBoxContainer = HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		row.add_child(_make_icon(ToolDefs.icon(tool), ICON_SIZE + 6.0))
		var info: VBoxContainer = VBoxContainer.new()
		info.add_theme_constant_override("separation", 0)
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var name_label: Label = Label.new()
		name_label.text = Loc.t("UI_FORGE_TOOL", {"tool_key": ToolDefs.name_key(tool),
				"have": Loc.number(b.stock_of(tool)), "max": Loc.number(b.stock_capacity(tool))})
		info.add_child(name_label)
		var cost_row: HBoxContainer = HBoxContainer.new()
		cost_row.add_theme_constant_override("separation", 6)
		var cost: Dictionary = ToolDefs.cost(tool)
		for resource_id: StringName in cost:
			cost_row.add_child(_icon_text(ResourceDefs.icon(resource_id), Loc.number(int(cost[resource_id])), 16.0))
		info.add_child(cost_row)
		row.add_child(info)
		var uid: int = b.uid
		var count: int = b.order_count(tool)
		row.add_child(_small_button("UI_MINUS", func() -> void: Commands.set_forge_order(uid, tool, count - 1)))
		var order_label: Label = Label.new()
		order_label.text = Loc.number(count)
		order_label.custom_minimum_size.x = 28.0
		order_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		order_label.tooltip_text = Loc.t("UI_FORGE_ORDER_TOOLTIP")
		order_label.mouse_filter = Control.MOUSE_FILTER_PASS
		row.add_child(order_label)
		row.add_child(_small_button("UI_PLUS", func() -> void: Commands.set_forge_order(uid, tool, count + 1)))
		_body.add_child(row)


func _add_dance(b: Building) -> void:
	var dancers: int = int(b.prop("dancers", 0))
	if dancers <= 0:
		return
	_body.add_child(_icon_text("icons/happy", Loc.t("UI_BUILDING_DANCERS", {"count": Loc.number(dancers)})))
	_body.add_child(_hint("UI_BUILDING_HINT_DANCE"))


func _refresh_buttons(b: Building) -> void:
	for child: Node in _buttons.get_children():
		_buttons.remove_child(child)
		child.queue_free()
	var uid: int = b.uid
	if b.can_upgrade():
		var upgrade: Button = _make_button(Loc.t("UI_BUILDING_UPGRADE", {"level": Loc.number(b.level + 1)}), "icons/upgrade")
		var cost_parts: PackedStringArray = []
		var cost: Dictionary = BuildingDefs.cost(b.building_id, b.level + 1)
		for resource_id: StringName in cost:
			cost_parts.append(Loc.plural(ResourceDefs.count_key(resource_id), int(cost[resource_id])))
		upgrade.tooltip_text = Loc.t("UI_BUILDING_UPGRADE_COST", {"cost": ", ".join(cost_parts)})
		upgrade.pressed.connect(func() -> void: Commands.upgrade_building(uid))
		_buttons.add_child(upgrade)
		_buttons.add_child(_cost_box(cost))
	if b.is_constructing():
		var key: String = "UI_BUILDING_CANCEL_FOUNDATION" if b.is_foundation() else "UI_BUILDING_CANCEL_UPGRADE"
		var cancel: Button = _make_button(Loc.t(key), "icons/close")
		cancel.tooltip_text = Loc.t("UI_BUILDING_CANCEL_TOOLTIP")
		cancel.pressed.connect(func() -> void: Commands.cancel_construction(uid))
		_buttons.add_child(cancel)
	_buttons.visible = _buttons.get_child_count() > 0


# --- Dựng khung ---

func _build() -> void:
	add_theme_constant_override("margin_left", 12)
	add_theme_constant_override("margin_bottom", 12)
	set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT, Control.PRESET_MODE_MINSIZE)
	grow_vertical = Control.GROW_DIRECTION_BEGIN
	var panel: PanelContainer = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	add_child(panel)
	var column: VBoxContainer = VBoxContainer.new()
	column.add_theme_constant_override("separation", 6)
	panel.add_child(column)

	var header: HBoxContainer = HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	column.add_child(header)
	var frame: PanelContainer = PanelContainer.new()
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color("#C5E1A5")
	style.border_color = Color("#4E342E")
	style.set_border_width_all(3)
	style.set_corner_radius_all(14)
	style.set_content_margin_all(4)
	frame.add_theme_stylebox_override("panel", style)
	frame.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	_thumb = TextureRect.new()
	_thumb.custom_minimum_size = THUMB_SIZE
	_thumb.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_thumb.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	frame.add_child(_thumb)
	header.add_child(frame)

	var info: VBoxContainer = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 2)
	header.add_child(info)
	_name_label = Label.new()
	_name_label.theme_type_variation = &"TitleLabel"
	_name_label.add_theme_font_size_override("font_size", NAME_FONT_SIZE)
	info.add_child(_name_label)
	_stars = HBoxContainer.new()
	_stars.add_theme_constant_override("separation", 2)
	_stars.mouse_filter = Control.MOUSE_FILTER_PASS
	info.add_child(_stars)
	_status_label = Label.new()
	_status_label.theme_type_variation = &"SmallLabel"
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status_label.custom_minimum_size.x = INFO_MIN_WIDTH
	info.add_child(_status_label)

	var close_button: TextureButton = TextureButton.new()
	close_button.texture_normal = ArtLibrary.get_texture("icons/close")
	close_button.ignore_texture_size = true
	close_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	close_button.custom_minimum_size = Vector2(CLOSE_BUTTON_SIZE, CLOSE_BUTTON_SIZE)
	close_button.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	close_button.pressed.connect(func() -> void: EventBus.deselect_requested.emit())
	header.add_child(close_button)

	_body = VBoxContainer.new()
	_body.add_theme_constant_override("separation", 4)
	column.add_child(_body)
	_buttons = HBoxContainer.new()
	_buttons.add_theme_constant_override("separation", 8)
	column.add_child(_buttons)


func _bar_row(icon_key: String, fraction: float, color: Color, tooltip_key: String) -> Control:
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	row.tooltip_text = Loc.t(tooltip_key)
	row.mouse_filter = Control.MOUSE_FILTER_PASS
	row.add_child(_make_icon(icon_key, ICON_SIZE))
	var bar: ProgressBar = ProgressBar.new()
	bar.custom_minimum_size = BAR_MIN_SIZE
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	bar.show_percentage = false
	bar.max_value = 1.0
	bar.value = fraction
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fill: StyleBoxFlat = StyleBoxFlat.new()
	fill.bg_color = color
	fill.set_corner_radius_all(6)
	var background: StyleBoxFlat = StyleBoxFlat.new()
	background.bg_color = Color("#EFE3D3")
	background.border_color = Color("#4E342E")
	background.set_border_width_all(2)
	background.set_corner_radius_all(6)
	bar.add_theme_stylebox_override("fill", fill)
	bar.add_theme_stylebox_override("background", background)
	row.add_child(bar)
	return row


func _cost_box(cost: Dictionary) -> Control:
	var box: HBoxContainer = HBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	for resource_id: StringName in ResourceDefs.ORDER:
		if cost.has(resource_id):
			box.add_child(_icon_text(ResourceDefs.icon(resource_id), Loc.number(int(cost[resource_id]))))
	return box


func _icon_text(icon_key: String, text: String, icon_size: float = ICON_SIZE) -> Control:
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	row.add_child(_make_icon(icon_key, icon_size))
	var label: Label = Label.new()
	label.text = text
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(label)
	return row


func _hint(key: String) -> Label:
	var label: Label = Label.new()
	label.theme_type_variation = &"SmallLabel"
	label.text = Loc.t(key)
	label.add_theme_color_override("font_color", HINT_COLOR)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size.x = INFO_MIN_WIDTH
	return label


func _warning(text: String) -> Control:
	var row: HBoxContainer = _icon_text("icons/warning", text) as HBoxContainer
	var label: Label = row.get_child(1) as Label
	label.add_theme_color_override("font_color", WARNING_COLOR)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size.x = INFO_MIN_WIDTH - ICON_SIZE
	return row


func _make_button(text: String, icon_key: String) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.icon = ArtLibrary.get_texture(icon_key)
	button.expand_icon = false
	button.add_theme_constant_override("icon_max_width", 24)
	button.custom_minimum_size.y = BUTTON_MIN_HEIGHT
	button.focus_mode = Control.FOCUS_NONE
	return button


func _small_button(key: String, on_press: Callable) -> Button:
	var button: Button = Button.new()
	button.text = Loc.t(key)
	button.custom_minimum_size = Vector2(BUTTON_MIN_HEIGHT, BUTTON_MIN_HEIGHT)
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(on_press)
	return button


func _make_icon(key: String, side: float) -> TextureRect:
	var icon: TextureRect = TextureRect.new()
	icon.texture = ArtLibrary.get_texture(key)
	icon.custom_minimum_size = Vector2(side, side)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return icon
