class_name YardRing
extends Node2D
## Vòng đá thấp quây quanh sân một công trình (kiểu Prehistoric Tribes: mỗi nhà là một "khu"
## có sân đất và vòng đá). Vẽ bằng code: các viên đá nhỏ xếp theo hình chữ nhật bo góc quanh
## sân, lệch nhẹ, thỉnh thoảng hở, chừa một lối vào ở giữa cạnh trước. Nằm dưới thổ dân
## (lớp trang trí) — chỉ để nhìn, không chặn đường.

const STONE_SPACING: float = 21.0
const GAP_CHANCE: float = 0.18
const CORNER_RADIUS: float = 34.0
## Lối vào ở giữa cạnh trước rộng chừng này px.
const ENTRANCE_WIDTH: float = 54.0
const STONE_FILL: Color = Color("#B3ABA0")
const STONE_LIGHT: Color = Color("#D4CEC4")
const STONE_EDGE: Color = Color("#6D6158")

var _rect: Rect2
var _seed: int = 0
## Sân các công trình khác (px): đá rơi vào đó thì bỏ — hai nhà sát nhau thành một sân chung,
## không có hàng đá chắn giữa.
var _excluded: Array[Rect2] = []


## `rect` = mép sân (px, toạ độ thế giới).
func setup(rect: Rect2, seed_value: int) -> void:
	_rect = rect
	_seed = seed_value
	queue_redraw()


func set_excluded(rects: Array[Rect2]) -> void:
	_excluded = rects
	queue_redraw()


func _draw() -> void:
	var perimeter: PackedVector2Array = _rounded_rect(_rect, CORNER_RADIUS)
	var length: float = 0.0
	for i: int in perimeter.size():
		length += perimeter[i].distance_to(perimeter[(i + 1) % perimeter.size()])
	var count: int = int(length / STONE_SPACING)
	var front_center: Vector2 = Vector2(_rect.get_center().x, _rect.end.y)
	for index: int in count:
		var point: Vector2 = _point_at(perimeter, index * STONE_SPACING)
		if point.distance_to(front_center) < ENTRANCE_WIDTH * 0.5 or _hash01(index, 1) < GAP_CHANCE:
			continue
		if _excluded.any(func(other: Rect2) -> bool: return other.has_point(point)):
			continue
		point += Vector2(_hash01(index, 2) - 0.5, _hash01(index, 3) - 0.5) * 6.0
		var size: Vector2 = Vector2(4.2 + _hash01(index, 4) * 3.0, 3.0 + _hash01(index, 5) * 1.6)
		_ellipse(point, size + Vector2(1.6, 1.6), STONE_EDGE)
		_ellipse(point, size, STONE_FILL)
		_ellipse(point + Vector2(-size.x * 0.25, -size.y * 0.3), size * Vector2(0.4, 0.3), STONE_LIGHT)


func _ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
	draw_set_transform(center, 0.0, Vector2(radius.x / radius.y, 1.0))
	draw_circle(Vector2.ZERO, radius.y, color, true, -1.0, true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


static func _rounded_rect(rect: Rect2, radius: float) -> PackedVector2Array:
	var points: PackedVector2Array = PackedVector2Array()
	var r: float = minf(radius, minf(rect.size.x, rect.size.y) * 0.5)
	var corners: Array[Vector2] = [
		Vector2(rect.end.x - r, rect.position.y + r), Vector2(rect.end.x - r, rect.end.y - r),
		Vector2(rect.position.x + r, rect.end.y - r), Vector2(rect.position.x + r, rect.position.y + r),
	]
	for corner_index: int in 4:
		var start_angle: float = -PI * 0.5 + corner_index * PI * 0.5
		for step: int in 5:
			var angle: float = start_angle + step * PI * 0.125
			points.append(corners[corner_index] + Vector2(cos(angle), sin(angle)) * r)
	return points


static func _point_at(points: PackedVector2Array, distance: float) -> Vector2:
	var left: float = distance
	for i: int in points.size():
		var a: Vector2 = points[i]
		var b: Vector2 = points[(i + 1) % points.size()]
		var segment: float = a.distance_to(b)
		if left <= segment:
			return a.lerp(b, left / maxf(segment, 0.001))
		left -= segment
	return points[0]


func _hash01(index: int, salt: int) -> float:
	var h: int = (index * 374761393 + (_seed + salt) * 668265263) & 0x7fffffff
	h = ((h ^ (h >> 13)) * 1274126177) & 0x7fffffff
	return float((h ^ (h >> 16)) % 10007) / 10007.0
