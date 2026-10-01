class_name FishSpotFx
extends Node2D
## Chỗ câu cá trông "có cá": vòng gợn lan ra đều đều, thỉnh thoảng một con cá
## nhảy vọt lên rồi tõm xuống. Giúp người chơi nhận ra chỗ câu mà không cần chữ.

const RING_KEY: String = "env/ripple_ring"
const JUMP_KEY: String = "env/fish_jump"
const RING_INTERVAL: float = 1.5 # giây
const RING_LIFE: float = 1.8
const RING_START_SCALE: float = 0.25
const RING_END_SCALE: float = 0.9
const RING_ALPHA: float = 0.7
const JUMP_INTERVAL_MIN: float = 4.0
const JUMP_INTERVAL_MAX: float = 10.0
const JUMP_SECONDS: float = 0.75
const JUMP_HEIGHT: float = 30.0 # px
const JUMP_DISTANCE: float = 26.0 # px
const JUMP_TILT: float = 0.9 # rad, đầu chúc lên lúc nhảy, chúc xuống lúc rơi

var _ring_timer: float = 0.0
var _jump_timer: float = 0.0


func _ready() -> void:
	# Lệch pha ngẫu nhiên để các chỗ câu không nhịp nhàng giống hệt nhau.
	_ring_timer = randf() * RING_INTERVAL
	_jump_timer = randf_range(1.0, JUMP_INTERVAL_MAX)


func _process(delta: float) -> void:
	_ring_timer -= delta
	if _ring_timer <= 0.0:
		_ring_timer = RING_INTERVAL
		_spawn_ring(Vector2.ZERO)
	_jump_timer -= delta
	if _jump_timer <= 0.0:
		_jump_timer = randf_range(JUMP_INTERVAL_MIN, JUMP_INTERVAL_MAX)
		_jump()


func _spawn_ring(at: Vector2) -> void:
	var ring: Sprite2D = Sprite2D.new()
	ArtLibrary.setup_sprite(ring, RING_KEY)
	var full_scale: Vector2 = ring.scale
	ring.position = at
	ring.scale = full_scale * RING_START_SCALE
	ring.modulate.a = RING_ALPHA
	add_child(ring)
	var tween: Tween = ring.create_tween().set_parallel(true)
	tween.tween_property(ring, "scale", full_scale * RING_END_SCALE, RING_LIFE).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(ring, "modulate:a", 0.0, RING_LIFE).set_ease(Tween.EASE_IN)
	tween.finished.connect(ring.queue_free)


func _jump() -> void:
	var fish: Sprite2D = Sprite2D.new()
	ArtLibrary.setup_sprite(fish, JUMP_KEY)
	var direction: float = 1.0 if randf() < 0.5 else -1.0
	fish.scale.x *= direction
	add_child(fish)
	var start: Vector2 = Vector2(-JUMP_DISTANCE * 0.5 * direction, 0)
	var end: Vector2 = Vector2(JUMP_DISTANCE * 0.5 * direction, 0)
	_spawn_ring(start)
	var tween: Tween = fish.create_tween()
	tween.tween_method(_place_jumping_fish.bind(fish, start, end, direction), 0.0, 1.0, JUMP_SECONDS)
	tween.tween_callback(_spawn_ring.bind(end))
	tween.tween_callback(fish.queue_free)


# t = 0..1 dọc theo cung nhảy hình parabol.
func _place_jumping_fish(t: float, fish: Sprite2D, start: Vector2, end: Vector2, direction: float) -> void:
	fish.position = start.lerp(end, t) + Vector2(0, -sin(t * PI) * JUMP_HEIGHT)
	fish.rotation = lerpf(-JUMP_TILT, JUMP_TILT, t) * direction
