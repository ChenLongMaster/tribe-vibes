class_name TaskReturn
extends Task
## Đi về vùng dạo chơi quanh điểm neo — sau khi đi ăn, đi ngủ, hết việc được giao thì quay
## lại chỗ cũ chứ không đứng lại chỗ lạ. Cũng dùng khi người chơi bảo "đi tới chỗ này"
## (điểm neo đã đổi sang chỗ mới trước khi gọi).

const ARRIVE_RADIUS: float = 1.0 # ô quanh điểm neo — tới đây là coi như về rồi

## true = người chơi ra lệnh đi tới (chữ "đi tới chỗ mới" thay vì "quay về chỗ cũ").
var _ordered: bool = false


func _init(ordered: bool = false) -> void:
	_ordered = ordered
	kind = &"goto" if ordered else &"return"


func start() -> void:
	var target: Vector2i = villager.anchor_cell
	if world().grid.is_blocked(target):
		target = world().finder.find_free_cell_near(villager.anchor_cell, 0.0, ARRIVE_RADIUS + 1.0)
	if target == World.INVALID_CELL or not villager.move_to_cell(target):
		fail()


func tick(_delta: float) -> Status:
	if _failed:
		return Status.FAILED
	return Status.RUNNING if villager.is_moving() else Status.DONE


func activity_key() -> String:
	return "UI_ACTIVITY_GOTO" if _ordered else "UI_ACTIVITY_RETURN"
