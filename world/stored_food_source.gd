class_name StoredFoodSource
extends FoodSource
## Đồ ăn đã cất trong kho chung (GameState), lấy ở một công trình có cờ `food_storage`:
## hiện là lửa trại ("bếp tạm"); Đợt 3 Bếp cũng dùng lớp này. Đồ trong kho do người hái
## quả, thợ săn, thợ câu, đầu bếp mang về (Đợt 2).

const PRIORITY: int = 0
## Ăn món nào trước: món chín rồi mới tới quả. Thịt/cá sống không ăn được (phải nấu).
const FOOD_ORDER: Array[StringName] = [ResourceDefs.COOKED_MEAL, ResourceDefs.BERRY]
const FOOD_VALUES: Dictionary[StringName, float] = {
	ResourceDefs.COOKED_MEAL: Balance.COOKED_MEAL_HUNGER,
	ResourceDefs.BERRY: Balance.BERRY_HUNGER,
}
## Món chín ngon nên vui thêm.
const FOOD_FUN: Dictionary[StringName, float] = {
	ResourceDefs.COOKED_MEAL: Balance.FUN_COOKED_MEAL,
}


func _init(building: Building) -> void:
	target = building
	target_cell = building.origin_cell


func is_available(_villager: Villager) -> bool:
	return _first_food() != &""


func take() -> float:
	var food: StringName = _first_food()
	if food == &"" or not GameState.take_resource(food):
		return 0.0
	taken_icon = ResourceDefs.icon(food)
	taken_fun = FOOD_FUN.get(food, 0.0)
	return FOOD_VALUES[food]


func priority() -> int:
	return PRIORITY


func _first_food() -> StringName:
	for food: StringName in FOOD_ORDER:
		if GameState.get_amount(food) > 0:
			return food
	return &""
