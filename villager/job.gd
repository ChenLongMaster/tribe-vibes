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
## Mục tiêu vừa không tới được — lần tìm sau bỏ qua cho tới khi làm được một lượt.
var _skipped: Array[Node2D] = []


func _init(id: StringName, first_target: Node2D) -> void:
	job_id = id
	skill = JobDefs.skill_of(id)
	target = first_target
	origin_cell = target_cell(first_target)


func def() -> Dictionary:
	return JobDefs.get_def(job_id)


func icon_key() -> String:
	return JobDefs.icon(job_id)


## Hình vẽ trên tấm biển khi phải dừng việc: thiếu đồ nghề thì vẽ món đó, không thì vẽ việc.
func stop_sign_icon() -> String:
	if _missing_tool:
		return ToolDefs.icon(JobDefs.required_tool(job_id))
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


## Mục tiêu này còn làm được không (còn tài nguyên, chưa ai khác nhận).
static func is_workable(node: Node2D, villager: Villager) -> bool:
	if not is_instance_valid(node):
		return false
	if node is ResourceNode:
		var resource: ResourceNode = node as ResourceNode
		return resource.visible and resource.can_harvest() and not villager.world.reservations.is_taken_by_other(resource, villager)
	if node is Animal:
		var animal: Animal = node as Animal
		return animal.is_huntable() and not villager.world.reservations.is_taken_by_other(animal, villager)
	return node is Building


## Lượt việc tiếp theo, hoặc null nếu không còn gì để làm (bộ não sẽ dừng việc).
func next_task(villager: Villager) -> Task:
	if carried_count > 0:
		return TaskDeliver.new(self)
	if gave_up():
		return null
	var tool: StringName = JobDefs.required_tool(job_id)
	_missing_tool = false
	if tool != &"" and villager.tool != tool:
		var rack: Building = villager.world.finder.find_tool(tool, villager)
		if rack == null:
			_missing_tool = true
			return null
		return TaskFetchTool.new(self, rack, tool)
	var node: Node2D = pick_target(villager)
	if node == null:
		return null
	if node is Animal:
		return TaskHunt.new(self, node as Animal)
	if node is Building:
		return TaskCook.new(self, node as Building)
	return TaskHarvest.new(self, node as ResourceNode)


## Giữ mục tiêu cũ nếu còn làm được, không thì tìm cái tương tự gần đó.
func pick_target(villager: Villager) -> Node2D:
	if not _skipped.has(target) and is_workable(target, villager):
		return target
	target = villager.world.finder.find_job_target(job_id, origin_cell, villager, _skipped)
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


## Để lưu game (Đợt 3): chỉ cần loại việc + chỗ làm + đồ đang khuân.
func to_dict() -> Dictionary:
	return {
		"job": String(job_id),
		"origin_cell": [origin_cell.x, origin_cell.y],
		"carried_item": String(carried_item),
		"carried_count": carried_count,
	}
