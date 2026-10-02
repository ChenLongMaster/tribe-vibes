class_name BushFoodSource
extends FoodSource
## Đến bụi quả, hái rồi ăn tại chỗ. Mỗi bụi chỉ một người nhận một lúc.

const PRIORITY: int = 10

var _bush: ResourceNode


func _init(bush: ResourceNode) -> void:
	_bush = bush
	target = bush
	target_cell = bush.cell


func is_available(villager: Villager) -> bool:
	return _bush.has_berries() and not villager.world.reservations.is_taken_by_other(_bush, villager)


func reserve(villager: Villager, reservations: Reservations) -> void:
	reservations.reserve(_bush, villager)


func release(villager: Villager, reservations: Reservations) -> void:
	reservations.release(_bush, villager)


func fetch_seconds(villager: Villager) -> float:
	var level: int = villager.skill_level(SkillDefs.GATHER)
	return Balance.PICK_SECONDS / (Traits.modifier(villager.data.traits, "work_speed") * SkillDefs.speed_for_level(level))


func take() -> float:
	return _bush.take_berries() * Balance.BERRY_HUNGER


func priority() -> int:
	return PRIORITY
