class_name KitchenRoastDecor
extends Node2D
## Trang trí sống của bếp: quay xiên, than nhấp nhẹ và khói mỏng; không sinh món.

const TURN_SECONDS: float = 8.0
var _chicken: Sprite2D
var _fire: Sprite2D
var _chicken_scale: Vector2
var _fire_scale: Vector2
var _smoke_origin: Vector2
var _size: float = 1.0
var _time: float = 0.0

func setup(chicken: Sprite2D, fire: Sprite2D, smoke_origin: Vector2, size: float) -> void:
	_chicken = chicken
	_fire = fire
	_chicken_scale = chicken.scale
	_fire_scale = fire.scale
	_smoke_origin = smoke_origin
	_size = size

func _process(delta: float) -> void:
	_time += delta
	# Co/lật quanh trục xiên tạo cảm giác lăn; chân giá và xiên vẫn đứng yên.
	var turn: float = cos(_time * TAU / TURN_SECONDS)
	_chicken.scale.y = _chicken_scale.y * (maxf(0.08, absf(turn)) * (1.0 if turn >= 0.0 else -1.0))
	_fire.scale = _fire_scale * Vector2(1.0 + 0.05 * sin(_time * 7.1), 0.95 + 0.10 * sin(_time * 8.3))
	queue_redraw()

func _draw() -> void:
	if _chicken == null:
		return
	for index: int in 3:
		var phase: float = fposmod(_time * 0.27 + index / 3.0, 1.0)
		var point: Vector2 = _smoke_origin + Vector2(sin(phase * 4.0 + index) * 2.5, -phase * 17.0) * _size
		draw_set_transform(point, 0.0, Vector2(1.3, 0.7))
		draw_circle(Vector2.ZERO, (2.0 + phase * 2.0) * _size, Color(0.91, 0.86, 0.74, 0.16 * sin(phase * PI)))
	draw_set_transform(Vector2.ZERO)
