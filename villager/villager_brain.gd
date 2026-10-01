class_name VillagerBrain
extends RefCounted
## Bộ não chọn việc (utility AI đơn giản), được gọi mỗi 0.3–0.6 giây. Thứ tự ưu tiên:
##   1. Nguy hiểm (Đợt 5)
##   2. Nhu cầu khẩn cấp — đói thì đi ăn, kiệt sức thì đi ngủ, có bong bóng giải thích
##   3. Việc người chơi giao (Đợt 2)
##   4. Việc chung của làng (Đợt 2–3)
##   5. Rảnh → hoạt cảnh rảnh rỗi, chọn ngẫu nhiên có trọng số theo tính cách

## Trọng số gốc của hoạt cảnh rảnh rỗi (nhân thêm theo tính cách và tình trạng).
const IDLE_WEIGHTS: Dictionary[StringName, float] = {
	&"wander": 2.0,
	&"chat": 2.0,
	&"pick_flower": 1.0,
	&"scratch": 0.6,
	&"sit": 1.2,
	&"snack": 2.0,
}
## Không tìm được đồ ăn thì đợi chừng này giây rồi mới tìm lại (đỡ tìm liên tục).
const FOOD_RETRY_SECONDS: float = 5.0
const NO_FOOD_BUBBLE_SECONDS: float = 15.0

var _food_retry: float = 0.0
var _no_food_bubble_cooldown: float = 0.0


func think(villager: Villager, elapsed: float) -> void:
	_food_retry -= elapsed
	_no_food_bubble_cooldown -= elapsed
	var current: Task = villager.task
	if current != null and current.priority == Task.Priority.SCRIPTED:
		return
	if _handle_urgent_needs(villager, current):
		return
	if villager.task == null:
		villager.start_task(_choose_idle_task(villager))


# Trả về true nếu đã giao một việc vì nhu cầu (hoặc đang làm sẵn rồi).
func _handle_urgent_needs(villager: Villager, current: Task) -> bool:
	var data: VillagerData = villager.data
	var asleep: bool = current is TaskSleep and (current as TaskSleep).is_asleep()

	if data.hunger < Balance.HUNGER_URGENT:
		if current != null and current.kind == &"eat":
			return true
		# Đang ngủ thì chỉ dậy khi đói lắm.
		var can_interrupt: bool = not asleep or data.hunger < Balance.HUNGER_WAKE
		if can_interrupt and _food_retry <= 0.0:
			if villager.world.finder.find_bush_for(villager) != null:
				villager.start_task(TaskEat.new(true))
				villager.overhead.show_bubble(Loc.t("BUBBLE_HUNGRY"), "icons/hunger")
				villager.rig.flash_face(VillagerRig.FACE_SURPRISED, 0.8)
				return true
			_food_retry = FOOD_RETRY_SECONDS
			if _no_food_bubble_cooldown <= 0.0:
				_no_food_bubble_cooldown = NO_FOOD_BUBBLE_SECONDS
				villager.overhead.show_bubble(Loc.t("BUBBLE_NO_FOOD"), "icons/hunger")

	if data.energy < Balance.ENERGY_URGENT:
		if current != null and (current.kind == &"sleep" or current.priority >= Task.Priority.NEED):
			return current.kind == &"sleep"
		villager.start_task(TaskSleep.new())
		villager.overhead.show_bubble(Loc.t("BUBBLE_SLEEPY"), "icons/sleepy")
		return true
	return false


func _choose_idle_task(villager: Villager) -> Task:
	var data: VillagerData = villager.data
	var world: World = villager.world
	var weights: Dictionary[StringName, float] = {}
	for activity: StringName in IDLE_WEIGHTS:
		weights[activity] = IDLE_WEIGHTS[activity] * Traits.idle_weight(data.traits, activity)
	# Tình trạng hiện tại cũng ảnh hưởng: mệt thì muốn ngồi, chán thì muốn tán gẫu.
	if data.energy < Balance.ENERGY_TIRED:
		weights[&"sit"] *= 2.5
	if data.fun < 50.0:
		weights[&"chat"] *= 1.5
	if data.hunger >= Balance.HUNGER_SNACK or _food_retry > 0.0 or world.finder.find_bush_for(villager) == null:
		weights[&"snack"] = 0.0
	var partner: Villager = world.finder.find_chat_partner(villager)
	if partner == null:
		weights[&"chat"] = 0.0
	if world.finder.find_flower_near(villager).is_empty():
		weights[&"pick_flower"] = 0.0

	match _weighted_pick(weights):
		&"chat":
			var session: ChatSession = ChatSession.new(villager, partner)
			partner.start_task(TaskChat.new(session, false))
			return TaskChat.new(session, true)
		&"pick_flower":
			return TaskPickFlower.new()
		&"scratch":
			return TaskScratch.new()
		&"sit":
			return TaskSit.new()
		&"snack":
			return TaskEat.new(false)
	return TaskWander.new()


func _weighted_pick(weights: Dictionary[StringName, float]) -> StringName:
	var total: float = 0.0
	for key: StringName in weights:
		total += weights[key]
	var roll: float = randf() * total
	for key: StringName in weights:
		roll -= weights[key]
		if roll <= 0.0 and weights[key] > 0.0:
			return key
	return &"wander"
