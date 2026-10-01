class_name WaterLayer
extends TileMapLayer
## Vẽ nước kiểu "dual-grid": mỗi ô hình đặt ở góc chung của 4 ô lưới, chọn 1 trong
## 15 hình theo việc 4 ô quanh góc đó có nước hay không (bit: trên-trái 1,
## trên-phải 2, dưới-trái 4, dưới-phải 8). Nhờ vậy bờ hồ bo tròn mà chỉ cần 15 hình.

const TILE_KEY_FORMAT: String = "water/water_%02d"
const BIT_TOP_LEFT: int = 1
const BIT_TOP_RIGHT: int = 2
const BIT_BOTTOM_LEFT: int = 4
const BIT_BOTTOM_RIGHT: int = 8
const MASK_COUNT: int = 16


func build(data: MapData) -> void:
	var keys: Dictionary[int, String] = {}
	for mask: int in range(1, MASK_COUNT):
		keys[mask] = TILE_KEY_FORMAT % mask
	tile_set = TileSetBuilder.build(keys)
	scale = Vector2(ArtLibrary.ART_SCALE, ArtLibrary.ART_SCALE)
	# Lệch nửa ô để tâm mỗi ô hình trùng với góc lưới.
	position = -Vector2(Balance.TILE_SIZE, Balance.TILE_SIZE) * 0.5
	clear()
	for y: int in range(data.size.y + 1):
		for x: int in range(data.size.x + 1):
			var mask: int = corner_mask(data, Vector2i(x, y))
			if mask != 0:
				set_cell(Vector2i(x, y), mask, Vector2i.ZERO)


static func corner_mask(data: MapData, corner: Vector2i) -> int:
	var mask: int = 0
	if data.is_water(corner + Vector2i(-1, -1)):
		mask |= BIT_TOP_LEFT
	if data.is_water(corner + Vector2i(0, -1)):
		mask |= BIT_TOP_RIGHT
	if data.is_water(corner + Vector2i(-1, 0)):
		mask |= BIT_BOTTOM_LEFT
	if data.is_water(corner):
		mask |= BIT_BOTTOM_RIGHT
	return mask
