# ASSET_SPEC — Quy cách hình ảnh Tribe Vibes

Tài liệu này liệt kê **mọi** file hình game đang dùng, để bạn vẽ art thật thay cho hình tạm mà **không phải sửa code**.

> Khi thiết kế hoặc sửa công trình, **đọc [BUILDING_DESIGN.md](BUILDING_DESIGN.md) trước** để dùng đúng nguyên tắc đã duyệt và cách ráp scene/mảnh. File này giữ hợp đồng asset; GAME_DESIGN giữ luật và footprint/sức chứa.

> **Phong cách đã chốt 2026-10-04:** tiền sử thô mộc, thủ công, hơi ngố nhưng dễ thương, gần cảm giác Prehistoric Tribes; thêm nét Việt nhẹ qua tre/mây/cỏ/rơm, đồ đất và hoa văn Lạc Việt cách điệu. Chất liệu có nếp, khâu, sờn và nút buộc; màu ấm, viền nâu #4E342E, dáng mềm/bo tròn. Lấy cảm hứng, không chép hình gốc hay ép tái dựng lịch sử. Chi tiết: GAME_DESIGN mục 7.

> **Góc vẽ:** 2D 3/4 nhìn từ trên **và chếch một bên**, mái/mặt trên và chiều sâu ngang cùng rõ; mặt cửa xiên theo khối. Lều hướng trước-phải. Cảm giác khoảng 45–60°, hình đã duyệt là chuẩn, không ép isometric chuẩn; giữ camera/map và lưới vuông 64 px. Tránh cửa nhìn thẳng, mái phẳng chính diện hoặc chỉ nghiêng theo chiều cao. Công trình có chân/nền trải đúng footprint. Thổ dân chibi từ hơi trên cao, giữ biểu cảm đọc được; icon UI phẳng.

> **Ba cấp lều đã duyệt:** đều da thú thuôn nhọn phủ cỏ/rơm, khung tre/mây; cấp 1 nhỏ/cũ rách/vá/cỏ thưa, cấp 2 lớn hơn/lành/gọn, cấp 3 lớn nhất/cỏ rơm trang trí/chim Lạc-mặt trời-răng cưa. Không biến lều thành nhà sàn. Thân 76%/89%/100% quanh cùng chân (128,276), chung khung 256×300 và sân/footprint 2×2. Các cấp cần khác rõ bằng cỡ/dáng/độ hoàn thiện trước chi tiết nhỏ. Rách của cấp 1 chỉ là art, không phải hư hại gameplay.

> **Chuẩn tham chiếu:** `build/art-review/2026-10-04/tents-v7/after/footprint.png`, `levels.png`, `village_zoom_1.png`. Art mới dùng cùng nét/màu/góc và chất thủ công; vật liệu theo chức năng, không bắt mọi công trình dùng da hoặc mái thuyền. Trạng thái từng nhóm đã áp dụng/chưa vẽ lại nằm ở mục dưới; tài liệu này không mở thêm phạm vi. Giữ tên file, khung/neo (đổi thì sửa cả ArtSpecs), vẽ 2×/hiển thị ×0.5, không vẽ chữ.

> **Lượng lúc sinh tài nguyên (chốt 2026-10-04):** bụi quả mới sinh luôn đầy **100%**, dùng hình đầy quả. Chỉ sỏi/củi được khác lượng ban đầu; hình bụi quả thưa/trụi dành cho trạng thái đã bị hái, mọc lại thì đầy. Đây là quy tắc dữ liệu sinh, không chỉ chọn texture đầy cho một bụi thực tế thiếu quả.

## Chi tiết bếp ba cấp và khung PNG (2026-10-05) — ưu tiên hiện hành

- Scene cấp1 tách hai nhóm root: `MeatRack/Art` dùng `rack_1.svg`; `CookingCanopy/Cook` dùng `cook_1.svg` (thớt đá). Kéo/scale độc lập; marker Cook0/cảnh báo theo thớt. Hình/khung/neo/tọa độ ban đầu giữ nguyên, không sinh thêm asset hay đổi rào. Sau chỉnh vị trí cần Ctrl+S và Export menu / placement PNG.
- Con quay cấp3 đổi thành **heo rừng nguyên con**, mõm bè/ngà nhỏ, tai, chân gập và đuôi cong, màu nâu vàng đã nướng. Giữ key `buildings/kitchen/roast_chicken_3.svg` và node `RoastFire/Chicken` để tương thích scene/animation; khung512×552/neo256,504 không đổi. Cấp1 chim cút, cấp2 gà; giá/lửa/ghế/rào giữ nguyên. PNG kitchen_3 xuất lại từ scene, hình con quay vẫn là cùng MEAL.
- Cấp1 không mái/nồi: thớt đá có thịt và dao, giàn thịt gác bếp; chiếu bày món có viền riêng, món thịt/chim trên lá chuối. Chiếu khách dùng lá chuối, giá quay chim cút nhỏ. Cấp2 giữ mái cũ, giàn thịt khuất một phần, đôi đũa lệch nhẹ cạnh mỗi chén bàn ăn. Cấp3 mái lá xếp hàng/diềm gỗ/giằng/vách đan/mặt trời nhỏ, mỗi bàn có ống đũa tre.
- `buildings/kitchen/rack_1..2` và `chopsticks_3_0..3`: SVG512×552, neo(256,504), tỉ lệ(0.5,21/23), ×0.5. Node MeatRack / ChopstickHolder riêng; chỉ crop alpha vùng chọn. Giữ toàn bộ rào và nhóm nội thất người dùng đã chỉnh; marker Cook0 cấp1 theo thớt. Lá chuối/chén/đũa trong hình bàn; món dự trữ được thêm động theo kho.
- **PNG thật** `assets/art/buildings/kitchen_1..3.png`:576×552, hiển thị288×276, neo(288,504), vẫn tỉ lệ(0.5,21/23). Nới đệm ngang để chứa đá đã được người dùng chỉnh ngoài khung cũ; không scale/dời vật. **SVG composite/lớp** còn512×552/neo256,504, phục vụ fallback/generator. ArtSpecs dùng cùng neo tỉ lệ nên không cần đổi giá trị. Footprint vẫn4×3; khung xám xuất576×552 là hợp đồng hiện hành, thay số PNG cũ ở các mục lịch sử.
- `props/stone_kitchen_knife`:24×60, neo(12,9) = (0.5,0.15), hiển thị12×30 trước thu rig. `props/meal_smoked_meat` / `meal_roast_bird`:64×48, neo(32,24) = (0.5,0.5), hiển thị32×24 trước thu rig/quầy. Bày món cấp1 dùng hệ số0.28; rig dùng hệ số đồ cầm hiện hành. Không dùng icon chén khi dân cầm món chín cấp1.
- Biến thể thịt/chim chọn theo vị trí bếp/ô bày, không thêm loại kho/công thức hoặc dùng RNG mô phỏng. Bóng gian cấp1 theo thớt; cảnh báo theo giàn thấp. Khung/bảng màu/không chữ giữ nguyên. Nguồn bố cục là scene, generator không sinh đè các scene/PNG ráp tay.

## Rào bếp dùng instance mảnh (2026-10-05) — hiện hành

Ba scene kitchen_1..3 đã bỏ Sprite Art rào nguyên khối, thay bằng 42/79/79 instance trong FenceBack/FenceFront. Cấp1 đá; cấp2 đá/tre; cấp3 đá/gỗ. Các nhóm rào mở khoá, không gom chọn toàn nhóm; chọn từng mảnh để chỉnh. Đường bao/cổng theo toạ độ gốc, nội thất/marker/vùng tránh người dùng chỉnh giữ nguyên. Các lớp SVG512×552/neo256,504/footprint4×3 và ArtSpecs giữ nguyên; ba PNG576×552/neo288,504 assets/art/buildings/kitchen_1..3 đã xuất lại. SVG rào cũ không xoá nhưng không còn được ba scene nạp. Generator kit không sửa bố cục scene.

## Bộ mảnh trang trí ráp tay (2026-10-05)

20 SVG tại `assets/placeholder/props/modular/`, dùng qua scene cùng tên ở `buildings/parts/`. ArtLibrary ưu tiên art thật, hiển thị ×0.5; ArtSpecs khai báo neo tường minh. Không có chữ hoặc nền sân trong hình. Giữ góc cao, khối mềm, mặt trên sáng và hông phải tối.

| Key dưới props/modular/ | Khung SVG 2× | Neo px 2× | Chiều dài nối hiển thị |
|---|---|---|---|
| stone_01…08 | 96×64 | (48,54) | Viên đá riêng |
| bamboo_post, bamboo_post_tied, wood_post, wood_post_tied | 64×112 | (32,104) | Cọc ở chân |
| bamboo_h_32, wood_h_32 | 96×96 | (48,88) | 32 px; JoinA/B = (±16,0) |
| bamboo_h_64, wood_h_64 | 160×96 | (80,88) | 64 px; JoinA/B = (±32,0) |
| bamboo_v_32, wood_v_32 | 64×136 | (32,128) | 32 px; JoinA/B = (0,-32)/(0,0) |
| bamboo_v_64, wood_v_64 | 64×200 | (32,192) | 64 px; JoinA/B = (0,-64)/(0,0) |

Sprite crop alpha chỉ giảm vùng chọn trong suốt, giữ file/neo. Thanh không chứa cọc hoặc đá: đặt cọc ở JoinA/B, viên đá trong khe giữa cọc; hai thanh dùng chung cọc ở góc. Đá đổi scale đều, thanh nối thêm đoạn thay kéo giãn; không xoay/mirror hướng vẽ. Kit không tự tạo va chạm/đường đi hoặc thay scene bếp đã chỉnh. `catalog.tscn`, `examples/fence_examples.tscn` và README là nơi xem/học ráp; generator chỉ ghi SVG.

## Bố cục bếp chỉnh bằng scene Godot (2026-10-05) — hiện hành

- Nguồn bố cục là `buildings/kitchen_layouts/kitchen_1..3.tscn`; Root có nhóm CookingCanopy/Serving/RoastFire/Dining0… và rào ghép mảnh trong FenceBack/FenceFront. Sprite giữ ID ArtLibrary, dùng region_rect cắt khoảng trong suốt để chọn/nhìn từng vật dễ hơn. Crop chỉ ở Sprite, không đổi file SVG/khung/neo. Mỗi bàn có cặp ghế riêng `seating_<level>_<index>.svg`, cùng hợp đồng512×552; lớp seats_1..3 nguyên khối vẫn để tương thích/composite cũ.
- Position/Scale dương nhóm là nguồn chung cho hình, marker tương tác, mặt ghế và vùng tránh. KitchenLayout đọc transform scene, giữ raw chỉ làm trung gian đường đi; không cần sửa số Python/GDScript để dời vật. KitchenInterior nạp chính scene, ghép động món/lửa/gà/khói; cảnh báo và bóng mái theo nhóm. Gian nấu theo chi tiết ba cấp hiện hành;4×3/hiển thị0.5/4–6–8 khách/1–2–3 thợ, SVG512×552 và PNG576×552.
- Show Guides/Show People chỉ hiển thị trong editor. Dân mẫu đứng giữ cỡ người lớn0.65, không scale theo đồ vật; game thật dùng rig/animation hiện hành. Root/Sprite con khoá chọn; các nhóm nội thất chỉnh qua nhóm cha, rào chỉnh từng instance mảnh. Không xoay/mirror nhóm hoặc đổi tên/số marker tương tác.
- Nút Export menu / placement PNG trên root xuất assets/art/buildings/kitchen_1..3.png từ scene đang sửa, nền alpha/khung/neo giữ nguyên. Lưu scene trước khi xuất, chờ import rồi chạy lại. Đây là hình cho menu/bóng đặt/móng; cần xuất lại sau khi chỉnh bố cục. Nếu hình vượt khung xám thì báo warning và không ghi đè. Generator tạm không ghi đè scene hay PNG. Xem README trong thư mục scene.

## Giá quay theo sơ đồ và đầu bếp tương tác (2026-10-05) — bố cục gốc của scene

- Giữ mái/cọc gian nấu cũ; hoãn bản thử kiến trúc. Giá quay raw(158,210)/(154,210)/(282,187) qua ba cấp; cấp3 bàn/ghế hàng trên tâmY115 thay141 (lên26px raw), hàng dướiY234 giữ nguyên. Khung512×552/neo256,504/footprint4×3 giữ nguyên. Generator và KitchenLayout cùng tọa độ để hình/ghế/đường tránh khớp.
- Slot1 đầu bếp ở cấp2–3 đứng tại tâm giá+(48,8), quay xiên tay không bằng ANIM_ROAST; slot0 nồi chính, slot2 khu nấu phụ. Khi còn một người thì chuyển về slot0, không mất nguyên liệu nấu dở. Đây là cùng việc nấu hiện hành, không tạo công trình hay kho món mới.

## Phác kiến trúc gian nấu ba cấp (2026-10-05) — hoãn

- Cấp1 mái một dốc võng/sờn/vá thô; cấp2 mái cỏ hai tầng chồng, phên tre thấp phía sau và giằng chéo; cấp3 mái có nóc/hai mặt sáng-tối, mái phụ ngắn tựa khung xa và mặt trời nhỏ ở mép trước. Giữ hướng chếch phải và chân cọc/vị trí quầy/bàn/ghế/rào/bếp quay đã duyệt. Không tạo nền riêng.
- Bản thử riêng tại `build/art-review/2026-10-05/canopy-tiers/`: design.py dùng generator hiện hành làm nền, thay ba lớp cook/roof/pole theo kiến trúc mới, ghi SVG trong build/assets. Khung512×552/neo256,504/hiển thị0.5/footprint4×3 giữ nguyên. Preview nạp texture thử vào cache của phiên chụp, không ghi đè assets game. Xem after/empty_levels.png và live_levels.png; chờ duyệt trước khi đưa vào generator chính.

## Bếp than quay gà trong sân (2026-10-05)

- Giá quay nhỏ tại raw(128,238), thu theo sân76/89/100%; không dịch gian nấu/quầy/bàn/ghế/rào. Cấp1 chạc cây/xiên tre, cấp2 giá gỗ/vòng đá nhỏ, cấp3 giá dày/tay quay/khay hứng/bát gia vị. Gà vàng nâu, lửa thấp, khói mỏng, nền trong suốt và bóng tiếp xúc.
- Generator tạo ba lớp mỗi cấp `roast_base_1..3`, `roast_chicken_1..3`, `roast_fire_1..3` trong `buildings/kitchen/`; cùng khung512×552/neo(0.5,21/23)/hiển thị0.5. Composite kitchen_1..3 có đủ giá quay để menu/bóng mờ đồng bộ. Game ghép thành nhóm RoastFire, sort theo chân; thân gà co/lật quanh trục xiên mỗi8 giây game, lửa nhấp và khói vẽ bằng code, có phản hồi sáng khi chọn. Chỉ trang trí, không sinh món; đường nội thất tránh vùng raw72×40 quanh giá.

## Quầy thức ăn sát rào trái (2026-10-05) — ưu tiên mới nhất

- Quầy thức ăn giữ dáng dọc nhưng đặt sát rào trái, không canh tâm gian nấu: SERVING_CENTERS raw(54,238) cho cả ba cấp thayX97/105/113, giữY238. Chân quầy chừa khoảng6–8px raw với đá cạnh trái; mặt bàn vẫn gần rào tự nhiên. Điểm lấy món mỗi cấp raw(85,250), vật cản/món trên quầy/hướng lấy món theo tâm mới. Gian nấu, rào/đá, khu ăn và khung/neo giữ nguyên. Đây là đính chính vị trí quầy, ưu tiên hơn dòng “quầy cùng trục tâm gian nấu” của đợt trước.
- Ảnh/scene QA: `build/art-review/2026-10-05/serving-left/`.

## Bếp sát góc trái và đá chân rào (2026-10-05) — ưu tiên mới nhất

- Gian nấu cả ba cấp sát góc trên-trái, gốc raw(34,−24)/(33,−43)/(32,−60), giữ cỡ60/69/77% và hướng trước-phải. Chân cọc gần nhất cách đá/rào một khe nhỏ, mái được phủ qua rào; điểm đứng đầu bếp/icon cảnh báo/lớp sort đồng bộ. Quầy dọc cùng trục tâm gian nấu: SERVING_CENTERS raw(97,238)/(105,238)/(113,238), giữY238; FETCH_POINT mỗi cấp = tâm quầy+(31,12), vật cản và món bày trên quầy cùng dịch. Bàn/ghế/khu ăn giữ nguyên. Đá bếp méo/bo vai, đỉnh bè, không nhọn; cấp2–3 thêm2–4 viên mỗi khoang rào với cỡ lệch nhau để gần lấp đầy, chừa khe chân cọc. Chỉ thay hình đá trong bếp, không đổi mỏ đá/map.
- Nới khoảng trong suốt trên ảnh bếp48px2× để mái không bị cắt: mọi composite/lớp bếp512×552, neo(256,504)=(0.5,21/23), hiển thị0.5; hình cũ trong khung được cộng(0,48). KitchenLayout thêm FRAME_PADDING(0,48) trong đổi toạ độ và trừ ở đổi ngược, ArtSpecs đồng bộ. Sân4×3/lưới64px và điểm neo trên map giữ nguyên; không thay kích thước móng.
- Các số ở đây thay mô tả vị trí/khung của các đợt trước dưới đây. Ảnh/scene QA: `build/art-review/2026-10-05/kitchen-corner/`.

## Sân gọn và vị trí gian nấu/quầy (2026-10-05) — ưu tiên mới nhất

- Đất quanh công trình dùng GroundMask chung, thu vòng ngoài: margin đá chung0.35ô; ô sân bên ngoài strength0.28/góc0.16; giữ cỏ trang trí ngoài footprint. Bếp falloff1.8, còn đất trong rào và mép hữu cơ. Không thêm nền riêng vào SVG.
- Cấp1 giữ nguyên gian nấu đã duyệt. Cấp2–3 căn theo chân cọc trước (mốc rawY312) để phần tăng cỡ vươn lên sau thay vì nở xuống: CANOPY_ORIGINS raw(50,8)/(50,-20)/(50,-43), X50/cỡ60/69/77% giữ nguyên. Mốc chân trước rawY195.2/195.28/197.24 gần nhau; chỗ nấu, nhóm hình và cảnh báo cùng theo gốc từng cấp. Cấp2 khách ngồi trên khúc gỗ còn vỏ/vòng tuổi; cấp3 trên ghế gỗ có mặt ghế/chân/giằng/tựa phía ngoài bàn. Giữ chiếu cấp1 và4/6/8 khách. Chỗ đứng chân khách cấp2–3 tại tâm bàn+(±31,24), mặt ngồi tạiY12−5×0.85 (gỗ)/12−9×0.85 (ghế); tư thế ăn nâng hông khớp mặt ngồi theo cỡ thật của người, chân hướng tới bàn, chuyển tư thế0.25s. Rời ghế/đổi lệnh/nâng cấp trả độ nâng về0 trước khi đi. Khung/neo giữ nguyên.
- Gian nấu là nhóm Node2D CookingCanopy riêng gồm mái/cọc/nồi/dụng cụ/hơi nước; sân, rào, quầy và bàn ăn độc lập. Gốc từng cấp theo dòng trên thay gốc chung raw(50,8) của đợt trước. Không cố giấu đá phía sau: mái được chồng lên đá tự nhiên, chân cọc vẫn có khoảng đất. Sort từng lớp, chỗ đứng đầu bếp và cảnh báo đồng bộ gốc mới; nhịp sáng khi chọn bao gồm cả nhóm con. Đây vẫn là một công trình bếp, không thêm loại công trình hay thao tác di chuyển riêng. SERVING_CENTER(76,238), FETCH_POINT(107,250), khung512×504/neo256,456/hiển thị0.5 và footprint4×3 giữ nguyên.
- Giữ khung512×504/neo256,456/hiển thị0.5/footprint4×3; không đổi ArtSpecs. Mục này thay tọa độ/sân rộng ghi ở đợt trước. Ảnh: `build/art-review/2026-10-05/compact-yards/`.

## Dấu chọn công trình (2026-10-05)

- Vẽ bằng code trong CommandFeedback: bốn góc chữ L màu#FFF1B0, dài18px/nét2.5px/lùi6px trong footprint, không tô nền/vòng elip/nhấp nháy. Áp dụng móng, nhà đã xong, hover và mục tiêu giao việc; không đổi SVG/khung/neo.
- Building.selection_pulse sáng RGB thêm14% trong0.06s rồi giảm về màu gốc trong0.14s; không đổi vị trí/cỡ/góc. Lều/bếp nhiều lớp cũng sáng, giữ alpha lớp ẩn và không chạm màu người/icon cảnh báo. Chạy theo thời gian thật khi dừng/tăng tốc; chọn lại không để màu sáng bị cộng dồn.
- Ảnh trước/sau ở `build/art-review/2026-10-05/building-selection/`.

## Quầy thức ăn dọc và khoảng thoáng bếp (2026-10-04) — vị trí hiện hành

- Quầy cả ba cấp nhìn từ trên theo chiều dọc, dựng riêng mặt trên/hông/chân đứng, bát/đĩa vẫn đúng chiều. Tâm raw(88,238), tỉ lệ0.7; khối mặt khoảng44×64px trước thu, không xoay nguyên sprite quầy cũ. Nền trong suốt/bóng tiếp xúc nhẹ; chừa khoảng sân với rào.
- Khoảng cách cần chừa ở **chân cọc/chân quầy với đá**. Mái có thể sát/che đá, không dịch cả mái vào trong thành một khoảng trống đều. Nửa sau mái (rawY<125 sau phản chiếu) vươn sau-trái: Y=125+1.35×(Y−125), X cộng0.4×(Y−125); nửa trước giữ nguyên để không rời đầu cọc.
- Gian nấu gốc raw(50,34), giữ cỡ60/69/77% và hướng chếch phải. Tâm bàn ăn cấp1(258,141)/(258,234); cấp2(239,141)/(319,188)/(239,234); cấp3(234,141)/(326,141)/(234,234)/(326,234). Ghế/tâm người ăn cùng dịch; khoảng ghế51px cấp1,31px cấp2–3 giữ nguyên.
- Món chín xếp hai cột × ba hàng quanh tâm quầy; KitchenLayout.SERVING_CENTER/FETCH_POINT và vật cản đồng bộ. Điểm lấy món raw(119,250), icon cảnh báo vẫn theo mái mới. Không đổi khung512×504/neo256,456/hiển thị0.5/footprint4×3 hoặc luật chơi.
- Những vị trí trong các mục đợt trước bên dưới là lịch sử; mục này thay các tọa độ đó. Ảnh: `build/art-review/2026-10-04/kitchen-spacing/before/`, `after/empty_levels.png` và `after/live_levels.png`.

## Bếp có khối, đá kê chân rào (2026-10-04) — chuẩn hiện hành

- Giữ sân chữ nhật, mái nấu chếch phải, chiếu/bàn dọc; các vật có thể hướng khác nhau nhưng cùng mặt trên rộng, hông thấp và chiều sâu co lại. Không xoay toàn bộ nội thất45° để giả góc nhìn.
- `tools/kitchen_art.py`: đá có năm dáng khối, ba nhóm màu xám ấm, mặt trên sáng/hông tối; cỡ/cao thay đổi và vài khoang có hai viên lớn/nhỏ. Tọa độ lặp lại được bằng seed cục bộ, không sinh ngẫu nhiên lúc chơi. Cọc tre/gỗ chia khoang, đá đặt giữa các cọc; giới hạn hình đá chừa khe cho thân cọc. Đá vẽ sau phần thấp của rào để tạo che khuất sát đất, không trùng tâm cọc.
- Chiếu: mặt hình thang mềm co chiều sâu, tua đan và góc cuộn. Bàn đá/gỗ: mặt trên co sâu, hông/mép dày và chân; ghế đá khối lệch, ghế gỗ có chân/mặt ngồi. Bóng tiếp xúc16% sát vật thể, không thêm nền đất kín.
- Giữ toàn bộ tâm bàn/ghế/quầy/đầu bếp và hợp đồng lớp; khung512×504/pivot raw256,456, ART_SCALE0.5, footprint4×3, khách4/6/8 và thợ1/2/3. Không đổi ArtSpecs/KitchenLayout/path hoặc nền móng/lều. Art không vẽ chữ.
- Chuẩn ảnh: `build/art-review/2026-10-04/kitchen-depth/before/` và `after/`, kèm `live/` để soi người thật ăn/nấu.

## Khung móng và gian nấu mới (2026-10-04) — chuẩn hiện hành

- Móng2×2/3×2/3×3/4×3: bốn cọc hình chữ nhật chính diện nhìn từ trên, không xiên ngang. Với khungW×H ở2×, chân cọc(24,48),(W−24,48),(W−24,H−16),(24,H−16); dây nối tạiY chân−13. Cọc đứng/mặt trên elip, vật liệu/vết thi công nằm bên trong, nền trong suốt. Khung và neo cũ giữ nguyên.
- Gian nấu bếp: CANOPY_SCALES60/69/77%, gốc raw(26,14), giữ phép phản chiếu ngang theo hình mái chếch phải đã duyệt. So với trước tăng khoảng15%, dịch phải14px/lên6px trong raw trước khi thu sân/kéo khung4×3. Mái/nồi/cọc/hơi nước/dụng cụ cùng biến đổi; KitchenLayout đồng bộ chỗ đứng1/2/3 đầu bếp, icon cảnh báo theo điểm raw trên mái. Quầy/chiếu cấp1 giữ nguyên; cột bàn trái cấp2 dịchX211→225, hai cột cấp3X201/310→226/322, ghế mỗi bên38→31px raw để không bị mái che và không chồng người. Giữ kiểu/số bàn, bố cục tam giác/2×2, khung512×504/neo256,456 và footprint4×3.
- Ảnh trước/sau trong `build/art-review/2026-10-04/foundation-kitchen-adjust/`. Không đổi ArtSpecs, không tăng save format.

## Nền công trình trong suốt (2026-10-04) — chuẩn hiện hành

- Mọi asset công trình dùng nền trong suốt: không đóng mảng đất riêng phía sau/quanh vật. Sân đất phải do GroundMask chung của map vẽ để nối sân, giữ cùng texture/màu và mép cỏ tự nhiên. Chỉ giữ bóng tiếp xúc nhẹ sát chân. Các mô tả nền vuông/elip/hữu cơ trong lịch sử đã bị thay thế.
- Lều: bỏ hai lớp đất kín và elip màu đất dưới chân; `tent/floor_1..3` giữ file/khung/neo nhưng trống. Bếp: `kitchen/floor_1..3` giữ file/khung/neo nhưng trống, bỏ vệt đất cổng; World vẽ sân theo kích thước từng cấp, rào/đá giữ nguyên. Móng2×2/3×2/3×3/4×3: chỉ cọc/dây/vật liệu/vết thi công, nền trong suốt. Sân nhảy cấp1 bỏ nền đất/elip viền, giữ đá/đuốc; cấp2–3 giữ sàn gỗ/đá vật lý.
- Giữ mọi kích thước/pivot/footprint/tương tác; không phải tăng save format. Ảnh trước/sau: `build/art-review/2026-10-04/ground-blend/`.

## Bản sửa theo ảnh chơi thật (2026-10-04) — chuẩn hiện hành

Các số dưới đây ưu tiên hơn các ghi chú phác/triển khai cũ. Giữ phong cách/nét Việt/góc vẽ đã duyệt; không đổi camera2D hay lưới64px.

| Key | Cỡ file2× | Hiển thị cơ sở×0.5 | Neo | Ghi chú |
|---|---|---|---|---|
| buildings/tent/floor_1..3, body_1..3, door_1..3 |256×300|128×150|(0.5,0.92)|9 lớp chung khung/neo. Mép da che dân đang chui; floor trống, đất sân dùng map. tent_1..3 vẫn là ảnh đầy đủ cho menu/móng; muốn thay art sống phải thay bộ lớp. |
| buildings/kitchen_1..3 và mọi lớp buildings/kitchen/ |512×552|256×276|(0.5,21/23), raw256,504|Footprint4×3; sân512×384 từy144→528. Giữ layout bàn dọc/khách trái–phải và4/6/8 khách. Mỗi raw point cũ kéo×(4/3,1.5) và neo mới; data/kitchen_layout.gd đồng bộ generator. |
| buildings/foundation_4x3 |512×384|256×192|(0.5,1)|Móng phủ12 ô. |
| props/build_hammer |64×96|32×48 trước scale rig|(0.5,5/6), raw32,80|Cầm tại cán, đầu nằm phía ngoài tay theo animation. icons/skill_build giữ cho UI. |
| icons/move_feet |64×64|30×30 trong cursor|(0.5,0.5)|Dấu chân do người dùng chọn. Thay cursor di chuyển; không đổi cursor giao việc. |
| env/rock_cluster_100/_50/_30 |256×224|128×112|(0.5,25/28), raw128,200|Một mỏ liền2×2,96 đá/2 người. >50%,30–50%,≤30%; cùng neo, mỏ hết mở bốn ô. rock_big/small cũ chỉ giữ tương thích scene/test, map mới dùng cluster. |
| env/pebbles_100/_50/_20 |256×144|128×72|(0.5,0.75), raw128,108|54/30/14 viên với hạt vụn, mép hữu cơ không nền elip; các cụm kề nhau hòa thành bãi. Lật bố cục theo ô để giảm lặp; mỗi mỏ vẫn20 đá/2 người. |

- Rừng một loại mỗi cánh, tre chỉ trong dải ven hồ≤4 ô; dâu gom nguyên cụm2×2/3×2, giữ SVG quả nhỏ/nhiều đã duyệt và sinh đầy100%. Các khung/neo cây/dâu/củi không đổi.
- Animation cửa lều: đi tới cửa, cúi/chui0.85 giây, thân/mép da che dần rồi ẩn; tỉnh dậy đi ngược ra và vươn vai. TentEntrance giữ điểm cửa/lớp, TaskSleep giữ chuyển động; số chỗ/tốc độ hồi sức cũ.
- Generator vẫn tools/gen_building_art.py và tools/gen_resource_art.py; bếp helper tools/kitchen_art.py. Ảnh/animation QA tại build/art-review/2026-10-04/world-feedback. Không vẽ chữ vào asset, không sao chép ảnh đá tham khảo.

## Tài nguyên đã áp dụng và chuẩn style hiện hành (2026-10-04)

- Game dùng trực tiếp SVG trong assets/placeholder/env qua ResourceNode/ArtLibrary: tree_01/tree_03, tree_stump/bamboo_stump, bush_100/50/20/empty, rock_big/rock_small và twigs/pebbles ở các mức100/50/20. Đây là art đã áp dụng, không chỉ hình phác trong build.
- Cây lá rộng/tre/gốc, đá/củi/sỏi dùng góc3/4 v6: thấy mặt trên rộng và chiều sâu trước–sau/hông phải, cùng cảm giác lều trước-phải. Cây thân đứng thẳng, không xoay cả sprite. Cây thông tree_02 giữ nguyên.
- Bụi dâu tây dùng v7: tán mềm v5 đã duyệt, quả riêng lẻ đỏ tươi, tròn mọng, nhỏ65%, số quả18/9/4; không ghép đôi, không dùng tán phân tầng v6. Quả giảm khi hái, trụi vẫn giữ tán. Bụi mới sinh đầy100%; số quả là hình minh hoạ, không phải số món gameplay.
- Giữ style tiền sử thủ công, mềm/bo tròn, màu ấm/viền #4E342E, nét Việt gợi nhẹ và vật liệu hợp chức năng. Lều da+cỏ là chuẩn góc, không buộc mọi công trình thành lều. Bếp là ngoại lệ bố cục đã duyệt: sân chính diện, mái khu nấu chếch phải, chiếu/bàn dọc, người ngồi trái–phải. Thổ dân chibi nhỏ, đọc rõ mặt và đồ cầm. Icon UI phẳng; không còn icon việc thường trực trên đầu, vẫn giữ cảnh báo nhu cầu/bong bóng/biển.
- Chuẩn tài nguyên: build/art-review/2026-10-04/resources-v7/after/village_zoom_1.png và strawberries.png; các loại khác giữ góc v6. Vách đá/nước/nền/cỏ trang trí, kho/lò rèn/sân nhảy/hang/lửa trại và các bộ nhân vật ngoài01 chưa vẽ lại. Không đổi khung/neo/cỡ file trong đợt cập nhật tài liệu này.

## Bếp đã áp dụng trước lần tăng4×3 (2026-10-04, lịch sử)

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
| `env/pebbles_100` / `_50` / `_20` | 256×144 | 128×72 | (0.5, 0.75) | Sỏi mép hữu cơ sát mỏ lớn/chân vách,54/30/14 viên và hạt vụn; các cụm kề nhau hòa thành bãi. Không chặn đường. |
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
| `buildings/kitchen_1` · `_2` · `_3` | PNG576×552 / SVG512×552 | PNG288×276 / SVG256×276 (4×3) | (0.5,21/23), PNG(288,504) / SVG(256,504) | Composite mẫu v7 đã duyệt: sân nhỏ/vừa/lớn, mái nấu chéo phải,2 chiếu/3 bàn đá tam giác/4 bàn gỗ,4/6/8 khách. Dùng cho menu/bóng mờ; game sống dùng các lớp dưới. |
| `buildings/kitchen/floor_1..3` | 512×552 | 256×276 | (0.5,21/23) | Lớp rỗng trong suốt để giữ hợp đồng asset; đất sân dùng nền map chung. |
| `buildings/kitchen/fence_back_1..3` · `fence_front_1..3` | 512×552 | 256×276 | (0.5,21/23) | Đá / đá+tre mảnh / đá+gỗ dày, cổng trước-trái; hai lớp xa/gần. |
| `buildings/kitchen/cook_1..3` · `roof_1..3` · `pole_1..3` · `steam_1..3` | 512×552 | 256×276 | (0.5,21/23) | Khu nấu/mái/chân gần/hơi nước tách lớp;52/60/67%, bốn cọc và dụng cụ tăng qua cấp. |
| `buildings/kitchen/serving_1..3` · `seats_1..3` | 512×552 | 256×276 | (0.5,21/23) | Quầy món dưới-trái và ghế hai bên, seats_1 trong suốt vì ngồi chiếu. |
| `buildings/kitchen/seating_1_0..1` · `seating_2_0..2` · `seating_3_0..3` | 512×552 | 256×276 | (0.5,21/23) | Cặp ghế tách theo từng bàn để chỉnh nhóm trong scene; cấp1 trong suốt. |
| `buildings/kitchen/roast_base_1..3` · `roast_chicken_1..3` · `roast_fire_1..3` | 512×552 | 256×276 | (0.5,21/23) | Giá/than, thân gà và lửa tách lớp để quay quanh xiên; khói mỏng vẽ bằng code. |
| `buildings/kitchen/dining_1_0..1` · `dining_2_0..2` · `dining_3_0..3` | 512×552 | 256×276 | (0.5,21/23) | Mỗi chiếu/bàn một lớp để người đi trước/sau; trục dài dọc. |
| `props/cooking_spoon` | 20×80 | 10×40, thu theo rig | (0.5,0.075), raw(10,6) | Muôi gỗ neo cán ở tay, xoay khi khuấy nồi. |
| `props/stone_kitchen_knife` | 24×60 | 12×30, thu theo rig | (0.5,0.15), raw(12,9) | Dao đá cấp1, cán nối bàn tay, nhịp thái trên thớt. |
| `props/meal_smoked_meat` · `meal_roast_bird` | 64×48 | 32×24, thu theo rig/quầy | (0.5,0.5), raw(32,24) | Món chín trên lá chuối ở cấp1; cùng kho MEAL. |
| `buildings/kitchen/rack_1..2` · `chopsticks_3_0..3` | 512×552 | 256×276 | (0.5,21/23), raw(256,504) | Giàn thịt/ống đũa tách Sprite; lấy bố cục cuối từ scene. |

| `buildings/storage_1` · `_2` · `_3` | 384×380 | 192×190 (3×3) | (0.5, 0.9368) | Kho: cấp 1 mái che dựa + đống gỗ, đống đá; cấp 2 nhà vách gỗ cửa lớn; cấp 3 nhà kho to, nền đá, cửa đôi. |
| `buildings/forge_1` · `_2` · `_3` | 384×320 | 192×160 (3×2) | (0.5, 0.925) | Lò rèn: lò đá vòm bên trái (miệng lò đỏ rực), đe đá ở giữa; cấp 2 thêm mái + ống bễ; cấp 3 ống khói cao + cờ. **Chừa trống phần trước-trái, giữa và phải** để code dựng rìu (trái), cuốc (giữa), giáo (phải). |
| `buildings/dance_floor_1` · `_2` · `_3` | 384×400 | 192×200 (3×3) | (0.5, 0.94) | Sân nhảy **phẳng, đi lên được** (thổ dân đứng trên): cấp 1 sân đất viền đá + 2 đuốc; cấp 2 sàn gỗ + dây cờ; cấp 3 sàn đá ô màu + trống + 4 đuốc. Giữ phần giữa sân trống, ít chi tiết. |
| `buildings/foundation_2x2` | 256×256 | 128×128 | (0.5, 1.0) | Nền trong suốt, khung2×2; khung dây chữ nhật chính diện từ trên, cọc thấp có mặt trên elip/hông, cành tre và đá có mặt trên; cọc sau nằm trọn khung. Code đặt ở mép dưới diện tích. |
| `buildings/foundation_3x2` | 384×256 | 192×128 | (0.5, 1.0) | Móng3×2 (lò rèn): nền trong suốt/cọc/dây hình chữ nhật như móng2×2. |
| `buildings/foundation_3x3` | 384×384 | 192×192 | (0.5, 1.0) | Móng3×3 (kho, sân nhảy): nền trong suốt/cọc/dây hình chữ nhật như móng2×2. |
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
