class_name CliffRidge
extends RefCounted
## Một dãy vách đá = một cụm ô vách liền nhau, vẽ bằng code thành MỘT bức vách liền mạch
## (không ghép từng khối hình nên không có viền giữa các khối):
## - Mặt trên (nâng lên FACE_HEIGHT px) có mép đỉnh lởm chởm, rêu.
## - Mặt đứng quay về phía người nhìn (nam), có vân nứt dọc, tối dần xuống chân.
## - Đá vụn nhỏ dưới chân vách.
## Dãy được chia thành từng cột ô (mỗi cột một node trong lớp Entities) để y-sort đúng với
## thổ dân ở từng đoạn; các đường biên tính theo px trên toàn dãy nên các cột nối khít nhau.
## Mỗi cột ô vách chỉ có MỘT đoạn ô liền (hàng trên cùng → hàng dưới cùng) — MapGenerator
## đảm bảo điều đó.

const FACE_HEIGHT: float = 92.0 # px — chiều cao mặt đứng
## Mặt trên nhìn xiên nên co lại còn chừng này phần bề dày ô vách (vách trông dựng đứng, không
## thành cao nguyên).
const TOP_DEPTH_SCALE: float = 0.5
const BLEND: float = 24.0 # px — chỗ hai cột lệch hàng, đường biên uốn mượt trong chừng này px
const END_TAPER: float = 56.0 # px — hai đầu dãy thấp dần
const TOP_INSET: float = 6.0 # px — mép sau của mặt trên lùi vào trong ô
const PEAK_HEIGHT: float = 14.0 # px — mỏm đá lởm chởm trên đỉnh
const PEAK_SPACING: float = 14.0
const SAMPLE_STEP: float = 8.0
const CRACK_SPACING: float = 22.0
const RUBBLE_SPACING: float = 26.0
const MOSS_SPACING: float = 30.0
const DASH_SPACING: float = 16.0

const OUTLINE: Color = Color("#4E342E")
const TOP_LIGHT: Color = Color("#D2C9B6")
const TOP_DARK: Color = Color("#B2A790")
const FACE_LIGHT: Color = Color("#A39782")
const FACE_DARK: Color = Color("#766A59")
const CRACK: Color = Color("#5F5446")
const LIP_SHADE: Color = Color(0.2, 0.12, 0.08, 0.28)
const MOSS: Color = Color("#8DB04F")
const MOSS_DARK: Color = Color("#5E7F33")
const TOP_DASH: Color = Color("#A2967F")
const RUBBLE: Color = Color("#9E9E9E")

## x ô → Vector2i(hàng trên cùng, hàng dưới cùng).
var columns: Dictionary[int, Vector2i] = {}
var first_column: int = 1 << 30
var last_column: int = -(1 << 30)
var _seed: int = 0


## Gom các ô vách thành từng dãy (liền nhau theo 8 hướng).
static func group(cells: Array[Vector2i]) -> Array[CliffRidge]:
	var remaining: Dictionary[Vector2i, bool] = {}
	for cell: Vector2i in cells:
		remaining[cell] = true
	var ridges: Array[CliffRidge] = []
	for start: Vector2i in cells:
		if not remaining.has(start):
			continue
		remaining.erase(start)
		var ridge: CliffRidge = CliffRidge.new()
		ridge._seed = absi(start.x * 92821 + start.y * 68917)
		var stack: Array[Vector2i] = [start]
		while not stack.is_empty():
			var cell: Vector2i = stack.pop_back()
			ridge._add(cell)
			for offset: Vector2i in WorldGrid.NEIGHBORS_8:
				var next: Vector2i = cell + offset
				if remaining.has(next):
					remaining.erase(next)
					stack.append(next)
		ridges.append(ridge)
	return ridges


func _add(cell: Vector2i) -> void:
	if columns.has(cell.x):
		var span: Vector2i = columns[cell.x]
		columns[cell.x] = Vector2i(mini(span.x, cell.y), maxi(span.y, cell.y))
	else:
		columns[cell.x] = Vector2i(cell.y, cell.y)
	first_column = mini(first_column, cell.x)
	last_column = maxi(last_column, cell.x)


## Gốc (chân) node vẽ cột `column`: mép dưới hàng dưới cùng — để y-sort: ai đứng phía nam
## vách thì vẽ đè lên vách, ai đứng phía bắc thì bị vách che.
func slice_origin(column: int) -> Vector2:
	return Vector2((column + 0.5) * Balance.TILE_SIZE, (columns[column].y + 1) * Balance.TILE_SIZE)


# --- Đường biên theo px (toạ độ thế giới) ---

## Chân vách (mặt đất phía trước).
func base_y(px: float) -> float:
	return _blend(px, func(span: Vector2i) -> float: return (span.y + 1) * Balance.TILE_SIZE) + _value(px, 30.0, 11) * 3.0


## Mép sau của mặt trên khi chưa nâng (mặt đất phía sau).
func back_y(px: float) -> float:
	var depth: float = _blend(px, func(span: Vector2i) -> float: return (span.y - span.x + 1) * Balance.TILE_SIZE - TOP_INSET)
	return base_y(px) - depth * TOP_DEPTH_SCALE


## Chiều cao mặt đứng: hơi gợn, thấp dần ở hai đầu dãy.
func face_height(px: float) -> float:
	var x0: float = first_column * Balance.TILE_SIZE
	var x1: float = (last_column + 1) * Balance.TILE_SIZE
	var taper: float = lerpf(0.45, 1.0, smoothstep(0.0, END_TAPER, minf(px - x0, x1 - px)))
	return FACE_HEIGHT * taper * (0.88 + 0.24 * _value(px, 48.0, 3))


## Mép trước của mặt trên (chỗ mặt trên gặp mặt đứng).
func lip_y(px: float) -> float:
	return base_y(px) - face_height(px) + _jag(px, 9.0, 21) * 4.0


## Mép đỉnh (mép sau của mặt trên, đã nâng) — lởm chởm.
func top_y(px: float) -> float:
	return back_y(px) - face_height(px) - _jag(px, PEAK_SPACING, 7) * PEAK_HEIGHT


func x_range() -> Vector2:
	return Vector2(first_column * Balance.TILE_SIZE, (last_column + 1) * Balance.TILE_SIZE)


# --- Vẽ ---

## Vẽ phần dãy nằm trong cột `column` lên `canvas` (node có gốc ở slice_origin(column)).
func draw_slice(canvas: CanvasItem, column: int) -> void:
	var origin: Vector2 = slice_origin(column)
	var x0: float = column * Balance.TILE_SIZE
	var x1: float = x0 + Balance.TILE_SIZE
	var xs: PackedFloat32Array = PackedFloat32Array()
	var x: float = x0
	while x < x1 + 0.1:
		xs.append(x)
		x += SAMPLE_STEP
	var tops: PackedVector2Array = PackedVector2Array()
	var lips: PackedVector2Array = PackedVector2Array()
	var bases: PackedVector2Array = PackedVector2Array()
	for px: float in xs:
		var base: float = base_y(px)
		var lip: float = minf(lip_y(px), base - 10.0)
		tops.append(Vector2(px, minf(top_y(px), lip - 8.0)) - origin)
		lips.append(Vector2(px, lip) - origin)
		bases.append(Vector2(px, base) - origin)

	# Mặt trên: sáng ở mép đỉnh, tối dần về mép trước.
	_fill_band(canvas, tops, lips, TOP_LIGHT, TOP_DARK)
	_draw_moss(canvas, x0, x1, origin)
	# Mặt đứng: tối dần xuống chân.
	_fill_band(canvas, lips, bases, FACE_LIGHT, FACE_DARK)
	_draw_cracks(canvas, x0, x1, origin)
	var shade: PackedVector2Array = PackedVector2Array()
	for point: Vector2 in lips:
		shade.append(point + Vector2(0, 4))
	canvas.draw_polyline(shade, LIP_SHADE, 6.0, true)
	# Viền chỉ ở mép ngoài: đỉnh, mép trước, chân, và hai đầu dãy.
	canvas.draw_polyline(tops, OUTLINE, 3.0, true)
	canvas.draw_polyline(lips, OUTLINE, 2.5, true)
	canvas.draw_polyline(bases, OUTLINE, 3.0, true)
	if column == first_column:
		canvas.draw_line(tops[0], bases[0], OUTLINE, 3.0, true)
	if column == last_column:
		canvas.draw_line(tops[tops.size() - 1], bases[bases.size() - 1], OUTLINE, 3.0, true)
	_draw_rubble(canvas, x0, x1, origin)


## Bóng của cả dãy trên mặt đất (toạ độ thế giới): điểm cao h dời đi h * shadow_vec (như
## shader bóng của vật khác). Quét mặt trên theo chiều cao: với mỗi x lấy khoảng y bị che.
func draw_shadow(canvas: CanvasItem, shadow_vec: Vector2, color: Color) -> void:
	var span: Vector2 = x_range()
	var reach: float = shadow_vec.x * FACE_HEIGHT
	var x: float = floorf(minf(span.x, span.x + reach) / SAMPLE_STEP) * SAMPLE_STEP
	var x_end: float = maxf(span.y, span.y + reach)
	var upper: PackedVector2Array = PackedVector2Array()
	var lower: PackedVector2Array = PackedVector2Array()
	const STEPS: int = 10
	while x <= x_end + 0.1:
		var low: float = INF
		var high: float = -INF
		for k: int in STEPS + 1:
			var t: float = float(k) / STEPS
			var source: float = x - t * reach
			if source < span.x or source > span.y or t * FACE_HEIGHT > face_height(source) + 0.1:
				continue
			var shift: float = t * FACE_HEIGHT * shadow_vec.y
			low = minf(low, back_y(source) + shift)
			high = maxf(high, base_y(source) + shift)
		if high > low + 0.5:
			upper.append(Vector2(x, low))
			lower.append(Vector2(x, high))
		x += SAMPLE_STEP
	if upper.size() < 2:
		return
	lower.reverse()
	var polygon: PackedVector2Array = upper + lower
	canvas.draw_colored_polygon(polygon, color)


func _fill_band(canvas: CanvasItem, upper: PackedVector2Array, lower: PackedVector2Array, top_color: Color,
		bottom_color: Color) -> void:
	var points: PackedVector2Array = PackedVector2Array()
	var colors: PackedColorArray = PackedColorArray()
	for point: Vector2 in upper:
		points.append(point)
		colors.append(top_color)
	for i: int in range(lower.size() - 1, -1, -1):
		points.append(lower[i])
		colors.append(bottom_color)
	canvas.draw_polygon(points, colors)


# Vân nứt dọc trên mặt đứng — mỗi vết thuộc về đúng một cột (theo vị trí gốc) để không vẽ trùng.
func _draw_cracks(canvas: CanvasItem, x0: float, x1: float, origin: Vector2) -> void:
	var span: Vector2 = x_range()
	for index: int in range(floori(x0 / CRACK_SPACING), ceili(x1 / CRACK_SPACING) + 1):
		var x: float = (index + 0.2 + _hash01(index, 31) * 0.6) * CRACK_SPACING
		if x < x0 or x >= x1 or x < span.x + 8.0 or x > span.y - 8.0:
			continue
		var top: float = lip_y(x) + 7.0 + _hash01(index, 32) * 6.0
		var bottom: float = base_y(x) - 5.0 - _hash01(index, 33) * 14.0
		if bottom - top < 10.0:
			continue
		var slant: float = (_hash01(index, 34) - 0.5) * 8.0
		var mid: Vector2 = Vector2(x + slant * 0.3 + (_hash01(index, 35) - 0.5) * 5.0, (top + bottom) * 0.5)
		canvas.draw_polyline(PackedVector2Array([Vector2(x, top) - origin, mid - origin,
				Vector2(x + slant, bottom) - origin]), CRACK, 2.0, true)


# Mặt trên: vài vệt đá ngắn và vài búi rêu nhỏ bám sát mép đỉnh.
func _draw_moss(canvas: CanvasItem, x0: float, x1: float, origin: Vector2) -> void:
	var span: Vector2 = x_range()
	for index: int in range(floori(x0 / DASH_SPACING), ceili(x1 / DASH_SPACING) + 1):
		var x: float = (index + _hash01(index, 45)) * DASH_SPACING
		if _hash01(index, 46) > 0.5 or x < x0 or x >= x1 or x < span.x + 10.0 or x > span.y - 14.0:
			continue
		var y: float = lerpf(top_y(x) + 8.0, lip_y(x) - 6.0, _hash01(index, 47))
		var length: float = 6.0 + _hash01(index, 48) * 8.0
		canvas.draw_line(Vector2(x, y) - origin, Vector2(x + length, y + 1.0) - origin, TOP_DASH, 2.0, true)
	for index: int in range(floori(x0 / MOSS_SPACING), ceili(x1 / MOSS_SPACING) + 1):
		if _hash01(index, 41) > 0.4:
			continue
		var x: float = (index + _hash01(index, 42)) * MOSS_SPACING
		if x < x0 or x >= x1 or x < span.x + 12.0 or x > span.y - 12.0:
			continue
		var y: float = top_y(x) + 5.0
		for k: int in 3:
			var center: Vector2 = Vector2(x + (k - 1) * 4.5, y + absf(k - 1) * 1.5) - origin
			var radius: float = 3.0 + _hash01(index * 3 + k, 44) * 1.5
			canvas.draw_circle(center, radius + 1.2, MOSS_DARK, true, -1.0, true)
			canvas.draw_circle(center + Vector2(-0.4, -0.6), radius, MOSS, true, -1.0, true)


# Đá vụn nhỏ nằm sát chân vách (chỉ phía trước).
func _draw_rubble(canvas: CanvasItem, x0: float, x1: float, origin: Vector2) -> void:
	var span: Vector2 = x_range()
	for index: int in range(floori(x0 / RUBBLE_SPACING), ceili(x1 / RUBBLE_SPACING) + 1):
		if _hash01(index, 51) > 0.55:
			continue
		var x: float = (index + _hash01(index, 52)) * RUBBLE_SPACING
		if x < x0 or x >= x1 or x < span.x + 4.0 or x > span.y - 4.0:
			continue
		var radius: float = 3.0 + _hash01(index, 53) * 3.0
		var center: Vector2 = Vector2(x, base_y(x) + radius * 0.4) - origin
		canvas.draw_circle(center, radius + 2.0, OUTLINE, true, -1.0, true)
		canvas.draw_circle(center, radius, RUBBLE, true, -1.0, true)


# --- Nhiễu tất định (cùng dãy luôn vẽ giống nhau, không dùng RNG toàn cục) ---

func _blend(px: float, value_of: Callable) -> float:
	var column: int = clampi(floori(px / Balance.TILE_SIZE), first_column, last_column)
	while not columns.has(column) and column > first_column:
		column -= 1
	var here: float = value_of.call(columns[column])
	var local: float = px - column * Balance.TILE_SIZE
	if local < BLEND and columns.has(column - 1):
		return lerpf(value_of.call(columns[column - 1]), here, smoothstep(-BLEND, BLEND, local))
	if local > Balance.TILE_SIZE - BLEND and columns.has(column + 1):
		return lerpf(here, value_of.call(columns[column + 1]), smoothstep(-BLEND, BLEND, local - Balance.TILE_SIZE))
	return here


## Nhiễu mượt 0..1 theo px.
func _value(px: float, scale: float, salt: int) -> float:
	var index: int = floori(px / scale)
	return lerpf(_hash01(index, salt), _hash01(index + 1, salt), smoothstep(0.0, 1.0, px / scale - index))


## Nhiễu gãy khúc 0..1 (nối thẳng giữa các điểm) — cho mép đá lởm chởm.
func _jag(px: float, spacing: float, salt: int) -> float:
	var index: int = floori(px / spacing)
	return lerpf(_hash01(index, salt), _hash01(index + 1, salt), px / spacing - index)


func _hash01(index: int, salt: int) -> float:
	var h: int = (index * 374761393 + (_seed + salt) * 668265263) & 0x7fffffff
	h = ((h ^ (h >> 13)) * 1274126177) & 0x7fffffff
	h = h ^ (h >> 16)
	return float(h % 10007) / 10007.0
