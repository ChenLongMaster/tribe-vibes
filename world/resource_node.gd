class_name ResourceNode
extends Node2D
## Một nguồn tài nguyên trên map: cây, đá tảng, bụi quả, chỗ câu cá, củi, đá cuội.
## - Cây: chặt (cần rìu) TREE_USES khúc gỗ thì thành gốc. Gốc chỉ mọc lại khi số cây trong
##   rừng ít hơn lúc đầu — NatureSpawner quyết định, gọi regrow().
## - Đá tảng: đập (cần cuốc) ROCK_USES lượt thì vỡ hết, biến mất (ô đó đi qua được). Đá tảng
##   mới lăn ra từ vách đá (NatureSpawner gọi place_again()).
## - Bụi: hái một lần là hết quả, mọc lại sau một ngày.
## - Chỗ câu cá: không bao giờ cạn.
## - Củi, đá cuội: nằm trên mặt đất, không chặn đường, nhặt tay một lần là hết.
## Node đã hết KHÔNG bị xoá (chỉ ẩn) để không ai giữ tham chiếu tới node đã giải phóng;
## NatureSpawner dùng lại chúng cho củi/đá mới.

## Hết hẳn, biến mất khỏi map (đá vỡ, củi/đá cuội đã nhặt) — World nghe để mở ô cho đi qua.
signal cleared(node: ResourceNode)

## Gốc node nằm hơi thấp hơn tâm ô, để thổ dân đứng ô phía dưới được vẽ đè lên trên.
const FOOT_OFFSET: Vector2 = Vector2(0, 8)
## Vùng chạm (so với gốc node) theo loại — rộng hơn hình một chút cho dễ chạm.
const HIT_RECTS: Dictionary[StringName, Rect2] = {
	MapData.KIND_TREE: Rect2(-38, -124, 76, 136),
	MapData.KIND_ROCK: Rect2(-40, -60, 80, 72),
	MapData.KIND_BUSH: Rect2(-34, -54, 68, 64),
	MapData.KIND_FISH_SPOT: Rect2(-32, -32, 64, 64),
	MapData.KIND_TWIGS: Rect2(-28, -30, 56, 40),
	MapData.KIND_PEBBLES: Rect2(-28, -30, 56, 40),
}
## Đồ nằm lẫn trên đất (nhặt tay, không chặn đường).
const LOOSE_KINDS: Array[StringName] = [MapData.KIND_TWIGS, MapData.KIND_PEBBLES]
const POP_SECONDS: float = 0.3
const SHAKE_ANGLE: float = 0.06
const SHAKE_SECONDS: float = 0.25

var kind: StringName = &""
var cell: Vector2i = Vector2i.ZERO
var variant: int = 0
var uses_left: int = 0
## Đá đã vỡ hết (không còn trên map nữa).
var is_cleared: bool = false
## Giây đã thành gốc (cây) — gốc mới chặt chưa mọc lại ngay.
var stump_age: float = 0.0
var _regrow_left: float = 0.0

@onready var _sprite: Sprite2D = $Sprite


## `jitter` (px) lệch khỏi tâm ô — cho củi/đá cuội nằm lộn xộn tự nhiên.
func setup(object_kind: StringName, object_cell: Vector2i, object_variant: int, jitter: Vector2 = Vector2.ZERO) -> void:
	kind = object_kind
	cell = object_cell
	variant = object_variant
	uses_left = _initial_uses()
	position = WorldGrid.cell_to_world(cell) + FOOT_OFFSET + jitter
	# Chỗ câu cá nằm giữa ô nước nên neo ở tâm, không cần lệch.
	if kind == MapData.KIND_FISH_SPOT:
		position = WorldGrid.cell_to_world(cell)


func is_loose() -> bool:
	return LOOSE_KINDS.has(kind)


## Đặt lại một node đã hết ở chỗ mới (củi mới rơi, đá tảng mới lăn ra), nảy "bụp" lên.
func place_again(object_cell: Vector2i, object_variant: int, jitter: Vector2 = Vector2.ZERO) -> void:
	setup(kind, object_cell, object_variant, jitter)
	is_cleared = false
	visible = true
	_refresh_visual()
	scale = Vector2(0.2, 0.2)
	create_tween().tween_property(self, "scale", Vector2.ONE, POP_SECONDS).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Gốc cây mọc lại thành cây (NatureSpawner gọi khi rừng còn thưa).
func regrow() -> void:
	if kind != MapData.KIND_TREE or not is_depleted():
		return
	uses_left = _initial_uses()
	stump_age = 0.0
	set_process(false)
	_refresh_visual()
	_sprite.scale.y *= 0.3
	var base: Vector2 = Vector2(ArtLibrary.ART_SCALE, ArtLibrary.ART_SCALE)
	_sprite.create_tween().tween_property(_sprite, "scale", base, 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


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


## Còn làm việc ở đây được không (chặt, đập, hái, câu, nhặt).
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
			# Đếm tuổi gốc; mọc lại hay không do NatureSpawner (giới hạn số cây).
			stump_age = 0.0
			set_process(true)
		MapData.KIND_BUSH:
			_regrow_left = Balance.BUSH_REGROW_SECONDS
			set_process(true)
		MapData.KIND_ROCK, MapData.KIND_TWIGS, MapData.KIND_PEBBLES:
			# Đá vỡ vụn / củi, đá cuội đã nhặt: thu nhỏ rồi biến mất, ô trả lại cho lối đi.
			is_cleared = true
			var tween: Tween = create_tween()
			tween.tween_property(self, "scale", Vector2(1.2, 0.2), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
			tween.tween_callback(func() -> void: visible = false)
			cleared.emit(self)


func _process(delta: float) -> void:
	if kind == MapData.KIND_TREE:
		stump_age += delta
		return
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
		MapData.KIND_TWIGS:
			return "env/twigs"
		MapData.KIND_PEBBLES:
			return "env/pebbles"
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
