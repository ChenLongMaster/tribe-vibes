class_name FxLayer
extends Node2D
## Hiệu ứng "juice" vẽ đè lên thế giới, dùng chung mọi chế độ: bụi khi chặt/đập, làn khói
## "bụp", số bay "+3 gỗ" khi đồ vào kho, sao bung ra khi lên cấp. Chỉ NGHE EventBus — lõi
## mô phỏng không biết hiệu ứng trông thế nào.

const DUST_KEY: String = "fx/dust"
const DUST_SETTINGS: Dictionary[StringName, Dictionary] = {
	JobDefs.IMPACT_WOOD: {"color": Color("#D7CCC8"), "count": 4, "spread": 22.0, "size": 0.5},
	JobDefs.IMPACT_STONE: {"color": Color("#EEEEEE"), "count": 5, "spread": 26.0, "size": 0.55},
	JobDefs.IMPACT_POOF: {"color": Color("#FFFFFF"), "count": 9, "spread": 34.0, "size": 0.8},
}
const DUST_LIFE: float = 0.55
const FLOAT_LIFE: float = 1.4
const FLOAT_RISE: float = 46.0
const FLOAT_FONT_SIZE: int = 18
const FLOAT_ICON_SIZE: float = 22.0
const FLOAT_TEXT_COLOR: Color = Color("#FFF8E1")
const OUTLINE_COLOR: Color = Color("#4E342E")
const LEVEL_STAR_COUNT: int = 7
const LEVEL_STAR_DISTANCE: float = 38.0
const LEVEL_LIFE: float = 0.9
const LEVEL_LIFT: Vector2 = Vector2(0, -60)


func _ready() -> void:
	EventBus.work_impact.connect(_on_work_impact)
	EventBus.resource_delivered.connect(_on_resource_delivered)
	EventBus.skill_leveled_up.connect(_on_skill_leveled_up)


func _on_work_impact(pos: Vector2, kind: StringName) -> void:
	var settings: Dictionary = DUST_SETTINGS.get(kind, {})
	if settings.is_empty():
		return
	for i: int in int(settings["count"]):
		var puff: Sprite2D = Sprite2D.new()
		ArtLibrary.setup_sprite(puff, DUST_KEY)
		puff.modulate = settings["color"]
		var base: Vector2 = puff.scale * float(settings["size"]) * randf_range(0.7, 1.2)
		puff.scale = base * 0.4
		puff.position = pos
		add_child(puff)
		var direction: Vector2 = Vector2.from_angle(randf_range(PI * 1.05, TAU * 0.98))
		var tween: Tween = puff.create_tween().set_parallel(true)
		tween.tween_property(puff, "position", pos + direction * float(settings["spread"]) * randf_range(0.6, 1.0), DUST_LIFE).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(puff, "scale", base, DUST_LIFE)
		tween.tween_property(puff, "modulate:a", 0.0, DUST_LIFE).set_ease(Tween.EASE_IN)
		tween.finished.connect(puff.queue_free)


func _on_resource_delivered(resource_id: StringName, amount: int, pos: Vector2) -> void:
	var holder: Node2D = Node2D.new()
	holder.position = pos
	add_child(holder)
	var row: HBoxContainer = HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 2)
	holder.add_child(row)
	var icon: TextureRect = TextureRect.new()
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.texture = ArtLibrary.get_texture(ResourceDefs.icon(resource_id))
	icon.custom_minimum_size = Vector2(FLOAT_ICON_SIZE, FLOAT_ICON_SIZE)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	row.add_child(icon)
	var label: Label = Label.new()
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.text = Loc.t("UI_FLOAT_GAIN", {"amount": Loc.plural(ResourceDefs.count_key(resource_id), amount)})
	label.add_theme_font_size_override("font_size", FLOAT_FONT_SIZE)
	label.add_theme_color_override("font_color", FLOAT_TEXT_COLOR)
	label.add_theme_color_override("font_outline_color", OUTLINE_COLOR)
	label.add_theme_constant_override("outline_size", 6)
	row.add_child(label)
	row.reset_size()
	row.position = -row.size * 0.5
	holder.scale = Vector2(0.6, 0.6)
	var tween: Tween = holder.create_tween().set_parallel(true)
	tween.tween_property(holder, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(holder, "position", pos + Vector2(0, -FLOAT_RISE), FLOAT_LIFE).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(holder, "modulate:a", 0.0, FLOAT_LIFE * 0.4).set_delay(FLOAT_LIFE * 0.6)
	tween.finished.connect(holder.queue_free)


func _on_skill_leveled_up(villager: Node, _skill: StringName, _level: int) -> void:
	var source: Node2D = villager as Node2D
	if source == null:
		return
	var center: Vector2 = source.position + LEVEL_LIFT
	for i: int in LEVEL_STAR_COUNT:
		var star: Sprite2D = Sprite2D.new()
		ArtLibrary.setup_sprite(star, "icons/star")
		var base: Vector2 = star.scale * 0.6
		star.scale = base * 0.3
		star.position = center
		add_child(star)
		var direction: Vector2 = Vector2.from_angle(TAU * i / LEVEL_STAR_COUNT - PI * 0.5)
		var tween: Tween = star.create_tween().set_parallel(true)
		tween.tween_property(star, "position", center + direction * LEVEL_STAR_DISTANCE, LEVEL_LIFE).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(star, "scale", base, LEVEL_LIFE * 0.4)
		tween.tween_property(star, "rotation", PI, LEVEL_LIFE)
		tween.tween_property(star, "modulate:a", 0.0, LEVEL_LIFE * 0.5).set_delay(LEVEL_LIFE * 0.5)
		tween.finished.connect(star.queue_free)
