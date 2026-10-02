class_name FoodSource
extends RefCounted
## Một chỗ thổ dân đói có thể đến ăn. TaskEat chỉ làm việc với lớp này nên không quan
## tâm đồ ăn đến từ đâu: bụi quả (BushFoodSource), đồ ăn cất ở lửa trại (StoredFoodSource),
## Đợt 3 thêm Bếp — chỉ cần viết lớp con mới và đăng ký trong WorldFinder.find_food_for().

## Vật để đứng cạnh (bụi, lửa trại, bếp…) và ô của nó.
var target: Node2D
var target_cell: Vector2i
## Sau khi take(): icon món vừa lấy (cầm trên tay lúc ăn) và giải trí cộng thêm (món ngon).
var taken_icon: String = "icons/berry"
var taken_fun: float = 0.0


## Còn đồ ăn cho thổ dân này không (chưa ai khác giữ chỗ).
func is_available(_villager: Villager) -> bool:
	return false


func reserve(_villager: Villager, _reservations: Reservations) -> void:
	pass


func release(_villager: Villager, _reservations: Reservations) -> void:
	pass


## Thời gian lấy đồ ăn (hái quả lâu hơn bốc đồ có sẵn).
func fetch_seconds(_villager: Villager) -> float:
	return Balance.STORED_FOOD_FETCH_SECONDS


func fetch_anim() -> StringName:
	return VillagerRig.ANIM_GATHER


## Lấy đồ ăn ra, trả về lượng Đói hồi được (0 = hết rồi).
func take() -> float:
	return 0.0


## Ưu tiên khi chọn: số nhỏ hơn được chọn trước (đồ có sẵn ở bếp/lửa trại trước, hái quả sau).
func priority() -> int:
	return 0
