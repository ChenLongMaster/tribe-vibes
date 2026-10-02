extends MarginContainer
## Bảng thông tin khi chạm vào một thổ dân, xếp gọn để ít che màn hình:
## - Trên: chân dung nhỏ (rig thật đang thở, chớp mắt) | tên + mặt tâm trạng + giới tính,
##   tính cách dạng thẻ nhỏ (giải thích trong tooltip), việc đang làm, việc được giao.
## - Dưới: TRÁI 4 chỉ số xếp dọc (icon + thanh; thể lực là Zzz, giải trí là mặt vui / bình
##   thường / bực bội đỏ mặt) | PHẢI kỹ năng dạng lưới (icon + số cấp; việc thích có khung vàng).
## Không dùng chữ cho chỉ số / kỹ năng — tên đầy đủ nằm trong tooltip.
## Nằm góc dưới-trái, tự giãn theo độ dài chữ.

const REFRESH_SECONDS: float = 0.25
const PORTRAIT_SIZE: Vector2i = Vector2i(72, 84)
const PORTRAIT_FEET: Vector2 = Vector2(36, 79)
const PORTRAIT_SCALE: float = 1.0
const NAME_FONT_SIZE: int = 22
const ICON_SIZE: float = 22.0
const BAR_MIN_SIZE: Vector2 = Vector2(96, 12)
const NEED_ICON_SIZE: float = 20.0
const SKILL_ICON_SIZE: float = 22.0
const SKILL_COLUMNS: int = 4
const SKILL_LEVEL_FONT_SIZE: int = 17
const SKILL_LEVEL_WIDTH: float = 12.0
const SKILL_CELL_PADDING: float = 3.0
const FAVORITE_FILL: Color = Color("#FFF3C4")
const FAVORITE_BORDER: Color = Color("#F9A825")
const NEEDS_BAR_SIZE: Vector2 = Vector2(90, 12)
const TRAIT_CHIP_COLOR: Color = Color("#FFE0B2")
const TRAIT_TEXT_COLOR: Color = Color("#BF6A1F")
const LOW_BAR_COLOR: Color = Color("#E53935")
const BAR_BACKGROUND: Color = Color("#EFE3D3")
const INFO_MIN_WIDTH: float = 230.0
const CLOSE_BUTTON_SIZE: float = 40.0 # đủ to để chạm trên điện thoại

var _villager: Villager
var _refresh_timer: float = 0.0
var _portrait_root: Node2D
var _portrait_rig: VillagerRig
var _name_label: Label
var _mood_icon: TextureRect
var _subtitle_label: Label
var _activity_label: Label
var _job_label: Label
var _traits_box: HFlowContainer
var _need_icons: Dictionary[StringName, TextureRect] = {}
var _need_bars: Dictionary[StringName, ProgressBar] = {}
var _need_fill: Dictionary[StringName, StyleBoxFlat] = {}
var _skills_list: GridContainer


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build()
	visible = false
	EventBus.villager_selected.connect(_on_villager_selected)
	EventBus.skill_leveled_up.connect(_on_skill_leveled_up)
	Loc.language_changed.connect(_on_language_changed)


func _process(delta: float) -> void:
	if not visible:
		return
	if not is_instance_valid(_villager):
		visible = false
		return
	_refresh_timer -= delta
	if _refresh_timer <= 0.0:
		_refresh_timer = REFRESH_SECONDS
		_refresh_live()


func _on_villager_selected(villager: Node) -> void:
	_villager = villager as Villager
	visible = _villager != null
	if not visible:
		return
	if _portrait_rig != null:
		_portrait_rig.queue_free()
	_portrait_rig = VillagerRig.new()
	_portrait_rig.position = PORTRAIT_FEET
	_portrait_rig.scale = Vector2(PORTRAIT_SCALE, PORTRAIT_SCALE)
	_portrait_root.add_child(_portrait_rig)
	_portrait_rig.setup(_villager.data)
	_refresh_static()
	_refresh_live()


# Lên cấp thì vẽ lại sao kỹ năng ngay.
func _on_skill_leveled_up(villager: Node, _skill: StringName, _level: int) -> void:
	if visible and villager == _villager:
		_refresh_static()


func _on_language_changed(_code: String) -> void:
	if visible and is_instance_valid(_villager):
		_refresh_static()
		_refresh_live()


# Phần ít đổi: tên, giới tính, tính cách, kỹ năng.
func _refresh_static() -> void:
	var data: VillagerData = _villager.data
	_name_label.text = data.display_name
	var gender_key: String = "UI_GENDER_FEMALE" if data.gender == VillagerData.Gender.FEMALE else "UI_GENDER_MALE"
	var stage_key: String = "UI_STAGE_" + VillagerData.AgeStage.keys()[data.age_stage]
	_subtitle_label.text = Loc.t("UI_PANEL_SUBTITLE", {"gender": Loc.t(gender_key), "stage": Loc.t(stage_key)})
	for child: Node in _traits_box.get_children():
		child.queue_free()
	for trait_id: StringName in data.traits:
		_traits_box.add_child(_make_trait_chip(trait_id))
	var mode: GameModeConfig = GameState.get_mode()
	for need_id: StringName in NeedDefs.ORDER:
		var shown: bool = mode.need_enabled(need_id)
		_need_icons[need_id].visible = shown
		_need_bars[need_id].visible = shown
		_need_icons[need_id].tooltip_text = Loc.t(NeedDefs.DEFS[need_id]["name_key"])
	for child: Node in _skills_list.get_children():
		child.queue_free()
	for skill_id: StringName in SkillDefs.ORDER:
		_skills_list.add_child(_make_skill_cell(_villager, skill_id))


# Phần đổi liên tục: thanh chỉ số, tâm trạng, việc đang làm.
func _refresh_live() -> void:
	var status: VillagerStatus = _villager.status
	for need_id: StringName in NeedDefs.ORDER:
		var value: float = status.get_need(need_id)
		_need_bars[need_id].value = value
		_need_icons[need_id].texture = ArtLibrary.get_texture(NeedDefs.icon_for(need_id, value))
		# Dưới ngưỡng thì thanh chuyển đỏ cho dễ thấy.
		var low: bool = value < NeedDefs.alert_below(need_id)
		_need_fill[need_id].bg_color = LOW_BAR_COLOR if low else NeedDefs.DEFS[need_id]["color"]
	var mood: float = status.mood()
	var mood_key: String = "happy" if mood >= Balance.MOOD_HAPPY else ("sad" if mood < Balance.MOOD_SAD else "ok")
	_mood_icon.texture = ArtLibrary.get_texture("icons/mood_" + mood_key)
	_mood_icon.tooltip_text = Loc.t("UI_MOOD_" + mood_key.to_upper())
	_activity_label.text = Loc.t("UI_DOING", {"activity": Loc.t(_villager.activity_key(), _villager.activity_args())})
	if _villager.on_strike:
		_job_label.text = Loc.t("UI_PANEL_STRIKE")
	elif _villager.job != null:
		_job_label.text = Loc.t("UI_PANEL_JOB", {"job_key": SkillDefs.name_key(_villager.job.skill)})
	else:
		_job_label.text = Loc.t("UI_PANEL_NO_JOB")
	if _portrait_rig != null:
		_portrait_rig.set_mood_face(mood >= Balance.MOOD_SAD)


# Tính cách dạng thẻ nhỏ một dòng; giải thích nằm trong tooltip cho đỡ chiếm chỗ.
func _make_trait_chip(trait_id: StringName) -> Control:
	var chip: PanelContainer = PanelContainer.new()
	chip.mouse_filter = Control.MOUSE_FILTER_PASS
	chip.tooltip_text = Loc.t(Traits.desc_key(trait_id))
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = TRAIT_CHIP_COLOR
	style.set_corner_radius_all(8)
	style.content_margin_left = 6
	style.content_margin_right = 6
	style.content_margin_top = 0
	style.content_margin_bottom = 1
	chip.add_theme_stylebox_override("panel", style)
	var label: Label = Label.new()
	label.text = Loc.t(Traits.name_key(trait_id))
	label.theme_type_variation = &"SmallLabel"
	label.add_theme_color_override("font_color", TRAIT_TEXT_COLOR)
	chip.add_child(label)
	return chip


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
	header.add_theme_constant_override("separation", 8)
	column.add_child(header)
	header.add_child(_build_portrait())

	var info: VBoxContainer = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.custom_minimum_size.x = INFO_MIN_WIDTH
	info.add_theme_constant_override("separation", 1)
	header.add_child(info)
	var name_row: HBoxContainer = HBoxContainer.new()
	name_row.add_theme_constant_override("separation", 4)
	info.add_child(name_row)
	_name_label = Label.new()
	_name_label.theme_type_variation = &"TitleLabel"
	_name_label.add_theme_font_size_override("font_size", NAME_FONT_SIZE)
	name_row.add_child(_name_label)
	_mood_icon = _make_icon(ICON_SIZE)
	_mood_icon.mouse_filter = Control.MOUSE_FILTER_PASS
	name_row.add_child(_mood_icon)
	_subtitle_label = Label.new()
	_subtitle_label.theme_type_variation = &"SmallLabel"
	_subtitle_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	name_row.add_child(_subtitle_label)
	_traits_box = HFlowContainer.new()
	_traits_box.add_theme_constant_override("h_separation", 4)
	_traits_box.add_theme_constant_override("v_separation", 2)
	info.add_child(_traits_box)
	_activity_label = Label.new()
	_activity_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_child(_activity_label)
	_job_label = Label.new()
	_job_label.theme_type_variation = &"SmallLabel"
	_job_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_child(_job_label)

	var close_button: TextureButton = TextureButton.new()
	close_button.texture_normal = ArtLibrary.get_texture("icons/close")
	close_button.ignore_texture_size = true
	close_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	close_button.custom_minimum_size = Vector2(CLOSE_BUTTON_SIZE, CLOSE_BUTTON_SIZE)
	close_button.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	close_button.pressed.connect(func() -> void: EventBus.deselect_requested.emit())
	header.add_child(close_button)

	# Dưới: chỉ số (trái, xếp dọc) | kỹ năng (phải, dạng lưới).
	var columns: HBoxContainer = HBoxContainer.new()
	columns.add_theme_constant_override("separation", 10)
	column.add_child(columns)
	var needs: VBoxContainer = VBoxContainer.new()
	needs.add_theme_constant_override("separation", 3)
	needs.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	columns.add_child(needs)
	for need_id: StringName in NeedDefs.ORDER:
		var row: HBoxContainer = HBoxContainer.new()
		row.add_theme_constant_override("separation", 4)
		needs.add_child(row)
		var icon: TextureRect = _make_icon(NEED_ICON_SIZE)
		icon.texture = ArtLibrary.get_texture(NeedDefs.icon(need_id))
		icon.mouse_filter = Control.MOUSE_FILTER_PASS
		row.add_child(icon)
		_need_icons[need_id] = icon
		var fill: StyleBoxFlat = StyleBoxFlat.new()
		fill.set_corner_radius_all(6)
		_need_fill[need_id] = fill
		var bar: ProgressBar = _make_bar(fill)
		bar.custom_minimum_size = NEEDS_BAR_SIZE
		row.add_child(bar)
		_need_bars[need_id] = bar
	columns.add_child(VSeparator.new())
	_skills_list = GridContainer.new()
	_skills_list.columns = SKILL_COLUMNS
	_skills_list.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_skills_list.add_theme_constant_override("h_separation", 4)
	_skills_list.add_theme_constant_override("v_separation", 2)
	columns.add_child(_skills_list)


# Mỗi kỹ năng một ô (icon + số cấp). Việc thích thì ô có khung viền vàng + nền vàng nhạt
# (không thêm icon nữa — icon kỹ năng đã đủ, thêm trái tim dễ rối). Ô thường cũng chừa đúng
# lề như vậy để các ô thẳng hàng.
func _make_skill_cell(villager: Villager, skill_id: StringName) -> Control:
	var data: VillagerData = villager.data
	var frame: PanelContainer = PanelContainer.new()
	frame.mouse_filter = Control.MOUSE_FILTER_PASS
	var favorite: bool = data.is_favorite(skill_id)
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.set_corner_radius_all(7)
	style.set_content_margin_all(SKILL_CELL_PADDING)
	style.bg_color = FAVORITE_FILL if favorite else Color(0, 0, 0, 0)
	style.border_color = FAVORITE_BORDER
	style.set_border_width_all(2 if favorite else 0)
	frame.add_theme_stylebox_override("panel", style)
	var cell: HBoxContainer = HBoxContainer.new()
	cell.add_theme_constant_override("separation", 2)
	cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(cell)
	var level: int = villager.skill_level(skill_id)
	var tooltip_key: String = "UI_SKILL_TOOLTIP_FAVORITE" if favorite else "UI_SKILL_TOOLTIP"
	frame.tooltip_text = Loc.t(tooltip_key, {"job": Loc.t(SkillDefs.name_key(skill_id)), "level": Loc.number(level)})
	var icon: TextureRect = _make_icon(SKILL_ICON_SIZE)
	icon.texture = ArtLibrary.get_texture(SkillDefs.icon(skill_id))
	cell.add_child(icon)
	# Cấp kỹ năng bằng số (dễ đọc hơn hàng sao).
	var level_label: Label = Label.new()
	level_label.text = Loc.number(level)
	level_label.custom_minimum_size.x = SKILL_LEVEL_WIDTH
	level_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	level_label.add_theme_font_size_override("font_size", SKILL_LEVEL_FONT_SIZE)
	cell.add_child(level_label)
	return frame


func _build_portrait() -> Control:
	var frame: PanelContainer = PanelContainer.new()
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color("#C5E1A5")
	style.border_color = Color("#4E342E")
	style.set_border_width_all(3)
	style.set_corner_radius_all(14)
	frame.add_theme_stylebox_override("panel", style)
	frame.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	var container: SubViewportContainer = SubViewportContainer.new()
	container.custom_minimum_size = Vector2(PORTRAIT_SIZE)
	container.stretch = true
	frame.add_child(container)
	var viewport: SubViewport = SubViewport.new()
	viewport.transparent_bg = true
	viewport.size = PORTRAIT_SIZE
	container.add_child(viewport)
	_portrait_root = Node2D.new()
	viewport.add_child(_portrait_root)
	return frame


func _make_bar(fill: StyleBoxFlat) -> ProgressBar:
	var bar: ProgressBar = ProgressBar.new()
	bar.custom_minimum_size = BAR_MIN_SIZE
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	bar.show_percentage = false
	bar.max_value = VillagerStatus.MAX_NEED
	var background: StyleBoxFlat = StyleBoxFlat.new()
	background.bg_color = BAR_BACKGROUND
	background.border_color = Color("#4E342E")
	background.set_border_width_all(2)
	background.set_corner_radius_all(6)
	bar.add_theme_stylebox_override("fill", fill)
	bar.add_theme_stylebox_override("background", background)
	return bar


func _make_icon(side: float) -> TextureRect:
	var icon: TextureRect = TextureRect.new()
	icon.custom_minimum_size = Vector2(side, side)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return icon
