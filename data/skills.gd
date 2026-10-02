class_name SkillDefs
## Các loại việc / kỹ năng. Mỗi thổ dân có cấp 1–5 cho từng loại (VillagerData.skills)
## và đúng một việc thích (VillagerData.favorite_job). Key dịch tên việc: JOB_<ID>.
## - heavy: việc nặng làm đói nhanh hơn (Balance.HEAVY_WORK_HUNGER_MULT).

const CHOP: StringName = &"CHOP"
const MINE: StringName = &"MINE"
const GATHER: StringName = &"GATHER"
const HUNT: StringName = &"HUNT"
const FISH: StringName = &"FISH"
const COOK: StringName = &"COOK"
const BUILD: StringName = &"BUILD"
const SMITH: StringName = &"SMITH"
const FIGHT: StringName = &"FIGHT"

## Thứ tự hiển thị trong bảng thông tin.
const ORDER: Array[StringName] = [CHOP, MINE, GATHER, HUNT, FISH, COOK, BUILD, SMITH, FIGHT]

const DEFS: Dictionary[StringName, Dictionary] = {
	CHOP: {"icon": "icons/skill_chop", "heavy": true},
	MINE: {"icon": "icons/skill_mine", "heavy": true},
	GATHER: {"icon": "icons/skill_gather", "heavy": false},
	HUNT: {"icon": "icons/skill_hunt", "heavy": true},
	FISH: {"icon": "icons/skill_fish", "heavy": false},
	COOK: {"icon": "icons/skill_cook", "heavy": false},
	BUILD: {"icon": "icons/skill_build", "heavy": true},
	SMITH: {"icon": "icons/skill_smith", "heavy": true},
	FIGHT: {"icon": "icons/skill_fight", "heavy": true},
}


static func icon(id: StringName) -> String:
	return DEFS.get(id, {}).get("icon", "")


static func is_heavy(id: StringName) -> bool:
	return bool(DEFS.get(id, {}).get("heavy", false))


static func name_key(id: StringName) -> String:
	return "JOB_%s" % id


## Hệ số tốc độ theo cấp: cấp 1 = ×1, mỗi cấp thêm SKILL_SPEED_PER_LEVEL.
static func speed_for_level(level: int) -> float:
	return 1.0 + (level - Balance.SKILL_MIN_LEVEL) * Balance.SKILL_SPEED_PER_LEVEL
