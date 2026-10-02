extends MarginContainer
## Thông báo nổi giữa phía trên màn hình ("Bạp đình công!", "Mít lên cấp 2 môn Chặt cây!").
## Nghe EventBus.village_event — lõi chỉ gửi key + tham số, ở đây mới dịch. Nhiều thông
## báo thì xếp chồng, cái cũ nhất tự mờ đi trước. Không chặn chạm vào thế giới.

const MAX_TOASTS: int = 4
const SHOW_SECONDS: float = 3.5
const FADE_SECONDS: float = 0.5
const TOP_MARGIN: int = 104 # chừa chỗ cho thanh HUD phía trên
const ICON_SIZE: float = 26.0

var _column: VBoxContainer


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP, Control.PRESET_MODE_MINSIZE)
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	add_theme_constant_override("margin_top", TOP_MARGIN)
	_column = VBoxContainer.new()
	_column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_column.alignment = BoxContainer.ALIGNMENT_BEGIN
	_column.add_theme_constant_override("separation", 6)
	add_child(_column)
	EventBus.village_event.connect(show_toast)


func show_toast(key: String, args: Dictionary, icon_key: String) -> void:
	while _column.get_child_count() >= MAX_TOASTS:
		var oldest: Node = _column.get_child(0)
		_column.remove_child(oldest)
		oldest.queue_free()
	var panel: PanelContainer = PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var row: HBoxContainer = HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 8)
	panel.add_child(row)
	if not icon_key.is_empty():
		var icon: TextureRect = TextureRect.new()
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.texture = ArtLibrary.get_texture(icon_key)
		icon.custom_minimum_size = Vector2(ICON_SIZE, ICON_SIZE)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(icon)
	var label: Label = Label.new()
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.text = Loc.t(key, args)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(label)
	_column.add_child(panel)
	panel.modulate.a = 0.0
	var tween: Tween = panel.create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, 0.2)
	tween.tween_interval(SHOW_SECONDS)
	tween.tween_property(panel, "modulate:a", 0.0, FADE_SECONDS)
	tween.tween_callback(panel.queue_free)
