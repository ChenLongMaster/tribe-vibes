@tool
extends Sprite2D
## Neo dưới chân để các mảnh ráp ở scene nào cũng dùng cùng kích thước.

@export var art_key: String = ""

func _ready() -> void:
	if not Engine.is_editor_hint():
		ArtLibrary.setup_sprite(self, art_key)
	else:
		for folder: String in ["res://assets/art/", "res://assets/placeholder/"]:
			var found: bool = false
			for extension: String in ["png", "webp", "svg"]:
				var file_path: String = folder + art_key + "." + extension
				if ResourceLoader.exists(file_path):
					texture = load(file_path) as Texture2D
					found = true
					break
			if found:
				break
		if texture == null:
			return
		centered = false
		offset = -texture.get_size() * ArtSpecs.pivot(art_key)
		scale = Vector2(0.5, 0.5)
	if texture != null:
		# Cắt khoảng trong suốt trên Sprite, giữ nguyên hợp đồng file và điểm neo.
		region_rect = texture.get_image().get_used_rect()
		region_enabled = true
		offset += region_rect.position
