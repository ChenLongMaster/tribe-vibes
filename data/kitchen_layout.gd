class_name KitchenLayout
## Scene là nguồn bố cục; raw chỉ còn là hệ tọa độ trung gian cho đường nội thất.

const SCENES: Array[PackedScene] = [
	preload("res://buildings/kitchen_layouts/kitchen_1.tscn"),
	preload("res://buildings/kitchen_layouts/kitchen_2.tscn"),
	preload("res://buildings/kitchen_layouts/kitchen_3.tscn"),
]
static var _cache: Dictionary[int, Dictionary] = {}

static func read_layout(root: Node2D) -> Dictionary:
	var data: Dictionary = {"transforms": {}, "blocks": []}
	_capture(root, Transform2D.IDENTITY, "", data)
	return data

static func _capture(node: Node, parent_transform: Transform2D, path: String, data: Dictionary) -> void:
	var current: Transform2D = parent_transform
	if node is Node2D:
		current *= (node as Node2D).transform
		data["transforms"][path] = current
	if node.name == &"Avoid":
		var half: Vector2 = node.get("half_size")
		var block: Rect2 = Rect2(current * -half, Vector2.ZERO)
		for corner: Vector2 in [Vector2(half.x, -half.y), half, Vector2(-half.x, half.y)]:
			block = block.expand(current * corner)
		data["blocks"].append(block)
	for child: Node in node.get_children():
		_capture(child, current, str(child.name) if path.is_empty() else path + "/" + str(child.name), data)

static func scene_data(level: int) -> Dictionary:
	var index: int = clampi(level, 1, 3)
	if not _cache.has(index):
		var root: Node2D = SCENES[index - 1].instantiate() as Node2D
		_cache[index] = read_layout(root)
		root.free()
	return _cache[index]

static func scene_point(path: String, level: int) -> Vector2:
	var transform: Transform2D = scene_data(level)["transforms"][path]
	return transform.origin

static func to_raw(local: Vector2, level: int) -> Vector2:
	return Vector2(192, 192) + ((local / ArtLibrary.ART_SCALE + PIVOT - FRAME_PADDING) / EXPANSION - Vector2(192, 192)) / YARD_SCALE[level - 1]

static func marker_raw(path: String, level: int) -> Vector2:
	return to_raw(scene_point(path, level), level)

const FRAME: Vector2 = Vector2(512, 552)
const PIVOT: Vector2 = Vector2(256, 504)
const FRAME_PADDING: Vector2 = Vector2(0, 48)
## Bố cục raw cũ vẫn dùng chung generator; kéo sân thành4×3 ô.
const EXPANSION: Vector2 = Vector2(4.0 / 3.0, 1.5)
const YARD_SCALE: Array[float] = [0.76, 0.89, 1.0]
const CANOPY_SCALE: Array[float] = [0.60, 0.69, 0.77]
const CANOPY_ORIGINS: Array[Vector2] = [Vector2(34, -24), Vector2(33, -43), Vector2(32, -60)]
const SERVING_CENTERS: Array[Vector2] = [Vector2(54, 238), Vector2(54, 238), Vector2(54, 238)]
const ROAST_CENTERS: Array[Vector2] = [Vector2(158, 210), Vector2(154, 210), Vector2(282, 187)]
const ROAST_HALF: Vector2 = Vector2(36, 20)
const COOK_OFFSETS: Array[Vector2] = [Vector2.ZERO, Vector2(-24, 32), Vector2(-44, -22)]
const CENTERS: Array = [
	[Vector2(258, 141), Vector2(258, 234)],
	[Vector2(239, 141), Vector2(319, 188), Vector2(239, 234)],
	[Vector2(234, 115), Vector2(326, 115), Vector2(234, 234), Vector2(326, 234)],
]

static func local_point(raw: Vector2, level: int) -> Vector2:
	var factor: float = YARD_SCALE[clampi(level, 1, 3) - 1]
	return ((Vector2(192, 192) + (raw - Vector2(192, 192)) * factor) * EXPANSION + FRAME_PADDING - PIVOT) * ArtLibrary.ART_SCALE

static func seat_count(level: int) -> int:
	return 0 if level < 1 else CENTERS[level - 1].size() * 2

static func seat_raw(level: int, slot: int) -> Vector2:
	return marker_raw("Dining" + str(slot >> 1) + "/Seat" + str(slot % 2), level)

static func serving_center(level: int) -> Vector2:
	return marker_raw("Serving/Center", level)

static func fetch_point(level: int) -> Vector2:
	return marker_raw("Serving/Fetch", level)

static func canopy_origin(level: int) -> Vector2:
	return marker_raw("CookingCanopy", level)

## Mặt ngồi khớp vỏ gỗ hoặc mặt ghế trong generator, trước khi kéo sân.
static func seat_surface_raw(level: int, slot: int) -> Vector2:
	return marker_raw("Dining" + str(slot >> 1) + "/Surface" + str(slot % 2), level)

static func cook_raw(level: int, slot: int) -> Vector2:
	return marker_raw(("RoastFire" if slot == 1 else "CookingCanopy") + "/Cook" + str(slot), level)

static func roast_center(level: int) -> Vector2:
	return marker_raw("RoastFire/Center", level)

## Điểm cảnh báo trên mái trước khi thu sân; nửa sau mái vươn gần đá.
static func canopy_raw(raw: Vector2, level: int) -> Vector2:
	var projected: Vector2 = Vector2(210 - raw.x, raw.y)
	if raw.y < 125.0:
		projected += Vector2(0.4, 0.35) * (raw.y - 125.0)
	# Mốc SVG cũ để đọc một điểm bất kỳ; pivot scene mới ở chân cọc trước.
	var index: int = clampi(level, 1, 3) - 1
	var baked: Vector2 = CANOPY_ORIGINS[index] + projected * CANOPY_SCALE[index]
	var base: Vector2 = CANOPY_ORIGINS[index] + Vector2(70, 312) * CANOPY_SCALE[index]
	var transform: Transform2D = scene_data(level)["transforms"]["CookingCanopy"]
	return to_raw(transform * (local_point(baked, level) - local_point(base, level)), level)

static func entry_cell(origin: Vector2i) -> Vector2i:
	return origin + Vector2i(1, 3)

static func obstacles(level: int) -> Array[Rect2]:
	var result: Array[Rect2] = []
	for block: Rect2 in scene_data(level)["blocks"]:
		result.append(Rect2(to_raw(block.position, level), to_raw(block.end, level) - to_raw(block.position, level)))
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
