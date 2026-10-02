class_name VillagerStatus
extends RefCounted
## Trạng thái lúc chơi của một thổ dân: 4 chỉ số (máu, đói, thể lực, giải trí), sức
## đánh, kinh nghiệm kỹ năng. Tách khỏi VillagerData vì đây là thứ thay đổi liên tục,
## còn VillagerData là "bản thiết kế" của nhân vật.
## Lưu game = VillagerData + VillagerStatus + vị trí + việc đang làm.

const MAX_NEED: float = 100.0
const DEFAULT_ATTACK: float = 10.0

var health: float = MAX_NEED
## 100 = no căng, 0 = đói lả (icon 🍖).
var hunger: float = MAX_NEED
## Thể lực (icon ⚡).
var energy: float = MAX_NEED
## Giải trí (icon 🎉).
var fun: float = MAX_NEED
var attack: float = DEFAULT_ATTACK
## Kinh nghiệm tích luỹ cho cấp kế tiếp, theo từng kỹ năng (xem VillagerSkills).
var skill_xp: Dictionary[StringName, float] = {}
## Cấp hiện tại của kỹ năng đã lên cấp lúc chơi. Chưa có mục nào = vẫn ở cấp khởi đầu
## trong VillagerData.skills.
var skill_levels: Dictionary[StringName, int] = {}


## Nhu cầu ban đầu ngẫu nhiên trong khoảng cấu hình ở Balance — mỗi người một khác.
static func starting(rng: RandomNumberGenerator) -> VillagerStatus:
	var status: VillagerStatus = VillagerStatus.new()
	status.hunger = rng.randf_range(Balance.START_HUNGER_MIN, Balance.START_HUNGER_MAX)
	status.energy = rng.randf_range(Balance.START_ENERGY_MIN, Balance.START_ENERGY_MAX)
	status.fun = rng.randf_range(Balance.START_FUN_MIN, Balance.START_FUN_MAX)
	return status


## Đọc một chỉ số theo id trong NeedDefs — để hệ nhu cầu và UI chạy theo dữ liệu.
func get_need(need_id: StringName) -> float:
	match need_id:
		NeedDefs.HEALTH:
			return health
		NeedDefs.HUNGER:
			return hunger
		NeedDefs.ENERGY:
			return energy
		NeedDefs.FUN:
			return fun
	push_warning("VillagerStatus: không có chỉ số '%s'" % need_id)
	return MAX_NEED


func set_need(need_id: StringName, value: float) -> void:
	var clamped: float = clampf(value, 0.0, MAX_NEED)
	match need_id:
		NeedDefs.HEALTH:
			health = clamped
		NeedDefs.HUNGER:
			hunger = clamped
		NeedDefs.ENERGY:
			energy = clamped
		NeedDefs.FUN:
			fun = clamped
		_:
			push_warning("VillagerStatus: không có chỉ số '%s'" % need_id)


func add_need(need_id: StringName, amount: float) -> void:
	set_need(need_id, get_need(need_id) + amount)


func add_hunger(amount: float) -> void:
	add_need(NeedDefs.HUNGER, amount)


func add_energy(amount: float) -> void:
	add_need(NeedDefs.ENERGY, amount)


func add_fun(amount: float) -> void:
	add_need(NeedDefs.FUN, amount)


## Cấp hiện tại của một kỹ năng: đã lên cấp lúc chơi thì lấy ở đây, chưa thì cấp khởi đầu.
func skill_level(skill_id: StringName, data: VillagerData) -> int:
	if skill_levels.has(skill_id):
		return clampi(skill_levels[skill_id], Balance.SKILL_MIN_LEVEL, Balance.SKILL_MAX_LEVEL)
	return data.skill_level(skill_id)


## Tâm trạng 0..100 — chỉ dùng để chọn nét mặt cười/mếu, không hiện số.
func mood() -> float:
	return hunger * Balance.MOOD_WEIGHT_HUNGER + energy * Balance.MOOD_WEIGHT_ENERGY + fun * Balance.MOOD_WEIGHT_FUN


func to_dict() -> Dictionary:
	var xp: Dictionary = {}
	for skill_id: StringName in skill_xp:
		xp[String(skill_id)] = skill_xp[skill_id]
	var levels: Dictionary = {}
	for skill_id: StringName in skill_levels:
		levels[String(skill_id)] = skill_levels[skill_id]
	return {
		"health": health, "hunger": hunger, "energy": energy, "fun": fun, "attack": attack,
		"skill_xp": xp, "skill_levels": levels,
	}


static func from_dict(dict: Dictionary) -> VillagerStatus:
	var status: VillagerStatus = VillagerStatus.new()
	status.health = float(dict.get("health", MAX_NEED))
	status.hunger = float(dict.get("hunger", MAX_NEED))
	status.energy = float(dict.get("energy", MAX_NEED))
	status.fun = float(dict.get("fun", MAX_NEED))
	status.attack = float(dict.get("attack", DEFAULT_ATTACK))
	var xp: Dictionary = dict.get("skill_xp", {})
	for skill_id: String in xp:
		status.skill_xp[StringName(skill_id)] = float(xp[skill_id])
	var levels: Dictionary = dict.get("skill_levels", {})
	for skill_id: String in levels:
		status.skill_levels[StringName(skill_id)] = int(levels[skill_id])
	return status
