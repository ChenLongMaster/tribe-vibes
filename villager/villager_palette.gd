class_name VillagerPalette
## Các lựa chọn ngoại hình mà hàm sinh ngẫu nhiên được phép dùng: màu da, áo lông,
## tóc và số biến thể mỗi loại mảnh. VillagerData lưu mã màu + ID mảnh cụ thể, nên
## đổi bảng này chỉ ảnh hưởng thổ dân sinh ra SAU đó.

const SKIN: Array[Color] = [Color("#F2C29B"), Color("#D9A066"), Color("#A9714B"), Color("#F5D0B0")]
const FUR: Array[Color] = [Color("#A1887F"), Color("#FFB74D"), Color("#E57373"), Color("#8D6E63"), Color("#AED581")]
const HAIR: Array[Color] = [Color("#5D4037"), Color("#3E2723"), Color("#A1887F"), Color("#FF8A65"), Color("#FFE082")]

const HEAD_COUNT: int = 3
const FACE_COUNT: int = 1
const HAIR_COUNT: int = 5
const BODY_COUNT: int = 3
const ACCESSORY_COUNT: int = 3


## ID mảnh từ số thứ tự 0-based, vd piece_id("hair", 2) = "hair_03".
static func piece_id(slot: String, index: int) -> String:
	return "%s_%02d" % [slot, index + 1]


static func to_hex(color: Color) -> String:
	return "#" + color.to_html(false).to_upper()
