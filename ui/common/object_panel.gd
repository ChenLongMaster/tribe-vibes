extends MarginContainer
## Bảng thông tin khi chạm vào một vật thể (không chọn thổ dân): cây, gốc cây, đá tảng, đá nhỏ,
## bụi quả, đống củi, bãi sỏi, chỗ câu cá, con thú. Cho biết: là gì, làm ra gì (mỗi lượt bao
## nhiêu), còn bao nhiêu (thanh lượng — chỉ hiện ở đây, không vẽ trên map), cây non còn bao
## lâu, có cần đồ nghề không (làng có chưa), đang mọc lại / hết chưa, ai đang làm, và cách giao
## việc. Chỉ ĐỌC — không nút bấm nào đổi gì. Nằm góc dưới-trái như các bảng khác
## (không bao giờ mở cùng lúc), tự giãn theo độ dài chữ.

const REFRESH_SECONDS: float = 0.4
const THUMB_SIZE: Vector2 = Vector2(84, 84)
const NAME_FONT_SIZE: int = 24
const ICON_SIZE: float = 22.0
const CLOSE_BUTTON_SIZE: float = 44.0
const INFO_MIN_WIDTH: float = 300.0
const WARNING_COLOR: Color = Color("#C62828")
const HINT_COLOR: Color = Color("#6D4C41")
const AMOUNT_BAR_WIDTH: float = 150.0
const AMOUNT_BAR_HEIGHT: float = 14.0
const AMOUNT_BAR_BACK: Color = Color("#EFE6D6")
const AMOUNT_FULL: Color = Color("#7CB342")
const AMOUNT_HALF: Color = Color("#FFB300")
const AMOUNT_LOW: Color = Color("#E53935")
const ANIMAL_NAME_KEYS: Dictionary[StringName, String] = {&"boar": "ANIMAL_BOAR_NAME", &"deer": "ANIMAL_DEER_NAME"}

var _target: Node2D
var _world: World
var _refresh_timer: float = 0.0
var _thumb: TextureRect
var _name_label: Label
var _desc_label: Label
var _body: VBoxContainer


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build()
	visible = false
	EventBus.object_selected.connect(_on_object_selected)
	EventBus.world_ready.connect(func(world: Node) -> void: _world = world as World)
	Loc.language_changed.connect(func(_code: String) -> void: _refresh())


func _process(delta: float) -> void:
	if not visible:
		return
	if not _is_still_there():
		EventBus.deselect_requested.emit()
		visible = false
		return
	_refresh_timer -= delta
	if _refresh_timer <= 0.0:
		_refresh()


func _on_object_selected(target: Node) -> void:
	_target = target as Node2D
	visible = _target != null
	if visible:
		_refresh()


# Củi đã nhặt, đá đã vỡ, thú đã bị vác đi… thì đóng bảng.
func _is_still_there() -> bool:
	if not is_instance_valid(_target) or not _target.visible:
		return false
	if _target is ResourceNode:
		return not (_target as ResourceNode).is_cleared
	return true


func _refresh() -> void:
	_refresh_timer = REFRESH_SECONDS
	if not _is_still_there():
		return
	for child: Node in _body.get_children():
		_body.remove_child(child)
		child.queue_free()
	if _target is ResourceNode:
		_show_resource(_target as ResourceNode)
	elif _target is Animal:
		_show_animal(_target as Animal)


func _show_resource(node: ResourceNode) -> void:
	_thumb.texture = ArtLibrary.get_texture(node.art_key())
	var key: String = _resource_key(node)
	_name_label.text = Loc.t(key + "_NAME")
	_desc_label.text = Loc.t(key + "_DESC", {"days": Loc.number(roundi(Balance.BUSH_REGROW_DAYS))})
	var job_id: StringName = JobDefs.job_for_target(node)
	if node.kind == MapData.KIND_TREE and node.is_depleted():
		_body.add_child(_icon_text("icons/question", Loc.t("UI_OBJECT_STUMP")))
		return
	_add_gives(job_id)
	if node.kind == MapData.KIND_FISH_SPOT:
		_body.add_child(_icon_text("icons/res_fish", Loc.t("UI_OBJECT_ENDLESS")))
	else:
		_body.add_child(_amount_bar(node, job_id))
	if node.kind == MapData.KIND_BUSH and node.is_depleted():
		_body.add_child(_warning(Loc.t("UI_OBJECT_REGROW", {"time": _time_text(node.regrow_seconds_left())})))
	if not node.is_mature():
		_body.add_child(_warning(Loc.t("UI_OBJECT_YOUNG_TREE", {"time": _time_text(node.grow_seconds_left())}), "icons/res_wood"))
	_add_tool(job_id)
	_add_workers(node)
	if node.can_harvest():
		_body.add_child(_hint(job_id))


# "Thanh máu" của mỏ: còn bao nhiêu (quy ra tài nguyên chung) trên bao nhiêu khi đầy.
func _amount_bar(node: ResourceNode, job_id: StringName) -> Control:
	var item: StringName = JobDefs.get_def(job_id).get("item", &"")
	var left: int = ResourceDefs.item_value(item, node.amount) if item != &"" else node.amount
	var most: int = ResourceDefs.item_value(item, node.capacity) if item != &"" else node.capacity
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	var icon: TextureRect = TextureRect.new()
	icon.texture = ArtLibrary.get_texture(ResourceDefs.icon(ResourceDefs.item_resource(item)) if item != &"" else "icons/star")
	icon.custom_minimum_size = Vector2(ICON_SIZE, ICON_SIZE)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(icon)
	var bar: ProgressBar = ProgressBar.new()
	bar.show_percentage = false
	bar.max_value = maxf(1.0, most)
	bar.value = left
	bar.custom_minimum_size = Vector2(AMOUNT_BAR_WIDTH, AMOUNT_BAR_HEIGHT)
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var back: StyleBoxFlat = StyleBoxFlat.new()
	back.bg_color = AMOUNT_BAR_BACK
	back.border_color = Color("#4E342E")
	back.set_border_width_all(2)
	back.set_corner_radius_all(6)
	var fill: StyleBoxFlat = StyleBoxFlat.new()
	fill.bg_color = _amount_color(node.fraction())
	fill.set_corner_radius_all(6)
	bar.add_theme_stylebox_override("background", back)
	bar.add_theme_stylebox_override("fill", fill)
	row.add_child(bar)
	var label: Label = Label.new()
	label.text = Loc.t("UI_OBJECT_AMOUNT", {"left": Loc.number(left), "max": Loc.number(most)})
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(label)
	return row


func _amount_color(fraction: float) -> Color:
	if fraction > Balance.RESOURCE_STAGE_HALF:
		return AMOUNT_FULL
	if fraction > Balance.RESOURCE_STAGE_LOW:
		return AMOUNT_HALF
	return AMOUNT_LOW


# "3 ngày" khi còn lâu, "45 giây" khi sắp tới.
func _time_text(seconds: float) -> String:
	if seconds >= Balance.DAY_LENGTH_SECONDS:
		return Loc.t("UI_TIME_DAYS", {"count": Loc.number(ceili(seconds / Balance.DAY_LENGTH_SECONDS))})
	return Loc.t("UI_TIME_SECONDS", {"count": Loc.number(ceili(seconds))})


func _show_animal(animal: Animal) -> void:
	_thumb.texture = ArtLibrary.get_texture(animal.art_key())
	_name_label.text = Loc.t(ANIMAL_NAME_KEYS.get(animal.species, "ANIMAL_BOAR_NAME"))
	_desc_label.text = Loc.t("ANIMAL_DESC")
	_add_gives(JobDefs.HUNT)
	_add_tool(JobDefs.HUNT)
	if not animal.is_huntable():
		_body.add_child(_warning(Loc.t("UI_OBJECT_ANIMAL_CAUGHT")))
		return
	_add_workers(animal)
	_body.add_child(_hint(JobDefs.HUNT))


# "Mỗi lượt: 10 gỗ (khúc gỗ)" — quy ra tài nguyên chung, kèm món khuân về.
func _add_gives(job_id: StringName) -> void:
	var def: Dictionary = JobDefs.get_def(job_id)
	var item: StringName = def.get("item", &"")
	if item == &"":
		return
	var resource_id: StringName = ResourceDefs.item_resource(item)
	var value: int = ResourceDefs.item_value(item, int(def.get("amount", 1)))
	var args: Dictionary = {
		"amount": Loc.plural(ResourceDefs.count_key(resource_id), value),
		"item_key": ResourceDefs.item_noun_key(item),
		"seconds": Loc.number(ceili(float(def.get("seconds", 1.0))))}
	# Món trùng tên tài nguyên (đá → đá) thì khỏi nhắc lại.
	var same: bool = Loc.t(ResourceDefs.item_noun_key(item)) == Loc.t(ResourceDefs.noun_key(resource_id))
	_body.add_child(_icon_text(ResourceDefs.icon(resource_id), Loc.t("UI_OBJECT_GIVES_PLAIN" if same else "UI_OBJECT_GIVES", args)))


# Cần đồ nghề gì, làng đang có mấy cái (cả cái đang trong tay thổ dân).
func _add_tool(job_id: StringName) -> void:
	var tool: StringName = JobDefs.required_tool(job_id)
	if tool == &"":
		var held: String = JobDefs.held_art(job_id)
		_body.add_child(_icon_text(held if not held.is_empty() else "icons/skill_gather", Loc.t("UI_OBJECT_BY_HAND")))
		return
	var owned: int = _count_tool(tool)
	var text: String = Loc.t("UI_OBJECT_NEEDS_TOOL", {"tool_key": ToolDefs.name_key(tool)})
	if owned > 0:
		_body.add_child(_icon_text(ToolDefs.icon(tool), text + " " + Loc.t("UI_OBJECT_TOOL_HAVE", {"count": Loc.number(owned)})))
	else:
		_body.add_child(_warning(text + " " + Loc.t("UI_OBJECT_TOOL_NONE"), ToolDefs.icon(tool)))


func _add_workers(target: Node2D) -> void:
	if _world == null:
		return
	var names: PackedStringArray = []
	for villager: Villager in _world.villagers:
		if villager.job != null and villager.job.target == target:
			names.append(villager.data.display_name)
	if names.is_empty():
		return
	var label: Label = Label.new()
	label.text = Loc.t("UI_OBJECT_WORKERS", {"names": ", ".join(names)})
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size.x = INFO_MIN_WIDTH
	_body.add_child(label)


func _count_tool(tool: StringName) -> int:
	if _world == null:
		return 0
	var count: int = 0
	for building: Building in _world.buildings:
		count += building.stock_of(tool)
	for villager: Villager in _world.villagers:
		if villager.tool == tool:
			count += 1
	return count


# Key gốc cho tên + mô tả: OBJECT_TREE, OBJECT_STUMP, OBJECT_ROCK, OBJECT_BUSH…
func _resource_key(node: ResourceNode) -> String:
	if node.kind == MapData.KIND_TREE and node.is_depleted():
		return "OBJECT_STUMP"
	return "OBJECT_" + String(node.kind).to_upper()


func _hint(job_id: StringName) -> Label:
	var label: Label = Label.new()
	label.theme_type_variation = &"SmallLabel"
	label.text = Loc.t("UI_OBJECT_HINT", {"job_key": str(JobDefs.get_def(job_id).get("activity_key", ""))})
	label.add_theme_color_override("font_color", HINT_COLOR)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size.x = INFO_MIN_WIDTH
	return label


func _warning(text: String, icon_key: String = "icons/warning") -> Control:
	var row: HBoxContainer = _icon_text(icon_key, text) as HBoxContainer
	(row.get_child(1) as Label).add_theme_color_override("font_color", WARNING_COLOR)
	return row


func _icon_text(icon_key: String, text: String) -> Control:
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	var icon: TextureRect = TextureRect.new()
	icon.texture = ArtLibrary.get_texture(icon_key)
	icon.custom_minimum_size = Vector2(ICON_SIZE, ICON_SIZE)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(icon)
	var label: Label = Label.new()
	label.text = text
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size.x = INFO_MIN_WIDTH - ICON_SIZE
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
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
	_desc_label = Label.new()
	_desc_label.theme_type_variation = &"SmallLabel"
	_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_desc_label.custom_minimum_size.x = INFO_MIN_WIDTH
	info.add_child(_desc_label)

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
