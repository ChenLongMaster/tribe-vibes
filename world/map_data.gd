class_name MapData
extends RefCounted
## Kết quả sinh map — thuần dữ liệu, không có node. Nhờ vậy test được mà không cần
## dựng scene, và save game chỉ cần lưu seed + những gì đã thay đổi.

enum Edge { NORTH, SOUTH, EAST, WEST }

const KIND_TREE: StringName = &"tree"
## Đá tảng (cần cuốc). Đá cuội nhặt tay là KIND_PEBBLES.
const KIND_ROCK: StringName = &"rock"
const KIND_BUSH: StringName = &"bush"
const KIND_FISH_SPOT: StringName = &"fish_spot"
## Đồ nằm lẫn trên mặt đất, nhặt tay, không chặn đường. Không sinh cùng map mà rơi ra dần
## lúc chơi (NatureSpawner): củi dưới tán cây, đá cuội quanh đá tảng.
const KIND_TWIGS: StringName = &"twigs"
const KIND_PEBBLES: StringName = &"pebbles"

const DECOR_FLOWER: StringName = &"flower"
const DECOR_TUFT: StringName = &"grass_tuft"
const PATCH_DIRT: StringName = &"dirt_patch"
const PATCH_GRASS: StringName = &"grass_patch"

const GROUND_VARIANTS: int = 3

var map_seed: int = 0
var size: Vector2i = Vector2i.ZERO
## 1 byte mỗi ô: 1 = nước.
var water: PackedByteArray = PackedByteArray()
## 1 byte mỗi ô: biến thể hình cỏ (0..GROUND_VARIANTS-1).
var ground_variant: PackedByteArray = PackedByteArray()
## {kind: StringName, cell: Vector2i, variant: int}
var objects: Array[Dictionary] = []
## {id: StringName, cell: Vector2i} — cell là ô trên-trái của công trình.
var buildings: Array[Dictionary] = []
## Trang trí không chặn đường: {kind: StringName, pos: Vector2, variant: int}
var decor: Array[Dictionary] = []
## Mảng đất lớn nằm dưới mọi thứ: {kind: StringName, pos: Vector2, variant: int}
var patches: Array[Dictionary] = []

var village_center: Vector2i = Vector2i.ZERO
var cave_cell: Vector2i = Vector2i.ZERO
var campfire_cell: Vector2i = Vector2i.ZERO
## Ô trước cửa hang — thổ dân chui ra ở đây, cũng là điểm gốc để kiểm tra đường đi.
var cave_entrance_cell: Vector2i = Vector2i.ZERO
var forest_side: Edge = Edge.WEST
var rock_side: Edge = Edge.EAST
var lake_side: Edge = Edge.NORTH
## Cạnh map mà cannibal kéo đến (Đợt 5).
var raid_side: Edge = Edge.SOUTH
var meadow_rect: Rect2i = Rect2i()
## Ô gốc (trên-trái) của các vách đá — đá tảng mới lăn ra quanh đây.
var cliffs: Array[Vector2i] = []


func init_arrays(map_size: Vector2i) -> void:
	size = map_size
	water.resize(size.x * size.y)
	water.fill(0)
	ground_variant.resize(size.x * size.y)
	ground_variant.fill(0)


func index(cell: Vector2i) -> int:
	return cell.y * size.x + cell.x


func in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < size.x and cell.y < size.y


func is_water(cell: Vector2i) -> bool:
	return in_bounds(cell) and water[index(cell)] == 1


func objects_of_kind(kind: StringName) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for object: Dictionary in objects:
		if object["kind"] == kind:
			result.append(object)
	return result


## Mọi ô không đi qua được lúc mới sinh map: nước, vật thể, công trình.
func blocked_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for y: int in size.y:
		for x: int in size.x:
			if water[y * size.x + x] == 1:
				cells.append(Vector2i(x, y))
	for object: Dictionary in objects:
		cells.append(object["cell"])
	for building: Dictionary in buildings:
		cells.append_array(BuildingDefs.footprint_cells(building["id"], building["cell"]))
	return cells


## Lưới đã đánh dấu sẵn các ô bị chặn của map này.
func make_grid() -> WorldGrid:
	var grid: WorldGrid = WorldGrid.new(size)
	for cell: Vector2i in blocked_cells():
		grid.set_blocked(cell, true, false)
	return grid


## Dạng so sánh được — dùng để test "cùng seed ra cùng map".
func fingerprint() -> String:
	return var_to_str([
		size, water, ground_variant, objects, buildings, decor, patches,
		cave_cell, campfire_cell, forest_side, lake_side, raid_side, meadow_rect,
	])
