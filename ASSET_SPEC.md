# ASSET_SPEC — Quy cách hình ảnh Tribe Vibes

Tài liệu này liệt kê **mọi** file hình game đang dùng, để bạn vẽ art thật thay cho hình tạm mà **không phải sửa code**.

## Cách thay art

1. Vẽ hình, xuất **PNG** (nền trong suốt). WebP hoặc SVG cũng được.
2. Đặt vào `assets/art/` với **đúng đường dẫn con và tên file** như cột "Key" bên dưới.
   Ví dụ key `env/tree_01` → `assets/art/env/tree_01.png`.
3. Mở Godot editor một lần để nó import file mới. Xong — game tự dùng hình của bạn
   (`ArtLibrary` luôn ưu tiên `assets/art/`, không có mới lấy `assets/placeholder/`).
4. Muốn quay về hình tạm: xoá file trong `assets/art/`.

## Quy tắc chung

| Quy tắc | Chi tiết |
|---|---|
| **Vẽ 2×** | Mọi hình vẽ gấp đôi cỡ hiển thị (cột "Cỡ file"). Game thu nhỏ còn một nửa (`ArtLibrary.ART_SCALE = 0.5`) nên vẫn nét khi phóng to ×2 và trên điện thoại màn hình nét. |
| **Điểm neo** | Cột "Neo" ghi theo tỉ lệ ảnh: `(0.5, 1.0)` = giữa mép dưới, `(0.5, 0.5)` = tâm. Với vật đứng (cây, đá, nhà) điểm neo là **chỗ chân chạm đất**. Nếu art của bạn neo khác, sửa số trong `data/art_specs.gd` (cùng key). |
| **Không vẽ chữ vào hình** | Biển hiệu, nút, thẻ nhiệm vụ… để trống chỗ chữ. Chữ luôn là `Label` đè lên, để còn dịch sang ngôn ngữ khác. |
| **Viền** | Nâu đậm `#4E342E`, dày **6 px ở file 2×** (= 3 px trên màn hình). Vật nhỏ (hoa, cỏ) có thể viền mảnh hơn. |
| **Bóng đổ** | Vật đứng tự có một hình elip bóng mờ dưới chân (màu `#3E2723`, độ mờ ~18%), vẽ luôn trong hình. |
| **Ô nền** | Phủ kín 100%, không trong suốt, **liền mép** (đặt cạnh nhau không lộ đường nối). Tránh chi tiết nổi bật ở cùng một chỗ trên mọi ô, nhìn sẽ thành lưới. |
| **Bộ phận tô màu bằng code** | (Từ Đợt 1 — da, áo lông thổ dân.) Vẽ phần cần đổi màu bằng **trắng/xám sáng**, viền tối giữ nguyên. Code nhân màu vào (`modulate`), nên trắng → đúng màu da, viền tối vẫn tối. |
| **Bảng màu gợi ý** | Cỏ `#8BC34A`/`#7CB342` · đất `#C8A27A` · nước `#4FC3F7` · gỗ `#8D6E63` · đá `#9E9E9E` · viền `#4E342E` · da `#F2C29B`/`#D9A066`/`#A9714B` · áo lông `#A1887F`/`#FFB74D`/`#E57373` |

## Danh sách file hiện có (Đợt 0)

Lưới bản đồ: mỗi ô **64×64 px** trên màn hình (= 128×128 ở file 2×).

### Nền (`ground/`)

| Key | Cỡ file (2×) | Hiển thị | Neo | Ghi chú |
|---|---|---|---|---|
| `ground/grass_01` | 128×128 | 64×64 | — (ô lưới) | Cỏ có một khóm cỏ nhỏ. ~30% số ô. |
| `ground/grass_02` | 128×128 | 64×64 | — | Cỏ có vài đốm sáng. ~25% số ô. |
| `ground/grass_03` | 128×128 | 64×64 | — | Cỏ trơn. ~45% số ô — nên để đơn giản nhất. |
| `ground/grass_patch_01` | 320×224 | 160×112 | (0.5, 0.5) | Mảng cỏ **sáng**, bán trong suốt, mép mềm. Rải ngẫu nhiên để nền đỡ đều màu. |
| `ground/grass_patch_02` | 320×224 | 160×112 | (0.5, 0.5) | Mảng cỏ **tối**, như trên. |
| `ground/dirt_patch_01` | 384×256 | 192×128 | (0.5, 0.5) | Bãi đất lớn — "sân làng" quanh lửa trại. Không viền. |
| `ground/dirt_patch_02` | 256×160 | 128×80 | (0.5, 0.5) | Bãi đất nhỏ rải quanh làng. |

### Nước (`water/`) — kiểu "dual-grid"

| Key | Cỡ file (2×) | Hiển thị | Neo | Ghi chú |
|---|---|---|---|---|
| `water/water_01` … `water/water_15` | 128×128 | 64×64 | Tâm hình = **góc chung của 4 ô lưới** | 15 hình bờ hồ. |

Cách hiểu số trong tên: mỗi hình nằm ở góc chung của 4 ô; cộng các số của ô **có nước**:
trên-trái = **1**, trên-phải = **2**, dưới-trái = **4**, dưới-phải = **8**.
Ví dụ `water_03` = hai ô trên là nước (bờ nằm ngang ở giữa hình), `water_15` = toàn nước.

- Đường bờ luôn chạm mép hình ở **giữa cạnh** (toạ độ 64 ở file 2×) và vuông góc với mép, để các hình nối liền nhau.
- Góc bo hiện tại là 1/4 hình tròn bán kính 64 (file 2×) quanh tâm mỗi ô lưới.
- Hình tạm được **sinh bằng code**: `tools/gen_water_tiles.gd` (đổi màu/độ bo ở đầu file rồi chạy lại). Chỉ cần vẽ 5 dạng gốc (01, 03, 09, 07, 15), 10 hình còn lại là xoay 90°.

### Thiên nhiên (`env/`)

| Key | Cỡ file (2×) | Hiển thị | Neo | Ghi chú |
|---|---|---|---|---|
| `env/tree_01` | 192×256 | 96×128 | (0.5, 0.92) | Cây tán tròn. Neo ở gốc thân. Chặn 1 ô. |
| `env/tree_02` | 176×272 | 88×136 | (0.5, 0.93) | Cây lá kim (nhiều hơn ở sâu trong rừng). |
| `env/tree_stump` | 96×72 | 48×36 | (0.5, 0.8) | Gốc cây sau khi chặt hết (Đợt 2). |
| `env/rock_big` | 160×128 | 80×64 | (0.5, 0.88) | Tảng đá lớn. |
| `env/rock_small` | 112×88 | 56×44 | (0.5, 0.86) | Tảng đá nhỏ. |
| `env/bush_berries` | 128×112 | 64×56 | (0.5, 0.9) | Bụi có quả mọng. |
| `env/bush_empty` | 128×112 | 64×56 | (0.5, 0.9) | Cùng bụi, đã hái hết quả — **giữ nguyên dáng** với bản có quả. |
| `env/flower_01` … `03` | 48×56 | 24×28 | (0.5, 0.95) | Hoa trang trí (hồng, vàng, tím). Không chặn đường. |
| `env/grass_tuft_01` … `02` | 64×48 | 32×24 | (0.5, 0.95) | Khóm cỏ trang trí. |
| `env/fish_spot` | 128×128 | 64×64 | (0.5, 0.5) | Chỗ câu cá: bọt nước + bóng đàn cá mờ. Đặt giữa một ô nước sát bờ. Vòng gợn và cá nhảy do code thêm. |
| `env/ripple_ring` | 128×64 | 64×32 | (0.5, 0.5) | Vòng gợn trắng (elip) — code phóng to dần và làm mờ ở chỗ câu cá. |
| `env/fish_jump` | 72×40 | 36×20 | (0.5, 0.5) | Cá nhìn ngang, **đầu quay sang phải**. Code cho nhảy theo cung và lật hướng. |
| `env/fish_shadow` | 64×32 | 32×16 | (0.5, 0.5) | Bóng cá nhìn từ trên xuống, **đầu quay sang phải**, một màu, không viền (code làm mờ ~45% cho giống ở dưới nước). |
| `env/ripple` | 64×24 | 32×12 | (0.5, 0.5) | Gợn sóng nhỏ màu trắng, hiện lên rồi trôi theo gió trên mặt hồ. |

**Đung đưa theo gió:** cỏ, hoa, bụi, cây và ngọn lửa được code làm nghiêng (mép **dưới** ảnh đứng yên, mép **trên** lệch nhiều nhất). Vì vậy chân vật phải nằm sát mép dưới ảnh, đừng để khoảng trống lớn bên dưới.

### Công trình (`buildings/`)

| Key | Cỡ file (2×) | Hiển thị | Neo | Ghi chú |
|---|---|---|---|---|
| `buildings/cave` | 384×320 | 192×160 | (0.5, 0.95) | Hang xuất phát, chiếm **3×2 ô** — cũng là **kho tạm** lúc đầu (Đợt 3). Cửa hang ở giữa mép dưới (thổ dân chui ra ở đó). Phần trên cao hơn footprint là "lưng" hang. |
| `buildings/campfire` | 128×112 | 64×56 | (0.5, 0.85) | Lửa trại (đá + củi, **không** có ngọn lửa). Chiếm 1 ô. |
| `buildings/campfire_flame_01` … `04` | 80×104 | 40×52 | (0.5, 1.0) | 4 khung hình ngọn lửa, chạy 8 hình/giây theo thứ tự 01→04. Vẽ chồng lên lửa trại, lệch `(0, -12)` px. Giữ chân lửa cùng một chỗ ở mọi khung, chỉ đổi phần ngọn. Muốn nhiều khung hơn: thêm file và thêm key vào `extra_art_frames` trong `data/buildings.gd`. |

### Hiệu ứng (`fx/`)

| Key | Cỡ file (2×) | Hiển thị | Neo | Ghi chú |
|---|---|---|---|---|
| `fx/ember` | 16×16 | 2–5 (ngẫu nhiên) | (0.5, 0.5) | Một đốm tàn lửa tròn. Code tô màu từ vàng sang đỏ rồi mờ dần, nên vẽ màu sáng. |

### Thổ dân (`villager/`) — Đợt 1

Thổ dân ghép từ nhiều mảnh, code tự xoay/nảy để hoạt họa (không cần vẽ từng frame).
Cả nhân vật cao ~72 px trên màn hình, đầu chiếm ~45% (chibi). **Mọi mảnh vẽ nhìn nghiêng 3/4 quay sang PHẢI** — code tự lật khi đi sang trái.

**Bốn lớp đầu** (đầu, mặt, tóc, phụ kiện) vẽ trên **cùng một khung 80×80**, chồng khít lên nhau, neo chung ở **cổ** `(0.5, 0.9)` — tức điểm (40, 72) trong ảnh. Vẽ đầu tròn khoảng tâm (40, 40), bán kính ~29.

| Key | Cỡ file (2×) | Hiển thị | Neo | Tô màu bằng code? | Ghi chú |
|---|---|---|---|---|---|
| `villager/head_01` … `03` | 80×80 | 40×40 | (0.5, 0.9) cổ | **Có — màu da** | Đầu + tai phía sau. Vẽ trắng/xám rất nhạt, viền nâu. |
| `villager/face_01_happy` | 80×80 | 40×40 | (0.5, 0.9) | Không | Bộ mặt số 01, biểu cảm vui. Mắt nằm khoảng (40, 42) và (58, 42). |
| `villager/face_01_sad` · `face_01_blink` · `face_01_sleep` · `face_01_surprised` | 80×80 | 40×40 | (0.5, 0.9) | Không | Buồn · chớp mắt (cũng dùng khi gãi, dụi mắt) · ngủ · ngạc nhiên/ngáp. **Mỗi bộ mặt phải đủ 5 biểu cảm.** Thêm kiểu mặt mới = vẽ bộ `face_02_*` rồi tăng `FACE_COUNT` trong `villager/villager_palette.gd`. |
| `villager/hair_01` … `05` | 80×80 | 40×40 | (0.5, 0.9) | **Có — màu tóc** | 01 tóc dựng, 02 búi, 03 tóc dài, 04 đuôi ngựa, 05 chỏm tóc. Vẽ trắng/xám nhạt. |
| `villager/accessory_01` … `03` | 80×80 | 40×40 | (0.5, 0.9) | Không | 01 xương cài tóc, 02 lông chim, 03 bông hoa. |
| `villager/body_01` … `03` | 56×48 | 28×24 | (0.5, 1.0) mép dưới vạt áo | **Có — màu áo lông** | Áo lông từ cổ xuống hông. Đốm/hoạ tiết vẽ xám đậm hơn nền một chút. |
| `villager/arm` | 16×32 | 8×16 | (0.5, 0.1) vai | **Có — màu da** | Tay buông thẳng xuống, bàn tay tròn ở dưới. Code xoay quanh vai. |
| `villager/leg` | 22×30 | 11×15 | (0.36, 0.1) hông | **Có — màu da** | Chân thẳng, bàn chân hướng sang phải. Code xoay quanh hông. |
| `villager/shadow` | 64×20 | 32×10 | (0.5, 0.5) | Không | Bóng dưới chân. |

Vị trí các khớp (hông, vai, cổ) nằm ở đầu `villager/villager_rig.gd` — nếu art thật tỉ lệ khác thì chỉnh ở đó. Thổ dân lưu ngoại hình bằng **ID mảnh** (vd `hair_03`, `face_01`) và mã màu, nên vẽ thêm mảnh mới chỉ cần đặt đúng tên file rồi tăng số đếm (`HAIR_COUNT`…) trong `villager/villager_palette.gd`; bảng màu da/áo/tóc cũng ở đó.

### Icon & hiệu ứng nhỏ — Đợt 1 / 1.5

| Key | Cỡ file (2×) | Hiển thị | Neo | Ghi chú |
|---|---|---|---|---|
| `icons/hunger` | 48×48 | 24×24 | tâm | Đùi thịt — icon chỉ số Đói nhấp nháy trên đầu. |
| `icons/sleepy` | 48×48 | 24×24 | tâm | Hai chữ Z — mây nghĩ "buồn ngủ", bong bóng khi gục ngủ / nghỉ tay. |
| `icons/happy` | 48×48 | 24×24 | tâm | Nốt nhạc — vui. |
| `icons/love` | 48×48 | 24×24 | tâm | Trái tim. |
| `icons/scared` | 48×48 | 24×24 | tâm | Dấu chấm than (Đợt 5). |
| `icons/berry` | 48×48 | 24×24 | tâm | Quả mọng — icon "đang đi ăn" trên đầu, và quả cầm trên tay khi ăn. |
| `icons/star` | 48×48 | 24×24 | tâm | Ngôi sao (xem thêm cỡ nhỏ ở dưới). |
| `icons/close` | 48×48 | 24×24 (nút 44×44) | tâm | Nút ✕ đóng bảng. |
| `icons/mood_happy` · `mood_ok` · `mood_sad` | 48×48 | 26×26 | tâm | Mặt tâm trạng trong bảng thông tin. |
| `icons/stat_health` | 48×48 | 22×22 | tâm | Chỉ số **Máu** ❤ (tim đỏ có dấu cộng). Dùng trong bảng thông tin và nhấp nháy trên đầu khi thấp. |
| `icons/hunger` | 48×48 | 22×22 | tâm | Chỉ số **Đói** 🍖. |
| `icons/stat_energy` | 48×48 | 22×22 | tâm | Chỉ số **Thể lực** ⚡. |
| `icons/stat_fun` | 48×48 | 22×22 | tâm | Chỉ số **Giải trí** 🎉 (pháo giấy). |
| `icons/skill_chop` · `skill_mine` · `skill_gather` · `skill_hunt` · `skill_fish` · `skill_cook` · `skill_build` · `skill_smith` · `skill_fight` | 48×48 | 24×24 | tâm | Icon 9 loại việc/kỹ năng: rìu, cuốc, giỏ quả, giáo, cần câu, nồi, búa, đe, chùy xương. Dùng trong bảng thông tin (kèm sao cấp), sau này làm icon việc trên đầu. |
| `icons/star` (nhỏ) | 48×48 | 10×10 | tâm | Mỗi sao = một cấp kỹ năng. Cũng dùng làm sao quay quanh đầu khi ngất. |
| `icons/love` (nhỏ) | 48×48 | 14×14 | tâm | Tim cạnh kỹ năng = việc thích. |
| `fx/zzz` | 32×32 | 8–18 | tâm | Một chữ Z bay lên khi ngủ. |
| `fx/heart` | 32×32 | 16×16 | tâm | Tim bay lên khi tặng hoa / hẹn hò (Đợt 4). |
| `ui/selection_ring` | 96×40 | 48×20 | tâm | Vòng vàng dưới chân thổ dân đang được chọn. |

Bong bóng nói là khung vẽ bằng code (không phải hình) chứa 1–2 icon. **Thổ dân không nói chữ** — xem bảng "Bong bóng & tấm biển" bên dưới.

### Lao động & tài nguyên — Đợt 2

| Key | Cỡ file (2×) | Hiển thị | Neo | Ghi chú |
|---|---|---|---|---|
| `icons/res_wood` · `res_stone` · `res_food` | 48×48 | 22–26 | tâm | 3 tài nguyên chung trên thanh HUD và số bay "+10 gỗ": bó gỗ, hai hòn đá, **đùi thịt (thức ăn)**. |
| `icons/res_meat` · `res_fish` · `icons/berry` | 48×48 | 22–26 | tâm | Món thức ăn cụ thể: cầm trên tay lúc ăn; cá cũng giơ trên đầu khi khuân. |
| `icons/res_meal` | 48×48 | ~20 | tâm | Bát món chín — đồ riêng của bếp, bày quanh lửa trại (tối đa 4 chỗ) cho thấy còn bao nhiêu. |
| `icons/angry` | 48×48 | 22–24 | tâm | 💢 đình công — bong bóng và icon trên đầu suốt lúc đình công. |
| `icons/skill_*` (đã có) | 48×48 | 24×24 | tâm | Nay dùng thêm làm **icon việc trên đầu** và **đồ nghề cầm tay** (rìu, cuốc, cần câu, giáo, muôi nồi). Code xoay đồ nghề theo cánh tay, nghiêng thêm `TOOL_TILT` trong `villager/villager_rig.gd` — vẽ cán chéo từ dưới-trái lên trên-phải như hình tạm. |
| `animals/boar` | 128×96 | 64×48 | (0.48, 0.92) chân | Lợn rừng, **quay mặt sang PHẢI** (code tự lật). Có bóng elip dưới chân. |
| `animals/deer` | 112×128 | 56×64 | (0.45, 0.94) chân | Hươu nhỏ, quay sang phải. |
| `fx/dust` | 32×32 | 6–14 | tâm | Một cụm bụi trắng mờ. Code tô màu (gỗ: nâu nhạt, đá: xám) và cho bay toả ra khi chặt/đập, khói "bụp" khi thú bị săn biến mất. |
| `ui/speed_pause` · `speed_1` · `speed_2` · `speed_3` | 48×48 | ~32 trong nút 44×44 | tâm | Nút tốc độ: hai vạch, 1/2/3 tam giác. **Không vẽ chữ "×2"** — chỉ hình. Nền nút do code vẽ (vàng = đang chọn). |
| `ui/target_ring` | 128×56 | 64×28 (× cỡ mục tiêu) | tâm | Vòng elip nét đứt vàng dưới chân mục tiêu đang rê chuột / kéo tới / được giao. Code phóng to theo cỡ vật và nhịp phập phồng. |
| `ui/move_marker` | 64×64 | 32×32 | (0.375, 0.875) chân cột cờ | Lá cờ nhỏ cắm ở chỗ bảo thổ dân đi tới. |

Đường chấm chấm tới nơi được giao, đường kéo khi kéo-thả và số "+3 gỗ" đều vẽ bằng code (không cần hình).

### Đồ cầm tay, đồ khuân & thiên nhiên — Đợt 2.2

| Key | Cỡ file (2×) | Hiển thị | Neo | Ghi chú |
|---|---|---|---|---|
| `props/basket` | 48×48 | ~17×17 | (0.5, 0.15) quai | Giỏ đan rỗng, **xách thõng** dưới bàn tay lúc đi hái quả (không xoay theo tay). |
| `props/basket_berries` | 48×48 | ~26×26 | tâm | Giỏ đầy quả — giơ trên đầu khi khuân về. |
| `props/bucket` | 48×48 | ~17×17 | (0.5, 0.15) quai | Xô gỗ rỗng, xách thõng lúc nhặt đá cuội. Cũng là icon việc "nhặt đá cuội" trên đầu. |
| `props/bucket_pebbles` | 48×48 | ~26×26 | tâm | Xô đầy đá cuội — giơ trên đầu khi khuân về. |
| `props/log` | 72×36 | ~40×20 | tâm | Khúc gỗ (= 10 gỗ) — giơ trên đầu khi khuân về. |
| `props/twig_bundle` | 48×40 | ~26×22 | tâm | Bó củi buộc dây — giơ trên đầu khi khuân; icon việc "nhặt củi". |
| `props/fishing_rod` | 48×48 | ~17×17 | tâm | Cần câu, **vẽ chéo từ dưới-trái lên trên-phải**, đầu cần ở góc trên-phải (16, −18 px so với tâm — `ROD_TIP_TEXTURE_OFFSET`). Dây câu + phao do code vẽ. |
| `env/twigs` | 64×40 | 32×20 | (0.5, 0.75) | Củi rơi trên đất dưới tán cây. Không chặn đường. |
| `env/pebbles` | 64×40 | 32×20 | (0.5, 0.75) | Đá cuội quanh đá tảng. Không chặn đường. |
| `env/cliff` | 384×320 | 192×160 (phủ 3×2 ô) | (0.5, 0.97) chân vách | Vách đá lớn — một phần của map, không khai thác được. Đá tảng thỉnh thoảng lăn ra sát chân vách. |
| `animals/boar` · `animals/deer` (đã có) | | ×0.7 | | Dùng lại làm **xác thú vác chổng vó trên đầu** (code lật dọc) — vẽ thú quay sang phải, chân ở mép dưới. |

Đồ nghề rèn (rìu, cuốc, giáo) dùng lại `icons/skill_chop` · `skill_mine` · `skill_hunt`: cầm tay khi làm, **đeo xiên sau lưng** khi không dùng, vẽ trên tấm biển khi thiếu.

### Bong bóng & tấm biển (thổ dân "nói" bằng hình)

| Key | Cỡ file (2×) | Hiển thị | Neo | Ghi chú |
|---|---|---|---|---|
| `ui/thought_bubble` | 96×88 | 48×44 | (0.5, 1.0) giữa mép dưới | Mây suy nghĩ (đang muốn gì đó): đám mây trắng + 2 chấm tròn nhỏ dẫn xuống đầu. Phần mây ở nửa trên; code đặt icon vào tâm mây (`THOUGHT_ICON_POS` trong `villager/overhead.gd`). Để trống ruột mây, **không vẽ gì bên trong**. |
| `props/sign` | 84×96 | 42×48 | (0.5, 1.0) đáy cán | Tấm biển gỗ khi cần người chơi ra tay (đói lả, đình công, hết cây, thiếu đồ nghề…). **Đứng thì cắm xuống đất** trước mặt (đáy cán chạm đất, một tay vịn), **ngồi thì hai tay giơ lên** trên đầu. Mặt biển **để trống** — code đặt icon vào giữa (`SIGN_ICON_POS` trong `villager/villager_rig.gd`). Không vẽ chữ. |
| `icons/cross` | 48×48 | ~26×26 | tâm | Dấu ✕ đỏ, đè lên icon trên tấm biển: "hết rồi / không làm". Nét dày, có viền để nổi trên mọi icon. |
| `icons/question` | 48×48 | ~26×26 | tâm | Dấu "?" — mây nghĩ khi không tới được chỗ làm; cũng là một "từ" khi tán gẫu. |
| `icons/dots` | 48×48 | ~26×26 | tâm | Ba chấm "…" — mây nghĩ "lát nữa nhé" (bảo đi đâu khi đang ăn/ngủ). |

### Công trình xây được — Đợt 3

Quy ước chung cho hình công trình (để art thật thay vào là khớp lưới):

- **Rộng** = số ô ngang × 128 px (file 2×). **Mép dưới hình = mép dưới diện tích** công trình (hàng ô dưới cùng). Phần nhô lên (mái, ống khói, cờ) cứ vẽ cao lên trên, chiều cao tuỳ ý.
- **Neo** đặt cách mép dưới **24 px** (= `Building.FOOT_INSET` ×2) ở giữa chiều ngang: neo y = (cao − 24) ÷ cao. Đổi chiều cao hình thì sửa số neo trong `data/art_specs.gd`.
- Mỗi cấp một hình riêng, cấp sau to / đẹp hơn rõ rệt (người chơi nhìn là biết cấp mấy). Không cần vẽ hình "đang xây": game vẽ hình cấp kế tiếp **mờ, nhạt màu, mọc dần từ dưới lên** trên tấm móng; đang nâng cấp thì giữ hình cấp cũ và tự vẽ giàn giáo + thanh tiến độ bằng code.
- **Không vẽ** đồ riêng (bát món chín, rìu/cuốc/giáo bày quanh lò) và icon cảnh báo vào hình — code đặt sprite riêng theo số lượng thật (chỗ đặt trong `stock_display` của `data/buildings.gd`).
- Hình **hư hại** để Đợt 5.
- Hình tạm sinh bằng `tools/gen_building_art.py` (Python, chỉ là công cụ — game không cần).

| Key | Cỡ file (2×) | Hiển thị | Neo | Ghi chú |
|---|---|---|---|---|
| `buildings/tent_1` · `_2` · `_3` | 256×300 | 128×150 (phủ 2×2 ô) | (0.5, 0.92) | Lều ngủ: cấp 1 lều da trơn nhỏ; cấp 2 to hơn, vá màu, vòng đá quanh chân; cấp 3 lều vẽ hoa văn, lông chim trên đỉnh. Cửa lều tối ở giữa mép dưới (thổ dân đứng trước cửa rồi "chui vào"). |
| `buildings/kitchen_1` · `_2` · `_3` | 256×320 | 128×160 (2×2) | (0.5, 0.925) | Bếp: mái tranh trên 4 cột, bếp đá + nồi bốc hơi; cấp 2 thêm kệ hũ; cấp 3 thêm lò nướng đá có ống khói. Chừa chỗ trống hai bên chân để code bày bát món chín. |
| `buildings/storage_1` · `_2` · `_3` | 384×380 | 192×190 (3×3) | (0.5, 0.9368) | Kho: cấp 1 mái che dựa + đống gỗ, đống đá; cấp 2 nhà vách gỗ cửa lớn; cấp 3 nhà kho to, nền đá, cửa đôi. |
| `buildings/forge_1` · `_2` · `_3` | 384×320 | 192×160 (3×2) | (0.5, 0.925) | Lò rèn: lò đá vòm bên trái (miệng lò đỏ rực), đe đá ở giữa; cấp 2 thêm mái + ống bễ; cấp 3 ống khói cao + cờ. **Chừa trống phần trước-trái, giữa và phải** để code dựng rìu (trái), cuốc (giữa), giáo (phải). |
| `buildings/dance_floor_1` · `_2` · `_3` | 384×400 | 192×200 (3×3) | (0.5, 0.94) | Sân nhảy **phẳng, đi lên được** (thổ dân đứng trên): cấp 1 sân đất viền đá + 2 đuốc; cấp 2 sàn gỗ + dây cờ; cấp 3 sàn đá ô màu + trống + 4 đuốc. Giữ phần giữa sân trống, ít chi tiết. |
| `buildings/foundation_2x2` | 256×256 | 128×128 | (0.5, 1.0) | Móng: nền đất nện + cọc 4 góc + dây căng, phủ **đúng** diện tích. Code đặt ở mép dưới diện tích. |
| `buildings/foundation_3x2` | 384×256 | 192×128 | (0.5, 1.0) | Móng 3×2 (lò rèn). |
| `buildings/foundation_3x3` | 384×384 | 192×192 | (0.5, 1.0) | Móng 3×3 (kho, sân nhảy). |
| `villager/hard_hat` | 80×80 | 40×40 | (0.5, 0.9) như tóc | Mũ công trường vàng của thợ xây, vẽ trên cùng khung đầu 80×80 với tóc (đội trùm lên tóc). |

Ánh lửa ban đêm (lửa trại, bếp, lò rèn) là hình tròn mờ **do code tạo** (GradientTexture2D), không cần file.

### Icon & HUD — Đợt 3

| Key | Cỡ file (2×) | Hiển thị | Neo | Ghi chú |
|---|---|---|---|---|
| `icons/warning` | 48×48 | ~24×24 | tâm | Tam giác vàng có dấu "!" — trên mái công trình sản xuất thiếu người phụ trách; trong bảng công trình. |
| `icons/storage` | 48×48 | ~26×26 | tâm | Cái kho nhỏ (mái + vách + khúc gỗ, hòn đá) — vẽ trên tấm biển (gạch chéo) khi **kho đầy**. |
| `icons/upgrade` | 48×48 | ~24×24 | tâm | Mũi tên xanh lên — nút nâng cấp. |
| `icons/check` | 48×48 | ~30×30 | tâm | Dấu ✓ trong vòng xanh — nút xác nhận đặt công trình (cảm ứng). |
| `icons/save` · `icons/load` | 48×48 | ~30×30 | tâm | Nút lưu / tải ván. Không vẽ chữ. |
| `ui/sun` · `ui/moon` | 48×48 | 18×18 | tâm | Mặt trời / mặt trăng chạy trên cung của đồng hồ mặt trời (HUD). |
| `fx/confetti` | 16×24 | 8×12 | tâm | Mảnh pháo giấy **trắng** (code tô màu) khi xây xong / lên cấp. |
| `icons/skill_build` (đã có) | | | | Cũng là nút **Xây** trên HUD, búa trên tay thợ xây, icon thanh tiến độ gõ búa. |
| `icons/skill_smith` (đã có) | | | | Búa trên tay thợ rèn. |

## Sẽ thêm ở các đợt sau

Danh sách sẽ được bổ sung vào bảng trên khi làm tới (tên dự kiến theo `GAME_DESIGN.md` mục 7):

- **Đợt 4:** hoạt cảnh disco, nhật ký làng.
- **Đợt 5:** công trình **hư hại** (mỗi công trình × 3 cấp), cannibal (mặt nạ xương, sơn chiến) và biến thể màu, chùy.
