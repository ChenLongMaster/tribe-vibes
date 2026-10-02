class_name VillagerFactory
## Sinh ngẫu nhiên một VillagerData: tên, ngoại hình, tính cách, kỹ năng, việc thích.
## Chỉ tạo dữ liệu — muốn có thổ dân trong thế giới thì gọi Commands.spawn_villager().

## Trọng số chọn kiểu tóc 1..5 theo giới tính — chỉ là "hay gặp", không bắt buộc.
const HAIR_WEIGHTS_MALE: Array[float] = [2.0, 0.5, 0.6, 0.3, 1.5]
const HAIR_WEIGHTS_FEMALE: Array[float] = [0.5, 2.0, 2.0, 2.0, 0.3]
## Trọng số phụ kiện: không có, xương, lông chim, hoa.
const ACCESSORY_WEIGHTS_MALE: Array[float] = [1.5, 1.0, 1.0, 0.2]
const ACCESSORY_WEIGHTS_FEMALE: Array[float] = [1.2, 0.4, 0.8, 1.5]
const VOICE_PITCH_MALE: Vector2 = Vector2(0.8, 1.05)
const VOICE_PITCH_FEMALE: Vector2 = Vector2(1.05, 1.3)


static func create(rng: RandomNumberGenerator, gender: VillagerData.Gender,
		language: String, taken_names: PackedStringArray = []) -> VillagerData:
	var data: VillagerData = VillagerData.new()
	data.gender = gender
	data.age_stage = VillagerData.AgeStage.ADULT
	data.display_name = NameBank.pick(rng, language, taken_names)
	var female: bool = gender == VillagerData.Gender.FEMALE
	# 0 = không đeo phụ kiện.
	var accessory: int = _weighted(rng, ACCESSORY_WEIGHTS_FEMALE if female else ACCESSORY_WEIGHTS_MALE)
	data.appearance = {
		"head": VillagerPalette.piece_id("head", rng.randi_range(0, VillagerPalette.HEAD_COUNT - 1)),
		"face": VillagerPalette.piece_id("face", rng.randi_range(0, VillagerPalette.FACE_COUNT - 1)),
		"hair": VillagerPalette.piece_id("hair", _weighted(rng, HAIR_WEIGHTS_FEMALE if female else HAIR_WEIGHTS_MALE)),
		"body": VillagerPalette.piece_id("body", rng.randi_range(0, VillagerPalette.BODY_COUNT - 1)),
		"accessory": VillagerPalette.piece_id("accessory", accessory - 1) if accessory > 0 else "",
		"skin": VillagerPalette.to_hex(_pick_color(rng, VillagerPalette.SKIN)),
		"fur": VillagerPalette.to_hex(_pick_color(rng, VillagerPalette.FUR)),
		"hair_color": VillagerPalette.to_hex(_pick_color(rng, VillagerPalette.HAIR)),
	}
	var pitch: Vector2 = VOICE_PITCH_FEMALE if female else VOICE_PITCH_MALE
	data.voice_pitch = rng.randf_range(pitch.x, pitch.y)
	data.traits = _pick_traits(rng)
	data.skills = _pick_skills(rng, data.traits)
	data.favorite_job = SkillDefs.ORDER[rng.randi_range(0, SkillDefs.ORDER.size() - 1)]
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


## Cấp khởi đầu ngẫu nhiên thấp (1..SKILL_START_RANDOM_MAX), cộng theo tính cách, tối đa
## SKILL_START_CAP — để còn chỗ lên cấp khi chơi.
static func _pick_skills(rng: RandomNumberGenerator, traits: Array[StringName]) -> Dictionary[StringName, int]:
	var skills: Dictionary[StringName, int] = {}
	for skill_id: StringName in SkillDefs.ORDER:
		var level: int = rng.randi_range(Balance.SKILL_MIN_LEVEL, Balance.SKILL_START_RANDOM_MAX)
		skills[skill_id] = mini(level + Traits.skill_bonus(traits, skill_id), Balance.SKILL_START_CAP)
	return skills


static func _pick_color(rng: RandomNumberGenerator, colors: Array[Color]) -> Color:
	return colors[rng.randi_range(0, colors.size() - 1)]


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
