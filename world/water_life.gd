class_name WaterLife
extends Node2D
## Sự sống trên mặt hồ: gợn sóng nhỏ hiện lên rồi trôi theo gió, và vài con cá
## bơi lượn dưới nước. Gió càng mạnh gợn sóng càng nhiều.

const RIPPLE_KEY: String = "env/ripple"
const FISH_PER_WATER_CELLS: int = 12
const FISH_MIN: int = 2
const FISH_MAX: int = 6
const RIPPLE_MAX: int = 18
const RIPPLE_INTERVAL: float = 0.4 # giây giữa hai gợn sóng khi gió vừa
const RIPPLE_LIFE_MIN: float = 2.2
const RIPPLE_LIFE_MAX: float = 3.6
const RIPPLE_ALPHA: float = 0.75
const RIPPLE_DRIFT: float = 18.0 # px trôi theo gió trong một đời gợn sóng
const RIPPLE_JITTER: float = 20.0

var _map: MapData
var _wind: Wind
var _water_cells: Array[Vector2i] = []
## Ô nước có 4 phía đều là nước — gợn sóng và cá ở đây không lấn lên bờ.
var _open_cells: Array[Vector2i] = []
var _ripple_count: int = 0
var _spawn_timer: float = 0.0


func setup(map: MapData, wind: Wind) -> void:
	_map = map
	_wind = wind
	for y: int in map.size.y:
		for x: int in map.size.x:
			var cell: Vector2i = Vector2i(x, y)
			if not map.is_water(cell):
				continue
			_water_cells.append(cell)
			if _is_open_water(cell):
				_open_cells.append(cell)
	if _open_cells.is_empty():
		_open_cells = _water_cells.duplicate()
	if _open_cells.is_empty():
		set_process(false)
		return
	var fish_total: int = clampi(floori(_water_cells.size() / float(FISH_PER_WATER_CELLS)), FISH_MIN, FISH_MAX)
	for i: int in fish_total:
		var fish: Fish = Fish.new()
		fish.setup(map, _open_cells, WorldGrid.cell_to_world(_random_open_cell()))
		add_child(fish)


func fish_count() -> int:
	var count: int = 0
	for child: Node in get_children():
		if child is Fish:
			count += 1
	return count


func _process(delta: float) -> void:
	# Gió mạnh → đếm ngược nhanh hơn → nhiều gợn sóng hơn.
	_spawn_timer -= delta * (0.5 + _wind.strength)
	if _spawn_timer <= 0.0 and _ripple_count < RIPPLE_MAX:
		_spawn_timer = RIPPLE_INTERVAL
		_spawn_ripple()


func _spawn_ripple() -> void:
	var sprite: Sprite2D = Sprite2D.new()
	ArtLibrary.setup_sprite(sprite, RIPPLE_KEY)
	var jitter: Vector2 = Vector2(randf_range(-RIPPLE_JITTER, RIPPLE_JITTER), randf_range(-RIPPLE_JITTER, RIPPLE_JITTER))
	sprite.position = WorldGrid.cell_to_world(_random_open_cell()) + jitter
	sprite.modulate.a = 0.0
	add_child(sprite)
	_ripple_count += 1

	var life: float = randf_range(RIPPLE_LIFE_MIN, RIPPLE_LIFE_MAX)
	var base_scale: Vector2 = sprite.scale
	var tween: Tween = sprite.create_tween().set_parallel(true)
	tween.tween_property(sprite, "modulate:a", RIPPLE_ALPHA, life * 0.35).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "modulate:a", 0.0, life * 0.65).set_delay(life * 0.35).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "position:x", sprite.position.x + RIPPLE_DRIFT * (0.5 + _wind.strength), life)
	tween.tween_property(sprite, "scale", base_scale * Vector2(1.3, 1.0), life)
	tween.finished.connect(_on_ripple_finished.bind(sprite))


func _on_ripple_finished(sprite: Sprite2D) -> void:
	_ripple_count -= 1
	sprite.queue_free()


func _random_open_cell() -> Vector2i:
	return _open_cells[randi() % _open_cells.size()]


func _is_open_water(cell: Vector2i) -> bool:
	for offset: Vector2i in WorldGrid.NEIGHBORS_4:
		if not _map.is_water(cell + offset):
			return false
	return true
