class_name JobDefs
## Các việc người chơi giao được, viết dạng dữ liệu. Một mục = một loại việc (theo kỹ năng):
## - target: loại mục tiêu (kind của ResourceNode, &"animal", hoặc &"cook_station").
## - seconds: thời gian làm một lượt ở cấp 1 (chia cho tốc độ làm việc).
## - resource / amount: làm xong một lượt ra gì, bao nhiêu (rồi khuân về kho).
## - anim: hoạt họa lúc làm. tool: đồ nghề cầm tay (key hình, "" = tay không).
## - impact: hiệu ứng mỗi nhát (bụi gỗ / bụi đá), "" = không có. swing: giây giữa hai nhát.
## - activity_key: chữ "đang làm gì" trong bảng thông tin.
## - none_bubble: bong bóng khi quanh đó không còn gì để làm.
## - search_radius: hết mục tiêu thì tìm cái tương tự trong bán kính này (ô).

const TARGET_ANIMAL: StringName = &"animal"
const TARGET_COOK_STATION: StringName = &"cook_station"

const IMPACT_WOOD: StringName = &"wood"
const IMPACT_STONE: StringName = &"stone"
## "Bụp" — làn khói nhỏ khi con thú bị săn biến mất, hoặc đồ được đặt xuống kho.
const IMPACT_POOF: StringName = &"poof"

const DEFS: Dictionary[StringName, Dictionary] = {
	SkillDefs.CHOP: {
		"target": MapData.KIND_TREE,
		"seconds": Balance.CHOP_SECONDS,
		"resource": ResourceDefs.WOOD,
		"amount": Balance.WOOD_PER_CHOP,
		"anim": VillagerRig.ANIM_CHOP,
		"tool": "icons/skill_chop",
		"impact": IMPACT_WOOD,
		"swing": 0.9,
		"activity_key": "UI_ACTIVITY_CHOP",
		"none_bubble": "BUBBLE_NO_TREES",
		"search_radius": Balance.JOB_SEARCH_RADIUS_CELLS,
	},
	SkillDefs.MINE: {
		"target": MapData.KIND_ROCK,
		"seconds": Balance.MINE_SECONDS,
		"resource": ResourceDefs.STONE,
		"amount": Balance.STONE_PER_MINE,
		"anim": VillagerRig.ANIM_MINE,
		"tool": "icons/skill_mine",
		"impact": IMPACT_STONE,
		"swing": 0.8,
		"activity_key": "UI_ACTIVITY_MINE",
		"none_bubble": "BUBBLE_NO_ROCKS",
		"search_radius": Balance.JOB_SEARCH_RADIUS_CELLS,
	},
	SkillDefs.GATHER: {
		"target": MapData.KIND_BUSH,
		"seconds": Balance.PICK_SECONDS,
		"resource": ResourceDefs.BERRY,
		"amount": Balance.BUSH_BERRIES_PER_PICK,
		"anim": VillagerRig.ANIM_GATHER,
		"tool": "",
		"impact": &"",
		"swing": 0.0,
		"activity_key": "UI_ACTIVITY_GATHER",
		"none_bubble": "BUBBLE_NO_BERRIES",
		"search_radius": Balance.GATHER_SEARCH_RADIUS_CELLS,
	},
	SkillDefs.FISH: {
		"target": MapData.KIND_FISH_SPOT,
		"seconds": Balance.FISH_SECONDS,
		"resource": ResourceDefs.RAW_FISH,
		"amount": Balance.FISH_PER_CATCH,
		"anim": VillagerRig.ANIM_FISH,
		"tool": "icons/skill_fish",
		"impact": &"",
		"swing": 0.0,
		"activity_key": "UI_ACTIVITY_FISH",
		"none_bubble": "BUBBLE_NO_FISH",
		"search_radius": Balance.JOB_SEARCH_RADIUS_CELLS,
	},
	SkillDefs.HUNT: {
		"target": TARGET_ANIMAL,
		"seconds": Balance.HUNT_SECONDS,
		"resource": ResourceDefs.RAW_MEAT,
		"amount": Balance.MEAT_PER_HUNT,
		"anim": VillagerRig.ANIM_ATTACK,
		"tool": "icons/skill_hunt",
		"impact": &"",
		"swing": 0.0,
		"activity_key": "UI_ACTIVITY_HUNT",
		"none_bubble": "BUBBLE_NO_ANIMALS",
		"search_radius": Balance.HUNT_SEARCH_RADIUS_CELLS,
	},
	SkillDefs.COOK: {
		"target": TARGET_COOK_STATION,
		"seconds": Balance.COOK_SECONDS_CAMPFIRE,
		"resource": ResourceDefs.COOKED_MEAL,
		"amount": 1,
		"anim": VillagerRig.ANIM_COOK,
		"tool": "icons/skill_cook",
		"impact": &"",
		"swing": 0.0,
		"activity_key": "UI_ACTIVITY_COOK",
		"none_bubble": "BUBBLE_NOTHING_TO_COOK",
		"search_radius": Balance.JOB_SEARCH_RADIUS_CELLS,
	},
}


static func has_job(skill: StringName) -> bool:
	return DEFS.has(skill)


static func get_def(skill: StringName) -> Dictionary:
	return DEFS.get(skill, {})


## Việc ứng với một mục tiêu người chơi chạm vào (&"" nếu mục tiêu đó không giao việc được).
static func skill_for_target(target: Node) -> StringName:
	var target_kind: StringName = &""
	if target is ResourceNode:
		target_kind = (target as ResourceNode).kind
	elif target is Animal:
		target_kind = TARGET_ANIMAL
	elif target is Building and (target as Building).def.get("cook_station", false):
		target_kind = TARGET_COOK_STATION
	if target_kind == &"":
		return &""
	for skill: StringName in DEFS:
		if DEFS[skill]["target"] == target_kind:
			return skill
	return &""
