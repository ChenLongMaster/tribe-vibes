class_name Task
extends RefCounted
## Một việc thổ dân đang làm (đi ăn, ngủ, tán gẫu…). Mỗi việc một file nhỏ, tự chia
## thành các bước (đi tới → làm → xong). Villager gọi start() một lần, tick() mỗi
## frame, và LUÔN gọi stop() khi việc kết thúc hay bị ngắt — để trả lại chỗ đã đặt.

enum Status { RUNNING, DONE, FAILED }
## Thứ tự ưu tiên khi bộ não cân nhắc có nên ngắt việc đang làm hay không.
## IDLE = hoạt cảnh rảnh (giao việc là ngắt ngay), WORK = việc người chơi giao (đói/mệt
## ngắt được), NEED = đi ăn/ngủ/đình công, SCRIPTED = hoạt cảnh không ai ngắt được.
enum Priority { IDLE, WORK, NEED, SCRIPTED }

var villager: Villager
## Loại việc, dùng để so sánh ("đang đi ăn rồi thì thôi khỏi giao lại").
var kind: StringName = &""
var priority: Priority = Priority.IDLE
## Kỹ năng của việc đang làm (vd &"CHOP"); &"" nếu không phải việc lao động.
## Hệ nhu cầu đọc để biết việc nặng hay nhẹ, có phải việc thích không.
var skill: StringName = &""

## Bước hiện tại và đồng hồ đếm ngược — dùng chung cho các việc con.
var step: int = 0
var timer: float = 0.0
var _failed: bool = false


func start() -> void:
	pass


func tick(_delta: float) -> Status:
	return Status.DONE


func stop() -> void:
	pass


## Key dịch + tham số mô tả việc đang làm — UI tự dịch khi hiển thị (lõi không dịch chữ).
func activity_key() -> String:
	return "UI_ACTIVITY_IDLE"


func activity_args() -> Dictionary:
	return {}


## Icon nhỏ trên đầu khi đang làm việc này ("" = không có).
func icon_key() -> String:
	return ""


## Giờ tick() sẽ trả FAILED — dùng trong start() khi không làm được.
func fail() -> void:
	_failed = true


func world() -> World:
	return villager.world


## Hệ số tốc độ làm một loại việc, tính cả tính cách và cấp kỹ năng.
func work_speed(job: StringName) -> float:
	var speed: float = Traits.modifier(villager.data.traits, "work_speed")
	return speed * SkillDefs.speed_for_level(villager.skill_level(job))
