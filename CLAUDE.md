# Tribe Vibes — ghi chú cho Claude

Spec đầy đủ (cách làm việc, phạm vi MVP, các đợt): @MVP_PROMPT.md

Kế hoạch đã duyệt + quyết định kỹ thuật: `PLAN.md`. Nhật ký từng đợt: `DEVLOG.md` — đọc mục mới nhất trước khi làm tiếp.

## Lệnh

Godot 4.7.2 ở `C:\Tools\Godot\` (PowerShell: `godot`; Git Bash: `/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe`).

- Import + bắt lỗi parse: `godot --headless --path . --editor --quit`
- Chạy game ~10 s: `godot --headless --path . --quit-after 600`
- Smoke test: `godot --headless --path . res://tests/run_tests.tscn` — in `PASS`/`FAIL`, mã thoát 1 khi có test trượt. Thêm test = thêm file `tests/cases/test_*.gd` kế thừa `TestCase`.
- Soi cảnh báo GDScript (chạy ngoài editor thì Godot không in cảnh báo): copy `tools/strict_warnings.cfg` thành `override.cfg` ở gốc project → chạy test + game (cảnh báo thành lỗi) → **xoá** `override.cfg`.
- Chụp màn hình (mở cửa sổ thật vài giây): `godot --path . res://tools/screenshot.tscn -- --out=<thư mục> --seed=42`
- Seed cố định: `godot --path . -- --seed=42`, hoặc đặt `Balance.DEBUG_FIXED_SEED`.
- Sinh lại 15 hình nước: `godot --headless --path . -s res://tools/gen_water_tiles.gd`

Đóng Godot editor trước khi sửa `project.godot` (editor đang mở sẽ ghi đè).

## Quy ước đã chốt

- Art vẽ 2×, hiển thị ×0.5 (`ArtLibrary.ART_SCALE`). Lấy hình qua `ArtLibrary.get_texture()` / `setup_sprite()`; điểm neo ở `data/art_specs.gd`, phải khớp `ASSET_SPEC.md`. Thêm hình mới thì cập nhật cả hai.
- `WorldGrid` là nguồn sự thật duy nhất về ô (64 px). TileMapLayer chỉ để vẽ (tile 128, scale 0.5).
- Mọi con số cân bằng ở `data/balance.gd`; công trình cấu hình ở `data/buildings.gd`.
- Chữ hiển thị: chỉ key trong `i18n/strings.csv`, gọi `Loc.t` / `Loc.plural` / `Loc.number`. Ô trống tự dùng tiếng Việt. Xem `i18n/README.md`.
- Input: chỉ nghe signal của `InputRouter` (tapped, pan/zoom_requested, drag_assign_*, long_pressed, hovered, cancel_requested), không đọc chuột/cảm ứng trực tiếp. Control phủ lên thế giới phải `mouse_filter = IGNORE` nếu không cần bấm.
- Sinh map chỉ dùng RNG riêng của generator (không `randf()`/`shuffle()` toàn cục) để cùng seed ra cùng map.
- Godot có sẵn enum toàn cục `Side` — đừng đặt tên enum/class trùng tên global.
- Static typing đầy đủ, kể cả biến vòng lặp (`for cell: Vector2i in ...`). Tên trong code bằng tiếng Anh, comment tiếng Việt ngắn giải thích *vì sao*.
