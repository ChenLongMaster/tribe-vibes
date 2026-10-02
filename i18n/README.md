# Chữ trong game (i18n)

Mọi chữ người chơi nhìn thấy nằm trong `strings.csv`. Code chỉ dùng **key**, gọi qua autoload `Loc`.

## Định dạng `strings.csv`

- Dòng đầu: `keys,vi,en`. Mỗi cột sau `keys` là một ngôn ngữ.
- Mỗi dòng một key. Chữ có dấu phẩy thì bọc trong ngoặc kép: `"Ừ, ở đây ấm áp."`
- **Ghi chú**: dòng bắt đầu bằng `#` và có **đủ số dấu phẩy** như các dòng khác, vd `# --- UI ---,,`. Godot bỏ qua dòng này (đã có test kiểm tra).
- Ô để trống → game tự dùng chữ tiếng Việt thay thế (không bao giờ hiện chữ rỗng).
- Chỗ giữ chỗ có tên: `{name} chào đời!` → trong code `Loc.t("TOAST_BABY_BORN", {"name": baby.display_name})`. **Không** ghép chuỗi.
- Câu có số đếm: hai key `..._ONE` (n = 1) và `..._OTHER`, gọi `Loc.plural("RES_WOOD_COUNT", n)`. `{n}` được tự định dạng theo ngôn ngữ (vi `1.250`, en `1,250`).
- Tham số là một **key khác**: đặt tên tham số có đuôi `_key`, `Loc` dịch key đó rồi thay vào chỗ giữ chỗ không đuôi: `Loc.t("TOAST_LEVEL_UP", {"name": "Bạp", "job_key": "JOB_CHOP", "level": 2})` → `{job}` = "Chặt cây". Nhờ vậy thông báo/nhật ký chỉ lưu key, đổi ngôn ngữ là đổi theo.

## Nhóm key (tiền tố)

| Tiền tố | Dùng cho |
|---|---|
| `GAME_` | Tên game (`GAME_TITLE`) |
| `UI_` | Nút, nhãn, menu, bảng thông tin. `UI_DEBUG_*` chỉ hiện ở bản debug |
| `TOAST_` | Thông báo nổi ("Bé Tí chào đời!") |
| `LOG_` | Nhật ký làng |
| `TRAIT_` | Tính cách: `TRAIT_<ID>_NAME`, `TRAIT_<ID>_DESC` |
| `JOB_` | Tên việc |
| `BUILDING_` | Công trình: `BUILDING_<ID>_NAME` |
| `RES_` | Tài nguyên: `RES_<ID>_NAME` (viết hoa, đứng một mình), `RES_<ID>_NOUN` (viết thường, ghép vào câu), `RES_<ID>_COUNT_ONE/_OTHER` |
| `GOAL_` | Nhiệm vụ |

Key đặc biệt `UI_LANGUAGE_NAME`: tên ngôn ngữ viết bằng chính ngôn ngữ đó ("Tiếng Việt", "English"), dùng cho menu chọn ngôn ngữ — mỗi cột phải điền.

## Thêm một ngôn ngữ mới

1. Thêm một cột vào `strings.csv` (vd `ja`), điền tối thiểu `GAME_TITLE` và `UI_LANGUAGE_NAME`. Mở editor để import — Godot tạo `strings.ja.translation`, `Loc` tự nạp mọi file `.translation` trong thư mục này.
2. Thêm file tên `data/names/names_ja.gd` (hằng `NAMES`). Không có thì dùng tên tiếng Việt.
3. Nếu font Nunito thiếu chữ của ngôn ngữ đó: thêm font vào `fallbacks` của font trong `ui/theme/main_theme.tres`.

Không cần sửa code hay Project Settings (đã thử với một cột `ja` tạm). Bấm **F9** (bản debug) để đổi vòng qua các ngôn ngữ.

## Lưu ý kỹ thuật

File `strings.csv.import` đặt `compress=0` (không nén). Bắt buộc giữ như vậy: `Loc` cần đọc danh sách key để chép chữ tiếng Việt vào các ô trống.
