class_name SaveGame
## Gom / dựng lại một ván chơi thành dữ liệu JSON được (SaveSystem lo đọc ghi file).
## Map sinh lại từ seed nên chỉ cần lưu những gì đã ĐỔI so với lúc mới sinh:
## - game: ngày giờ, seed, kho chung (GameState).
## - nodes: trạng thái từng cây, đá, bụi, củi, đá cuội — theo đúng thứ tự trong
##   World.resource_nodes (node không bao giờ bị xoá nên thứ tự giữ nguyên; node mọc thêm
##   lúc chơi nằm ở cuối).
## - buildings: mọi công trình (cấp, lượt xây dở + vật liệu đã đổ, đồ riêng, đơn rèn). Công
##   trình có sẵn trên map khớp theo vị trí; công trình người chơi xây thì dựng lại.
## - villagers: VillagerData + VillagerStatus (chỉ số, kỹ năng, đồ nghề đang giữ) + vị trí,
##   điểm neo, việc đang nhớ (Job).
## Thú không lưu (đàn thú lang thang mới). Việc đang làm dở (Task) không lưu — tải xong
## thổ dân tự làm tiếp lượt mới của việc đang nhớ.

## Tăng khi cách sinh map đổi (map dựng lại từ seed phải ra đúng map cũ) hoặc cấu trúc save đổi.
## v3: map 96×72, tài nguyên theo cụm, dãy vách đá.
## v8: bếp3×2; không dựng save2×2 cũ đè vào công trình bên cạnh.
const VERSION: int = 9


## Ván lưu này còn dựng lại được không (cùng phiên bản cách sinh map).
static func is_compatible(save: Dictionary) -> bool:
	return int(save.get("format", 0)) == VERSION


static func capture(world: World) -> Dictionary:
	var nodes: Array = []
	for node: ResourceNode in world.resource_nodes:
		nodes.append(node.to_dict())
	var buildings: Array = []
	for building: Building in world.buildings:
		buildings.append(building.to_dict())
	var villagers: Array = []
	for villager: Villager in world.villagers:
		villagers.append({
			"id": villager.id,
			"data": villager.data.to_dict(),
			"status": villager.status.to_dict(),
			"pos": [villager.position.x, villager.position.y],
			"anchor": [villager.anchor_cell.x, villager.anchor_cell.y],
			"job": villager.job.to_dict() if villager.job != null else {},
		})
	return {"format": VERSION, "game": GameState.to_dict(), "nodes": nodes, "buildings": buildings, "villagers": villagers,
			"wear": world.wear_to_save()}


## Áp ván đã lưu lên thế giới vừa dựng từ cùng seed (World.build đã chạy, chưa có thổ dân).
static func restore(world: World, save: Dictionary) -> void:
	_restore_nodes(world, save.get("nodes", []))
	_restore_buildings(world, save.get("buildings", []))
	world.refresh_storage_capacity()
	world.refresh_yards()
	world.apply_saved_wear(save.get("wear", []))
	GameState.apply_saved_resources(save.get("game", {}))
	_restore_villagers(world, save.get("villagers", []))
	world.refresh_staff()
	world.day_night.refresh_glows()


static func _restore_nodes(world: World, saved: Array) -> void:
	for i: int in saved.size():
		var dict: Dictionary = saved[i]
		var kind: StringName = StringName(str(dict.get("kind", "")))
		if i < world.resource_nodes.size() and world.resource_nodes[i].kind == kind:
			_apply_node(world, world.resource_nodes[i], dict)
			continue
		var cell_array: Array = dict.get("cell", [0, 0])
		var node: ResourceNode = world.place_resource(kind, Vector2i(int(cell_array[0]), int(cell_array[1])),
				int(dict.get("variant", 0)), Vector2.ZERO, false)
		_apply_node(world, node, dict)


# Áp trạng thái rồi sửa lại ô bị chặn (đá đã vỡ thì mở, đá mới lăn ra thì chặn).
static func _apply_node(world: World, node: ResourceNode, dict: Dictionary) -> void:
	var was_blocking: bool = not node.is_loose() and not node.is_cleared
	var old_cells: Array[Vector2i] = node.footprint_cells()
	node.apply_dict(dict)
	if node.is_loose() or node.kind == MapData.KIND_FISH_SPOT:
		return
	if was_blocking:
		for at: Vector2i in old_cells:
			world.grid.set_blocked(at, false)
	if not node.is_cleared:
		for at: Vector2i in node.footprint_cells():
			world.grid.set_blocked(at, true)


static func _restore_buildings(world: World, saved: Array) -> void:
	for dict: Dictionary in saved:
		var id: StringName = StringName(str(dict.get("id", "")))
		var cell_array: Array = dict.get("cell", [0, 0])
		var cell: Vector2i = Vector2i(int(cell_array[0]), int(cell_array[1]))
		var building: Building = world.building_at_cell(cell)
		if building == null or building.building_id != id or building.origin_cell != cell:
			building = world.add_building(id, cell, int(dict.get("level", 1)), int(dict.get("uid", 0)))
		building.apply_dict(dict)


static func _restore_villagers(world: World, saved: Array) -> void:
	for dict: Dictionary in saved:
		var data: VillagerData = VillagerData.from_dict(dict.get("data", {}))
		var status: VillagerStatus = VillagerStatus.from_dict(dict.get("status", {}))
		var pos_array: Array = dict.get("pos", [0.0, 0.0])
		var pos: Vector2 = Vector2(float(pos_array[0]), float(pos_array[1]))
		var cell: Vector2i = WorldGrid.world_to_cell(pos)
		if world.grid.is_blocked(cell):
			cell = world.finder.find_free_cell_near(cell, 1.0, 4.0)
			pos = WorldGrid.cell_to_world(cell)
		var villager: Villager = world.spawn_villager(data, cell, status, int(dict.get("id", 0)))
		villager.position = pos
		var anchor: Array = dict.get("anchor", [cell.x, cell.y])
		villager.anchor_cell = Vector2i(int(anchor[0]), int(anchor[1]))
		var job_dict: Dictionary = dict.get("job", {})
		if not job_dict.is_empty():
			villager.job = Job.from_dict(job_dict, villager)
			villager.notify_task_changed()
