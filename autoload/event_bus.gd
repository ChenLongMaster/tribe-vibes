extends Node
## Signal toàn cục. Chỉ khai báo, không chứa logic — các hệ thống nói chuyện
## với nhau qua đây để không phải giữ tham chiếu trực tiếp tới nhau.

# Các signal được phát từ file khác nên Godot tưởng là "không dùng".
@warning_ignore_start("unused_signal")

## Thế giới đã dựng xong (map, vật thể). Tham số là node World.
signal world_ready(world: Node)
## Một ô lưới đổi trạng thái đi được/bị chặn — ai đang có đường đi thì tính lại.
signal grid_changed(cell: Vector2i)
## Số lượng một loại tài nguyên trong kho thay đổi.
signal resource_changed(resource_id: StringName, amount: int)
## Một thổ dân vừa xuất hiện trong thế giới.
signal villager_spawned(villager: Node)
## Thổ dân được chọn (null = bỏ chọn) — bảng thông tin nghe signal này.
signal villager_selected(villager: Node)
## UI (vd nút ✕) muốn bỏ chọn.
signal deselect_requested
## Tốc độ game đổi (0 = tạm dừng).
signal game_speed_changed(speed: int)

@warning_ignore_restore("unused_signal")
