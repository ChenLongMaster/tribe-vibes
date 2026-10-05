@tool
extends Node2D
## Scene là nguồn bố cục; root/rào giữ footprint, chỉ chỉnh các nhóm nội thất.

const EXPORT_SIZE: Vector2i = Vector2i(576, 552)
const EXPORT_ORIGIN: Vector2 = Vector2(288, 504)
const EXPORT_FRAME: Rect2 = Rect2(-144, -252, 288, 276)

@export_range(1, 3) var level: int = 1
@export var show_guides: bool = true
@export var show_people: bool = false
@export_tool_button("Export menu / placement PNG") var export_art: Callable = _export_art

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()

func _draw() -> void:
	if not Engine.is_editor_hint() or not show_guides:
		return
	draw_rect(Rect2(-128, -180, 256, 192), Color(0.3, 0.7, 0.3, 0.06))
	draw_rect(EXPORT_FRAME, Color(0.6, 0.6, 0.6, 0.4), false, 1.0)
	for x: int in range(-128, 129, 64):
		draw_line(Vector2(x, -180), Vector2(x, 12), Color(0.3, 0.7, 0.3, 0.4))
	for y: int in range(-180, 13, 64):
		draw_line(Vector2(-128, y), Vector2(128, y), Color(0.3, 0.7, 0.3, 0.4))

func _export_art() -> void:
	if not _fits_frame(self):
		push_warning("Kitchen: artwork exceeds the grey export frame; move/scale the group inside it before exporting.")
		return
	# Xuất bản đang sửa (kể cả chưa lưu), để menu/bóng đặt khớp bố cục cuối.
	var viewport: SubViewport = SubViewport.new()
	viewport.size = EXPORT_SIZE
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)
	var packed: PackedScene = PackedScene.new()
	assert(packed.pack(self) == OK)
	var copy: Node2D = packed.instantiate() as Node2D
	copy.set("show_guides", false)
	copy.set("show_people", false)
	copy.position = EXPORT_ORIGIN
	copy.scale = Vector2(2, 2)
	viewport.add_child(copy)
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var output: String = "res://assets/art/buildings/kitchen_" + str(level) + ".png"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://assets/art/buildings"))
	var result: Error = viewport.get_texture().get_image().save_png(ProjectSettings.globalize_path(output))
	print("Kitchen layout export: ", output, " / ", error_string(result))
	viewport.queue_free()

func _fits_frame(node: Node) -> bool:
	if node is Sprite2D and (node as Sprite2D).visible:
		var sprite: Sprite2D = node as Sprite2D
		var rect: Rect2 = sprite.get_rect()
		var transform_to_root: Transform2D = global_transform.affine_inverse() * sprite.global_transform
		var frame: Rect2 = EXPORT_FRAME.grow(0.1)
		for corner: Vector2 in [rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)]:
			if not frame.has_point(transform_to_root * corner):
				return false
	for child: Node in node.get_children():
		if not _fits_frame(child):
			return false
	return true
