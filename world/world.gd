class_name World
extends Node2D
## Dựng thế giới từ MapData: nền cỏ, nước, mảng đất, trang trí, vật thể, công trình,
## thổ dân. Giữ `grid` (WorldGrid) làm nguồn sự thật về ô, `reservations` để đặt chỗ,
## `finder` để thổ dân hỏi "tìm chỗ", `nature` để củi/đá/cây tự hồi lại dần.

## Ô "không có" — trả về khi không tìm được chỗ nào.
const INVALID_CELL: Vector2i = Vector2i(-1, -1)
const RESOURCE_NODE_SCENE: PackedScene = preload("res://world/resource_node.tscn")
const BUILDING_SCENE: PackedScene = preload("res://buildings/building.tscn")
const VILLAGER_SCENE: PackedScene = preload("res://villager/villager.tscn")
const SPAWN_SEED_SALT: int = 104729
const ANIMAL_SEED_SALT: int = 15485863
const NATURE_SEED_SALT: int = 32452843
const GROUND_KEY_FORMAT: String = "ground/grass_%02d"
const DIRT_PATCH_KEY_FORMAT: String = "ground/dirt_patch_%02d"
const GRASS_PATCH_KEY_FORMAT: String = "ground/grass_patch_%02d"
const FLOWER_KEY_FORMAT: String = "env/flower_%02d"
const TUFT_KEY_FORMAT: String = "env/grass_tuft_%02d"

var grid: WorldGrid
var map_data: MapData
var reservations: Reservations = Reservations.new()
var finder: WorldFinder
var villagers: Array[Villager] = []
var resource_nodes: Array[ResourceNode] = []
var buildings: Array[Building] = []
var animals: Array[Animal] = []
var nature: NatureSpawner
var _villagers_by_id: Dictionary[int, Villager] = {}
## RNG riêng cho nhu cầu ban đầu lúc spawn — gieo theo seed map để lặp lại được.
var _spawn_rng: RandomNumberGenerator = RandomNumberGenerator.new()

@onready var _ground: TileMapLayer = $Ground
@onready var _patches: Node2D = $Patches
@onready var _water: WaterLayer = $Water
@onready var _water_life: WaterLife = $WaterLife
@onready var _decor: Node2D = $Decor
@onready var _entities: Node2D = $Entities
@onready var _camera: CameraController = $Camera
@onready var _wind: Wind = $Wind
@onready var _spawner: VillagerSpawner = $VillagerSpawner


func _ready() -> void:
	# Hiệu ứng (bụi, số bay, sao lên cấp) vẽ đè lên mọi vật.
	add_overlay(FxLayer.new(), false)


func build(seed_value: int) -> void:
	map_data = MapGenerator.new().generate(seed_value)
	grid = map_data.make_grid()
	finder = WorldFinder.new(self)
	_spawn_rng.seed = seed_value + SPAWN_SEED_SALT
	_build_ground()
	_water.build(map_data)
	_water.material = _wind.water_material()
	_water_life.setup(map_data, _wind)
	_build_patches()
	_build_decor()
	_spawn_buildings()
	_spawn_objects()
	_spawn_animals(seed_value + ANIMAL_SEED_SALT)
	nature = NatureSpawner.new()
	add_child(nature)
	nature.setup(self, seed_value + NATURE_SEED_SALT)
	var focus: Vector2 = WorldGrid.cell_to_world(map_data.campfire_cell) + Vector2(0, -48)
	_camera.setup(Rect2(Vector2.ZERO, grid.pixel_size()), focus)
	EventBus.world_ready.emit(self)


func get_camera() -> CameraController:
	return _camera


func get_wind() -> Wind:
	return _wind


func get_water_life() -> WaterLife:
	return _water_life


## Hoạt cảnh mở đầu: cả bộ lạc lần lượt chui ra khỏi hang.
func start_intro() -> void:
	_spawner.start_intro(self)


## Cách DUY NHẤT đưa một thổ dân vào thế giới (người chơi đi qua Commands.spawn_villager).
## `status` để trống = nhu cầu ban đầu ngẫu nhiên; truyền vào khi tải game đã lưu.
func spawn_villager(data: VillagerData, cell: Vector2i, status: VillagerStatus = null) -> Villager:
	if status == null:
		status = VillagerStatus.starting(_spawn_rng)
	var villager: Villager = VILLAGER_SCENE.instantiate()
	villager.setup(GameState.next_villager_id(), data, status, self, cell)
	_entities.add_child(villager)
	villagers.append(villager)
	_villagers_by_id[villager.id] = villager
	EventBus.villager_spawned.emit(villager)
	return villager


## Thêm một lớp vẽ lên thế giới (vd đường chấm chấm, vòng mục tiêu của controller).
## `below_entities` = vẽ dưới thổ dân, cây cối (như vẽ trên mặt đất).
func add_overlay(overlay: Node2D, below_entities: bool) -> void:
	add_child(overlay)
	move_child(overlay, _entities.get_index() + (0 if below_entities else 1))


## Vật giao việc được dưới điểm chạm: thú, cây, đá, bụi, chỗ câu cá, công trình nhận việc
## (lửa trại để nấu). Nhiều vật chồng nhau thì lấy vật đứng trước (y lớn nhất). null nếu không có.
func pick_job_target(world_point: Vector2) -> Node2D:
	var best: Node2D = null
	for animal: Animal in animals:
		if animal.hit_test(world_point) and (best == null or animal.position.y > best.position.y):
			best = animal
	if best != null:
		return best
	for node: ResourceNode in resource_nodes:
		if node.hit_test(world_point) and (best == null or node.position.y > best.position.y):
			best = node
	if best != null:
		return best
	for building: Building in buildings:
		if building.hit_test(world_point) and JobDefs.job_for_target(building) != &"":
			return building
	return null


## Đặt một tài nguyên mới lên map lúc đang chơi (củi rơi, đá tảng lăn ra…). Dùng lại node đã
## hết cùng loại nếu có — node không bao giờ bị xoá. Đá tảng chặn ô; củi, đá cuội thì không.
func place_resource(kind: StringName, cell: Vector2i, variant: int, jitter: Vector2 = Vector2.ZERO) -> ResourceNode:
	for node: ResourceNode in resource_nodes:
		if node.kind == kind and node.is_cleared:
			node.place_again(cell, variant, jitter)
			_block_if_solid(node)
			return node
	var fresh: ResourceNode = RESOURCE_NODE_SCENE.instantiate()
	fresh.setup(kind, cell, variant, jitter)
	_entities.add_child(fresh)
	fresh.set_wind(_wind)
	resource_nodes.append(fresh)
	fresh.cleared.connect(_on_resource_cleared)
	_block_if_solid(fresh)
	return fresh


func get_villager(villager_id: int) -> Villager:
	return _villagers_by_id.get(villager_id, null)


func cell_of(villager: Villager) -> Vector2i:
	return WorldGrid.world_to_cell(villager.position)


## Thổ dân dưới điểm chạm; nhiều người chồng nhau thì lấy người đứng trước (y lớn nhất).
func pick_villager(world_point: Vector2) -> Villager:
	var best: Villager = null
	for villager: Villager in villagers:
		if villager.hit_test(world_point) and (best == null or villager.position.y > best.position.y):
			best = villager
	return best


func _build_ground() -> void:
	var keys: Dictionary[int, String] = {}
	for variant: int in MapData.GROUND_VARIANTS:
		keys[variant] = GROUND_KEY_FORMAT % (variant + 1)
	_ground.tile_set = TileSetBuilder.build(keys)
	_ground.scale = Vector2(ArtLibrary.ART_SCALE, ArtLibrary.ART_SCALE)
	_ground.clear()
	for y: int in map_data.size.y:
		for x: int in map_data.size.x:
			var cell: Vector2i = Vector2i(x, y)
			_ground.set_cell(cell, map_data.ground_variant[map_data.index(cell)], Vector2i.ZERO)


func _build_patches() -> void:
	for patch: Dictionary in map_data.patches:
		var key_format: String = GRASS_PATCH_KEY_FORMAT if patch["kind"] == MapData.PATCH_GRASS else DIRT_PATCH_KEY_FORMAT
		_add_sprite(_patches, key_format % (int(patch["variant"]) + 1), patch["pos"])


func _build_decor() -> void:
	for item: Dictionary in map_data.decor:
		var key_format: String = FLOWER_KEY_FORMAT if item["kind"] == MapData.DECOR_FLOWER else TUFT_KEY_FORMAT
		var sprite: Sprite2D = _add_sprite(_decor, key_format % (int(item["variant"]) + 1), item["pos"])
		sprite.material = _wind.sway_material(Wind.Profile.GRASS)


func _spawn_buildings() -> void:
	for entry: Dictionary in map_data.buildings:
		var building: Building = BUILDING_SCENE.instantiate()
		building.setup(entry["id"], entry["cell"])
		_entities.add_child(building)
		building.set_wind(_wind)
		buildings.append(building)


func _spawn_objects() -> void:
	for entry: Dictionary in map_data.objects:
		var node: ResourceNode = RESOURCE_NODE_SCENE.instantiate()
		node.setup(entry["kind"], entry["cell"], entry["variant"])
		_entities.add_child(node)
		node.set_wind(_wind)
		resource_nodes.append(node)
		node.cleared.connect(_on_resource_cleared)


# Thú lang thang trên đồng cỏ — vị trí ban đầu theo seed để cùng seed ra cùng đàn thú.
func _spawn_animals(seed_value: int) -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = seed_value
	var rect: Rect2i = map_data.meadow_rect
	var attempts: int = Balance.ANIMAL_COUNT * 20
	while animals.size() < Balance.ANIMAL_COUNT and attempts > 0:
		attempts -= 1
		var cell: Vector2i = rect.position + Vector2i(rng.randi_range(0, rect.size.x - 1), rng.randi_range(0, rect.size.y - 1))
		if grid.is_blocked(cell):
			continue
		var animal: Animal = Animal.new()
		animal.setup(self, Animal.SPECIES[animals.size() % Animal.SPECIES.size()], cell)
		_entities.add_child(animal)
		animals.append(animal)


# Đá vỡ hết thì ô đó thành lối đi (củi, đá cuội vốn không chặn gì).
func _on_resource_cleared(node: ResourceNode) -> void:
	if not node.is_loose():
		grid.set_blocked(node.cell, false)


func _block_if_solid(node: ResourceNode) -> void:
	if not node.is_loose():
		grid.set_blocked(node.cell, true)


func _add_sprite(parent: Node2D, key: String, pos: Vector2) -> Sprite2D:
	var sprite: Sprite2D = Sprite2D.new()
	ArtLibrary.setup_sprite(sprite, key)
	sprite.position = pos
	parent.add_child(sprite)
	return sprite
