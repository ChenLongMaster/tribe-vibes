class_name VillagerData
extends Resource
## Toàn bộ thông tin để TẠO một thổ dân: ngoại hình, tên, giới tính, tính cách,
## kỹ năng, việc thích, tuổi. Không chứa trạng thái lúc chơi (nhu cầu, vị trí, việc
## đang làm — xem VillagerStatus và Villager).
##
## Mọi cách tạo thổ dân (ngẫu nhiên, em bé, sau này là trình tạo nhân vật của chế
## độ Thần Linh) đều chỉ tạo ra một VillagerData rồi gọi Commands.spawn_villager().
## Là Resource nên lưu được thành file .tres (vd mẫu nhân vật dựng sẵn).

enum Gender { MALE, FEMALE }
enum AgeStage { BABY, CHILD, ADULT }

## Ô ngoại hình lưu ID mảnh (vd "hair_03") — rig ghép thành key hình "villager/hair_03".
## Lưu ID chứ không lưu đường dẫn ảnh, nên thay art thật vẫn hiển thị đúng.
const PIECE_SLOTS: Array[String] = ["head", "face", "hair", "body", "accessory"]
## Ô màu lưu mã màu "#RRGGBB" (để sau này chọn màu tự do được).
const COLOR_SLOTS: Array[String] = ["skin", "fur", "hair_color"]
## Mảnh mặc định khi thiếu (vd save cũ, dữ liệu tự tạo thiếu ô).
const DEFAULT_APPEARANCE: Dictionary = {
	"head": "head_01", "face": "face_01", "hair": "hair_01", "body": "body_01", "accessory": "",
	"skin": "#F2C29B", "fur": "#A1887F", "hair_color": "#5D4037",
}

## Tên chọn lúc sinh ra, không đổi khi đổi ngôn ngữ.
@export var display_name: String = ""
@export var gender: Gender = Gender.MALE
@export var age_stage: AgeStage = AgeStage.ADULT
## ID mảnh + mã màu, xem PIECE_SLOTS / COLOR_SLOTS. accessory = "" là không đeo gì.
@export var appearance: Dictionary = DEFAULT_APPEARANCE.duplicate()
## Cao độ giọng lẩm bẩm riêng của mỗi người (dùng khi có âm thanh).
@export var voice_pitch: float = 1.0
@export var traits: Array[StringName] = []
## Cấp khởi đầu 1–5 cho từng loại việc (xem data/skills.gd). Kinh nghiệm tích luỹ lúc chơi
## và cấp đã lên lúc chơi nằm ở VillagerStatus (đọc cấp hiện tại qua Villager.skill_level()).
@export var skills: Dictionary[StringName, int] = {}
## Đúng một việc thích: làm việc này thì lên cấp nhanh hơn và giải trí giảm chậm hơn.
@export var favorite_job: StringName = &""


func is_adult() -> bool:
	return age_stage == AgeStage.ADULT


## Lấy một ô ngoại hình, thiếu thì dùng mặc định.
func look(slot: String) -> String:
	return str(appearance.get(slot, DEFAULT_APPEARANCE.get(slot, "")))


func to_dict() -> Dictionary:
	var trait_names: Array[String] = []
	for trait_id: StringName in traits:
		trait_names.append(String(trait_id))
	return {
		"name": display_name,
		"gender": Gender.keys()[gender],
		"age_stage": AgeStage.keys()[age_stage],
		"appearance": appearance.duplicate(),
		"voice_pitch": voice_pitch,
		"traits": trait_names,
		"skills": _skills_to_dict(),
		"favorite_job": String(favorite_job),
	}


static func from_dict(dict: Dictionary) -> VillagerData:
	var data: VillagerData = VillagerData.new()
	data.display_name = str(dict.get("name", ""))
	data.gender = Gender.get(str(dict.get("gender", "MALE")), Gender.MALE) as Gender
	data.age_stage = AgeStage.get(str(dict.get("age_stage", "ADULT")), AgeStage.ADULT) as AgeStage
	var saved_look: Dictionary = dict.get("appearance", {})
	for slot: String in DEFAULT_APPEARANCE:
		data.appearance[slot] = str(saved_look.get(slot, DEFAULT_APPEARANCE[slot]))
	data.voice_pitch = float(dict.get("voice_pitch", 1.0))
	for trait_id: String in dict.get("traits", []):
		data.traits.append(StringName(trait_id))
	var saved_skills: Dictionary = dict.get("skills", {})
	for skill_id: String in saved_skills:
		var id: StringName = SkillDefs.from_saved_id(skill_id)
		data.skills[id] = maxi(data.skills.get(id, 0), int(saved_skills[skill_id]))
	data.favorite_job = SkillDefs.from_saved_id(str(dict.get("favorite_job", "")))
	return data


## Cấp KHỞI ĐẦU của một kỹ năng (chưa có thì coi như cấp thấp nhất). Cấp lúc chơi: VillagerStatus.skill_level().
func skill_level(skill_id: StringName) -> int:
	return clampi(skills.get(skill_id, Balance.SKILL_MIN_LEVEL), Balance.SKILL_MIN_LEVEL, Balance.SKILL_MAX_LEVEL)


func is_favorite(skill_id: StringName) -> bool:
	return skill_id != &"" and skill_id == favorite_job


func _skills_to_dict() -> Dictionary:
	var result: Dictionary = {}
	for skill_id: StringName in skills:
		result[String(skill_id)] = skills[skill_id]
	return result
