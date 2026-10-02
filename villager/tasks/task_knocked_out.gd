class_name TaskKnockedOut
extends Task
## Hết máu → ngất (nằm, sao quay quanh đầu). Độ khó Dễ: ngất một lúc rồi tự tỉnh với chút
## máu và chút sức để đi ăn — vì chưa có ai mang đồ ăn tới cứu (Đợt 5 sẽ có người cứu,
## và độ khó Thường thì có thể chết). Bộ não không ngắt được việc này.

enum Step { DOWN, WAKE }

const WAKE_SECONDS: float = 1.5


func _init() -> void:
	kind = &"knocked_out"
	priority = Priority.SCRIPTED


func start() -> void:
	villager.state = Villager.State.KNOCKED_OUT
	villager.rig.play(VillagerRig.ANIM_KNOCKED_OUT)
	villager.rig.squash(0.25)
	timer = Balance.KNOCKOUT_SECONDS
	step = Step.DOWN


func tick(delta: float) -> Status:
	timer -= delta
	match step:
		Step.DOWN:
			if timer > 0.0:
				return Status.RUNNING
			var status: VillagerStatus = villager.status
			status.health = maxf(status.health, Balance.KNOCKOUT_WAKE_HEALTH)
			status.hunger = maxf(status.hunger, Balance.KNOCKOUT_WAKE_HUNGER)
			villager.state = Villager.State.IDLE
			villager.rig.play(VillagerRig.ANIM_RUB_EYES)
			timer = WAKE_SECONDS
			step = Step.WAKE
		Step.WAKE:
			if timer <= 0.0:
				return Status.DONE
	return Status.RUNNING


func activity_key() -> String:
	return "UI_ACTIVITY_KNOCKED_OUT"
