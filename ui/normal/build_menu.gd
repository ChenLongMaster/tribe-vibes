class_name BuildMenu
extends PanelContainer
## Menu xây (chế độ Normal): mỗi công trình một nút — hình, tên, một dòng giải thích, giá cấp 1.
## Chọn một cái thì báo EventBus.placement_requested (controller vào chế độ đặt) rồi đóng menu.
## Vật liệu không trừ lúc đặt — thợ xây khuân từ kho tới — nên luôn chọn được.

const THUMB_SIZE: float = 56.0
const COST_ICON_SIZE: float = 18.0
const ROW_MIN_WIDTH: float = 280.0
## Hai cột cho menu khỏi cao quá màn hình (khung hình ngang).
const COLUMNS: int = 2

var _rows: VBoxContainer


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	_rows = VBoxContainer.new()
	_rows.add_theme_constant_override("separation", 6)
	add_child(_rows)
	Loc.language_changed.connect(func(_code: String) -> void: _rebuild())
	_rebuild()
	visible = false


func toggle() -> void:
	visible = not visible


func _rebuild() -> void:
	for child: Node in _rows.get_children():
		child.queue_free()
	var title: Label = Label.new()
	title.theme_type_variation = &"TitleLabel"
	title.text = Loc.t("UI_BUILD_MENU_TITLE")
	_rows.add_child(title)
	var grid: GridContainer = GridContainer.new()
	grid.columns = COLUMNS
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	_rows.add_child(grid)
	for building_id: StringName in BuildingDefs.MENU_ORDER:
		grid.add_child(_make_row(building_id))


func _make_row(building_id: StringName) -> Control:
	var button: Button = Button.new()
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size.x = ROW_MIN_WIDTH
	button.pressed.connect(func() -> void:
		visible = false
		EventBus.placement_requested.emit(building_id))
	var margin: MarginContainer = MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for side: String in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		margin.add_theme_constant_override(side, 6)
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	button.add_child(margin)
	var row: HBoxContainer = HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 10)
	margin.add_child(row)
	var thumb: TextureRect = _icon(BuildingDefs.art(building_id, 1), THUMB_SIZE)
	row.add_child(thumb)
	var info: VBoxContainer = VBoxContainer.new()
	info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info.add_theme_constant_override("separation", 0)
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(info)
	var name_label: Label = Label.new()
	name_label.text = Loc.t(BuildingDefs.name_key(building_id))
	info.add_child(name_label)
	var desc: Label = Label.new()
	desc.theme_type_variation = &"SmallLabel"
	desc.text = Loc.t(BuildingDefs.desc_key(building_id))
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.custom_minimum_size.x = ROW_MIN_WIDTH - THUMB_SIZE - 40.0
	info.add_child(desc)
	var cost_row: HBoxContainer = HBoxContainer.new()
	cost_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cost_row.add_theme_constant_override("separation", 4)
	var cost: Dictionary = BuildingDefs.cost(building_id, 1)
	for resource_id: StringName in ResourceDefs.ORDER:
		if not cost.has(resource_id):
			continue
		cost_row.add_child(_icon(ResourceDefs.icon(resource_id), COST_ICON_SIZE))
		var amount: Label = Label.new()
		amount.text = Loc.number(int(cost[resource_id]))
		cost_row.add_child(amount)
	var size_label: Label = Label.new()
	size_label.theme_type_variation = &"SmallLabel"
	var footprint: Vector2i = BuildingDefs.footprint(building_id)
	size_label.text = Loc.t("UI_BUILD_SIZE", {"w": footprint.x, "h": footprint.y})
	cost_row.add_child(size_label)
	info.add_child(cost_row)
	# Nút phải cao đủ chứa nội dung (Button không tự giãn theo con).
	button.custom_minimum_size.y = THUMB_SIZE + 12.0
	margin.minimum_size_changed.connect(func() -> void:
		button.custom_minimum_size.y = maxf(THUMB_SIZE, margin.get_combined_minimum_size().y))
	return button


func _icon(key: String, side: float) -> TextureRect:
	var icon: TextureRect = TextureRect.new()
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.texture = ArtLibrary.get_texture(key)
	icon.custom_minimum_size = Vector2(side, side)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return icon
