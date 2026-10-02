class_name VillagerNeeds
## Cho 4 chỉ số chạy theo thời gian, đọc tốc độ cơ bản từ NeedDefs (dữ liệu) và chỉ bật
## những chỉ số có trong GameModeConfig.enabled_needs. Phần dưới là các luật "dính" nhau:
## - Việc nặng làm đói nhanh hơn.
## - Làm việc thích thì giải trí giảm rất chậm (việc khác bình thường); Siêng năng giảm chậm hơn.
## - Ngủ hồi thể lực nhân theo chỗ ngủ (ngủ đất ×1, lều theo cấp — Đợt 3).
## - Đói = 0 thì mất máu; không đói thì máu tự hồi.

const ACTIVITY_IDLE: String = "idle"
const ACTIVITY_WORK: String = "work"
const ACTIVITY_SLEEP: String = "sleep"


static func tick(villager: Villager, delta: float) -> void:
	var context: Dictionary = {
		"activity": activity_of(villager.state),
		"skill": villager.current_skill(),
		"sleep_rate": villager.sleep_rate_multiplier,
	}
	step(villager.status, villager.data, GameState.get_mode().enabled_needs, context, delta)


## Phần tính toán thuần (không cần node) — test gọi thẳng được.
## context: activity ("idle"/"work"/"sleep"), skill (kỹ năng của việc đang làm, có thể &""),
## sleep_rate (hệ số hồi thể lực của chỗ ngủ).
static func step(status: VillagerStatus, data: VillagerData, enabled: Array[StringName],
		context: Dictionary, delta: float) -> void:
	var activity: String = context.get("activity", ACTIVITY_IDLE)
	var skill: StringName = context.get("skill", &"")
	for need_id: StringName in NeedDefs.ORDER:
		if not enabled.has(need_id):
			continue
		var rate: float = NeedDefs.rate(need_id, activity) * _multiplier(need_id, activity, skill, data, context)
		status.add_need(need_id, rate * delta)

	if enabled.has(NeedDefs.HEALTH):
		var starving: bool = enabled.has(NeedDefs.HUNGER) and status.hunger <= 0.0
		if starving:
			status.add_need(NeedDefs.HEALTH, -Balance.HEALTH_STARVE_LOSS * delta)
		elif not enabled.has(NeedDefs.HUNGER) or status.hunger > Balance.UNCOMFORTABLE_LEVEL:
			status.add_need(NeedDefs.HEALTH, Balance.HEALTH_REGEN * delta)


static func activity_of(state: Villager.State) -> String:
	match state:
		Villager.State.SLEEPING, Villager.State.KNOCKED_OUT:
			return ACTIVITY_SLEEP
		Villager.State.WORKING, Villager.State.CARRYING:
			return ACTIVITY_WORK
	return ACTIVITY_IDLE


static func _multiplier(need_id: StringName, activity: String, skill: StringName,
		data: VillagerData, context: Dictionary) -> float:
	match need_id:
		NeedDefs.HUNGER:
			var factor: float = Traits.modifier(data.traits, "hunger_rate")
			if activity == ACTIVITY_WORK and SkillDefs.is_heavy(skill):
				factor *= Balance.HEAVY_WORK_HUNGER_MULT
			return factor
		NeedDefs.ENERGY:
			if activity == ACTIVITY_SLEEP:
				return float(context.get("sleep_rate", 1.0))
		NeedDefs.FUN:
			if activity == ACTIVITY_WORK:
				var drain: float = Traits.modifier(data.traits, "work_fun_drain")
				if data.is_favorite(skill):
					drain *= Balance.FAVORITE_FUN_DECAY_MULT
				return drain
	return 1.0
