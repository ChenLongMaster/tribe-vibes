class_name GroundMask
extends Sprite2D
## Lớp đất trơ phủ lên nền cỏ: sân công trình, sân làng và đường mòn (GAME_DESIGN mục 9.1).
## Giữ một ảnh nhỏ, mỗi ô map một điểm ảnh — kênh R = độ mòn đường (World cộng dần khi thổ dân
## đi qua, mờ dần nếu bỏ không), kênh G = sân (cố định theo công trình). Shader ground_mask
## phóng to + nhiễu để vẽ thành mảng đất mềm. Chỉ đổi điểm ảnh rồi cập nhật texture thưa (không
## mỗi frame) nên rất nhẹ.

const SHADER: Shader = preload("res://fx/ground_mask.gdshader")
const NOISE_SIZE: int = 256
## Gom thay đổi lại, cập nhật texture tối đa chừng này giây một lần.
const FLUSH_SECONDS: float = 0.4

var _image: Image
var _texture: ImageTexture
var _size: Vector2i
var _dirty: bool = false
var _flush_timer: float = 0.0


func setup(map_size: Vector2i, noise_seed: int) -> void:
	_size = map_size
	_image = Image.create(map_size.x, map_size.y, false, Image.FORMAT_RG8)
	_image.fill(Color(0, 0, 0))
	_texture = ImageTexture.create_from_image(_image)
	texture = _texture
	centered = false
	scale = Vector2(Balance.TILE_SIZE, Balance.TILE_SIZE)
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var noise: FastNoiseLite = FastNoiseLite.new()
	noise.seed = noise_seed
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 0.03
	var shader_material: ShaderMaterial = ShaderMaterial.new()
	shader_material.shader = SHADER
	shader_material.set_shader_parameter("noise_tex", ImageTexture.create_from_image(noise.get_seamless_image(NOISE_SIZE, NOISE_SIZE)))
	shader_material.set_shader_parameter("map_cells", Vector2(map_size))
	material = shader_material


## Độ mòn đường (0..1) của một ô.
func set_wear(cell: Vector2i, value: float) -> void:
	_set_channel(cell, 0, value)


## Sân (0..1) của một ô.
func set_yard(cell: Vector2i, value: float) -> void:
	_set_channel(cell, 1, value)


func yard_at(cell: Vector2i) -> float:
	return _image.get_pixelv(cell).g if _in_bounds(cell) else 0.0


func clear_yards() -> void:
	for y: int in _size.y:
		for x: int in _size.x:
			var color: Color = _image.get_pixel(x, y)
			if color.g > 0.0:
				_image.set_pixel(x, y, Color(color.r, 0.0, 0.0))
	_dirty = true


## Cập nhật texture ngay (vd lúc dựng map xong).
func flush() -> void:
	if _dirty:
		_texture.update(_image)
		_dirty = false


func _process(delta: float) -> void:
	_flush_timer -= delta
	if _flush_timer <= 0.0:
		_flush_timer = FLUSH_SECONDS
		flush()


func _set_channel(cell: Vector2i, channel: int, value: float) -> void:
	if not _in_bounds(cell):
		return
	var color: Color = _image.get_pixelv(cell)
	if channel == 0:
		color.r = clampf(value, 0.0, 1.0)
	else:
		color.g = clampf(value, 0.0, 1.0)
	_image.set_pixelv(cell, color)
	_dirty = true


func _in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < _size.x and cell.y < _size.y
