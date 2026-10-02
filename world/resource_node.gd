class_name ResourceNode
extends Node2D
## Một nguồn tài nguyên trên map: cây, đá, bụi quả, chỗ câu cá.
## - Cây: chặt TREE_USES lượt thì thành gốc, rất lâu sau mọc lại.
## - Đá: đập ROCK_USES lượt thì vỡ hết, biến mất (ô đó đi qua được).
## - Bụi: hái một lần là hết quả, mọc lại sau một ngày.
## - Chỗ câu cá: không bao giờ cạn.

## Đá vỡ hết — World nghe để mở ô đó cho đi qua.
signal cleared(node: ResourceNode)

## Gốc node nằm hơi thấp hơn tâm ô, để thổ dân đứng ô phía dưới được vẽ đè lên trên.
const FOOT_OFFSET: Vector2 = Vector2(0, 8)
## Vùng chạm (so với gốc node) theo loại — rộng hơn hình một chút cho dễ chạm.
const HIT_RECTS: Dictionary[StringName, Rect2] = {
	MapData.KIND_TREE: Rect2(-38, -124, 76, 136),
	MapData.KIND_ROCK: Rect2(-40, -60, 80, 72),
	MapData.KIND_BUSH: Rect2(-34, -54, 68, 64),
	MapData.KIND_FISH_SPOT: Rect2(-32, -32, 64, 64),
}
const SHAKE_ANGLE: float = 0.06
const SHAKE_SECONDS: float = 0.25

var kind: StringName = &""
var cell: Vector2i = Vector2i.ZERO
var variant: int = 0
var uses_left: int = 0
## Đá đã vỡ hết (không còn trên map nữa).
var is_cleared: bool = false
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


## Còn làm việc ở đây được không (chặt, đập, hái, câu).
func can_harvest() -> bool:
	if is_cleared:
		return false
	return kind == MapData.KIND_FISH_SPOT or not is_depleted()


## Làm xong một lượt: trừ lượt, đổi hình, trả về số tài nguyên thu được (0 = hết rồi).
func harvest(amount: int) -> int:
	if not can_harvest():
		return 0
	if kind == MapData.KIND_FISH_SPOT:
		return amount
	uses_left -= 1
	if is_depleted():
		_on_depleted()
	_refresh_visual()
	return amount


## Hái hết quả trên bụi để ăn ngay, trả về số quả. Bụi mọc lại sau một thời gian.
func take_berries() -> int:
	if not has_berries():
		return 0
	return harvest(Balance.BUSH_BERRIES_PER_PICK)


## Rung nhẹ khi bị chặt/đập trúng.
func shake() -> void:
	var tween: Tween = _sprite.create_tween()
	tween.tween_property(_sprite, "rotation", SHAKE_ANGLE, SHAKE_SECONDS * 0.25)
	tween.tween_property(_sprite, "rotation", -SHAKE_ANGLE * 0.6, SHAKE_SECONDS * 0.35)
	tween.tween_property(_sprite, "rotation", 0.0, SHAKE_SECONDS * 0.4)


func hit_test(world_point: Vector2) -> bool:
	if is_cleared:
		return false
	var rect: Rect2 = HIT_RECTS.get(kind, Rect2(-32, -32, 64, 64))
	return rect.has_point(world_point - position)


func _on_depleted() -> void:
	match kind:
		MapData.KIND_TREE:
			_start_regrow(Balance.TREE_REGROW_SECONDS)
		MapData.KIND_BUSH:
			_start_regrow(Balance.BUSH_REGROW_SECONDS)
		MapData.KIND_ROCK:
			# Đá vỡ vụn: thu nhỏ rồi biến mất, ô trả lại cho lối đi.
			is_cleared = true
			var tween: Tween = create_tween()
			tween.tween_property(self, "scale", Vector2(1.2, 0.2), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
			tween.tween_callback(func() -> void: visible = false)
			cleared.emit(self)


func _start_regrow(seconds: float) -> void:
	_regrow_left = seconds
	set_process(true)


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
