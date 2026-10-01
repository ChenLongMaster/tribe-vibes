extends TestCase
## Khung đa ngôn ngữ: fallback tiếng Việt, tham số, số nhiều, định dạng số.

const FONT_TEST_VI: String = "Thổ dân đói bụng quá! Ừ, ở đây ấm áp."


func test_title_in_both_languages() -> void:
	_with_language("vi", func() -> void:
		check_eq(Loc.t("GAME_TITLE"), "Bộ Lạc Chill", "Tên game tiếng Việt"))
	_with_language("en", func() -> void:
		check_eq(Loc.t("GAME_TITLE"), "Tribe Vibes", "Tên game tiếng Anh"))


func test_empty_english_falls_back_to_vietnamese() -> void:
	_with_language("en", func() -> void:
		check_eq(Loc.t("UI_DEBUG_FONT_TEST"), FONT_TEST_VI, "Loc.t ở en phải hiện chữ vi")
		# Chế độ tự dịch của Control cũng đi qua TranslationServer.
		check_eq(String(TranslationServer.translate("UI_DEBUG_FONT_TEST")), FONT_TEST_VI, "tr() ở en phải hiện chữ vi"))


func test_named_placeholders() -> void:
	_with_language("vi", func() -> void:
		check_eq(Loc.t("UI_DEBUG_SEED", {"seed": "42"}), "Seed bản đồ: 42", "Thay {seed}"))


func test_plural_picks_one_or_other() -> void:
	var vi: Translation = _translation("vi")
	vi.add_message("TEST_APPLE_ONE", "{n} quả táo (một)")
	vi.add_message("TEST_APPLE_OTHER", "{n} quả táo (nhiều)")
	_with_language("vi", func() -> void:
		check_eq(Loc.plural("TEST_APPLE", 1), "1 quả táo (một)", "n = 1 dùng _ONE")
		check_eq(Loc.plural("TEST_APPLE", 0), "0 quả táo (nhiều)", "n = 0 dùng _OTHER")
		check_eq(Loc.plural("TEST_APPLE", 1250), "1.250 quả táo (nhiều)", "n được định dạng theo ngôn ngữ")
		check_eq(Loc.plural("RES_WOOD_COUNT", 3), "3 gỗ", "Key thật trong CSV"))
	vi.erase_message("TEST_APPLE_ONE")
	vi.erase_message("TEST_APPLE_OTHER")


func test_number_format() -> void:
	_with_language("vi", func() -> void:
		check_eq(Loc.number(1250), "1.250", "vi: nghìn dùng dấu chấm")
		check_eq(Loc.number(999), "999", "vi: dưới nghìn")
		check_eq(Loc.number(1000000), "1.000.000", "vi: triệu")
		check_eq(Loc.number(-1250), "-1.250", "vi: số âm")
		check_eq(Loc.number(1234567.5, 1), "1.234.567,5", "vi: thập phân dùng dấu phẩy")
		check_eq(Loc.number(-0.4), "0", "vi: không hiện -0"))
	_with_language("en", func() -> void:
		check_eq(Loc.number(1250), "1,250", "en: nghìn dùng dấu phẩy")
		check_eq(Loc.number(1234567.5, 1), "1,234,567.5", "en: thập phân dùng dấu chấm"))


func test_available_languages() -> void:
	var languages: PackedStringArray = Loc.available_languages()
	check(languages.size() >= 2, "Phải có ít nhất vi và en")
	check_eq(languages[0], "vi", "Tiếng Việt đứng đầu")
	check(languages.has("en"), "Có tiếng Anh")
	check_eq(Loc.language_display_name("vi"), "Tiếng Việt", "Tên ngôn ngữ vi")
	check_eq(Loc.language_display_name("en"), "English", "Tên ngôn ngữ en")


func test_language_changed_signal() -> void:
	var received: Array[String] = []
	var listener: Callable = func(code: String) -> void: received.append(code)
	Loc.language_changed.connect(listener)
	_with_language("en", func() -> void: pass)
	Loc.language_changed.disconnect(listener)
	check(received.has("en"), "Đổi ngôn ngữ phải phát language_changed")


func test_csv_is_clean() -> void:
	var vi: Translation = _translation("vi")
	for key: String in vi.get_message_list():
		check(not key.begins_with("#"), "Dòng ghi chú '%s' bị nhập thành key" % key)
		check(not String(vi.get_message(key)).is_empty(), "Key '%s' thiếu chữ tiếng Việt" % key)


# Đổi ngôn ngữ tạm (không ghi vào setting), chạy `body`, rồi trả lại như cũ.
func _with_language(code: String, body: Callable) -> void:
	var previous: String = Loc.get_language()
	Loc.set_language(code, false)
	body.call()
	Loc.set_language(previous, false)


func _translation(code: String) -> Translation:
	return TranslationServer.get_translation_object(code)
