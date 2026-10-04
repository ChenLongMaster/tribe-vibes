# ASSET_SPEC — Quy cách hình ảnh Tribe Vibes

Tài liệu này liệt kê **mọi** file hình game đang dùng, để bạn vẽ art thật thay cho hình tạm mà **không phải sửa code**.

> **Phong cách đã chốt 2026-10-04:** tiền sử thô mộc, thủ công, hơi ngố nhưng dễ thương, gần cảm giác Prehistoric Tribes; thêm nét Việt nhẹ qua tre/mây/cỏ/rơm, đồ đất và hoa văn Lạc Việt cách điệu. Chất liệu có nếp, khâu, sờn và nút buộc; màu ấm, viền nâu #4E342E, dáng mềm/bo tròn. Lấy cảm hứng, không chép hình gốc hay ép tái dựng lịch sử. Chi tiết: GAME_DESIGN mục 7.

> **Góc vẽ:** 2D 3/4 nhìn từ trên **và chếch một bên**, mái/mặt trên và chiều sâu ngang cùng rõ; mặt cửa xiên theo khối. Lều hướng trước-phải. Cảm giác khoảng 45–60°, hình đã duyệt là chuẩn, không ép isometric chuẩn; giữ camera/map và lưới vuông 64 px. Tránh cửa nhìn thẳng, mái phẳng chính diện hoặc chỉ nghiêng theo chiều cao. Công trình có chân/nền trải đúng footprint. Thổ dân chibi từ hơi trên cao, giữ biểu cảm đọc được; icon UI phẳng.

> **Ba cấp lều đã duyệt:** đều da thú thuôn nhọn phủ cỏ/rơm, khung tre/mây; cấp 1 nhỏ/cũ rách/vá/cỏ thưa, cấp 2 lớn hơn/lành/gọn, cấp 3 lớn nhất/cỏ rơm trang trí/chim Lạc-mặt trời-răng cưa. Không biến lều thành nhà sàn. Thân 76%/89%/100% quanh cùng chân (128,276), chung khung 256×300 và sân/footprint 2×2. Các cấp cần khác rõ bằng cỡ/dáng/độ hoàn thiện trước chi tiết nhỏ. Rách của cấp 1 chỉ là art, không phải hư hại gameplay.

> **Chuẩn tham chiếu:** `build/art-review/2026-10-04/tents-v7/after/footprint.png`, `levels.png`, `village_zoom_1.png`. Art mới dùng cùng nét/màu/góc và chất thủ công; vật liệu theo chức năng, không bắt mọi công trình dùng da hoặc mái thuyền. Trạng thái từng nhóm đã áp dụng/chưa vẽ lại nằm ở mục dưới; tài liệu này không mở thêm phạm vi. Giữ tên file, khung/neo (đổi thì sửa cả ArtSpecs), vẽ 2×/hiển thị ×0.5, không vẽ chữ.

> **Lượng lúc sinh tài nguyên (chốt 2026-10-04):** bụi quả mới sinh luôn đầy **100%**, dùng hình đầy quả. Chỉ sỏi/củi được khác lượng ban đầu; hình bụi quả thưa/trụi dành cho trạng thái đã bị hái, mọc lại thì đầy. Đây là quy tắc dữ liệu sinh, không chỉ chọn texture đầy cho một bụi thực tế thiếu quả.

## Tài nguyên đã áp dụng và chuẩn style hiện hành (2026-10-04)

- Game dùng trực tiếp SVG trong assets/placeholder/env qua ResourceNode/ArtLibrary: tree_01/tree_03, tree_stump/bamboo_stump, bush_100/50/20/empty, rock_big/rock_small và twigs/pebbles ở các mức100/50/20. Đây là art đã áp dụng, không chỉ hình phác trong build.
- Cây lá rộng/tre/gốc, đá/củi/sỏi dùng góc3/4 v6: thấy mặt trên rộng và chiều sâu trước–sau/hông phải, cùng cảm giác lều trước-phải. Cây thân đứng thẳng, không xoay cả sprite. Cây thông tree_02 giữ nguyên.
- Bụi dâu tây dùng v7: tán mềm v5 đã duyệt, quả riêng lẻ đỏ tươi, tròn mọng, nhỏ65%, số quả18/9/4; không ghép đôi, không dùng tán phân tầng v6. Quả giảm khi hái, trụi vẫn giữ tán. Bụi mới sinh đầy100%; số quả là hình minh hoạ, không phải số món gameplay.
- Giữ style tiền sử thủ công, mềm/bo tròn, màu ấm/viền #4E342E, nét Việt gợi nhẹ và vật liệu hợp chức năng. Lều da+cỏ là chuẩn góc, không buộc mọi công trình thành lều. Bếp là ngoại lệ bố cục đã duyệt: sân chính diện, mái khu nấu chếch phải, chiếu/bàn dọc, người ngồi trái–phải. Thổ dân chibi nhỏ, đọc rõ mặt và đồ cầm. Icon UI phẳng; không còn icon việc thường trực trên đầu, vẫn giữ cảnh báo nhu cầu/bong bóng/biển.
- Chuẩn tài nguyên: build/art-review/2026-10-04/resources-v7/after/village_zoom_1.png và strawberries.png; các loại khác giữ góc v6. Vách đá/nước/nền/cỏ trang trí, kho/lò rèn/sân nhảy/hang/lửa trại và các bộ nhân vật ngoài01 chưa vẽ lại. Không đổi khung/neo/cỡ file trong đợt cập nhật tài liệu này.

## Bếp đã áp dụng vào game (2026-10-04)

- Chuẩn v7 đã duyệt: footprint3×2 ở cả ba cấp; khung384×336, hiển thị192×168, sân384×256 từy64→320; neo192,296=(0.5,37/42), khớp Building.FOOT_INSET12. Sân76/89/100%, mái nấu chéo phải, chiếu/bàn dọc, khách ở hai bên. Giữ tỉ lệ dân game0.65; người trong phác cũ nhỏ hơn, không dùng số đó để đổi rig game.
- Hình đầy đủ giữ key buildings/kitchen_1..3 cho bóng mờ/menu. Hình sống tách36 lớp chung khung/neo qua ArtLibrary, y-sort theo điểm tiếp đất: floor/fence_back/cook/roof/pole/steam/serving/seats và từng dining. Mái làm nguồn bóng, sân không đổ bóng cao. Không vẽ chữ.
- Generator: python tools/gen_building_art.py, helper hình tự chứa trong tools/kitchen_art.py, không đọc build. Đường đi và ghế dùng data/kitchen_layout.gd, mọi toạ độ raw theo2× cùng generator. Thay art bếp đang hoạt động phải thay bộ lớp tương ứng, chỉ thay ảnh composite sẽ chỉ đổi menu/bóng mờ.
- Món chín bày trên quầy riêng (tối đa6 bát nhỏ đại diện lượng dự trữ, số chính xác6/10/16 trên panel), không bày quanh sân. Muôi props/cooking_spoon là dụng cụ cầm thật trong rig; icon việc thường trực trên đầu đã bỏ. Cảnh báo nằm trên mái góc trên-trái theo cấp, không ở tâm sân.
- Ảnh game chuẩn tại build/art-review/2026-10-04/kitchen-live-v1/after: village_zoom_1/levels/construction/work và kitchen_1..3. Cảnh live dùng TaskCook/TaskEat thật, giữ từng người tại khoảnh khắc ăn/nấu để chụp đủ4/6/8 khách và1/2/3 đầu bếp; không phải một khoảnh khắc tự nhiên của ván chơi. Các mục phác bên dưới chỉ lưu lịch sử.

## Lịch sử phác khu bếp có người (2026-10-04)


- **Mẫu mới nhất v7:** `build/art-review/2026-10-04/kitchen-compound-v7-vertical/levels.png`/`layout.png`/`footprint.png`, giữ khung384×336 vàfootprint3×2 của v6. Chiếu/bàn ăn trục dài dọc màn hình, chân bàn vẫn đứng thẳng, người ngồi trái–phải; bàn bày món là quầy riêng dưới-trái. Khu nấu lớn/hoàn thiện dần: mái sờn+nồi; mái chắc+chum/cối/chày/muôi treo; mái lớn nhiều lớp+khung gỗ dày/quầy chuẩn bị/bếp-nồi phụ/rây đan/gùi. Tỉ lệ phần nấu thử52/60/67%, sân76/89/100%,4/6/8 người; không thay rig game. ArtLibrary/ArtSpecs/neo và footprint code hiện hành chưa đổi; v6 dưới đây ghi lịch sử trước khi đổi trục bàn.

- **Chuẩn bố cục mới nhất v6:** `build/art-review/2026-10-04/kitchen-compound-v6-six-cells/levels.png`/`layout.png`/`footprint.png`. Cả ba cấp giữ thiết kế footprint**3×2 = 6 ô**, khung phác**384×336 ở2×**; sân gốc384×256 từy64, phần sân/nội thất thu quanh(192,192) theo**76%/89%/100%**. Cấp1 vòng đá/hai chiếu/4 người; cấp2 đá+tre mảnh/ba bàn đá xếp tam giác/6 người; cấp3 đá+gỗ dày/bốn bàn gỗ2×2/8 người. Ngồi hai bên trái–phải, khu nấu chếch sang phải, đủ bốn chân; bàn bày món riêng dưới-trái và cổng trước cạnh bàn. Tách chân gần khỏi nồi, mái/rào/bàn/người theo lớp. Đây là scene dựng riêng trong build; ArtLibrary/ArtSpecs/SVG bếp đang dùng và footprint code2×2 chưa đổi, neo chính thức chưa đăng ký. Góc/sân/số chỗ ở v1–v4 dưới đây là lịch sử đã được thay bằng yêu cầu v6; v5 dở dang bỏ theo lời đính chính. Rig game không đổi; người phác dùng tỉ lệ đồng đều ở cả ba cấp.

- **Mẫu mới nhất v4:** `build/art-review/2026-10-04/kitchen-compound-v4-tiers/levels.png`/`layout.png`. Giữ sân chữ nhật512×448/đề xuất4×3, khu nấu chéo trước-phải khoảng45° như lều, khu ăn chính diện. Cấp1 vòng đá + hai chiếu cho bốn người (không bàn/rào); cấp2 đá+rào tre mảnh + ba bàn đá; cấp3 đá+rào gỗ dày có giằng + bốn bàn gỗ. Thêm chi tiết vật liệu/trang trí riêng, tách từng bàn/mái/rào/nhân vật để thử che khuất. Bản v3 dưới đây là lịch sử; phác v4 chưa thay ArtLibrary/ArtSpecs hay gameplay, chưa chốt số chỗ ăn cấp2–3.

- **Mẫu mới v3 — sân chữ nhật:** `build/art-review/2026-10-04/kitchen-compound-v3-rectangle/levels.png` và `layout.png`, trái→phải cấp1→3. Hàng rào tre / chân đá+tre / chân đá+gỗ, chừa cổng phía trước; mái che nấu ở góc trên-trái có chiều sâu dọc, bàn ăn giữ thẳng. Khung thử512×448 (2×), sân512×384 ứng với đề xuất4×3. Lớp hàng rào phía xa/gần tách để không che sai người. Chỉ mẫu build chờ duyệt; không đăng ký ArtLibrary/ArtSpecs hay đổi footprint bếp trong game. Hai chỗ ăn giữ giống nhau để so vật liệu, chưa đại diện sức chứa theo cấp.

- **Mẫu góc mới v2:** `build/art-review/2026-10-04/kitchen-compound-v2-front/inhabited.png` và `layout.png`: chính diện từ trên xuống, chỉ nghiêng dọc theo yêu cầu mới; cạnh trước mái/bàn nằm ngang, nồi và lỗ lửa quay ra trước. Cùng năm lớp384×448, sân3×3 và hai người ăn; lều tham chiếu giữ nguyên. Chỉ mẫu so sánh, không thay quy tắc góc chung trước khi duyệt. V1 dưới đây là bản xiên ngang cũ để đối chiếu.

- Đặt tại `build/art-review/2026-10-04/kitchen-compound-v1/`, chưa đăng ký key ArtLibrary. Khu nấu sau-trái dưới mái cỏ một phần, khu ăn trước-phải với bàn thấp/ghế khúc gỗ; lối đi giữa hai khu. Cùng góc 3/4 chếch trước-phải với lều.
- Năm lớp thử `floor/back/roof/table/front.svg` chung khung **384×448** (2×), phần sân 384×384 nằm từ y64; thể hiện đề xuất **3×3**. Bản dựng dùng rig01 hiện có, một người nấu và hai người ăn; script tư thế ngồi ăn chỉ nằm trong build. Tách mái và bàn để thử che khuất nhân vật.
- Xem `inhabited.png` (có người) và `layout.png` (bố cục trống); chạy lại bằng `godot --path . res://build/art-review/2026-10-04/kitchen-compound-v1/preview.tscn`. Đây là cảnh dựng kiểm tra hình, chưa có AI đi vào/chọn ghế. **Bếp đang dùng vẫn 2×2, kitchen_1 khung256×320/neo(0.5,0.925)**; chưa thay SVG game, ArtSpecs hay footprint. Cần duyệt bố cục trước khi xác định neo/lớp chính thức.

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
| `env/tree_01` | 192×256 | 96×128 | (0.5, 0.92) | Cây lá rộng 3/4 trước-phải, tán lệch phân mảng hữu cơ có mặt trên xiên rộng/hông thấp, mặt trên sáng, mặt dưới tối; có khe lộ chạc, thân cong/gốc bè, lá cách điệu. Neo ở gốc thân, chặn 1 ô. |
| `env/tree_02` | 176×272 | 88×136 | (0.5, 0.93) | Cây lá kim (nhiều hơn ở sâu trong rừng). |
| `env/tree_03` | 176×272 | 88×136 | (0.5, 0.93) | Bụi tre 3/4 có gốc trước/sau trên đất xiên, thân thẳng, lá co chiều sâu, đốt/miệng thân nhìn từ trên; biến thể cây cho gỗ (rìu), cùng luật cây non/chặt/mọc lại. Giữ thông tree_02. |
| `env/tree_stump` | 96×72 | 48×36 | (0.5, 0.8) | Gốc cây 3/4: mặt cắt xiên rộng, vân vòng, hông phải tối/rễ trước-sau; sau khi chặt hết. |
| `env/bamboo_stump` | 96×72 | 48×36 | (0.5, 0.8) | Gốc tre sau chặt, đoạn thân rỗng cắt lệch nhau/xếp trước-sau trên đất xiên, cùng neo/khung gốc cây. |
| `env/rock_big_100` / `_50` / `_20` | 160×128 | 80×64 | (0.5, 0.88) | Tảng đá xám ngà 3/4 trước-phải, mặt trên xiên rộng/sáng, hông phải và mặt trước thấp khác sắc, ít rêu; lúc sinh đầy. Theo lượng còn lại: > 50% nguyên vẹn; 20–50% nhỏ lại, sứt mẻ, vài mảnh vụn dưới chân; < 20% chỉ còn mẩu nhỏ + đá vụn. **Cùng khung hình, cùng chân** để đổi hình không bị nhảy. |
| `env/rock_small_100` / `_50` / `_20` | 112×88 | 56×44 | (0.5, 0.88) | Tảng đá nhỏ, 3 mức như trên (vẫn cần cuốc như đá to). |
| `env/bush_100` / `_50` / `_20` | 192×160 | 96×80 (rộng ~1,5 ô) | (0.5, 0.91) | **Bụi dâu tây cách điệu** dùng lại tán/lá mềm v5 theo yêu cầu (không dùng tán phân tầng v6); sum suê, lá ba chét có răng cưa nhẹ; từng quả riêng lẻ đỏ tươi tròn đầy, bóng mọng, hạt vàng nhỏ và đài xanh: quả vẽ bằng 65% cỡ v5: đầy (18 quả) / còn nửa (9 quả) / còn ít (4 quả). Sinh mới amount=capacity; chỉ đổi mức sau khi hái. Giữ nguyên dáng tán lá giữa các mức. |
| `env/bush_empty` | 192×160 | 96×80 | (0.5, 0.91) | Cùng bụi, đã hái trụi (chờ 60 ngày ra quả lại) — chỉ còn cuống. |
| `env/flower_01` … `03` | 48×56 | 24×28 | (0.5, 0.95) | Hoa trang trí (hồng, vàng, tím). Không chặn đường. |
| `env/grass_tuft_01` … `02` | 64×48 | 32×24 | (0.5, 0.95) | Khóm cỏ trang trí. |
| `env/tall_grass_01` … `02` | 72×80 | 36×40 | (0.5, 0.97) | Cỏ cao trang trí (bản 02 có bông cỏ lau khô). |
| `env/fern_01` … `02` | 96×72 | 48×36 | (0.5, 0.92) | Dương xỉ trang trí, nhiều dưới tán rừng. |
| `env/shrub_01` … `02` | 96×64 | 48×32 | (0.5, 0.92) | Bụi lá trang trí — **không có quả** (để khỏi lẫn với bụi quả). |
| `env/reeds_01` | 64×96 | 32×48 | (0.5, 0.97) | Lau sậy ven hồ. |
| `env/mushroom_01` | 40×36 | 20×18 | (0.5, 0.94) | Nấm nhỏ dưới tán cây. |

**Quy tắc cây cỏ trang trí** (mọi hình `env/` ở trên trừ mỏ tài nguyên): chỉ để nhìn, phủ kín map, nên vẽ **màu xanh chìm, viền xanh đậm** (`#4F7A2A`), không viền nâu đậm `#4E342E`, không quả, không đá — để người chơi nhìn là biết không phải thứ giao việc được (mỏ tài nguyên mới có viền nâu đậm và màu nổi). Game vẽ chúng hàng loạt (MultiMesh), lật ngang ngẫu nhiên, to nhỏ ±15%, lay theo gió. Sân đất, đường mòn, vòng đá quanh sân vẽ bằng code (không có file hình).
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
Cả bộ khung cũ cao ~72 px; bộ thử góc cao ngày 2026-10-03 cao ~62 px trước khi nhân `VILLAGER_SCALE` 0,65 (~40 px trong thế giới). **Mặt quay ra trước, hơi hướng sang PHẢI** — code tự lật khi đi sang trái. Bộ thử có đỉnh tóc rộng, mặt thấp và vai nhìn từ trên, thân/chân co ngắn. Các hình head_02–03, hair_02–05, body_02–03 giữ nguyên.

**Bốn lớp đầu** (đầu, mặt, tóc, phụ kiện) vẽ trên **cùng một khung 80×80**, chồng khít lên nhau, neo chung ở **cổ** `(0.5, 0.9)` — tức điểm (40, 72) trong ảnh. Bộ 01: đầu rộng khoảng 60 px, cao khoảng 58 px, cằm ở y≈68; tóc phủ đỉnh từ y≈3 đến y≈43, cổ nối xuống điểm neo.

| Key | Cỡ file (2×) | Hiển thị | Neo | Tô màu bằng code? | Ghi chú |
|---|---|---|---|---|---|
| `villager/head_01` … `03` | 80×80 | 40×40 | (0.5, 0.9) cổ | **Có — màu da** | Đầu + tai phía sau. Vẽ trắng/xám rất nhạt, viền nâu. |
| `villager/face_01_happy` | 80×80 | 40×40 | (0.5, 0.9) | Không | Bộ mặt số 01, biểu cảm vui. Mắt nằm khoảng (40, 47) và (58, 47), miệng y≈60; phần mặt thấp hơn để thấy nhiều đỉnh đầu. |
| `villager/face_01_sad` · `face_01_blink` · `face_01_sleep` · `face_01_surprised` | 80×80 | 40×40 | (0.5, 0.9) | Không | Buồn · chớp mắt (cũng dùng khi gãi, dụi mắt) · ngủ · ngạc nhiên/ngáp. **Mỗi bộ mặt phải đủ 5 biểu cảm.** Thêm kiểu mặt mới = vẽ bộ `face_02_*` rồi tăng `FACE_COUNT` trong `villager/villager_palette.gd`. |
| `villager/hair_01` … `05` | 80×80 | 40×40 | (0.5, 0.9) | **Có — màu tóc** | 01 tóc dựng, 02 búi, 03 tóc dài, 04 đuôi ngựa, 05 chỏm tóc. Vẽ trắng/xám nhạt. |
| `villager/accessory_01` … `03` | 80×80 | 40×40 | (0.5, 0.9) | Không | 01 xương cài tóc, 02 lông chim, 03 bông hoa. |
| `villager/body_01` | 56×40 | 28×20 | (0.5, 1.0) mép dưới vạt áo | **Có — màu áo lông** | Bộ thử: vai elip có mặt trên, vạt áo ngắn. Đốm/hoạ tiết xám đậm hơn nền. |
| `villager/body_02` · `03` | 56×48 | 28×24 | (0.5, 1.0) mép dưới vạt áo | **Có — màu áo lông** | Giữ hình cũ, vẫn ghép được với khớp mới. |
| `villager/arm` | 16×28 | 8×14 | (0.5, 0.1) vai | **Có — màu da** | Tay co ngắn, thấy mặt trên vai/bàn tay; xoay quanh (8, 2.8) trong file. Khoảng cách tới bàn tay trong rig = 11 px hiển thị. |
| `villager/leg` | 22×26 | 11×13 | (0.36, 0.1) hông | **Có — màu da** | Chân co ngắn, bàn chân hướng sang phải, thấy mặt trên; xoay quanh (7.92, 2.6) trong file. |
| `villager/shadow` | 64×20 | 32×10 | (0.5, 0.5) | Không | Bóng dưới chân. |

Vị trí các khớp (hông, vai, cổ) nằm ở đầu `villager/villager_rig.gd` — nếu art thật tỉ lệ khác thì chỉnh ở đó. Thổ dân lưu ngoại hình bằng **ID mảnh** (vd `hair_03`, `face_01`) và mã màu, nên vẽ thêm mảnh mới chỉ cần đặt đúng tên file rồi tăng số đếm (`HAIR_COUNT`…) trong `villager/villager_palette.gd`; bảng màu da/áo/tóc cũng ở đó.

Khớp của bản thử (px hiển thị, gốc ở chân): hông sau/trước (-4, -12)/(5, -12), vai sau/trước (-9, -25)/(9, -25), cổ (0, -27), đáy áo (0, -9). Đồ khuân neo y=-57 (bù khoảng trống trong hình đồ để nằm sát tóc), biển giơ y=-46, đồ sau lưng (-7, -19). Các điểm neo tỉ lệ trong `data/art_specs.gd` giữ nguyên; chỉ khung body_01/arm/leg đổi như bảng trên.

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
| `icons/stat_energy` | 48×48 | 22×22 | tâm | Chỉ số **Thể lực**: chữ **Zzz** xanh (ngủ là hồi sức). |
| `icons/stat_fun_happy` | 48×48 | 22×22 | tâm | Chỉ số **Giải trí** khi cao (≥ 60): mặt cười tít mắt. |
| `icons/stat_fun_ok` | 48×48 | 22×22 | tâm | Giải trí vừa (≥ 30): mặt bình thường, miệng thẳng. |
| `icons/stat_fun_angry` | 48×48 | 22×22 | tâm | Giải trí thấp: mặt **bực bội đỏ cả mặt**, lông mày chau (sắp đình công). Cũng nhấp nháy trên đầu khi giải trí thấp. |
| `icons/skill_chop` · `skill_mine` · `skill_gather` · `skill_hunt` · `skill_fish` · `skill_cook` · `skill_build` · `skill_smith` | 48×48 | 22×22 | tâm | Icon 8 kỹ năng: rìu, cuốc, giỏ quả, giáo (**Săn bắn & chiến đấu** — một kỹ năng), cần câu, nồi, búa, đe. Dùng trong bảng thông tin (kèm số cấp) và làm icon việc trên đầu. |
| `icons/skill_fight` | 48×48 | — | tâm | Chùy xương — **tạm chưa dùng** (kỹ năng Chiến đấu đã gộp vào Săn bắn, dùng icon giáo). Giữ lại cho vũ khí cannibal Đợt 5. |
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
| `props/bucket` | 48×48 | ~17×17 | (0.5, 0.15) quai | Xô gỗ rỗng, xách thõng lúc nhặt sỏi. Cũng là icon việc "nhặt sỏi" trên đầu. |
| `props/bucket_pebbles` | 48×48 | ~26×26 | tâm | Xô đầy sỏi — giơ trên đầu khi khuân về. |
| `props/log` | 72×36 | ~40×20 | tâm | Khúc gỗ (= 10 gỗ) — giơ trên đầu khi khuân về. |
| `props/twig_bundle` | 48×40 | ~26×22 | tâm | Bó củi buộc dây — giơ trên đầu khi khuân; icon việc "nhặt củi". |
| `props/fishing_rod` | 48×48 | ~17×17 | tâm | Cần câu, **vẽ chéo từ dưới-trái lên trên-phải**, đầu cần ở góc trên-phải (16, −18 px so với tâm — `ROD_TIP_TEXTURE_OFFSET`). Dây câu + phao do code vẽ. |
| `env/twigs_100` / `_50` / `_20` | 160×96 | 80×48 (rộng hơn 1 ô) | (0.5, 0.73) | **Đống củi** dưới tán cây: cành khô cong/chạc nằm chồng, mặt cắt đầu gỗ (12 / 6 / 3 cành). Không chặn đường. |
| `env/pebbles_100` / `_50` / `_20` | 160×96 | 80×48 | (0.5, 0.65) | **Bãi sỏi** cạnh đá tảng / chân vách: nền sỏi vụn + nhiều viên đá cuội to nhỏ (18 / 9 / 4 viên, nhặt dần từ rìa vào). Không chặn đường. |
| (vách đá) | — | — | — | **Vẽ bằng code, không có file hình** (`world/cliff_ridge.gd`): mỗi dãy vách là một bức vách liền — mặt trên lởm chởm có rêu, mặt đứng có vân nứt dọc, đá vụn dưới chân, viền nâu đậm chỉ ở mép ngoài. Màu sắc là các hằng `TOP_*`, `FACE_*`, `CRACK`, `MOSS*` ở đầu file. Muốn dùng art thật sau này thì nên vẽ dạng **dải lặp ngang** (texture mặt đứng + texture mặt trên) để dán theo đường biên, không vẽ từng khối. |
| `animals/boar` · `animals/deer` (đã có) | | ×0.7 | | Dùng lại làm **xác thú vác chổng vó trên đầu** (code lật dọc) — vẽ thú quay sang phải, chân ở mép dưới. |

Đồ nghề rèn (rìu, cuốc, giáo) dùng lại `icons/skill_chop` · `skill_mine` · `skill_hunt`: cầm tay khi làm, **đeo xiên sau lưng** khi không dùng, vẽ trên tấm biển khi thiếu.

### Bong bóng & tấm biển (thổ dân "nói" bằng hình)

| Key | Cỡ file (2×) | Hiển thị | Neo | Ghi chú |
|---|---|---|---|---|
| `ui/thought_bubble` | 96×88 | 48×44 | (0.5, 1.0) giữa mép dưới | Mây suy nghĩ (đang muốn gì đó): đám mây trắng + 2 chấm tròn nhỏ dẫn xuống đầu. Phần mây ở nửa trên; code đặt icon vào tâm mây (`THOUGHT_ICON_POS` trong `villager/overhead.gd`). Để trống ruột mây, **không vẽ gì bên trong**. |
| `props/sign` | 84×96 | 42×48 | (0.5, 1.0) đáy cán | Tấm biển gỗ khi cần người chơi ra tay (đói lả, đình công, hết cây, thiếu đồ nghề…). **Đứng thì cắm xuống đất** trước mặt (đáy cán chạm đất, một tay vịn), **ngồi thì hai tay giơ lên** trên đầu. Mặt biển **để trống** — code đặt icon vào giữa (`SIGN_ICON_POS` trong `villager/villager_rig.gd`). Không vẽ chữ. |
| `icons/cross` | 48×48 | ~26×26 | tâm | Dấu ✕ đỏ, đè lên icon trên tấm biển: "hết rồi / không làm" (hết cây, kho đầy, đủ người, đình công). Biển "thiếu đồ nghề / nguyên liệu" **không** có dấu này. Nét dày, có viền để nổi trên mọi icon. |
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
| `buildings/tent_1` · `_2` · `_3` | 256×300 | 128×150 (phủ 2×2 ô) | (0.5, 0.92) | Cả ba là lều da phủ cỏ/rơm, cửa chếch phải. Thân 76%/89%/100% quanh chân (128,276), sân đất cố định 2×2. Cấp 1 nhỏ, da nâu cũ rách, miếng vá, mép sờn, cỏ thưa. Cấp 2 lớn hơn, da lành sáng, mái cỏ ngay ngắn. Cấp 3 lớn nhất, mái cỏ dày, tua rơm cửa, chim Lạc/mặt trời/dải răng cưa màu đất-đồng trên da. |
| `buildings/kitchen_1` · `_2` · `_3` | 384×336 | 192×168 (3×2) | (0.5,37/42), raw(192,296) | Composite mẫu v7 đã duyệt: sân nhỏ/vừa/lớn, mái nấu chéo phải,2 chiếu/3 bàn đá tam giác/4 bàn gỗ,4/6/8 khách. Dùng cho menu/bóng mờ; game sống dùng các lớp dưới. |
| `buildings/kitchen/floor_1..3` | 384×336 | 192×168 | (0.5,37/42) | Sân đất76/89/100%, nằm dưới mọi đồ/người. |
| `buildings/kitchen/fence_back_1..3` · `fence_front_1..3` | 384×336 | 192×168 | (0.5,37/42) | Đá / đá+tre mảnh / đá+gỗ dày, cổng trước-trái; hai lớp xa/gần. |
| `buildings/kitchen/cook_1..3` · `roof_1..3` · `pole_1..3` · `steam_1..3` | 384×336 | 192×168 | (0.5,37/42) | Khu nấu/mái/chân gần/hơi nước tách lớp;52/60/67%, bốn cọc và dụng cụ tăng qua cấp. |
| `buildings/kitchen/serving_1..3` · `seats_1..3` | 384×336 | 192×168 | (0.5,37/42) | Quầy món dưới-trái và ghế hai bên, seats_1 trong suốt vì ngồi chiếu. |
| `buildings/kitchen/dining_1_0..1` · `dining_2_0..2` · `dining_3_0..3` | 384×336 | 192×168 | (0.5,37/42) | Mỗi chiếu/bàn một lớp để người đi trước/sau; trục dài dọc. |
| `props/cooking_spoon` | 20×80 | 10×40, thu theo rig | (0.5,0.075), raw(10,6) | Muôi gỗ neo cán ở tay, xoay khi khuấy nồi. |

| `buildings/storage_1` · `_2` · `_3` | 384×380 | 192×190 (3×3) | (0.5, 0.9368) | Kho: cấp 1 mái che dựa + đống gỗ, đống đá; cấp 2 nhà vách gỗ cửa lớn; cấp 3 nhà kho to, nền đá, cửa đôi. |
| `buildings/forge_1` · `_2` · `_3` | 384×320 | 192×160 (3×2) | (0.5, 0.925) | Lò rèn: lò đá vòm bên trái (miệng lò đỏ rực), đe đá ở giữa; cấp 2 thêm mái + ống bễ; cấp 3 ống khói cao + cờ. **Chừa trống phần trước-trái, giữa và phải** để code dựng rìu (trái), cuốc (giữa), giáo (phải). |
| `buildings/dance_floor_1` · `_2` · `_3` | 384×400 | 192×200 (3×3) | (0.5, 0.94) | Sân nhảy **phẳng, đi lên được** (thổ dân đứng trên): cấp 1 sân đất viền đá + 2 đuốc; cấp 2 sàn gỗ + dây cờ; cấp 3 sàn đá ô màu + trống + 4 đuốc. Giữ phần giữa sân trống, ít chi tiết. |
| `buildings/foundation_2x2` | 256×256 | 128×128 | (0.5, 1.0) | Bộ thử mới: nền đất vuông bo góc phủ đúng2×2 ô, khung dây xiên trước-phải bên trong, cọc thấp có mặt trên elip/hông, cành tre và đá có mặt trên; cọc sau nằm trọn khung. Code đặt ở mép dưới diện tích. |
| `buildings/foundation_3x2` | 384×256 | 192×128 | (0.5, 1.0) | Móng3×2 (lò rèn): cùng bộ thử nền vuông/cọc/dây/vật liệu xiên như móng2×2. |
| `buildings/foundation_3x3` | 384×384 | 192×192 | (0.5, 1.0) | Móng3×3 (kho, sân nhảy): cùng bộ thử nền vuông/cọc/dây/vật liệu xiên như móng2×2. |
| `villager/hard_hat` | 80×80 | 40×40 | (0.5, 0.9) như tóc | Mũ công trường vàng của thợ xây, vẽ trên cùng khung đầu 80×80 với tóc (đội trùm lên tóc). |

Ánh lửa ban đêm (lửa trại, bếp, lò rèn) là hình tròn mờ **do code tạo** (GradientTexture2D), không cần file.

**Soát góc lều (bản phân cấp 2026-10-04):** khung 256×300, sân/footprint `x=0..256, y=44..300` giữ nguyên. Nhóm thân và phụ kiện thu quanh `(128,276)` với tỉ lệ `0.76/0.89/1.0`; khung PNG/SVG và neo không đổi. Cấp 1 mép da sờn, lỗ rách nhỏ và vá; cấp 2 bỏ lỗ rách/vá thô, cỏ phủ gọn; cấp 3 chóp cỏ rộng hơn tới y≈162, tua rơm buộc cửa, chim Lạc/mặt trời/dải răng cưa đủ lớn để đọc. Chóp sau-trái, cửa trước-phải, chân elip vẫn giữ cảm giác góc cao. Không đổi camera/renderer, core, móng hay thổ dân.

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

**Bản thử tài nguyên 2026-10-04:** sinh bằng `python tools/gen_resource_art.py`. Các khung/neo cũ giữ nguyên; chỉ thêm tree_03/bamboo_stump vào ArtSpecs. Bảng xem các mức: `build/art-review/2026-10-04/resources-v7/after/board.png`; hàng 1 cây lá rộng/tre/lều đã duyệt/gốc cây/gốc tre, hàng 2 bụi đầy→nửa→ít→trụi, hàng 3 đá lớn 3 mức và đá nhỏ, hàng 4 củi 3 mức và sỏi cũ. Đây là đợt thử nhóm tài nguyên, chưa vẽ lại toàn bộ map.

**Sửa hình 2026-10-04 (v2):** chỉ tree_01 và bush_100/50/20/empty đổi hình; giữ khung/neo, bóng/chân, luật sinh đầy và lượng sau khi hái. Cây lá rộng giảm cảm giác quả cầu đều; dâu tằm là bụi cách điệu để giữ khả năng đọc mỏ thức ăn.

**Sửa hình 2026-10-04 (v3):** cây v2 đã được duyệt, giữ nguyên. Bụi quả hiện dùng dâu tây đỏ thay dâu tằm theo yêu cầu; 9/4/2 chùm, mỗi chùm 2 quả, trụi giữ lá. Khung/neo và luật sinh đầy 100% không đổi.

**Sửa hình 2026-10-04 (v4):** dâu tây mọc riêng lẻ, có khoảng lá giữa quả, dáng tròn đầy và điểm sáng gợi mọng nước; 9/4/2 quả, không ghép đôi. Giữ khung 192×160/neo 0.5/0.91 và sinh mới đầy 100%. Cây đã duyệt giữ nguyên.

**Màu dâu 2026-10-04 (v5):** giữ nguyên dáng quả v4 đã duyệt; tăng đỏ bằng thân quả `#DF3235`/`#C4262E`, mảng sáng `#F1534A`; điểm bóng/hạt/lá không đổi. Chỉ bush_100/50/20 đổi màu, bush_empty giữ nguyên.

**Góc tài nguyên 2026-10-04 (v6):** dùng lều đã duyệt làm chuẩn mặt trên/hông trước-phải. Generator dùng hai trục đất xiên (0.86, 0.40) và (-0.65, 0.50) để đặt gốc tre/lá/củi/sỏi; phương đứng vẫn thẳng. Cây/bụi có mặt tán trên co chiều sâu, đá có hông phải riêng. Củi giữ cành cong/chạc chồng theo trục đất, sỏi có mặt trên và hông thấp. Tất cả khung/neo/sản lượng/sinh mới đầy vẫn giữ; ArtSpecs không đổi. Phạm vi 20 SVG thử; tree_02/vách/nước/decor/công trình cũ chưa đổi, không xem chúng là chuẩn góc mới.

**Bụi dâu 2026-10-04 (v7):** người dùng chọn lại tán/lá v5, không dùng bụi phân tầng v6. Giữ dáng quả tròn mọng/màu đỏ đã duyệt, thu quả còn65% và tăng18/9/4 quả đơn; trụi giữ tán. Khung192×160/neo0.5/0.91 và sinh mới đầy100% không đổi. Các tài nguyên khác giữ góc v6 đã được đồng ý; không sửa lõi/map.

**Bếp/móng thử 2026-10-04:** sinh bằng `python tools/gen_building_art.py`; chỉ kitchen_1 và foundation_2x2/3x2/3x3 đổi. Bếp256×320/neo0.5,0.925; móng256×256/384×256/384×384, neo0.5,1.0 giữ nguyên (ArtSpecs không đổi). Warning cố định x128,y≈112 trong file bếp vẫn nằm trên mái; chừa mép trước cho các slot món chín hiện có. Đặt cạnh lều mẫu: `build/art-review/2026-10-04/kitchen-foundation-v1/after/board.png`. Bếp cấp2–3 và các công trình khác chưa triển khai.
