extends Node
## Trạng thái chung của một ván: chế độ, seed, độ khó, tài nguyên trong kho, ngày, tốc độ.
## Chỉ giữ dữ liệu và phát signal; không biết gì về map hay thổ dân.

enum Difficulty { EASY, NORMAL }

## Tham số dòng lệnh để ép seed khi test: `godot --path . -- --seed=42`
const SEED_ARG_PREFIX: String = "--seed="
const DEV_ARG: String = "--dev"
## Giá trị hữu hạn cho các phép so sánh số nguyên; HUD hiển thị ∞ thay số này.
const DEV_RESOURCE_AMOUNT: int = 1 << 30

## Chế độ đang chơi (luật chơi đọc từ đây, xem modes/game_mode_config.gd).
var mode: GameModeConfig
var world_seed: int = 0
var difficulty: Difficulty = Difficulty.EASY
var day: int = 1
## Thời điểm trong ngày, 0..1 (0 = nửa đêm, 0.5 = trưa). Đợt 3 dùng để đổi ánh sáng.
var time_of_day: float = Balance.START_HOUR_FRACTION
## 0 = tạm dừng, 1..Balance.MAX_GAME_SPEED = nhân tốc độ.
var speed: int = 1
var _resources: Dictionary[StringName, int] = {}
## Trong một tài nguyên chung có bao nhiêu phần là món nào (thức ăn: quả / cá / thịt) — người
## chơi chỉ thấy tổng, còn thổ dân lấy ra ăn thì cầm đúng món trên tay.
var _items: Dictionary[StringName, Dictionary] = {}
## Sức chứa chung mỗi loại tài nguyên (World tính từ hang đá, Kho, Bếp). Chưa có = không giới hạn.
var _capacity: Dictionary[StringName, int] = {}
var _next_villager_id: int = 1
## Tốc độ trước khi tạm dừng — bấm Space lần nữa thì chạy lại đúng tốc độ đó.
var _speed_before_pause: int = 1
## Đồng hồ ngày chỉ chạy khi đang có ván chơi (test dựng World lẻ thì không đếm).
var _clock_running: bool = false
## Cờ của phiên chạy, không lưu vào save và không ghi đè lượng thật trong kho.
var _dev_mode: bool = false


func _ready() -> void:
	set_dev_mode(OS.get_cmdline_user_args().has(DEV_ARG))


func is_dev_mode() -> bool:
	return OS.is_debug_build() and _dev_mode


func set_dev_mode(enabled: bool) -> void:
	enabled = enabled and OS.is_debug_build()
	if _dev_mode == enabled:
		return
	_dev_mode = enabled
	EventBus.dev_mode_changed.emit(enabled)
	for resource_id: StringName in ResourceDefs.ORDER:
		EventBus.resource_changed.emit(resource_id, get_amount(resource_id))


func _is_unlimited(resource_id: StringName) -> bool:
	return is_dev_mode() and ResourceDefs.DEFS.has(resource_id)


func new_game(game_mode: GameModeConfig, chosen_difficulty: Difficulty = Difficulty.EASY) -> void:
	mode = game_mode
	world_seed = _pick_seed()
	difficulty = chosen_difficulty
	day = 1
	time_of_day = Balance.START_HOUR_FRACTION
	_resources.clear()
	_items.clear()
	_capacity.clear()
	add_resource(ResourceDefs.FOOD, Balance.START_FOOD, ResourceDefs.ITEM_BERRIES)
	_next_villager_id = 1
	_speed_before_pause = 1
	_clock_running = true
	set_speed(1)


func _process(delta: float) -> void:
	if not _clock_running:
		return
	time_of_day += delta / Balance.DAY_LENGTH_SECONDS
	if time_of_day >= 1.0:
		time_of_day -= 1.0
		day += 1
		EventBus.day_changed.emit(day)


func get_amount(resource_id: StringName) -> int:
	if _is_unlimited(resource_id):
		return DEV_RESOURCE_AMOUNT
	return _resources.get(resource_id, 0)


## Cất thêm `amount` vào kho (không vượt sức chứa). `item` = món cụ thể (vd quả, cá) nếu
## muốn nhớ để vẽ cho đúng. Trả về số đã cất được — kho đầy thì phần dư không vào được.
func add_resource(resource_id: StringName, amount: int, item: StringName = &"") -> int:
	amount = mini(amount, room(resource_id))
	if amount <= 0:
		return 0
	if item != &"":
		var items: Dictionary = _items.get_or_add(resource_id, {})
		items[item] = int(items.get(item, 0)) + amount
	# Nhặt đồ vẫn cất vào kho thật; không cộng vào lượng ảo của DEV.
	_set_amount(resource_id, int(_resources.get(resource_id, 0)) + amount)
	return amount


## Sức chứa chung (-1 = không giới hạn).
func capacity(resource_id: StringName) -> int:
	return _capacity.get(resource_id, -1)


## Còn cất thêm được bao nhiêu.
func room(resource_id: StringName) -> int:
	var cap: int = capacity(resource_id)
	if cap < 0:
		return 1 << 30
	return maxi(0, cap - int(_resources.get(resource_id, 0)))


func set_capacity(resource_id: StringName, cap: int) -> void:
	if _capacity.get(resource_id, -2) == cap:
		return
	_capacity[resource_id] = cap
	EventBus.storage_capacity_changed.emit(resource_id, cap)


## Lấy `amount` ra khỏi kho nếu đủ. Trả về false (và không lấy gì) nếu không đủ.
func take_resource(resource_id: StringName, amount: int = 1) -> bool:
	if amount > 0 and _is_unlimited(resource_id):
		return true
	if amount <= 0 or get_amount(resource_id) < amount:
		return false
	for i: int in amount:
		_take_item(resource_id)
	_set_amount(resource_id, get_amount(resource_id) - amount)
	return true


## Lấy MỘT phần ra khỏi kho, trả về món vừa lấy (vd &"fish"); không nhớ món thì trả về
## chính `resource_id`. Kho trống thì trả về &"".
func take_one(resource_id: StringName) -> StringName:
	if _is_unlimited(resource_id):
		return ResourceDefs.ITEM_BERRIES if resource_id == ResourceDefs.FOOD else resource_id
	if get_amount(resource_id) < 1:
		return &""
	var item: StringName = _take_item(resource_id)
	_set_amount(resource_id, get_amount(resource_id) - 1)
	return item if item != &"" else resource_id


## Trong kho có bao nhiêu phần là món `item`.
func item_amount(resource_id: StringName, item: StringName) -> int:
	return int(_items.get(resource_id, {}).get(item, 0))


func _set_amount(resource_id: StringName, total: int) -> void:
	_resources[resource_id] = maxi(total, 0)
	EventBus.resource_changed.emit(resource_id, get_amount(resource_id))


# Bớt một phần của món đang có nhiều nhất (ăn cho đều, kho đỡ lệch). &"" nếu không nhớ món.
func _take_item(resource_id: StringName) -> StringName:
	var items: Dictionary = _items.get(resource_id, {})
	var best: StringName = &""
	for item: StringName in items:
		if int(items[item]) > 0 and (best == &"" or int(items[item]) > int(items[best])):
			best = item
	if best != &"":
		items[best] = int(items[best]) - 1
	return best


func set_speed(new_speed: int) -> void:
	speed = clampi(new_speed, 0, Balance.MAX_GAME_SPEED)
	if speed > 0:
		_speed_before_pause = speed
	# Dùng pause của SceneTree để mọi thứ trong thế giới đứng yên; UI và camera
	# đặt PROCESS_MODE_ALWAYS nên vẫn chạy.
	get_tree().paused = speed == 0
	Engine.time_scale = maxf(speed, 1)
	EventBus.game_speed_changed.emit(speed)


## Tạm dừng ↔ chạy lại tốc độ trước đó.
func toggle_pause() -> void:
	set_speed(_speed_before_pause if speed == 0 else 0)


# Ưu tiên: seed dòng lệnh > seed cố định trong Balance > ngẫu nhiên.
func _pick_seed() -> int:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with(SEED_ARG_PREFIX):
			return arg.trim_prefix(SEED_ARG_PREFIX).to_int()
	if Balance.DEBUG_FIXED_SEED >= 0:
		return Balance.DEBUG_FIXED_SEED
	return randi()


## Mã số riêng cho mỗi thổ dân (để lưu game và liên kết cặp đôi sau này).
func next_villager_id() -> int:
	var id: int = _next_villager_id
	_next_villager_id += 1
	return id


## Để lưu game: những gì của ván chơi không nằm trong thế giới (seed, ngày giờ, kho chung…).
func to_dict() -> Dictionary:
	var resources: Dictionary = {}
	for resource_id: StringName in _resources:
		resources[String(resource_id)] = _resources[resource_id]
	var items: Dictionary = {}
	for resource_id: StringName in _items:
		var inner: Dictionary = {}
		for item: StringName in _items[resource_id]:
			inner[String(item)] = _items[resource_id][item]
		items[String(resource_id)] = inner
	return {
		"seed": world_seed, "difficulty": Difficulty.keys()[difficulty], "day": day,
		"time_of_day": time_of_day, "resources": resources, "items": items,
		"next_villager_id": _next_villager_id,
	}


## Áp ván đã lưu (gọi sau new_game, trước khi dựng thế giới — vì seed quyết định map).
## Kho chung nạp sau, khi thế giới đã tính xong sức chứa: xem apply_saved_resources().
func apply_dict(dict: Dictionary) -> void:
	world_seed = int(dict.get("seed", world_seed))
	difficulty = Difficulty.get(str(dict.get("difficulty", "EASY")), Difficulty.EASY) as Difficulty
	day = int(dict.get("day", 1))
	time_of_day = float(dict.get("time_of_day", Balance.START_HOUR_FRACTION))
	_next_villager_id = int(dict.get("next_villager_id", 1))


func apply_saved_resources(dict: Dictionary) -> void:
	_resources.clear()
	_items.clear()
	var resources: Dictionary = dict.get("resources", {})
	for resource_id: String in resources:
		_set_amount(StringName(resource_id), int(resources[resource_id]))
	var items: Dictionary = dict.get("items", {})
	for resource_id: String in items:
		var inner: Dictionary = {}
		for item: String in items[resource_id]:
			inner[StringName(item)] = int(items[resource_id][item])
		_items[StringName(resource_id)] = inner


## Mã số kế tiếp phải lớn hơn mọi mã đã dùng (sau khi tải game).
func reserve_villager_id(used_id: int) -> void:
	_next_villager_id = maxi(_next_villager_id, used_id + 1)


## Chế độ đang chơi; chưa nạp chế độ nào (vd trong test) thì dùng luật mặc định = Normal.
func get_mode() -> GameModeConfig:
	if mode == null:
		mode = GameModeConfig.new()
	return mode
