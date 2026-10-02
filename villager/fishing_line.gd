class_name FishingLine
extends Node2D
## Dây câu từ đầu cần tới cái phao nổi trước mặt — vẽ bằng code (không cần hình), VillagerRig
## cập nhật hai đầu mỗi frame. Toạ độ theo khung của rig (đã lật theo hướng nhìn).

const LINE_COLOR: Color = Color(0.306, 0.204, 0.18, 0.8)
const LINE_WIDTH: float = 1.2
## Dây hơi võng xuống giữa chừng cho mềm.
const SAG: float = 10.0
const SEGMENTS: int = 8
const BOBBER_RADIUS: float = 3.5
const BOBBER_TOP: Color = Color("#E53935")
const BOBBER_BOTTOM: Color = Color("#FFFFFF")
const OUTLINE: Color = Color("#4E342E")

var tip: Vector2 = Vector2.ZERO
var bobber: Vector2 = Vector2.ZERO


func _draw() -> void:
	var points: PackedVector2Array = PackedVector2Array()
	for i: int in SEGMENTS + 1:
		var t: float = float(i) / SEGMENTS
		points.append(tip.lerp(bobber, t) + Vector2(0, sin(t * PI) * SAG))
	draw_polyline(points, LINE_COLOR, LINE_WIDTH, true)
	# Phao đỏ trắng: nửa trên đỏ, nửa dưới trắng, viền nâu như mọi hình khác.
	draw_circle(bobber, BOBBER_RADIUS + 1.2, OUTLINE)
	draw_circle(bobber, BOBBER_RADIUS, BOBBER_BOTTOM)
	var top: PackedVector2Array = PackedVector2Array()
	for i: int in SEGMENTS + 1:
		top.append(bobber + Vector2.from_angle(PI + PI * i / SEGMENTS) * BOBBER_RADIUS)
	draw_colored_polygon(top, BOBBER_TOP)
