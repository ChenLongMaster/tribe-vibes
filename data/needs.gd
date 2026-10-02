class_name NeedDefs
## 4 chỉ số của thổ dân, viết dạng dữ liệu. VillagerNeeds đọc bảng này để tăng/giảm
## theo hoạt động; UI đọc icon/màu để vẽ; chế độ chơi bật/tắt từng chỉ số qua
## GameModeConfig.enabled_needs. Thêm chỉ số mới = thêm một mục ở đây.
##
## Tốc độ (mỗi giây, + là hồi, − là giảm) theo hoạt động:
##   idle = rảnh / đi lại, work = đang làm việc, sleep = đang ngủ (hoặc ngất).
## Các luật "dính" nhau (máu theo đói, việc nặng, việc thích, lều) nằm trong VillagerNeeds.

const HEALTH: StringName = &"health"
const HUNGER: StringName = &"hunger"
const ENERGY: StringName = &"energy"
const FUN: StringName = &"fun"

## Thứ tự hiển thị trong bảng thông tin.
const ORDER: Array[StringName] = [HEALTH, HUNGER, ENERGY, FUN]

const DEFS: Dictionary[StringName, Dictionary] = {
	HEALTH: {
		"icon": "icons/stat_health",
		"name_key": "UI_NEED_HEALTH",
		"color": Color("#EF5350"),
		"alert_below": Balance.ALERT_HEALTH_BELOW,
		"idle": 0.0, "work": 0.0, "sleep": 0.0,
	},
	HUNGER: {
		"icon": "icons/hunger",
		"name_key": "UI_NEED_HUNGER",
		"color": Color("#FFB74D"),
		"alert_below": Balance.HUNGER_EAT_BELOW,
		"idle": -Balance.HUNGER_DECAY, "work": -Balance.HUNGER_DECAY, "sleep": -Balance.HUNGER_DECAY,
	},
	ENERGY: {
		"icon": "icons/stat_energy",
		"name_key": "UI_NEED_ENERGY",
		"color": Color("#64B5F6"),
		"alert_below": Balance.ENERGY_SLEEP_BELOW,
		"idle": -Balance.ENERGY_DECAY_IDLE, "work": -Balance.ENERGY_DECAY_WORK, "sleep": Balance.ENERGY_RESTORE_GROUND,
	},
	FUN: {
		"icon": "icons/stat_fun_happy",
		# Icon đổi theo mức: vui / bình thường / bực bội đỏ mặt (xem icon_for).
		"icon_levels": [[Balance.FUN_FACE_HAPPY, "icons/stat_fun_happy"], [Balance.FUN_FACE_OK, "icons/stat_fun_ok"],
				[0.0, "icons/stat_fun_angry"]],
		"name_key": "UI_NEED_FUN",
		"color": Color("#F06292"),
		"alert_below": Balance.ALERT_FUN_BELOW,
		"idle": Balance.FUN_RESTORE_IDLE, "work": -Balance.FUN_DECAY_WORK, "sleep": 0.0,
	},
}


static func icon(id: StringName) -> String:
	return DEFS[id]["icon"]


## Icon theo giá trị hiện tại (giải trí: mặt vui / bình thường / bực bội); chỉ số khác dùng một icon.
static func icon_for(id: StringName, value: float) -> String:
	for level: Array in DEFS[id].get("icon_levels", []):
		if value >= float(level[0]):
			return level[1]
	return icon(id)


static func rate(id: StringName, activity: String) -> float:
	return float(DEFS[id].get(activity, 0.0))


static func alert_below(id: StringName) -> float:
	return float(DEFS[id]["alert_below"])
