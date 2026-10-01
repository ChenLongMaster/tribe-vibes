extends MarginContainer
## Bảng thông tin tạm cho lúc phát triển: tên game, câu thử font tiếng Việt, ngôn ngữ,
## seed, kiểu điều khiển. Chỉ hiện trong bản debug.
## Nhãn tĩnh dùng chế độ tự dịch của Control (text = key); nhãn có tham số thì
## dịch bằng Loc và vẽ lại khi đổi ngôn ngữ.

@onready var _language_label: Label = %LanguageLabel
@onready var _seed_label: Label = %SeedLabel
@onready var _input_label: Label = %InputLabel


func _ready() -> void:
	visible = OS.is_debug_build()
	Loc.language_changed.connect(_on_language_changed)
	InputRouter.input_mode_changed.connect(_on_input_mode_changed)
	EventBus.world_ready.connect(_on_world_ready)
	_refresh()


func _refresh() -> void:
	_language_label.text = Loc.t("UI_DEBUG_LANGUAGE", {"language": Loc.language_display_name(Loc.get_language())})
	_seed_label.text = Loc.t("UI_DEBUG_SEED", {"seed": Loc.number(GameState.world_seed)})
	var mode_key: String = "UI_INPUT_TOUCH" if InputRouter.mode == InputRouter.Mode.TOUCH else "UI_INPUT_MOUSE"
	_input_label.text = Loc.t("UI_DEBUG_INPUT_MODE", {"mode": Loc.t(mode_key)})


func _on_language_changed(_code: String) -> void:
	_refresh()


func _on_input_mode_changed(_mode: InputRouter.Mode) -> void:
	_refresh()


func _on_world_ready(_world: Node) -> void:
	_refresh()
