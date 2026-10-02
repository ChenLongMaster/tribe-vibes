class_name Job
extends RefCounted
## Việc người chơi GIAO cho một thổ dân (chặt cây, đập đá, săn…). Khác với Task (việc đang
## làm ngay lúc này): Job là thứ thổ dân GHI NHỚ. Mỗi lượt (làm → khuân về kho) là một Task
## do Job tạo ra; bị ngắt giữa chừng (đói, mệt, đình công) thì Task mất nhưng Job còn, nên
## xong chuyện là tự quay lại làm tiếp (MVP_PROMPT mục 5.2).
##
## Hết mục tiêu thì tìm cái tương tự gần đó (JobDefs.search_radius); không còn thì bộ não
## dừng việc và cho thổ dân nói vì sao.

## Loại việc = kỹ năng (SkillDefs.CHOP, MINE…), tra cách làm trong JobDefs.
var skill: StringName = &""
## Mục tiêu hiện tại (ResourceNode, Animal hoặc Building). Có thể đổi sang cái tương tự.
var target: Node2D
## Tâm vùng tìm mục tiêu tương tự — ô của mục tiêu gần nhất đã làm.
var origin_cell: Vector2i = Vector2i.ZERO
## Đồ đang khuân dở khi bị ngắt — lượt sau khuân nốt về kho trước rồi mới làm tiếp.
var carried_resource: StringName = &""
var carried_amount: int = 0
## Chờ (giây) trước khi được nhắc lại bong bóng "Chưa có gì để nấu…" — đỡ nói liên tục.
var nag_cooldown: float = 0.0

var _failures: int = 0
## Mục tiêu vừa không tới được — lần tìm sau bỏ qua cho tới khi làm được một lượt.
var _skipped: Array[Node2D] = []


func _init(job_skill: StringName, first_target: Node2D) -> void:
	skill = job_skill
	target = first_target
	origin_cell = target_cell(first_target)


func def() -> Dictionary:
	return JobDefs.get_def(skill)


func icon_key() -> String:
	return SkillDefs.icon(skill)


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
		return resource.can_harvest() and not villager.world.reservations.is_taken_by_other(resource, villager)
	if node is Animal:
		var animal: Animal = node as Animal
		return animal.is_huntable() and not villager.world.reservations.is_taken_by_other(animal, villager)
	return node is Building


## Lượt việc tiếp theo, hoặc null nếu không còn gì để làm (bộ não sẽ dừng việc).
func next_task(villager: Villager) -> Task:
	if carried_amount > 0:
		return TaskDeliver.new(self)
	if gave_up():
		return null
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
	target = villager.world.finder.find_job_target(skill, origin_cell, villager, _skipped)
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


## Bong bóng khi dừng việc: không tới được, hay hết thứ để làm.
func stop_bubble() -> String:
	return "BUBBLE_CANT_REACH" if gave_up() else str(def().get("none_bubble", ""))


## Để lưu game (Đợt 3): chỉ cần loại việc + chỗ làm + đồ đang khuân.
func to_dict() -> Dictionary:
	return {
		"skill": String(skill),
		"origin_cell": [origin_cell.x, origin_cell.y],
		"carried_resource": String(carried_resource),
		"carried_amount": carried_amount,
	}
