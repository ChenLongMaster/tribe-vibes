class_name ToolDefs
## Đồ nghề rèn ở lò rèn (Đợt 3): rìu, cuốc, giáo. Đồ nghề cất ở công trình (Building.stock);
## thổ dân được giao việc cần đồ nghề thì tự tới lấy, rồi GIỮ LUÔN (đeo sau lưng khi làm
## việc khác) cho tới khi được giao việc cần món khác — lúc đó tới chỗ cất đổi món.
## Chưa có món cần thiết thì không làm được việc đó (chỉ nhặt bằng tay: củi, đá cuội…).
## - icon: hình cầm tay / đeo sau lưng / vẽ trên tấm biển "thiếu đồ nghề".
## - cost: vật liệu thợ rèn lấy từ kho chung để rèn một món. name_key: tên trong bảng lò rèn.

const AXE: StringName = &"axe"
const PICKAXE: StringName = &"pickaxe"
const SPEAR: StringName = &"spear"

const ORDER: Array[StringName] = [AXE, PICKAXE, SPEAR]

const DEFS: Dictionary[StringName, Dictionary] = {
	AXE: {"icon": "icons/skill_chop", "name_key": "TOOL_AXE_NAME",
			"cost": {ResourceDefs.WOOD: 4, ResourceDefs.STONE: 2}},
	PICKAXE: {"icon": "icons/skill_mine", "name_key": "TOOL_PICKAXE_NAME",
			"cost": {ResourceDefs.WOOD: 3, ResourceDefs.STONE: 4}},
	SPEAR: {"icon": "icons/skill_hunt", "name_key": "TOOL_SPEAR_NAME",
			"cost": {ResourceDefs.WOOD: 5, ResourceDefs.STONE: 1}},
}


static func icon(id: StringName) -> String:
	return DEFS.get(id, {}).get("icon", "")


static func cost(id: StringName) -> Dictionary:
	return DEFS.get(id, {}).get("cost", {})


static func name_key(id: StringName) -> String:
	return str(DEFS.get(id, {}).get("name_key", ""))
