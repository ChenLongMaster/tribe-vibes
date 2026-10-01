class_name Fish
extends Node2D
## Một con cá (bóng mờ dưới nước) bơi lững thững trong hồ. Chỉ bơi theo đường thẳng
## nằm trọn trên ô nước, tới nơi thì nghỉ một lát rồi chọn chỗ mới.

const ART_KEY: String = "env/fish_shadow"
const ALPHA: float = 0.45
const SPEED_MIN: float = 18.0 # px/giây
const SPEED_MAX: float = 38.0
const REST_MIN: float = 0.5 # giây
const REST_MAX: float = 2.5
const MIN_TRIP: float = 40.0 # px — bơi ngắn quá trông như đứng yên
const TARGET_JITTER: float = 14.0
const PATH_SAMPLE_STEP: float = 12.0
const TARGET_ATTEMPTS: int = 12
const TURN_SPEED: float = 5.0
const TAIL_SPEED: float = 11.0
const TAIL_ANGLE: float = 0.14

var _map: MapData
var _cells: Array[Vector2i] = []
var _target: Vector2 = Vector2.ZERO
var _speed: float = SPEED_MIN
var _rest: float = 0.0
var _time: float = 0.0
var _heading: float = 0.0
var _sprite: Sprite2D


## `cells`: các ô cá được chọn làm đích (nên là ô giữa hồ, không sát bờ).
func setup(map: MapData, cells: Array[Vector2i], start: Vector2) -> void:
	_map = map
	_cells = cells
	position = start
	_target = start
	_heading = randf() * TAU
	_time = randf() * 10.0
	_rest = randf_range(0.0, REST_MAX)


func _ready() -> void:
	_sprite = Sprite2D.new()
	ArtLibrary.setup_sprite(_sprite, ART_KEY)
	_sprite.modulate = Color(1, 1, 1, ALPHA)
	add_child(_sprite)


func _process(delta: float) -> void:
	_time += delta
	var tail_speed: float = TAIL_SPEED
	if _rest > 0.0:
		_rest -= delta
		tail_speed *= 0.35
		if _rest <= 0.0:
			_pick_target()
	else:
		var to_target: Vector2 = _target - position
		var step: float = _speed * delta
		if to_target.length() <= step:
			position = _target
			_rest = randf_range(REST_MIN, REST_MAX)
		else:
			position += to_target.normalized() * step
			_heading = lerp_angle(_heading, to_target.angle(), 1.0 - exp(-TURN_SPEED * delta))
	# Vẫy đuôi: lắc nhẹ cả thân, lúc nghỉ thì vẫy chậm.
	_sprite.rotation = _heading + sin(_time * tail_speed) * TAIL_ANGLE


func _pick_target() -> void:
	for attempt: int in TARGET_ATTEMPTS:
		var cell: Vector2i = _cells[randi() % _cells.size()]
		var jitter: Vector2 = Vector2(randf_range(-TARGET_JITTER, TARGET_JITTER), randf_range(-TARGET_JITTER, TARGET_JITTER))
		var candidate: Vector2 = WorldGrid.cell_to_world(cell) + jitter
		if position.distance_to(candidate) >= MIN_TRIP and _path_on_water(position, candidate):
			_target = candidate
			_speed = randf_range(SPEED_MIN, SPEED_MAX)
			return
	# Không tìm được đường: nghỉ thêm rồi thử lại.
	_rest = REST_MAX


func _path_on_water(from: Vector2, to: Vector2) -> bool:
	var steps: int = ceili(from.distance_to(to) / PATH_SAMPLE_STEP)
	for i: int in range(steps + 1):
		var point: Vector2 = from.lerp(to, float(i) / maxf(steps, 1))
		if not _map.is_water(WorldGrid.world_to_cell(point)):
			return false
	return true
