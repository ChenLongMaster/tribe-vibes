class_name World
extends Node2D
## Dựng thế giới từ MapData: nền cỏ, nước, mảng đất, trang trí, vật thể, công trình.
## Giữ `grid` (WorldGrid) làm nguồn sự thật về ô cho các hệ thống khác.

const RESOURCE_NODE_SCENE: PackedScene = preload("res://world/resource_node.tscn")
const BUILDING_SCENE: PackedScene = preload("res://buildings/building.tscn")
const GROUND_KEY_FORMAT: String = "ground/grass_%02d"
const DIRT_PATCH_KEY_FORMAT: String = "ground/dirt_patch_%02d"
const GRASS_PATCH_KEY_FORMAT: String = "ground/grass_patch_%02d"
const FLOWER_KEY_FORMAT: String = "env/flower_%02d"
const TUFT_KEY_FORMAT: String = "env/grass_tuft_%02d"

var grid: WorldGrid
var map_data: MapData

@onready var _ground: TileMapLayer = $Ground
@onready var _patches: Node2D = $Patches
@onready var _water: WaterLayer = $Water
@onready var _water_life: WaterLife = $WaterLife
@onready var _decor: Node2D = $Decor
@onready var _entities: Node2D = $Entities
@onready var _camera: CameraController = $Camera
@onready var _wind: Wind = $Wind


func build(seed_value: int) -> void:
	map_data = MapGenerator.new().generate(seed_value)
	grid = map_data.make_grid()
	_build_ground()
	_water.build(map_data)
	_water.material = _wind.water_material()
	_water_life.setup(map_data, _wind)
	_build_patches()
	_build_decor()
	_spawn_buildings()
	_spawn_objects()
	var focus: Vector2 = WorldGrid.cell_to_world(map_data.campfire_cell) + Vector2(0, -48)
	_camera.setup(Rect2(Vector2.ZERO, grid.pixel_size()), focus)
	EventBus.world_ready.emit(self)


func get_camera() -> CameraController:
	return _camera


func get_wind() -> Wind:
	return _wind


func get_water_life() -> WaterLife:
	return _water_life


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


func _spawn_objects() -> void:
	for entry: Dictionary in map_data.objects:
		var node: ResourceNode = RESOURCE_NODE_SCENE.instantiate()
		node.setup(entry["kind"], entry["cell"], entry["variant"])
		_entities.add_child(node)
		node.set_wind(_wind)


func _add_sprite(parent: Node2D, key: String, pos: Vector2) -> Sprite2D:
	var sprite: Sprite2D = Sprite2D.new()
	ArtLibrary.setup_sprite(sprite, key)
	sprite.position = pos
	parent.add_child(sprite)
	return sprite
