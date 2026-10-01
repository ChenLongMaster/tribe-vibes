class_name VillagerData
extends RefCounted
## Dữ liệu thuần của một thổ dân — không có node, để lưu game và test dễ.
## Chỉ lưu key/chỉ số (vd trait "LAZY", tóc số 3), không lưu chữ đã dịch.

enum Gender { MALE, FEMALE }
enum Stage { BABY, CHILD, ADULT }

## Các việc có thể "giỏi nhất". Key dịch: JOB_<ID>.
const JOBS: Array[StringName] = [&"CHOP", &"MINE", &"GATHER", &"HUNT", &"FISH", &"COOK", &"BUILD"]
const MAX_NEED: float = 100.0

var id: int = 0
## Tên chọn lúc sinh ra, không đổi khi đổi ngôn ngữ.
var display_name: String = ""
var gender: Gender = Gender.MALE
var stage: Stage = Stage.ADULT
## Chỉ số hình/màu: head, hair, body, accessory (-1 = không có), skin, fur, hair_color.
var appearance: Dictionary = {}
## Cao độ giọng lẩm bẩm riêng của mỗi người (dùng khi có âm thanh).
var voice_pitch: float = 1.0
var traits: Array[StringName] = []
var best_job: StringName = &""
var hunger: float = MAX_NEED
var energy: float = MAX_NEED
var fun: float = MAX_NEED
var health: float = MAX_NEED
var attack: float = 10.0


## Tâm trạng 0..100 = trung bình có trọng số của ba nhu cầu.
func mood() -> float:
	return hunger * Balance.MOOD_WEIGHT_HUNGER + energy * Balance.MOOD_WEIGHT_ENERGY + fun * Balance.MOOD_WEIGHT_FUN


func is_adult() -> bool:
	return stage == Stage.ADULT


func to_dict() -> Dictionary:
	var trait_names: Array[String] = []
	for trait_id: StringName in traits:
		trait_names.append(String(trait_id))
	return {
		"id": id,
		"name": display_name,
		"gender": Gender.keys()[gender],
		"stage": Stage.keys()[stage],
		"appearance": appearance.duplicate(),
		"voice_pitch": voice_pitch,
		"traits": trait_names,
		"best_job": String(best_job),
		"hunger": hunger,
		"energy": energy,
		"fun": fun,
		"health": health,
		"attack": attack,
	}


static func from_dict(data: Dictionary) -> VillagerData:
	var villager: VillagerData = VillagerData.new()
	villager.id = int(data.get("id", 0))
	villager.display_name = str(data.get("name", ""))
	villager.gender = Gender.get(str(data.get("gender", "MALE")), Gender.MALE)
	villager.stage = Stage.get(str(data.get("stage", "ADULT")), Stage.ADULT)
	# JSON đọc số thành float — ép lại về int cho chỉ số hình.
	var look: Dictionary = data.get("appearance", {})
	for key: String in look:
		villager.appearance[key] = int(look[key])
	villager.voice_pitch = float(data.get("voice_pitch", 1.0))
	for trait_id: String in data.get("traits", []):
		villager.traits.append(StringName(trait_id))
	villager.best_job = StringName(str(data.get("best_job", "")))
	villager.hunger = float(data.get("hunger", MAX_NEED))
	villager.energy = float(data.get("energy", MAX_NEED))
	villager.fun = float(data.get("fun", MAX_NEED))
	villager.health = float(data.get("health", MAX_NEED))
	villager.attack = float(data.get("attack", 10.0))
	return villager
