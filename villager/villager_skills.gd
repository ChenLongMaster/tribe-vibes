class_name VillagerSkills
## Lên cấp kỹ năng: làm việc nào thì tích kinh nghiệm việc đó (tính bằng giây làm thật),
## việc thích nhận ×FAVORITE_XP_MULT. Đủ SKILL_XP_TO_NEXT thì lên cấp (tối đa 5).
## Cấp khởi đầu nằm trong VillagerData.skills (bản thiết kế); cấp hiện tại và kinh nghiệm
## nằm trong VillagerStatus (thay đổi lúc chơi, được lưu game).


## Kinh nghiệm cần để lên từ `level` lên cấp kế tiếp (INF nếu đã tối đa).
static func xp_to_next(level: int) -> float:
	var index: int = level - Balance.SKILL_MIN_LEVEL
	if level >= Balance.SKILL_MAX_LEVEL or index < 0 or index >= Balance.SKILL_XP_TO_NEXT.size():
		return INF
	return Balance.SKILL_XP_TO_NEXT[index]


## Phần tính toán thuần (test gọi thẳng được). Trả về cấp mới nếu vừa lên cấp, 0 nếu chưa.
static func gain(status: VillagerStatus, data: VillagerData, skill: StringName, seconds: float) -> int:
	if skill == &"":
		return 0
	var level: int = status.skill_level(skill, data)
	var needed: float = xp_to_next(level)
	if needed == INF:
		return 0
	var mult: float = Balance.FAVORITE_XP_MULT if data.is_favorite(skill) else 1.0
	var xp: float = status.skill_xp.get(skill, 0.0) + seconds * mult
	if xp < needed:
		status.skill_xp[skill] = xp
		return 0
	status.skill_xp[skill] = xp - needed
	status.skill_levels[skill] = level + 1
	return level + 1


static func add_work(villager: Villager, skill: StringName, seconds: float) -> void:
	var new_level: int = gain(villager.status, villager.data, skill, seconds)
	if new_level > 0:
		villager.on_skill_level_up(skill, new_level)
