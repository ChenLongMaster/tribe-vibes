extends Node
## Tra hình theo key logic (vd "env/tree_01"). Ưu tiên art thật trong assets/art/,
## không có thì lấy hình tạm trong assets/placeholder/. Nhờ vậy thay art chỉ cần
## bỏ file cùng tên vào assets/art/, không phải sửa code.

## Art được vẽ ở 2× cỡ hiển thị cho nét khi zoom và trên màn hình mật độ cao.
const ART_SCALE: float = 0.5
const ART_DIR: String = "res://assets/art/"
const PLACEHOLDER_DIR: String = "res://assets/placeholder/"
const EXTENSIONS: PackedStringArray = ["png", "webp", "svg"]
const MISSING_SIZE: int = 32
const MISSING_COLOR: Color = Color(1.0, 0.0, 1.0)

var _cache: Dictionary[String, Texture2D] = {}
var _missing_texture: Texture2D


func get_texture(key: String) -> Texture2D:
	if _cache.has(key):
		return _cache[key]
	var texture: Texture2D = _find_in(ART_DIR, key)
	if texture == null:
		texture = _find_in(PLACEHOLDER_DIR, key)
	if texture == null:
		push_warning("ArtLibrary: thiếu hình '%s'" % key)
		texture = _get_missing_texture()
	_cache[key] = texture
	return texture


func has_texture(key: String) -> bool:
	return _find_path(ART_DIR, key) != "" or _find_path(PLACEHOLDER_DIR, key) != ""


## Gắn hình vào Sprite2D theo đúng điểm neo trong ArtSpecs và scale 2× → 1×.
## Gốc toạ độ của sprite sẽ nằm đúng điểm neo (vd chân cây).
func setup_sprite(sprite: Sprite2D, key: String) -> void:
	var texture: Texture2D = get_texture(key)
	sprite.texture = texture
	sprite.centered = false
	sprite.offset = -texture.get_size() * ArtSpecs.pivot(key)
	sprite.scale = Vector2(ART_SCALE, ART_SCALE)


func _find_in(directory: String, key: String) -> Texture2D:
	var path: String = _find_path(directory, key)
	if path.is_empty():
		return null
	return load(path) as Texture2D


func _find_path(directory: String, key: String) -> String:
	for extension: String in EXTENSIONS:
		var path: String = "%s%s.%s" % [directory, key, extension]
		if ResourceLoader.exists(path):
			return path
	return ""


# Ô hồng chói để thấy ngay chỗ nào thiếu hình, nhưng game không bị crash.
func _get_missing_texture() -> Texture2D:
	if _missing_texture == null:
		var image: Image = Image.create(MISSING_SIZE, MISSING_SIZE, false, Image.FORMAT_RGBA8)
		image.fill(MISSING_COLOR)
		_missing_texture = ImageTexture.create_from_image(image)
	return _missing_texture
