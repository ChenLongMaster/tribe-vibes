class_name TaskSulk
extends Task
## Đói mà bếp hết đồ ăn: ngồi bệt nũng nịu tại chỗ, thỉnh thoảng nghĩ tới đùi thịt — để
## người chơi thấy ngay "bếp hết đồ rồi, giao người đi kiếm đi". Đói tới 0 thì không còn
## sức nghĩ nữa, giơ luôn tấm biển vẽ đồ ăn. Việc này không tự kết thúc: bộ não tìm lại
## đồ ăn định kỳ và thay bằng TaskEat khi bếp có đồ.

const FOOD_ICON: String = "icons/res_food"
const THINK_EVERY: float = 4.5
const THINK_SECONDS: float = 2.5

var _sign_up: bool = false


func _init() -> void:
	kind = &"sulk"
	priority = Priority.NEED


func start() -> void:
	villager.state = Villager.State.IDLE
	villager.rig.play(VillagerRig.ANIM_POUT)
	villager.rig.squash(0.15)
	timer = 0.0


func tick(delta: float) -> Status:
	var starving: bool = villager.status.hunger <= 0.0
	if starving and not _sign_up:
		villager.clear_bubble()
		villager.hold_sign(FOOD_ICON, false, Villager.UNTIL_CLEARED)
	elif not starving and _sign_up:
		villager.lower_sign()
	_sign_up = starving
	if not starving:
		timer -= delta
		if timer <= 0.0:
			timer = THINK_EVERY
			villager.think(FOOD_ICON, THINK_SECONDS)
	return Status.RUNNING


func stop() -> void:
	if _sign_up:
		villager.lower_sign()
	villager.clear_bubble()


func activity_key() -> String:
	return "UI_ACTIVITY_SULK"
