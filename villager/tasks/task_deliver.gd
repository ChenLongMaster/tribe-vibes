class_name TaskDeliver
extends TaskWork
## Khuân nốt đồ đang cầm dở (bị ngắt vì đói, mệt…) về kho, rồi mới làm lượt mới.


func _init(owner_job: Job) -> void:
	super(owner_job)
	kind = &"deliver"


func start() -> void:
	begin_carry(job.carried_item, job.carried_count)


func tick(delta: float) -> Status:
	return tick_carry(delta)
