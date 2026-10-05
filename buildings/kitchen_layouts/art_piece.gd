@tool
extends Sprite2D
## Cắt vùng trong suốt để chọn vật bằng chuột; vẫn dùng file/neo của ArtLibrary.

@export var art_key: String = ""
@export var art_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	var library: Node = get_node_or_null("/root/ArtLibrary")
	if library != null and not Engine.is_editor_hint():
		texture = library.get_texture(art_key)
	else:
		for folder: String in ["res://assets/art/", "res://assets/placeholder/"]:
			for extension: String in ["png", "webp", "svg"]:
				var file_path: String = folder + art_key + "." + extension
				if ResourceLoader.exists(file_path):
					texture = load(file_path) as Texture2D
					break
			if texture != null and texture.resource_path.begins_with("res://assets/art/"):
				break
	if texture == null:
		return
	region_enabled = true
	region_rect = texture.get_image().get_used_rect()
	# Giữ Visible người dùng đã tắt khi thay lớp nguyên khối bằng các mảnh riêng.
	if not region_rect.has_area():
		visible = false
	centered = false
	offset = art_offset + region_rect.position
