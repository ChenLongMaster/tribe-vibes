extends Node
## Lớp bọc đa ngôn ngữ quanh TranslationServer. MỌI chữ người chơi nhìn thấy đi qua đây.
##
## Thêm ngôn ngữ mới = thêm một cột vào i18n/strings.csv (+ file tên trong data/names/),
## không phải sửa code. Ô nào bỏ trống sẽ tự dùng tiếng Việt thay thế.

signal language_changed(code: String)

const DEFAULT_LANGUAGE: String = "vi"
const SETTING_KEY: String = "language"
## Godot import CSV thành các file `strings.<mã>.translation` trong thư mục này.
const TRANSLATIONS_DIR: String = "res://i18n/"
const TRANSLATION_EXTENSION: String = ".translation"
## Key trong CSV chứa tên ngôn ngữ viết bằng chính ngôn ngữ đó ("Tiếng Việt", "English").
const LANGUAGE_NAME_KEY: StringName = &"UI_LANGUAGE_NAME"
const PLURAL_ONE_SUFFIX: String = "_ONE"
const PLURAL_OTHER_SUFFIX: String = "_OTHER"

const THOUSANDS_SEPARATORS: Dictionary[String, String] = {"vi": ".", "en": ","}
const DECIMAL_SEPARATORS: Dictionary[String, String] = {"vi": ",", "en": "."}
const FALLBACK_THOUSANDS_SEPARATOR: String = ","
const FALLBACK_DECIMAL_SEPARATOR: String = "."

var _language: String = DEFAULT_LANGUAGE
## Key thiếu hẳn (kể cả tiếng Việt) — chỉ cảnh báo một lần mỗi key cho đỡ rối log.
var _warned_keys: Dictionary[String, bool] = {}
var _translations: Array[Translation] = []


func _ready() -> void:
	_register_translations()
	_fill_missing_from_default()
	var saved: String = str(SaveSystem.get_setting(SETTING_KEY, DEFAULT_LANGUAGE))
	if not available_languages().has(saved):
		saved = DEFAULT_LANGUAGE
	_apply_language(saved)


## Dịch một key. `args` thay vào chỗ giữ chỗ có tên: "{name} chào đời!".
func t(key: String, args: Dictionary = {}) -> String:
	var text: String = String(TranslationServer.translate(key))
	if text == key and not _warned_keys.has(key):
		_warned_keys[key] = true
		push_warning("Loc: thiếu key '%s' trong i18n/strings.csv" % key)
	if args.is_empty():
		return text
	return text.format(args)


## Câu có số đếm: dùng `KEY_ONE` khi n == 1, ngược lại `KEY_OTHER`.
## Nếu `args` chưa có "n" thì tự thêm `n` đã định dạng theo ngôn ngữ.
func plural(key: String, n: int, args: Dictionary = {}) -> String:
	var full_args: Dictionary = args.duplicate()
	if not full_args.has("n"):
		full_args["n"] = number(n)
	var suffix: String = PLURAL_ONE_SUFFIX if n == 1 else PLURAL_OTHER_SUFFIX
	return t(key + suffix, full_args)


## Định dạng số theo ngôn ngữ hiện tại: vi "1.250,5" — en "1,250.5".
func number(value: float, decimals: int = 0) -> String:
	var thousands: String = THOUSANDS_SEPARATORS.get(_language, FALLBACK_THOUSANDS_SEPARATOR)
	var decimal: String = DECIMAL_SEPARATORS.get(_language, FALLBACK_DECIMAL_SEPARATOR)
	var fixed: String = ("%." + str(maxi(decimals, 0)) + "f") % absf(value)
	var parts: PackedStringArray = fixed.split(".")
	var int_part: String = parts[0]
	var grouped: String = ""
	var count: int = 0
	for i: int in range(int_part.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			grouped = thousands + grouped
		grouped = int_part[i] + grouped
		count += 1
	var result: String = grouped
	if parts.size() > 1:
		result += decimal + parts[1]
	# Không hiện "-0" khi số âm làm tròn về 0.
	if value < 0.0 and fixed.to_float() != 0.0:
		result = "-" + result
	return result


func get_language() -> String:
	return _language


## Đổi ngôn ngữ ngay lập tức. `persist = false` dùng cho test để không ghi đè setting.
func set_language(code: String, persist: bool = true) -> void:
	if not available_languages().has(code):
		push_warning("Loc: không có ngôn ngữ '%s'" % code)
		return
	_apply_language(code)
	if persist:
		SaveSystem.set_setting(SETTING_KEY, code)


## Các ngôn ngữ đang có (lấy từ các cột trong CSV), tiếng Việt luôn đứng đầu.
func available_languages() -> PackedStringArray:
	var result: PackedStringArray = [DEFAULT_LANGUAGE]
	var others: Array[String] = []
	for code: String in TranslationServer.get_loaded_locales():
		if code != DEFAULT_LANGUAGE and not others.has(code):
			others.append(code)
	others.sort()
	result.append_array(others)
	return result


## Tên ngôn ngữ viết bằng chính nó, để hiện trong menu chọn ngôn ngữ.
func language_display_name(code: String) -> String:
	var translation: Translation = _find_translation(code)
	if translation == null:
		return code
	var text: String = String(translation.get_message(LANGUAGE_NAME_KEY))
	return text if not text.is_empty() else code


func _apply_language(code: String) -> void:
	_language = code
	TranslationServer.set_locale(code)
	language_changed.emit(code)


# Ô trống hoặc thiếu ở ngôn ngữ khác thì chép chữ tiếng Việt sang, nên cả tr()
# lẫn chế độ tự dịch của Control đều không bao giờ hiện chữ rỗng.
func _fill_missing_from_default() -> void:
	var base: Translation = _find_translation(DEFAULT_LANGUAGE)
	if base == null:
		push_error("Loc: không tìm thấy bản dịch tiếng Việt — kiểm tra i18n/strings.csv")
		return
	var keys: PackedStringArray = base.get_message_list()
	for translation: Translation in _translations:
		if translation == base:
			continue
		var filled: int = 0
		for key: String in keys:
			if String(translation.get_message(key)).is_empty():
				translation.add_message(key, base.get_message(key))
				filled += 1
		if filled > 0 and OS.is_debug_build():
			print("[Loc] '%s' thiếu %d/%d câu, dùng tiếng Việt thay thế" % [translation.locale, filled, keys.size()])


func _find_translation(code: String) -> Translation:
	for translation: Translation in _translations:
		if translation.locale == code:
			return translation
	return null


# Nạp mọi file .translation trong i18n/ — thêm cột vào CSV là có ngôn ngữ mới, không
# cần khai báo thêm trong Project Settings. File nào đã khai báo thì ResourceLoader trả
# về đúng đối tượng TranslationServer đang dùng, add_translation lần nữa không bị trùng.
func _register_translations() -> void:
	_translations.clear()
	for file: String in DirAccess.get_files_at(TRANSLATIONS_DIR):
		# Bản xuất (export) có thể đổi tên thành ".remap".
		var path: String = TRANSLATIONS_DIR + file.trim_suffix(".remap")
		if not path.ends_with(TRANSLATION_EXTENSION):
			continue
		var translation: Translation = load(path) as Translation
		if translation != null and not _translations.has(translation):
			_translations.append(translation)
			TranslationServer.add_translation(translation)
