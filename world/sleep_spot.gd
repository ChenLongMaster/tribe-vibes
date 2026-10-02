class_name SleepSpot
extends RefCounted
## Một chỗ ngủ: ô để nằm + tốc độ hồi thể lực. Ngủ đất cạnh lửa trại (×1), hoặc một chỗ
## trong lều (`tent`: đi tới cửa lều rồi chui vào, hệ số hồi theo cấp lều).

var cell: Vector2i
## Nhân với tốc độ hồi thể lực khi ngủ đất (Balance.ENERGY_RESTORE_GROUND).
var rate_multiplier: float = 1.0
## Key đặt chỗ (để hai người không nằm đè lên nhau).
var reservation_key: Variant
## Lều để chui vào ngủ (null = ngủ đất).
var tent: Building


func _init(spot_cell: Vector2i, multiplier: float, key: Variant, in_tent: Building = null) -> void:
	cell = spot_cell
	rate_multiplier = multiplier
	reservation_key = key
	tent = in_tent
