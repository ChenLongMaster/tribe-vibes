# DEVLOG — Tribe Vibes (Bộ Lạc Chill)

Mỗi đợt một mục: đã làm gì, chọn gì và vì sao. Mục mới nhất ở trên cùng.

---

## Đợt 1 — Thổ dân sống động (2026-10-01)

**Trạng thái:** xong, đang chờ chạy thử và duyệt — chưa commit.

### Đã làm
- **Khung cutout** (`villager/villager_rig.gd`): 10 mảnh ghép theo thứ tự spec, chibi ~72 px, ghép ngẫu nhiên 3 đầu × 5 tóc × 3 áo × 4 phụ kiện × 4 màu da × 5 màu áo × 5 màu tóc. Hoạt họa bằng code: đứng thở, chớp mắt ngẫu nhiên, đi, chạy, cúi hái, ăn (nhai), ngủ (nằm + Zzz), nói, gãi mông, ngồi, ngáp, vươn vai, dụi mắt, nhảy cẫng, cầm đồ; lật theo hướng đi; nảy squash & stretch khi dừng chân. Mặt cười/mếu theo tâm trạng.
- **Dữ liệu** (`VillagerData`): tên (bộ tên tiếng Việt), giới, giai đoạn, ngoại hình (chỉ số), cao độ giọng, 1–2 tính cách, việc giỏi nhất, No/Năng lượng/Vui/Máu. Lưu/đọc JSON được.
- **8 tính cách** ở `data/traits.gd` dạng hệ số (Lười làm chậm 20% và hay ngồi, Háu ăn mau đói nhưng ăn vui gấp đôi, Lãng mạn hay hái hoa tặng người khác…).
- **Bộ não** suy nghĩ mỗi 0.3–0.6 s, lệch nhịp nhau: đói (<20) → bỏ việc rảnh đi hái quả ăn, kèm bong bóng "Đói quá!"; kiệt sức (<15) → ra quanh lửa trại nằm ngủ, bong bóng "Buồn ngủ..."; rảnh → chọn ngẫu nhiên có trọng số: đi dạo, tán gẫu theo cặp ("Ugga bugga!", "Bi bô?"…), hái hoa (Lãng mạn mang đi tặng, bật tim), gãi mông, ngồi phơi nắng (mệt thì ngáp), ăn vặt.
- **Đặt chỗ**: mỗi bụi quả, mỗi chỗ ngủ chỉ một người nhận. Bụi hái xong mọc lại sau 1 ngày.
- **Mở đầu**: 6 người (3 nam, 3 nữ) lần lượt ló ra khỏi hang, dụi mắt, ngáp, đi ra lửa trại. Cùng seed → cùng bộ lạc.
- **Chọn thổ dân**: chạm/click → vòng vàng dưới chân + tên trên đầu + bảng thông tin (chân dung là rig thật đang thở, tên, giới tính, tính cách kèm giải thích, 3 thanh nhu cầu, mặt tâm trạng, việc đang làm, việc giỏi nhất ⭐, nút ✕). Rê chuột / nhấn giữ → hiện tên. Chạm chỗ trống, Esc, chuột phải → bỏ chọn.
- **Watchdog** (chỉ bản debug): cảnh báo trong Output nếu một việc kéo quá 40 giây (trừ ngủ) hoặc đang đi mà đứng im 4 giây.
- Test mới (30 test tổng): tạo thổ dân hợp lệ, lưu/đọc, hệ số tính cách, **mô phỏng 5 phút game** (×20): cả 6 người ra khỏi hang, không ai chết đói khi còn quả, không ai lọt vào ô bị chặn, watchdog im lặng, thấy ≥5 loại hoạt động (gồm tán gẫu), chọn đúng người khi chạm, bảng hiện/ẩn đúng. Lần chạy gần nhất thấy đủ 8 loại: ra khỏi hang, đi dạo, tán gẫu, hái hoa, gãi, ngồi, ăn vặt, ngủ.
- Công cụ chụp màn hình thêm tuỳ chọn `--wait=` (chờ N giây game), `--speed=` (tua nhanh lúc chờ), `--select` (mở sẵn bảng thông tin người đầu tiên).

### Lỗi đã sửa trong lúc làm
- Sắp xếp chỗ ngủ gọi `randf()` ngay trong hàm so sánh → Godot báo "bad comparison function". Sửa: bốc số ngẫu nhiên cho từng ô trước rồi mới sắp xếp.
- Nút ✕ trên bảng thông tin chỉ hiện thành một chấm nhỏ (Button không giãn icon) → đổi sang `TextureButton`.
- Biến dùng chung `_step`, `_timer` ở lớp `Task` bị Godot cảnh báo "không dùng" (vì chỉ lớp con dùng) → đổi tên thành `step`, `timer`.

### Quyết định
- Rig dựng bằng code (không vẽ trong scene) để vị trí khớp nằm một chỗ (hằng số đầu file) và dùng lại được cho chân dung.
- Mảnh da/áo/tóc vẽ trắng rồi nhân màu (`modulate`) → chỉ cần một hình cho mọi màu da.
- Việc mỗi loại một file `villager/tasks/task_*.gd`, đều có `stop()` luôn được gọi để trả chỗ đã đặt → không bao giờ kẹt bụi quả.
- Các câu hỏi "tìm chỗ" tách ra `WorldFinder` để `World` không thành god object.
- Tán gẫu dùng chung một `ChatSession` cho hai người: một bên bỏ đi thì bên kia cũng thôi.
- Đợt 1 chưa có chết: No về 0 thì máu giảm nhưng giữ 1 (ngất/mất người làm ở Đợt 5 theo độ khó).
- Thổ dân ăn vặt từ khi No < 60 nếu rảnh, nên hiếm khi tụt xuống mức "Đói quá!" khi còn quả.

### Còn biết / để sau
- Chưa có âm thanh lẩm bẩm (để Đợt 6).
- Lâu lâu hai người đứng gần chồng lên nhau một chút khi cùng đứng cạnh một bụi/người.
- Hái hoa không làm mất bông hoa trên map.
- Mắt ở tư thế nằm ngủ vẫn là mặt nghiêng — ổn với hình tạm.
- Bảng debug (góc trên) và bảng thông tin (góc dưới) cùng nằm bên trái, hơi chật.

### Số nên tinh chỉnh (đề xuất)
- `HUNGER_SNACK` = 60 → hạ còn ~40 nếu muốn thấy dân đói rõ hơn.
- `ENERGY_DECAY_IDLE`: hiện ~2,5 ngày mới cần ngủ; Đợt 3 có ngày/đêm thì cho ngủ theo đêm.
- `FUN_CHAT` = 3, `FUN_SIT` = 1,5: Vui lên khá nhanh, hầu như ai cũng vui — có thể giảm để tâm trạng dao động hơn.
- `IDLE_WEIGHTS` trong `villager/villager_brain.gd`: trọng số chọn hoạt cảnh rảnh.

---

## Đợt 0b — Map sinh động hơn (2026-10-01, theo góp ý sau Đợt 0)

**Trạng thái:** đã duyệt, commit `13d045a` (gộp chung với Đợt 0).

### Đã làm
- **Gió chung** (`world/wind.gd`): một đồng hồ gió + sức gió lên xuống theo đợt. Shader `fx/wind_sway.gdshader` làm cỏ, hoa, bụi, cây, ngọn lửa nghiêng theo cùng một nhịp; sóng gió lướt từ trái sang phải.
- **Mặt hồ**: shader `fx/water_shimmer.gdshader` vẽ đường gợn sáng lượn sóng trôi theo gió (chỉ tác động lên điểm ảnh xanh nước). `WaterLife` thêm gợn sóng nhỏ hiện lên rồi trôi đi (gió mạnh thì nhiều hơn), và 2–6 con cá bơi lượn.
- **Chỗ câu cá**: vòng gợn lan ra đều đều, thỉnh thoảng một con cá nhảy lên theo cung.
- **Lửa trại**: 4 khung hình chạy 8 hình/giây + phập phồng nhẹ, ngọn lửa nghiêng theo gió, tàn lửa bay lên và bị gió đẩy dạt.
- Test mới: gió chạy, cá không bao giờ bơi lên bờ, lửa đổi khung hình, có gợn sóng.

### Quyết định
- Mỗi loại vật dùng **chung một ShaderMaterial**, node Wind cập nhật vài material mỗi frame — rẻ dù có hàng trăm sprite.
- Đồng hồ gió chạy theo thời gian game (không dùng `TIME` của shader) để tạm dừng thì mọi thứ đứng yên, ×3 thì nhanh theo.
- Cá chỉ bơi theo đường thẳng mà mọi điểm trên đường đều là ô nước, đích chọn ở ô có 4 phía là nước → không lấn lên bờ.
- Bỏ gợn sóng vẽ cứng trong ô nước (lặp thành lưới), thay bằng gợn sóng động.
- Số tinh chỉnh hiệu ứng nằm ở đầu từng script (`wind.gd`, `water_life.gd`, `fish.gd`, `fish_spot_fx.gd`, `campfire_embers.gd`) vì là số hình ảnh, không phải cân bằng game.

---

## Đợt 0 — Dựng khung (2026-10-01)

**Trạng thái:** đã duyệt, commit `13d045a`.

### Đã làm

- **Project**: tên `Tribe Vibes`, renderer Compatibility (desktop + mobile), 1280×720, `canvas_items` + `expand`, main scene `main.tscn`, input map (WASD/mũi tên, Space, 1–3, Esc, F9), theme mặc định, bus âm thanh Master/Music/SFX/Voice, màu nền xanh cỏ đậm (nếu lỡ thấy mép map).
- **Autoload** (thứ tự nạp): `EventBus` → `SaveSystem` → `GameState` → `Loc` → `ArtLibrary` → `InputRouter`.
- **Đa ngôn ngữ** (`Loc`): `t`, `plural`, `number`, `set_language`, `available_languages`, `language_display_name`, signal `language_changed`. Ngôn ngữ lưu ở `user://settings.cfg`. F9 (chỉ bản debug) đổi vòng vi ↔ en; nhãn cập nhật ngay.
- **Font** Nunito (OFL, kèm `assets/fonts/OFL.txt`), dùng bản variable với độ đậm 650 cho chữ thường, 900 cho tiêu đề.
- **Bản đồ** 48×36 ô sinh theo seed: hang + lửa trại giữa map, rừng một phía (trái/phải), bãi đá phía đối diện, hồ phía trên hoặc dưới (hình hạt đậu, bờ bo tròn), đồng cỏ nhiều hoa phía còn lại (cũng là hướng cannibal sẽ đến), bụi quả quanh làng và ngoài đồng cỏ, 4 chỗ câu cá gần làng nhất. Mọi vật thể đều đi tới được từ cửa hang.
- **Camera**: kéo (chuột trái ở chỗ trống / chuột giữa / một ngón / WASD / touchpad hai ngón), zoom về phía con trỏ (lăn chuột / chụm hai ngón / chụm touchpad), mượt, không bao giờ lộ ra ngoài map, vẫn chạy khi tạm dừng.
- **Hình tạm SVG** (2×, viền nâu, màu ấm): 3 ô cỏ, 2 mảng cỏ, 2 bãi đất, 15 ô nước, 2 loại cây, gốc cây, 2 cỡ đá, bụi có/hết quả, 3 hoa, 2 khóm cỏ, chỗ câu cá, hang, lửa trại + ngọn lửa phập phồng.
- **Test headless** (25 test): i18n (fallback, tham số, số nhiều, định dạng số, CSV sạch), sinh map trên 12 seed (lặp lại được, đủ tài nguyên, đúng bố cục, không chồng nhau, tới được hết), InputRouter (click, kéo, lăn, chuột phải, chuột giả lập, chạm, chụm, nhấn giữ, kéo-giao-việc), dựng World thật.
- **Công cụ**: `tools/gen_water_tiles.gd` (sinh hình nước), `tools/screenshot.tscn` (chụp màn hình), `tools/strict_warnings.cfg` (soi cảnh báo GDScript).
- **Tài liệu**: `ASSET_SPEC.md`, `i18n/README.md`, `CLAUDE.md`, `PLAN.md`, file này.

### Quyết định & lý do

- **Art vẽ 2×, hiển thị ×0.5** — nét khi zoom ×2 và trên điện thoại. TileMapLayer dùng ô 128 px với node scale 0.5; mọi toạ độ ô đi qua `WorldGrid` (64 px) để không ai phải tính scale.
- **Nước kiểu dual-grid** (lớp nước lệch nửa ô): 15 hình là đủ cho mọi hình dạng bờ, góc bo là 1/4 hình tròn nên ô nước lẻ thành vũng tròn và bờ bậc thang thành đường cong. Hình sinh bằng code để dễ đổi màu.
- **Cây/đá/bụi là node**, không phải tile — vì cần y-sort với thổ dân, đặt chỗ, tương tác, đổi hình khi hết.
- **Hang và lửa trại là `Building`** dựng từ `data/buildings.gd` ngay từ giờ, để Đợt 3 chỉ cần thêm trạng thái móng/hư hại, không phải viết lại.
- **Mật độ rừng tối đa 0.42**: cao hơn ~0.4 thì rừng thành bức tường, cây bên trong không tới được và bị bỏ → rừng rỗng ruột.
- **Fallback tiếng Việt**: CSV import không nén (`compress=0`); `Loc` chép chữ vi vào mọi ô trống của ngôn ngữ khác lúc khởi động → cả `Loc.t` lẫn chế độ tự dịch của Control đều không hiện chữ rỗng. Mỗi lần chạy in một dòng `[Loc] 'en' thiếu …` để biết còn bao nhiêu câu chưa dịch.
- **Tự nạp mọi `.translation` trong `i18n/`**: thêm cột vào CSV là có ngôn ngữ mới, không cần sửa Project Settings (đã thử với cột `ja` tạm rồi xoá).
- **Ghi chú trong CSV**: dòng bắt đầu bằng `#` (đủ dấu phẩy) được Godot bỏ qua — có test canh.
- **Input**: bắt đầu cử chỉ ở `_unhandled_input` (UI được ưu tiên), theo dõi/kết thúc ở `_input` (kéo lướt qua UI không đứt); bỏ chuột giả lập từ cảm ứng để không nhận đôi. Nhấn giữ 0.4 s đo bằng thời gian thật.
- **Tốc độ game** dùng `Engine.time_scale` + `SceneTree.paused`; camera và InputRouter `PROCESS_MODE_ALWAYS`, camera dùng thời gian thật.
- **Seed**: `--seed=N` trên dòng lệnh > `Balance.DEBUG_FIXED_SEED` > ngẫu nhiên.
- **Ô cỏ trơn chiếm ~45%** + mảng cỏ sáng/tối lớn rải ngẫu nhiên: lúc đầu hoa văn cỏ lặp thành lưới khi zoom gần, nhìn rất "ô vuông".
- Đổi tên enum hướng trong `MapData` thành `Edge` vì Godot có sẵn enum toàn cục `Side` (gây lỗi parse khó hiểu).

### Còn biết / để sau

- Bảng debug góc trên-trái che một phần map (chỉ có ở bản debug, sẽ thay bằng HUD thật ở Đợt 2).
- `SaveSystem` mới có phần setting và hàm đọc/ghi JSON; lưu ván chơi làm ở Đợt 3.
- Bản Web chưa xuất (Đợt 6). Chưa có âm thanh.
- Bãi đá hơi nhiều đá nhỏ lấm tấm; xem lại khi có thổ dân đi đập đá.
