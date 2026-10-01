class_name VillagerPalette
## Màu da, áo lông, tóc của thổ dân. Dữ liệu chỉ lưu chỉ số, nên đổi màu ở đây là
## mọi thổ dân (cả trong save cũ) đổi theo.

const SKIN: Array[Color] = [Color("#F2C29B"), Color("#D9A066"), Color("#A9714B"), Color("#F5D0B0")]
const FUR: Array[Color] = [Color("#A1887F"), Color("#FFB74D"), Color("#E57373"), Color("#8D6E63"), Color("#AED581")]
const HAIR: Array[Color] = [Color("#5D4037"), Color("#3E2723"), Color("#A1887F"), Color("#FF8A65"), Color("#FFE082")]

const HEAD_COUNT: int = 3
const HAIR_COUNT: int = 5
const BODY_COUNT: int = 3
const ACCESSORY_COUNT: int = 3


static func pick(colors: Array[Color], index: int) -> Color:
	return colors[clampi(index, 0, colors.size() - 1)]
