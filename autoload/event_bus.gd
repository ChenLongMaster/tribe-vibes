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
## Sang ngày mới.
signal day_changed(day: int)

## Người chơi vừa giao việc (target = cây, đá, thú, lửa trại…) hoặc bảo đi tới một ô.
signal job_assigned(villager: Node, target: Node)
signal move_ordered(villager: Node, cell: Vector2i)
## Một chuyến hàng vừa vào kho tại vị trí `pos` (để hiện số bay "+3 gỗ").
signal resource_delivered(resource_id: StringName, amount: int, pos: Vector2)
## Một nhát chặt/đập trúng vật (để tung bụi). kind = JobDefs.IMPACT_*.
signal work_impact(pos: Vector2, kind: StringName)
## Thổ dân lên cấp một kỹ năng.
signal skill_leveled_up(villager: Node, skill: StringName, level: int)
## Chuyện đáng kể trong làng — thông báo nổi (và sau này nhật ký làng) hiển thị.
## Chỉ mang key dịch + tham số; tham số tên `*_key` là key dịch (xem Loc.t).
signal village_event(key: String, args: Dictionary, icon_key: String)
## Sức chứa chung của một loại tài nguyên đổi (xây/nâng cấp kho, bếp). -1 = không giới hạn.
signal storage_capacity_changed(resource_id: StringName, capacity: int)

# --- Công trình (Đợt 3) ---
## Vừa đặt móng (hoặc dựng công trình khi tải game).
signal building_placed(building: Node)
## Xây xong cấp 1 hoặc nâng cấp xong (`level` = cấp mới) — pháo giấy, thông báo.
signal building_completed(building: Node, level: int)
## Móng bị huỷ.
signal building_removed(building: Node)
## Công trình được chọn (null = bỏ chọn) — bảng công trình nghe signal này.
signal building_selected(building: Node)
## Vật thể được chọn để xem thông tin: cây, đá, bụi quả, củi, chỗ câu cá, con thú (null = bỏ chọn).
signal object_selected(target: Node)

# --- Chế độ đặt công trình (UI ↔ controller) ---
## Người chơi chọn một công trình trong menu xây.
signal placement_requested(building_id: StringName)
## Controller báo đang đặt hay thôi: HUD hiện thanh xác nhận/huỷ (✓ chỉ cần trên cảm ứng).
signal placement_state_changed(active: bool, building_id: StringName, can_confirm: bool)
signal placement_confirm_requested
signal placement_cancel_requested

# --- Lưu game ---
## Vừa lưu xong (`auto` = tự lưu đầu ngày).
signal game_saved(auto: bool)
## Người chơi muốn tải ván đã lưu — main dựng lại cả cảnh.
signal load_requested

@warning_ignore_restore("unused_signal")
