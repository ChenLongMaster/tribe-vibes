class_name ShadowLayer
extends Node2D
## Bóng đổ theo mặt trời cho mọi vật (GAME_DESIGN mục 6.2): cây, đá, bụi, công trình, thổ dân,
## thú. Nằm ngay dưới lớp Entities nên bóng luôn nằm trên mặt đất, dưới mọi vật.
## Làm nhẹ cho bản Web — không Light2D/Occluder, chỉ dùng chính hình của vật tô tối:
## - Vật đứng yên (một hình): sprite bóng dùng shader chiếu xuống đất (shadow_project), mọi
##   bóng chung MỘT material nên đổi hướng mặt trời chỉ là đặt một tham số.
## - Vật nhiều mảnh, chuyển động (khung cutout thổ dân, thú): chép từng mảnh sang một node bóng
##   mỗi frame; phép chiếu nằm ở transform của node đó.
## DayNight gọi set_sun() mỗi frame.

const PROJECT_SHADER: Shader = preload("res://fx/shadow_project.gdshader")
const FLAT_SHADER: Shader = preload("res://fx/shadow_flat.gdshader")
## Màu bóng — khớp `shadow_color` trong fx/shadow_project.gdshader.
const SHADOW_COLOR: Color = Color(0.16, 0.1, 0.2)
## Vật đứng yên hiếm khi đổi hình — đồng bộ thưa cho đỡ tốn.
const STATIC_SYNC_SECONDS: float = 0.2

var project_material: ShaderMaterial
var flat_material: ShaderMaterial
var shadow_vec: Vector2 = Vector2(0, -0.3)
var shadow_alpha: float = Balance.SHADOW_ALPHA

## {caster: Node2D, source: Sprite2D, shadow: Sprite2D}
var _static: Array[Dictionary] = []
## {caster: Node2D, sources: Array[Sprite2D], holder: Node2D, shadows: Array[Sprite2D]}
var _dynamic: Array[Dictionary] = []
var _static_timer: float = 0.0
## Dãy vách đá: bóng vẽ bằng đa giác (CliffRidge.draw_shadow), chỉ vẽ lại khi mặt trời đổi đủ nhiều.
var _walls: Array[CliffRidge] = []
var _wall_node: Node2D
var _wall_vec: Vector2 = Vector2.INF
var _wall_alpha: float = -1.0


func _init() -> void:
	project_material = ShaderMaterial.new()
	project_material.shader = PROJECT_SHADER
	flat_material = ShaderMaterial.new()
	flat_material.shader = FLAT_SHADER
	set_sun(shadow_vec, shadow_alpha)


## Hướng + độ dài bóng (px trên đất cho mỗi px chiều cao) và độ đậm.
func set_sun(vec: Vector2, alpha: float) -> void:
	shadow_vec = vec
	shadow_alpha = alpha
	project_material.set_shader_parameter("shadow_vec", vec)
	project_material.set_shader_parameter("shadow_alpha", alpha)
	flat_material.set_shader_parameter("shadow_alpha", alpha)
	visible = alpha > 0.005
	if _wall_node != null and ((vec - _wall_vec).length() * CliffRidge.FACE_HEIGHT > 1.5 or absf(alpha - _wall_alpha) > 0.01):
		_wall_vec = vec
		_wall_alpha = alpha
		_wall_node.queue_redraw()


## Bóng của các dãy vách đá.
func add_walls(ridges: Array[CliffRidge]) -> void:
	_walls.append_array(ridges)
	if _wall_node == null:
		_wall_node = Node2D.new()
		_wall_node.name = "CliffShadows"
		_wall_node.draw.connect(_draw_walls)
		add_child(_wall_node)
	_wall_vec = shadow_vec
	_wall_alpha = shadow_alpha
	_wall_node.queue_redraw()


func _draw_walls() -> void:
	var color: Color = Color(SHADOW_COLOR, shadow_alpha)
	for ridge: CliffRidge in _walls:
		ridge.draw_shadow(_wall_node, shadow_vec, color)


## Vật đứng yên đổ bóng theo hình `source` (con của `caster`, gốc hình = chân).
func add_static(caster: Node2D, source: Sprite2D) -> void:
	var shadow: Sprite2D = Sprite2D.new()
	shadow.material = project_material
	add_child(shadow)
	var entry: Dictionary = {"caster": caster, "source": source, "shadow": shadow}
	_static.append(entry)
	_sync_static(entry)


## Vật nhiều mảnh: mỗi mảnh trong `sources` (con cháu của `caster`) có một bóng riêng.
func add_dynamic(caster: Node2D, sources: Array[Sprite2D]) -> void:
	var holder: Node2D = Node2D.new()
	add_child(holder)
	var shadows: Array[Sprite2D] = []
	for source: Sprite2D in sources:
		var shadow: Sprite2D = Sprite2D.new()
		shadow.material = flat_material
		holder.add_child(shadow)
		shadows.append(shadow)
	_dynamic.append({"caster": caster, "sources": sources, "holder": holder, "shadows": shadows})


func static_count() -> int:
	return _static.size()


func dynamic_count() -> int:
	return _dynamic.size()


func _process(delta: float) -> void:
	if not visible:
		return
	_static_timer -= delta
	if _static_timer <= 0.0:
		_static_timer = STATIC_SYNC_SECONDS
		for entry: Dictionary in _static:
			_sync_static(entry)
	var projection: Transform2D = Transform2D(Vector2(1, 0), -shadow_vec, Vector2.ZERO)
	for entry: Dictionary in _dynamic:
		_sync_dynamic(entry, projection)


func _sync_static(entry: Dictionary) -> void:
	var caster: Node2D = entry["caster"]
	var source: Sprite2D = entry["source"]
	var shadow: Sprite2D = entry["shadow"]
	if not is_instance_valid(caster) or not is_instance_valid(source):
		shadow.visible = false
		return
	shadow.visible = caster.is_visible_in_tree() and source.visible and source.texture != null
	if not shadow.visible:
		return
	shadow.texture = source.texture
	shadow.centered = source.centered
	shadow.offset = source.offset
	shadow.flip_h = source.flip_h
	if source == caster:
		shadow.scale = source.scale
		shadow.position = caster.position
	else:
		shadow.scale = source.scale * caster.scale
		shadow.position = caster.position + source.position * caster.scale


func _sync_dynamic(entry: Dictionary, projection: Transform2D) -> void:
	var caster: Node2D = entry["caster"]
	var holder: Node2D = entry["holder"]
	holder.visible = is_instance_valid(caster) and caster.is_visible_in_tree()
	if not holder.visible:
		return
	var origin: Vector2 = caster.global_position
	holder.transform = Transform2D(projection.x, projection.y, origin)
	var sources: Array = entry["sources"]
	var shadows: Array = entry["shadows"]
	for i: int in sources.size():
		var source: Sprite2D = sources[i]
		var shadow: Sprite2D = shadows[i]
		shadow.visible = source.is_visible_in_tree() and source.texture != null
		if not shadow.visible:
			continue
		var local: Transform2D = source.global_transform
		local.origin -= origin
		shadow.transform = local
		shadow.texture = source.texture
		shadow.centered = source.centered
		shadow.offset = source.offset
		shadow.flip_h = source.flip_h
		shadow.flip_v = source.flip_v
