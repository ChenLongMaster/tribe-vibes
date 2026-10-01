class_name SelectionController
extends Node
## Biến lệnh chung từ InputRouter thành "chọn thổ dân". Chạm vào thổ dân → chọn và mở
## bảng thông tin; chạm chỗ trống / Esc / chuột phải / nút ✕ → bỏ chọn.
## Rê chuột (máy tính) hoặc nhấn giữ (điện thoại) → hiện tên để xem nhanh.
## (Đợt 2: đang chọn mà chạm vào cây/đá → giao việc.)

const LONG_PRESS_NAME_SECONDS: float = 2.0

var selected: Villager
var _world: World
var _hovered: Villager
var _long_press_shown: Villager
var _long_press_timer: float = 0.0


func _ready() -> void:
	_world = get_parent() as World
	InputRouter.tapped.connect(_on_tapped)
	InputRouter.hovered.connect(_on_hovered)
	InputRouter.long_pressed.connect(_on_long_pressed)
	InputRouter.cancel_requested.connect(deselect)
	EventBus.deselect_requested.connect(deselect)


func select(villager: Villager) -> void:
	if selected == villager:
		return
	if is_instance_valid(selected):
		selected.set_selected(false)
	selected = villager
	if selected != null:
		selected.set_selected(true)
		selected.rig.squash(-0.12)
	EventBus.villager_selected.emit(selected)


func deselect() -> void:
	select(null)


func _process(delta: float) -> void:
	if _long_press_timer > 0.0:
		_long_press_timer -= delta
		if _long_press_timer <= 0.0 and is_instance_valid(_long_press_shown):
			_long_press_shown.set_hovered(false)


func _on_tapped(screen_pos: Vector2) -> void:
	select(_world.pick_villager(InputRouter.screen_to_world(screen_pos)))


func _on_hovered(screen_pos: Vector2) -> void:
	var villager: Villager = _world.pick_villager(InputRouter.screen_to_world(screen_pos))
	if villager == _hovered:
		return
	if is_instance_valid(_hovered):
		_hovered.set_hovered(false)
	_hovered = villager
	if _hovered != null:
		_hovered.set_hovered(true)


func _on_long_pressed(screen_pos: Vector2) -> void:
	var villager: Villager = _world.pick_villager(InputRouter.screen_to_world(screen_pos))
	if villager == null:
		return
	villager.set_hovered(true)
	_long_press_shown = villager
	_long_press_timer = LONG_PRESS_NAME_SECONDS
