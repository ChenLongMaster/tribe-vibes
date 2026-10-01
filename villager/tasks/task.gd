class_name Task
extends RefCounted
## Một việc thổ dân đang làm (đi ăn, ngủ, tán gẫu…). Mỗi việc một file nhỏ, tự chia
## thành các bước (đi tới → làm → xong). Villager gọi start() một lần, tick() mỗi
## frame, và LUÔN gọi stop() khi việc kết thúc hay bị ngắt — để trả lại chỗ đã đặt.

enum Status { RUNNING, DONE, FAILED }
## Thứ tự ưu tiên khi bộ não cân nhắc có nên ngắt việc đang làm hay không.
enum Priority { IDLE, NEED, PLAYER, SCRIPTED }

var villager: Villager
## Loại việc, dùng để so sánh ("đang đi ăn rồi thì thôi khỏi giao lại").
var kind: StringName = &""
var priority: Priority = Priority.IDLE

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


## Key dịch mô tả việc đang làm (hiện trong bảng thông tin).
func activity_key() -> String:
	return "UI_ACTIVITY_IDLE"


func activity_args() -> Dictionary:
	return {}


func activity_text() -> String:
	return Loc.t(activity_key(), activity_args())


## Icon nhỏ trên đầu khi đang làm việc này ("" = không có).
func icon_key() -> String:
	return ""


## Giờ tick() sẽ trả FAILED — dùng trong start() khi không làm được.
func fail() -> void:
	_failed = true


func world() -> World:
	return villager.world


## Hệ số tốc độ làm một loại việc, tính cả tính cách và việc giỏi nhất.
func work_speed(job: StringName) -> float:
	var speed: float = Traits.modifier(villager.data.traits, "work_speed")
	if villager.data.best_job == job:
		speed *= Balance.BEST_JOB_BONUS
	return speed
