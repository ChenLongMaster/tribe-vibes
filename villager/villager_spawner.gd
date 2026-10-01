class_name VillagerSpawner
extends Node
## Đưa thổ dân vào thế giới. Lúc mở đầu: tạo cả bộ lạc (nửa nam nửa nữ) rồi cho từng
## người lần lượt chui ra khỏi hang. Cùng seed map thì ra cùng một bộ lạc.

## Cộng vào seed map để bộ lạc ngẫu nhiên khác với map nhưng vẫn lặp lại được.
const SEED_SALT: int = 7919

var _queue: Array[VillagerData] = []
var _world: World
var _timer: float = 0.0


func _ready() -> void:
	set_process(false)


func start_intro(world: World) -> void:
	_world = world
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = world.map_data.map_seed + SEED_SALT
	var taken: PackedStringArray = []
	for i: int in Balance.START_VILLAGERS:
		var gender: VillagerData.Gender = VillagerData.Gender.MALE if i % 2 == 0 else VillagerData.Gender.FEMALE
		var data: VillagerData = VillagerFactory.create(rng, GameState.next_villager_id(), gender, Loc.get_language(), taken)
		taken.append(data.display_name)
		_queue.append(data)
	_timer = 0.0
	set_process(true)


func is_done() -> bool:
	return _queue.is_empty()


func _process(delta: float) -> void:
	_timer -= delta
	if _timer > 0.0:
		return
	_timer = Balance.INTRO_INTERVAL
	var data: VillagerData = _queue.pop_front()
	var entrance: Vector2 = WorldGrid.cell_to_world(_world.map_data.cave_entrance_cell)
	var villager: Villager = _world.spawn_villager(data, entrance)
	villager.start_task(TaskEmerge.new())
	if _queue.is_empty():
		set_process(false)
