class_name VillagerBrain
extends RefCounted
## Bộ não chọn việc, được gọi mỗi 0.3–0.6 giây. Chế độ Normal (`villager_autonomy =
## OBEDIENT`): thổ dân NGHE LỜI — không tự kiếm việc, chỉ tự rời chỗ khi đói, mệt (và
## Đợt 4: muốn tìm bạn đời). Thứ tự ưu tiên (GAME_DESIGN mục 5.2):
##   1. Nguy hiểm (Đợt 5)
##   2. Máu = 0 → ngất. Thể lực = 0 → gục ngủ tại chỗ.
##   3. Giải trí = 0 → đình công (quăng đồ nghề, từ chối việc tới khi giải trí hồi lại)
##   4. Đói < 50 → đi tới bếp ăn (vừa đi vừa nghĩ tới đồ ăn); bếp hết đồ thì ngồi bệt
##      nũng nịu (người đang làm việc được giao thì làm tiếp tới khi đói lả). Thể lực < 50%
##      → đi ngủ. Luôn có bong bóng nghĩ / tấm biển giải thích.
##   5. Muốn tìm bạn đời (Đợt 4)
##   6. Việc người chơi giao (Job) → làm từng lượt, xong lượt lại làm tiếp — chế độ
##      AUTONOMOUS thêm "tự kiếm việc" ở đây
##   7. Rảnh → về đúng chỗ được thả (điểm neo) rồi ĐỨNG YÊN làm trò tại chỗ: đứng chờ, vẫy
##      người chơi, ngó nghiêng, vươn vai, gãi, tán gẫu với người sát bên. Đứng quá
##      IDLE_BORED_SECONDS mà chưa có việc thì chán: ngồi phịch xuống, nằm ngủ gật, hoặc đi hái
##      bông hoa gần đó rồi quay về đúng chỗ cũ. Không đi dạo lung tung.

## Trọng số hoạt cảnh lúc mới đứng chờ (nhân thêm theo tính cách và tình trạng).
const WAITING_WEIGHTS: Dictionary[StringName, float] = {
	&"stand": 3.0,
	&"wave": 1.2,
	&"look": 1.5,
	&"stretch": 0.5,
	&"scratch": 0.5,
	&"chat": 1.5,
}
## Trọng số lúc đã chán (đứng chờ quá lâu).
const BORED_WEIGHTS: Dictionary[StringName, float] = {
	&"sit": 2.0,
	&"nap": 1.5,
	&"pick_flower": 1.5,
	&"look": 0.6,
	&"scratch": 0.5,
	&"chat": 1.0,
}
const FIDGET_ANIMS: Dictionary[StringName, StringName] = {
	&"stand": VillagerRig.ANIM_IDLE,
	&"wave": VillagerRig.ANIM_WAVE,
	&"look": VillagerRig.ANIM_LOOK,
	&"stretch": VillagerRig.ANIM_STRETCH,
}
## Không tìm được đồ ăn thì đợi chừng này giây rồi mới tìm lại (đỡ tìm liên tục).
const FOOD_RETRY_SECONDS: float = 3.0
## Đang làm việc được giao mà bếp hết đồ: thỉnh thoảng nghĩ tới đồ ăn (không bỏ việc).
const NO_FOOD_THINK_SECONDS: float = 15.0
const FOOD_THOUGHT_ICON: String = "icons/res_food"

var _food_retry: float = 0.0
var _no_food: bool = false
var _no_food_think_cooldown: float = 0.0


func think(villager: Villager, elapsed: float) -> void:
	_food_retry -= elapsed
	_no_food_think_cooldown -= elapsed
	var current: Task = villager.task
	if current != null and current.priority == Task.Priority.SCRIPTED:
		return
	var mode: GameModeConfig = GameState.get_mode()
	if _handle_collapse(villager, current, mode):
		return
	if _handle_strike(villager, mode):
		return
	if _handle_needs(villager, current, mode):
		return
	# Đợt 4: muốn tìm bạn đời (bước 5) chen vào đây.
	if _handle_job(villager):
		return
	if mode.villager_autonomy == GameModeConfig.Autonomy.AUTONOMOUS:
		# Sau MVP (chế độ Thần Linh): tự kiếm việc của làng ở đây.
		pass
	if villager.task != null:
		return
	if _is_away_from_anchor(villager):
		villager.start_task(TaskReturn.new())
	else:
		villager.start_task(_choose_idle_task(villager))


# Máu = 0 → ngất; thể lực = 0 → gục ngủ tại chỗ. Trả về true nếu đã xử lý.
func _handle_collapse(villager: Villager, current: Task, mode: GameModeConfig) -> bool:
	var status: VillagerStatus = villager.status
	if mode.need_enabled(NeedDefs.HEALTH) and status.health <= 0.0:
		villager.start_task(TaskKnockedOut.new())
		return true
	if mode.need_enabled(NeedDefs.ENERGY) and status.energy <= 0.0:
		if current is TaskSleep:
			return true
		villager.start_task(TaskSleep.new(null, true))
		villager.emote("icons/sleepy")
		return true
	return false


# Đói < 50 → đi ăn; thể lực < 50% → đi ngủ. Trả về true nếu đang lo nhu cầu.
func _handle_needs(villager: Villager, current: Task, mode: GameModeConfig) -> bool:
	var status: VillagerStatus = villager.status
	var asleep: bool = current is TaskSleep and (current as TaskSleep).is_asleep()

	if mode.need_enabled(NeedDefs.HUNGER) and status.hunger < Balance.HUNGER_EAT_BELOW:
		if current != null and current.kind == &"eat":
			return true
		# Đang ngủ thì chỉ dậy khi đói lắm.
		var can_interrupt: bool = not asleep or status.hunger < Balance.HUNGER_WAKE
		if can_interrupt and _food_retry <= 0.0:
			var source: FoodSource = villager.world.finder.find_food_for(villager)
			_no_food = source == null
			if source != null:
				villager.start_task(TaskEat.new(source))
				villager.rig.flash_face(VillagerRig.FACE_SURPRISED, 0.8)
				return true
			_food_retry = FOOD_RETRY_SECONDS
		# Vừa mệt vừa đói mà bếp hết đồ: ngủ trước (ngủ dậy vẫn dỗi tiếp nếu chưa có đồ ăn).
		var tired: bool = mode.need_enabled(NeedDefs.ENERGY) and status.energy < Balance.ENERGY_SLEEP_BELOW 				and status.hunger >= Balance.HUNGER_WAKE
		if current is TaskSulk and not tired:
			return true
		if can_interrupt and _no_food and not tired and _handle_no_food(villager, current):
			return true

	if mode.need_enabled(NeedDefs.ENERGY) and status.energy < Balance.ENERGY_SLEEP_BELOW:
		if current != null and current.kind == &"sleep":
			return true
		if current != null and current.priority >= Task.Priority.NEED and not (current is TaskSulk):
			# Đang đi ăn thì ăn xong rồi ngủ.
			return true
		villager.start_task(TaskSleep.new(villager.world.finder.find_bed_for(villager)))
		villager.think("icons/sleepy")
		return true
	return false


# Đói mà bếp hết đồ ăn. Rảnh (hoặc đã đói lả) thì ngồi bệt nũng nịu cho người chơi thấy;
# đang làm việc được giao thì làm tiếp — biết đâu chính họ đang kiếm đồ ăn về — chỉ
# thỉnh thoảng nghĩ tới đồ ăn. Trả về true nếu vừa ngồi dỗi.
func _handle_no_food(villager: Villager, current: Task) -> bool:
	var busy_with_job: bool = villager.job != null and not villager.on_strike
	if busy_with_job and villager.status.hunger > 0.0:
		if _no_food_think_cooldown <= 0.0 and not villager.rig.is_carrying():
			_no_food_think_cooldown = NO_FOOD_THINK_SECONDS
			villager.think(FOOD_THOUGHT_ICON)
		return false
	# Đang ngủ thì chỉ dậy dỗi khi đói lắm; không chen ngang màn giận dỗi (việc NEED khác).
	if current is TaskSleep:
		if villager.status.hunger >= Balance.HUNGER_WAKE:
			return false
	elif current != null and current.priority >= Task.Priority.NEED:
		return false
	villager.start_task(TaskSulk.new())
	return true


# Giải trí = 0 → đình công; đang đình công mà giải trí hồi đủ thì làm lại. Trả về true nếu
# vừa bắt đầu đình công (màn quăng đồ nghề).
func _handle_strike(villager: Villager, mode: GameModeConfig) -> bool:
	if not mode.need_enabled(NeedDefs.FUN):
		if villager.on_strike:
			villager.end_strike()
		return false
	if villager.on_strike:
		if villager.status.fun >= Balance.STRIKE_RESUME_FUN:
			villager.end_strike()
		return false
	if villager.status.fun <= 0.0 and villager.state != Villager.State.SLEEPING:
		villager.begin_strike()
		return true
	return false


# Bước 6: có việc được giao (và không đình công) thì làm lượt tiếp theo. Đang ăn/ngủ thì
# để xong đã. Hết thứ để làm thì thôi việc, đứng chờ tại chỗ. Trả về true nếu đang bận việc.
func _handle_job(villager: Villager) -> bool:
	var job: Job = villager.job
	if job == null or villager.on_strike:
		return false
	var current: Task = villager.task
	if current != null and current.priority != Task.Priority.IDLE:
		return true
	var next: Task = job.next_task(villager)
	if next == null:
		villager.stop_job()
		return false
	villager.start_task(next)
	return true


# Rảnh thì đứng đúng ô được thả. Ô đó bị chặn mất (vd có nhà xây đè) thì neo luôn chỗ đang đứng.
func _is_away_from_anchor(villager: Villager) -> bool:
	var here: Vector2i = villager.world.cell_of(villager)
	if villager.world.grid.is_blocked(villager.anchor_cell):
		villager.anchor_cell = here
	return here != villager.anchor_cell


func _choose_idle_task(villager: Villager) -> Task:
	var data: VillagerData = villager.data
	var world: World = villager.world
	var bored: bool = villager.idle_seconds >= Balance.IDLE_BORED_SECONDS
	var weights: Dictionary[StringName, float] = (BORED_WEIGHTS if bored else WAITING_WEIGHTS).duplicate()
	for activity: StringName in weights:
		weights[activity] *= Traits.idle_weight(data.traits, activity)
	# Mệt thì muốn ngồi / ngủ gật, chán thì muốn tán gẫu.
	if villager.status.energy < Balance.ENERGY_TIRED:
		for activity: StringName in [&"sit", &"nap"]:
			if weights.has(activity):
				weights[activity] *= 2.5
	if villager.status.fun < 50.0:
		weights[&"chat"] *= 1.5
	var partner: Villager = world.finder.find_chat_partner(villager)
	if partner == null:
		weights[&"chat"] = 0.0
	if weights.has(&"pick_flower") and world.finder.find_flower_near(villager).is_empty():
		weights[&"pick_flower"] = 0.0

	var choice: StringName = _weighted_pick(weights)
	match choice:
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
		&"nap":
			return TaskNap.new()
	var seconds: float = randf_range(Balance.IDLE_MIN_SECONDS, Balance.IDLE_MAX_SECONDS)
	return TaskFidget.new(FIDGET_ANIMS.get(choice, VillagerRig.ANIM_IDLE), seconds)


func _weighted_pick(weights: Dictionary[StringName, float]) -> StringName:
	var total: float = 0.0
	for key: StringName in weights:
		total += weights[key]
	var roll: float = randf() * total
	for key: StringName in weights:
		roll -= weights[key]
		if roll <= 0.0 and weights[key] > 0.0:
			return key
	return &"stand"
