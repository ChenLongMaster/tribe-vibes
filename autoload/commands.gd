extends Node
## API chung của lõi cho MỌI hành động người chơi (và kịch bản như hoạt cảnh mở đầu).
## Controller và UI chỉ được đi qua đây, không sửa thẳng dữ liệu thổ dân hay thế giới
## — để chế độ Thần Linh sau này dùng lại y nguyên, chỉ khác controller gọi lệnh nào.
##
## Đợt sau thêm: apply_effect(effect_id, cell) (phép thần).

const INVALID_ID: int = -1
## Tản nhóm người ra quanh điểm đến tối đa chừng này ô.
const GROUP_SPREAD_MAX_RADIUS: int = 6

var _world: World


func _ready() -> void:
	EventBus.world_ready.connect(_on_world_ready)


## Đưa một thổ dân mới vào thế giới tại ô `cell`. Trả về mã số, hoặc INVALID_ID nếu
## chưa có thế giới / ô bị chặn.
func spawn_villager(data: VillagerData, cell: Vector2i) -> int:
	if not _has_world():
		return INVALID_ID
	if _world.grid.is_blocked(cell):
		push_warning("Commands.spawn_villager: ô %s bị chặn" % cell)
		return INVALID_ID
	return _world.spawn_villager(data, cell).id


## Thổ dân theo mã số (null nếu không có). Chỉ để ĐỌC — muốn đổi gì thì thêm lệnh vào đây.
func get_villager(villager_id: int) -> Villager:
	if not _has_world():
		return null
	return _world.get_villager(villager_id)


## Giao việc: `target` là cây, đá tảng, bụi quả, củi, đá cuội, chỗ câu cá, con thú, hoặc một
## công trình: móng / công trình đang nâng cấp (xây), lửa trại / Bếp (nấu), lò rèn (rèn), lều
## (đi ngủ), sân nhảy (lên chơi), công trình khác (đi tới đứng cạnh). Thổ dân nhớ việc này và
## tự làm đi làm lại. Trả về false nếu không giao được (không phải người lớn, chế độ không cho
## ra lệnh, mục tiêu không nhận việc, đã hết tài nguyên, đủ người rồi, hoặc làng không có đồ
## nghề cần cho việc đó — thổ dân giơ biển giải thích).
func assign_job(villager_id: int, target: Node) -> bool:
	var villager: Villager = _commandable(villager_id)
	if villager == null or not is_instance_valid(target):
		return false
	var job_id: StringName = JobDefs.job_for_target(target)
	if job_id == &"":
		if target is Building:
			return _send_to_building(villager, target as Building)
		return false
	var node: Node2D = target as Node2D
	if node is Building and not Job.building_has_room(node as Building, villager, job_id):
		# Đủ người rồi (thợ xây tối đa theo diện tích, người phụ trách theo cấp).
		villager.hold_sign(JobDefs.icon(job_id), true)
		return false
	if node is ResourceNode and not (node as ResourceNode).can_harvest():
		villager.hold_sign(JobDefs.icon(job_id), true)
		return false
	if node is Animal and not (node as Animal).is_huntable():
		return false
	var tool: StringName = JobDefs.required_tool(job_id)
	if tool != &"" and villager.tool != tool and not _world.finder.has_tool_in_stock(tool):
		# Chưa có cuốc: tự nhặt đá cuội ngay cạnh tảng đá (nghĩ tới cái cuốc cho người chơi biết).
		var fallback: Node2D = _fallback_target(job_id, node, villager)
		if fallback != null:
			villager.assign_job(Job.new(JobDefs.fallback_job(job_id), fallback))
			villager.think(ToolDefs.icon(tool))
			EventBus.job_assigned.emit(villager, fallback)
			return true
		# Biển "cần món này" — chỉ vẽ món đó, không gạch chéo.
		villager.hold_sign(ToolDefs.icon(tool))
		return false
	villager.assign_job(Job.new(job_id, node))
	EventBus.job_assigned.emit(villager, node)
	return true


## Giao việc cho cả nhóm. Vật chỉ một người làm được (cây, đá, bụi…) thì mỗi người nhận một
## cái tương tự gần đó (không xúm vào một cây); công trình thì cùng vào đó (thừa người thì người
## thừa cắm biển). Trả về số người nhận việc.
func assign_group(villager_ids: Array[int], target: Node) -> int:
	if not _has_world():
		return 0
	var job_id: StringName = JobDefs.job_for_target(target)
	var taken: Array[Node2D] = []
	var count: int = 0
	for villager_id: int in villager_ids:
		var mine: Node = target
		var villager: Villager = _commandable(villager_id)
		if villager != null and job_id != &"" and not (target is Building) and taken.has(target as Node2D):
			var near: Node2D = _world.finder.find_job_target(job_id, Job.target_cell(target as Node2D), villager, taken)
			if near != null:
				mine = near
		if assign_job(villager_id, mine):
			count += 1
			if mine is Node2D:
				taken.append(mine as Node2D)
	return count


## Bảo cả nhóm đi tới quanh ô `cell`: mỗi người một ô trống gần đó (không đứng chồng lên nhau).
## Trả về số người đi.
func move_group(villager_ids: Array[int], cell: Vector2i) -> int:
	if not _has_world():
		return 0
	var spots: Array[Vector2i] = _spread_cells(cell, villager_ids.size())
	var count: int = 0
	for i: int in mini(spots.size(), villager_ids.size()):
		if move_villager(villager_ids[i], spots[i]):
			count += 1
	return count


## Bảo thổ dân đi tới ô `cell` rồi đứng chơi quanh đó (bỏ việc đang giao).
## Trả về false nếu ô bị chặn hoặc không có đường tới.
func move_villager(villager_id: int, cell: Vector2i) -> bool:
	var villager: Villager = _commandable(villager_id)
	if villager == null or _world.grid.is_blocked(cell):
		return false
	if not _world.grid.has_path(villager.path_origin(), cell):
		return false
	villager.order_move(cell)
	EventBus.move_ordered.emit(villager, cell)
	return true


# --- Công trình ---

## Công trình theo mã số (null nếu không có). Chỉ để ĐỌC.
func get_building(building_uid: int) -> Building:
	if not _has_world():
		return null
	return _world.get_building(building_uid)


## Đặt móng công trình `building_id` với ô trên-trái `cell` được không (trống, không chặn lối).
func can_place_building(building_id: StringName, cell: Vector2i) -> bool:
	return _has_world() and _world.placer.can_place(building_id, cell)


## Đặt móng. Vật liệu không trừ ngay — thợ xây khuân từ kho tới. Trả về mã số công trình,
## hoặc INVALID_ID nếu không đặt được.
func place_building(building_id: StringName, cell: Vector2i) -> int:
	if not _has_world():
		return INVALID_ID
	var building: Building = _world.placer.place(building_id, cell)
	if building == null:
		return INVALID_ID
	EventBus.village_event.emit("TOAST_FOUNDATION_PLACED", {"building_key": building.name_key()}, "icons/skill_build")
	return building.uid


## Nâng cấp lên cấp kế tiếp: thành công trường (cần thợ xây khuân vật liệu tới), trong lúc đó
## vẫn hoạt động ở cấp cũ.
func upgrade_building(building_uid: int) -> bool:
	var building: Building = get_building(building_uid)
	if building == null or not building.can_upgrade():
		return false
	building.start_construction(building.level + 1)
	return true


## Huỷ lượt xây đang dở (móng thì bỏ hẳn, nâng cấp thì giữ cấp cũ). Vật liệu đã đổ vào được
## cất lại kho chung.
func cancel_construction(building_uid: int) -> bool:
	var building: Building = get_building(building_uid)
	if building == null or not building.is_constructing():
		return false
	var refund: Dictionary = building.cancel_construction()
	for resource_id: StringName in refund:
		GameState.add_resource(resource_id, int(refund[resource_id]))
	if building.demolished:
		_world.remove_building(building)
	return true


## Lò rèn: đặt số món `tool` còn muốn rèn (0..FORGE_MAX_ORDER).
func set_forge_order(building_uid: int, tool: StringName, count: int) -> bool:
	var building: Building = get_building(building_uid)
	if building == null or not building.def.get("forge", false) or not ToolDefs.DEFS.has(tool):
		return false
	building.set_order(tool, count)
	return true


# --- Lưu & tải ---

## Lưu ván đang chơi xuống máy. `auto` = tự lưu đầu ngày.
func save_game(auto: bool = false) -> bool:
	if not _has_world():
		return false
	var ok: bool = SaveSystem.write_save(SaveGame.capture(_world))
	if ok:
		EventBus.game_saved.emit(auto)
		EventBus.village_event.emit("TOAST_AUTOSAVED" if auto else "TOAST_SAVED", {"day": GameState.day}, "icons/save")
	return ok


## Tải ván đã lưu: cả cảnh được dựng lại (main lo phần đó). false nếu chưa có ván nào.
func load_game() -> bool:
	if not SaveSystem.has_save():
		return false
	EventBus.load_requested.emit()
	return true


## CHỈ ĐỂ TEST / CÔNG CỤ: cất thêm `amount` mỗi loại đồ nghề vào lò rèn (chưa có thì hang đá)
## để thử chặt cây, đập đá, săn mà không phải rèn. Không có trong luồng chơi bình thường.
func debug_give_tools(amount: int = 1) -> void:
	if not _has_world():
		return
	var rack: Building = null
	for building: Building in _world.buildings:
		if building.is_built() and building.def.get("forge", false):
			rack = building
			break
		if building.building_id == BuildingDefs.CAVE and rack == null:
			rack = building
	if rack != null:
		for tool: StringName in ToolDefs.ORDER:
			rack.add_stock(tool, amount, true)


## 0 = tạm dừng, 1..3 = tốc độ.
func set_game_speed(speed: int) -> void:
	GameState.set_speed(speed)


## Vô hạn ba tài nguyên chung khi debug; không thay lượng thật hoặc cờ trong save.
func toggle_dev_mode() -> void:
	GameState.set_dev_mode(not GameState.is_dev_mode())


## Tạm dừng ↔ chạy lại tốc độ trước đó (phím Space).
func toggle_pause() -> void:
	GameState.toggle_pause()


func _on_world_ready(world: Node) -> void:
	_world = world as World


# Các ô trống gần `cell` nhất (theo từng vòng), dùng để tản một nhóm người ra.
func _spread_cells(cell: Vector2i, count: int) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	if not _world.grid.is_blocked(cell):
		result.append(cell)
	var radius: int = 1
	while result.size() < count and radius <= GROUP_SPREAD_MAX_RADIUS:
		var ring: Array[Vector2i] = []
		for y: int in range(-radius, radius + 1):
			for x: int in range(-radius, radius + 1):
				if maxi(absi(x), absi(y)) == radius:
					ring.append(cell + Vector2i(x, y))
		ring.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
			return Vector2(a - cell).length_squared() < Vector2(b - cell).length_squared())
		for spot: Vector2i in ring:
			if result.size() >= count:
				break
			if not _world.grid.is_blocked(spot):
				result.append(spot)
		radius += 1
	return result


# Mục tiêu tay không sát bên cho việc thiếu đồ nghề (vd đá cuội quanh tảng đá), hoặc null.
func _fallback_target(job_id: StringName, node: Node2D, villager: Villager) -> Node2D:
	var fallback: StringName = JobDefs.fallback_job(job_id)
	if fallback == &"":
		return null
	return _world.finder.find_job_target(fallback, Job.target_cell(node), villager, [], Balance.TOOL_FALLBACK_RADIUS_CELLS)


# Công trình không có việc để giao: lều → đi ngủ ngay (nếu còn chỗ), sân nhảy → lên đứng chơi
# trên sân, còn lại → đi tới đứng cạnh. Việc đang giao vẫn nhớ khi đi ngủ; đi chơi / đi tới
# thì bỏ việc (như chạm mặt đất).
func _send_to_building(villager: Villager, building: Building) -> bool:
	if not building.is_built():
		return false
	match building.action():
		BuildingDefs.ACTION_SLEEP:
			var spot: SleepSpot = _world.finder.find_tent_bed(villager, building)
			if spot == null:
				villager.hold_sign("icons/sleepy", true)
				return false
			villager.order_sleep(spot)
			EventBus.job_assigned.emit(villager, building)
			return true
		BuildingDefs.ACTION_DANCE:
			var cells: Array[Vector2i] = building.footprint_cells()
			cells.shuffle()
			for cell: Vector2i in cells:
				if _world.grid.has_path(villager.path_origin(), cell):
					villager.order_move(cell)
					EventBus.move_ordered.emit(villager, cell)
					return true
			return false
	var stand: Vector2i = _world.finder.find_building_stand_cell(building, villager)
	if stand == World.INVALID_CELL:
		return false
	villager.order_move(stand)
	EventBus.move_ordered.emit(villager, stand)
	return true


# Thổ dân nhận lệnh được không: có thật, là người lớn, chế độ cho ra lệnh trực tiếp.
func _commandable(villager_id: int) -> Villager:
	if not GameState.get_mode().allow_direct_commands:
		return null
	var villager: Villager = get_villager(villager_id)
	if villager == null or not villager.data.is_adult():
		return null
	return villager


func _has_world() -> bool:
	if not is_instance_valid(_world):
		push_warning("Commands: chưa có thế giới")
		return false
	return true
