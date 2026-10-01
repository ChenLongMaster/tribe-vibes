class_name ResourceNode
extends Node2D
## Một nguồn tài nguyên trên map: cây, đá, bụi quả, chỗ câu cá.
## Bụi quả hái được và tự mọc lại (Đợt 1); chặt cây, đập đá, câu cá thêm ở Đợt 2.

## Gốc node nằm hơi thấp hơn tâm ô, để thổ dân đứng ô phía dưới được vẽ đè lên trên.
const FOOT_OFFSET: Vector2 = Vector2(0, 8)

var kind: StringName = &""
var cell: Vector2i = Vector2i.ZERO
var variant: int = 0
var uses_left: int = 0
var _regrow_left: float = 0.0

@onready var _sprite: Sprite2D = $Sprite


func setup(object_kind: StringName, object_cell: Vector2i, object_variant: int) -> void:
	kind = object_kind
	cell = object_cell
	variant = object_variant
	uses_left = _initial_uses()
	position = WorldGrid.cell_to_world(cell) + FOOT_OFFSET
	# Chỗ câu cá nằm giữa ô nước nên neo ở tâm, không cần lệch.
	if kind == MapData.KIND_FISH_SPOT:
		position = WorldGrid.cell_to_world(cell)


func _ready() -> void:
	set_process(false)
	_refresh_visual()
	if kind == MapData.KIND_FISH_SPOT:
		add_child(FishSpotFx.new())


## Cây và bụi đung đưa theo gió; đá và chỗ câu cá thì không.
func set_wind(wind: Wind) -> void:
	match kind:
		MapData.KIND_TREE:
			_sprite.material = wind.sway_material(Wind.Profile.TREE)
		MapData.KIND_BUSH:
			_sprite.material = wind.sway_material(Wind.Profile.BUSH)


func is_depleted() -> bool:
	return uses_left <= 0


## Bụi còn quả để hái không.
func has_berries() -> bool:
	return kind == MapData.KIND_BUSH and not is_depleted()


## Hái hết quả trên bụi, trả về số quả hái được. Bụi mọc lại sau một thời gian.
func take_berries() -> int:
	if not has_berries():
		return 0
	uses_left = 0
	_regrow_left = Balance.BUSH_REGROW_SECONDS
	_refresh_visual()
	set_process(true)
	return Balance.BUSH_BERRIES_PER_PICK


func _process(delta: float) -> void:
	_regrow_left -= delta
	if _regrow_left <= 0.0:
		uses_left = _initial_uses()
		_refresh_visual()
		set_process(false)


func _refresh_visual() -> void:
	ArtLibrary.setup_sprite(_sprite, _art_key())


func _art_key() -> String:
	match kind:
		MapData.KIND_TREE:
			return "env/tree_stump" if is_depleted() else "env/tree_%02d" % (variant + 1)
		MapData.KIND_ROCK:
			return "env/rock_big" if variant == 0 else "env/rock_small"
		MapData.KIND_BUSH:
			return "env/bush_empty" if is_depleted() else "env/bush_berries"
		MapData.KIND_FISH_SPOT:
			return "env/fish_spot"
	return "missing/" + String(kind)


func _initial_uses() -> int:
	match kind:
		MapData.KIND_TREE:
			return Balance.TREE_USES
		MapData.KIND_ROCK:
			return Balance.ROCK_USES
		MapData.KIND_BUSH:
			return 1
	# Chỗ câu cá không bao giờ cạn.
	return 1
