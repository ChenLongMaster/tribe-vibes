# Plan MVP — Tribe Vibes (Bộ Lạc Chill)

## Context

Cần dựng từ đầu bản MVP chơi được của một colony-sim tiền sử dễ thương (cảm hứng Prehistoric Tribes) cho người chơi casual, theo spec `C:\Users\Legion\Desktop\MVP_PROMPT.md`. Spec chia 7 đợt (0→6), **mỗi đợt dừng lại chờ duyệt**. Plan này chốt kiến trúc chung, các quyết định kỹ thuật, và nội dung + tiêu chí kiểm tra của từng đợt. Khi được duyệt, mình làm **Đợt 0** rồi dừng.

**Hiện trạng repo** (`tribe-vibes/`): project Godot trống vừa tạo bằng editor — `project.godot` (đang là *Forward Plus*, tên "New Game Project", driver d3d12), `icon.svg`, `.gitignore`, chưa có commit nào. Godot **4.7.2** có sẵn ở `C:\Tools\Godot\godot.cmd` (đã trong PATH, dùng được cho headless check), export templates 4.7.2 đã cài → xuất Web được.

---

## Quy trình mỗi đợt

1. Code + asset tạm → 2. `godot --headless --path . --editor --quit` (import, bắt lỗi parse) → 3. `godot --headless --path . --quit-after 600` (runtime 10 s) → 4. chạy **smoke test headless** của đợt (mục *Kiểm tra*) → 5. sửa hết error/warning → 6. cập nhật `DEVLOG.md` → 7. báo cáo 4 phần (đã làm / cách chơi thử / lỗi còn biết / số nên chỉnh) → **dừng** → khi bạn OK thì commit đợt đó.

- **Đóng Godot editor** khi mình đang sửa `project.godot` (editor đang mở sẽ ghi đè file).
- Bật warning `untyped_declaration` trong project để ép static typing; warning của code mình = phải sửa.
- Tải file ngoài (font Nunito ở Đợt 0, SFX Kenney ở Đợt 6): mình sẽ hỏi xác nhận từng lần trước khi tải.
- Tạo `CLAUDE.md` ngắn (quy ước + lệnh godot) có dòng `@MVP_PROMPT.md`, và copy spec vào repo thành `MVP_PROMPT.md` → mỗi phiên sau Claude tự đọc spec, không bị hai bản lệch nhau.

---

## Kiến trúc chung

```
main.tscn (Node)
├─ World (world.tscn)
│  ├─ Ground   TileMapLayer   (cỏ/đất)
│  ├─ Water    TileMapLayer   (dual-grid, lệch nửa ô → bờ hồ bo tròn)
│  ├─ Decor    Node2D         (cỏ, hoa trang trí — không chặn đường)
│  ├─ Entities Node2D y_sort  (resource node, công trình, thổ dân, thú, cannibal)
│  ├─ FX       Node2D         (bụi, tim, sao, số bay)
│  ├─ DayNight CanvasModulate
│  ├─ SelectionController
│  └─ Camera2D + camera_controller.gd
├─ GlowLayer CanvasLayer(follow_viewport) — lửa trại phát sáng, KHÔNG bị CanvasModulate làm tối
└─ UI CanvasLayer — HUD, panel, toast, menu (UiScaler cho setting "Cỡ giao diện")
```

**Autoload:** `EventBus` (chỉ signal) · `GameState` (tài nguyên, ngày giờ, tốc độ, độ khó, seed) · `Loc` · `InputRouter` · `ArtLibrary` · `SaveSystem`.

**File thêm ngoài cấu trúc spec** (cần để giữ "mỗi file một việc"):
- `main.tscn/.gd`, `autoload/art_library.gd`
- `world/world_grid.gd` (ô↔toạ độ, `AStarGrid2D`, ô bị chiếm) · `world/map_generator.gd` · `world/camera_controller.gd` · `world/reservations.gd` · `world/water_dual_grid.gd`
- `villager/villager_data.gd` (dữ liệu thuần, `to_dict/from_dict`) · `villager/villager_needs.gd` · `villager/tasks/*.gd` (mỗi việc/hoạt cảnh một Task nhỏ: `start / tick / interrupt`)
- `ui/theme/main_theme.tres`, `default_bus_layout.tres` (Master/Music/SFX/Voice)
- `tests/` — scene smoke test chạy headless, `quit(1)` khi fail

### Quyết định kỹ thuật chính

| Vấn đề | Chọn |
|---|---|
| Renderer | `gl_compatibility` cho cả desktop & mobile, xoá dòng d3d12; viewport 1280×720, `canvas_items` + `expand` |
| Độ nét khi zoom | **Mọi art vẽ ở 2× cỡ hiển thị**, game hiển thị scale 0.5 (hằng `ArtLibrary.ART_SCALE`). TileMapLayer tile 128 px + node scale 0.5; `WorldGrid` là nguồn duy nhất cho toạ độ ô (64 px). Import mặc định bật mipmaps, filter linear-mipmap |
| Tô màu ngẫu nhiên | Bộ phận da/áo lông vẽ màu trắng–xám sáng, tô bằng `modulate` (ghi rõ trong ASSET_SPEC để art thật theo cùng quy tắc) |
| Đa ngôn ngữ | CSV importer của Godot với `compress=false` (ra `Translation` thường). Lúc khởi động `Loc` duyệt mọi locale ≠ vi: key thiếu/rỗng → `add_message` bằng bản vi + `push_warning` (debug). Nhờ vậy cả `tr()` lẫn auto-translate của Control đều fallback đúng. Placeholder dùng `String.format({...})`. Ngôn ngữ lưu ở `user://settings.cfg` |
| Comment trong CSV | Thử dòng `#` khi import Đợt 0; Godot không hỗ trợ → bỏ, viết `i18n/README.md` |
| Font | **Nunito** (variable, OFL) từ `github.com/google/fonts` + `OFL.txt`, gắn vào Theme mặc định, chừa sẵn `fallbacks` |
| Input | `InputRouter` dùng `_unhandled_input` (UI ăn trước). Giữ `emulate_mouse_from_touch` cho nút UI, nhưng router **bỏ qua** mouse event có `device == DEVICE_ID_EMULATION` → không bị nhân đôi. Router nhận `picker` Callable do World đăng ký để biết lúc nhấn có trúng thổ dân không (kéo-giao-việc vs pan). Phát: `tap`, `long_press`, `drag_assign_*`, `pan`, `zoom`, `cancel`, `input_mode_changed`. `SelectionController` dịch `tap` → `select` / `command_target`. Picking không dùng physics: duyệt nhóm thổ dân (≤50) với vùng chạm ≥48×48 + tra ô lưới |
| Vật thể map | Cây/đá/bụi/hang/lửa trại là scene Node2D trong `Entities` (cần đặt chỗ, y-sort, tương tác), không phải tile. Cây/đá chặn ô của nó, thổ dân đứng ô kề để làm |
| Tìm đường | `AStarGrid2D` 48×36, chéo khi không vướng; chỉ tính lại khi đổi mục tiêu hoặc nhận `EventBus.grid_changed` |
| Tốc độ game | `Engine.time_scale` cho ×1/×2/×3, `get_tree().paused` cho tạm dừng; UI & camera `PROCESS_MODE_ALWAYS`, camera dùng delta thật |
| Hạt hiệu ứng | `CPUParticles2D` (an toàn trên Web/Compatibility) |
| Âm thanh lẩm bẩm | Lúc khởi động tổng hợp sẵn 6–8 "âm tiết" thành `AudioStreamWAV` bằng code, phát với `pitch_scale` riêng mỗi thổ dân (không dùng `AudioStreamGenerator` cho chắc chạy Web không thread) |
| Lưu game | JSON `user://save.json` có `version`; lưu seed + phần map đã thay đổi (lượng còn lại của từng node, công trình) + dân + tài nguyên + giờ. Thú sinh lại mới khi tải |
| Cân bằng | Mọi con số trong `data/balance.gd` (`class_name Balance`, `const`). Tính cách là data: `traits.gd` chứa modifier (`work_speed`, `hunger_rate`, `idle_weights`…), code chỉ gọi `Traits.modifier(traits, "work_speed")` |

---

## Đợt 0 — Dựng khung

**Làm:**
- `project.godot`: tên `Tribe Vibes`, Compatibility, 1280×720, main scene, 6 autoload, input map (WASD/mũi tên, Space, 1–3, Esc, F9), translations + fallback `vi`, theme mặc định, import defaults (mipmaps), warning typing. `.gitignore` thêm `/build/`.
- `Loc` đầy đủ API mục 3.1 (`t`, `plural`, `number`, `set_language`, `available_languages`, signal `language_changed`, fallback vi). `i18n/strings.csv` cột `keys,vi,en` với `GAME_TITLE` + vài key UI/test; F9 đổi vi↔en.
- `EventBus`, `GameState` (khung), `ArtLibrary.get_texture()` (ưu tiên `assets/art/*.png|svg` → `assets/placeholder/*.svg`, cache, texture "thiếu" + cảnh báo), `InputRouter` đủ gesture chuột + cảm ứng (pinch), `SaveSystem` khung.
- `data/balance.gd`, `data/names/names_vi.gd` (~60 tên), `names_en.gd` (vài tên mẫu).
- SVG tạm map (vẽ tay, 2×, viền `#4E342E` 3 px, bảng màu spec): cỏ ×3, đất, 16 ô nước dual-grid, cây ×2, gốc cây, đá ×2 cỡ, bụi quả (có/hết), hoa ×3, cỏ trang trí, hang, lửa trại.
- `MapGenerator` theo seed (`FastNoiseLite`): hang + lửa trại giữa map, rừng một phía, bãi đá phía kia, hồ có ô câu cá, đồng cỏ, cạnh raid được đánh dấu; đảm bảo mọi tài nguyên đi tới được từ lửa trại. Seed cố định bật được trong `balance.gd`.
- Camera: pan (kéo chỗ trống / WASD / chuột giữa / một ngón), zoom về phía con trỏ (lăn / chụm), mượt, giới hạn trong map.
- Debug overlay nhỏ: tiêu đề `GAME_TITLE` qua `Loc`, câu test "Thổ dân đói bụng quá! Ừ, ở đây ấm áp.", ngôn ngữ hiện tại.
- `ASSET_SPEC.md` (bảng mọi file: đường dẫn, cỡ file 2× / cỡ hiển thị, điểm neo, quy tắc tô màu, quy tắc "không vẽ chữ vào hình"), `DEVLOG.md`, `CLAUDE.md`, `MVP_PROMPT.md`.

**Kiểm tra:** smoke test — map gen cùng seed ra cùng kết quả; hang ở giữa; có hồ, rừng, đá, bụi quả; mọi node tới được bằng AStar; `Loc.t` ở `en` với ô trống trả về chữ vi; `Loc.number(1250)` = `1.250` / `1,250`. Thủ công: F5 thấy map dễ thương, kéo/zoom mượt, F9 không vỡ chữ, Output sạch.

## Đợt 1 — Thổ dân sống động

- SVG bộ phận (head ×3, 5 mặt, hair ×5, body ×3, arm, leg, accessory ×3), icon cảm xúc/việc.
- `villager_rig`: 10 Sprite2D theo thứ tự spec, chibi ~72 px; animation bằng code (sin/tween): idle thở, chớp mắt, walk, lật hướng, squash & stretch, gather, eat, sleep + Zzz, talk, pick_flower, scratch, sit/ngáp, celebrate.
- `VillagerData` (tên, giới, giai đoạn, ngoại hình, 1–2 trait, việc giỏi nhất, máu/sức đánh) + factory random; `villager_needs` (No/Năng lượng/Vui, mood có trọng số).
- Di chuyển theo path, lệch nhẹ trong ô để không chồng nhau; `Reservations` (1 cây = 1 người, chỗ ngủ theo slot).
- `villager_brain` nghĩ mỗi 0.3–0.6 s lệch pha, theo thứ tự ưu tiên spec (mức 1 nguy hiểm để trống tới Đợt 5). Đói → hái quả ăn; mệt → ngủ ngoài trời cạnh lửa trại; bong bóng giải thích.
- Hoạt cảnh rảnh (3–10 s, trọng số theo trait): tán gẫu (bong bóng "Ugga bugga!" — các key `BUBBLE_GIBBERISH_*`), hái hoa, gãi mông, ngồi phơi nắng/ngáp, ăn vặt quả mọng.
- Intro: 6 người (3 nam 3 nữ) lần lượt ló ra khỏi hang, dụi mắt, vươn vai.
- Chạm thổ dân → `villager_panel` (chân dung = rig thứ hai trong SubViewport, tên, trait + mô tả, thanh nhu cầu, việc đang làm, ⭐ việc giỏi).
- **Watchdog debug**: cảnh báo nếu một thổ dân đứng yên/không đổi trạng thái > 30 s mà không ngủ.

**Kiểm tra:** smoke sim headless (seed cố định, tua nhanh ~5 phút game) — không ai No = 0 khi còn quả, watchdog không báo. Thủ công: xem 5 phút thấy làng "sống".

## Đợt 2 — Lao động & tài nguyên

- `SelectionController`: chọn rồi chạm mục tiêu; **kéo-thả** thổ dân vào mục tiêu (đường kéo hiện trên màn hình); nút ✕ khi đang dùng cảm ứng.
- Task: chặt cây, đập đá, hái quả, săn (`animal.tscn`: lợn rừng, hươu — đi lang thang, bỏ chạy, bị đuổi kịp thì "bonk" → thịt sống), câu cá (ô bờ hồ), khuân về kho gần nhất (lúc đầu là lửa trại), nấu ở lửa trại (10 s).
- Việc lặp lại: hết cây này tự tìm cây cùng loại gần nhất. Bị ngắt (đói/buồn ngủ) → nhớ việc, bong bóng lý do, tự quay lại.
- Juice: icon việc trên đầu, đường chấm chấm tới mục tiêu (Line2D texture tile), số bay "+3 gỗ", bụi khi chặt/đập.
- HUD: thanh tài nguyên (chỉ đồ đã vào kho, `Loc.number`), nút tạm dừng/×1/×2/×3 + phím Space/1–3. Ăn: ưu tiên món chín > quả mọng; đồ sống không ăn được.

**Kiểm tra:** sim giao 3 chặt + 2 đập → gỗ/đá tăng đều, watchdog sạch, việc bị ngắt được tiếp tục.

## Đợt 3 — Xây dựng & ngày đêm

- `data/buildings.gd` + một `building.tscn` chung: trạng thái MÓNG / XONG / HƯ, footprint chặn lưới, slot, thanh tiến độ, mọc dần khi xây, nảy "bụp" + pháo giấy khi xong.
- `build_menu` (thẻ công trình + chi phí, dùng container tự giãn), bóng mờ xanh/đỏ theo con trỏ/ngón tay, nút xác nhận/huỷ trên cảm ứng.
- Task khuân vật liệu từ kho tới móng rồi xây. Chức năng: lều (2 chỗ ngủ, +giới hạn dân), bếp (nấu 5 s), kho (điểm cất + sức chứa), kho vũ khí (làm chùy thành tài nguyên), sân nhảy (nhảy cơ bản).
- Ngày/đêm (4 phút: 3 ngày + 1 đêm), `CanvasModulate` theo gradient, lửa trại phát sáng trên `GlowLayer`. Đêm về lều; thiếu chỗ thì ngủ ngoài trời, kém vui.
- Save/Load đầy đủ, tự lưu mỗi sáng, menu tạm dừng có Lưu/Tải.

**Kiểm tra:** sim xây đủ 5 công trình bằng tài nguyên cấp sẵn → bếp ra món chín; đêm xuống mọi người vào lều đủ chỗ; save → load → so khớp trạng thái.

## Đợt 4 — Tình yêu & dân số

- Điều kiện yêu (2 người lớn khác giới, mood > 70, lều còn chỗ) → nắm tay về lều, lều rung + tim → cặp đôi cố định (tim nhỏ khi đứng gần). 0.5 ngày → em bé (toast + tên ngẫu nhiên). Em bé (bò) → trẻ con (chơi đuổi nhau, không làm việc) → người lớn; rig đổi tỉ lệ theo giai đoạn.
- Giới hạn dân = slot lều × hệ số, tối đa 50. Trait Lãng mạn tặng hoa; Mê nhảy/Ham chơi (đuổi bướm).
- Hệ toast (hàng đợi) + **nhật ký làng** (lưu `{key, args}`, dịch khi hiển thị).
- Sân nhảy: hoạt cảnh disco + đèn màu.

**Kiểm tra:** sim ~15 phút game ở điều kiện tốt → ≥ 2 em bé sinh ra và lớn lên; giới hạn dân được tôn trọng.

## Đợt 5 — Cannibal & chiến đấu

- `RaidDirector`: đợt đầu ngày 5 (3 kẻ), sau đó vài ngày một đợt (+1–2). Cảnh báo 20 s: tiếng tù và, toast, mũi tên rìa màn hình chỉ hướng.
- `cannibal.tscn` dùng lại rig (mặt nạ xương, sơn chiến, biến thể màu): nhắm công trình/dân gần nhất, hết máu thì bỏ chạy lăn lộn.
- Kho vũ khí làm chùy; dân tự đi lấy & trang bị (nút "Trang bị" trong panel). Có chùy → tự ra đánh khi địch gần; không chùy / Nhát gan → chạy về lều/hang.
- **Dàn quân**: nút HUD "Gọi quân" chọn sẵn nhóm dân có chùy (chạm từng người để thêm/bớt) → chạm một chỗ để tập trung.
- Đánh tự động theo nhịp, hurt (giật + nháy trắng), ngất (sao quay). Công trình HƯ mất chức năng → việc sửa tự động.
- Độ khó chọn khi tạo game: Dễ (tự tỉnh, không ai chết, địch yếu) / Thường (ngất quá lâu không ai cứu → bia mộ dễ thương).

**Kiểm tra:** sim qua 2 đợt raid ở Dễ không crash, nhà hư được sửa, không ai chết.

## Đợt 6 — Đánh bóng & gửi đi

- Nhiệm vụ dạng thẻ (`data/goals.gd`): "Dựng 2 lều", "Có 10 người", "Nấu 5 món chín", "Sống sót đợt đầu"… có thưởng nhỏ.
- Màn bắt đầu "Chạm để bắt đầu" (mở khoá audio trên trình duyệt), Tiếp tục / Game mới + độ khó, hướng dẫn mũi tên vài bước đầu.
- Setting: âm lượng 4 bus, cỡ giao diện 80–150 %, ngôn ngữ.
- Âm thanh (lẩm bẩm tổng hợp + SFX Kenney CC0 nếu bạn cho tải), icon game mới, cân bằng lại số.
- `export_presets.cfg` Web (tắt Thread Support) → `build/web/`; đo cỡ file; chạy server tĩnh cục bộ và thử trong browser pane (cỡ desktop + mobile). Đăng lên đâu (itch.io / GitHub Pages) do bạn quyết, mình chỉ làm khi bạn đồng ý.

**Kiểm tra:** build Web mở được, chạm-để-bắt-đầu có tiếng, chơi được bằng cảm ứng giả lập, không lỗi console.

---

## Rủi ro đã tính trước

- Editor đang mở ghi đè `project.godot` → nhắc đóng editor.
- API Godot 4.7 lệch trí nhớ (tham số `AStarGrid2D`, CSV importer, `--quit-after`) → bắt bằng headless check ngay trong đợt, chỉnh theo output thật.
- Hiệu năng Web với 50 dân × 10 sprite: thấp; brain lệch pha + path chỉ tính lại khi cần; đo lại ở Đợt 6.
- Mốc "15 phút có 2 em bé lớn lên" sát với số gốc (lớn = 3 ngày = 12 phút) → sẽ báo số đề xuất chỉnh ở Đợt 4.

## Verification (tổng)

```
godot --headless --path . --editor --quit
godot --headless --path . --quit-after 600
godot --headless --path . --scene res://tests/<test_cua_dot>.tscn
```
Đọc output, không còn error/warning từ code mình; smoke test in `PASS`. Sau đó bạn chạy thử bằng F5 theo mục "Cách chơi thử" trong báo cáo, so với tiêu chí "Xong khi" của spec.
