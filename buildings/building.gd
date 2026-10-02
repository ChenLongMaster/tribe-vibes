class_name Building
extends Node2D
## Một scene chung cho mọi công trình, dựng theo dữ liệu trong data/buildings.gd.
## Đợt 0 mới có công trình dựng sẵn (hang, lửa trại, vách đá); móng/xây/hư hại thêm ở Đợt 3.
## Mỗi công trình có kho RIÊNG (`stock`): món chín ở bếp, vũ khí ở lò rèn… — khác với tài
## nguyên chung của làng trong GameState.

signal stock_changed(building: Building)

## Gốc node nằm sát mép dưới footprint (lùi lên một chút) để y-sort đúng với thổ dân.
const FOOT_INSET: float = 12.0
const DEFAULT_FRAME_FPS: float = 8.0
## Phập phồng nhẹ chồng lên các khung hình, để chuyển khung không bị khựng.
const FLICKER_SPEED: float = 9.0
const FLICKER_AMOUNT: float = 0.04
## Phần hình nhô lên trên footprint vẫn tính là chạm trúng công trình.
const HIT_EXTRA_HEIGHT: float = 40.0
const STOCK_ITEM_SCALE: float = 0.8

var building_id: StringName = &""
var origin_cell: Vector2i = Vector2i.ZERO
var def: Dictionary = {}
## Đồ riêng đang cất ở đây: {món: số}.
var stock: Dictionary[StringName, int] = {}

var _time: float = 0.0
var _frames: Array[Texture2D] = []
var _frame_fps: float = DEFAULT_FRAME_FPS
var _fx: Node
## Hình đồ riêng bày quanh công trình: {món: [sprite theo từng chỗ]}.
var _stock_sprites: Dictionary[StringName, Array] = {}

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
	_setup_stock_display()
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


# --- Kho riêng ---

func stock_of(item: StringName) -> int:
	return stock.get(item, 0)


## Cất tối đa bao nhiêu món này (-1 = không giới hạn).
func stock_capacity(item: StringName) -> int:
	return int(def.get("stock_capacity", {}).get(item, -1))


func has_room_for(item: StringName) -> bool:
	var capacity: int = stock_capacity(item)
	return capacity < 0 or stock_of(item) < capacity


## Cất thêm (không vượt sức chứa). Trả về số đã cất được.
func add_stock(item: StringName, amount: int = 1) -> int:
	var capacity: int = stock_capacity(item)
	var added: int = amount if capacity < 0 else clampi(capacity - stock_of(item), 0, amount)
	if added > 0:
		stock[item] = stock_of(item) + added
		_refresh_stock_display()
		stock_changed.emit(self)
	return added


func take_stock(item: StringName, amount: int = 1) -> bool:
	if stock_of(item) < amount:
		return false
	stock[item] = stock_of(item) - amount
	_refresh_stock_display()
	stock_changed.emit(self)
	return true


func _setup_stock_display() -> void:
	var display: Dictionary = def.get("stock_display", {})
	for item: StringName in display:
		var sprites: Array[Sprite2D] = []
		for slot: Vector2 in display[item]["slots"]:
			var sprite: Sprite2D = Sprite2D.new()
			ArtLibrary.setup_sprite(sprite, display[item]["art"])
			sprite.scale *= STOCK_ITEM_SCALE
			sprite.position = slot
			sprite.visible = false
			add_child(sprite)
			sprites.append(sprite)
		_stock_sprites[item] = sprites


func _refresh_stock_display() -> void:
	for item: StringName in _stock_sprites:
		var sprites: Array = _stock_sprites[item]
		for i: int in sprites.size():
			var sprite: Sprite2D = sprites[i]
			var wanted: bool = i < stock_of(item)
			if wanted and not sprite.visible:
				sprite.scale = Vector2.ZERO
				var base: Vector2 = Vector2(ArtLibrary.ART_SCALE, ArtLibrary.ART_SCALE) * STOCK_ITEM_SCALE
				sprite.create_tween().tween_property(sprite, "scale", base, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			sprite.visible = wanted


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
