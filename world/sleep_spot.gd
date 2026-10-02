class_name SleepSpot
extends RefCounted
## Một chỗ ngủ: ô để nằm + tốc độ hồi thể lực. Hiện chỉ có ngủ đất cạnh lửa trại (×1);
## Đợt 3 Lều trả về chỗ trong lều với hệ số theo cấp — TaskSleep không phải sửa.

var cell: Vector2i
## Nhân với tốc độ hồi thể lực khi ngủ đất (Balance.ENERGY_RESTORE_GROUND).
var rate_multiplier: float = 1.0
## Key đặt chỗ (để hai người không nằm đè lên nhau).
var reservation_key: Variant


func _init(spot_cell: Vector2i, multiplier: float, key: Variant) -> void:
	cell = spot_cell
	rate_multiplier = multiplier
	reservation_key = key
