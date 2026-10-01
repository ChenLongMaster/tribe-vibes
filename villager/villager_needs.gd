class_name VillagerNeeds
## Nhu cầu thay đổi theo thời gian: No giảm dần, Năng lượng giảm khi thức/làm việc và
## hồi khi ngủ, Vui giảm dần (nhanh hơn khi đói/mệt). No về 0 thì mất máu.


static func tick(villager: Villager, delta: float) -> void:
	var data: VillagerData = villager.data
	var max_need: float = VillagerData.MAX_NEED
	data.hunger = clampf(data.hunger - Balance.HUNGER_DECAY * Traits.modifier(data.traits, "hunger_rate") * delta, 0.0, max_need)

	match villager.state:
		Villager.State.SLEEPING:
			data.energy += Balance.ENERGY_RESTORE_SLEEP * delta
		Villager.State.WORKING:
			data.energy -= Balance.ENERGY_DECAY_WORK * delta
		_:
			data.energy -= Balance.ENERGY_DECAY_IDLE * delta
	data.energy = clampf(data.energy, 0.0, max_need)

	# Ngủ thì không thấy chán; đói hoặc mệt thì vui tụt nhanh hơn.
	if villager.state != Villager.State.SLEEPING:
		var fun_loss: float = Balance.FUN_DECAY
		if data.hunger < Balance.UNCOMFORTABLE_LEVEL or data.energy < Balance.UNCOMFORTABLE_LEVEL:
			fun_loss += Balance.FUN_DECAY_UNCOMFORTABLE
		data.fun = clampf(data.fun - fun_loss * delta, 0.0, max_need)

	if data.hunger <= 0.0:
		# Đợt 1 chưa có chết: giữ lại 1 máu. Ngất/mất người làm ở Đợt 5 theo độ khó.
		data.health = maxf(data.health - Balance.HEALTH_STARVE_LOSS * delta, 1.0)
	elif data.hunger > Balance.UNCOMFORTABLE_LEVEL:
		data.health = minf(data.health + Balance.HEALTH_REGEN * delta, max_need)
