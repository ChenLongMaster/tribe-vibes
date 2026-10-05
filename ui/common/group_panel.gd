extends MarginContainer
## Bảng nhóm khi chọn nhiều thổ dân cùng lúc (kéo khung / Shift+click): "Đang chọn N người"
## và mỗi người một nút nhỏ (icon việc đang làm + tên). Bấm một người thì chọn riêng người đó
## (mở bảng thổ dân). Nằm góc dưới-trái như các bảng khác (không mở cùng lúc).

const REFRESH_SECONDS: float = 0.5
const ICON_SIZE: float = 20.0
const COLUMNS: int = 3
const BUTTON_MIN_HEIGHT: float = 34.0
const CLOSE_BUTTON_SIZE: float = 36.0

var _members: Array[Villager] = []
var _title: Label
var _hint: Label
var _grid: GridContainer
var _refresh_timer: float = 0.0
## Chỉ dựng lại nút khi có gì đổi — dựng lại nút đang bấm dở thì cú bấm bị mất.
var _signature: String = ""


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build()
	visible = false
	EventBus.villagers_selected.connect(_on_villagers_selected)
	Loc.language_changed.connect(_on_language_changed)


func _process(delta: float) -> void:
	if not visible:
		return
	_refresh_timer -= delta
	if _refresh_timer <= 0.0:
		_refresh_timer = REFRESH_SECONDS
		_rebuild()


func _on_language_changed(_code: String) -> void:
	_hint.text = Loc.t("UI_GROUP_HINT")
	_rebuild()


func _on_villagers_selected(villagers: Array) -> void:
	_members.clear()
	for villager: Variant in villagers:
		if villager is Villager:
			_members.append(villager as Villager)
	visible = _members.size() > 1
	_signature = ""
	if visible:
		_rebuild()


func _rebuild() -> void:
	_refresh_timer = REFRESH_SECONDS
	if not visible:
		return
	_title.text = Loc.t("UI_GROUP_TITLE", {"count": Loc.number(_members.size())})
	var parts: PackedStringArray = [Loc.get_language()]
	for villager: Villager in _members:
		if is_instance_valid(villager):
			parts.append("%d:%s" % [villager.id, villager.activity_icon()])
	var signature: String = "|".join(parts)
	if signature == _signature:
		return
	_signature = signature
	for child: Node in _grid.get_children():
		_grid.remove_child(child)
		child.queue_free()
	for villager: Villager in _members:
		if is_instance_valid(villager):
			_grid.add_child(_make_member(villager))


func _make_member(villager: Villager) -> Button:
	var button: Button = Button.new()
	button.text = villager.data.display_name
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size.y = BUTTON_MIN_HEIGHT
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	var icon_key: String = villager.activity_icon()
	if icon_key.is_empty():
		icon_key = NeedDefs.icon_for(NeedDefs.FUN, villager.status.fun)
	button.icon = ArtLibrary.get_texture(icon_key)
	button.expand_icon = false
	button.add_theme_constant_override("icon_max_width", int(ICON_SIZE))
	button.tooltip_text = Loc.t(villager.activity_key(), villager.activity_args())
	button.pressed.connect(func() -> void: EventBus.villager_focus_requested.emit(villager))
	return button


func _build() -> void:
	add_theme_constant_override("margin_left", 10)
	add_theme_constant_override("margin_bottom", 10)
	set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT, Control.PRESET_MODE_MINSIZE)
	grow_vertical = Control.GROW_DIRECTION_BEGIN
	var panel: PanelContainer = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	add_child(panel)
	var column: VBoxContainer = VBoxContainer.new()
	column.add_theme_constant_override("separation", 6)
	panel.add_child(column)
	var header: HBoxContainer = HBoxContainer.new()
	column.add_child(header)
	_title = Label.new()
	_title.theme_type_variation = &"TitleLabel"
	_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(_title)
	var close_button: TextureButton = TextureButton.new()
	close_button.texture_normal = ArtLibrary.get_texture("icons/close")
	close_button.ignore_texture_size = true
	close_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	close_button.custom_minimum_size = Vector2(CLOSE_BUTTON_SIZE, CLOSE_BUTTON_SIZE)
	close_button.pressed.connect(func() -> void: EventBus.deselect_requested.emit())
	header.add_child(close_button)
	_grid = GridContainer.new()
	_grid.columns = COLUMNS
	_grid.add_theme_constant_override("h_separation", 4)
	_grid.add_theme_constant_override("v_separation", 4)
	column.add_child(_grid)
	_hint = Label.new()
	_hint.theme_type_variation = &"SmallLabel"
	_hint.text = Loc.t("UI_GROUP_HINT")
	_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint.custom_minimum_size.x = 300.0
	column.add_child(_hint)
