class_name DayNight
extends Node
## Ngày và đêm — chỉ để trang trí và đếm ngày (thổ dân ngủ theo Thể lực, không theo giờ):
## - Ánh sáng: CanvasModulate lấy màu từ một dải màu theo giờ (bình minh hồng → trưa trắng →
##   chiều vàng → hoàng hôn đỏ cam → đêm xanh tím), đổi liên tục, không nhảy bậc.
## - Bóng đổ: báo hướng/độ dài bóng cho ShadowLayer — sáng bóng dài về phía tây, trưa ngắn
##   dưới chân, chiều dài về phía đông, đêm mờ hẳn. Nhìn bóng là ước được giờ.
## - Ánh lửa ban đêm: sprite cộng sáng ở lửa trại, bếp, lò rèn (không dùng Light2D để Web
##   chạy nhẹ). Nằm trên một CanvasLayer riêng đi theo camera nên không bị CanvasModulate
##   làm tối.
## Chỉ ĐỌC GameState.time_of_day — đồng hồ ngày nằm ở GameState.

const GLOW_TEXTURE_SIZE: int = 128
const GLOW_FLICKER_SPEED: float = 7.0
const GLOW_FLICKER: float = 0.08
## Ánh lửa hiện dần từ lúc chạng vạng (độ sáng trời dưới mức này).
const GLOW_START_DAYLIGHT: float = 0.85

const NIGHT: Color = Color(0.43, 0.48, 0.78)
## Mốc màu theo giờ (0 = nửa đêm, 0.5 = trưa) — khớp SUNRISE/SUNSET trong Balance.
const LIGHT_KEYS: Array[Array] = [
	[0.0, NIGHT],
	[0.085, NIGHT],
	[0.125, Color(0.93, 0.74, 0.82)],
	[0.18, Color(1.0, 0.9, 0.86)],
	[0.3, Color(1.0, 0.98, 0.95)],
	[0.5, Color(1.0, 1.0, 1.0)],
	[0.68, Color(1.0, 0.95, 0.84)],
	[0.79, Color(1.0, 0.84, 0.62)],
	[0.86, Color(1.0, 0.66, 0.52)],
	[0.91, Color(0.66, 0.56, 0.8)],
	[0.95, NIGHT],
	[1.0, NIGHT],
]

var _world: World
var _modulate: CanvasModulate
var _glow_layer: CanvasLayer
var _glow_texture: GradientTexture2D
var _glow_material: CanvasItemMaterial
## {Building: Sprite2D}
var _glows: Dictionary = {}
var _time: float = 0.0
static var _gradient: Gradient


func setup(world: World) -> void:
	_world = world
	_modulate = CanvasModulate.new()
	world.add_child(_modulate)
	_glow_layer = CanvasLayer.new()
	_glow_layer.layer = 1
	_glow_layer.follow_viewport_enabled = true
	world.add_child(_glow_layer)
	_glow_texture = GradientTexture2D.new()
	_glow_texture.width = GLOW_TEXTURE_SIZE
	_glow_texture.height = GLOW_TEXTURE_SIZE
	_glow_texture.fill = GradientTexture2D.FILL_RADIAL
	_glow_texture.fill_from = Vector2(0.5, 0.5)
	_glow_texture.fill_to = Vector2(1.0, 0.5)
	var falloff: Gradient = Gradient.new()
	falloff.set_color(0, Color(1, 1, 1, 1))
	falloff.set_color(1, Color(1, 1, 1, 0))
	falloff.add_point(0.45, Color(1, 1, 1, 0.45))
	_glow_texture.gradient = falloff
	_glow_material = CanvasItemMaterial.new()
	_glow_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	EventBus.building_completed.connect(func(_building: Node, _level: int) -> void: refresh_glows())
	EventBus.building_removed.connect(func(_building: Node) -> void: refresh_glows())
	refresh_glows()
	_apply(GameState.time_of_day)


## Dựng lại ánh lửa theo các công trình có lửa đã xây xong.
func refresh_glows() -> void:
	for building: Building in _world.buildings:
		var glow: Dictionary = building.def.get("glow", {})
		if glow.is_empty() or not building.is_built() or _glows.has(building):
			continue
		var sprite: Sprite2D = Sprite2D.new()
		sprite.texture = _glow_texture
		sprite.material = _glow_material
		sprite.modulate = glow.get("color", Color.ORANGE)
		var radius: float = float(glow.get("radius", 160.0))
		sprite.scale = Vector2.ONE * radius * 2.0 / GLOW_TEXTURE_SIZE * Vector2(1.0, 0.75)
		sprite.position = building.position + glow.get("offset", Vector2.ZERO)
		_glow_layer.add_child(sprite)
		_glows[building] = sprite
	for building: Building in _glows.keys():
		if not is_instance_valid(building) or not building.is_built():
			(_glows[building] as Sprite2D).queue_free()
			_glows.erase(building)


func _process(delta: float) -> void:
	_time += delta
	_apply(GameState.time_of_day)


func _apply(t: float) -> void:
	_modulate.color = light_color(t)
	var sun: Dictionary = sun_state(t)
	_world.shadows.set_sun(sun["shadow_vec"], sun["alpha"])
	var night: float = 1.0 - clampf(float(sun["daylight"]) / GLOW_START_DAYLIGHT, 0.0, 1.0)
	_glow_layer.visible = night > 0.01
	for building: Building in _glows:
		var sprite: Sprite2D = _glows[building]
		var base: Color = building.def.get("glow", {}).get("color", Color.ORANGE)
		var flicker: float = 1.0 + GLOW_FLICKER * sin(_time * GLOW_FLICKER_SPEED + building.position.x)
		sprite.modulate = Color(base.r, base.g, base.b, base.a * night * flicker)


## Màu ánh sáng trời lúc `t` (0 = nửa đêm, 0.5 = trưa).
static func light_color(t: float) -> Color:
	if _gradient == null:
		var offsets: PackedFloat32Array = PackedFloat32Array()
		var colors: PackedColorArray = PackedColorArray()
		for key: Array in LIGHT_KEYS:
			offsets.append(float(key[0]))
			colors.append(key[1])
		_gradient = Gradient.new()
		_gradient.offsets = offsets
		_gradient.colors = colors
	return _gradient.sample(fposmod(t, 1.0))


## Trạng thái mặt trời lúc `t`: daylight (0 đêm..1 trưa), shadow_vec (bóng dời bao nhiêu px
## trên đất cho mỗi px chiều cao vật), alpha (độ đậm bóng), sun (0..1 vị trí mặt trời trên
## cung trời, <0 hoặc >1 là đêm).
static func sun_state(t: float) -> Dictionary:
	var sun: float = (fposmod(t, 1.0) - Balance.SUNRISE) / (Balance.SUNSET - Balance.SUNRISE)
	if sun <= 0.0 or sun >= 1.0:
		return {"daylight": 0.0, "shadow_vec": Vector2(0, -Balance.SHADOW_LENGTH_MIN), "alpha": 0.0, "sun": sun}
	var elevation: float = sin(PI * sun)
	# Sáng: mặt trời phía đông → bóng đổ về tây (trái); chiều ngược lại. Trưa bóng ngắn, hơi
	# lệch ra sau vật.
	var direction: Vector2 = Vector2(-cos(PI * sun), -0.35 * elevation).normalized()
	var length: float = lerpf(Balance.SHADOW_LENGTH_MAX, Balance.SHADOW_LENGTH_MIN, elevation)
	var vec: Vector2 = direction * length * Vector2(1.0, Balance.SHADOW_DEPTH_SQUASH)
	var fade: float = smoothstep(0.0, 0.07, sun) * smoothstep(1.0, 0.93, sun)
	return {"daylight": clampf(elevation * 1.6, 0.0, 1.0), "shadow_vec": vec,
			"alpha": Balance.SHADOW_ALPHA * fade, "sun": sun}
