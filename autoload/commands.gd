extends Node
## API chung của lõi cho MỌI hành động người chơi (và kịch bản như hoạt cảnh mở đầu).
## Controller và UI chỉ được đi qua đây, không sửa thẳng dữ liệu thổ dân hay thế giới
## — để chế độ Thần Linh sau này dùng lại y nguyên, chỉ khác controller gọi lệnh nào.
##
## Đợt sau thêm: place_building(type, cell), upgrade_building(id) (Đợt 3),
## apply_effect(effect_id, cell) (phép thần).

const INVALID_ID: int = -1

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


## Giao việc: `target` là cây, đá, bụi quả, chỗ câu cá, con thú, hoặc lửa trại (nấu ăn).
## Thổ dân nhớ việc này và tự làm đi làm lại. Trả về false nếu không giao được (không phải
## người lớn, chế độ không cho ra lệnh, mục tiêu không nhận việc, hoặc đã hết tài nguyên).
func assign_job(villager_id: int, target: Node) -> bool:
	var villager: Villager = _commandable(villager_id)
	if villager == null or not is_instance_valid(target):
		return false
	var skill: StringName = JobDefs.skill_for_target(target)
	if skill == &"":
		return false
	var node: Node2D = target as Node2D
	if node is ResourceNode and not (node as ResourceNode).can_harvest():
		villager.say(str(JobDefs.get_def(skill).get("none_bubble", "")), {}, SkillDefs.icon(skill))
		return false
	if node is Animal and not (node as Animal).is_huntable():
		return false
	villager.assign_job(Job.new(skill, node))
	EventBus.job_assigned.emit(villager, node)
	return true


## Bảo thổ dân đi tới ô `cell` rồi đứng chơi quanh đó (bỏ việc đang giao).
## Trả về false nếu ô bị chặn hoặc không có đường tới.
func move_villager(villager_id: int, cell: Vector2i) -> bool:
	var villager: Villager = _commandable(villager_id)
	if villager == null or _world.grid.is_blocked(cell):
		return false
	if not _world.grid.has_path(_world.cell_of(villager), cell):
		return false
	villager.order_move(cell)
	EventBus.move_ordered.emit(villager, cell)
	return true


## 0 = tạm dừng, 1..3 = tốc độ.
func set_game_speed(speed: int) -> void:
	GameState.set_speed(speed)


## Tạm dừng ↔ chạy lại tốc độ trước đó (phím Space).
func toggle_pause() -> void:
	GameState.toggle_pause()


func _on_world_ready(world: Node) -> void:
	_world = world as World


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
