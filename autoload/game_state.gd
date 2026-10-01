extends Node
## Trạng thái chung của một ván: seed, độ khó, tài nguyên trong kho, ngày, tốc độ game.
## Chỉ giữ dữ liệu và phát signal; không biết gì về map hay thổ dân.

enum Difficulty { EASY, NORMAL }

## Tham số dòng lệnh để ép seed khi test: `godot --path . -- --seed=42`
const SEED_ARG_PREFIX: String = "--seed="

var world_seed: int = 0
var difficulty: Difficulty = Difficulty.EASY
var day: int = 1
## 0 = tạm dừng, 1..Balance.MAX_GAME_SPEED = nhân tốc độ.
var speed: int = 1
var _resources: Dictionary[StringName, int] = {}
var _next_villager_id: int = 1


func new_game(chosen_difficulty: Difficulty = Difficulty.EASY) -> void:
	world_seed = _pick_seed()
	difficulty = chosen_difficulty
	day = 1
	_resources.clear()
	_next_villager_id = 1
	set_speed(1)


func get_amount(resource_id: StringName) -> int:
	return _resources.get(resource_id, 0)


func add_resource(resource_id: StringName, amount: int) -> void:
	var total: int = maxi(get_amount(resource_id) + amount, 0)
	_resources[resource_id] = total
	EventBus.resource_changed.emit(resource_id, total)


func set_speed(new_speed: int) -> void:
	speed = clampi(new_speed, 0, Balance.MAX_GAME_SPEED)
	# Dùng pause của SceneTree để mọi thứ trong thế giới đứng yên; UI và camera
	# đặt PROCESS_MODE_ALWAYS nên vẫn chạy.
	get_tree().paused = speed == 0
	Engine.time_scale = maxf(speed, 1)
	EventBus.game_speed_changed.emit(speed)


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
