class_name TaskSleep
extends Task
## Ngủ. Hai kiểu:
## - Bình thường (thể lực < 50%): đi tới chỗ ngủ (SleepSpot): lều còn chỗ thì chui vào trong
##   lều (ẩn đi, lều bay Zzz, hồi nhanh theo cấp lều); không thì ngủ đất cạnh lửa trại. Ngủ đủ
##   thì chui ra, vươn vai dậy.
## - Gục (thể lực = 0): ngã ra ngủ ngay tại chỗ tới khi hồi ENERGY_COLLAPSE_WAKE, rồi xong
##   việc — bộ não thấy vẫn còn mệt sẽ cho đi tìm chỗ ngủ tử tế.

enum Step { GO, APPROACH, ENTER, SLEEP, EXIT, LEAVE, WAKE }

const WAKE_SECONDS: float = 1.3
const DOOR_SECONDS: float = 0.85

var collapsed: bool = false
var _spot: SleepSpot
var _portal_start: Vector2
var _portal_end: Vector2


## `spot` = null thì ngủ tại chỗ (khi gục, hoặc khi không còn chỗ nào).
func _init(spot: SleepSpot, is_collapse: bool = false) -> void:
	_spot = spot
	collapsed = is_collapse
	kind = &"sleep"
	priority = Priority.NEED


func start() -> void:
	step = Step.GO
	if _spot != null and not collapsed:
		if not villager.move_to_cell(_spot.cell):
			fail()


func tick(delta: float) -> Status:
	if _failed:
		return Status.FAILED
	match step:
		Step.GO:
			if villager.is_moving():
				return Status.RUNNING
			if _spot != null and _spot.tent != null and not collapsed:
				if not _spot.tent.is_built():
					return Status.FAILED
				villager.follow_path(PackedVector2Array([_spot.tent.tent_entrance.approach()]))
				step = Step.APPROACH
			else:
				_sleep()
		Step.APPROACH:
			if not villager.is_moving():
				_portal_start = villager.position
				_portal_end = _spot.tent.tent_entrance.door() + Vector2(-6, -4)
				villager.face_towards(_portal_end)
				villager.rig.play(VillagerRig.ANIM_WALK)
				villager.rig.move_speed = Balance.WALK_SPEED * 0.35
				timer = DOOR_SECONDS
				step = Step.ENTER
		Step.ENTER:
			timer = maxf(0.0, timer - delta)
			var progress: float = 1.0 - timer / DOOR_SECONDS
			villager.position = _portal_start.lerp(_portal_end, progress)
			villager.rig.entrance_crouch = progress
			villager.modulate.a = 1.0 - smoothstep(0.65, 1.0, progress)
			if timer <= 0.0:
				villager.set_inside(_spot.tent)
				_spot.tent.add_sleeper(villager)
				_spot.tent.wiggle()
				_sleep()
		Step.SLEEP:
			var wake_at: float = Balance.ENERGY_COLLAPSE_WAKE if collapsed else Balance.ENERGY_WAKE
			if villager.status.energy < wake_at:
				return Status.RUNNING
			villager.state = Villager.State.IDLE
			if villager.inside != null:
				_portal_start = villager.inside.tent_entrance.approach()
				_portal_end = villager.inside.tent_entrance.door() + Vector2(-6, -4)
				_leave_tent()
				villager.position = _portal_end
				villager.face_towards(_portal_start)
				villager.rig.play(VillagerRig.ANIM_WALK)
				villager.rig.move_speed = Balance.WALK_SPEED * 0.35
				timer = DOOR_SECONDS
				step = Step.EXIT
			else:
				_wake()
		Step.EXIT:
			timer = maxf(0.0, timer - delta)
			var progress: float = timer / DOOR_SECONDS
			villager.position = _portal_start.lerp(_portal_end, progress)
			villager.rig.entrance_crouch = progress
			villager.modulate.a = 1.0 - smoothstep(0.65, 1.0, progress)
			if timer <= 0.0:
				villager.follow_path(PackedVector2Array([WorldGrid.cell_to_world(_spot.cell)]))
				step = Step.LEAVE
		Step.LEAVE:
			if not villager.is_moving():
				_wake()
		Step.WAKE:
			timer -= delta
			if timer <= 0.0:
				return Status.DONE
	return Status.RUNNING


func stop() -> void:
	if step in [Step.APPROACH, Step.ENTER, Step.SLEEP, Step.EXIT, Step.LEAVE] and _spot != null and _spot.tent != null:
		villager.position = WorldGrid.cell_to_world(_spot.cell)
		villager.stop_moving()
	villager.rig.entrance_crouch = 0.0
	villager.modulate.a = 1.0
	villager.sleep_rate_multiplier = 1.0
	_leave_tent()
	if _spot != null:
		world().reservations.release(_spot.reservation_key, villager)


func _leave_tent() -> void:
	if villager.inside == null:
		return
	var tent: Building = villager.inside
	tent.remove_sleeper(villager)
	tent.wiggle()
	villager.set_inside(null)


func is_asleep() -> bool:
	return step == Step.SLEEP


func activity_key() -> String:
	if collapsed:
		return "UI_ACTIVITY_COLLAPSE"
	if _spot != null and _spot.tent != null:
		return "UI_ACTIVITY_SLEEP_TENT"
	return "UI_ACTIVITY_SLEEP"


func _sleep() -> void:
	villager.rig.play(VillagerRig.ANIM_SLEEP)
	villager.rig.squash(0.2 if collapsed else 0.1)
	villager.state = Villager.State.SLEEPING
	villager.sleep_rate_multiplier = _spot.rate_multiplier if _spot != null else 1.0
	step = Step.SLEEP

func _wake() -> void:
	villager.rig.entrance_crouch = 0.0
	villager.modulate.a = 1.0
	villager.rig.play(VillagerRig.ANIM_STRETCH)
	timer = WAKE_SECONDS
	step = Step.WAKE


func entry_cell() -> Vector2i:
	return _spot.cell if _spot != null else world().cell_of(villager)
