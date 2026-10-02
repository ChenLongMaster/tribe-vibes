extends MarginContainer
## Bảng thông tin khi chạm vào một thổ dân: chân dung (rig thật đang thở, chớp mắt),
## tên, tính cách kèm giải thích, việc đang làm, 4 chỉ số và kỹ năng. Chỉ số và kỹ năng
## hiển thị bằng ICON + thanh nhỏ / sao (không dùng chữ) — tên đầy đủ nằm trong tooltip.
## Nằm góc dưới-trái, tự giãn theo độ dài chữ.

const REFRESH_SECONDS: float = 0.25
const PORTRAIT_SIZE: Vector2i = Vector2i(104, 112)
const PORTRAIT_FEET: Vector2 = Vector2(52, 104)
const PORTRAIT_SCALE: float = 1.35
const NAME_FONT_SIZE: int = 26
const ICON_SIZE: float = 26.0
const BAR_MIN_SIZE: Vector2 = Vector2(96, 12)
const NEED_ICON_SIZE: float = 22.0
const SKILL_ICON_SIZE: float = 24.0
const SKILL_STAR_SIZE: float = 10.0
const SKILL_HEART_SIZE: float = 14.0
const SKILL_COLUMNS: int = 3
const LOW_BAR_COLOR: Color = Color("#E53935")
const BAR_BACKGROUND: Color = Color("#EFE3D3")
const ACTIVITY_MIN_WIDTH: float = 210.0
const CLOSE_BUTTON_SIZE: float = 44.0 # đủ to để chạm trên điện thoại

var _villager: Villager
var _refresh_timer: float = 0.0
var _portrait_root: Node2D
var _portrait_rig: VillagerRig
var _name_label: Label
var _mood_icon: TextureRect
var _subtitle_label: Label
var _activity_label: Label
var _job_label: Label
var _traits_box: VBoxContainer
var _need_icons: Dictionary[StringName, TextureRect] = {}
var _need_bars: Dictionary[StringName, ProgressBar] = {}
var _need_fill: Dictionary[StringName, StyleBoxFlat] = {}
var _skills_grid: GridContainer


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
		_traits_box.add_child(_make_trait_row(trait_id))
	var mode: GameModeConfig = GameState.get_mode()
	for need_id: StringName in NeedDefs.ORDER:
		var shown: bool = mode.need_enabled(need_id)
		_need_icons[need_id].visible = shown
		_need_bars[need_id].visible = shown
		_need_icons[need_id].tooltip_text = Loc.t(NeedDefs.DEFS[need_id]["name_key"])
	for child: Node in _skills_grid.get_children():
		child.queue_free()
	for skill_id: StringName in SkillDefs.ORDER:
		_skills_grid.add_child(_make_skill_cell(_villager, skill_id))


# Phần đổi liên tục: thanh chỉ số, tâm trạng, việc đang làm.
func _refresh_live() -> void:
	var status: VillagerStatus = _villager.status
	for need_id: StringName in NeedDefs.ORDER:
		var value: float = status.get_need(need_id)
		_need_bars[need_id].value = value
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


func _make_trait_row(trait_id: StringName) -> Control:
	var row: VBoxContainer = VBoxContainer.new()
	row.add_theme_constant_override("separation", 0)
	var name_label: Label = Label.new()
	name_label.text = Loc.t(Traits.name_key(trait_id))
	name_label.add_theme_color_override("font_color", Color("#BF6A1F"))
	row.add_child(name_label)
	var desc_label: Label = Label.new()
	desc_label.text = Loc.t(Traits.desc_key(trait_id))
	desc_label.theme_type_variation = &"SmallLabel"
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	row.add_child(desc_label)
	return row


func _build() -> void:
	add_theme_constant_override("margin_left", 12)
	add_theme_constant_override("margin_bottom", 12)
	set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT, Control.PRESET_MODE_MINSIZE)
	grow_vertical = Control.GROW_DIRECTION_BEGIN

	var panel: PanelContainer = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	add_child(panel)
	var column: VBoxContainer = VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	panel.add_child(column)

	var header: HBoxContainer = HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	column.add_child(header)
	header.add_child(_build_portrait())

	var info: VBoxContainer = VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 2)
	header.add_child(info)
	var name_row: HBoxContainer = HBoxContainer.new()
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
	info.add_child(_subtitle_label)
	_activity_label = Label.new()
	_activity_label.custom_minimum_size.x = ACTIVITY_MIN_WIDTH
	_activity_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_child(_activity_label)
	_job_label = Label.new()
	_job_label.theme_type_variation = &"SmallLabel"
	_job_label.custom_minimum_size.x = ACTIVITY_MIN_WIDTH
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

	_traits_box = VBoxContainer.new()
	_traits_box.add_theme_constant_override("separation", 4)
	column.add_child(_traits_box)

	# 4 chỉ số: icon + thanh nhỏ, hai cặp mỗi hàng.
	var needs: GridContainer = GridContainer.new()
	needs.columns = 4
	needs.add_theme_constant_override("h_separation", 6)
	needs.add_theme_constant_override("v_separation", 6)
	column.add_child(needs)
	for need_id: StringName in NeedDefs.ORDER:
		var icon: TextureRect = _make_icon(NEED_ICON_SIZE)
		icon.texture = ArtLibrary.get_texture(NeedDefs.icon(need_id))
		icon.mouse_filter = Control.MOUSE_FILTER_PASS
		needs.add_child(icon)
		_need_icons[need_id] = icon
		var fill: StyleBoxFlat = StyleBoxFlat.new()
		fill.set_corner_radius_all(6)
		_need_fill[need_id] = fill
		var bar: ProgressBar = _make_bar(fill)
		needs.add_child(bar)
		_need_bars[need_id] = bar

	# Kỹ năng: icon việc + sao cấp + tim nếu là việc thích.
	_skills_grid = GridContainer.new()
	_skills_grid.columns = SKILL_COLUMNS
	_skills_grid.add_theme_constant_override("h_separation", 12)
	_skills_grid.add_theme_constant_override("v_separation", 4)
	column.add_child(_skills_grid)


func _make_skill_cell(villager: Villager, skill_id: StringName) -> Control:
	var data: VillagerData = villager.data
	var cell: HBoxContainer = HBoxContainer.new()
	cell.add_theme_constant_override("separation", 2)
	cell.mouse_filter = Control.MOUSE_FILTER_PASS
	var level: int = villager.skill_level(skill_id)
	var favorite: bool = data.is_favorite(skill_id)
	var tooltip_key: String = "UI_SKILL_TOOLTIP_FAVORITE" if favorite else "UI_SKILL_TOOLTIP"
	cell.tooltip_text = Loc.t(tooltip_key, {"job": Loc.t(SkillDefs.name_key(skill_id)), "level": Loc.number(level)})
	var icon: TextureRect = _make_icon(SKILL_ICON_SIZE)
	icon.texture = ArtLibrary.get_texture(SkillDefs.icon(skill_id))
	cell.add_child(icon)
	var stars: HBoxContainer = HBoxContainer.new()
	stars.add_theme_constant_override("separation", 0)
	stars.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	for i: int in level:
		var star: TextureRect = _make_icon(SKILL_STAR_SIZE)
		star.texture = ArtLibrary.get_texture("icons/star")
		stars.add_child(star)
	cell.add_child(stars)
	if favorite:
		var heart: TextureRect = _make_icon(SKILL_HEART_SIZE)
		heart.texture = ArtLibrary.get_texture("icons/love")
		cell.add_child(heart)
	return cell


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
