class_name PlayerController
extends Node
## Lớp gốc của controller: nhận lệnh chung từ InputRouter rồi quyết định làm gì,
## mọi thay đổi thật đi qua Commands. Mỗi chế độ một controller (NormalController,
## sau này GodController) — cùng một cú chạm, mỗi chế độ hiểu một kiểu.

var world: World
var mode: GameModeConfig


## Gọi một lần sau khi thế giới đã dựng xong.
func setup(owner_world: World, game_mode: GameModeConfig) -> void:
	world = owner_world
	mode = game_mode
