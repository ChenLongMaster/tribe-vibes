class_name TentEntrance
extends RefCounted
## Da cửa nằm trước dân; thân và sân nằm sau để đoạn chui vào có chiều sâu.

const PIVOT: Vector2 = Vector2(128, 276)
const SIZES: Array[float] = [0.76, 0.89, 1.0]
var building: Building
var _layers: Array[Sprite2D] = []
var _level: int = -1

func _init(owner: Building) -> void:
	building = owner

func local_point(raw: Vector2) -> Vector2:
	return (raw - PIVOT) * SIZES[maxi(building.level, 1) - 1] * ArtLibrary.ART_SCALE

func door() -> Vector2:
	return building.position + local_point(Vector2(188, 271))

func approach() -> Vector2:
	return door() + Vector2(19, 22)

func entry_cell() -> Vector2i:
	return building.origin_cell + Vector2i(1, 2)

func refresh() -> void:
	if _level == building.level:
		return
	_level = building.level
	for layer: Sprite2D in _layers:
		layer.queue_free()
	_layers.clear()
	if not building.is_built():
		return
	_add("floor", Vector2(0, -110))
	_add("body", local_point(Vector2(128, 230)))
	_add("door", local_point(Vector2(188, 282)))

func _add(part: String, sort_at: Vector2) -> void:
	var layer: Sprite2D = Sprite2D.new()
	ArtLibrary.setup_sprite(layer, "buildings/tent/" + part + "_" + str(building.level))
	layer.position = sort_at
	layer.offset -= sort_at / ArtLibrary.ART_SCALE
	building.add_child(layer)
	_layers.append(layer)
