class_name BuildingDefs
## Định nghĩa công trình bằng dữ liệu. Thêm công trình mới = thêm một mục ở đây,
## scene `buildings/building.tscn` tự đọc và dựng theo.
##
## Thuộc tính chung (đọc thẳng trong mục):
## - footprint: số ô chiếm (rộng, cao); ô gốc là ô trên-trái.
## - art: key hình (công trình dựng sẵn, chỉ một cấp).
## - extra_art_frames: các khung hình phụ vẽ chồng lên và chạy lần lượt (vd ngọn lửa),
##   kèm extra_art_fps, extra_art_offset (lệch so với gốc), extra_art_sways (nghiêng theo gió).
## - fx_scene: scene hiệu ứng gắn kèm (vd tàn lửa), đặt lệch fx_offset so với gốc.
## - glow: ánh lửa ban đêm {offset, radius (px), color} — vẽ cộng sáng, không dùng Light2D.
## - buildable: người chơi có xây được từ menu không. desc_key: một dòng giải thích trong menu.
## - walkable: đi lên được (sân nhảy) — chiếm chỗ nhưng không chặn đường.
## - action: chọn thổ dân rồi chạm vào công trình đã xong thì làm gì:
##   &"sleep" (đi ngủ), &"dance" (lên sân chơi), còn lại thì đi tới đứng cạnh.
## - staff_job: việc của người phụ trách (JobDefs: &"cook", &"smith"). production: true =
##   công trình sản xuất — không ai phụ trách thì ngừng và hiện icon cảnh báo.
## - food_storage / material_storage: nơi cất thức ăn thô / gỗ, đá (kho chung của làng).
## - cook_station: giao người vào đây để nấu thức ăn thô thành món chín.
## - stock_display: vẽ đồ riêng quanh công trình, mỗi món một chỗ: {món: {art, slots: [lệch]}}
##   — nhìn là biết còn bao nhiêu (nhiều hơn số chỗ thì chỉ vẽ đủ chỗ).
##
## Công trình xây được có "levels": mỗi cấp một mục, ghi đè thuộc tính chung ở cấp đó:
## - art, cost ({tài nguyên: số} — thợ xây khuân từ kho tới), build_seconds (một thợ cấp 1 xây
##   một mình mất chừng này giây), staff (số người phụ trách tối đa), capacity (sức chứa kho
##   chung {tài nguyên: số}), stock_capacity (sức chứa đồ riêng {món: số}), sleep_slots,
##   sleep_rate, cook_seconds, dancers.
## Đọc thuộc tính theo cấp hiện tại qua Building.prop().

const CLIFF: StringName = &"cliff"
const CAVE: StringName = &"cave"
const CAMPFIRE: StringName = &"campfire"
const TENT: StringName = &"tent"
const KITCHEN: StringName = &"kitchen"
const STORAGE: StringName = &"storage"
const FORGE: StringName = &"forge"
const DANCE_FLOOR: StringName = &"dance_floor"

## Thứ tự trong menu xây.
const MENU_ORDER: Array[StringName] = [TENT, KITCHEN, STORAGE, FORGE, DANCE_FLOOR]

const ACTION_SLEEP: StringName = &"sleep"
const ACTION_DANCE: StringName = &"dance"

const MEAL_SLOTS_KITCHEN: Array[Vector2] = [
	Vector2(-52, 2), Vector2(52, 2), Vector2(-34, 14), Vector2(34, 14), Vector2(-14, 20), Vector2(14, 20),
]

const DEFS: Dictionary[StringName, Dictionary] = {
	# Vách đá lớn: một phần của map, không khai thác được; thỉnh thoảng lăn ra đá tảng.
	CLIFF: {
		"name_key": "BUILDING_CLIFF_NAME",
		"footprint": Vector2i(3, 2),
		"art": "env/cliff",
		"buildable": false,
		"selectable": false,
	},
	# Hang đá: kho tạm lúc đầu — cất gỗ, đá, thức ăn thô nhưng ít thôi. Muốn cất nhiều thì
	# xây Kho (gỗ, đá) và Bếp (thức ăn).
	CAVE: {
		"name_key": "BUILDING_CAVE_NAME",
		"desc_key": "BUILDING_CAVE_DESC",
		"footprint": Vector2i(3, 2),
		"art": "buildings/cave",
		"buildable": false,
		"food_storage": true,
		"material_storage": true,
		"capacity": {
			ResourceDefs.WOOD: Balance.CAVE_WOOD_CAPACITY,
			ResourceDefs.STONE: Balance.CAVE_STONE_CAPACITY,
			ResourceDefs.FOOD: Balance.CAVE_FOOD_CAPACITY,
		},
	},
	# Lửa trại: bếp tạm — chỉ cất ít món chín, nấu chậm, một người nấu.
	CAMPFIRE: {
		"name_key": "BUILDING_CAMPFIRE_NAME",
		"desc_key": "BUILDING_CAMPFIRE_DESC",
		"footprint": Vector2i(1, 1),
		"art": "buildings/campfire",
		"extra_art_frames": [
			"buildings/campfire_flame_01", "buildings/campfire_flame_02",
			"buildings/campfire_flame_03", "buildings/campfire_flame_04",
		],
		"extra_art_fps": 8.0,
		"extra_art_offset": Vector2(0, -12),
		"extra_art_sways": true,
		"glow": {"offset": Vector2(0, -24), "radius": 230.0, "color": Color(1.0, 0.62, 0.25, 0.55)},
		"cook_station": true,
		"cook_seconds": Balance.COOK_SECONDS_CAMPFIRE,
		"staff_job": &"cook",
		"staff": Balance.CAMPFIRE_COOKS,
		"stock_capacity": {ResourceDefs.MEAL: Balance.CAMPFIRE_MEAL_CAPACITY},
		"stock_display": {
			ResourceDefs.MEAL: {
				"art": "icons/res_meal",
				"slots": [Vector2(-30, 4), Vector2(30, 4), Vector2(-20, 16), Vector2(20, 16)],
			},
		},
		"fx_scene": "res://fx/campfire_embers.tscn",
		"fx_offset": Vector2(0, -38),
		"buildable": false,
	},
	TENT: {
		"name_key": "BUILDING_TENT_NAME",
		"desc_key": "BUILDING_TENT_DESC",
		"footprint": Vector2i(2, 2),
		"buildable": true,
		"action": ACTION_SLEEP,
		"levels": [
			{"art": "buildings/tent_1", "cost": {ResourceDefs.WOOD: 20}, "build_seconds": 20.0,
					"sleep_slots": 2, "sleep_rate": 1.5},
			{"art": "buildings/tent_2", "cost": {ResourceDefs.WOOD: 40, ResourceDefs.STONE: 15}, "build_seconds": 30.0,
					"sleep_slots": 3, "sleep_rate": 2.0},
			{"art": "buildings/tent_3", "cost": {ResourceDefs.WOOD: 60, ResourceDefs.STONE: 40}, "build_seconds": 45.0,
					"sleep_slots": 4, "sleep_rate": 2.5},
		],
	},
	KITCHEN: {
		"name_key": "BUILDING_KITCHEN_NAME",
		"desc_key": "BUILDING_KITCHEN_DESC",
		"footprint": Vector2i(2, 2),
		"buildable": true,
		"production": true,
		"staff_job": &"cook",
		"cook_station": true,
		"food_storage": true,
		"glow": {"offset": Vector2(0, -40), "radius": 180.0, "color": Color(1.0, 0.6, 0.25, 0.4)},
		"cook_seconds": Balance.COOK_SECONDS_KITCHEN,
		"stock_display": {ResourceDefs.MEAL: {"art": "icons/res_meal", "slots": MEAL_SLOTS_KITCHEN}},
		"levels": [
			{"art": "buildings/kitchen_1", "cost": {ResourceDefs.WOOD: 25, ResourceDefs.STONE: 10}, "build_seconds": 25.0,
					"staff": 1, "stock_capacity": {ResourceDefs.MEAL: 6}, "capacity": {ResourceDefs.FOOD: 30}},
			{"art": "buildings/kitchen_2", "cost": {ResourceDefs.WOOD: 40, ResourceDefs.STONE: 25}, "build_seconds": 35.0,
					"staff": 2, "stock_capacity": {ResourceDefs.MEAL: 10}, "capacity": {ResourceDefs.FOOD: 60}},
			{"art": "buildings/kitchen_3", "cost": {ResourceDefs.WOOD: 60, ResourceDefs.STONE: 50}, "build_seconds": 50.0,
					"staff": 3, "stock_capacity": {ResourceDefs.MEAL: 16}, "capacity": {ResourceDefs.FOOD: 120}},
		],
	},
	STORAGE: {
		"name_key": "BUILDING_STORAGE_NAME",
		"desc_key": "BUILDING_STORAGE_DESC",
		"footprint": Vector2i(3, 3),
		"buildable": true,
		"material_storage": true,
		"levels": [
			{"art": "buildings/storage_1", "cost": {ResourceDefs.WOOD: 30, ResourceDefs.STONE: 10}, "build_seconds": 30.0,
					"capacity": {ResourceDefs.WOOD: 100, ResourceDefs.STONE: 100}},
			{"art": "buildings/storage_2", "cost": {ResourceDefs.WOOD: 60, ResourceDefs.STONE: 30}, "build_seconds": 45.0,
					"capacity": {ResourceDefs.WOOD: 200, ResourceDefs.STONE: 200}},
			{"art": "buildings/storage_3", "cost": {ResourceDefs.WOOD: 120, ResourceDefs.STONE: 60}, "build_seconds": 60.0,
					"capacity": {ResourceDefs.WOOD: 400, ResourceDefs.STONE: 400}},
		],
	},
	FORGE: {
		"name_key": "BUILDING_FORGE_NAME",
		"desc_key": "BUILDING_FORGE_DESC",
		"footprint": Vector2i(3, 2),
		"buildable": true,
		"production": true,
		"staff_job": &"smith",
		"forge": true,
		"glow": {"offset": Vector2(-36, -40), "radius": 170.0, "color": Color(1.0, 0.5, 0.2, 0.45)},
		"stock_display": {
			ToolDefs.AXE: {"art": "icons/skill_chop", "slots": [
				Vector2(-88, -6), Vector2(-76, 2), Vector2(-64, 10), Vector2(-100, 2), Vector2(-88, 12), Vector2(-76, 18)]},
			ToolDefs.PICKAXE: {"art": "icons/skill_mine", "slots": [
				Vector2(-30, 12), Vector2(-14, 16), Vector2(2, 12), Vector2(-22, 22), Vector2(-6, 24), Vector2(10, 22)]},
			ToolDefs.SPEAR: {"art": "icons/skill_hunt", "slots": [
				Vector2(52, 4), Vector2(64, 10), Vector2(76, 4), Vector2(88, 10), Vector2(100, 4), Vector2(58, 18)]},
		},
		"levels": [
			{"art": "buildings/forge_1", "cost": {ResourceDefs.WOOD: 15, ResourceDefs.STONE: 10}, "build_seconds": 25.0,
					"staff": 1, "stock_capacity": {ToolDefs.AXE: 2, ToolDefs.PICKAXE: 2, ToolDefs.SPEAR: 2}},
			{"art": "buildings/forge_2", "cost": {ResourceDefs.WOOD: 40, ResourceDefs.STONE: 30}, "build_seconds": 40.0,
					"staff": 2, "stock_capacity": {ToolDefs.AXE: 4, ToolDefs.PICKAXE: 4, ToolDefs.SPEAR: 4}},
			{"art": "buildings/forge_3", "cost": {ResourceDefs.WOOD: 70, ResourceDefs.STONE: 60}, "build_seconds": 55.0,
					"staff": 3, "stock_capacity": {ToolDefs.AXE: 6, ToolDefs.PICKAXE: 6, ToolDefs.SPEAR: 6}},
		],
	},
	DANCE_FLOOR: {
		"name_key": "BUILDING_DANCE_FLOOR_NAME",
		"desc_key": "BUILDING_DANCE_FLOOR_DESC",
		"footprint": Vector2i(3, 3),
		"buildable": true,
		"walkable": true,
		"action": ACTION_DANCE,
		"levels": [
			{"art": "buildings/dance_floor_1", "cost": {ResourceDefs.WOOD: 20, ResourceDefs.STONE: 10}, "build_seconds": 20.0,
					"dancers": 4},
			{"art": "buildings/dance_floor_2", "cost": {ResourceDefs.WOOD: 40, ResourceDefs.STONE: 25}, "build_seconds": 30.0,
					"dancers": 6},
			{"art": "buildings/dance_floor_3", "cost": {ResourceDefs.WOOD: 60, ResourceDefs.STONE: 45}, "build_seconds": 45.0,
					"dancers": 8},
		],
	},
}


static func get_def(id: StringName) -> Dictionary:
	if not DEFS.has(id):
		push_error("BuildingDefs: không có công trình '%s'" % id)
		return {}
	return DEFS[id]


static func footprint(id: StringName) -> Vector2i:
	return get_def(id).get("footprint", Vector2i.ONE)


## Các ô công trình chiếm khi đặt ô gốc (trên-trái) tại `origin`.
static func footprint_cells(id: StringName, origin: Vector2i) -> Array[Vector2i]:
	var size: Vector2i = footprint(id)
	var cells: Array[Vector2i] = []
	for y: int in size.y:
		for x: int in size.x:
			cells.append(origin + Vector2i(x, y))
	return cells


static func is_buildable(id: StringName) -> bool:
	return DEFS.has(id) and bool(DEFS[id].get("buildable", false))


## Số cấp tối đa (công trình dựng sẵn chỉ có một cấp).
static func max_level(id: StringName) -> int:
	return maxi(1, (get_def(id).get("levels", []) as Array).size())


## Các thuộc tính riêng của một cấp ({} nếu công trình không chia cấp).
static func level_def(id: StringName, level: int) -> Dictionary:
	var levels: Array = get_def(id).get("levels", [])
	if level < 1 or level > levels.size():
		return {}
	return levels[level - 1]


## Vật liệu để xây (cấp 1) hoặc nâng lên `level`: {tài nguyên: số}.
static func cost(id: StringName, level: int) -> Dictionary:
	return level_def(id, level).get("cost", {})


static func build_seconds(id: StringName, level: int) -> float:
	return float(level_def(id, level).get("build_seconds", 20.0))


static func art(id: StringName, level: int) -> String:
	return str(level_def(id, level).get("art", get_def(id).get("art", "")))


## Hình móng theo diện tích (vd "buildings/foundation_3x2").
static func foundation_art(id: StringName) -> String:
	var size: Vector2i = footprint(id)
	return "buildings/foundation_%dx%d" % [size.x, size.y]


## Thợ xây tối đa cùng lúc: max(1, số ô ÷ 2).
static func max_builders(id: StringName) -> int:
	var size: Vector2i = footprint(id)
	return maxi(1, floori(size.x * size.y / 2.0))


static func name_key(id: StringName) -> String:
	return str(get_def(id).get("name_key", ""))


static func desc_key(id: StringName) -> String:
	return str(get_def(id).get("desc_key", ""))
