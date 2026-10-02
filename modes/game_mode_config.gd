class_name GameModeConfig
extends Resource
## Luật chơi của một chế độ (Normal "Bộ Lạc", sau này God "Thần Linh"). Code hỏi các
## cờ ở đây thay vì viết `if che_do == ...` rải rác — thêm chế độ mới = thêm một file
## .tres + controller + HUD, lõi mô phỏng không phải sửa.
## Giá trị mặc định = chế độ Normal (dùng khi chưa nạp chế độ nào, vd trong test).

enum Autonomy {
	## Nghe lời: chỉ làm việc được giao; rảnh thì dạo quanh điểm neo (Normal).
	OBEDIENT,
	## Tự lập: tự kiếm việc của làng kiểu RimWorld (God, làm sau MVP).
	AUTONOMOUS,
}

## Mã chế độ, vd &"normal", &"god".
@export var id: StringName = &"normal"
## Key dịch tên chế độ (hiện ở màn hình bắt đầu).
@export var name_key: String = "UI_MODE_NORMAL"

@export_group("Luật chơi")
## Được chọn từng thổ dân và giao việc trực tiếp.
@export var allow_direct_commands: bool = true
## Có thẻ nhiệm vụ.
@export var goals_enabled: bool = true
## Cannibal tự kéo đến theo đợt.
@export var raids_auto: bool = true
## Có thể thua (vd cả làng ngất/mất hết người).
@export var can_lose: bool = true
## Có phép thần.
@export var god_powers_enabled: bool = false
## Phép thần không tốn năng lượng.
@export var god_powers_unlimited: bool = false
## Có trình tạo nhân vật.
@export var character_creator_enabled: bool = false
## Bắt đầu với cả bộ lạc chui ra khỏi hang (chế độ sandbox có thể bắt đầu trống).
@export var starts_with_tribe: bool = true

@export_group("Thổ dân")
## Thổ dân nghe lời hay tự lập (xem GAME_DESIGN mục 5.2).
@export var villager_autonomy: Autonomy = Autonomy.OBEDIENT
## Chỉ số nào đang bật (xem data/needs.gd). Bỏ một id ra là chỉ số đó đứng yên và bị ẩn.
@export var enabled_needs: Array[StringName] = [&"health", &"hunger", &"energy", &"fun"]

@export_group("Cảnh nạp theo chế độ")
## Controller diễn giải lệnh từ InputRouter (gốc phải là PlayerController).
@export var controller_scene: PackedScene
## HUD riêng của chế độ, gắn vào lớp UI.
@export var hud_scene: PackedScene


func need_enabled(need_id: StringName) -> bool:
	return enabled_needs.has(need_id)
