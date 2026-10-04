class_name KitchenLayout
## Cùng toạ độ 2× với tools/kitchen_art.py; lưới thế giới vẫn là ô vuông.

const FRAME: Vector2 = Vector2(384, 336)
const PIVOT: Vector2 = Vector2(192, 296)
const YARD_SCALE: Array[float] = [0.76, 0.89, 1.0]
const CANOPY_SCALE: Array[float] = [0.52, 0.60, 0.67]
const CENTERS: Array = [
	[Vector2(254, 141), Vector2(254, 234)],
	[Vector2(211, 141), Vector2(319, 188), Vector2(211, 234)],
	[Vector2(201, 141), Vector2(310, 141), Vector2(201, 234), Vector2(310, 234)],
]

static func local_point(raw: Vector2, level: int) -> Vector2:
	var factor: float = YARD_SCALE[clampi(level, 1, 3) - 1]
	return (Vector2(192, 192) + (raw - Vector2(192, 192)) * factor - PIVOT) * ArtLibrary.ART_SCALE

static func seat_count(level: int) -> int:
	return 0 if level < 1 else CENTERS[level - 1].size() * 2

static func seat_raw(level: int, slot: int) -> Vector2:
	var center: Vector2 = CENTERS[level - 1][slot >> 1]
	var offset: float = 51.0 if level == 1 else 38.0
	return center + Vector2(-offset if slot % 2 == 0 else offset, 34)

static func cook_raw(level: int, slot: int) -> Vector2:
	var factor: float = CANOPY_SCALE[level - 1]
	var primary: Vector2 = Vector2(21 + 152 * factor, 40 + 255 * factor)
	return primary + [Vector2.ZERO, Vector2(-2, 42), Vector2(-44, 0)][slot]

static func entry_cell(origin: Vector2i) -> Vector2i:
	return origin + Vector2i(1, 2)

static func obstacles(level: int) -> Array[Rect2]:
	var result: Array[Rect2] = [Rect2(Vector2(21, 235), Vector2(74, 45))]
	for center: Vector2 in CENTERS[level - 1]:
		var half: Vector2 = Vector2(24, 34) if level == 1 else Vector2(20, 26)
		result.append(Rect2(center - half, half * 2.0))
	return result

## Đường đi ngắn trong sân dùng các góc tránh bàn; không mở đường xuyên rào cho AStar map.
static func route(from: Vector2, to: Vector2, level: int) -> PackedVector2Array:
	var graph: AStar2D = AStar2D.new()
	var blocks: Array[Rect2] = obstacles(level)
	# Bàn dịch khi lên cấp; người đang đứng ở vị trí cũ được bước ra khỏi vùng vừa đổi.
	for index: int in range(blocks.size() - 1, -1, -1):
		if blocks[index].has_point(from):
			blocks.remove_at(index)
	var points: Array[Vector2] = [from, to]
	for block: Rect2 in blocks:
		var outer: Rect2 = block.grow(6.0)
		points.append_array([outer.position, Vector2(outer.end.x, outer.position.y), outer.end, Vector2(outer.position.x, outer.end.y)])
	for index: int in points.size():
		graph.add_point(index, points[index])
	for first: int in points.size():
		for second: int in range(first + 1, points.size()):
			var clear: bool = true
			for block: Rect2 in blocks:
				if block.has_point(points[first]) or block.has_point(points[second]):
					clear = false
					break
				var corners: Array[Vector2] = [block.position, Vector2(block.end.x, block.position.y), block.end, Vector2(block.position.x, block.end.y)]
				for edge: int in 4:
					if Geometry2D.segment_intersects_segment(points[first], points[second], corners[edge], corners[(edge + 1) % 4]) != null:
						clear = false
						break
			if clear:
				graph.connect_points(first, second)
	return graph.get_point_path(0, 1)
