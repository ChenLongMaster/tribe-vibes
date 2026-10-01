class_name TaskChat
extends Task
## Tán gẫu: người rủ đi tới cạnh người kia, hai người quay mặt vào nhau, thay phiên
## nói "Ugga bugga!". Người được rủ đứng chờ; ai bỏ đi thì cuộc trò chuyện kết thúc.

const WAIT_TIMEOUT: float = 12.0 # giây chờ người rủ đi tới
const TALK_MIN: float = 4.0
const TALK_MAX: float = 8.0
const TURN_SECONDS: float = 1.4
const GIBBERISH_COUNT: int = 8
const HAPPY_EMOTE_CHANCE: float = 0.5

var session: ChatSession
var _is_initiator: bool = false
var _wait: float = 0.0
var _turn_timer: float = 0.0


func _init(chat: ChatSession, initiator: bool) -> void:
	session = chat
	_is_initiator = initiator
	kind = &"chat"


func start() -> void:
	villager.state = Villager.State.SOCIAL
	if not _is_initiator:
		villager.rig.play(VillagerRig.ANIM_IDLE)
		return
	var stand: Vector2i = world().finder.find_stand_cell(world().cell_of(session.partner), villager)
	if stand == World.INVALID_CELL or not villager.move_to_cell(stand):
		fail()


func tick(delta: float) -> Status:
	if _failed:
		return Status.FAILED
	if session.ended:
		return Status.DONE
	var other: Villager = session.other(villager)
	if not session.talking:
		_wait += delta
		if _wait > WAIT_TIMEOUT:
			session.ended = true
			return Status.FAILED
		if _is_initiator and not villager.is_moving():
			session.talking = true
			session.talk_left = randf_range(TALK_MIN, TALK_MAX)
			_turn_timer = 0.0
		elif not _is_initiator:
			villager.face_towards(other.position)
		return Status.RUNNING

	villager.face_towards(other.position)
	villager.data.fun = minf(villager.data.fun + Balance.FUN_CHAT * delta, VillagerData.MAX_NEED)
	if not _is_initiator:
		return Status.RUNNING
	# Người rủ "cầm nhịp" cho cả hai: đổi lượt nói và đếm giờ.
	session.talk_left -= delta
	_turn_timer -= delta
	if _turn_timer <= 0.0:
		_turn_timer = TURN_SECONDS
		var speaker: Villager = session.initiator if session.initiator_speaking else session.partner
		var listener: Villager = session.other(speaker)
		speaker.rig.play(VillagerRig.ANIM_TALK)
		listener.rig.play(VillagerRig.ANIM_IDLE)
		speaker.overhead.show_bubble(Loc.t("BUBBLE_GIBBERISH_%02d" % randi_range(1, GIBBERISH_COUNT)), "", TURN_SECONDS * 0.9)
		session.initiator_speaking = not session.initiator_speaking
	if session.talk_left <= 0.0:
		session.ended = true
		if randf() < HAPPY_EMOTE_CHANCE:
			villager.overhead.show_emote("icons/happy")
		return Status.DONE
	return Status.RUNNING


func stop() -> void:
	session.ended = true


func activity_key() -> String:
	return "UI_ACTIVITY_CHAT"


func activity_args() -> Dictionary:
	return {"name": session.other(villager).data.display_name}
