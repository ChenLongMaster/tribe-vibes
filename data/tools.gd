class_name ToolDefs
## Đồ nghề rèn ở lò rèn (Đợt 3): rìu, cuốc, giáo. Đồ nghề cất ở công trình (Building.stock);
## thổ dân được giao việc cần đồ nghề thì tự tới lấy, rồi GIỮ LUÔN (đeo sau lưng khi làm
## việc khác) cho tới khi được giao việc cần món khác — lúc đó tới chỗ cất đổi món.
## Chưa có món cần thiết thì không làm được việc đó (chỉ nhặt bằng tay: củi, đá cuội…).
## - icon: hình cầm tay / đeo sau lưng / vẽ trên tấm biển "thiếu đồ nghề".

const AXE: StringName = &"axe"
const PICKAXE: StringName = &"pickaxe"
const SPEAR: StringName = &"spear"

const ORDER: Array[StringName] = [AXE, PICKAXE, SPEAR]

const DEFS: Dictionary[StringName, Dictionary] = {
	AXE: {"icon": "icons/skill_chop"},
	PICKAXE: {"icon": "icons/skill_mine"},
	SPEAR: {"icon": "icons/skill_hunt"},
}


static func icon(id: StringName) -> String:
	return DEFS.get(id, {}).get("icon", "")
