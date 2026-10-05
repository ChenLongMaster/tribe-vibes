class_name TaskBuild
extends TaskWork
## Một lượt của thợ xây (đội mũ công trường — xem Villager._refresh_gear):
## - Công trường còn thiếu vật liệu: ra kho gần nhất lấy một chuyến (gỗ hoặc đá), giơ trên đầu
##   khuân tới, đổ vào công trường. Kho không đủ thì đứng trước công trình, cắm biển vẽ gỗ/đá
##   (món đang cần), chờ một lúc rồi thử lại (không bỏ việc — có người mang về là xây tiếp).
## - Đủ vật liệu: đứng cạnh công trình gõ búa. Nhiều thợ cùng gõ thì nhanh hơn.
## Bị ngắt giữa đường thì vật liệu đang khuân được cất lại kho (không mất).

enum Step { GO_STORAGE, TAKE, GO_SITE, DROP, GO_BUILD, BUILD, WAIT }

const TAKE_SECONDS: float = 0.6
## Gõ búa tối đa chừng này giây mỗi lượt rồi tính lại (công trình lớn xây nhiều lượt).
const BUILD_ROUND_SECONDS: float = 15.0
const DROP_SECONDS_SITE: float = 0.4
## Biển giơ lâu hơn lúc chờ một chút, vì còn phải đi tới trước công trình.
const SIGN_WALK_SECONDS: float = 3.0
const MATERIAL_CARRY_ART: Dictionary[StringName, String] = {
	&"wood": "props/log",
	&"stone": "props/bucket_pebbles",
}

var _site: Building
var _resource: StringName = &""
var _amount: int = 0
## Phần đã hứa gồm cả lúc chưa lấy đồ; tách khỏi _holding để ngắt việc luôn trả đúng.
var _pledged_amount: int = 0
## Đã lấy ra khỏi kho, đang trên tay (chưa đổ vào công trường).
var _holding: bool = false
var _stand: Vector2i = World.INVALID_CELL
var _stand_key: Array = []


func _init(owner_job: Job, site: Building) -> void:
	super(owner_job)
	_site = site
	kind = &"build"


func start() -> void:
	_decide()


func tick(delta: float) -> Status:
	if _failed:
		return Status.FAILED
	job.nag_cooldown -= delta
	if not _site.is_constructing():
		return Status.DONE
	match step:
		Step.GO_STORAGE:
			if villager.is_moving():
				return Status.RUNNING
			if _storage != null:
				villager.face_towards(_storage.position)
			villager.rig.play(VillagerRig.ANIM_GATHER)
			timer = TAKE_SECONDS
			step = Step.TAKE
		Step.TAKE:
			timer -= delta
			if timer > 0.0:
				return Status.RUNNING
			_take_material()
		Step.GO_SITE:
			if villager.is_moving():
				return Status.RUNNING
			villager.face_towards(_site.position)
			villager.rig.set_carry_item("")
			villager.rig.squash(0.18)
			_site.deliver_material(_resource, _amount)
			_pledged_amount = 0
			_holding = false
			timer = DROP_SECONDS_SITE
			step = Step.DROP
		Step.DROP:
			timer -= delta
			if timer <= 0.0:
				return Status.DONE
		Step.GO_BUILD:
			if villager.is_moving():
				return Status.RUNNING
			villager.face_towards(_site.position)
			hold_job_item()
			villager.rig.play(VillagerRig.ANIM_HAMMER)
			villager.state = Villager.State.WORKING
			timer = 0.0
			step = Step.BUILD
			villager.notify_task_changed()
		Step.BUILD:
			if not _site.materials_complete():
				return Status.DONE
			var seconds: float = delta * work_speed(skill)
			VillagerSkills.add_work(villager, skill, delta)
			_tick_swing(delta)
			if _site.add_build_work(seconds):
				villager.emote("icons/happy")
				return Status.DONE
			timer += delta
			if timer >= BUILD_ROUND_SECONDS:
				return Status.DONE
		Step.WAIT:
			timer -= delta
			if timer <= 0.0:
				return Status.DONE
	return Status.RUNNING


func stop() -> void:
	super.stop()
	if _holding:
		# Bị ngắt giữa đường: cất vật liệu lại kho chung, bỏ phần đã hứa mang tới.
		GameState.add_resource(_resource, _amount)
		_holding = false
	_release_pledge(_pledged_amount)
	if not _stand_key.is_empty():
		world().reservations.release(_stand_key, villager)


func impact_target() -> Node2D:
	return _site


func activity_key() -> String:
	match step:
		Step.GO_STORAGE, Step.TAKE, Step.GO_SITE, Step.DROP:
			return "UI_ACTIVITY_BUILD_HAUL"
		Step.WAIT:
			return "UI_ACTIVITY_BUILD_WAIT"
	return "UI_ACTIVITY_BUILD"


func activity_args() -> Dictionary:
	if _resource != &"":
		return {"resource_key": ResourceDefs.noun_key(_resource)}
	return {}


func icon_key() -> String:
	return "" if _holding else job.icon_key()


# Đủ vật liệu thì xây; thiếu thì đi lấy loại kho đang có; kho hết thì chờ trước công trình.
func _decide() -> void:
	if _site.materials_complete():
		_go_build()
		return
	var missing_any: StringName = &""
	for resource_id: StringName in ResourceDefs.ORDER:
		var missing: int = _site.material_missing(resource_id)
		if missing <= 0:
			continue
		if missing_any == &"":
			missing_any = resource_id
		if GameState.get_amount(resource_id) > 0:
			_go_fetch(resource_id, mini(missing, int(Balance.BUILD_CARRY.get(resource_id, 5))))
			return
	# Không lấy được gì: hoặc kho hết (giơ biển), hoặc người khác đang khuân nốt (chỉ chờ).
	_wait_at_site(missing_any)


func _go_fetch(resource_id: StringName, amount: int) -> void:
	_resource = resource_id
	_amount = amount
	_storage = world().finder.find_storage_for(resource_id, villager)
	# Hứa trước để thợ khác không khuân trùng phần này.
	_site.pledge(resource_id, amount)
	_pledged_amount = amount
	_holding = false
	var stand: Vector2i = World.INVALID_CELL
	if _storage != null:
		stand = world().finder.find_building_stand_cell(_storage, villager)
	if stand == World.INVALID_CELL or not villager.move_to_cell(stand):
		_release_pledge(_pledged_amount)
		fail()
		return
	villager.state = Villager.State.MOVING
	step = Step.GO_STORAGE


func _take_material() -> void:
	var taken: int = mini(_amount, GameState.get_amount(_resource))
	if taken <= 0 or not GameState.take_resource(_resource, taken):
		# Người khác vừa lấy hết: trả lời hứa, lượt sau tính lại.
		_release_pledge(_pledged_amount)
		_wait_at_site(_resource)
		return
	_release_pledge(_amount - taken)
	_amount = taken
	_holding = true
	villager.rig.play(VillagerRig.ANIM_IDLE)
	villager.rig.set_held_item("")
	villager.rig.set_carry_item(MATERIAL_CARRY_ART.get(_resource, ResourceDefs.icon(_resource)))
	villager.rig.squash(-0.1)
	villager.state = Villager.State.CARRYING
	villager.notify_task_changed()
	if not _move_to_site():
		# Không tới được công trường: cất lại kho.
		GameState.add_resource(_resource, _amount)
		_release_pledge(_pledged_amount)
		_holding = false
		villager.rig.set_carry_item("")
		fail()
		return
	step = Step.GO_SITE


## Trả một lần cả khi đường đi thất bại hoặc task bị stop() ngay sau đó.
func _release_pledge(amount: int) -> void:
	var released: int = mini(amount, _pledged_amount)
	if released <= 0:
		return
	_site.unpledge(_resource, released)
	_pledged_amount -= released


func _go_build() -> void:
	if not _move_to_site():
		fail()
		return
	villager.state = Villager.State.MOVING
	step = Step.GO_BUILD


func _wait_at_site(missing: StringName) -> void:
	_resource = missing
	step = Step.WAIT
	timer = Balance.BUILD_WAIT_SECONDS
	if not _move_to_site():
		fail()
		return
	villager.state = Villager.State.IDLE
	# Kho thật sự hết loại này thì giơ biển cho người chơi biết; còn người khác đang khuân
	# nốt thì chỉ đứng chờ.
	if missing != &"" and GameState.get_amount(missing) <= 0 and job.nag_cooldown <= 0.0:
		job.nag_cooldown = TaskCook.NAG_SECONDS
		villager.hold_sign(ResourceDefs.icon(missing), false, Balance.BUILD_WAIT_SECONDS + SIGN_WALK_SECONDS)
	villager.notify_task_changed()


# Đứng ở một ô trống sát công trình, mỗi thợ một ô (đặt chỗ) cho khỏi chồng lên nhau.
func _move_to_site() -> bool:
	if _stand == World.INVALID_CELL:
		_stand = world().finder.find_building_stand_cell(_site, villager, true)
		if _stand == World.INVALID_CELL:
			_stand = world().finder.find_building_stand_cell(_site, villager)
		if _stand == World.INVALID_CELL:
			return false
		_stand_key = [&"stand", _stand]
		world().reservations.reserve(_stand_key, villager)
	return villager.move_to_cell(_stand)
