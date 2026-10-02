class_name PlacementGhost
extends Node2D
## Bóng mờ công trình đang chọn chỗ đặt (chế độ Normal): phủ đúng diện tích, ô xanh = đặt
## được, đỏ = không; hình công trình cấp 1 mờ mờ đứng trên đó. Đặt không được mà vẫn chạm
## thì lắc nhẹ. Chỉ để HIỂN THỊ — kiểm tra chỗ đặt là việc của lõi (Commands.can_place_building).

const OK_FILL: Color = Color(0.55, 0.9, 0.45, 0.35)
const BAD_FILL: Color = Color(0.95, 0.35, 0.3, 0.38)
const OK_LINE: Color = Color("#33691E")
const BAD_LINE: Color = Color("#B71C1C")
const ART_ALPHA: float = 0.6
const SHAKE_SECONDS: float = 0.3

var building_id: StringName = &""
var origin: Vector2i = Vector2i.ZERO
var valid: bool = false

var _sprite: Sprite2D
var _shake: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_sprite = Sprite2D.new()
	_sprite.modulate.a = ART_ALPHA
	add_child(_sprite)
	visible = false


func show_for(id: StringName) -> void:
	building_id = id
	ArtLibrary.setup_sprite(_sprite, BuildingDefs.art(id, 1))
	visible = false


## Dời bóng mờ tới ô gốc mới (trên-trái).
func set_origin(cell: Vector2i, can_place: bool) -> void:
	origin = cell
	valid = can_place
	visible = true
	var footprint: Vector2i = BuildingDefs.footprint(building_id)
	var tile: float = Balance.TILE_SIZE
	_sprite.position = Vector2((cell.x + footprint.x * 0.5) * tile, (cell.y + footprint.y) * tile - Building.FOOT_INSET)
	_sprite.modulate = Color(1, 1, 1, ART_ALPHA) if valid else Color(1, 0.7, 0.7, ART_ALPHA)
	queue_redraw()


func hide_ghost() -> void:
	visible = false
	building_id = &""


## Chạm vào chỗ không đặt được: lắc nhẹ cho người chơi biết.
func shake() -> void:
	_shake = SHAKE_SECONDS


func _process(delta: float) -> void:
	if _shake > 0.0:
		_shake -= delta / maxf(Engine.time_scale, 0.001)
		position.x = sin(_shake * 60.0) * 6.0 * (_shake / SHAKE_SECONDS)
		if _shake <= 0.0:
			position.x = 0.0


func _draw() -> void:
	if building_id == &"":
		return
	var tile: float = Balance.TILE_SIZE
	for cell: Vector2i in BuildingDefs.footprint_cells(building_id, origin):
		var rect: Rect2 = Rect2(Vector2(cell) * tile, Vector2(tile, tile)).grow(-2.0)
		draw_rect(rect, OK_FILL if valid else BAD_FILL)
		draw_rect(rect, OK_LINE if valid else BAD_LINE, false, 2.0)
