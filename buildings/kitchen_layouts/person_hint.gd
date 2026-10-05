@tool
extends Marker2D
## Dân mẫu chỉ trong editor, giữ cỡ thật thay vì phóng theo đồ nội thất.

var _images: Dictionary[String, Texture2D] = {}

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()

func _draw() -> void:
	if not Engine.is_editor_hint() or not get_parent().get_parent().get("show_people"):
		return
	# Triệt tiêu scale nhóm để so với một người lớn cỡ0.65 trong game.
	var size_scale: Vector2 = global_scale.abs()
	var factor: Vector2 = Vector2.ONE * Balance.VILLAGER_SCALE / Vector2(maxf(size_scale.x, 0.001), maxf(size_scale.y, 0.001))
	draw_set_transform(Vector2.ZERO, 0.0, factor)
	for part: Array in [["leg", Vector2(-4, -12)], ["leg", Vector2(5, -12)], ["body_01", Vector2(0, -9)], ["arm", Vector2(-9, -25)], ["arm", Vector2(9, -25)], ["head_01", Vector2(0, -27)], ["face_01_happy", Vector2(0, -27)], ["hair_01", Vector2(0, -27)]]:
		var key: String = "villager/" + str(part[0])
		if not _images.has(key):
			_images[key] = load("res://assets/placeholder/" + key + ".svg") as Texture2D
		var picture: Texture2D = _images[key]
		var size: Vector2 = picture.get_size() * 0.5
		var tint: Color = Color.WHITE
		if str(part[0]) in ["leg", "arm", "head_01"]: tint = Color("#D9A066")
		if str(part[0]) == "body_01": tint = Color("#FFB74D")
		if str(part[0]) == "hair_01": tint = Color("#5D4037")
		draw_texture_rect(picture, Rect2((part[1] as Vector2) - size * ArtSpecs.pivot(key), size), false, tint)
	draw_set_transform(Vector2.ZERO)
