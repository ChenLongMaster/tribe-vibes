class_name NormalController
extends PlayerController
## Controller của chế độ Normal (Bộ Lạc). Diễn giải lệnh chung từ InputRouter.
##
## Chuột (kiểu Age of Empires):
## - Click trái: chọn thổ dân (giữ Shift để thêm / bớt), công trình (bảng công trình) hoặc vật
##   thể (bảng thông tin: cây, đá, bụi quả, thú…). Click chỗ trống = bỏ chọn. Click trái KHÔNG
##   bao giờ ra lệnh.
## - Kéo chuột trái: khung chọn nhiều thổ dân (Shift = thêm vào nhóm đang chọn).
## - Click phải: ra lệnh cho những người đang chọn — vào cây, đá, bụi, thú, công trình thì giao
##   việc (cả nhóm thì mỗi người một mục tiêu gần nhau), vào mặt đất thì đi tới (cả nhóm thì
##   đứng tản ra). Ra lệnh xong vẫn giữ chọn.
## - Đang chọn người mà rê chuột lên mục tiêu: con trỏ có icon nhún nhún cho biết sẽ làm gì
##   (bụi quả → đồ ăn, cây → rìu, đá → cuốc, móng → búa, mặt đất → cờ…).
## Cảm ứng (điện thoại không có chuột phải):
## - Chạm thổ dân → chọn. Đang chọn mà chạm mục tiêu / mặt đất → ra lệnh rồi bỏ chọn.
## - Kéo từ một thổ dân rồi thả vào mục tiêu → giao việc. Nhấn giữ rồi kéo → khung chọn.
## Chung:
## - Chọn công trình trong menu xây → chế độ đặt: bóng mờ đúng diện tích (xanh/đỏ); chuột: click
##   để đặt; cảm ứng: chạm để dời bóng, chạm lại đúng chỗ hoặc bấm ✓ để đặt. Esc / chuột phải /
##   ✕ để thôi.
## - Esc / nút ✕ → bỏ chọn. Space, phím 1–3 → tạm dừng / tốc độ.
## Mọi thay đổi thật đều đi qua Commands; phản hồi hình ảnh (đường chấm chấm, vòng mục tiêu,
## khung chọn, đường kéo, bóng mờ công trình) nằm ở CommandFeedback / PlacementGhost; icon con
## trỏ do HUD vẽ (nghe EventBus.command_cursor_changed).

const LONG_PRESS_NAME_SECONDS: float = 2.0
const SPEED_ACTIONS: Dictionary[StringName, int] = {&"speed_1": 1, &"speed_2": 2, &"speed_3": 3}
## Icon con trỏ khi rê lên mặt đất / chỗ không đi được.
const CURSOR_MOVE: String = "icons/move_feet"
const CURSOR_BLOCKED: String = "icons/cross"

## Những thổ dân đang chọn (thứ tự chọn).
var selection: Array[Villager] = []
## Người đang chọn khi chỉ chọn một người (null nếu không chọn ai hoặc chọn cả nhóm).
var selected: Villager:
	get:
		return selection[0] if selection.size() == 1 else null
var selected_building: Building
## Vật thể đang xem thông tin (ResourceNode / Animal).
var selected_object: Node2D
## Công trình đang chọn chỗ đặt (&"" = không đặt gì).
var placing: StringName = &""
var _hovered: Villager
var _long_press_shown: Villager
var _long_press_timer: float = 0.0
var _dragging: Villager
var _feedback: CommandFeedback
var _ghost: PlacementGhost
var _cursor_icon: String = ""


func _ready() -> void:
	# Vẫn nhận phím và ra lệnh khi đang tạm dừng (dừng lại để giao việc cho thong thả).
	process_mode = Node.PROCESS_MODE_ALWAYS
	InputRouter.tapped.connect(_on_tapped)
	InputRouter.secondary_tapped.connect(_on_secondary_tapped)
	InputRouter.hovered.connect(_on_hovered)
	InputRouter.long_pressed.connect(_on_long_pressed)
	InputRouter.cancel_requested.connect(_on_cancel)
	InputRouter.drag_assign_started.connect(_on_drag_started)
	InputRouter.drag_assign_moved.connect(_on_drag_moved)
	InputRouter.drag_assign_ended.connect(_on_drag_ended)
	InputRouter.box_select_started.connect(_on_box_started)
	InputRouter.box_select_moved.connect(_on_box_moved)
	InputRouter.box_select_ended.connect(_on_box_ended)
	InputRouter.input_mode_changed.connect(func(_mode: InputRouter.Mode) -> void: _set_cursor(""))
	EventBus.deselect_requested.connect(deselect)
	EventBus.villager_focus_requested.connect(func(villager: Node) -> void: select(villager as Villager))
	EventBus.placement_requested.connect(begin_placement)
	EventBus.placement_confirm_requested.connect(confirm_placement)
	EventBus.placement_cancel_requested.connect(cancel_placement)
	EventBus.building_removed.connect(_on_building_removed)


func setup(owner_world: World, game_mode: GameModeConfig) -> void:
	super(owner_world, game_mode)
	_feedback = CommandFeedback.new()
	world.add_overlay(_feedback, true)
	_ghost = PlacementGhost.new()
	world.add_overlay(_ghost, false)
	if mode.allow_direct_commands:
		# Cảm ứng: kéo bắt đầu từ một thổ dân thì là kéo-giao-việc, không phải kéo bản đồ.
		InputRouter.drag_picker = _pick_villager_node


func _exit_tree() -> void:
	if InputRouter.drag_picker == Callable(self, &"_pick_villager_node"):
		InputRouter.drag_picker = Callable()
	_set_cursor("")


# --- Chọn ---

## Chọn đúng một thổ dân (null = bỏ chọn hết thổ dân).
func select(villager: Villager) -> void:
	var list: Array[Villager] = []
	if villager != null:
		list.append(villager)
	set_selection(list)


## Chọn một nhóm thổ dân (chỉ người lớn mới nhận lệnh, nhưng vẫn chọn được để xem).
func set_selection(villagers: Array[Villager]) -> void:
	if not villagers.is_empty():
		select_building(null)
		select_object(null)
	if villagers == selection:
		return
	for old: Villager in selection:
		if is_instance_valid(old) and not villagers.has(old):
			old.set_selected(false)
	for villager: Villager in villagers:
		if not selection.has(villager):
			villager.set_selected(true)
			villager.rig.squash(-0.12)
	selection = villagers.duplicate()
	if _feedback != null:
		_feedback.set_selection(selection)
	if selection.is_empty():
		_set_cursor("")
	EventBus.villager_selected.emit(selected)
	EventBus.villagers_selected.emit(selection)


func deselect() -> void:
	select(null)
	select_building(null)
	select_object(null)


func select_building(building: Building) -> void:
	if selected_building == building:
		return
	if building != null:
		select(null)
		select_object(null)
	selected_building = building
	if _feedback != null:
		_feedback.set_selected_object(building)
	if building != null:
		building.selection_pulse()
	EventBus.building_selected.emit(building)


## Xem thông tin một vật thể (cây, đá, bụi, củi, chỗ câu cá, thú). null = đóng bảng.
func select_object(target: Node2D) -> void:
	if selected_object == target:
		return
	if target != null:
		select(null)
		select_building(null)
	selected_object = target
	if _feedback != null:
		_feedback.set_selected_object(target)
	EventBus.object_selected.emit(target)


# --- Đặt công trình ---

func begin_placement(building_id: StringName) -> void:
	if not mode.allow_direct_commands or not BuildingDefs.is_buildable(building_id):
		return
	deselect()
	placing = building_id
	_ghost.show_for(building_id)
	# Chưa biết ngón tay ở đâu: đặt sẵn bóng mờ giữa màn hình cho người chơi thấy.
	var center: Vector2 = InputRouter.screen_to_world(get_viewport().get_visible_rect().size * 0.5)
	_move_ghost(center)
	_emit_placement_state()


func confirm_placement() -> void:
	if placing == &"" or not _ghost.visible:
		return
	var origin: Vector2i = _ghost.origin
	if not Commands.can_place_building(placing, origin):
		_ghost.shake()
		return
	var uid: int = Commands.place_building(placing, origin)
	cancel_placement()
	if uid != Commands.INVALID_ID:
		select_building(Commands.get_building(uid))


func cancel_placement() -> void:
	if placing == &"":
		return
	placing = &""
	_ghost.hide_ghost()
	_emit_placement_state()


func _emit_placement_state() -> void:
	EventBus.placement_state_changed.emit(placing != &"", placing, InputRouter.mode == InputRouter.Mode.TOUCH)


# Bóng mờ canh giữa điểm chạm / con trỏ.
func _move_ghost(point: Vector2) -> void:
	var footprint: Vector2i = BuildingDefs.footprint(placing)
	var cell: Vector2i = WorldGrid.world_to_cell(point)
	var origin: Vector2i = cell - Vector2i(floori((footprint.x - 1) / 2.0), floori((footprint.y - 1) / 2.0))
	_ghost.set_origin(origin, Commands.can_place_building(placing, origin))


func _on_placement_tap(point: Vector2) -> void:
	var before: Vector2i = _ghost.origin
	var was_visible: bool = _ghost.visible
	_move_ghost(point)
	# Chuột: click là đặt luôn. Cảm ứng: chạm lần đầu để dời bóng, chạm lại đúng chỗ thì đặt.
	if InputRouter.mode == InputRouter.Mode.MOUSE or (was_visible and before == _ghost.origin):
		confirm_placement()


func _on_building_removed(building: Node) -> void:
	if building == selected_building:
		select_building(null)


# --- Phím ---

func _process(delta: float) -> void:
	if _long_press_timer > 0.0:
		_long_press_timer -= delta
		if _long_press_timer <= 0.0 and is_instance_valid(_long_press_shown):
			_long_press_shown.set_hovered(false)
	# Người đang chọn có thể biến mất khỏi tầm chọn (chui vào lều ngủ): bỏ khỏi nhóm.
	for villager: Villager in selection:
		if not is_instance_valid(villager) or not villager.visible:
			var kept: Array[Villager] = []
			for one: Villager in selection:
				if is_instance_valid(one) and one.visible:
					kept.append(one)
			set_selection(kept)
			break


func _unhandled_input(event: InputEvent) -> void:
	if OS.is_debug_build() and event.is_action_pressed(&"debug_toggle_dev"):
		Commands.toggle_dev_mode()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed(&"toggle_pause"):
		Commands.toggle_pause()
		get_viewport().set_input_as_handled()
		return
	for action: StringName in SPEED_ACTIONS:
		if event.is_action_pressed(action):
			Commands.set_game_speed(SPEED_ACTIONS[action])
			get_viewport().set_input_as_handled()
			return


# --- Chạm / click ---

func _on_tapped(screen_pos: Vector2) -> void:
	var point: Vector2 = InputRouter.screen_to_world(screen_pos)
	if placing != &"":
		_on_placement_tap(point)
		return
	var villager: Villager = _pick(screen_pos)
	if villager != null:
		if InputRouter.mode == InputRouter.Mode.MOUSE and InputRouter.is_additive():
			_toggle_in_selection(villager)
		else:
			select(villager)
		return
	# Cảm ứng không có chuột phải: đang chọn người mà chạm chỗ khác = ra lệnh.
	if InputRouter.mode == InputRouter.Mode.TOUCH and not selection.is_empty():
		_command_selection(point)
		deselect()
		return
	_select_under(point)


## Click phải (chuột): ra lệnh cho người đang chọn. Không chọn ai thì chỉ bỏ chọn bảng đang mở.
func _on_secondary_tapped(screen_pos: Vector2) -> void:
	if placing != &"":
		cancel_placement()
		return
	if selection.is_empty():
		deselect()
		return
	_command_selection(InputRouter.screen_to_world(screen_pos))


# Không chọn người: chạm công trình → bảng công trình; chạm vật thể → bảng thông tin (chạm lại
# lần nữa thì đóng); chạm chỗ trống → bỏ chọn.
func _select_under(point: Vector2) -> void:
	var target: Node2D = world.pick_job_target(point)
	if target is Building and target != selected_building:
		select_building(target as Building)
		return
	if target != null and not (target is Building) and target != selected_object:
		select_object(target)
		return
	deselect()


func _toggle_in_selection(villager: Villager) -> void:
	var list: Array[Villager] = selection.duplicate()
	if list.has(villager):
		list.erase(villager)
	else:
		list.append(villager)
	set_selection(list)


## Ra lệnh cho cả nhóm đang chọn theo thứ dưới điểm `point`: giao việc hoặc đi tới.
## Trả về true nếu đã ra lệnh cho ít nhất một người.
func _command_selection(point: Vector2) -> bool:
	var ids: Array[int] = []
	for villager: Villager in selection:
		if is_instance_valid(villager) and villager.data.is_adult():
			ids.append(villager.id)
	if not mode.allow_direct_commands or ids.is_empty():
		return false
	var target: Node2D = world.pick_job_target(point)
	if target != null:
		var given: int = Commands.assign_group(ids, target)
		for villager: Villager in selection:
			_feedback.show_command(villager, target)
		return given > 0
	var cell: Vector2i = WorldGrid.world_to_cell(point)
	var moved: int = Commands.move_group(ids, cell)
	if moved > 0:
		for villager: Villager in selection:
			_feedback.show_move(villager, cell)
	return moved > 0


## Ra lệnh cho một người (kéo-thả trên cảm ứng). Trả về true nếu đã ra lệnh.
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


# --- Rê chuột: tên, vòng mục tiêu, icon con trỏ ---

func _on_hovered(screen_pos: Vector2) -> void:
	var point: Vector2 = InputRouter.screen_to_world(screen_pos)
	if placing != &"":
		_move_ghost(point)
		return
	var villager: Villager = _pick(screen_pos)
	if villager != _hovered:
		if is_instance_valid(_hovered):
			_hovered.set_hovered(false)
		_hovered = villager
		if _hovered != null:
			_hovered.set_hovered(true)
	# Đang chọn người thì sáng vòng dưới mục tiêu và đổi icon con trỏ theo việc sẽ làm.
	var target: Node2D = null
	var icon: String = ""
	if villager == null and not selection.is_empty():
		target = world.pick_job_target(point)
		icon = command_icon(target, point)
	_feedback.set_hover_target(target)
	_set_cursor(icon)


## Icon con trỏ cho lệnh sẽ ra khi click phải vào `target` (hoặc mặt đất tại `point`).
func command_icon(target: Node2D, point: Vector2) -> String:
	if target == null:
		return CURSOR_BLOCKED if world.grid.is_blocked(WorldGrid.world_to_cell(point)) else CURSOR_MOVE
	var job_id: StringName = JobDefs.job_for_target(target)
	if job_id != &"":
		return JobDefs.cursor_icon(job_id)
	if target is Building:
		match (target as Building).action():
			BuildingDefs.ACTION_SLEEP:
				return "icons/sleepy"
			BuildingDefs.ACTION_DANCE:
				return "icons/happy"
	return CURSOR_MOVE


func _set_cursor(icon: String) -> void:
	if icon == _cursor_icon:
		return
	_cursor_icon = icon
	EventBus.command_cursor_changed.emit(icon)


func _on_long_pressed(screen_pos: Vector2) -> void:
	var villager: Villager = _pick(screen_pos)
	if villager == null:
		return
	villager.set_hovered(true)
	_long_press_shown = villager
	_long_press_timer = LONG_PRESS_NAME_SECONDS


func _on_cancel() -> void:
	if placing != &"":
		cancel_placement()
		return
	if _dragging != null:
		_dragging = null
		_feedback.end_drag()
	deselect()


# --- Khung chọn nhiều người ---

func _on_box_started(screen_pos: Vector2) -> void:
	var point: Vector2 = InputRouter.screen_to_world(screen_pos)
	_feedback.update_box(point, point)


func _on_box_moved(from_pos: Vector2, to_pos: Vector2) -> void:
	_feedback.update_box(InputRouter.screen_to_world(from_pos), InputRouter.screen_to_world(to_pos))


func _on_box_ended(from_pos: Vector2, to_pos: Vector2) -> void:
	_feedback.end_box()
	if placing != &"":
		return
	var a: Vector2 = InputRouter.screen_to_world(from_pos)
	var b: Vector2 = InputRouter.screen_to_world(to_pos)
	var rect: Rect2 = Rect2(a, Vector2.ZERO).expand(b)
	var picked: Array[Villager] = []
	if InputRouter.is_additive():
		picked = selection.duplicate()
	for villager: Villager in world.villagers:
		if villager.visible and not picked.has(villager) and rect.has_point(villager.position + Villager.PICK_CENTER * villager.scale):
			picked.append(villager)
	set_selection(picked)


# --- Kéo-thả giao việc (cảm ứng) ---

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
