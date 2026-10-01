extends Node
## Điểm vào game: tạo ván mới, dựng thế giới, giữ tiêu đề cửa sổ theo ngôn ngữ.

@onready var _world: World = $World


func _ready() -> void:
	Loc.language_changed.connect(_on_language_changed)
	_update_window_title()
	GameState.new_game()
	_world.build(GameState.world_seed)


func _unhandled_input(event: InputEvent) -> void:
	# Phím tắt chỉ dành cho lúc phát triển: đổi vòng qua các ngôn ngữ đang có.
	if OS.is_debug_build() and event.is_action_pressed("debug_toggle_language"):
		var languages: PackedStringArray = Loc.available_languages()
		var next: int = (languages.find(Loc.get_language()) + 1) % languages.size()
		Loc.set_language(languages[next])
		get_viewport().set_input_as_handled()


func _on_language_changed(_code: String) -> void:
	_update_window_title()


func _update_window_title() -> void:
	get_window().title = Loc.t("GAME_TITLE")
