class_name SkillDefs
## Các loại việc / kỹ năng. Mỗi thổ dân có cấp 1–5 cho từng loại (VillagerData.skills)
## và đúng một việc thích (VillagerData.favorite_job). Key dịch tên việc: JOB_<ID>.
## - heavy: việc nặng làm đói nhanh hơn (Balance.HEAVY_WORK_HUNGER_MULT).
## Săn bắn và chiến đấu là MỘT kỹ năng (FIGHT): đi săn luyện nó, chiến đấu giỏi thì đâm/chém
## lẫn ném giáo đều đau hơn (Đợt 5). Save cũ có kỹ năng "HUNT" được đổi sang FIGHT (from_saved_id).

const CHOP: StringName = &"CHOP"
const MINE: StringName = &"MINE"
const GATHER: StringName = &"GATHER"
const FISH: StringName = &"FISH"
const COOK: StringName = &"COOK"
const BUILD: StringName = &"BUILD"
const SMITH: StringName = &"SMITH"
const FIGHT: StringName = &"FIGHT"

## Thứ tự hiển thị trong bảng thông tin.
const ORDER: Array[StringName] = [CHOP, MINE, GATHER, FIGHT, FISH, COOK, BUILD, SMITH]
## Id kỹ năng cũ đã gộp vào kỹ năng khác (đọc save cũ).
const MERGED: Dictionary[StringName, StringName] = {&"HUNT": FIGHT}

const DEFS: Dictionary[StringName, Dictionary] = {
	CHOP: {"icon": "icons/skill_chop", "heavy": true},
	MINE: {"icon": "icons/skill_mine", "heavy": true},
	GATHER: {"icon": "icons/skill_gather", "heavy": false},
	FISH: {"icon": "icons/skill_fish", "heavy": false},
	COOK: {"icon": "icons/skill_cook", "heavy": false},
	BUILD: {"icon": "icons/skill_build", "heavy": true},
	SMITH: {"icon": "icons/skill_smith", "heavy": true},
	FIGHT: {"icon": "icons/skill_hunt", "heavy": true},
}


## Id kỹ năng đọc từ save (đổi id cũ đã gộp sang id mới).
static func from_saved_id(id: String) -> StringName:
	return MERGED.get(StringName(id), StringName(id))


static func icon(id: StringName) -> String:
	return DEFS.get(id, {}).get("icon", "")


static func is_heavy(id: StringName) -> bool:
	return bool(DEFS.get(id, {}).get("heavy", false))


static func name_key(id: StringName) -> String:
	return "JOB_%s" % id


## Hệ số tốc độ theo cấp: cấp 1 = ×1, mỗi cấp thêm SKILL_SPEED_PER_LEVEL.
static func speed_for_level(level: int) -> float:
	return 1.0 + (level - Balance.SKILL_MIN_LEVEL) * Balance.SKILL_SPEED_PER_LEVEL
