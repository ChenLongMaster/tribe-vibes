class_name JobDefs
## Các việc người chơi giao được, viết dạng dữ liệu. Một mục = một loại việc. Nhiều việc có
## thể chung một kỹ năng (nhặt củi, nhặt đá cuội, hái quả đều là Hái lượm).
## - skill: kỹ năng luyện được (SkillDefs) — icon, kinh nghiệm, việc thích đều theo kỹ năng.
## - target: loại mục tiêu (kind của ResourceNode, &"animal", hoặc &"cook_station").
## - seconds: thời gian làm một lượt ở cấp 1 (chia cho tốc độ làm việc).
## - item / amount: làm xong một lượt ra món gì, bao nhiêu (ResourceDefs.ITEMS), rồi khuân về kho.
## - batch: nhặt đủ chừng này món (từ các mục tiêu sát nhau) rồi mới khuân về một thể.
## - tool_item: đồ nghề BẮT BUỘC (ToolDefs); không có thì không làm được việc này.
## - held: hình cầm trên tay lúc làm (giỏ, xô, cần câu… — "" = tay không). Việc cần
##   đồ nghề thì cầm chính món đó. held_tilts: false = xách thõng (giỏ, xô), không xoay
##   chéo theo cánh tay như cán rìu.
## - icon: icon việc trên đầu (mặc định icon kỹ năng).
## - anim: hoạt họa lúc làm. impact: hiệu ứng mỗi nhát, "" = không có. swing: giây giữa hai nhát.
## - activity_key: chữ "đang làm gì" trong bảng thông tin.
## - search_radius: hết mục tiêu thì tìm cái tương tự trong bán kính này (ô).

const CHOP: StringName = &"chop"
const MINE: StringName = &"mine"
const GATHER: StringName = &"gather"
const TWIGS: StringName = &"twigs"
const PEBBLES: StringName = &"pebbles"
const FISH: StringName = &"fish"
const HUNT: StringName = &"hunt"
const COOK: StringName = &"cook"

const TARGET_ANIMAL: StringName = &"animal"
const TARGET_COOK_STATION: StringName = &"cook_station"

const IMPACT_WOOD: StringName = &"wood"
const IMPACT_STONE: StringName = &"stone"
## "Bụp" — làn khói nhỏ khi đồ được đặt xuống kho, con thú mới xuất hiện…
const IMPACT_POOF: StringName = &"poof"

const DEFS: Dictionary[StringName, Dictionary] = {
	CHOP: {
		"skill": SkillDefs.CHOP,
		"target": MapData.KIND_TREE,
		"seconds": Balance.CHOP_SECONDS,
		"item": ResourceDefs.ITEM_LOG,
		"amount": 1,
		"tool_item": ToolDefs.AXE,
		"anim": VillagerRig.ANIM_CHOP,
		"impact": IMPACT_WOOD,
		"swing": 0.9,
		"activity_key": "UI_ACTIVITY_CHOP",
		"search_radius": Balance.JOB_SEARCH_RADIUS_CELLS,
	},
	MINE: {
		"skill": SkillDefs.MINE,
		"target": MapData.KIND_ROCK,
		"seconds": Balance.MINE_SECONDS,
		"item": ResourceDefs.ITEM_STONE,
		"amount": Balance.STONE_PER_MINE,
		"tool_item": ToolDefs.PICKAXE,
		"anim": VillagerRig.ANIM_MINE,
		"impact": IMPACT_STONE,
		"swing": 0.8,
		"activity_key": "UI_ACTIVITY_MINE",
		"search_radius": Balance.JOB_SEARCH_RADIUS_CELLS,
	},
	GATHER: {
		"skill": SkillDefs.GATHER,
		"target": MapData.KIND_BUSH,
		"seconds": Balance.PICK_SECONDS,
		"item": ResourceDefs.ITEM_BERRIES,
		"amount": Balance.BUSH_BERRIES_PER_PICK,
		"held": "props/basket",
		"held_tilts": false,
		"anim": VillagerRig.ANIM_GATHER,
		"activity_key": "UI_ACTIVITY_GATHER",
		"search_radius": Balance.GATHER_SEARCH_RADIUS_CELLS,
	},
	TWIGS: {
		"skill": SkillDefs.GATHER,
		"target": MapData.KIND_TWIGS,
		"seconds": Balance.TWIG_PICK_SECONDS,
		"item": ResourceDefs.ITEM_TWIGS,
		"amount": 1,
		"batch": Balance.LOOSE_PICK_BATCH,
		"icon": "props/twig_bundle",
		"anim": VillagerRig.ANIM_GATHER,
		"activity_key": "UI_ACTIVITY_TWIGS",
		"search_radius": Balance.GATHER_SEARCH_RADIUS_CELLS,
	},
	PEBBLES: {
		"skill": SkillDefs.GATHER,
		"target": MapData.KIND_PEBBLES,
		"seconds": Balance.PEBBLE_PICK_SECONDS,
		"item": ResourceDefs.ITEM_PEBBLES,
		"amount": 1,
		"batch": Balance.LOOSE_PICK_BATCH,
		"held": "props/bucket",
		"held_tilts": false,
		"icon": "props/bucket",
		"anim": VillagerRig.ANIM_GATHER,
		"activity_key": "UI_ACTIVITY_PEBBLES",
		"search_radius": Balance.GATHER_SEARCH_RADIUS_CELLS,
	},
	FISH: {
		"skill": SkillDefs.FISH,
		"target": MapData.KIND_FISH_SPOT,
		"seconds": Balance.FISH_SECONDS,
		"item": ResourceDefs.ITEM_FISH,
		"amount": Balance.FISH_PER_CATCH,
		"held": "props/fishing_rod",
		"anim": VillagerRig.ANIM_FISH,
		"activity_key": "UI_ACTIVITY_FISH",
		"search_radius": Balance.JOB_SEARCH_RADIUS_CELLS,
	},
	HUNT: {
		"skill": SkillDefs.HUNT,
		"target": TARGET_ANIMAL,
		"seconds": Balance.HUNT_SECONDS,
		"item": ResourceDefs.ITEM_MEAT,
		"amount": Balance.MEAT_PER_HUNT,
		"tool_item": ToolDefs.SPEAR,
		"anim": VillagerRig.ANIM_ATTACK,
		"activity_key": "UI_ACTIVITY_HUNT",
		"search_radius": Balance.HUNT_SEARCH_RADIUS_CELLS,
	},
	COOK: {
		"skill": SkillDefs.COOK,
		"target": TARGET_COOK_STATION,
		"seconds": Balance.COOK_SECONDS_CAMPFIRE,
		"held": "icons/skill_cook",
		"anim": VillagerRig.ANIM_COOK,
		"activity_key": "UI_ACTIVITY_COOK",
		"search_radius": Balance.JOB_SEARCH_RADIUS_CELLS,
	},
}


static func has_job(job_id: StringName) -> bool:
	return DEFS.has(job_id)


static func get_def(job_id: StringName) -> Dictionary:
	return DEFS.get(job_id, {})


static func skill_of(job_id: StringName) -> StringName:
	return get_def(job_id).get("skill", &"")


## Đồ nghề bắt buộc của việc (&"" = tay không cũng làm được).
static func required_tool(job_id: StringName) -> StringName:
	return get_def(job_id).get("tool_item", &"")


## Hình cầm tay lúc làm: đồ nghề bắt buộc, hoặc giỏ/xô/cần câu, hoặc tay không.
static func held_art(job_id: StringName) -> String:
	var tool: StringName = required_tool(job_id)
	if tool != &"":
		return ToolDefs.icon(tool)
	return str(get_def(job_id).get("held", ""))


static func held_tilts(job_id: StringName) -> bool:
	return bool(get_def(job_id).get("held_tilts", true))


static func icon(job_id: StringName) -> String:
	return str(get_def(job_id).get("icon", SkillDefs.icon(skill_of(job_id))))


## Việc ứng với một mục tiêu người chơi chạm vào (&"" nếu mục tiêu đó không giao việc được).
static func job_for_target(target: Node) -> StringName:
	var target_kind: StringName = &""
	if target is ResourceNode:
		target_kind = (target as ResourceNode).kind
	elif target is Animal:
		target_kind = TARGET_ANIMAL
	elif target is Building and (target as Building).def.get("cook_station", false):
		target_kind = TARGET_COOK_STATION
	if target_kind == &"":
		return &""
	for job_id: StringName in DEFS:
		if DEFS[job_id]["target"] == target_kind:
			return job_id
	return &""
