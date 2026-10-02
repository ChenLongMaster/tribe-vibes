class_name ResourceDefs
## Các loại tài nguyên trong kho chung (GameState). Thêm tài nguyên mới = thêm một mục ở đây
## + key dịch RES_<ID>_NAME, RES_<ID>_NOUN, RES_<ID>_COUNT_ONE/_OTHER trong i18n/strings.csv.
## - category: MATERIAL khuân về kho vật liệu (cờ `material_storage` của công trình),
##   FOOD khuân về chỗ cất đồ ăn (cờ `food_storage`).

enum Category { MATERIAL, FOOD }

const WOOD: StringName = &"wood"
const STONE: StringName = &"stone"
const BERRY: StringName = &"berry"
const RAW_MEAT: StringName = &"raw_meat"
const RAW_FISH: StringName = &"raw_fish"
const COOKED_MEAL: StringName = &"cooked_meal"

## Thứ tự hiển thị trên thanh tài nguyên.
const ORDER: Array[StringName] = [WOOD, STONE, BERRY, RAW_MEAT, RAW_FISH, COOKED_MEAL]
## Đồ sống nấu được ở lửa trại/bếp, nấu cái nào trước.
const COOKABLE: Array[StringName] = [RAW_MEAT, RAW_FISH]

const DEFS: Dictionary[StringName, Dictionary] = {
	WOOD: {"icon": "icons/res_wood", "category": Category.MATERIAL},
	STONE: {"icon": "icons/res_stone", "category": Category.MATERIAL},
	BERRY: {"icon": "icons/berry", "category": Category.FOOD},
	RAW_MEAT: {"icon": "icons/res_meat", "category": Category.FOOD},
	RAW_FISH: {"icon": "icons/res_fish", "category": Category.FOOD},
	COOKED_MEAL: {"icon": "icons/res_meal", "category": Category.FOOD},
}


static func icon(id: StringName) -> String:
	return DEFS.get(id, {}).get("icon", "")


## Tên viết hoa đứng một mình (tooltip trên HUD).
static func name_key(id: StringName) -> String:
	return "RES_%s_NAME" % String(id).to_upper()


## Tên viết thường để ghép vào câu ("khuân {resource} về kho").
static func noun_key(id: StringName) -> String:
	return "RES_%s_NOUN" % String(id).to_upper()


## Gốc key số nhiều, dùng với Loc.plural(): "RES_WOOD_COUNT" → "{n} gỗ".
static func count_key(id: StringName) -> String:
	return "RES_%s_COUNT" % String(id).to_upper()


static func is_food(id: StringName) -> bool:
	return DEFS.get(id, {}).get("category", Category.MATERIAL) == Category.FOOD


## Cờ trong data/buildings.gd đánh dấu công trình nhận cất loại tài nguyên này.
static func storage_flag(id: StringName) -> String:
	return "food_storage" if is_food(id) else "material_storage"
