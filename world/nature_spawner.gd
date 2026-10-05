class_name NatureSpawner
extends Node
## Thiên nhiên tự hồi lại, chậm và có giới hạn để map không bao giờ cạn mà cũng không đầy
## (GAME_DESIGN mục 9.1–9.2):
## - Cây trưởng thành rụng cành: thêm củi vào đống củi cạnh cây, chưa có thì thành đống mới
##   (tối đa TWIG_PILE_MAX đống). Rụng nhiều ở rừng rậm hơn cây lẻ.
## - Vách đá lở: chỗ chân vách (phía trước) lở ra một tảng đá (chỉ khi đá tảng ít hơn lúc mới
##   sinh map) hoặc một ít sỏi (vào bãi sỏi gần đó, chưa có thì thành bãi mới — tối đa
##   PEBBLE_PATCH_MAX bãi).
## - Gốc cây mọc lại thành cây non (rồi lớn dần), chỉ khi số cây ít hơn lúc đầu.
## Sỏi và củi không chặn đường; đá tảng thì có, nên chỉ đặt ở ô trống không ai đứng.

## Thử chừng này ô ngẫu nhiên mỗi lần tìm chỗ đặt.
const PLACE_ATTEMPTS: int = 12
const LOOSE_JITTER: Vector2 = Vector2(9, 6)
## Chọn cây rụng cành: bốc thêm chừng này cây, lấy cây nằm trong rừng dày nhất.
const SOURCE_PICKS: int = 3
## Sỏi / củi rơi gần một bãi / đống có sẵn trong chừng này ô thì dồn vào đó.
const MERGE_RADIUS_CELLS: float = 1.5

var _world: World
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _tree_cap: int = 0
var _boulder_cap: int = 0
var _cliff_cells: Dictionary[Vector2i, bool] = {}
## Ô vách đá ở chân (ô phía nam không phải vách) — chỗ đá lở ra.
var _cliff_feet: Array[Vector2i] = []
var _twig_timer: float = 0.0
var _slide_timer: float = 0.0
var _tree_timer: float = 0.0


func setup(world: World, seed_value: int) -> void:
	_world = world
	_rng.seed = seed_value
	_cliff_cells.clear()
	_cliff_feet.clear()
	for cell: Vector2i in world.map_data.cliffs:
		_cliff_cells[cell] = true
	for cell: Vector2i in world.map_data.cliffs:
		if not _cliff_cells.has(cell + Vector2i.DOWN):
			_cliff_feet.append(cell)
	_tree_cap = _count(MapData.KIND_TREE)
	_boulder_cap = _count(MapData.KIND_ROCK)
	_twig_timer = _next_delay(Balance.TWIG_DROP_SECONDS)
	_slide_timer = _next_delay(Balance.CLIFF_SLIDE_SECONDS)
	_tree_timer = _next_delay(Balance.TREE_REGROW_CHECK_SECONDS)


func _process(delta: float) -> void:
	if _world == null:
		return
	_twig_timer -= delta
	if _twig_timer <= 0.0:
		_twig_timer = _next_delay(Balance.TWIG_DROP_SECONDS)
		spawn_twig()
	_slide_timer -= delta
	if _slide_timer <= 0.0:
		_slide_timer = _next_delay(Balance.CLIFF_SLIDE_SECONDS)
		if _rng.randf() >= Balance.CLIFF_SLIDE_BOULDER_CHANCE or not spawn_boulder():
			spawn_pebble()
	_tree_timer -= delta
	if _tree_timer <= 0.0:
		_tree_timer = _next_delay(Balance.TREE_REGROW_CHECK_SECONDS)
		regrow_tree()


## Một cây trưởng thành rụng cành thành củi. Trả về false nếu không có chỗ / đã đủ đống.
func spawn_twig() -> bool:
	var trees: Array[ResourceNode] = []
	var tree_cells: Dictionary[Vector2i, bool] = {}
	for node: ResourceNode in _active(MapData.KIND_TREE):
		if node.is_mature():
			trees.append(node)
			tree_cells[node.cell] = true
	if trees.is_empty():
		return false
	var best: ResourceNode = trees[_rng.randi_range(0, trees.size() - 1)]
	var best_count: int = _count_near(best.cell, tree_cells)
	for i: int in SOURCE_PICKS:
		var other: ResourceNode = trees[_rng.randi_range(0, trees.size() - 1)]
		var other_count: int = _count_near(other.cell, tree_cells)
		if other_count > best_count:
			best = other
			best_count = other_count
	return _drop(MapData.KIND_TWIGS, best.cell, Vector2i(-1, -1), Vector2i(1, 1), Balance.TWIG_DROP_AMOUNT,
			Balance.TWIG_PILE_MAX)


## Vách đá lở ra một ít sỏi ở chân vách (phía trước).
func spawn_pebble() -> bool:
	if _cliff_feet.is_empty():
		return false
	var foot: Vector2i = _cliff_feet[_rng.randi_range(0, _cliff_feet.size() - 1)]
	return _drop(MapData.KIND_PEBBLES, foot, Vector2i(-1, 1), Vector2i(1, 2), Balance.CLIFF_SLIDE_PEBBLES,
			Balance.PEBBLE_PATCH_MAX)


## Vách đá lở ra một tảng đá ở chân vách — chỉ khi đá tảng đã ít hơn lúc đầu.
func spawn_boulder() -> bool:
	if _cliff_feet.is_empty() or _count(MapData.KIND_ROCK) >= _boulder_cap:
		return false
	for attempt: int in PLACE_ATTEMPTS:
		var foot: Vector2i = _cliff_feet[_rng.randi_range(0, _cliff_feet.size() - 1)]
		var cell: Vector2i = foot + Vector2i(_rng.randi_range(-1, 1), _rng.randi_range(1, 2))
		if _cliff_cells.has(cell) or _behind_cliff(cell) or not _can_block_cluster(cell):
			continue
		var variant: int = 2
		var start: int = Balance.ROCK_CLUSTER_STONE
		var node: ResourceNode = _world.place_resource(MapData.KIND_ROCK, cell, variant, _jitter(), true, start)
		node.pop(0.2)
		EventBus.work_impact.emit(node.position, JobDefs.IMPACT_STONE)
		return true
	return false


## Một gốc cây đã để đủ lâu mọc lại thành cây non — chỉ khi rừng còn ít cây hơn lúc đầu.
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


# Rơi `amount` sỏi / củi quanh `around` (trong khung offset `from`..`to`): dồn vào bãi / đống có
# sẵn ở gần nếu còn chỗ, không thì thành bãi / đống mới (nếu chưa đủ `max_piles`).
func _drop(kind: StringName, around: Vector2i, from: Vector2i, to: Vector2i, amount: int, max_piles: int) -> bool:
	var piles: Array[ResourceNode] = _active(kind)
	var center: Vector2 = Vector2(around) + Vector2(from + to) * 0.5
	for pile: ResourceNode in piles:
		if Vector2(pile.cell).distance_to(center) <= MERGE_RADIUS_CELLS + 1.0 and pile.add_amount(amount) > 0:
			pile.pop()
			return true
	if piles.size() >= max_piles:
		return false
	for attempt: int in PLACE_ATTEMPTS:
		var cell: Vector2i = around + Vector2i(_rng.randi_range(from.x, to.x), _rng.randi_range(from.y, to.y))
		if cell == around or not _world.grid.in_bounds(cell) or _world.grid.is_blocked(cell) or _has_loose_at(cell) \
				or _behind_cliff(cell):
			continue
		var node: ResourceNode = _world.place_resource(kind, cell, 0, _jitter(), true, amount)
		node.pop(0.2)
		return true
	return false


# Ô đặt đá tảng được không: trống, không có đồ nằm trên đất, không ai/thú đứng gần,
# và vẫn đi tới được từ cửa hang (không chặn mất lối duy nhất).
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


# Ngay sau lưng (phía bắc) một dãy vách — đá lở chỉ nằm ở chân vách phía trước.
func _behind_cliff(cell: Vector2i) -> bool:
	for row: int in range(1, 4):
		if _cliff_cells.has(cell + Vector2i(0, row)):
			return true
	return _cliff_cells.has(cell + Vector2i(-1, 1)) or _cliff_cells.has(cell + Vector2i(1, 1))


func _has_loose_at(cell: Vector2i) -> bool:
	for node: ResourceNode in _world.resource_nodes:
		if node.is_loose() and not node.is_cleared and node.cell == cell:
			return true
	return false


func _count_near(cell: Vector2i, cells: Dictionary[Vector2i, bool]) -> int:
	var count: int = 0
	for y: int in range(-2, 3):
		for x: int in range(-2, 3):
			if cells.has(cell + Vector2i(x, y)):
				count += 1
	return count


# Số mỏ còn dùng được (cây còn cây, đá chưa vỡ, bãi sỏi / đống củi chưa hết).
func _count(kind: StringName) -> int:
	return _active(kind).size()


func _active(kind: StringName) -> Array[ResourceNode]:
	var result: Array[ResourceNode] = []
	for node: ResourceNode in _world.resource_nodes:
		if node.kind == kind and not node.is_cleared and not node.is_depleted():
			result.append(node)
	return result


func _jitter() -> Vector2:
	return Vector2(_rng.randf_range(-1.0, 1.0), _rng.randf_range(-1.0, 1.0)) * LOOSE_JITTER


func _next_delay(average: float) -> float:
	return average * _rng.randf_range(0.6, 1.4)


func _can_block_cluster(origin: Vector2i) -> bool:
	var extra: Dictionary[Vector2i, bool] = {}
	for at: Vector2i in MapData.resource_cells(MapData.KIND_ROCK, origin, 2):
		if _behind_cliff(at) or not _can_block(at):
			return false
		extra[at] = true
	var start: Vector2i = _world.map_data.cave_entrance_cell
	var before: PackedByteArray = _world.grid.flood_fill(start)
	var after: PackedByteArray = _world.grid.flood_fill(start, extra)
	return before.count(1) - after.count(1) == extra.size()
