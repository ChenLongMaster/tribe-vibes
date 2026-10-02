class_name BuildingDefs
## Định nghĩa công trình bằng dữ liệu. Thêm công trình mới = thêm một mục ở đây,
## scene `buildings/building.tscn` tự đọc và dựng theo.
##
## - footprint: số ô chiếm (rộng, cao); ô gốc là ô trên-trái.
## - art: key hình trong ArtLibrary.
## - extra_art_frames: các khung hình phụ vẽ chồng lên và chạy lần lượt (vd ngọn lửa),
##   kèm extra_art_fps, extra_art_offset (lệch so với gốc), extra_art_sways (nghiêng theo gió).
## - fx_scene: scene hiệu ứng gắn kèm (vd tàn lửa), đặt lệch fx_offset so với gốc.
## - buildable: người chơi có xây được từ menu không.
## - food_storage: nơi cất thức ăn chung; dân đói đến đây ăn (lửa trại; Đợt 3 Bếp).
## - material_storage: nơi cất gỗ, đá (lửa trại; Đợt 3 Kho).
## - cook_station: giao người vào đây để nấu thức ăn thô thành món chín (lửa trại; Đợt 3 Bếp).
## - cook_seconds: thời gian nấu một món ở đây (cấp 1).
## - stock_capacity: đồ RIÊNG của công trình cất tối đa bao nhiêu ({món: số}) — vd món chín
##   ở bếp; Đợt 3 vũ khí ở lò rèn (cờ `tool_storage`).
## - stock_display: vẽ đồ riêng quanh công trình, mỗi món một chỗ: {món: {art, slots: [lệch]}}
##   — nhìn là biết còn bao nhiêu.

const DEFS: Dictionary[StringName, Dictionary] = {
	# Vách đá lớn: một phần của map, không khai thác được; thỉnh thoảng lăn ra đá tảng.
	&"cliff": {
		"name_key": "BUILDING_CLIFF_NAME",
		"footprint": Vector2i(3, 2),
		"art": "env/cliff",
		"buildable": false,
	},
	&"cave": {
		"name_key": "BUILDING_CAVE_NAME",
		"footprint": Vector2i(3, 2),
		"art": "buildings/cave",
		"buildable": false,
	},
	&"campfire": {
		"name_key": "BUILDING_CAMPFIRE_NAME",
		"footprint": Vector2i(1, 1),
		"art": "buildings/campfire",
		"extra_art_frames": [
			"buildings/campfire_flame_01", "buildings/campfire_flame_02",
			"buildings/campfire_flame_03", "buildings/campfire_flame_04",
		],
		"extra_art_fps": 8.0,
		"extra_art_offset": Vector2(0, -12),
		"extra_art_sways": true,
		# Kho + bếp tạm ban đầu: cất gỗ, đá, đồ ăn; dân đói đến đây ăn; nấu chậm.
		"food_storage": true,
		"material_storage": true,
		# Bếp tạm: nấu chậm hơn bếp thật.
		"cook_station": true,
		"cook_seconds": Balance.COOK_SECONDS_CAMPFIRE,
		"stock_capacity": {ResourceDefs.MEAL: Balance.CAMPFIRE_MEAL_CAPACITY},
		"stock_display": {
			ResourceDefs.MEAL: {
				"art": "icons/res_meal",
				"slots": [Vector2(-30, 4), Vector2(30, 4), Vector2(-20, 16), Vector2(20, 16)],
			},
		},
		"fx_scene": "res://fx/campfire_embers.tscn",
		"fx_offset": Vector2(0, -38),
		"buildable": false,
	},
}


static func get_def(id: StringName) -> Dictionary:
	if not DEFS.has(id):
		push_error("BuildingDefs: không có công trình '%s'" % id)
		return {}
	return DEFS[id]


static func footprint(id: StringName) -> Vector2i:
	return get_def(id).get("footprint", Vector2i.ONE)


## Các ô công trình chiếm khi đặt ô gốc (trên-trái) tại `origin`.
static func footprint_cells(id: StringName, origin: Vector2i) -> Array[Vector2i]:
	var size: Vector2i = footprint(id)
	var cells: Array[Vector2i] = []
	for y: int in size.y:
		for x: int in size.x:
			cells.append(origin + Vector2i(x, y))
	return cells
