class_name VillagerFactory
## Tạo thổ dân ngẫu nhiên: tên, ngoại hình, tính cách, việc giỏi nhất, nhu cầu ban đầu.

## Trọng số chọn kiểu tóc 1..5 theo giới tính — chỉ là "hay gặp", không bắt buộc.
const HAIR_WEIGHTS_MALE: Array[float] = [2.0, 0.5, 0.6, 0.3, 1.5]
const HAIR_WEIGHTS_FEMALE: Array[float] = [0.5, 2.0, 2.0, 2.0, 0.3]
## Trọng số phụ kiện: không có, xương, lông chim, hoa.
const ACCESSORY_WEIGHTS_MALE: Array[float] = [1.5, 1.0, 1.0, 0.2]
const ACCESSORY_WEIGHTS_FEMALE: Array[float] = [1.2, 0.4, 0.8, 1.5]
const VOICE_PITCH_MALE: Vector2 = Vector2(0.8, 1.05)
const VOICE_PITCH_FEMALE: Vector2 = Vector2(1.05, 1.3)


static func create(rng: RandomNumberGenerator, id: int, gender: VillagerData.Gender,
		language: String, taken_names: PackedStringArray = []) -> VillagerData:
	var data: VillagerData = VillagerData.new()
	data.id = id
	data.gender = gender
	data.stage = VillagerData.Stage.ADULT
	data.display_name = NameBank.pick(rng, language, taken_names)
	var female: bool = gender == VillagerData.Gender.FEMALE
	data.appearance = {
		"head": rng.randi_range(0, VillagerPalette.HEAD_COUNT - 1),
		"hair": _weighted(rng, HAIR_WEIGHTS_FEMALE if female else HAIR_WEIGHTS_MALE),
		"body": rng.randi_range(0, VillagerPalette.BODY_COUNT - 1),
		# -1 = không đeo gì.
		"accessory": _weighted(rng, ACCESSORY_WEIGHTS_FEMALE if female else ACCESSORY_WEIGHTS_MALE) - 1,
		"skin": rng.randi_range(0, VillagerPalette.SKIN.size() - 1),
		"fur": rng.randi_range(0, VillagerPalette.FUR.size() - 1),
		"hair_color": rng.randi_range(0, VillagerPalette.HAIR.size() - 1),
	}
	var pitch: Vector2 = VOICE_PITCH_FEMALE if female else VOICE_PITCH_MALE
	data.voice_pitch = rng.randf_range(pitch.x, pitch.y)
	data.traits = _pick_traits(rng)
	data.best_job = VillagerData.JOBS[rng.randi_range(0, VillagerData.JOBS.size() - 1)]
	data.hunger = rng.randf_range(Balance.START_HUNGER_MIN, Balance.START_HUNGER_MAX)
	data.energy = rng.randf_range(Balance.START_ENERGY_MIN, Balance.START_ENERGY_MAX)
	data.fun = rng.randf_range(Balance.START_FUN_MIN, Balance.START_FUN_MAX)
	return data


static func _pick_traits(rng: RandomNumberGenerator) -> Array[StringName]:
	var pool: Array[StringName] = Traits.all_ids()
	var count: int = 2 if rng.randf() < Balance.SECOND_TRAIT_CHANCE else 1
	var chosen: Array[StringName] = []
	var attempts: int = 0
	while chosen.size() < count and attempts < 20:
		attempts += 1
		var candidate: StringName = pool[rng.randi_range(0, pool.size() - 1)]
		if Traits.compatible(chosen, candidate):
			chosen.append(candidate)
	return chosen


static func _weighted(rng: RandomNumberGenerator, weights: Array[float]) -> int:
	var total: float = 0.0
	for weight: float in weights:
		total += weight
	var roll: float = rng.randf() * total
	for i: int in weights.size():
		roll -= weights[i]
		if roll <= 0.0:
			return i
	return weights.size() - 1
