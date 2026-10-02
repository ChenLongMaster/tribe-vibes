extends Node
## Điểm vào game. Nạp một chế độ chơi (GameModeConfig) rồi dựng theo đó: thế giới,
## controller của chế độ, HUD của chế độ. Màn hình bắt đầu (Đợt 6) chỉ việc gọi
## start_game() với chế độ người chơi chọn — MVP tự chọn chế độ Normal.
## Thử chế độ khác từ dòng lệnh: `godot --path . -- --mode=res://modes/normal_mode.tres`

const DEFAULT_MODE: GameModeConfig = preload("res://modes/normal_mode.tres")
const MODE_ARG_PREFIX: String = "--mode="

var _controller: PlayerController
var _hud: Control

@onready var _world: World = $World
@onready var _ui: CanvasLayer = $UI


func _ready() -> void:
	Loc.language_changed.connect(_on_language_changed)
	EventBus.day_changed.connect(_on_day_changed)
	EventBus.load_requested.connect(_on_load_requested)
	_update_window_title()
	# Vừa bấm "Tải": dựng lại cảnh từ ván đã đọc.
	var save: Dictionary = SaveSystem.pending_load
	SaveSystem.pending_load = {}
	start_game(_mode_from_command_line(), save)


## `save` = ván đã lưu để dựng lại (trống = ván mới).
func start_game(mode: GameModeConfig, save: Dictionary = {}) -> void:
	GameState.new_game(mode)
	if not save.is_empty():
		GameState.apply_dict(save.get("game", {}))
	_world.build(GameState.world_seed)
	if not save.is_empty():
		SaveGame.restore(_world, save)
	_controller = mode.controller_scene.instantiate() as PlayerController
	add_child(_controller)
	_controller.setup(_world, mode)
	_hud = mode.hud_scene.instantiate() as Control
	_ui.add_child(_hud)
	# HUD nằm dưới cùng lớp UI, để bảng thông tin dùng chung đè lên trên.
	_ui.move_child(_hud, 0)
	if mode.starts_with_tribe and save.is_empty():
		_world.start_intro()


func get_controller() -> PlayerController:
	return _controller


func get_hud() -> Control:
	return _hud


func _unhandled_input(event: InputEvent) -> void:
	# Phím tắt chỉ dành cho lúc phát triển: đổi vòng qua các ngôn ngữ đang có.
	if OS.is_debug_build() and event.is_action_pressed("debug_toggle_language"):
		var languages: PackedStringArray = Loc.available_languages()
		var next: int = (languages.find(Loc.get_language()) + 1) % languages.size()
		Loc.set_language(languages[next])
		get_viewport().set_input_as_handled()


func _mode_from_command_line() -> GameModeConfig:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with(MODE_ARG_PREFIX):
			var mode: GameModeConfig = load(arg.trim_prefix(MODE_ARG_PREFIX)) as GameModeConfig
			if mode != null:
				return mode
			push_warning("Không đọc được chế độ '%s', dùng chế độ Normal" % arg)
	return DEFAULT_MODE


# Tự lưu mỗi khi sang ngày mới.
func _on_day_changed(_day: int) -> void:
	Commands.save_game(true)


# Tải ván đã lưu: đọc file rồi dựng lại cả cảnh (dọn sạch thế giới cũ, không sót tham chiếu).
func _on_load_requested() -> void:
	var save: Dictionary = SaveSystem.read_save()
	if save.is_empty():
		return
	SaveSystem.pending_load = save
	Engine.time_scale = 1.0
	get_tree().paused = false
	get_tree().reload_current_scene.call_deferred()


func _on_language_changed(_code: String) -> void:
	_update_window_title()


func _update_window_title() -> void:
	get_window().title = Loc.t("GAME_TITLE")
