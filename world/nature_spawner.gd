class_name NatureSpawner
extends Node
## Thiên nhiên tự hồi lại, chậm và có giới hạn để map không bao giờ cạn mà cũng không đầy:
## - Củi rơi dần dưới tán cây (tối đa TWIG_MAX bó nằm trên đất).
## - Đá cuội lăn ra quanh đá tảng (tối đa PEBBLE_MAX viên).
## - Đá tảng thỉnh thoảng lăn ra từ vách đá, chỉ khi số đá tảng ít hơn lúc mới sinh map.
## - Gốc cây mọc lại thành cây, chỉ khi số cây ít hơn lúc đầu.
## Củi và đá cuội không chặn đường; đá tảng thì có, nên chỉ đặt ở ô trống không ai đứng.

## Thử chừng này ô ngẫu nhiên mỗi lần tìm chỗ đặt.
const PLACE_ATTEMPTS: int = 12
const LOOSE_JITTER: Vector2 = Vector2(16, 12)

var _world: World
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _tree_cap: int = 0
var _boulder_cap: int = 0
var _twig_timer: float = 0.0
var _pebble_timer: float = 0.0
var _boulder_timer: float = 0.0
var _tree_timer: float = 0.0


func setup(world: World, seed_value: int) -> void:
	_world = world
	_rng.seed = seed_value
	_tree_cap = _count(MapData.KIND_TREE)
	_boulder_cap = _count(MapData.KIND_ROCK)
	for i: int in Balance.TWIG_START:
		spawn_twig()
	for i: int in Balance.PEBBLE_START:
		spawn_pebble()
	_twig_timer = _next_delay(Balance.TWIG_SPAWN_SECONDS)
	_pebble_timer = _next_delay(Balance.PEBBLE_SPAWN_SECONDS)
	_boulder_timer = _next_delay(Balance.BOULDER_SPAWN_SECONDS)
	_tree_timer = _next_delay(Balance.TREE_REGROW_CHECK_SECONDS)


func _process(delta: float) -> void:
	if _world == null:
		return
	_twig_timer -= delta
	if _twig_timer <= 0.0:
		_twig_timer = _next_delay(Balance.TWIG_SPAWN_SECONDS)
		spawn_twig()
	_pebble_timer -= delta
	if _pebble_timer <= 0.0:
		_pebble_timer = _next_delay(Balance.PEBBLE_SPAWN_SECONDS)
		spawn_pebble()
	_boulder_timer -= delta
	if _boulder_timer <= 0.0:
		_boulder_timer = _next_delay(Balance.BOULDER_SPAWN_SECONDS)
		spawn_boulder()
	_tree_timer -= delta
	if _tree_timer <= 0.0:
		_tree_timer = _next_delay(Balance.TREE_REGROW_CHECK_SECONDS)
		regrow_tree()


## Một bó củi rơi dưới một cái cây ngẫu nhiên. Trả về false nếu đã đủ / không có chỗ.
func spawn_twig() -> bool:
	if _count(MapData.KIND_TWIGS) >= Balance.TWIG_MAX:
		return false
	var trees: Array[ResourceNode] = _active(MapData.KIND_TREE)
	if trees.is_empty():
		return false
	return _drop_loose(MapData.KIND_TWIGS, trees[_rng.randi_range(0, trees.size() - 1)].cell)


## Một viên đá cuội lăn ra cạnh một đá tảng ngẫu nhiên.
func spawn_pebble() -> bool:
	if _count(MapData.KIND_PEBBLES) >= Balance.PEBBLE_MAX:
		return false
	var boulders: Array[ResourceNode] = _active(MapData.KIND_ROCK)
	if boulders.is_empty():
		return false
	return _drop_loose(MapData.KIND_PEBBLES, boulders[_rng.randi_range(0, boulders.size() - 1)].cell)


## Một đá tảng lăn ra sát chân một vách đá — chỉ khi đá tảng đã ít hơn lúc đầu.
func spawn_boulder() -> bool:
	var cliffs: Array[Vector2i] = _world.map_data.cliffs
	if cliffs.is_empty() or _count(MapData.KIND_ROCK) >= _boulder_cap:
		return false
	var cliff: Vector2i = cliffs[_rng.randi_range(0, cliffs.size() - 1)]
	var ring: Array[Vector2i] = MapGenerator.cells_around(cliff, BuildingDefs.footprint(&"cliff"))
	for attempt: int in PLACE_ATTEMPTS:
		var cell: Vector2i = ring[_rng.randi_range(0, ring.size() - 1)]
		if _can_block(cell):
			var variant: int = 0 if _rng.randf() < Balance.ROCK_BIG_CHANCE else 1
			_world.place_resource(MapData.KIND_ROCK, cell, variant)
			return true
	return false


## Một gốc cây đã để đủ lâu mọc lại thành cây — chỉ khi rừng còn ít cây hơn lúc đầu.
func regrow_tree() -> bool:
	if _count(MapData.KIND_TREE) >= _tree_cap:
		return false
	var stumps: Array[ResourceNode] = []
	for node: ResourceNode in _world.resource_nodes:
		if node.kind == MapData.KIND_TREE and node.is_depleted() and node.stump_age >= Balance.STUMP_MIN_SECONDS \
				and not _world.reservations.is_taken_by_other(node, self):
			stumps.append(node)
	if stumps.is_empty():
		return false
	stumps[_rng.randi_range(0, stumps.size() - 1)].regrow()
	return true


# Đặt củi / đá cuội ở một ô trống sát `around` (không chặn đường nên chỉ cần ô đi được).
func _drop_loose(kind: StringName, around: Vector2i) -> bool:
	for attempt: int in PLACE_ATTEMPTS:
		var cell: Vector2i = around + WorldGrid.NEIGHBORS_8[_rng.randi_range(0, WorldGrid.NEIGHBORS_8.size() - 1)]
		if _world.grid.is_blocked(cell) or _has_loose_at(cell):
			continue
		var jitter: Vector2 = Vector2(_rng.randf_range(-1.0, 1.0), _rng.randf_range(-1.0, 1.0)) * LOOSE_JITTER
		_world.place_resource(kind, cell, _rng.randi_range(0, 1), jitter)
		return true
	return false


# Ô đặt đá tảng được không: trống, không có đồ nằm trên đất, không ai/thú đứng gần,
# và vẫn đi tới được từ lửa trại (không chặn mất lối duy nhất).
func _can_block(cell: Vector2i) -> bool:
	if not _world.grid.in_bounds(cell) or _world.grid.is_blocked(cell) or _has_loose_at(cell):
		return false
	for villager: Villager in _world.villagers:
		if Vector2(_world.cell_of(villager) - cell).length() < 2.0:
			return false
	for animal: Animal in _world.animals:
		if Vector2(animal.current_cell() - cell).length() < 2.0:
			return false
	return _world.grid.has_path(_world.map_data.cave_entrance_cell, cell)


func _has_loose_at(cell: Vector2i) -> bool:
	for node: ResourceNode in _world.resource_nodes:
		if node.is_loose() and not node.is_cleared and node.cell == cell:
			return true
	return false


# Số cái còn dùng được (cây còn cây, đá chưa vỡ, củi chưa nhặt).
func _count(kind: StringName) -> int:
	return _active(kind).size()


func _active(kind: StringName) -> Array[ResourceNode]:
	var result: Array[ResourceNode] = []
	for node: ResourceNode in _world.resource_nodes:
		if node.kind == kind and not node.is_cleared and not node.is_depleted():
			result.append(node)
	return result


func _next_delay(average: float) -> float:
	return average * _rng.randf_range(0.6, 1.4)
