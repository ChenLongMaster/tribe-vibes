extends Node
## Đọc/ghi dữ liệu xuống máy người chơi.
## - Ván chơi: JSON (`user://save.json`), dễ đọc khi gỡ lỗi.
## - Setting (ngôn ngữ, âm lượng…): ConfigFile riêng, không mất khi xoá save.

const SAVE_PATH: String = "user://save.json"
const SETTINGS_PATH: String = "user://settings.cfg"
const SETTINGS_SECTION: String = "settings"
## Tăng số này mỗi khi đổi cấu trúc save, để còn chuyển đổi save cũ.
const SAVE_VERSION: int = 2

## Đường dẫn file ván chơi — test đổi sang file khác để không đè lên ván thật.
var save_path: String = SAVE_PATH
## Ván vừa đọc để main dựng lại cảnh từ đó (dùng một lần rồi xoá).
var pending_load: Dictionary = {}

var _settings: ConfigFile


func get_setting(key: String, default_value: Variant) -> Variant:
	return _get_settings().get_value(SETTINGS_SECTION, key, default_value)


func set_setting(key: String, value: Variant) -> void:
	var settings: ConfigFile = _get_settings()
	settings.set_value(SETTINGS_SECTION, key, value)
	var err: Error = settings.save(SETTINGS_PATH)
	if err != OK:
		push_warning("SaveSystem: không lưu được setting (%s)" % error_string(err))


func has_save() -> bool:
	return FileAccess.file_exists(save_path)


## Ghi một ván chơi. `data` chỉ chứa kiểu JSON được (số, chữ, mảng, dictionary).
func write_save(data: Dictionary) -> bool:
	var payload: Dictionary = data.duplicate()
	payload["version"] = SAVE_VERSION
	var file: FileAccess = FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		push_warning("SaveSystem: không mở được file save (%s)" % error_string(FileAccess.get_open_error()))
		return false
	file.store_string(JSON.stringify(payload, "\t"))
	return true


## Đọc ván chơi. Trả về {} nếu chưa có hoặc file hỏng (game coi như chơi mới).
func read_save() -> Dictionary:
	if not has_save():
		return {}
	var text: String = FileAccess.get_file_as_string(save_path)
	var parsed: Variant = JSON.parse_string(text)
	if not parsed is Dictionary:
		push_warning("SaveSystem: file save hỏng, bỏ qua")
		return {}
	return parsed


# Đọc file setting lần đầu khi cần, nên autoload nào gọi trước cũng được.
func _get_settings() -> ConfigFile:
	if _settings == null:
		_settings = ConfigFile.new()
		if FileAccess.file_exists(SETTINGS_PATH):
			_settings.load(SETTINGS_PATH)
	return _settings
