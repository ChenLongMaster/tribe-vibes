class_name CommandFeedback
extends Node2D
## Phản hồi hình ảnh cho lệnh của người chơi (chế độ Normal), vẽ trên mặt đất:
## - Đường chấm chấm chạy từ thổ dân tới nơi được giao — cho người đang chọn, và trong vài
##   giây sau mỗi lệnh (lệnh xong là bỏ chọn nên đây là phản hồi chính).
## - Vòng vàng dưới mục tiêu: mục tiêu đang rê chuột / đang kéo tới / việc vừa giao.
## - Đường kéo từ thổ dân tới ngón tay khi kéo-thả giao việc.
## - Cắm cờ nhỏ ở chỗ bảo thổ dân đi tới.
## Chỉ ĐỌC thổ dân (đường đi, việc được giao) — không đổi gì trong lõi.

const SHOW_SECONDS: float = 3.0
const DOT_SPACING: float = 18.0
const DOT_RADIUS: float = 3.5
const DOT_OUTLINE: float = 1.5
const DOT_SPEED: float = 28.0 # px/giây — chấm chạy về phía đích cho thấy hướng đi
const DOT_COLOR: Color = Color("#FFF8E1")
const DRAG_DOT_COLOR: Color = Color("#FFEB3B")
const OUTLINE_COLOR: Color = Color("#4E342E")
const DRAG_LIFT: Vector2 = Vector2(0, -30)
const RING_KEY: String = "ui/target_ring"
const MARKER_KEY: String = "ui/move_marker"
const RING_PULSE_SPEED: float = 5.0
const RING_PULSE: float = 0.06
## Cỡ vòng theo loại mục tiêu (1 = cỡ một ô).
const RING_SCALE_TREE: float = 1.1
const RING_SCALE_DEFAULT: float = 1.0
const RING_SCALE_FISH: float = 0.9

var _selected: Villager
## Thổ dân vừa nhận lệnh → số giây còn hiện đường đi.
var _recent: Dictionary[Villager, float] = {}
var _hover_target: Node2D
var _drag_villager: Villager
var _drag_point: Vector2 = Vector2.ZERO
var _drag_target: Node2D
var _ring_texture: Texture2D
var _marker: Sprite2D
var _marker_left: float = 0.0
var _time: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ring_texture = ArtLibrary.get_texture(RING_KEY)
	_marker = Sprite2D.new()
	ArtLibrary.setup_sprite(_marker, MARKER_KEY)
	_marker.visible = false
	add_child(_marker)


func set_selected(villager: Villager) -> void:
	_selected = villager


func show_command(villager: Villager, _target: Node2D) -> void:
	_recent[villager] = SHOW_SECONDS


func show_move(villager: Villager, cell: Vector2i) -> void:
	_recent[villager] = SHOW_SECONDS
	_marker.position = WorldGrid.cell_to_world(cell)
	_marker.visible = true
	_marker.modulate.a = 1.0
	_marker_left = SHOW_SECONDS
	var base: Vector2 = Vector2(ArtLibrary.ART_SCALE, ArtLibrary.ART_SCALE)
	_marker.scale = base * Vector2(1.3, 0.5)
	var tween: Tween = _marker.create_tween()
	tween.tween_property(_marker, "scale", base, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func set_hover_target(target: Node2D) -> void:
	_hover_target = target


func begin_drag(villager: Villager) -> void:
	_drag_villager = villager
	_drag_point = villager.position
	_drag_target = null


func update_drag(point: Vector2, target: Node2D) -> void:
	_drag_point = point
	_drag_target = target


func end_drag() -> void:
	_drag_villager = null
	_drag_target = null


func _process(delta: float) -> void:
	# Chạy theo thời gian thật để tạm dừng vẫn thấy chấm chạy (đang giao việc lúc dừng).
	var real_delta: float = delta / maxf(Engine.time_scale, 0.001)
	_time += real_delta
	for villager: Villager in _recent.keys():
		_recent[villager] -= real_delta
		if _recent[villager] <= 0.0 or not is_instance_valid(villager):
			_recent.erase(villager)
	if _marker.visible:
		_marker_left -= real_delta
		_marker.modulate.a = clampf(_marker_left, 0.0, 1.0)
		_marker.visible = _marker_left > 0.0
	queue_redraw()


func _draw() -> void:
	var shown: Array[Villager] = []
	if is_instance_valid(_selected):
		shown.append(_selected)
	for villager: Villager in _recent:
		if is_instance_valid(villager) and not shown.has(villager):
			shown.append(villager)
	for villager: Villager in shown:
		_draw_dots(villager.remaining_path(), DOT_COLOR)
		if villager.job != null and is_instance_valid(villager.job.target):
			_draw_ring(villager.job.target)
	if is_instance_valid(_hover_target):
		_draw_ring(_hover_target)
	if is_instance_valid(_drag_villager):
		var line: PackedVector2Array = PackedVector2Array([_drag_villager.position + DRAG_LIFT, _drag_point])
		_draw_dots(line, DRAG_DOT_COLOR)
		if is_instance_valid(_drag_target):
			_draw_ring(_drag_target)


# Chấm tròn đều nhau dọc theo đường gấp khúc, trôi dần về phía cuối đường.
func _draw_dots(points: PackedVector2Array, color: Color) -> void:
	if points.size() < 2:
		return
	var carry: float = DOT_SPACING - fmod(_time * DOT_SPEED, DOT_SPACING)
	for i: int in points.size() - 1:
		var from: Vector2 = points[i]
		var to: Vector2 = points[i + 1]
		var length: float = from.distance_to(to)
		var along: float = carry
		while along < length:
			var point: Vector2 = from.lerp(to, along / length)
			draw_circle(point, DOT_RADIUS + DOT_OUTLINE, OUTLINE_COLOR)
			draw_circle(point, DOT_RADIUS, color)
			along += DOT_SPACING
		carry = along - length


func _draw_ring(target: Node2D) -> void:
	if not target.visible:
		return
	var factor: float = RING_SCALE_DEFAULT
	if target is ResourceNode:
		var kind: StringName = (target as ResourceNode).kind
		if kind == MapData.KIND_TREE:
			factor = RING_SCALE_TREE
		elif kind == MapData.KIND_FISH_SPOT:
			factor = RING_SCALE_FISH
	elif target is Building:
		factor = float(BuildingDefs.footprint((target as Building).building_id).x)
	factor *= 1.0 + RING_PULSE * sin(_time * RING_PULSE_SPEED)
	var size: Vector2 = _ring_texture.get_size() * ArtLibrary.ART_SCALE * factor
	draw_texture_rect(_ring_texture, Rect2(target.position - size * 0.5, size), false)
