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
	"env/rock_big_100": Vector2(0.5, 0.88),
	"env/rock_big_50": Vector2(0.5, 0.88),
	"env/rock_big_20": Vector2(0.5, 0.88),
	"env/rock_small_100": Vector2(0.5, 0.88),
	"env/rock_small_50": Vector2(0.5, 0.88),
	"env/rock_small_20": Vector2(0.5, 0.88),
	"env/bush_100": Vector2(0.5, 0.91),
	"env/bush_50": Vector2(0.5, 0.91),
	"env/bush_20": Vector2(0.5, 0.91),
	"env/bush_empty": Vector2(0.5, 0.91),
	"env/flower_01": Vector2(0.5, 0.95),
	"env/flower_02": Vector2(0.5, 0.95),
	"env/flower_03": Vector2(0.5, 0.95),
	"env/grass_tuft_01": Vector2(0.5, 0.95),
	"env/grass_tuft_02": Vector2(0.5, 0.95),
	"env/tall_grass_01": Vector2(0.5, 0.97),
	"env/tall_grass_02": Vector2(0.5, 0.97),
	"env/fern_01": Vector2(0.5, 0.92),
	"env/fern_02": Vector2(0.5, 0.92),
	"env/shrub_01": Vector2(0.5, 0.92),
	"env/shrub_02": Vector2(0.5, 0.92),
	"env/reeds_01": Vector2(0.5, 0.97),
	"env/mushroom_01": Vector2(0.5, 0.94),
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
	"ui/thought_bubble": Vector2(0.5, 1.0),
	"props/sign": Vector2(0.5, 1.0),
	# Giỏ, xô xách thõng: neo ở quai (mép trên) để treo dưới bàn tay.
	"props/basket": Vector2(0.5, 0.15),
	"props/bucket": Vector2(0.5, 0.15),
	"env/twigs_100": Vector2(0.5, 0.73),
	"env/twigs_50": Vector2(0.5, 0.73),
	"env/twigs_20": Vector2(0.5, 0.73),
	"env/pebbles_100": Vector2(0.5, 0.65),
	"env/pebbles_50": Vector2(0.5, 0.65),
	"env/pebbles_20": Vector2(0.5, 0.65),
	# Khối đá của dãy vách: gốc ở chân khối (đáy ~ 226/240).
	# Công trình Đợt 3: mép dưới hình = mép dưới diện tích, neo cách mép dưới 24 px (file 2×)
	# = Building.FOOT_INSET. Neo y = (cao - 24) / cao.
	"buildings/tent_1": Vector2(0.5, 0.92),
	"buildings/tent_2": Vector2(0.5, 0.92),
	"buildings/tent_3": Vector2(0.5, 0.92),
	"buildings/kitchen_1": Vector2(0.5, 0.925),
	"buildings/kitchen_2": Vector2(0.5, 0.925),
	"buildings/kitchen_3": Vector2(0.5, 0.925),
	"buildings/storage_1": Vector2(0.5, 0.9368),
	"buildings/storage_2": Vector2(0.5, 0.9368),
	"buildings/storage_3": Vector2(0.5, 0.9368),
	"buildings/forge_1": Vector2(0.5, 0.925),
	"buildings/forge_2": Vector2(0.5, 0.925),
	"buildings/forge_3": Vector2(0.5, 0.925),
	"buildings/dance_floor_1": Vector2(0.5, 0.94),
	"buildings/dance_floor_2": Vector2(0.5, 0.94),
	"buildings/dance_floor_3": Vector2(0.5, 0.94),
	# Móng phủ đúng diện tích; Building đặt sprite móng ở mép dưới diện tích nên neo mép dưới.
	"buildings/foundation_2x2": Vector2(0.5, 1.0),
	"buildings/foundation_3x2": Vector2(0.5, 1.0),
	"buildings/foundation_3x3": Vector2(0.5, 1.0),
	# Mũ công trường vẽ trên khung đầu 80×80 như tóc, neo ở cổ.
	"villager/hard_hat": Vector2(0.5, 0.9),
	"fx/confetti": Vector2(0.5, 0.5),
}

## Neo chung cho cả nhóm hình cùng tiền tố (dùng khi không có trong PIVOTS).
## Các lớp đầu (đầu, mặt, tóc, phụ kiện) vẽ trên cùng một khung 80×80, neo ở cổ.
## Bộ thử góc cao: body_01 56×40, arm 16×28, leg 22×26; giữ neo tỉ lệ,
## vị trí khớp và đồ khuân được chỉnh trong VillagerRig để ghép cả mảnh cũ.
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
	"props/": Vector2(0.5, 0.5),
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
