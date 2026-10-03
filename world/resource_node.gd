class_name ResourceNode
extends Node2D
## Một MỎ tài nguyên trên map: cây, đá tảng, bụi quả, bãi sỏi, đống củi, chỗ câu cá.
## Mỗi mỏ có LƯỢNG còn lại (`amount` / `capacity` — "thanh máu", chỉ hiện trong bảng thông tin),
## tính bằng món khuân về (khúc gỗ, đá, quả, bó củi, viên sỏi). Nhiều người làm chung một mỏ
## (`max_workers`). Hình đổi theo lượng còn lại: _100 (> 50%), _50 (20–50%), _20 (< 20%).
## - Cây: lớn dần (`growth` 0 → 1, cây non vẽ nhỏ hơn); chỉ cây trưởng thành mới chặt được (cần
##   rìu) và rụng cành thành củi. Chặt hết khúc thì thành gốc; gốc mọc lại thành cây non khi rừng
##   còn ít cây hơn lúc đầu (NatureSpawner gọi regrow()).
## - Đá tảng: đập (cần cuốc) hết thì vỡ, biến mất (ô đó đi qua được). Vách đá lở ra tảng mới.
## - Bụi quả: hái trụi thì BUSH_REGROW_DAYS ngày sau mới đầy lại.
## - Bãi sỏi, đống củi: nằm trên đất, không chặn đường, nhặt tay; hết thì biến mất. Vách đá lở
##   thêm sỏi, cây rụng thêm củi (add_amount / NatureSpawner).
## - Chỗ câu cá: không bao giờ cạn.
## Node đã hết KHÔNG bị xoá (chỉ ẩn) để không ai giữ tham chiếu tới node đã giải phóng;
## NatureSpawner dùng lại chúng cho đá / sỏi / củi mới.

## Hết hẳn, biến mất khỏi map (đá vỡ, sỏi / củi đã nhặt hết) — World nghe để mở ô cho đi qua.
signal cleared(node: ResourceNode)

## Gốc node nằm hơi thấp hơn tâm ô, để thổ dân đứng ô phía dưới được vẽ đè lên trên.
const FOOT_OFFSET: Vector2 = Vector2(0, 8)
## Vùng chạm (so với gốc node) theo loại — rộng hơn hình một chút cho dễ chạm.
const HIT_RECTS: Dictionary[StringName, Rect2] = {
	MapData.KIND_TREE: Rect2(-38, -124, 76, 136),
	MapData.KIND_ROCK: Rect2(-40, -60, 80, 72),
	MapData.KIND_BUSH: Rect2(-48, -76, 96, 86),
	MapData.KIND_FISH_SPOT: Rect2(-32, -32, 64, 64),
	MapData.KIND_TWIGS: Rect2(-40, -34, 80, 46),
	MapData.KIND_PEBBLES: Rect2(-40, -34, 80, 46),
}
const POP_SECONDS: float = 0.3
const SHAKE_ANGLE: float = 0.06
const SHAKE_SECONDS: float = 0.25

var kind: StringName = &""
var cell: Vector2i = Vector2i.ZERO
var variant: int = 0
## Lượng còn lại / lượng khi đầy (tính bằng món: khúc gỗ, đá, quả, bó củi, viên sỏi).
var amount: int = 0
var capacity: int = 0
## Cây: 0 = mới nhú, 1 = trưởng thành (chặt được, rụng củi). Loại khác luôn 1.
var growth: float = 1.0
## Đá đã vỡ hết / sỏi, củi đã nhặt hết (không còn trên map nữa).
var is_cleared: bool = false
## Giây đã thành gốc (cây) — gốc mới chặt chưa mọc lại ngay.
var stump_age: float = 0.0
var _regrow_left: float = 0.0
## Ai đang làm ở đây đứng chỗ nào (instance id thổ dân → ô / phía) — để nhiều người làm chung
## một mỏ không đứng chồng lên nhau.
var _stands: Dictionary[int, Vector2i] = {}

@onready var _sprite: Sprite2D = $Sprite


## `jitter` (px) lệch khỏi tâm ô cho đỡ thẳng hàng. `start_amount` < 0 = đầy.
func setup(object_kind: StringName, object_cell: Vector2i, object_variant: int, jitter: Vector2 = Vector2.ZERO,
		start_amount: int = -1) -> void:
	kind = object_kind
	cell = object_cell
	variant = object_variant
	capacity = _capacity()
	amount = capacity if start_amount < 0 else clampi(start_amount, 0, capacity)
	position = WorldGrid.cell_to_world(cell) + FOOT_OFFSET + jitter
	# Chỗ câu cá nằm giữa ô nước nên neo ở tâm, không cần lệch.
	if kind == MapData.KIND_FISH_SPOT:
		position = WorldGrid.cell_to_world(cell)


func is_loose() -> bool:
	return MapData.LOOSE_KINDS.has(kind)


## Mấy người làm cùng lúc ở mỏ này.
func max_workers() -> int:
	match kind:
		MapData.KIND_BUSH:
			return Balance.BUSH_WORKERS
		MapData.KIND_TWIGS, MapData.KIND_PEBBLES:
			return Balance.PILE_WORKERS
		MapData.KIND_ROCK:
			return Balance.ROCK_WORKERS
	return 1


## Phần còn lại (0..1).
func fraction() -> float:
	return float(amount) / capacity if capacity > 0 else 1.0


## Cây đã lớn hẳn chưa (loại khác luôn coi là "lớn").
func is_mature() -> bool:
	return kind != MapData.KIND_TREE or growth >= 1.0


## Cây non: còn bao nhiêu giây nữa thì trưởng thành.
func grow_seconds_left() -> float:
	return (1.0 - growth) * Balance.TREE_GROW_SECONDS if kind == MapData.KIND_TREE and not is_depleted() else 0.0


## Bụi hết quả: còn bao nhiêu giây nữa thì ra quả lại (0 nếu không chờ gì).
func regrow_seconds_left() -> float:
	return maxf(_regrow_left, 0.0) if kind == MapData.KIND_BUSH and is_depleted() else 0.0


## Đặt lại một node đã hết ở chỗ mới (đá tảng / bãi sỏi lở ra, đống củi mới), nảy "bụp" lên.
func place_again(object_cell: Vector2i, object_variant: int, jitter: Vector2 = Vector2.ZERO, start_amount: int = -1) -> void:
	setup(kind, object_cell, object_variant, jitter, start_amount)
	is_cleared = false
	growth = 1.0
	_stands.clear()
	visible = true
	_refresh_visual()
	_update_process()
	pop(0.2)


## Nảy "bụp" một cái từ cỡ `from` (vừa xuất hiện / vừa được thêm sỏi, củi).
func pop(from: float = 0.7) -> void:
	scale = Vector2(from, from)
	create_tween().tween_property(self, "scale", Vector2.ONE, POP_SECONDS).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Thêm lượng (sỏi lở thêm, cành rụng thêm). Trả về số đã thêm được (kẹp theo sức chứa).
func add_amount(count: int) -> int:
	var added: int = mini(count, capacity - amount)
	if added <= 0 or is_cleared:
		return 0
	amount += added
	_refresh_visual()
	return added


## Gốc cây mọc lại thành cây non (NatureSpawner gọi khi rừng còn thưa) rồi lớn dần.
func regrow() -> void:
	if kind != MapData.KIND_TREE or not is_depleted():
		return
	amount = capacity
	growth = 0.0
	stump_age = 0.0
	_refresh_visual()
	_update_process()


func _ready() -> void:
	_refresh_visual()
	_update_process()
	if kind == MapData.KIND_FISH_SPOT:
		add_child(FishSpotFx.new())


## Cây và bụi đung đưa theo gió; đá, sỏi, củi và chỗ câu cá thì không.
func set_wind(wind: Wind) -> void:
	match kind:
		MapData.KIND_TREE:
			_sprite.material = wind.sway_material(Wind.Profile.TREE)
		MapData.KIND_BUSH:
			_sprite.material = wind.sway_material(Wind.Profile.BUSH)


func is_depleted() -> bool:
	return amount <= 0


## Bụi còn quả để hái không.
func has_berries() -> bool:
	return kind == MapData.KIND_BUSH and not is_depleted()


## Còn làm việc ở đây được không (chặt, đập, hái, câu, nhặt). Cây non thì chưa chặt được.
func can_harvest() -> bool:
	if is_cleared:
		return false
	if kind == MapData.KIND_FISH_SPOT:
		return true
	return not is_depleted() and is_mature()


## Làm xong một lượt: lấy tối đa `count` món, đổi hình, trả về số lấy được (0 = hết rồi).
func harvest(count: int) -> int:
	if not can_harvest():
		return 0
	if kind == MapData.KIND_FISH_SPOT:
		return count
	var taken: int = mini(count, amount)
	amount -= taken
	if is_depleted():
		_on_depleted()
	_refresh_visual()
	return taken


## Hái một nắm quả trên bụi, trả về số quả.
func take_berries() -> int:
	if not has_berries():
		return 0
	return harvest(Balance.BUSH_BERRIES_PER_PICK)


## Dọn đi sỏi / củi nằm trên đất (vd chỗ đó vừa đặt móng nhà).
func clear_away() -> void:
	if not is_loose() or is_cleared:
		return
	amount = 0
	is_cleared = true
	visible = false
	_stands.clear()
	cleared.emit(self)


# --- Chỗ đứng khi nhiều người làm chung ---

func claim_stand(villager: Object, stand: Vector2i) -> void:
	_stands[villager.get_instance_id()] = stand


func release_stand(villager: Object) -> void:
	_stands.erase(villager.get_instance_id())


## Chỗ đứng người khác đang dùng ở mỏ này.
func stands_taken_by_others(villager: Object) -> Array[Vector2i]:
	var taken: Array[Vector2i] = []
	var own: int = villager.get_instance_id()
	for owner_id: int in _stands:
		if owner_id != own:
			taken.append(_stands[owner_id])
	return taken


## Để lưu game: trạng thái lúc chơi của node này.
func to_dict() -> Dictionary:
	var jitter: Vector2 = position - WorldGrid.cell_to_world(cell) - FOOT_OFFSET
	return {
		"kind": String(kind), "cell": [cell.x, cell.y], "variant": variant, "jitter": [jitter.x, jitter.y],
		"amount": amount, "growth": growth, "cleared": is_cleared, "stump_age": stump_age, "regrow": _regrow_left,
	}


## Áp trạng thái đã lưu (cùng loại). Trả về false nếu khác loại.
func apply_dict(dict: Dictionary) -> bool:
	if StringName(str(dict.get("kind", ""))) != kind:
		return false
	var saved_cell: Array = dict.get("cell", [cell.x, cell.y])
	var jitter: Array = dict.get("jitter", [0.0, 0.0])
	setup(kind, Vector2i(int(saved_cell[0]), int(saved_cell[1])), int(dict.get("variant", variant)),
			Vector2(float(jitter[0]), float(jitter[1])), int(dict.get("amount", amount)))
	growth = float(dict.get("growth", 1.0))
	is_cleared = bool(dict.get("cleared", false))
	stump_age = float(dict.get("stump_age", 0.0))
	_regrow_left = float(dict.get("regrow", 0.0))
	visible = not is_cleared
	scale = Vector2.ONE
	if is_node_ready():
		_refresh_visual()
		_update_process()
	return true


func shadow_sprite() -> Sprite2D:
	return _sprite


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
		MapData.KIND_BUSH:
			_regrow_left = Balance.BUSH_REGROW_SECONDS
		MapData.KIND_ROCK, MapData.KIND_TWIGS, MapData.KIND_PEBBLES:
			# Đá vỡ vụn / sỏi, củi đã nhặt hết: thu nhỏ rồi biến mất, ô trả lại cho lối đi.
			is_cleared = true
			_stands.clear()
			var tween: Tween = create_tween()
			tween.tween_property(self, "scale", Vector2(1.2, 0.2), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
			tween.tween_callback(func() -> void: visible = false)
			cleared.emit(self)
	_update_process()


func _update_process() -> void:
	var tree_busy: bool = kind == MapData.KIND_TREE and (is_depleted() or growth < 1.0)
	set_process(not is_cleared and (tree_busy or (kind == MapData.KIND_BUSH and is_depleted())))


func _process(delta: float) -> void:
	if kind == MapData.KIND_TREE:
		if is_depleted():
			stump_age += delta
			return
		growth = minf(growth + delta / Balance.TREE_GROW_SECONDS, 1.0)
		_apply_growth()
		if growth >= 1.0:
			set_process(false)
		return
	_regrow_left -= delta
	if _regrow_left <= 0.0:
		amount = capacity
		_refresh_visual()
		set_process(false)


func _refresh_visual() -> void:
	ArtLibrary.setup_sprite(_sprite, _art_key())
	_apply_growth()


# Cây non vẽ nhỏ hơn, lớn dần đều tới cỡ cây trưởng thành.
func _apply_growth() -> void:
	var size: float = ArtLibrary.ART_SCALE
	if kind == MapData.KIND_TREE and not is_depleted():
		size *= lerpf(Balance.YOUNG_TREE_SCALE, 1.0, growth)
	_sprite.scale = Vector2(size, size)


## Key hình đang hiện (cây / gốc, bụi theo lượng quả, bãi sỏi theo lượng…).
func art_key() -> String:
	return _art_key()


## Hậu tố hình theo lượng còn lại: "100" (> 50%), "50" (20–50%), "20" (< 20%).
func stage_suffix() -> String:
	var left: float = fraction()
	if left > Balance.RESOURCE_STAGE_HALF:
		return "100"
	if left > Balance.RESOURCE_STAGE_LOW:
		return "50"
	return "20"


func _art_key() -> String:
	match kind:
		MapData.KIND_TREE:
			return "env/tree_stump" if is_depleted() else "env/tree_%02d" % (variant + 1)
		MapData.KIND_ROCK:
			return "env/rock_%s_%s" % ["big" if variant == 0 else "small", stage_suffix()]
		MapData.KIND_BUSH:
			return "env/bush_empty" if is_depleted() else "env/bush_" + stage_suffix()
		MapData.KIND_FISH_SPOT:
			return "env/fish_spot"
		MapData.KIND_TWIGS:
			return "env/twigs_" + stage_suffix()
		MapData.KIND_PEBBLES:
			return "env/pebbles_" + stage_suffix()
	return "missing/" + String(kind)


func _capacity() -> int:
	match kind:
		MapData.KIND_TREE:
			return Balance.TREE_USES
		MapData.KIND_ROCK:
			return Balance.ROCK_STONE
		MapData.KIND_BUSH:
			return Balance.BUSH_FOOD
		MapData.KIND_TWIGS:
			return Balance.TWIG_PILE_WOOD
		MapData.KIND_PEBBLES:
			return Balance.PEBBLE_PATCH_STONE
	# Chỗ câu cá không bao giờ cạn.
	return 1
