class_name Job
extends RefCounted
## Việc người chơi GIAO cho một thổ dân (chặt cây, đập đá, săn…). Khác với Task (việc đang
## làm ngay lúc này): Job là thứ thổ dân GHI NHỚ. Mỗi lượt (làm → khuân về kho) là một Task
## do Job tạo ra; bị ngắt giữa chừng (đói, mệt, đình công) thì Task mất nhưng Job còn, nên
## xong chuyện là tự quay lại làm tiếp (GAME_DESIGN mục 5.2).
##
## Hết mục tiêu thì tìm cái tương tự gần đó (JobDefs.search_radius); không còn thì bộ não
## dừng việc và cho thổ dân giơ biển vì sao. Việc cần đồ nghề (rìu, cuốc, giáo) thì lượt đầu
## là đi lấy đồ nghề; không còn món nào thì dừng việc, giơ biển vẽ món đó gạch chéo.
## Kho chung đã đầy loại đồ việc này làm ra thì cũng dừng, giơ biển vẽ cái kho gạch chéo.
## Việc xây: xây xong thì tìm công trình dở khác gần đó; không còn thì dừng (vui vẻ, không biển).

const STORAGE_FULL_ICON: String = "icons/storage"

## Loại việc (JobDefs.CHOP, TWIGS…), tra cách làm trong JobDefs.
var job_id: StringName = &""
## Kỹ năng luyện được khi làm việc này (SkillDefs) — một kỹ năng có thể có nhiều việc.
var skill: StringName = &""
## Mục tiêu hiện tại (ResourceNode, Animal hoặc Building). Có thể đổi sang cái tương tự.
var target: Node2D
## Tâm vùng tìm mục tiêu tương tự — ô của mục tiêu gần nhất đã làm.
var origin_cell: Vector2i = Vector2i.ZERO
## Món đang khuân dở khi bị ngắt — lượt sau khuân nốt về kho trước rồi mới làm tiếp.
var carried_item: StringName = &""
var carried_count: int = 0
## Chờ (giây) trước khi được nhắc lại bong bóng "Chưa có gì để nấu…" — đỡ nói liên tục.
var nag_cooldown: float = 0.0

var _failures: int = 0
## Lần tìm gần nhất không còn đồ nghề cần thiết ở đâu cả.
var _missing_tool: bool = false
## Lần tìm gần nhất kho chung đã đầy loại đồ việc này làm ra.
var _storage_full: bool = false
## Việc xây kết thúc vì công trình đã xây xong (không phải vì thiếu gì) — ăn mừng, không giơ biển.
var finished_building: bool = false
## Mục tiêu vừa không tới được — lần tìm sau bỏ qua cho tới khi làm được một lượt.
var _skipped: Array[Node2D] = []


func _init(id: StringName, first_target: Node2D) -> void:
	job_id = id
	skill = JobDefs.skill_of(id)
	target = first_target
	if first_target != null:
		origin_cell = target_cell(first_target)


func def() -> Dictionary:
	return JobDefs.get_def(job_id)


func icon_key() -> String:
	return JobDefs.icon(job_id)


## Hình vẽ trên tấm biển khi phải dừng việc: thiếu đồ nghề thì vẽ món đó, kho đầy thì vẽ cái
## kho, không thì vẽ việc (hết cây, hết đá…).
## Biển "thiếu đồ nghề" chỉ vẽ món cần (không gạch chéo); "hết rồi" / "kho đầy" thì gạch chéo.
func stop_sign_crossed() -> bool:
	return not _missing_tool


func stop_sign_icon() -> String:
	if _missing_tool:
		return ToolDefs.icon(JobDefs.required_tool(job_id))
	if _storage_full:
		return STORAGE_FULL_ICON
	return icon_key()


## Ô của một mục tiêu bất kỳ.
static func target_cell(node: Node2D) -> Vector2i:
	if node is ResourceNode:
		return (node as ResourceNode).cell
	if node is Animal:
		return (node as Animal).current_cell()
	if node is Building:
		return (node as Building).origin_cell
	return WorldGrid.world_to_cell(node.position)


## Mục tiêu này còn làm được không (còn tài nguyên, chưa ai khác nhận; công trình thì đúng
## loại việc và còn chỗ cho thêm người).
static func is_workable(node: Node2D, villager: Villager, for_job: StringName = &"") -> bool:
	if not is_instance_valid(node):
		return false
	if node is Building:
		return building_has_room(node as Building, villager, for_job)
	if node is ResourceNode:
		var resource: ResourceNode = node as ResourceNode
		return resource.visible and resource.can_harvest() 				and not villager.world.reservations.is_taken_by_other(resource, villager, resource.max_workers())
	if node is Animal:
		var animal: Animal = node as Animal
		return animal.is_huntable() and not villager.world.reservations.is_taken_by_other(animal, villager)
	return false


## Công trình còn nhận thêm người làm việc `for_job` không: đúng loại (móng/bếp/lò rèn), chưa
## đủ thợ xây (max(1, số ô ÷ 2)) hoặc chưa đủ người phụ trách (theo cấp).
static func building_has_room(building: Building, villager: Villager, for_job: StringName) -> bool:
	if building.demolished:
		return false
	var wanted: StringName = for_job if for_job != &"" else JobDefs.job_for_target(building)
	if not JobDefs.building_accepts_job(building, wanted):
		return false
	var limit: int = BuildingDefs.max_builders(building.building_id) if wanted == JobDefs.BUILD else building.staff_capacity()
	var count: int = 0
	for other: Villager in villager.world.villagers:
		if other != villager and other.job != null and other.job.target == building and other.job.job_id == wanted:
			count += 1
	return count < limit


## Lượt việc tiếp theo, hoặc null nếu không còn gì để làm (bộ não sẽ dừng việc).
func next_task(villager: Villager) -> Task:
	if carried_count > 0:
		return TaskDeliver.new(self)
	if gave_up():
		return null
	var tool: StringName = JobDefs.required_tool(job_id)
	_missing_tool = false
	_storage_full = false
	var item: StringName = def().get("item", &"")
	if item != &"" and GameState.room(ResourceDefs.item_resource(item)) <= 0:
		_storage_full = true
		return null
	if tool != &"" and villager.tool != tool:
		var rack: Building = villager.world.finder.find_tool(tool, villager)
		if rack == null:
			# Hết đồ nghề giữa chừng: có việc tay không thay thế ngay cạnh thì chuyển sang làm
			# (vd không còn cuốc → nhặt đá cuội quanh tảng đá).
			if _switch_to_fallback(villager):
				return next_task(villager)
			_missing_tool = true
			return null
		return TaskFetchTool.new(self, rack, tool)
	var node: Node2D = pick_target(villager)
	if node == null:
		return null
	if node is Animal:
		return TaskHunt.new(self, node as Animal)
	if node is Building:
		match job_id:
			JobDefs.BUILD:
				return TaskBuild.new(self, node as Building)
			JobDefs.SMITH:
				return TaskSmith.new(self, node as Building)
		return TaskCook.new(self, node as Building)
	return TaskHarvest.new(self, node as ResourceNode)


func _switch_to_fallback(villager: Villager) -> bool:
	var fallback: StringName = JobDefs.fallback_job(job_id)
	if fallback == &"":
		return false
	var near: Node2D = villager.world.finder.find_job_target(fallback, origin_cell, villager, [],
			Balance.TOOL_FALLBACK_RADIUS_CELLS)
	if near == null:
		return false
	job_id = fallback
	skill = JobDefs.skill_of(fallback)
	target = near
	origin_cell = target_cell(near)
	villager.notify_task_changed()
	return true


## Giữ mục tiêu cũ nếu còn làm được, không thì tìm cái tương tự gần đó.
func pick_target(villager: Villager) -> Node2D:
	if not _skipped.has(target) and is_workable(target, villager, job_id):
		return target
	if job_id == JobDefs.BUILD and target is Building and (target as Building).is_built() \
			and not (target as Building).is_constructing():
		finished_building = true
	target = villager.world.finder.find_job_target(job_id, origin_cell, villager, _skipped)
	if target != null:
		finished_building = false
	if target != null:
		origin_cell = target_cell(target)
	return target


## Bộ não báo kết quả một lượt: hỏng thì bỏ qua mục tiêu đó lần sau.
func report(result: Task.Status) -> void:
	if result == Task.Status.FAILED:
		_failures += 1
		if is_instance_valid(target) and not _skipped.has(target):
			_skipped.append(target)
		target = null
	else:
		_failures = 0
		_skipped.clear()


## Không tới được mục tiêu nhiều lần liền — thôi, đứng chờ lệnh mới.
func gave_up() -> bool:
	return _failures >= Balance.JOB_MAX_FAILURES


## Để lưu game: chỉ cần loại việc + chỗ làm (ô / công trình) + đồ đang khuân.
func to_dict() -> Dictionary:
	return {
		"job": String(job_id),
		"origin_cell": [origin_cell.x, origin_cell.y],
		"building_uid": (target as Building).uid if target is Building else 0,
		"carried_item": String(carried_item),
		"carried_count": carried_count,
	}


## Dựng lại việc đã lưu cho `villager` (đã ở trong thế giới). Mục tiêu: đúng công trình cũ,
## hoặc vật cùng loại nằm ở ô cũ; không còn thì lượt sau tự tìm cái tương tự quanh đó.
static func from_dict(dict: Dictionary, villager: Villager) -> Job:
	var id: StringName = StringName(str(dict.get("job", "")))
	if not JobDefs.has_job(id):
		return null
	var cell_array: Array = dict.get("origin_cell", [0, 0])
	var cell: Vector2i = Vector2i(int(cell_array[0]), int(cell_array[1]))
	var found: Node2D = null
	var uid: int = int(dict.get("building_uid", 0))
	if uid > 0:
		found = villager.world.get_building(uid)
	else:
		var kind: StringName = JobDefs.get_def(id).get("target", &"")
		for node: ResourceNode in villager.world.resource_nodes:
			if node.kind == kind and node.cell == cell:
				found = node
				break
	var job: Job = Job.new(id, found)
	job.origin_cell = cell
	job.carried_item = StringName(str(dict.get("carried_item", "")))
	job.carried_count = int(dict.get("carried_count", 0))
	return job
