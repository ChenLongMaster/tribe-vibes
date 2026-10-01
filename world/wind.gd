class_name Wind
extends Node
## Gió chung cho cả map. Cỏ, hoa, bụi, cây, ngọn lửa, mặt hồ và tàn lửa đều đọc
## từ đây nên đung đưa cùng một nhịp; gió thổi theo từng đợt lúc mạnh lúc lặng.
##
## Mỗi loại vật dùng chung MỘT material, nên mỗi frame chỉ cập nhật vài material
## dù có hàng trăm sprite.

enum Profile { GRASS, BUSH, TREE, FLAME }

const SWAY_SHADER: Shader = preload("res://fx/wind_sway.gdshader")
const WATER_SHADER: Shader = preload("res://fx/water_shimmer.gdshader")
## Độ lay mép trên (px trong ảnh 2×) theo thứ tự Profile.
const SWAY_AMOUNTS: Array[float] = [12.0, 4.0, 7.0, 10.0]
const BASE_STRENGTH: float = 0.5
const GUST_STRENGTH: float = 0.5

## Đồng hồ gió — chạy theo thời gian game (dừng khi tạm dừng, nhanh khi ×3).
var time: float = 0.0
## 0..1, cao lúc có đợt gió.
var strength: float = BASE_STRENGTH

var _sway_materials: Dictionary[Profile, ShaderMaterial] = {}
var _water_material: ShaderMaterial


func sway_material(profile: Profile) -> ShaderMaterial:
	if not _sway_materials.has(profile):
		var material: ShaderMaterial = ShaderMaterial.new()
		material.shader = SWAY_SHADER
		material.set_shader_parameter("sway_amount", SWAY_AMOUNTS[profile])
		_sway_materials[profile] = material
	return _sway_materials[profile]


func water_material() -> ShaderMaterial:
	if _water_material == null:
		_water_material = ShaderMaterial.new()
		_water_material.shader = WATER_SHADER
	return _water_material


func _process(delta: float) -> void:
	time += delta
	# Hai sóng chậm lệch pha nhân nhau → đợt gió đến không đều, có lúc lặng hẳn.
	var gust: float = (0.5 + 0.5 * sin(time * 0.31)) * (0.5 + 0.5 * sin(time * 0.17 + 1.3))
	strength = BASE_STRENGTH + GUST_STRENGTH * gust
	for material: ShaderMaterial in _sway_materials.values():
		_push(material)
	if _water_material != null:
		_push(_water_material)


func _push(material: ShaderMaterial) -> void:
	material.set_shader_parameter("wind_time", time)
	material.set_shader_parameter("wind_strength", strength)
