class_name StoredFoodSource
extends FoodSource
## Ăn ở một công trình có đồ ăn: món chín cất ở chính chỗ đó (lửa trại, Bếp) trước (ngon,
## vui hơn); chỗ cất thức ăn thô (hang đá, Bếp) thì lấy một phần trong kho chung (quả / cá /
## thịt — cầm đúng món trên tay lúc ăn). Phần nào cũng làm no căng.

const PRIORITY: int = 0

var _building: Building


func _init(building: Building) -> void:
	_building = building
	target = building
	target_cell = building.origin_cell


func is_available(person: Villager) -> bool:
	return (has_meal() or has_raw()) and (_building.kitchen == null or _building.kitchen.has_seat(person))


func reserve(person: Villager, _reservations: Reservations) -> void:
	if _building.kitchen != null:
		_building.kitchen.reserve(person)


func release(person: Villager, _reservations: Reservations) -> void:
	if _building.kitchen != null:
		_building.kitchen.release(person)


func has_meal() -> bool:
	return _building.is_built() and _building.stock_of(ResourceDefs.MEAL) > 0


func has_raw() -> bool:
	return _building.accepts(ResourceDefs.FOOD) and GameState.get_amount(ResourceDefs.FOOD) > 0


func take() -> float:
	if has_meal() and _building.take_stock(ResourceDefs.MEAL):
		taken_icon = ResourceDefs.icon(ResourceDefs.MEAL)
		if _building.kitchen != null:
			taken_icon = _building.kitchen.meal_art(_building.stock_of(ResourceDefs.MEAL))
		taken_fun = Balance.FUN_COOKED_MEAL
		return Balance.KITCHEN_MEAL_HUNGER
	if not has_raw():
		return 0.0
	var item: StringName = GameState.take_one(ResourceDefs.FOOD)
	if item == &"":
		return 0.0
	taken_icon = ResourceDefs.item_eat_art(item)
	taken_fun = 0.0
	return Balance.KITCHEN_MEAL_HUNGER


## Có món chín thì đi tới đó trước (vui hơn); chỉ có thức ăn thô thì sau.
func priority() -> int:
	return PRIORITY if has_meal() else PRIORITY + 1
