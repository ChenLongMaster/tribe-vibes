class_name ArtSpecs
## Điểm neo (pivot) của từng hình — phải khớp với bảng trong ASSET_SPEC.md.
## Pivot tính theo tỉ lệ ảnh: (0.5, 1.0) = giữa mép dưới, (0.5, 0.5) = tâm ảnh.
## Đặt theo tỉ lệ nên art thật có kích thước hơi khác vẫn neo đúng chỗ.

const DEFAULT_PIVOT: Vector2 = Vector2(0.5, 1.0)

const PIVOTS: Dictionary[String, Vector2] = {
	"ground/dirt_patch_01": Vector2(0.5, 0.5),
	"ground/dirt_patch_02": Vector2(0.5, 0.5),
	"ground/grass_patch_01": Vector2(0.5, 0.5),
	"ground/grass_patch_02": Vector2(0.5, 0.5),
	"env/tree_01": Vector2(0.5, 0.92),
	"env/tree_02": Vector2(0.5, 0.93),
	"env/tree_stump": Vector2(0.5, 0.8),
	"env/rock_big": Vector2(0.5, 0.88),
	"env/rock_small": Vector2(0.5, 0.86),
	"env/bush_berries": Vector2(0.5, 0.9),
	"env/bush_empty": Vector2(0.5, 0.9),
	"env/flower_01": Vector2(0.5, 0.95),
	"env/flower_02": Vector2(0.5, 0.95),
	"env/flower_03": Vector2(0.5, 0.95),
	"env/grass_tuft_01": Vector2(0.5, 0.95),
	"env/grass_tuft_02": Vector2(0.5, 0.95),
	"env/fish_spot": Vector2(0.5, 0.5),
	"buildings/cave": Vector2(0.5, 0.95),
	"buildings/campfire": Vector2(0.5, 0.85),
	"buildings/campfire_flame_01": Vector2(0.5, 1.0),
	"buildings/campfire_flame_02": Vector2(0.5, 1.0),
	"buildings/campfire_flame_03": Vector2(0.5, 1.0),
	"buildings/campfire_flame_04": Vector2(0.5, 1.0),
	"env/ripple": Vector2(0.5, 0.5),
	"env/ripple_ring": Vector2(0.5, 0.5),
	"env/fish_jump": Vector2(0.5, 0.5),
	"env/fish_shadow": Vector2(0.5, 0.5),
	"fx/ember": Vector2(0.5, 0.5),
	"animals/boar": Vector2(0.48, 0.92),
	"animals/deer": Vector2(0.45, 0.94),
	"ui/move_marker": Vector2(0.375, 0.875),
}

## Neo chung cho cả nhóm hình cùng tiền tố (dùng khi không có trong PIVOTS).
## Các lớp đầu (đầu, mặt, tóc, phụ kiện) vẽ trên cùng một khung 80×80, neo ở cổ.
const PREFIX_PIVOTS: Dictionary[String, Vector2] = {
	"villager/head_": Vector2(0.5, 0.9),
	"villager/face_": Vector2(0.5, 0.9),
	"villager/hair_": Vector2(0.5, 0.9),
	"villager/accessory_": Vector2(0.5, 0.9),
	"villager/body_": Vector2(0.5, 1.0),
	"villager/arm": Vector2(0.5, 0.1),
	"villager/leg": Vector2(0.36, 0.1),
	"villager/shadow": Vector2(0.5, 0.5),
	"icons/": Vector2(0.5, 0.5),
	"fx/": Vector2(0.5, 0.5),
	"ui/": Vector2(0.5, 0.5),
}


static func pivot(key: String) -> Vector2:
	if PIVOTS.has(key):
		return PIVOTS[key]
	for prefix: String in PREFIX_PIVOTS:
		if key.begins_with(prefix):
			return PREFIX_PIVOTS[prefix]
	return DEFAULT_PIVOT
