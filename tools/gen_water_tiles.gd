extends SceneTree
## Sinh 15 hình nước dual-grid (SVG) vào assets/placeholder/water/.
## Chạy lại khi muốn đổi màu/độ bo của bờ hồ:
##   godot --headless --path . -s res://tools/gen_water_tiles.gd
##
## Mỗi hình 128×128 (2×), tâm hình = góc chung của 4 ô lưới. Bit trong tên file:
## trên-trái 1, trên-phải 2, dưới-trái 4, dưới-phải 8 (ô nào có nước).
## Chỉ cần vẽ 5 dạng gốc, các dạng còn lại là dạng gốc xoay 90°.

const OUT_DIR: String = "res://assets/placeholder/water/"
const SAND_COLOR: String = "#E8D5A8"
const SHALLOW_COLOR: String = "#81D4FA"
const WATER_COLOR: String = "#4FC3F7"
const OUTLINE_COLOR: String = "#4E342E"

## Dạng gốc: mask → {outer: viền ngoài mặt nước, inner: phần nước sâu, shore: đường bờ}.
## Góc bo là cung tròn bán kính nửa ô, tâm ở tâm ô lưới: một ô nước lẻ thành vũng
## tròn, bờ "bậc thang" thành đường cong mềm. (35.35 ≈ 64 × 0.5523 — hệ số vẽ cung tròn bằng Bézier.)
const SHAPES: Dictionary[int, Dictionary] = {
	# Một góc (trên-trái): góc lồi = 1/4 hình tròn quanh tâm ô trên-trái.
	1: {
		"outer": "M0 0 H64 C64 35.35 35.35 64 0 64 Z",
		"inner": "M0 0 H56 C56 30.93 30.93 56 0 56 Z",
		"shore": ["M64 0 C64 35.35 35.35 64 0 64"],
	},
	# Nửa trên: bờ thẳng.
	3: {
		"outer": "M0 0 H128 V64 H0 Z",
		"inner": "M0 0 H128 V56 H0 Z",
		"shore": ["M0 64 H128"],
	},
	# Hai góc chéo (trên-trái + dưới-phải).
	9: {
		"outer": "M0 0 H64 C64 35.35 35.35 64 0 64 Z M128 128 H64 C64 92.65 92.65 64 128 64 Z",
		"inner": "M0 0 H56 C56 30.93 30.93 56 0 56 Z M128 128 H72 C72 97.07 97.07 72 128 72 Z",
		"shore": ["M64 0 C64 35.35 35.35 64 0 64", "M64 128 C64 92.65 92.65 64 128 64"],
	},
	# Ba góc (thiếu dưới-phải): góc lõm = đất ở ô dưới-phải thành 1/4 hình tròn.
	7: {
		"outer": "M0 0 H128 V64 C92.65 64 64 92.65 64 128 H0 Z",
		"inner": "M0 0 H128 V56 C88.23 56 56 88.23 56 128 H0 Z",
		"shore": ["M128 64 C92.65 64 64 92.65 64 128"],
	},
	# Toàn nước.
	15: {
		"outer": "M0 0 H128 V128 H0 Z",
		"inner": "M0 0 H128 V128 H0 Z",
		"shore": [],
	},
}


func _init() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	for mask: int in range(1, 16):
		var path: String = OUT_DIR + "water_%02d.svg" % mask
		var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
		file.store_string(_build_svg(mask))
		file.close()
	print("Đã sinh 15 hình nước vào ", OUT_DIR)
	quit()


func _build_svg(mask: int) -> String:
	var base: int = 0
	var turns: int = 0
	for candidate: int in SHAPES:
		var rotated: int = candidate
		for k: int in 4:
			if rotated == mask:
				base = candidate
				turns = k
				break
			rotated = _rotate_cw(rotated)
		if base != 0:
			break
	var shape: Dictionary = SHAPES[base]
	var lines: PackedStringArray = []
	lines.append('<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128">')
	lines.append('  <g transform="rotate(%d 64 64)">' % (turns * 90))
	for shore: String in shape["shore"]:
		lines.append('    <path d="%s" fill="none" stroke="%s" stroke-width="24"/>' % [shore, SAND_COLOR])
	lines.append('    <path d="%s" fill="%s"/>' % [shape["outer"], SHALLOW_COLOR])
	lines.append('    <path d="%s" fill="%s"/>' % [shape["inner"], WATER_COLOR])
	# Không vẽ gợn sóng cố định: vẽ vào ô sẽ lặp thành lưới. Gợn sóng động do WaterLife
	# và shader water_shimmer lo.
	for shore: String in shape["shore"]:
		lines.append('    <path d="%s" fill="none" stroke="%s" stroke-width="5" stroke-opacity="0.8"/>' % [shore, OUTLINE_COLOR])
	lines.append('  </g>')
	lines.append('</svg>')
	return "\n".join(lines) + "\n"


# Xoay 90° theo chiều kim đồng hồ: trên-trái → trên-phải → dưới-phải → dưới-trái.
func _rotate_cw(mask: int) -> int:
	var result: int = 0
	if mask & 1:
		result |= 2
	if mask & 2:
		result |= 8
	if mask & 8:
		result |= 4
	if mask & 4:
		result |= 1
	return result
