class_name TaskEmerge
extends Task
## Hoạt cảnh mở đầu: ló ra khỏi hang, dụi mắt, vươn vai (ngủ đông lâu quá mà!),
## rồi đi ra chỗ lửa trại. Bộ não không ngắt được việc này.

enum Step { POP, RUB, STRETCH, WALK }

const POP_SECONDS: float = 0.6
const POP_RISE: float = 26.0 # px — bắt đầu lấp trong miệng hang rồi bước ra
const RUB_SECONDS: float = 1.4
const STRETCH_SECONDS: float = 1.3
const WAKE_BUBBLE_CHANCE: float = 0.5


func _init() -> void:
	kind = &"emerge"
	priority = Priority.SCRIPTED


func start() -> void:
	var end_pos: Vector2 = villager.position
	villager.position = end_pos + Vector2(0, -POP_RISE)
	villager.modulate.a = 0.0
	villager.scale = Vector2(0.7, 0.7)
	var tween: Tween = villager.create_tween().set_parallel(true)
	tween.tween_property(villager, "position", end_pos, POP_SECONDS).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(villager, "modulate:a", 1.0, POP_SECONDS * 0.6)
	tween.tween_property(villager, "scale", villager.stage_scale(), POP_SECONDS).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	villager.face_towards(villager.position + Vector2(1 if randf() < 0.5 else -1, 0))
	timer = POP_SECONDS
	step = Step.POP


func tick(delta: float) -> Status:
	timer -= delta
	match step:
		Step.POP:
			if timer <= 0.0:
				villager.rig.play(VillagerRig.ANIM_RUB_EYES)
				timer = RUB_SECONDS
				step = Step.RUB
		Step.RUB:
			if timer <= 0.0:
				villager.rig.play(VillagerRig.ANIM_YAWN)
				if randf() < WAKE_BUBBLE_CHANCE:
					villager.overhead.show_bubble(Loc.t("BUBBLE_WAKE"))
				timer = STRETCH_SECONDS
				step = Step.STRETCH
		Step.STRETCH:
			if timer <= 0.0:
				var target: Vector2i = world().finder.find_free_cell_near(world().map_data.campfire_cell, 2.0, 4.0)
				if target == World.INVALID_CELL or not villager.move_to_cell(target):
					return Status.DONE
				step = Step.WALK
		Step.WALK:
			if not villager.is_moving():
				return Status.DONE
	return Status.RUNNING


func activity_key() -> String:
	return "UI_ACTIVITY_EMERGE"
