class_name TaskSleep
extends Task
## Ngủ. Hai kiểu:
## - Bình thường (thể lực < 50%): đi tới chỗ ngủ (SleepSpot): lều còn chỗ thì chui vào trong
##   lều (ẩn đi, lều bay Zzz, hồi nhanh theo cấp lều); không thì ngủ đất cạnh lửa trại. Ngủ đủ
##   thì chui ra, vươn vai dậy.
## - Gục (thể lực = 0): ngã ra ngủ ngay tại chỗ tới khi hồi ENERGY_COLLAPSE_WAKE, rồi xong
##   việc — bộ não thấy vẫn còn mệt sẽ cho đi tìm chỗ ngủ tử tế.

enum Step { GO, SLEEP, WAKE }

const WAKE_SECONDS: float = 1.3

var collapsed: bool = false
var _spot: SleepSpot


## `spot` = null thì ngủ tại chỗ (khi gục, hoặc khi không còn chỗ nào).
func _init(spot: SleepSpot, is_collapse: bool = false) -> void:
	_spot = spot
	collapsed = is_collapse
	kind = &"sleep"
	priority = Priority.NEED


func start() -> void:
	step = Step.GO
	if _spot != null and not collapsed:
		villager.move_to_cell(_spot.cell)


func tick(delta: float) -> Status:
	match step:
		Step.GO:
			if villager.is_moving():
				return Status.RUNNING
			if _spot != null and _spot.tent != null and not collapsed:
				if not _spot.tent.is_built():
					return Status.FAILED
				villager.face_towards(_spot.tent.position)
				villager.set_inside(_spot.tent)
				_spot.tent.add_sleeper(villager)
				_spot.tent.wiggle()
			villager.rig.play(VillagerRig.ANIM_SLEEP)
			villager.rig.squash(0.2 if collapsed else 0.1)
			villager.state = Villager.State.SLEEPING
			villager.sleep_rate_multiplier = _spot.rate_multiplier if _spot != null else 1.0
			step = Step.SLEEP
		Step.SLEEP:
			var wake_at: float = Balance.ENERGY_COLLAPSE_WAKE if collapsed else Balance.ENERGY_WAKE
			if villager.status.energy < wake_at:
				return Status.RUNNING
			villager.state = Villager.State.IDLE
			_leave_tent()
			villager.rig.play(VillagerRig.ANIM_STRETCH)
			timer = WAKE_SECONDS
			step = Step.WAKE
		Step.WAKE:
			timer -= delta
			if timer <= 0.0:
				return Status.DONE
	return Status.RUNNING


func stop() -> void:
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
