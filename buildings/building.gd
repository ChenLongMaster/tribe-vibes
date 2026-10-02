class_name Building
extends Node2D
## Một scene chung cho mọi công trình, dựng theo dữ liệu trong data/buildings.gd.
## Đợt 0 mới có công trình dựng sẵn (hang, lửa trại); móng/xây/hư hại thêm ở Đợt 3.

## Gốc node nằm sát mép dưới footprint (lùi lên một chút) để y-sort đúng với thổ dân.
const FOOT_INSET: float = 12.0
const DEFAULT_FRAME_FPS: float = 8.0
## Phập phồng nhẹ chồng lên các khung hình, để chuyển khung không bị khựng.
const FLICKER_SPEED: float = 9.0
const FLICKER_AMOUNT: float = 0.04
## Phần hình nhô lên trên footprint vẫn tính là chạm trúng công trình.
const HIT_EXTRA_HEIGHT: float = 40.0

var building_id: StringName = &""
var origin_cell: Vector2i = Vector2i.ZERO
var def: Dictionary = {}

var _time: float = 0.0
var _frames: Array[Texture2D] = []
var _frame_fps: float = DEFAULT_FRAME_FPS
var _fx: Node

@onready var _sprite: Sprite2D = $Sprite
@onready var _extra_sprite: Sprite2D = $ExtraSprite


func setup(id: StringName, cell: Vector2i) -> void:
	building_id = id
	origin_cell = cell
	def = BuildingDefs.get_def(id)
	var footprint: Vector2i = BuildingDefs.footprint(id)
	var tile: float = Balance.TILE_SIZE
	position = Vector2((cell.x + footprint.x * 0.5) * tile, (cell.y + footprint.y) * tile - FOOT_INSET)


func _ready() -> void:
	ArtLibrary.setup_sprite(_sprite, def.get("art", ""))
	_setup_extra_art()
	var fx_path: String = def.get("fx_scene", "")
	if not fx_path.is_empty():
		var fx_scene: PackedScene = load(fx_path)
		_fx = fx_scene.instantiate()
		if _fx is Node2D:
			(_fx as Node2D).position = def.get("fx_offset", Vector2.ZERO)
		add_child(_fx)
	# Lệch pha ngẫu nhiên để nhiều đống lửa không nhảy cùng nhịp.
	_time = randf() * 10.0
	set_process(not _frames.is_empty())


## Gắn gió: hình phụ (vd ngọn lửa) nghiêng theo gió, hiệu ứng (tàn lửa) bị gió đẩy.
func set_wind(wind: Wind) -> void:
	if def.get("extra_art_sways", false) and _extra_sprite.visible:
		_extra_sprite.material = wind.sway_material(Wind.Profile.FLAME)
	if _fx != null and _fx.has_method("set_wind"):
		_fx.call("set_wind", wind)


## Chạm trúng công trình không: phủ footprint + phần thân nhô lên phía trên.
func hit_test(world_point: Vector2) -> bool:
	var size: Vector2 = Vector2(BuildingDefs.footprint(building_id)) * Balance.TILE_SIZE
	var bottom: float = position.y + FOOT_INSET
	var rect: Rect2 = Rect2(position.x - size.x * 0.5, bottom - size.y - HIT_EXTRA_HEIGHT, size.x, size.y + HIT_EXTRA_HEIGHT)
	return rect.has_point(world_point)


func footprint_cells() -> Array[Vector2i]:
	return BuildingDefs.footprint_cells(building_id, origin_cell)


func _setup_extra_art() -> void:
	var keys: Array = def.get("extra_art_frames", [])
	_extra_sprite.visible = not keys.is_empty()
	if keys.is_empty():
		return
	for key: String in keys:
		_frames.append(ArtLibrary.get_texture(key))
	ArtLibrary.setup_sprite(_extra_sprite, keys[0])
	_extra_sprite.position = def.get("extra_art_offset", Vector2.ZERO)
	_frame_fps = def.get("extra_art_fps", DEFAULT_FRAME_FPS)


func _process(delta: float) -> void:
	_time += delta
	_extra_sprite.texture = _frames[int(_time * _frame_fps) % _frames.size()]
	var wave: float = sin(_time * FLICKER_SPEED)
	var base: float = ArtLibrary.ART_SCALE
	_extra_sprite.scale = Vector2(base * (1.0 - wave * FLICKER_AMOUNT * 0.5), base * (1.0 + wave * FLICKER_AMOUNT))
