class_name Traits
## Định nghĩa tính cách bằng dữ liệu. Code không hỏi "có phải Lười không" mà hỏi
## "hệ số làm việc là bao nhiêu" — thêm tính cách mới chỉ cần thêm một mục ở đây.
##
## Mỗi tính cách có key dịch TRAIT_<ID>_NAME / TRAIT_<ID>_DESC trong i18n/strings.csv.
## - Hệ số nhân (mặc định 1.0): work_speed, hunger_rate, eat_joy (giải trí khi ăn), attack,
##   romance (tỉ lệ đi tìm bạn đời, Đợt 4), work_fun_drain (giải trí giảm khi làm việc).
## - skill_bonus: các kỹ năng được cộng cấp khởi đầu.
## - idle_weights: nhân trọng số chọn hoạt cảnh rảnh rỗi (xem VillagerBrain).
## - flags: cờ hành vi, vd "flee_from_danger", "takes_breaks" (hay nghỉ tay giữa chừng khi làm việc).

const LAZY: StringName = &"LAZY"
const GLUTTON: StringName = &"GLUTTON"
const STRONG: StringName = &"STRONG"
const COWARD: StringName = &"COWARD"
const DANCER: StringName = &"DANCER"
const ROMANTIC: StringName = &"ROMANTIC"
const PLAYFUL: StringName = &"PLAYFUL"
const DILIGENT: StringName = &"DILIGENT"

const DEFS: Dictionary[StringName, Dictionary] = {
	LAZY: {"work_speed": 0.8, "flags": [&"takes_breaks"], "idle_weights": {&"sit": 2.5, &"scratch": 1.5}},
	GLUTTON: {"hunger_rate": 1.35, "eat_joy": 2.0},
	STRONG: {"skill_bonus": [&"CHOP", &"MINE", &"FIGHT"], "attack": 1.3},
	COWARD: {"flags": [&"flee_from_danger"]},
	DANCER: {"idle_weights": {&"dance": 3.0, &"chat": 1.2}},
	ROMANTIC: {"romance": 2.0, "idle_weights": {&"pick_flower": 3.0}},
	PLAYFUL: {"idle_weights": {&"chat": 1.8, &"stroll": 1.5, &"scratch": 1.3}},
	DILIGENT: {"work_speed": 1.15, "work_fun_drain": 0.75, "idle_weights": {&"sit": 0.5}},
}

## Cặp tính cách không được có cùng lúc.
const EXCLUSIVE_PAIRS: Array[Array] = [[LAZY, DILIGENT], [COWARD, STRONG]]


static func all_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	ids.assign(DEFS.keys())
	return ids


static func name_key(id: StringName) -> String:
	return "TRAIT_%s_NAME" % id


static func desc_key(id: StringName) -> String:
	return "TRAIT_%s_DESC" % id


## Tích hệ số `key` của mọi tính cách (không có thì 1.0).
static func modifier(traits: Array[StringName], key: String) -> float:
	var result: float = 1.0
	for id: StringName in traits:
		result *= float(DEFS.get(id, {}).get(key, 1.0))
	return result


## Hệ số nhân trọng số cho một hoạt cảnh rảnh rỗi.
static func idle_weight(traits: Array[StringName], activity: StringName) -> float:
	var result: float = 1.0
	for id: StringName in traits:
		var weights: Dictionary = DEFS.get(id, {}).get("idle_weights", {})
		result *= float(weights.get(activity, 1.0))
	return result


static func has_flag(traits: Array[StringName], flag: StringName) -> bool:
	for id: StringName in traits:
		var flags: Array = DEFS.get(id, {}).get("flags", [])
		if flags.has(flag):
			return true
	return false


static func compatible(existing: Array[StringName], candidate: StringName) -> bool:
	if existing.has(candidate):
		return false
	for pair: Array in EXCLUSIVE_PAIRS:
		if pair.has(candidate):
			for other: StringName in pair:
				if other != candidate and existing.has(other):
					return false
	return true


## Số cấp cộng thêm cho kỹ năng khởi đầu (vd Khoẻ như trâu → Chặt cây, Đập đá, Chiến đấu).
static func skill_bonus(traits: Array[StringName], skill: StringName) -> int:
	var bonus: int = 0
	for id: StringName in traits:
		var skills: Array = DEFS.get(id, {}).get("skill_bonus", [])
		if skills.has(skill):
			bonus += 1
	return bonus
