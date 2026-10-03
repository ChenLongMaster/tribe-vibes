extends Node
## Vẽ sơ đồ toàn map (mỗi ô vài điểm ảnh màu) ra file PNG để soi nhanh cách sinh map, không
## cần mở game:
##   godot --headless --path . res://tools/map_preview.tscn -- --seed=42 --out=C:/thu_muc/map.png
## Màu: cỏ xanh, nước lam, cây xanh đậm, đá tảng xám, vách đá nâu xám, bụi quả đỏ, chỗ câu cá
## vàng, bãi sỏi xám nhạt, đống củi nâu nhạt, đồng cỏ xanh nhạt, hang + lửa trại cam.

const PIXELS_PER_CELL: int = 6
const COLORS: Dictionary[StringName, Color] = {
	&"grass": Color("#8BC34A"),
	&"meadow": Color("#C5E1A5"),
	&"water": Color("#4FC3F7"),
	&"tree": Color("#2E7D32"),
	&"rock": Color("#9E9E9E"),
	&"cliff": Color("#5D4037"),
	&"bush": Color("#E53935"),
	&"fish_spot": Color("#FFEB3B"),
	&"pebbles": Color("#E0E0E0"),
	&"twigs": Color("#A1887F"),
	&"building": Color("#FF9800"),
}


func _ready() -> void:
	var seed_value: int = 42
	var out: String = "user://map_preview.png"
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--seed="):
			seed_value = arg.trim_prefix("--seed=").to_int()
		elif arg.begins_with("--out="):
			out = arg.trim_prefix("--out=")
	var data: MapData = MapGenerator.new().generate(seed_value)
	var image: Image = Image.create(data.size.x * PIXELS_PER_CELL, data.size.y * PIXELS_PER_CELL, false, Image.FORMAT_RGB8)
	for y: int in data.size.y:
		for x: int in data.size.x:
			var cell: Vector2i = Vector2i(x, y)
			var key: StringName = &"water" if data.is_water(cell) else (&"meadow" if data.meadow_rect.has_point(cell) else &"grass")
			_fill(image, cell, COLORS[key])
	for cell: Vector2i in data.cliffs:
		_fill(image, cell, COLORS[&"cliff"])
	for building: Dictionary in data.buildings:
		for cell: Vector2i in BuildingDefs.footprint_cells(building["id"], building["cell"]):
			_fill(image, cell, COLORS[&"building"])
	for object: Dictionary in data.objects:
		_fill(image, object["cell"], COLORS.get(object["kind"], Color.MAGENTA))
	image.save_png(out)
	print("Đã lưu ", out, " (", data.objects_of_kind(MapData.KIND_TREE).size(), " cây, ",
		data.objects_of_kind(MapData.KIND_ROCK).size(), " đá tảng, ", data.objects_of_kind(MapData.KIND_BUSH).size(),
		" bụi quả, ", data.cliffs.size(), " ô vách đá)")
	get_tree().quit()


func _fill(image: Image, cell: Vector2i, color: Color) -> void:
	image.fill_rect(Rect2i(cell * PIXELS_PER_CELL, Vector2i(PIXELS_PER_CELL, PIXELS_PER_CELL)), color)
