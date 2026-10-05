@tool
extends Node2D
## Vùng tránh có cùng cha với hình: kéo/scale nhóm là cả hai đi cùng nhau.

@export var half_size: Vector2 = Vector2(10, 10)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()

func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	var layout: Node = get_parent().get_parent()
	if not layout.get("show_guides"):
		return
	draw_rect(Rect2(-half_size, half_size * 2.0), Color(0.9, 0.3, 0.15, 0.12))
	draw_rect(Rect2(-half_size, half_size * 2.0), Color(0.9, 0.3, 0.15, 0.65), false, 1.0)
