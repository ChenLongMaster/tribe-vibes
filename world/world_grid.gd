class_name WorldGrid
extends RefCounted
## Nguồn sự thật duy nhất về lưới ô: đổi toạ độ ô ↔ thế giới, ô nào bị chặn,
## tìm đường. Các lớp hình (TileMapLayer) chỉ để vẽ, không ai hỏi chúng về toạ độ.

const NEIGHBORS_4: Array[Vector2i] = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
const NEIGHBORS_8: Array[Vector2i] = [
	Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
	Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1),
]

var size: Vector2i
var astar: AStarGrid2D
var _blocked: PackedByteArray


func _init(grid_size: Vector2i) -> void:
	size = grid_size
	_blocked.resize(size.x * size.y)
	astar = AStarGrid2D.new()
	astar.region = Rect2i(Vector2i.ZERO, size)
	astar.cell_size = Vector2(Balance.TILE_SIZE, Balance.TILE_SIZE)
	# Đường đi trả về tâm ô thay vì góc ô.
	astar.offset = astar.cell_size * 0.5
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	astar.update()


## Tâm ô trong toạ độ thế giới.
static func cell_to_world(cell: Vector2i) -> Vector2:
	return (Vector2(cell) + Vector2(0.5, 0.5)) * Balance.TILE_SIZE


static func world_to_cell(pos: Vector2) -> Vector2i:
	return Vector2i((pos / Balance.TILE_SIZE).floor())


func pixel_size() -> Vector2:
	return Vector2(size * Balance.TILE_SIZE)


func in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < size.x and cell.y < size.y


func is_blocked(cell: Vector2i) -> bool:
	if not in_bounds(cell):
		return true
	return _blocked[_index(cell)] == 1


## `notify = false` khi đang dựng map hàng loạt, để không bắn hàng trăm signal.
func set_blocked(cell: Vector2i, blocked: bool, notify: bool = true) -> void:
	if not in_bounds(cell):
		return
	_blocked[_index(cell)] = 1 if blocked else 0
	astar.set_point_solid(cell, blocked)
	if notify:
		EventBus.grid_changed.emit(cell)


## Đường đi qua tâm các ô. Không tới được hẳn thì đi tới chỗ gần nhất có thể.
func find_path(from_cell: Vector2i, to_cell: Vector2i) -> PackedVector2Array:
	if not in_bounds(from_cell) or not in_bounds(to_cell):
		return PackedVector2Array()
	return astar.get_point_path(from_cell, to_cell, true)


## Có đường đi trọn vẹn từ ô này tới ô kia không (không tính đường "tới gần nhất").
func has_path(from_cell: Vector2i, to_cell: Vector2i) -> bool:
	if from_cell == to_cell:
		return not is_blocked(to_cell)
	if is_blocked(to_cell) or not in_bounds(from_cell):
		return false
	return not astar.get_id_path(from_cell, to_cell, false).is_empty()


## Loang từ `start`: trả về mảng 1 byte mỗi ô, 1 = đi tới được (đi 4 hướng).
func flood_fill(start: Vector2i) -> PackedByteArray:
	var reached: PackedByteArray = PackedByteArray()
	reached.resize(size.x * size.y)
	if is_blocked(start):
		return reached
	var queue: Array[Vector2i] = [start]
	reached[_index(start)] = 1
	var head: int = 0
	while head < queue.size():
		var cell: Vector2i = queue[head]
		head += 1
		for offset: Vector2i in NEIGHBORS_4:
			var next: Vector2i = cell + offset
			if in_bounds(next) and not is_blocked(next) and reached[_index(next)] == 0:
				reached[_index(next)] = 1
				queue.append(next)
	return reached


## Vật chặn ô của nó (cây, đá) "tới được" khi có ít nhất một ô kề đi tới được.
func has_reachable_neighbor(cell: Vector2i, reached: PackedByteArray) -> bool:
	for offset: Vector2i in NEIGHBORS_8:
		var next: Vector2i = cell + offset
		if in_bounds(next) and reached[_index(next)] == 1:
			return true
	return false


func is_reached(cell: Vector2i, reached: PackedByteArray) -> bool:
	return in_bounds(cell) and reached[_index(cell)] == 1


func _index(cell: Vector2i) -> int:
	return cell.y * size.x + cell.x
