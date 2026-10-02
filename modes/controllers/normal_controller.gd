class_name NormalController
extends PlayerController
## Controller của chế độ Normal (Bộ Lạc). Diễn giải lệnh chung từ InputRouter:
## - Chạm thổ dân → chọn (mở bảng thông tin). Rê chuột / nhấn giữ → hiện tên.
## - Đang chọn mà chạm cây, đá, bụi quả, chỗ câu cá, thú, lửa trại → Commands.assign_job().
##   Chạm mặt đất trống → Commands.move_villager() (đi tới đó, đặt điểm neo mới).
##   Ra lệnh xong thì bỏ chọn — để lỡ chạm nhầm mặt đất không làm người đó bỏ việc.
## - Kéo từ một thổ dân rồi thả vào mục tiêu → như trên (kéo-thả giao việc).
## - Chạm chỗ không làm gì được / Esc / chuột phải / nút ✕ → bỏ chọn.
## - Space, phím 1–3 → tạm dừng / tốc độ.
## Mọi thay đổi thật đều đi qua Commands; phản hồi hình ảnh (đường chấm chấm, vòng mục
## tiêu, đường kéo) nằm ở CommandFeedback.

const LONG_PRESS_NAME_SECONDS: float = 2.0
const SPEED_ACTIONS: Dictionary[StringName, int] = {&"speed_1": 1, &"speed_2": 2, &"speed_3": 3}

var selected: Villager
var _hovered: Villager
var _long_press_shown: Villager
var _long_press_timer: float = 0.0
var _dragging: Villager
var _feedback: CommandFeedback


func _ready() -> void:
	# Vẫn nhận phím và ra lệnh khi đang tạm dừng (dừng lại để giao việc cho thong thả).
	process_mode = Node.PROCESS_MODE_ALWAYS
	InputRouter.tapped.connect(_on_tapped)
	InputRouter.hovered.connect(_on_hovered)
	InputRouter.long_pressed.connect(_on_long_pressed)
	InputRouter.cancel_requested.connect(_on_cancel)
	InputRouter.drag_assign_started.connect(_on_drag_started)
	InputRouter.drag_assign_moved.connect(_on_drag_moved)
	InputRouter.drag_assign_ended.connect(_on_drag_ended)
	EventBus.deselect_requested.connect(deselect)


func setup(owner_world: World, game_mode: GameModeConfig) -> void:
	super(owner_world, game_mode)
	_feedback = CommandFeedback.new()
	world.add_overlay(_feedback, true)
	if mode.allow_direct_commands:
		# Kéo bắt đầu từ một thổ dân thì là kéo-giao-việc, không phải kéo bản đồ.
		InputRouter.drag_picker = _pick_villager_node


func _exit_tree() -> void:
	if InputRouter.drag_picker == Callable(self, &"_pick_villager_node"):
		InputRouter.drag_picker = Callable()


func select(villager: Villager) -> void:
	if selected == villager:
		return
	if is_instance_valid(selected):
		selected.set_selected(false)
	selected = villager
	if selected != null:
		selected.set_selected(true)
		selected.rig.squash(-0.12)
	if _feedback != null:
		_feedback.set_selected(selected)
	EventBus.villager_selected.emit(selected)


func deselect() -> void:
	select(null)


func _process(delta: float) -> void:
	if _long_press_timer > 0.0:
		_long_press_timer -= delta
		if _long_press_timer <= 0.0 and is_instance_valid(_long_press_shown):
			_long_press_shown.set_hovered(false)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"toggle_pause"):
		Commands.toggle_pause()
		get_viewport().set_input_as_handled()
		return
	for action: StringName in SPEED_ACTIONS:
		if event.is_action_pressed(action):
			Commands.set_game_speed(SPEED_ACTIONS[action])
			get_viewport().set_input_as_handled()
			return


func _on_tapped(screen_pos: Vector2) -> void:
	var point: Vector2 = InputRouter.screen_to_world(screen_pos)
	var villager: Villager = _pick(screen_pos)
	if villager != null:
		select(villager)
		return
	if is_instance_valid(selected) and _command(selected, point):
		deselect()
		return
	deselect()


## Ra lệnh cho `villager` theo thứ dưới điểm `point`: giao việc hoặc đi tới. Trả về true
## nếu đã ra lệnh (kể cả khi thổ dân trả lời "Hết cây rồi!").
func _command(villager: Villager, point: Vector2) -> bool:
	if not mode.allow_direct_commands or not villager.data.is_adult():
		return false
	var target: Node2D = world.pick_job_target(point)
	if target != null:
		if Commands.assign_job(villager.id, target):
			_feedback.show_command(villager, target)
		return true
	var cell: Vector2i = WorldGrid.world_to_cell(point)
	if Commands.move_villager(villager.id, cell):
		_feedback.show_move(villager, cell)
		return true
	return false


func _on_hovered(screen_pos: Vector2) -> void:
	var villager: Villager = _pick(screen_pos)
	if villager != _hovered:
		if is_instance_valid(_hovered):
			_hovered.set_hovered(false)
		_hovered = villager
		if _hovered != null:
			_hovered.set_hovered(true)
	# Đang chọn một người thì sáng vòng dưới mục tiêu có thể giao việc.
	var target: Node2D = null
	if villager == null and is_instance_valid(selected):
		target = world.pick_job_target(InputRouter.screen_to_world(screen_pos))
	_feedback.set_hover_target(target)


func _on_long_pressed(screen_pos: Vector2) -> void:
	var villager: Villager = _pick(screen_pos)
	if villager == null:
		return
	villager.set_hovered(true)
	_long_press_shown = villager
	_long_press_timer = LONG_PRESS_NAME_SECONDS


func _on_cancel() -> void:
	if _dragging != null:
		_dragging = null
		_feedback.end_drag()
	deselect()


# --- Kéo-thả giao việc ---

func _on_drag_started(_screen_pos: Vector2, target: Node) -> void:
	_dragging = target as Villager
	if _dragging == null:
		return
	select(_dragging)
	_feedback.begin_drag(_dragging)


func _on_drag_moved(screen_pos: Vector2) -> void:
	if not is_instance_valid(_dragging):
		return
	var point: Vector2 = InputRouter.screen_to_world(screen_pos)
	_feedback.update_drag(point, world.pick_job_target(point))


func _on_drag_ended(screen_pos: Vector2) -> void:
	var villager: Villager = _dragging
	_dragging = null
	_feedback.end_drag()
	if not is_instance_valid(villager):
		return
	_command(villager, InputRouter.screen_to_world(screen_pos))
	deselect()


func _pick(screen_pos: Vector2) -> Villager:
	if world == null:
		return null
	return world.pick_villager(InputRouter.screen_to_world(screen_pos))


func _pick_villager_node(screen_pos: Vector2) -> Node:
	return _pick(screen_pos)
