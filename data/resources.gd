class_name ResourceDefs
## Tài nguyên CHUNG của làng — chỉ 3 thứ người chơi phải để ý (thanh tài nguyên trên HUD):
## gỗ, đá, thức ăn. Thêm tài nguyên mới = thêm một mục ở đây + key dịch RES_<ID>_NAME,
## RES_<ID>_NOUN, RES_<ID>_COUNT_ONE/_OTHER trong i18n/strings.csv.
## - category: MATERIAL khuân về kho vật liệu (cờ `material_storage` của công trình),
##   FOOD khuân về chỗ cất đồ ăn (cờ `food_storage`).
##
## Bên trong, thứ thổ dân thật sự khuân về là MÓN (ITEMS): giỏ quả, con cá, xác thú, khúc
## gỗ, bó củi, xô đá cuội… — để vẽ cho đúng. Tới kho thì quy ra tài nguyên chung. Thức ăn
## còn nhớ trong kho có bao nhiêu phần là quả/cá/thịt (GameState theo dõi) để lúc ăn cầm
## đúng món trên tay.
##
## Đồ riêng của từng công trình (món chín ở bếp, vũ khí ở lò rèn) KHÔNG phải tài nguyên
## chung — nằm trong Building.stock, xem STOCK_ITEMS.

enum Category { MATERIAL, FOOD }

const WOOD: StringName = &"wood"
const STONE: StringName = &"stone"
const FOOD: StringName = &"food"

## Thứ tự hiển thị trên thanh tài nguyên.
const ORDER: Array[StringName] = [WOOD, STONE, FOOD]

const DEFS: Dictionary[StringName, Dictionary] = {
	WOOD: {"icon": "icons/res_wood", "category": Category.MATERIAL},
	STONE: {"icon": "icons/res_stone", "category": Category.MATERIAL},
	FOOD: {"icon": "icons/res_food", "category": Category.FOOD},
}

# --- Món khuân về ---

const ITEM_BERRIES: StringName = &"berries"
const ITEM_FISH: StringName = &"fish"
const ITEM_MEAT: StringName = &"meat"
const ITEM_LOG: StringName = &"log"
const ITEM_TWIGS: StringName = &"twigs"
const ITEM_STONE: StringName = &"stone_chunk"
const ITEM_PEBBLES: StringName = &"pebbles"

## - resource / value: quy ra tài nguyên chung nào, mỗi món bằng bao nhiêu đơn vị.
## - carry: hình giơ trên đầu khi khuân. eat: hình cầm trên tay lúc ăn (chỉ đồ ăn).
## - noun_key: tên trong câu "khuân {resource} về kho".
const ITEMS: Dictionary[StringName, Dictionary] = {
	ITEM_BERRIES: {"resource": FOOD, "value": 1, "carry": "props/basket_berries", "eat": "icons/berry",
			"noun_key": "RES_ITEM_BERRIES_NOUN"},
	ITEM_FISH: {"resource": FOOD, "value": 1, "carry": "icons/res_fish", "eat": "icons/res_fish",
			"noun_key": "RES_ITEM_FISH_NOUN"},
	ITEM_MEAT: {"resource": FOOD, "value": 1, "carry": "icons/res_meat", "eat": "icons/res_meat",
			"noun_key": "RES_ITEM_MEAT_NOUN"},
	ITEM_LOG: {"resource": WOOD, "value": Balance.WOOD_PER_LOG, "carry": "props/log",
			"noun_key": "RES_ITEM_LOG_NOUN"},
	ITEM_TWIGS: {"resource": WOOD, "value": 1, "carry": "props/twig_bundle",
			"noun_key": "RES_ITEM_TWIGS_NOUN"},
	ITEM_STONE: {"resource": STONE, "value": 1, "carry": "icons/res_stone",
			"noun_key": "RES_ITEM_STONE_NOUN"},
	ITEM_PEBBLES: {"resource": STONE, "value": 1, "carry": "props/bucket_pebbles",
			"noun_key": "RES_ITEM_PEBBLES_NOUN"},
}

# --- Đồ riêng của công trình ---

## Món chín: đầu bếp nấu từ thức ăn thô, cất ngay ở bếp (lửa trại), tối đa theo sức chứa
## của bếp (`meal_capacity` trong data/buildings.gd).
const MEAL: StringName = &"meal"

const STOCK_ITEMS: Dictionary[StringName, Dictionary] = {
	MEAL: {"icon": "icons/res_meal"},
}


static func icon(id: StringName) -> String:
	if DEFS.has(id):
		return DEFS[id].get("icon", "")
	return STOCK_ITEMS.get(id, {}).get("icon", "")


## Tên viết hoa đứng một mình (tooltip trên HUD).
static func name_key(id: StringName) -> String:
	return "RES_%s_NAME" % String(id).to_upper()


## Tên viết thường để ghép vào câu.
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


static func item_resource(item: StringName) -> StringName:
	return ITEMS[item]["resource"]


## Số đơn vị tài nguyên chung của `count` món (vd 1 khúc gỗ = 10 gỗ).
static func item_value(item: StringName, count: int) -> int:
	return int(ITEMS[item]["value"]) * count


static func item_carry_art(item: StringName) -> String:
	return ITEMS.get(item, {}).get("carry", "")


## Hình cầm trên tay khi ăn một phần thức ăn thuộc món này (mặc định đùi thịt).
static func item_eat_art(item: StringName) -> String:
	return ITEMS.get(item, {}).get("eat", DEFS[FOOD]["icon"])


static func item_noun_key(item: StringName) -> String:
	return ITEMS.get(item, {}).get("noun_key", "")
