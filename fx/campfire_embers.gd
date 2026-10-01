extends CPUParticles2D
## Tàn lửa bay lên từ đống lửa, bị gió thổi dạt sang một bên.
## Dùng CPUParticles2D cho chắc chạy trên Web / máy yếu.

const ART_KEY: String = "fx/ember"
const WIND_PUSH: float = 30.0 # px/giây² gió đẩy ngang khi gió mạnh nhất

var _wind: Wind


func _ready() -> void:
	texture = ArtLibrary.get_texture(ART_KEY)
	amount = 10
	lifetime = 1.6
	preprocess = lifetime
	emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	emission_rect_extents = Vector2(8, 3)
	direction = Vector2(0, -1)
	spread = 25.0
	gravity = Vector2(0, -20)
	initial_velocity_min = 20.0
	initial_velocity_max = 45.0
	damping_min = 4.0
	damping_max = 8.0
	scale_amount_min = 0.15
	scale_amount_max = 0.3
	var ramp: Gradient = Gradient.new()
	ramp.set_color(0, Color(1.0, 0.9, 0.45, 1.0))
	ramp.set_color(1, Color(0.9, 0.3, 0.1, 0.0))
	ramp.add_point(0.6, Color(1.0, 0.5, 0.15, 0.8))
	color_ramp = ramp


func set_wind(wind: Wind) -> void:
	_wind = wind


func _process(_delta: float) -> void:
	if _wind != null:
		gravity.x = WIND_PUSH * _wind.strength
