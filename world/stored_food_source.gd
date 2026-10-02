class_name StoredFoodSource
extends FoodSource
## Ăn ở bếp (hiện là lửa trại — "bếp tạm"; Đợt 3 Bếp cũng dùng lớp này): món chín cất ở
## chính bếp đó trước (ngon, vui hơn), hết thì một phần thức ăn thô trong kho chung (quả /
## cá / thịt — cầm đúng món trên tay lúc ăn). Phần nào cũng làm no căng.

const PRIORITY: int = 0

var _building: Building


func _init(building: Building) -> void:
	_building = building
	target = building
	target_cell = building.origin_cell


func is_available(_villager: Villager) -> bool:
	return _building.stock_of(ResourceDefs.MEAL) > 0 or GameState.get_amount(ResourceDefs.FOOD) > 0


func take() -> float:
	if _building.take_stock(ResourceDefs.MEAL):
		taken_icon = ResourceDefs.icon(ResourceDefs.MEAL)
		taken_fun = Balance.FUN_COOKED_MEAL
		return Balance.KITCHEN_MEAL_HUNGER
	var item: StringName = GameState.take_one(ResourceDefs.FOOD)
	if item == &"":
		return 0.0
	taken_icon = ResourceDefs.item_eat_art(item)
	taken_fun = 0.0
	return Balance.KITCHEN_MEAL_HUNGER


func priority() -> int:
	return PRIORITY
