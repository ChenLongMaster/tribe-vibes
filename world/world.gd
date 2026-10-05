class_name World
extends Node2D
## Dựng thế giới từ MapData: nền cỏ, nước, mảng đất, trang trí, vật thể, công trình,
## thổ dân. Giữ `grid` (WorldGrid) làm nguồn sự thật về ô, `reservations` để đặt chỗ,
## `finder` để thổ dân hỏi "tìm chỗ", `nature` để củi/đá/cây tự hồi lại dần, `placer` để
## đặt công trình, `shadows` + `day_night` cho ánh sáng và bóng đổ theo mặt trời.
## Sức chứa chung của làng (hang đá, Kho, Bếp) tính ở đây rồi báo cho GameState.

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
const DECOR_KEY_FORMAT: String = "env/%s_%02d"
## Công trình nằm trong sân làng chung (không có sân / vòng đá riêng).
const VILLAGE_BUILDINGS: Array[StringName] = [&"cave", &"campfire"]
## Cập nhật người phụ trách công trình (để hiện cảnh báo thiếu người) mỗi chừng này giây.
const STAFF_REFRESH_SECONDS: float = 0.5

var grid: WorldGrid
var map_data: MapData
var reservations: Reservations = Reservations.new()
var finder: WorldFinder
var villagers: Array[Villager] = []
var resource_nodes: Array[ResourceNode] = []
var buildings: Array[Building] = []
var animals: Array[Animal] = []
## Các dãy vách đá (hình dạng để vẽ, xem CliffRidge).
var cliff_ridges: Array[CliffRidge] = []
var nature: NatureSpawner
var placer: BuildingPlacer
var shadows: ShadowLayer
var day_night: DayNight
var _villagers_by_id: Dictionary[int, Villager] = {}
var _buildings_by_uid: Dictionary[int, Building] = {}
## Ô nào thuộc công trình nào (kể cả công trình đi lên được như sân nhảy).
var _building_cells: Dictionary[Vector2i, Building] = {}
var _next_building_uid: int = 1
var _staff_timer: float = 0.0
## RNG riêng cho nhu cầu ban đầu lúc spawn — gieo theo seed map để lặp lại được.
var _spawn_rng: RandomNumberGenerator = RandomNumberGenerator.new()
## Đất trơ: sân + đường mòn (GroundMask). Độ mòn từng ô, và mức sàn của lối mòn có sẵn.
var _ground_mask: GroundMask
var _decor_layer: DecorLayer
var _yards_node: Node2D
var _yard_rings: Dictionary[Building, YardRing] = {}
var _wear: PackedFloat32Array = PackedFloat32Array()
var _wear_floor: PackedFloat32Array = PackedFloat32Array()
var _wear_timer: float = 0.0

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
	# Bóng đổ nằm trên mặt đất, dưới mọi vật.
	shadows = ShadowLayer.new()
	shadows.name = "Shadows"
	add_child(shadows)
	move_child(shadows, _entities.get_index())
	# Hiệu ứng (bụi, số bay, sao lên cấp, pháo giấy) vẽ đè lên mọi vật.
	add_overlay(FxLayer.new(), false)
	EventBus.building_completed.connect(_on_building_completed)


func build(seed_value: int) -> void:
	map_data = MapGenerator.new().generate(seed_value)
	grid = map_data.make_grid()
	finder = WorldFinder.new(self)
	placer = BuildingPlacer.new(self)
	_spawn_rng.seed = seed_value + SPAWN_SEED_SALT
	_build_ground()
	_water.build(map_data)
	_water.material = _wind.water_material()
	_water_life.setup(map_data, _wind)
	_build_patches()
	_build_ground_mask(seed_value)
	_build_decor()
	_spawn_buildings()
	_spawn_cliffs()
	_spawn_objects()
	_spawn_animals(seed_value + ANIMAL_SEED_SALT)
	nature = NatureSpawner.new()
	add_child(nature)
	nature.setup(self, seed_value + NATURE_SEED_SALT)
	refresh_storage_capacity()
	refresh_yards()
	_ground_mask.flush()
	day_night = DayNight.new()
	add_child(day_night)
	day_night.setup(self)
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
## `villager_id` > 0 để giữ đúng mã số cũ khi tải game.
func spawn_villager(data: VillagerData, cell: Vector2i, status: VillagerStatus = null, villager_id: int = 0) -> Villager:
	if status == null:
		status = VillagerStatus.starting(_spawn_rng)
	if villager_id > 0:
		GameState.reserve_villager_id(villager_id)
	else:
		villager_id = GameState.next_villager_id()
	var villager: Villager = VILLAGER_SCENE.instantiate()
	villager.setup(villager_id, data, status, self, cell)
	_entities.add_child(villager)
	villagers.append(villager)
	_villagers_by_id[villager.id] = villager
	shadows.add_dynamic(villager, villager.rig.shadow_sources())
	EventBus.villager_spawned.emit(villager)
	return villager


# --- Công trình ---

## Dựng một công trình ở ô gốc `cell`. `level` = 0 là đặt móng (chờ thợ xây). Chặn các ô
## nó chiếm (trừ công trình đi lên được như sân nhảy). Người chơi đặt móng thì đi qua
## `placer` (kiểm tra chỗ trống, không chặn lối) — hàm này không kiểm tra gì.
func add_building(building_id: StringName, cell: Vector2i, level: int = 1, uid: int = 0) -> Building:
	var building: Building = BUILDING_SCENE.instantiate()
	building.setup(building_id, cell, level)
	building.uid = uid if uid > 0 else _next_building_uid
	_next_building_uid = maxi(_next_building_uid, building.uid + 1)
	_entities.add_child(building)
	building.set_wind(_wind)
	buildings.append(building)
	_buildings_by_uid[building.uid] = building
	for footprint_cell: Vector2i in building.footprint_cells():
		_building_cells[footprint_cell] = building
		if not building.is_walkable():
			grid.set_blocked(footprint_cell, true)
	shadows.add_static(building, building.shadow_sprite())
	if _ground_mask != null and not VILLAGE_BUILDINGS.has(building_id):
		_add_yard(building)
	EventBus.building_placed.emit(building)
	return building


## Bỏ một công trình khỏi map (móng bị huỷ): mở lại các ô. Node không bị xoá, chỉ ẩn.
func remove_building(building: Building) -> void:
	if not buildings.has(building):
		return
	buildings.erase(building)
	_buildings_by_uid.erase(building.uid)
	for footprint_cell: Vector2i in building.footprint_cells():
		if _building_cells.get(footprint_cell) == building:
			_building_cells.erase(footprint_cell)
			grid.set_blocked(footprint_cell, false)
	building.visible = false
	refresh_storage_capacity()
	refresh_yards()
	EventBus.building_removed.emit(building)


func get_building(uid: int) -> Building:
	return _buildings_by_uid.get(uid, null)


func building_at_cell(cell: Vector2i) -> Building:
	return _building_cells.get(cell, null)


## Công trình dưới điểm chạm (bỏ qua vách đá); nhiều cái chồng nhau thì lấy cái đứng trước.
func pick_building(world_point: Vector2) -> Building:
	var best: Building = null
	for building: Building in buildings:
		if not bool(building.def.get("selectable", true)) or not building.hit_test(world_point):
			continue
		if best == null or building.position.y > best.position.y:
			best = building
	return best


## Tính lại sức chứa chung của làng từ mọi công trình đã xây (hang đá, Kho, Bếp).
func refresh_storage_capacity() -> void:
	for resource_id: StringName in ResourceDefs.ORDER:
		var total: int = 0
		for building: Building in buildings:
			total += building.storage_capacity(resource_id)
		GameState.set_capacity(resource_id, total)


func _process(delta: float) -> void:
	_wear_timer -= delta
	if _wear_timer <= 0.0 and not _wear.is_empty():
		_wear_timer = Balance.WEAR_DECAY_SECONDS
		_decay_wear()
	_staff_timer -= delta
	if _staff_timer > 0.0:
		return
	_staff_timer = STAFF_REFRESH_SECONDS
	refresh_staff()


## Ai đang phụ trách / đang xây công trình nào (người được giao việc ở đó, không đình công).
func refresh_staff() -> void:
	var staff_by: Dictionary[Building, Array] = {}
	var builders_by: Dictionary[Building, Array] = {}
	for villager: Villager in villagers:
		var job: Job = villager.job
		if job == null or villager.on_strike or not (job.target is Building):
			continue
		var building: Building = job.target as Building
		if job.job_id == JobDefs.BUILD:
			builders_by.get_or_add(building, []).append(villager)
		elif job.job_id == building.staff_job():
			staff_by.get_or_add(building, []).append(villager)
	for building: Building in buildings:
		var list: Array[Villager] = []
		list.assign(builders_by.get(building, []))
		building.set_builders(list)
		if building.staff_job() == &"":
			continue
		var staff_list: Array[Villager] = []
		staff_list.assign(staff_by.get(building, []))
		building.set_staff(staff_list)


func _on_building_completed(_building: Node, _level: int) -> void:
	refresh_storage_capacity()


## Thêm một lớp vẽ lên thế giới (vd đường chấm chấm, vòng mục tiêu của controller).
## `below_entities` = vẽ dưới thổ dân, cây cối (như vẽ trên mặt đất).
func add_overlay(overlay: Node2D, below_entities: bool) -> void:
	add_child(overlay)
	move_child(overlay, _entities.get_index() + (0 if below_entities else 1))


## Vật giao việc được dưới điểm chạm: thú, cây, đá, bụi, chỗ câu cá, công trình (móng để xây,
## bếp để nấu, lò rèn để rèn, lều để ngủ…). Nhiều vật chồng nhau thì lấy vật đứng trước
## (y lớn nhất). null nếu không có.
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
	return pick_building(world_point)


## Đặt một tài nguyên mới lên map lúc đang chơi (củi rơi, đá tảng lăn ra…). Dùng lại node đã
## hết cùng loại nếu có — node không bao giờ bị xoá. Đá tảng chặn ô; củi, đá cuội thì không.
## `reuse = false` để luôn tạo node mới (khi tải game, giữ đúng thứ tự node đã lưu).
func place_resource(kind: StringName, cell: Vector2i, variant: int, jitter: Vector2 = Vector2.ZERO,
		reuse: bool = true, start_amount: int = -1) -> ResourceNode:
	for node: ResourceNode in resource_nodes:
		if reuse and node.kind == kind and node.is_cleared:
			node.place_again(cell, variant, jitter, start_amount)
			_block_if_solid(node)
			return node
	var fresh: ResourceNode = RESOURCE_NODE_SCENE.instantiate()
	fresh.setup(kind, cell, variant, jitter, start_amount)
	_entities.add_child(fresh)
	fresh.set_wind(_wind)
	resource_nodes.append(fresh)
	fresh.cleared.connect(_on_resource_cleared)
	_block_if_solid(fresh)
	shadows.add_static(fresh, fresh.shadow_sprite())
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
	_decor_layer = DecorLayer.new()
	_decor_layer.name = "Plants"
	_decor.add_child(_decor_layer)
	_decor_layer.build(map_data.decor, func(item: Dictionary) -> String:
		return DECOR_KEY_FORMAT % [String(item["kind"]), int(item["variant"]) + 1], _wind.sway_material(Wind.Profile.GRASS))
	# Vòng đá quanh sân nằm trên cây cỏ, dưới thổ dân.
	_yards_node = Node2D.new()
	_yards_node.name = "YardRings"
	_decor.add_child(_yards_node)


## Ô này có cây cỏ trang trí đã bị giấu (sân công trình đè lên) không — hoa ở đó không hái được.
func is_decor_hidden(cell: Vector2i) -> bool:
	return _decor_layer != null and _decor_layer.is_hidden(cell)


# --- Đất trơ: sân + đường mòn ---

func _build_ground_mask(seed_value: int) -> void:
	_ground_mask = GroundMask.new()
	_ground_mask.name = "GroundMask"
	add_child(_ground_mask)
	move_child(_ground_mask, _patches.get_index() + 1)
	_ground_mask.setup(map_data.size, seed_value)
	_wear.resize(map_data.size.x * map_data.size.y)
	_wear.fill(0.0)
	_wear_floor.resize(_wear.size())
	_wear_floor.fill(0.0)
	for cell: Vector2i in map_data.trails:
		var index: int = map_data.index(cell)
		_wear[index] = Balance.TRAIL_WEAR
		_wear_floor[index] = Balance.TRAIL_FLOOR
		_ground_mask.set_wear(cell, Balance.TRAIL_WEAR)


## Thổ dân vừa bước vào ô này: cỏ mòn thêm một chút (đi nhiều thành đường đất).
func trample(cell: Vector2i) -> void:
	if not grid.in_bounds(cell):
		return
	var index: int = map_data.index(cell)
	if _wear[index] >= 1.0:
		return
	_wear[index] = minf(_wear[index] + Balance.WEAR_PER_STEP, 1.0)
	_ground_mask.set_wear(cell, _wear[index])


func _cell_of_index(index: int) -> Vector2i:
	return Vector2i(index % map_data.size.x, floori(float(index) / map_data.size.x))


func wear_at(cell: Vector2i) -> float:
	return _wear[map_data.index(cell)] if grid.in_bounds(cell) else 0.0


# Bỏ không thì cỏ mọc lại dần (lối mòn có sẵn không mờ dưới mức sàn).
func _decay_wear() -> void:
	for index: int in _wear.size():
		var value: float = _wear[index]
		if value <= _wear_floor[index]:
			continue
		var faded: float = maxf(value * Balance.WEAR_DECAY, _wear_floor[index])
		if faded < 0.05:
			faded = 0.0
		_wear[index] = faded
		_ground_mask.set_wear(_cell_of_index(index), faded)


## Để lưu game: các ô đã mòn (thưa — chỉ ô có mòn) dạng [chỉ số, phần trăm].
func wear_to_save() -> Array:
	var saved: Array = []
	for index: int in _wear.size():
		if _wear[index] > 0.0:
			saved.append([index, roundi(_wear[index] * 100.0)])
	return saved


func apply_saved_wear(saved: Array) -> void:
	for index: int in _wear.size():
		_wear[index] = _wear_floor[index]
	for entry: Variant in saved:
		var pair: Array = entry
		var index: int = int(pair[0])
		if index >= 0 and index < _wear.size():
			_wear[index] = maxf(float(pair[1]) / 100.0, _wear_floor[index])
	for index: int in _wear.size():
		_ground_mask.set_wear(_cell_of_index(index), _wear[index])
	_ground_mask.flush()


## Vẽ lại sân: sân làng quanh hang + lửa trại, và sân + vòng đá quanh mỗi công trình (kể cả
## móng). Cây cỏ trang trí trong sân bị giấu.
func refresh_yards() -> void:
	_ground_mask.clear_yards()
	var center: Vector2 = (Vector2(map_data.cave_entrance_cell) + Vector2(map_data.campfire_cell)) * 0.5
	var reach: int = ceili(Balance.VILLAGE_YARD_RADIUS) + 1
	for y: int in range(floori(center.y) - reach, ceili(center.y) + reach + 1):
		for x: int in range(floori(center.x) - reach, ceili(center.x) + reach + 1):
			var distance: float = Vector2(x, y).distance_to(center)
			var value: float = clampf(1.0 - (distance - Balance.VILLAGE_YARD_RADIUS + 1.0) * 0.5, 0.0, 1.0)
			if value > 0.0:
				_ground_mask.set_yard(Vector2i(x, y), value)
	for building: Building in buildings:
		if VILLAGE_BUILDINGS.has(building.building_id) or building.demolished:
			continue
		_add_yard(building)
	for building: Building in _yard_rings.keys():
		if not buildings.has(building):
			_yard_rings[building].queue_free()
			_yard_rings.erase(building)
	_update_ring_overlaps()


# Hai sân chồng nhau thì thành một sân chung: vòng đá của nhà này bỏ đoạn nằm trong sân nhà kia
# (và trong sân làng).
func _update_ring_overlaps() -> void:
	var village: Vector2 = (Vector2(map_data.cave_entrance_cell) + Vector2(map_data.campfire_cell)) * 0.5
	var village_rect: Rect2 = Rect2(WorldGrid.cell_to_world(Vector2i(village.round())), Vector2.ZERO) 			.grow((Balance.VILLAGE_YARD_RADIUS - 0.5) * Balance.TILE_SIZE)
	for building: Building in _yard_rings:
		var rects: Array[Rect2] = [village_rect]
		for other: Building in _yard_rings:
			if other != building:
				rects.append(_yard_rect(other).grow(-Balance.TILE_SIZE * 0.2))
		_yard_rings[building].set_excluded(rects)


func _yard_rect(building: Building) -> Rect2:
	var size: Vector2i = BuildingDefs.footprint(building.building_id)
	return Rect2(Vector2(building.origin_cell * Balance.TILE_SIZE), Vector2(size * Balance.TILE_SIZE)) 			.grow(Balance.YARD_MARGIN_CELLS * Balance.TILE_SIZE)


func _add_yard(building: Building) -> void:
	if building.building_id == BuildingDefs.KITCHEN:
		# Sân bếp dùng đất map; chỉ rào/đá nằm trong art, không thêm vòng đá thứ hai.
		var tier: int = building.level if building.is_built() else 3
		var first: Vector2 = (building.position + KitchenLayout.local_point(Vector2(0, 64), tier)) / Balance.TILE_SIZE
		var last: Vector2 = (building.position + KitchenLayout.local_point(Vector2(384, 320), tier)) / Balance.TILE_SIZE
		var center: Vector2 = (first + last) * 0.5
		var half_size: Vector2 = (last - first) * 0.5
		for y: int in range(floori(first.y) - 1, ceili(last.y) + 2):
			for x: int in range(floori(first.x) - 1, ceili(last.x) + 2):
				var cell: Vector2i = Vector2i(x, y)
				var edge: Vector2 = (Vector2(cell) + Vector2.ONE * 0.5 - center).abs() - half_size
				var value: float = clampf(0.8 - maxf(edge.x, edge.y) * Balance.KITCHEN_YARD_FALLOFF, 0.0, 1.0)
				_ground_mask.set_yard(cell, maxf(_ground_mask.yard_at(cell), value))
		_decor_layer.hide_cells(building.footprint_cells())
		return
	var cells: Array[Vector2i] = building.footprint_cells()
	var origin: Vector2i = building.origin_cell
	var size: Vector2i = BuildingDefs.footprint(building.building_id)
	for y: int in range(-1, size.y + 1):
		for x: int in range(-1, size.x + 1):
			var cell: Vector2i = origin + Vector2i(x, y)
			var inside: bool = cells.has(cell)
			var corner: bool = (x == -1 or x == size.x) and (y == -1 or y == size.y)
			var value: float = 1.0 if inside else (Balance.YARD_CORNER_STRENGTH if corner else Balance.YARD_EDGE_STRENGTH)
			_ground_mask.set_yard(cell, maxf(_ground_mask.yard_at(cell), value))
	_decor_layer.hide_cells(cells)
	if not _yard_rings.has(building):
		var ring: YardRing = YardRing.new()
		ring.setup(_yard_rect(building), building.uid * 7919)
		_yards_node.add_child(ring)
		_yard_rings[building] = ring
		_update_ring_overlaps()


# Công trình có sẵn trên map (hang, lửa trại, vách đá).
func _spawn_buildings() -> void:
	for entry: Dictionary in map_data.buildings:
		add_building(entry["id"], entry["cell"])


# Dãy vách đá vẽ bằng code thành bức vách liền (CliffRidge). Mỗi cột ô một node trong Entities
# (gốc ở chân vách) để y-sort với thổ dân: người đi sau vách bị che. Bóng cả dãy ở ShadowLayer.
# Không chạm / chọn được.
func _spawn_cliffs() -> void:
	cliff_ridges = CliffRidge.group(map_data.cliffs)
	for ridge: CliffRidge in cliff_ridges:
		for column: int in range(ridge.first_column, ridge.last_column + 1):
			if not ridge.columns.has(column):
				continue
			var slice: Node2D = Node2D.new()
			slice.name = "Cliff"
			slice.position = ridge.slice_origin(column)
			slice.draw.connect(ridge.draw_slice.bind(slice, column))
			_entities.add_child(slice)
	shadows.add_walls(cliff_ridges)


func _spawn_objects() -> void:
	for entry: Dictionary in map_data.objects:
		var node: ResourceNode = RESOURCE_NODE_SCENE.instantiate()
		node.setup(entry["kind"], entry["cell"], entry["variant"], entry.get("jitter", Vector2.ZERO), entry.get("amount", -1))
		node.growth = entry.get("growth", 1.0)
		_entities.add_child(node)
		node.set_wind(_wind)
		resource_nodes.append(node)
		node.cleared.connect(_on_resource_cleared)
		shadows.add_static(node, node.shadow_sprite())


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
		shadows.add_dynamic(animal, animal.shadow_sources())


# Đá vỡ hết thì ô đó thành lối đi (củi, đá cuội vốn không chặn gì).
func _on_resource_cleared(node: ResourceNode) -> void:
	if not node.is_loose():
		for at: Vector2i in node.footprint_cells():
			grid.set_blocked(at, false)


func _block_if_solid(node: ResourceNode) -> void:
	if not node.is_loose():
		for at: Vector2i in node.footprint_cells():
			grid.set_blocked(at, true)


func _add_sprite(parent: Node2D, key: String, pos: Vector2) -> Sprite2D:
	var sprite: Sprite2D = Sprite2D.new()
	ArtLibrary.setup_sprite(sprite, key)
	sprite.position = pos
	parent.add_child(sprite)
	return sprite
