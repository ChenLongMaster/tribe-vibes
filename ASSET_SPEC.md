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
| `buildings/cave` | 384×320 | 192×160 | (0.5, 0.95) | Hang xuất phát, chiếm **3×2 ô**. Cửa hang ở giữa mép dưới (thổ dân chui ra ở đó). Phần trên cao hơn footprint là "lưng" hang. |
| `buildings/campfire` | 128×112 | 64×56 | (0.5, 0.85) | Lửa trại (đá + củi, **không** có ngọn lửa). Chiếm 1 ô. |
| `buildings/campfire_flame_01` … `04` | 80×104 | 40×52 | (0.5, 1.0) | 4 khung hình ngọn lửa, chạy 8 hình/giây theo thứ tự 01→04. Vẽ chồng lên lửa trại, lệch `(0, -12)` px. Giữ chân lửa cùng một chỗ ở mọi khung, chỉ đổi phần ngọn. Muốn nhiều khung hơn: thêm file và thêm key vào `extra_art_frames` trong `data/buildings.gd`. |

### Hiệu ứng (`fx/`)

| Key | Cỡ file (2×) | Hiển thị | Neo | Ghi chú |
|---|---|---|---|---|
| `fx/ember` | 16×16 | 2–5 (ngẫu nhiên) | (0.5, 0.5) | Một đốm tàn lửa tròn. Code tô màu từ vàng sang đỏ rồi mờ dần, nên vẽ màu sáng. |

## Sẽ thêm ở các đợt sau

Danh sách sẽ được bổ sung vào bảng trên khi làm tới (tên dự kiến theo `MVP_PROMPT.md` mục 7):

- **Đợt 1 — thổ dân:** `villager/head_01..03`, `villager/face_happy|sad|blink|sleep|surprised`, `villager/hair_01..05`, `villager/body_01..03`, `villager/arm`, `villager/leg`, `villager/accessory_01..03`; icon cảm xúc (đói, buồn ngủ, vui, yêu, sợ) và icon việc.
- **Đợt 2:** thú (lợn rừng, hươu), icon tài nguyên, đồ khuân trên đầu.
- **Đợt 3:** lều, bếp, kho, kho vũ khí, sân nhảy — mỗi cái 3 trạng thái: móng, hoàn thành, hư hại; icon nút tốc độ.
- **Đợt 5:** cannibal (mặt nạ xương, sơn chiến) và biến thể màu, chùy.
