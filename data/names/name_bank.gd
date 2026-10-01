class_name NameBank
## Chọn tên thổ dân theo ngôn ngữ. Thêm ngôn ngữ = thêm file `names_<mã>.gd`
## có hằng NAMES, không phải sửa code. Thiếu file thì dùng bộ tên tiếng Việt.

const NAMES_PATH_FORMAT: String = "res://data/names/names_%s.gd"
const FALLBACK_LANGUAGE: String = "vi"


static func names_for(language: String) -> PackedStringArray:
	var names: PackedStringArray = _load_names(language)
	if names.is_empty() and language != FALLBACK_LANGUAGE:
		names = _load_names(FALLBACK_LANGUAGE)
	return names


## Chọn một tên chưa ai dùng nếu còn; hết tên thì cho trùng (vẫn hơn là lỗi).
static func pick(rng: RandomNumberGenerator, language: String, taken: PackedStringArray = []) -> String:
	var names: PackedStringArray = names_for(language)
	if names.is_empty():
		return "?"
	var free: PackedStringArray = []
	for candidate: String in names:
		if not taken.has(candidate):
			free.append(candidate)
	var pool: PackedStringArray = free if not free.is_empty() else names
	return pool[rng.randi_range(0, pool.size() - 1)]


static func _load_names(language: String) -> PackedStringArray:
	var path: String = NAMES_PATH_FORMAT % language
	if not ResourceLoader.exists(path):
		return PackedStringArray()
	var script: GDScript = load(path) as GDScript
	if script == null:
		return PackedStringArray()
	return script.get_script_constant_map().get("NAMES", PackedStringArray())
