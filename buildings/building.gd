class_name Building
extends Node2D
## Một scene chung cho mọi công trình, dựng theo dữ liệu trong data/buildings.gd.
## - Công trình dựng sẵn (hang, lửa trại, vách đá) chỉ có một cấp.
## - Công trình xây được có 3 cấp. Mới đặt thì là MÓNG (level = 0) đang chờ xây lên cấp 1;
##   nâng cấp cũng là một lượt xây (construction) nhưng trong lúc đó vẫn chạy ở cấp cũ.
##   Thợ xây khuân vật liệu tới đổ vào công trường (`deliver_material`), đủ rồi mới gõ búa
##   (`add_build_work`); xong thì nảy "bụp", pháo giấy (EventBus.building_completed).
## - Kho RIÊNG (`stock`): món chín ở bếp, rìu/cuốc/giáo ở lò rèn… — khác với tài nguyên
##   chung của làng trong GameState.
## - Lò rèn nhận đơn đặt rèn (`orders`) — thợ rèn làm lần lượt.
## Thuộc tính theo cấp đọc qua prop().

signal stock_changed(building: Building)
## Cấp, tiến độ xây, người phụ trách, đơn rèn… vừa đổi — bảng công trình vẽ lại.
signal changed(building: Building)

## Gốc node nằm sát mép dưới footprint (lùi lên một chút) để y-sort đúng với thổ dân.
const FOOT_INSET: float = 12.0
const DEFAULT_FRAME_FPS: float = 8.0
## Phập phồng nhẹ chồng lên các khung hình, để chuyển khung không bị khựng.
const FLICKER_SPEED: float = 9.0
const FLICKER_AMOUNT: float = 0.04
## Phần hình nhô lên trên footprint vẫn tính là chạm trúng công trình.
const HIT_EXTRA_HEIGHT: float = 40.0
const STOCK_ITEM_SCALE: float = 0.8
const REVEAL_SHADER: Shader = preload("res://fx/build_reveal.gdshader")
const POP_SECONDS: float = 0.45
const WARNING_KEY: String = "icons/warning"
const WARNING_BOB: float = 3.0
const WARNING_HEIGHT: float = 0.62 # tỉ lệ chiều cao hình tính từ chân
const BAR_WIDTH: float = 76.0
const BAR_HEIGHT: float = 8.0
const BAR_ICON: float = 16.0
const BAR_GAP: float = 4.0
const BAR_MATERIAL_COLOR: Color = Color("#A1887F")
const BAR_BUILD_COLOR: Color = Color("#FFD54F")
const BAR_BACK_COLOR: Color = Color("#EFE3D3")
const OUTLINE_COLOR: Color = Color("#4E342E")
const ZZZ_INTERVAL: float = 1.1
const ZZZ_LIFE: float = 1.8
## Cọc giàn giáo cắm quanh công trình đang nâng cấp (vẽ bằng code).
const SCAFFOLD_COLOR: Color = Color("#8D6E63")

## Mã số do World cấp — Commands dùng để nói tới công trình này.
var uid: int = 0
var building_id: StringName = &""
var origin_cell: Vector2i = Vector2i.ZERO
var def: Dictionary = {}
## 0 = móng chưa xây xong; 1..3 = cấp đang hoạt động.
var level: int = 1
## Lượt xây đang dở ({} = không xây gì): target_level, delivered {tài nguyên: số đã đổ vào},
## progress 0..1 (phần gõ búa, chỉ chạy khi đã đủ vật liệu).
var construction: Dictionary = {}
## Vật liệu thợ xây đang khuân trên đường tới (để người sau không khuân thừa).
var pledged: Dictionary[StringName, int] = {}
## Bị huỷ (móng bị huỷ) — node không bị xoá, chỉ ẩn, để không ai giữ tham chiếu tới node đã free.
var demolished: bool = false
## Đồ riêng đang cất ở đây: {món: số}.
var stock: Dictionary[StringName, int] = {}
## Lò rèn: còn phải rèn bao nhiêu món mỗi loại.
var orders: Dictionary[StringName, int] = {}
## Người phụ trách hiện tại (World cập nhật định kỳ) — chỉ để hiển thị và cảnh báo.
var staff: Array[Villager] = []
## Thợ xây đang nhận việc xây ở đây (World cập nhật định kỳ) — để hiển thị.
var builders: Array[Villager] = []
## Người đang ngủ trong lều.
var sleepers: Array[Villager] = []

var kitchen: KitchenInterior

var _time: float = 0.0
var _frames: Array[Texture2D] = []
var _frame_fps: float = DEFAULT_FRAME_FPS
var _fx: Node
## Hình đồ riêng bày quanh công trình: {món: [sprite theo từng chỗ]}.
var _stock_sprites: Dictionary[StringName, Array] = {}
var _foundation: Sprite2D
var _ghost: Sprite2D
var _ghost_material: ShaderMaterial
var _warning: Sprite2D
var _overlay: Node2D
var _zzz_timer: float = 0.0
## Món rèn lần trước — lần sau bắt đầu từ món kế tiếp cho đều.
var _last_forged: int = -1

@onready var _sprite: Sprite2D = $Sprite
@onready var _extra_sprite: Sprite2D = $ExtraSprite


## `start_level` = 0 để đặt móng (chờ thợ xây lên cấp 1).
func setup(id: StringName, cell: Vector2i, start_level: int = 1) -> void:
	building_id = id
	origin_cell = cell
	def = BuildingDefs.get_def(id)
	level = start_level
	if level <= 0:
		level = 0
		start_construction(1)
	var footprint: Vector2i = BuildingDefs.footprint(id)
	var tile: float = Balance.TILE_SIZE
	position = Vector2((cell.x + footprint.x * 0.5) * tile, (cell.y + footprint.y) * tile - FOOT_INSET)


func _ready() -> void:
	if building_id == BuildingDefs.KITCHEN:
		y_sort_enabled = true
		kitchen = KitchenInterior.new(self)
	_foundation = Sprite2D.new()
	_foundation.position = Vector2(0, FOOT_INSET)
	add_child(_foundation)
	move_child(_foundation, 0)
	_ghost = Sprite2D.new()
	_ghost_material = ShaderMaterial.new()
	_ghost_material.shader = REVEAL_SHADER
	_ghost.material = _ghost_material
	add_child(_ghost)
	move_child(_ghost, 1)
	_setup_extra_art()
	_setup_stock_display()
	var fx_path: String = def.get("fx_scene", "")
	if not fx_path.is_empty():
		var fx_scene: PackedScene = load(fx_path)
		_fx = fx_scene.instantiate()
		if _fx is Node2D:
			(_fx as Node2D).position = def.get("fx_offset", Vector2.ZERO)
		add_child(_fx)
	_warning = Sprite2D.new()
	ArtLibrary.setup_sprite(_warning, WARNING_KEY)
	_warning.visible = false
	add_child(_warning)
	_overlay = Node2D.new()
	_overlay.draw.connect(_draw_overlay)
	add_child(_overlay)
	# Lệch pha ngẫu nhiên để nhiều đống lửa không nhảy cùng nhịp.
	_time = randf() * 10.0
	_refresh_visual()


## Gắn gió: hình phụ (vd ngọn lửa) nghiêng theo gió, hiệu ứng (tàn lửa) bị gió đẩy.
func set_wind(wind: Wind) -> void:
	if def.get("extra_art_sways", false) and _extra_sprite.visible:
		_extra_sprite.material = wind.sway_material(Wind.Profile.FLAME)
	if _fx != null and _fx.has_method("set_wind"):
		_fx.call("set_wind", wind)


## Hình chính (để ShadowLayer đổ bóng theo đúng hình đang hiện).
func shadow_sprite() -> Sprite2D:
	return _sprite


# --- Thuộc tính theo cấp ---

## Thuộc tính `key` ở cấp đang hoạt động (cấp ghi đè thuộc tính chung). Móng chưa có cấp
## nào nên chỉ đọc thuộc tính chung.
func prop(key: String, default_value: Variant = null) -> Variant:
	var at_level: Dictionary = BuildingDefs.level_def(building_id, level)
	if at_level.has(key):
		return at_level[key]
	return def.get(key, default_value)


func max_level() -> int:
	return BuildingDefs.max_level(building_id)


## Đã xây xong ít nhất cấp 1 (đang nâng cấp vẫn tính là hoạt động ở cấp cũ).
func is_built() -> bool:
	return level >= 1 and not demolished


func is_foundation() -> bool:
	return level == 0 and not demolished


func name_key() -> String:
	return BuildingDefs.name_key(building_id)


## Có nhận cất loại tài nguyên chung này không (kho tạm ở hang, Kho, Bếp).
func accepts(resource_id: StringName) -> bool:
	return is_built() and bool(prop(ResourceDefs.storage_flag(resource_id), false))


## Góp bao nhiêu vào sức chứa chung của làng cho loại tài nguyên này.
func storage_capacity(resource_id: StringName) -> int:
	if not accepts(resource_id):
		return 0
	return int((prop("capacity", {}) as Dictionary).get(resource_id, 0))


func is_production() -> bool:
	return bool(def.get("production", false))


func staff_job() -> StringName:
	return def.get("staff_job", &"")


## Số người phụ trách tối đa ở cấp hiện tại.
func staff_capacity() -> int:
	return int(prop("staff", 0)) if is_built() else 0


func sleep_slots() -> int:
	return int(prop("sleep_slots", 0)) if is_built() else 0


func action() -> StringName:
	return def.get("action", &"")


func is_walkable() -> bool:
	return bool(def.get("walkable", false))


## Thiếu người phụ trách: công trình sản xuất đã xong mà không ai làm → ngừng, hiện cảnh báo.
func needs_staff() -> bool:
	return is_production() and is_built() and staff.is_empty()


# --- Xây & nâng cấp ---

func is_constructing() -> bool:
	return not construction.is_empty() and not demolished


func can_upgrade() -> bool:
	return is_built() and not is_constructing() and level < max_level()


## Bắt đầu một lượt xây lên `next_level` (móng → 1, hoặc nâng cấp). Thợ xây khuân vật liệu tới.
func start_construction(next_level: int) -> void:
	construction = {"target_level": next_level, "delivered": {}, "progress": 0.0}
	pledged.clear()
	_refresh_visual()
	changed.emit(self)


func target_level() -> int:
	return int(construction.get("target_level", level))


## Tổng vật liệu cần cho lượt xây đang dở.
func construction_cost() -> Dictionary:
	return BuildingDefs.cost(building_id, target_level())


func delivered(resource_id: StringName) -> int:
	return int((construction.get("delivered", {}) as Dictionary).get(resource_id, 0))


## Còn thiếu bao nhiêu (trừ phần đã đổ và phần đang có người khuân tới).
func material_missing(resource_id: StringName) -> int:
	if not is_constructing():
		return 0
	var needed: int = int(construction_cost().get(resource_id, 0))
	return maxi(0, needed - delivered(resource_id) - int(pledged.get(resource_id, 0)))


func materials_complete() -> bool:
	if not is_constructing():
		return false
	var cost: Dictionary = construction_cost()
	for resource_id: StringName in cost:
		if delivered(resource_id) < int(cost[resource_id]):
			return false
	return true


## Tỉ lệ vật liệu đã đổ vào (0..1) — thanh tiến độ thứ nhất.
func materials_fraction() -> float:
	var cost: Dictionary = construction_cost()
	var total: int = 0
	var done: int = 0
	for resource_id: StringName in cost:
		total += int(cost[resource_id])
		done += mini(delivered(resource_id), int(cost[resource_id]))
	return 1.0 if total == 0 else float(done) / total


func build_progress() -> float:
	return float(construction.get("progress", 0.0))


func pledge(resource_id: StringName, amount: int) -> void:
	pledged[resource_id] = int(pledged.get(resource_id, 0)) + amount


func unpledge(resource_id: StringName, amount: int) -> void:
	pledged[resource_id] = maxi(0, int(pledged.get(resource_id, 0)) - amount)


## Thợ xây đổ vật liệu vào công trường.
func deliver_material(resource_id: StringName, amount: int) -> void:
	if not is_constructing():
		return
	unpledge(resource_id, amount)
	var done: Dictionary = construction["delivered"]
	done[resource_id] = int(done.get(resource_id, 0)) + amount
	_overlay.queue_redraw()
	changed.emit(self)


## Gõ búa: `seconds` = giây làm việc đã nhân tốc độ của thợ. Xong thì lên cấp. Trả về true
## nếu vừa xây xong.
func add_build_work(seconds: float) -> bool:
	if not is_constructing() or not materials_complete():
		return false
	var total: float = BuildingDefs.build_seconds(building_id, target_level())
	construction["progress"] = minf(1.0, build_progress() + seconds / maxf(total, 0.01))
	_ghost_material.set_shader_parameter("progress", build_progress())
	_overlay.queue_redraw()
	if build_progress() < 1.0:
		return false
	_finish_construction()
	return true


## Huỷ lượt xây đang dở. Trả về vật liệu đã đổ vào (để cất lại kho).
func cancel_construction() -> Dictionary:
	var refund: Dictionary = (construction.get("delivered", {}) as Dictionary).duplicate()
	construction = {}
	pledged.clear()
	if level <= 0:
		demolished = true
		visible = false
	else:
		_refresh_visual()
	changed.emit(self)
	return refund


func _finish_construction() -> void:
	level = target_level()
	construction = {}
	pledged.clear()
	_refresh_visual()
	_refresh_stock_display()
	# Nảy "bụp" một cái khi xong.
	scale = Vector2(1.15, 0.8)
	create_tween().tween_property(self, "scale", Vector2.ONE, POP_SECONDS).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	changed.emit(self)
	EventBus.building_completed.emit(self, level)
	var toast: String = "TOAST_BUILDING_DONE" if level == 1 else "TOAST_BUILDING_UPGRADED"
	EventBus.village_event.emit(toast, {"building_key": name_key(), "level": level}, "icons/skill_build")


# --- Lò rèn ---

func order_count(tool: StringName) -> int:
	return int(orders.get(tool, 0))


func set_order(tool: StringName, count: int) -> void:
	orders[tool] = clampi(count, 0, Balance.FORGE_MAX_ORDER)
	changed.emit(self)


## Món kế tiếp cần rèn (còn đơn và còn chỗ cất), lần lượt từng loại. &"" nếu không có gì.
func next_order() -> StringName:
	var count: int = ToolDefs.ORDER.size()
	for step: int in count:
		var index: int = (_last_forged + 1 + step) % count
		var tool: StringName = ToolDefs.ORDER[index]
		if order_count(tool) > 0 and has_room_for(tool):
			return tool
	return &""


## Thợ rèn nhận một đơn (trừ đơn ngay để hai thợ không rèn trùng). Trả lại bằng return_order().
func take_order(tool: StringName) -> void:
	orders[tool] = maxi(0, order_count(tool) - 1)
	_last_forged = ToolDefs.ORDER.find(tool)
	changed.emit(self)


func return_order(tool: StringName) -> void:
	orders[tool] = order_count(tool) + 1
	changed.emit(self)


# --- Người phụ trách & người ngủ ---

func set_staff(villagers: Array[Villager]) -> void:
	if villagers == staff:
		return
	staff = villagers
	changed.emit(self)


func set_builders(villagers: Array[Villager]) -> void:
	if villagers == builders:
		return
	builders = villagers
	changed.emit(self)


func add_sleeper(villager: Villager) -> void:
	if not sleepers.has(villager):
		sleepers.append(villager)
		changed.emit(self)


func remove_sleeper(villager: Villager) -> void:
	if sleepers.has(villager):
		sleepers.erase(villager)
		changed.emit(self)


## Lều rung nhẹ (có người chui vào/ra).
func wiggle() -> void:
	var tween: Tween = _sprite.create_tween()
	tween.tween_property(_sprite, "rotation", 0.04, 0.08)
	tween.tween_property(_sprite, "rotation", -0.03, 0.1)
	tween.tween_property(_sprite, "rotation", 0.0, 0.1)


# --- Chạm ---

## Chạm trúng công trình không: phủ footprint + phần thân nhô lên phía trên.
func hit_test(world_point: Vector2) -> bool:
	if demolished:
		return false
	var size: Vector2 = Vector2(BuildingDefs.footprint(building_id)) * Balance.TILE_SIZE
	var bottom: float = position.y + FOOT_INSET
	var height: float = maxf(size.y + HIT_EXTRA_HEIGHT, _art_height() + FOOT_INSET)
	var rect: Rect2 = Rect2(position.x - size.x * 0.5, bottom - height, size.x, height)
	return rect.has_point(world_point)


func footprint_cells() -> Array[Vector2i]:
	return BuildingDefs.footprint_cells(building_id, origin_cell)


# --- Kho riêng ---

func stock_of(item: StringName) -> int:
	return stock.get(item, 0)


## Cất tối đa bao nhiêu món này (-1 = không giới hạn).
func stock_capacity(item: StringName) -> int:
	return int((prop("stock_capacity", {}) as Dictionary).get(item, -1))


func has_room_for(item: StringName) -> bool:
	var capacity: int = stock_capacity(item)
	return capacity < 0 or stock_of(item) < capacity


## Cất thêm (không vượt sức chứa, trừ khi `force` — vd thổ dân trả lại đồ nghề cũ khi đổi món,
## không được làm mất). Trả về số đã cất được.
func add_stock(item: StringName, amount: int = 1, force: bool = false) -> int:
	var capacity: int = stock_capacity(item)
	var added: int = amount if capacity < 0 or force else clampi(capacity - stock_of(item), 0, amount)
	if added > 0:
		stock[item] = stock_of(item) + added
		_refresh_stock_display()
		stock_changed.emit(self)
	return added


func take_stock(item: StringName, amount: int = 1) -> bool:
	if stock_of(item) < amount:
		return false
	stock[item] = stock_of(item) - amount
	_refresh_stock_display()
	stock_changed.emit(self)
	return true


# --- Lưu game ---

func to_dict() -> Dictionary:
	var stock_out: Dictionary = {}
	for item: StringName in stock:
		stock_out[String(item)] = stock[item]
	var orders_out: Dictionary = {}
	for tool: StringName in orders:
		orders_out[String(tool)] = orders[tool]
	var construction_out: Dictionary = {}
	if is_constructing():
		var delivered_out: Dictionary = {}
		var done: Dictionary = construction["delivered"]
		for resource_id: StringName in done:
			delivered_out[String(resource_id)] = done[resource_id]
		construction_out = {"target_level": target_level(), "delivered": delivered_out, "progress": build_progress()}
	return {
		"uid": uid, "id": String(building_id), "cell": [origin_cell.x, origin_cell.y], "level": level,
		"construction": construction_out, "stock": stock_out, "orders": orders_out,
	}


## Áp trạng thái đã lưu (cấp, lượt xây dở, đồ riêng, đơn rèn) — vị trí, loại đã setup trước.
func apply_dict(dict: Dictionary) -> void:
	level = int(dict.get("level", level))
	construction = {}
	var saved: Dictionary = dict.get("construction", {})
	if not saved.is_empty():
		var delivered_in: Dictionary = {}
		var done: Dictionary = saved.get("delivered", {})
		for resource_id: String in done:
			delivered_in[StringName(resource_id)] = int(done[resource_id])
		construction = {"target_level": int(saved.get("target_level", level + 1)), "delivered": delivered_in,
				"progress": float(saved.get("progress", 0.0))}
	stock.clear()
	var stock_in: Dictionary = dict.get("stock", {})
	for item: String in stock_in:
		stock[StringName(item)] = int(stock_in[item])
	orders.clear()
	var orders_in: Dictionary = dict.get("orders", {})
	for tool: String in orders_in:
		orders[StringName(tool)] = int(orders_in[tool])
	if is_node_ready():
		_refresh_visual()
		_refresh_stock_display()
	changed.emit(self)


# --- Hình ảnh ---

func _refresh_visual() -> void:
	if not is_node_ready():
		return
	var building: bool = is_constructing()
	_foundation.visible = level == 0
	if _foundation.visible:
		ArtLibrary.setup_sprite(_foundation, BuildingDefs.foundation_art(building_id))
	_sprite.visible = level >= 1
	if _sprite.visible:
		ArtLibrary.setup_sprite(_sprite, BuildingDefs.art(building_id, level))
	if kitchen != null:
		_sprite.self_modulate.a = 0.0
		kitchen.refresh()
		if level >= 1:
			# Chỉ mái đổ bóng cao; sân đất không đổ bóng như một bức tường.
			ArtLibrary.setup_sprite(_sprite, "buildings/kitchen/roof_" + str(level))
		_warning.z_index = 2
		_overlay.z_index = 2
		_warning.position.x = KitchenLayout.local_point(Vector2(88, 113), maxi(level, 1)).x
	# Móng: hình công trình mờ mờ, mọc dần từ dưới lên theo tiến độ xây.
	_ghost.visible = building and level == 0
	if _ghost.visible:
		ArtLibrary.setup_sprite(_ghost, BuildingDefs.art(building_id, target_level()))
		_ghost_material.set_shader_parameter("progress", build_progress())
	_extra_sprite.visible = not _frames.is_empty() and level >= 1
	_warning.position.y = _warning_y()
	set_process(true)
	_overlay.queue_redraw()


# Cảnh báo nằm trên mái (không lơ lửng phía trên — dễ lẫn sang công trình đứng sau).
func _warning_y() -> float:
	if kitchen != null:
		return KitchenLayout.local_point(Vector2(88, 113), maxi(level, 1)).y
	return -_art_height() * WARNING_HEIGHT


func _art_height() -> float:
	var sprite: Sprite2D = _sprite if _sprite != null and _sprite.visible else _ghost
	if sprite == null or sprite.texture == null:
		return Vector2(BuildingDefs.footprint(building_id)).y * Balance.TILE_SIZE
	return -sprite.offset.y * sprite.scale.y


func _process(delta: float) -> void:
	_time += delta
	if not _frames.is_empty() and _extra_sprite.visible:
		_extra_sprite.texture = _frames[int(_time * _frame_fps) % _frames.size()]
		var wave: float = sin(_time * FLICKER_SPEED)
		var base: float = ArtLibrary.ART_SCALE
		_extra_sprite.scale = Vector2(base * (1.0 - wave * FLICKER_AMOUNT * 0.5), base * (1.0 + wave * FLICKER_AMOUNT))
	_warning.visible = needs_staff()
	if _warning.visible:
		_warning.position.y = _warning_y() + sin(_time * 4.0) * WARNING_BOB
	if not sleepers.is_empty():
		_zzz_timer -= delta
		if _zzz_timer <= 0.0:
			_zzz_timer = ZZZ_INTERVAL
			_float_zzz()


# Thanh tiến độ trên đầu công trình đang xây: vật liệu (nâu) rồi gõ búa (vàng). Đang nâng
# cấp thì cắm thêm vài cọc giàn giáo cho thấy "đang sửa".
func _draw_overlay() -> void:
	if not is_constructing():
		return
	var top: float = -_art_height() - 8.0
	if level >= 1:
		_draw_scaffold()
	var left: float = -BAR_WIDTH * 0.5 + BAR_ICON * 0.5
	_draw_bar(Vector2(left, top - BAR_HEIGHT * 2.0 - BAR_GAP), materials_fraction(), BAR_MATERIAL_COLOR, "icons/res_wood")
	_draw_bar(Vector2(left, top - BAR_HEIGHT), build_progress(), BAR_BUILD_COLOR, "icons/skill_build")


func _draw_bar(at: Vector2, fraction: float, color: Color, icon_key: String) -> void:
	var icon: Texture2D = ArtLibrary.get_texture(icon_key)
	_overlay.draw_texture_rect(icon, Rect2(at + Vector2(-BAR_ICON - 2.0, -BAR_ICON * 0.25), Vector2(BAR_ICON, BAR_ICON)), false)
	var rect: Rect2 = Rect2(at, Vector2(BAR_WIDTH, BAR_HEIGHT))
	_overlay.draw_rect(rect.grow(2.0), OUTLINE_COLOR)
	_overlay.draw_rect(rect, BAR_BACK_COLOR)
	_overlay.draw_rect(Rect2(at, Vector2(BAR_WIDTH * clampf(fraction, 0.0, 1.0), BAR_HEIGHT)), color)


func _draw_scaffold() -> void:
	var half: float = Vector2(BuildingDefs.footprint(building_id)).x * Balance.TILE_SIZE * 0.5 - 6.0
	var height: float = minf(_art_height() * 0.7, 120.0)
	for x: float in [-half, half]:
		_overlay.draw_line(Vector2(x, 6), Vector2(x, -height), OUTLINE_COLOR, 7.0)
		_overlay.draw_line(Vector2(x, 6), Vector2(x, -height), SCAFFOLD_COLOR, 4.0)
	for y: float in [-height * 0.35, -height * 0.8]:
		_overlay.draw_line(Vector2(-half, y), Vector2(half, y), OUTLINE_COLOR, 6.0)
		_overlay.draw_line(Vector2(-half, y), Vector2(half, y), SCAFFOLD_COLOR, 3.0)


func _float_zzz() -> void:
	var sprite: Sprite2D = Sprite2D.new()
	ArtLibrary.setup_sprite(sprite, "fx/zzz")
	var base: Vector2 = sprite.scale
	var start: Vector2 = Vector2(randf_range(-16.0, 16.0), -_art_height() * 0.6)
	sprite.position = start
	sprite.scale = base * 0.6
	add_child(sprite)
	var tween: Tween = sprite.create_tween().set_parallel(true)
	tween.tween_property(sprite, "position", start + Vector2(24, -40), ZZZ_LIFE).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "scale", base * 1.2, ZZZ_LIFE)
	tween.tween_property(sprite, "modulate:a", 0.0, ZZZ_LIFE * 0.5).set_delay(ZZZ_LIFE * 0.5)
	tween.finished.connect(sprite.queue_free)


func _setup_stock_display() -> void:
	var display: Dictionary = def.get("stock_display", {})
	for item: StringName in display:
		var sprites: Array[Sprite2D] = []
		for slot: Vector2 in display[item]["slots"]:
			var sprite: Sprite2D = Sprite2D.new()
			ArtLibrary.setup_sprite(sprite, display[item]["art"])
			sprite.scale *= STOCK_ITEM_SCALE
			sprite.position = slot
			sprite.visible = false
			add_child(sprite)
			sprites.append(sprite)
		_stock_sprites[item] = sprites
	_refresh_stock_display()


func _refresh_stock_display() -> void:
	for item: StringName in _stock_sprites:
		var sprites: Array = _stock_sprites[item]
		for i: int in sprites.size():
			var sprite: Sprite2D = sprites[i]
			var wanted: bool = i < stock_of(item) and is_built()
			if wanted and not sprite.visible:
				sprite.scale = Vector2.ZERO
				var base: Vector2 = Vector2(ArtLibrary.ART_SCALE, ArtLibrary.ART_SCALE) * STOCK_ITEM_SCALE
				sprite.create_tween().tween_property(sprite, "scale", base, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			sprite.visible = wanted


func _setup_extra_art() -> void:
	var keys: Array = def.get("extra_art_frames", [])
	_extra_sprite.visible = not keys.is_empty()
	if keys.is_empty():
		return
	for key: String in keys:
		_frames.append(ArtLibrary.get_texture(key))
	ArtLibrary.setup_sprite(_extra_sprite, keys[0])
	_extra_sprite.position = def.get("extra_art_offset", Vector2.ZERO)
	_frame_fps = def.get("extra_art_fps", DEFAULT_FRAME_FPS)
