extends Node
## Trạng thái chung của một ván: chế độ, seed, độ khó, tài nguyên trong kho, ngày, tốc độ.
## Chỉ giữ dữ liệu và phát signal; không biết gì về map hay thổ dân.

enum Difficulty { EASY, NORMAL }

## Tham số dòng lệnh để ép seed khi test: `godot --path . -- --seed=42`
const SEED_ARG_PREFIX: String = "--seed="

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
var _next_villager_id: int = 1
## Tốc độ trước khi tạm dừng — bấm Space lần nữa thì chạy lại đúng tốc độ đó.
var _speed_before_pause: int = 1
## Đồng hồ ngày chỉ chạy khi đang có ván chơi (test dựng World lẻ thì không đếm).
var _clock_running: bool = false


func new_game(game_mode: GameModeConfig, chosen_difficulty: Difficulty = Difficulty.EASY) -> void:
	mode = game_mode
	world_seed = _pick_seed()
	difficulty = chosen_difficulty
	day = 1
	time_of_day = Balance.START_HOUR_FRACTION
	_resources.clear()
	_items.clear()
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
	return _resources.get(resource_id, 0)


## Cất thêm `amount` vào kho. `item` = món cụ thể (vd quả, cá) nếu muốn nhớ để vẽ cho đúng.
func add_resource(resource_id: StringName, amount: int, item: StringName = &"") -> void:
	if amount <= 0:
		return
	if item != &"":
		var items: Dictionary = _items.get_or_add(resource_id, {})
		items[item] = int(items.get(item, 0)) + amount
	_set_amount(resource_id, get_amount(resource_id) + amount)


## Lấy `amount` ra khỏi kho nếu đủ. Trả về false (và không lấy gì) nếu không đủ.
func take_resource(resource_id: StringName, amount: int = 1) -> bool:
	if amount <= 0 or get_amount(resource_id) < amount:
		return false
	for i: int in amount:
		_take_item(resource_id)
	_set_amount(resource_id, get_amount(resource_id) - amount)
	return true


## Lấy MỘT phần ra khỏi kho, trả về món vừa lấy (vd &"fish"); không nhớ món thì trả về
## chính `resource_id`. Kho trống thì trả về &"".
func take_one(resource_id: StringName) -> StringName:
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
	EventBus.resource_changed.emit(resource_id, _resources[resource_id])


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


## Chế độ đang chơi; chưa nạp chế độ nào (vd trong test) thì dùng luật mặc định = Normal.
func get_mode() -> GameModeConfig:
	if mode == null:
		mode = GameModeConfig.new()
	return mode
