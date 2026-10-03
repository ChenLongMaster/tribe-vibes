class_name BuildingPlacer
extends RefCounted
## Luật đặt công trình lên map (lõi — UI chỉ hỏi can_place để tô bóng mờ xanh/đỏ):
## - Mọi ô của diện tích phải trong map, không phải nước, không có cây/đá/công trình khác.
##   Củi, đá cuội nằm trên đất thì được dọn đi.
## - Không được chặn mất lối: sau khi đặt, hang đá vẫn đi tới được chính công trình này và
##   mọi công trình khác (không thì thổ dân kẹt).
## - Thú đang đứng đó thì chờ nó đi đã; thổ dân đứng đó thì bị nhích ra chỗ trống bên cạnh.

var _world: World


func _init(world: World) -> void:
	_world = world


func can_place(building_id: StringName, origin: Vector2i) -> bool:
	if not BuildingDefs.is_buildable(building_id):
		return false
	var cells: Array[Vector2i] = BuildingDefs.footprint_cells(building_id, origin)
	for cell: Vector2i in cells:
		if not _world.grid.in_bounds(cell) or _world.map_data.is_water(cell):
			return false
		if _world.grid.is_blocked(cell) or _world.building_at_cell(cell) != null:
			return false
	for animal: Animal in _world.animals:
		if animal.visible and cells.has(animal.current_cell()):
			return false
	if bool(BuildingDefs.get_def(building_id).get("walkable", false)):
		return true
	return _keeps_paths(cells)


## Đặt móng. Trả về công trình mới, hoặc null nếu chỗ đó không đặt được.
## `level` > 0 = dựng luôn công trình đã xây xong (chỉ cho test / công cụ chụp màn hình).
func place(building_id: StringName, origin: Vector2i, level: int = 0) -> Building:
	if not can_place(building_id, origin):
		return null
	var cells: Array[Vector2i] = BuildingDefs.footprint_cells(building_id, origin)
	for node: ResourceNode in _world.resource_nodes:
		if node.is_loose() and not node.is_cleared and cells.has(node.cell):
			node.clear_away()
	var building: Building = _world.add_building(building_id, origin, level)
	if not building.is_walkable():
		_nudge_villagers(cells)
	return building


# Thử chặn các ô này rồi loang từ cửa hang: mọi ô đang đi tới được (trừ chính chỗ đặt) vẫn
# phải đi tới được — không quây kín vùng nào — và công trình mới lẫn mọi công trình cũ vẫn
# có ít nhất một ô kề đi tới được.
func _keeps_paths(cells: Array[Vector2i]) -> bool:
	var start: Vector2i = _world.map_data.cave_entrance_cell
	var before: PackedByteArray = _world.grid.flood_fill(start)
	var extra: Dictionary[Vector2i, bool] = {}
	var lost: int = 0
	for cell: Vector2i in cells:
		extra[cell] = true
		if _world.grid.is_reached(cell, before):
			lost += 1
	var reached: PackedByteArray = _world.grid.flood_fill(start, extra)
	if _count(reached) != _count(before) - lost:
		return false
	if not _any_neighbor_reached(cells, reached):
		return false
	for building: Building in _world.buildings:
		if building.is_walkable():
			continue
		if not _any_neighbor_reached(building.footprint_cells(), reached):
			return false
	return true


func _count(reached: PackedByteArray) -> int:
	return reached.count(1)


func _any_neighbor_reached(cells: Array[Vector2i], reached: PackedByteArray) -> bool:
	for cell: Vector2i in cells:
		if _world.grid.has_reachable_neighbor(cell, reached):
			return true
	return false


# Ai đang đứng trong diện tích mới thì nhảy sang ô trống gần nhất (không thì kẹt trong tường).
func _nudge_villagers(cells: Array[Vector2i]) -> void:
	for villager: Villager in _world.villagers:
		var cell: Vector2i = _world.cell_of(villager)
		if not cells.has(cell):
			continue
		var free: Vector2i = _world.finder.find_free_cell_near(cell, 1.0, 4.0)
		if free == World.INVALID_CELL:
			continue
		villager.hop_to(WorldGrid.cell_to_world(free))
