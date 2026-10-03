# DEVLOG — Tribe Vibes (Bộ Lạc Chill)

Mỗi đợt một mục: đã làm gì, chọn gì và vì sao. Mục mới nhất ở trên cùng.

---

## Đợt C.3 — Tài nguyên kiểu RTS: mỏ có lượng, nhiều người làm chung (2026-10-03)

**Trạng thái:** xong, chờ chạy thử và duyệt — chưa commit.

### Đã làm
- **Mỗi chỗ tài nguyên là một mỏ có lượng** (`ResourceNode.amount / capacity`, tính bằng món): bụi quả to 30 thức ăn, bãi sỏi 20 đá, đống củi 15 gỗ, đá tảng 16 đá, cây 3 khúc gỗ. **Nhiều người làm chung** (bụi 3, sỏi / củi / đá tảng 2, cây 1): Reservations nhận `capacity`, mỗi người một chỗ đứng quanh mỏ (`claim_stand`, ô đã có người bị phạt khi chọn chỗ). Thổ dân **làm liền ở cùng mỏ** tới đầy giỏ / bó / xô rồi mới khuân về (hái quả giờ cũng theo mẻ: 3 nắm = 6 thức ăn).
- **Hình theo lượng còn lại** > 50% / 20–50% / < 20% (`_100/_50/_20`): bụi quả (9 / 4 / 2 chùm quả + bụi trụi), bãi sỏi (18 / 9 / 4 viên), đống củi (12 / 6 / 3 cành), đá tảng to / nhỏ (nguyên → sứt mẻ → mẩu nhỏ). Hình tạm sinh bằng `tools/gen_resource_art.py`; bỏ hình cũ `rock_big/small`, `bush_berries`, `twigs`, `pebbles`.
- **Thanh lượng chỉ trong bảng thông tin** (click vào vật): thanh xanh / vàng / đỏ + "Còn X/Y" (quy ra tài nguyên chung). Không vẽ gì trên map.
- **Bãi sỏi, đống củi sinh cùng map** (`_place_piles`): bãi sỏi cạnh bãi đá tảng (chân vách được cộng điểm), đống củi cạnh cây trưởng thành ở rừng rậm; 2 cái gần làng mỗi loại. Đi qua được (`MapData.LOOSE_KINDS`). Lúc mở ván mỗi mỏ lượng ngẫu nhiên (đá tảng 30–100%, còn lại 50–100%).
- **Bụi quả to**, mỗi vạt 2–3 bụi sát nhau. Hái trụi thì **60 ngày** sau mới đầy lại (`BUSH_REGROW_DAYS`).
- **Cây lớn dần**: `growth` 0 → 1 trong 2 ngày, cây non vẽ nhỏ (40% → 100%), chưa chặt được; ~12% cây lúc mở ván là cây non (nhiều ở bìa rừng); gốc mọc lại thành cây non.
- **NatureSpawner viết lại**: cây trưởng thành rụng 3 gỗ ~10 giây một lần vào đống củi cạnh nó (chưa có thì đống mới, tối đa 30 đống; cây trong rừng rậm hay rụng hơn); vách đá lở ~45 giây một lần ở chân vách phía trước: 40% một tảng đá (khi ít hơn lúc đầu), còn lại 8 sỏi dồn vào bãi gần đó (chưa có thì bãi mới, tối đa 30 bãi), có bụi đá.
- Chữ: "đá cuội" → "sỏi" (bãi sỏi, xô sỏi, nhặt sỏi), "củi khô" → "đống củi", bảng thông tin có dòng cây non / bụi chờ ra quả (tính theo ngày khi còn lâu).
- `SaveGame.VERSION` = 6. Công cụ chụp màn hình thêm `resources.png`, `panel_pebbles.png`, `panel_twigs.png`; sơ đồ map tô màu bãi sỏi / đống củi.
- Test: thêm `test_resource_patches` (hình theo lượng, bụi trụi chờ 60 ngày, 3 người hái chung một bụi mỗi người một chỗ, bãi sỏi hết thì biến mất, cây non chưa chặt, vách lở ra sỏi ở chân vách); sửa các test dùng cơ chế cũ. 77/77, soi cảnh báo strict sạch.

### Quyết định
- Bụi quả hồi **60 ngày tính từ lúc hái trụi** (mỗi bụi một đồng hồ), không phải cả map cùng đầy một lúc.
- Hái quả thêm mẻ 3 nắm (trước khuân 2 quả mỗi chuyến) để đỡ chạy đi chạy về — đúng tinh thần "đỡ hỗn loạn".
- Thanh lượng tính theo tài nguyên chung (cây: "Còn 20/30" gỗ thay vì "2/3 khúc").

### Còn biết
- 60 ngày = 4 tiếng chơi thật (một ngày 4 phút) — gần như mỗi bụi chỉ hái được một lần mỗi buổi chơi; thức ăn lâu dài phải trông vào câu cá, săn thú.
- Dòng "Mỗi lượt (~3 giây): 2 thức ăn" trong bảng thông tin là một nắm, chưa nói rõ "3 nắm mới khuân về".
- Đống củi / bãi sỏi trên nền cỏ vẫn hơi nhỏ khi thu nhỏ hết cỡ.

### Số nên tinh chỉnh (`data/balance.gd`)
- Lượng / người: `BUSH_FOOD` 30 / `BUSH_WORKERS` 3, `PEBBLE_PATCH_STONE` 20, `TWIG_PILE_WOOD` 15 / `PILE_WORKERS` 2, `ROCK_STONE` 16 / `ROCK_WORKERS` 2.
- `BUSH_REGROW_DAYS` 60, `GATHER_PICK_BATCH` 3, `LOOSE_PICK_BATCH` 3.
- `TREE_GROW_SECONDS` 2 ngày, `YOUNG_TREE_CHANCE` 0,12, `YOUNG_TREE_SCALE` 0,4.
- `PEBBLE_PATCHES` 22, `TWIG_PILES` 20, `STARTER_PILES` 2, `TWIG_DROP_SECONDS` 10 / `TWIG_DROP_AMOUNT` 3 / `TWIG_PILE_MAX` 30, `CLIFF_SLIDE_SECONDS` 45 / `CLIFF_SLIDE_BOULDER_CHANCE` 0,4 / `CLIFF_SLIDE_PEBBLES` 8 / `PEBBLE_PATCH_MAX` 30.
- `RESOURCE_STAGE_HALF/LOW` 0,5 / 0,2, `START_AMOUNT_MIN` 0,5, `ROCK_START_AMOUNT_MIN` 0,3.

---

## Đợt C.2 — Vách đá thành bức vách liền, đá chỉ ở chân vách (2026-10-03)

**Trạng thái:** xong, chờ chạy thử và duyệt — chưa commit.

### Đã làm
- **Vách đá vẽ bằng code thành một bức vách liền** (`world/cliff_ridge.gd`), bỏ 4 hình khối `env/cliff_rock_0N` (và phần sinh hình trong `tools/gen_building_art.py`). Mỗi dãy: mặt đứng cao 92 px quay về phía người nhìn (tối dần xuống chân, vân nứt dọc), mặt trên co lại một nửa bề dày ô (nhìn xiên — vách trông dựng đứng, không thành cao nguyên), mép đỉnh lởm chởm, vài búi rêu và vệt đá, đá vụn dưới chân; viền chỉ ở mép ngoài nên không còn thấy từng khối. Hai đầu dãy thấp dần; chỗ chân vách dịch hàng thì đường biên uốn mượt.
- Mỗi cột ô vách là một node trong Entities (gốc ở chân vách) để y-sort: ai đi phía sau vách bị che, ai đứng trước vách vẽ đè lên vách. Bóng cả dãy là một đa giác ở ShadowLayer (quét theo chiều cao vách, cùng màu với bóng khác), chỉ vẽ lại khi mặt trời đổi đủ nhiều.
- **Dãy vách chạy ngang là chính** (mặt đứng quay về phía người nhìn mới ra "bức vách"): đi từng cột sang trái / phải, chân vách trôi lên / xuống dần theo một hướng nghiêng, dày 1–2 ô; dài 8–16 cột (trước 6–14 ô). Mỗi cột là một đoạn ô liền, cột cạnh nhau luôn chạm cạnh (không có khe chéo).
- **Bãi đá tảng chỉ ở chân vách phía trước** (3 hàng dưới chân: 85% / 40% / 16%), không còn ở phía sau. Đá tảng mới cũng chỉ lăn ra phía trước. Đá tảng / đá cuội / củi không rơi vào ô ngay sau lưng vách (`_behind_cliff`). **Đá cuội ưu tiên bãi đá chân vách** (cộng điểm `CLIFF_FOOT_BONUS` khi chọn nguồn).
- `SaveGame.VERSION` = 5. Công cụ chụp màn hình chụp thêm `cliff_far.png`.
- Test: đếm node theo cột vách + kiểm tra mỗi cột là đoạn liền; test 3 thợ chặt + 2 thợ đập đá dựng thêm một Kho cạnh bãi đá chân vách (bãi giờ xa làng) và cho phép một phút sản lượng đứng yên (cả nhóm đi ăn / ngủ). Sửa 3 test thỉnh thoảng trượt do may rủi: tán gẫu (ai bắt chuyện trước cũng được, chờ 4 phút), gục ngủ / ngất (chờ tới khi dậy, giới hạn rộng hơn), chạm chọn thổ dân (chọn người không bị ai đứng chồng). Chạy cả bộ 3 lần liền: 76/76.

### Còn biết
- Dãy vách chéo nhiều bậc thì mặt đứng thành bậc thang (mỗi cột lệch một hàng) — trông như vách gãy khúc, chấp nhận được.
- Vách không còn là file hình nên muốn thay art thật phải sửa code vẽ (ghi trong ASSET_SPEC).
- Bãi đá chân vách nằm xa làng: khai thác đá lâu dài nên xây thêm Kho gần đó.

### Số nên tinh chỉnh
- `cliff_ridge.gd`: `FACE_HEIGHT` = 92, `TOP_DEPTH_SCALE` = 0,5, `PEAK_HEIGHT` = 14, `END_TAPER` = 56, các màu `TOP_*` / `FACE_*`.
- `balance.gd`: `CLIFF_RIDGE_MIN/MAX_LENGTH` = 8/16, `CLIFF_TURN_CHANCE` = 0,35, `CLIFF_THICK_CHANCE` = 0,6, `RIDGE_SCREE_NEAR/FAR` = 0,85/0,4.
- `nature_spawner.gd`: `CLIFF_FOOT_BONUS` = 5.

---

## Đợt C.1 — Tài nguyên trông tự nhiên hơn (2026-10-03)

**Trạng thái:** xong, chờ chạy thử và duyệt — chưa commit.

### Đã làm
- **Bãi đá tảng liền dọc chân vách** (`_place_ridge_scree`): chọn một đoạn 55–85% dãy vách; ô sát vách 85% có đá (đá to nhiều), ô cách 2 ô 40% (đá nhỏ nhiều), hai đầu đoạn thưa dần, phía trước vách (nam) nhiều hơn phía sau; tối đa 16 tảng mỗi dãy. Không đặt trong 2 ô quanh dãy khác để giữ lối đi.
- **Bãi đá lẻ gom chặt**: ô gần tâm được chọn trước (cộng chút ngẫu nhiên cho hình méo), đá to ở giữa.
- **Rừng méo tự nhiên**: mỗi cánh rừng ghép 1 khối chính + 0–3 khối phụ, bìa gợn theo nhiễu, cây lẻ lấn ra ngoài bìa (tới 1,6 lần bán kính). Loại cây theo **mảng** nhiễu thấp tần (mảng thông, mảng cây lá tròn). Thêm 14 lùm 1–3 cây lẻ trên bãi cỏ.
- Cây và đá tảng **lệch nhẹ khỏi tâm ô** (cây ±14/±9 px, đá ±9/±6 px) — lưu trong `MapData.objects[i].jitter`.
- **Đá cuội nhiều hơn và gom đám**: mở ván 60 viên (trước 16), tối đa 100 (trước 30), lăn thêm ~8 giây. **Củi** mở ván 30, tối đa 50. Món mới 65% rơi cạnh món cùng loại có sẵn (vẫn phải trong 2,3 ô quanh đá tảng / 1,5 ô quanh cây); còn lại rơi quanh nguồn nằm trong cụm dày nhất trong 5 nguồn bốc ngẫu nhiên → dồn về bãi đá lớn / rừng rậm. **Rải sẵn 8 củi + 8 đá cuội quanh cụm gần làng** (vì cụm nhỏ ít được chọn) để ván mới tay trắng vẫn có đồ nhặt gần nhà.
- `SaveGame.VERSION` = 4 (map sinh khác → save của Đợt C bị từ chối).
- Test `test_three_choppers_two_miners` giờ giao đá ở bãi chân vách: bãi gần làng chỉ có 6 tảng, 2 người đập hết đúng trong 5 phút rồi (đúng luật) cắm biển "hết đá".

### Còn biết
- Mỗi ô chỉ một đám củi / đá cuội nên bãi đá cuội vẫn hơi thưa khi nhìn gần; muốn dày hơn thì cần hình "đống đá cuội" nhiều viên hơn.
- Bãi đá gần làng (6 tảng ≈ 96 đá) cạn sau vài phút đập — sau đó phải đi xa tới chân vách.

### Số nên tinh chỉnh
- `RIDGE_SCREE_NEAR/FAR` = 0,85/0,4, `RIDGE_SCREE_SPAN_MIN/MAX` = 0,55/0,85, `RIDGE_BOULDERS_MAX` = 16.
- `FOREST_BLOBS_MAX` = 3, `FOREST_EDGE_WOBBLE` = 0,3, `FOREST_STRAY_CHANCE` = 0,06, `LONE_COPSES` = 14, `TREE_JITTER` / `ROCK_JITTER`.
- `PEBBLE_START/MAX` = 60/100, `PEBBLE_SPAWN_SECONDS` = 8, `TWIG_START/MAX` = 30/50, `LOOSE_CLUMP_CHANCE` = 0,65, `PEBBLE_FIELD_RADIUS` = 2,3, `STARTER_LOOSE` = 8.

---

## Đợt C — Map rộng kiểu RTS, tài nguyên theo cụm, dãy vách đá (2026-10-03)

**Trạng thái:** xong, chờ chạy thử và duyệt — chưa commit.

### Đã làm
- **Map 96×72 ô** (gấp 4 diện tích). Mở game nhìn xa hơn (zoom 0.8), thu nhỏ được tới 0.35.
- **Bộ sinh map viết lại theo kiểu RTS** (`world/map_generator.gd`):
  - Rừng thành **11 cánh rừng** (8 cánh dồn về phía rừng, 3 cánh lẻ): lõi dày, bìa thưa, nhiễu tạo khoảng trống và lối đi.
  - **6 dãy vách đá** (5 dãy phía bãi đá, 1 dãy chỗ khác): đi ngoằn ngoèo 6–14 ô, dày 1–2 ô, cách nhau ít nhất 3 ô nên luôn có lối đi; dưới chân mỗi dãy 3–6 đá tảng. Thêm 4 bãi đá tảng lẻ.
  - Bụi quả mọc thành **vạt** 3–5 bụi: một vạt gần làng, một vạt trong đồng cỏ, 6 vạt rải quanh map.
  - **Gần làng có sẵn một cụm nhỏ mỗi loại**: lùm cây (cách làng 8–11 ô về phía rừng), 6 đá tảng (về phía bãi đá), một vạt bụi quả.
  - Hồ lớn hơn, 7 chỗ câu cá; đồng cỏ rộng hơn, 8 con thú. Củi / đá cuội tối đa 40 / 30.
- **Vách đá giờ là địa hình**, không còn là "công trình" 3×2: `MapData.cliffs` = các ô vách (chặn đường). Mỗi ô một **khối vách** (`env/cliff_rock_01..04`, chọn ngẫu nhiên theo ô, có lật ngang) rộng gần 2 ô nên các khối chồng lên nhau thành bức vách liền: đỉnh lởm chởm sáng, mặt đứng có vân dọc, phía phải tối, rêu trên đỉnh. Nằm trong lớp Entities (người đi sau vách bị che), có bóng đổ theo mặt trời. Đá tảng mới lăn ra sát chân dãy vách.
- **Save cũ không tải được nữa** (map sinh khác hẳn): `SaveGame.VERSION` = 3, bấm Tải ván cũ thì báo "Ván lưu từ bản cũ…".
- Công cụ mới `tools/map_preview.tscn`: vẽ sơ đồ toàn map ra PNG (mỗi ô một ô màu). Công cụ chụp màn hình chụp thêm `cliff.png`.
- **Tốc độ** (máy này, tắt vsync, camera trượt): zoom 0.8 ~440 khung/giây (~810 lệnh vẽ), thu nhỏ hết cỡ 0.35 ~200 khung/giây (~3.000 lệnh vẽ).
- Test: 76 test (thêm: map đúng cỡ, có vách đá chặn đường, gần làng đủ cụm cây/đá/bụi, cây mọc thành cụm). Sửa test cũ theo map mới. Soi cảnh báo strict: sạch.

### Quyết định
- Giữ "rừng một phía, đá phía đối diện, hồ trên/dưới, đồng cỏ phía còn lại" nhưng rải thêm vài cánh rừng / dãy vách ở chỗ khác cho map đỡ đơn điệu.
- Cây, đá kẹt không tới được vẫn bị bỏ khi sinh map (lõi rừng quá dày) — vì vậy mật độ lõi rừng giữ ≤ 0,45.
- Vách đá không chạm/chọn được (không có bảng thông tin), con trỏ hiện ✕ khi đang chọn người.

### Còn biết
- Khối vách đá vẫn có viền riêng từng khối nên dãy vách nhìn hơi thành "cột" khi chạy dọc; art thật nên vẽ liền mạch hơn.
- Thu nhỏ hết cỡ có ~3.000 lệnh vẽ — máy yếu / bản Web có thể chậm; cần đo trên điện thoại ở Đợt 6.
- Map rộng nên thổ dân đi xa hơn tới cụm giàu; cụm gần làng sẽ cạn sau vài phút (đúng tinh thần RTS).

### Số nên tinh chỉnh
- `MAP_WIDTH/HEIGHT` = 96/72, `CAMERA_ZOOM_DEFAULT` = 0,8, `CAMERA_ZOOM_MIN` = 0,35.
- Rừng: `FOREST_CLUSTERS` = 11, `FOREST_RADIUS_MIN/MAX` = 4,5/9, `FOREST_CORE_DENSITY` = 0,65, `FOREST_MAX_DENSITY` = 0,45.
- Vách: `CLIFF_RIDGE_COUNT` = 6, dài 6–14, `CLIFF_THICK_CHANCE` = 0,6, `CLIFF_RIDGE_GAP` = 3.
- Đá: `ROCK_FIELD_COUNT` = 4 (4–7 tảng), `STARTER_ROCKS` = 6, `RIDGE_BOULDERS_MIN/MAX` = 3/6.
- Bụi: `BERRY_GROVES` = 6 (3–5 bụi). Thú: `ANIMAL_COUNT` = 8.

---

## Đợt B — Điều khiển chuột kiểu AoE, khung chọn nhiều người, con trỏ đổi hình (2026-10-03)

**Trạng thái:** xong, chờ chạy thử và duyệt — chưa commit.

### Đã làm
- **Chuột kiểu AoE** (`autoload/input_router.gd` viết lại, `NormalController` viết lại):
  - **Click trái = chọn** thổ dân / công trình / vật thể (không bao giờ ra lệnh). Shift + click: thêm / bớt người vào nhóm. Click chỗ trống: bỏ chọn.
  - **Kéo chuột trái = khung chọn** nhiều thổ dân (Shift: thêm vào nhóm đang chọn). Bỏ kéo chuột trái để trượt bản đồ và bỏ kéo-thả giao việc bằng chuột.
  - **Click phải = ra lệnh** cho những người đang chọn (vẫn giữ chọn sau khi ra lệnh). Lúc đang đặt nhà hoặc không chọn ai thì click phải = huỷ / bỏ chọn.
  - **Trượt bản đồ:** phím WASD / mũi tên, **chuột sát mép màn hình** (8 px), kéo **chuột giữa**. Lăn chuột zoom như cũ.
- **Ra lệnh cho nhóm** (`Commands.assign_group`, `Commands.move_group`): vào cây / đá / bụi… thì mỗi người nhận một cái gần nhau (không xúm một cây); vào công trình thì cùng vào (thừa người thì người thừa cắm biển); vào mặt đất thì mỗi người một ô quanh điểm đó (không đứng chồng).
- **Bảng nhóm** (`ui/common/group_panel.gd`): "Đang chọn N người", mỗi người một nút (icon việc đang làm + tên), bấm để chọn riêng người đó. Đường chấm chấm hiện cho cả nhóm.
- **Con trỏ đổi hình** (`ui/normal/command_cursor.gd`): đang chọn người mà rê chuột lên mục tiêu thì cạnh con trỏ có icon nhún nhún — bụi quả / chỗ câu cá → đồ ăn, cây → rìu, đá → cuốc, thú → giáo, củi → bó củi, đá cuội → xô, móng → búa, bếp → nồi, lò rèn → búa rèn, lều → Zzz, sân nhảy → mặt cười, mặt đất → cờ, chỗ không đi được → ✕. Dữ liệu: khoá `cursor` trong `data/jobs.gd`.
- **Cảm ứng giữ cách cũ** (điện thoại không có chuột phải): chạm chọn, đang chọn mà chạm mục tiêu / mặt đất thì ra lệnh rồi bỏ chọn, kéo một ngón trượt bản đồ, kéo từ thổ dân = kéo-thả giao việc, **nhấn giữ rồi kéo = khung chọn**.
- Đổi các dòng gợi ý ("Chọn thổ dân rồi click phải (hoặc chạm)…") và dòng hướng dẫn điều khiển ở bảng debug.
- Test: 75 test (viết lại test InputRouter: kéo trái = khung, kéo giữa = trượt, click phải = ra lệnh, cảm ứng kéo / nhấn giữ kéo; controller: click trái chỉ chọn, click phải ra lệnh + giữ chọn, icon con trỏ; kéo khung chọn 3 người → đi tới mỗi người một ô, chặt cây mỗi người một cây). Soi cảnh báo strict: sạch. Công cụ chụp màn hình thêm `--group`.

### Quyết định
- Click phải ra lệnh xong **giữ chọn** (như AoE) để ra lệnh tiếp; cảm ứng vẫn bỏ chọn sau lệnh (tránh lỡ chạm).
- Thổ dân chui vào lều ngủ thì tự rời khỏi nhóm đang chọn.
- Không đổi hình con trỏ hệ thống (giữ mũi tên), chỉ thêm icon nhỏ cạnh con trỏ — chạy được cả bản Web.

### Còn biết
- Khung chọn vẽ dưới thổ dân / cây (lớp mặt đất).
- Bảng nhóm tối đa vài chục nút; chọn cả làng 50 người thì bảng khá cao.
- Chuột sát mép màn hình cũng trượt khi chuột đang nằm trên thanh HUD ở mép trên (giống AoE).

### Số nên tinh chỉnh
- `CAMERA_EDGE_SCROLL_PX` = 8, `CAMERA_KEY_PAN_SPEED` = 700 (dùng chung cho trượt mép). `Commands.GROUP_SPREAD_MAX_RADIUS` = 6.

---

## Đợt A (sau Đợt 3) — Dân đứng yên khi rảnh, đá cuội thay cuốc, biển đè lên người, bảng thổ dân, gió (2026-10-03)

**Trạng thái:** xong, chờ chạy thử và duyệt — chưa commit. (Đợt B: điều khiển chuột kiểu AoE; Đợt C: map rộng gấp 4, tài nguyên theo cụm, dãy vách đá.)

### Đã làm
- **Rảnh thì đứng yên tại chỗ được thả.** 30 giây đầu chỉ làm trò tại chỗ: đứng chờ, **vẫy vẫy người chơi** (hoạt họa mới), **ngó nghiêng** (quay qua quay lại), vươn vai, gãi, tán gẫu với người **đứng sát bên** (không ai bước đi tìm ai). Quá 30 giây mà chưa có việc thì **chán**: ngồi phịch, **nằm ngủ gật** tại chỗ 8–15 giây (task mới `TaskNap`, hồi chút sức), hoặc đi hái bông hoa trong 3 ô rồi **quay về đúng ô cũ**. Bỏ hẳn đi dạo (xoá `TaskStroll`). Lười hay ngồi / ngủ gật, Ham chơi hay vẫy tay.
- **Đá:** bỏ "đá nhỏ nhặt tay" (Đợt 3.1) — đá tảng to hay nhỏ đều cần cuốc. **Giao đập đá tảng mà làng chưa có cuốc → tự nhặt đá cuội nằm trong 3 ô quanh tảng đá đó** (nghĩ tới cái cuốc cho người chơi biết); không có đá cuội mới cắm biển cuốc (không gạch chéo). Đang đập đá mà cuốc bị lấy hết cũng tự chuyển như vậy. Viết dạng dữ liệu (`fallback_job` trong `data/jobs.gd`) để sau này việc khác dùng lại.
- **Tấm biển vẽ đè lên người** (tay, đầu, đồ cầm không che hình trên biển).
- **Bảng thổ dân gọn lại** (cao chỉ còn ~một nửa): chân dung nhỏ hơn; tên + mặt tâm trạng + giới tính một dòng; tính cách thành **thẻ nhỏ** (giải thích trong tooltip); bên dưới trái 4 chỉ số xếp dọc (icon + thanh), phải kỹ năng dạng lưới 4 cột (icon + **số cấp** — bỏ hàng sao; việc thích là ô có **khung viền vàng + nền vàng nhạt** thay cho trái tim).
- **Gộp Săn bắn + Chiến đấu thành một kỹ năng** "Săn bắn & chiến đấu" (id `FIGHT`, icon cây giáo): đi săn luyện kỹ năng này; Đợt 5 dùng nó cho sát thương cận chiến lẫn ném giáo. Còn 8 kỹ năng. Save cũ có kỹ năng "HUNT" tự đổi sang (lấy cấp cao hơn), việc thích "HUNT" cũng vậy. Icon thể lực đổi thành **Zzz**; icon giải trí là **mặt người đổi theo mức**: vui (≥ 60), bình thường (≥ 30), bực bội đỏ cả mặt (thấp hơn — cũng là icon nhấp nháy trên đầu khi sắp đình công).
- **Gió cố định** ở mức vừa (bỏ gió giật ngẫu nhiên). Sửa luôn lỗi gốc của gợn sóng: shader mặt hồ nhân `thời gian × sức gió`, nên game chạy lâu thì mỗi lần sức gió đổi chút xíu là gợn sóng giật vọt — giờ tốc độ trôi không phụ thuộc sức gió.
- Test: 72 test (thêm: đứng yên 30 giây đầu rồi mới chán + tán gẫu tại chỗ; không cuốc thì nhặt đá cuội cạnh tảng đá / không có thì cắm biển không gạch chéo). Test làng sống 5 phút giờ kiểm tra hoạt cảnh tại chỗ phải đứng **đúng ô** điểm neo. Soi cảnh báo strict: sạch.

### Quyết định
- "Đá cuội cạnh tảng đá" = trong 3 ô quanh tảng đá (đá cuội vốn lăn ra sát đá tảng).
- Ngủ gật lúc chán là việc rảnh: giao việc là dậy ngay; mệt thật (< 50%) thì vẫn đi tìm lều như cũ.
- Nhiều người cùng được thả một chỗ thì đứng chồng một ô — Đợt B (ra lệnh cho nhóm) sẽ tản họ ra.

### Số nên tinh chỉnh
- `IDLE_BORED_SECONDS` = 30, `NAP_MIN/MAX_SECONDS` = 8/15, `IDLE_RADIUS_CELLS` = 3 (bán kính đi hái hoa), `IDLE_CHAT_RANGE_CELLS` = 1,6.
- `TOOL_FALLBACK_RADIUS_CELLS` = 3. `Wind.STRENGTH` = 0,6. `FUN_FACE_HAPPY/OK` = 60/30.

---

## Đợt 3.1 — Đá nhỏ nhặt tay, biển "cần cái này", bảng thông tin vật thể (2026-10-03)

**Trạng thái:** xong, chờ chạy thử và duyệt — chưa commit.

### Đã làm
- **Đá nhỏ nhặt bằng tay** (việc mới `pick_rock`, kỹ năng Hái lượm): chạm đá nhỏ → thổ dân cúi nhặt, giơ đá trên đầu khuân về; 4 giây → 2 đá, mỗi viên 2 lượt. Đá tảng to vẫn cần cuốc. Người đang đập đá bằng cuốc mà quanh đó hết đá to thì đập luôn đá nhỏ (khỏi dừng việc sớm vì đá to giờ chỉ ~40% số đá).
- **Tấm biển "thiếu đồ nghề / nguyên liệu" bỏ dấu ✕** — chỉ vẽ món đang cần: thiếu rìu/cuốc/giáo, thiếu gỗ/đá để xây hay rèn, bếp chưa có gì để nấu. Dấu ✕ chỉ còn cho "hết rồi / không làm được": hết cây/đá/quả/thú, kho đầy, đủ người, lều hết chỗ, đình công. Nhờ vậy "cần rìu" (rìu) và "hết cây" (rìu ✕) không còn trông giống hệt nhau.
- **Bảng thông tin vật thể** (`ui/common/object_panel.gd`): không chọn thổ dân mà chạm cây, gốc cây, đá tảng, đá nhỏ, bụi quả, củi, đá cuội, chỗ câu cá, con thú → bảng góc dưới-trái: hình, tên, mô tả, mỗi lượt ra gì (bao nhiêu, mấy giây), còn mấy lượt, cần đồ nghề gì (làng đang có mấy / chưa có thì xây Lò rèn) hay làm bằng tay, bụi hết quả thì còn bao lâu ra quả lại, gốc cây, ai đang làm ở đó, gợi ý cách giao việc. Vật đang xem có vòng vàng dưới chân. Chạm lại / ✕ / chạm chỗ trống thì đóng; củi nhặt mất, thú bị săn thì bảng tự đóng.
- **Watchdog** không đếm thời gian đang đi đường nữa (đi rừng ↔ kho xa không phải kẹt) — trước đó test "3 chặt 2 đập" thỉnh thoảng trượt vì vậy.
- Test: 71 test (thêm: đá nhỏ nhặt tay + biển không/có ✕; chạm bụi / cây / thú hiện bảng, chạm lại thì đóng). Test cũ giao "đập đá" giờ nhắm đá tảng to. Soi cảnh báo strict: sạch. Công cụ chụp màn hình `--ui` chụp thêm `panel_bush/tree/rock.png`.

### Quyết định
- "Đá nhỏ" = hình đá tảng cỡ nhỏ có sẵn trên map (khác đá cuội nằm lẫn trên đất). Nhặt tay ra ít đá hơn đập đá to (4 đá vs 16 đá mỗi viên).
- Bảng vật thể chỉ để xem, không có nút giao việc — vẫn giao bằng cách chọn thổ dân rồi chạm (đúng kiểu game gốc).

### Số nên tinh chỉnh
- `SMALL_ROCK_USES` = 2, `STONE_PER_SMALL_ROCK` = 2, `SMALL_ROCK_PICK_SECONDS` = 4.
- `ROCK_BIG_CHANCE` = 0,4 (tỉ lệ đá to khi sinh map) — muốn nhiều đá phải dùng cuốc hơn thì tăng lên.

---

## Đợt 3 — Xây dựng, nâng cấp, ngày đêm & lưu game (2026-10-02)

**Trạng thái:** xong, chờ chạy thử và duyệt — chưa commit.

### Đã làm
**1. Xây dựng cơ bản**
- **Nút Xây** (cái búa, góc dưới-phải) mở menu 5 công trình (hình, tên, một dòng giải thích, giá cấp 1, diện tích). Chọn một cái → **bóng mờ đúng diện tích** (ô xanh/đỏ + hình công trình mờ). Chuột: bóng đi theo con trỏ, click là đặt. Cảm ứng: chạm để dời bóng, chạm lại đúng chỗ hoặc bấm ✓ để đặt. Thanh gợi ý dưới màn hình có nút ✕ (Esc / chuột phải cũng huỷ). Đặt xong mở luôn bảng của móng + thông báo "Đã đặt móng…".
- **Luật đặt** (`world/building_placer.gd`): trong map, không nước / cây / đá / công trình khác; củi, đá cuội nằm đó thì dọn đi; thú đứng đó thì chờ; người đứng đó thì nhảy sang ô bên. **Không chặn lối:** mọi ô đang đi tới được phải vẫn đi tới được (không quây kín vùng nào) và mọi công trình vẫn có lối vào.
- **Thợ xây** (`TaskBuild`): chạm/kéo thổ dân vào móng → **đội mũ công trường**, ra kho gần nhất lấy một chuyến (10 gỗ hoặc 5 đá, khúc gỗ / xô đá trên đầu), khuân đổ vào công trường, lặp lại tới khi **đủ vật liệu mới gõ búa**. Tối đa max(1, số ô ÷ 2) thợ, mỗi thợ một chỗ đứng quanh công trình; hứa trước phần đang khuân để không khuân thừa. Kho hết loại cần thì đứng trước công trình **cắm biển gỗ/đá ✕**, chờ rồi thử lại (không bỏ việc). Xây xong mà gần đó không còn công trình dở → **nhảy cẫng ăn mừng**, bỏ mũ. Bị ngắt giữa đường thì vật liệu đang khuân được cất lại kho.
- **Hiệu ứng:** móng (nền đất + cọc + dây), hình công trình mờ **mọc dần từ dưới lên** theo tiến độ (shader `fx/build_reveal.gdshader`), **hai thanh tiến độ** trên đầu (vật liệu, gõ búa), xong thì **nảy "bụp" + khói + pháo giấy** + thông báo. Đang nâng cấp thì cắm giàn giáo.
- **Bảng công trình** (`ui/common/building_panel.gd`, chạm công trình khi không chọn thổ dân): hình, tên, sao cấp, mô tả / trạng thái, vật liệu đã khuân / cần + 2 thanh tiến độ + số thợ, người phụ trách (hoặc cảnh báo + gợi ý cách giao), chỗ ngủ + ai đang ngủ, chỗ cất góp cho làng, món chín, đơn rèn, nút **Nâng lên cấp N** (kèm giá) và **Huỷ móng / Huỷ nâng cấp** (trả lại vật liệu đã khuân tới). Chỉ dựng lại phần nào thật sự đổi để không nuốt mất cú bấm.
- **Nâng cấp 3 cấp:** thành công trường, cần thợ xây khuân vật liệu như xây mới; **trong lúc đó vẫn hoạt động ở cấp cũ** (đầu bếp / thợ rèn làm tiếp). Chạm công trình đang nâng cấp = giao việc xây.

**2. Công trình chức năng**
- **Hang đá = kho tạm** (theo ý bạn): 30 gỗ, 30 đá, 15 thức ăn thô. **Lửa trại chỉ cất món chín** (4), một người nấu.
- **Kho chung có sức chứa** cộng dồn (`GameState.capacity/room`, World tính từ hang đá + Kho + Bếp). HUD hiện "đang có /sức chứa", đầy thì chữ đỏ, tooltip nhắc xây Kho/Bếp. Kho đầy: khuân về được phần nào hay phần đó, cắm biển **cái kho ✕** rồi thôi việc (lượt sau không làm nữa).
- **Lều:** 2 / 3 / 4 chỗ, hồi sức ×1.5 / ×2 / ×2.5. Mệt thì tự tìm lều gần nhất còn chỗ, **chui vào trong** (ẩn, lều rung nhẹ, bay Zzz), ngủ đủ chui ra vươn vai; hết chỗ thì ngủ đất cạnh lửa trại như cũ. Thả thổ dân vào lều = đi ngủ ngay (việc đang giao vẫn nhớ); lều đầy thì cắm biển Zzz ✕.
- **Bếp:** cất thêm 30 / 60 / 120 thức ăn thô, đầu bếp 1 / 2 / 3, nấu 5 giây một món (mỗi đầu bếp một nồi), món chín cất tại bếp 6 / 10 / 16 bát (bày quanh bếp). Dân đói tới chỗ có món chín trước, hết thì ăn đồ thô ở Bếp / hang đá.
- **Kho:** cộng 100 / 200 / 400 gỗ và đá.
- **Lò rèn:** thợ rèn 1 / 2 / 3; bảng −/+ đặt số rìu / cuốc / giáo còn muốn rèn (tối đa 9), thợ rèn làm lần lượt từng loại, lấy vật liệu từ kho lúc bắt đầu mỗi món (thiếu thì cắm biển gỗ/đá ✕), rèn xong "bụp" + món đó dựng cạnh lò đúng số lượng (rìu trái, cuốc giữa, giáo phải). Thổ dân lấy / đổi đồ nghề ở lò rèn như mục 9.4; món cũ luôn được trả lại (kể cả lò đầy). **Bỏ phím F10** (`Commands.debug_give_tools()` chỉ còn cho test / công cụ).
- **Sân nhảy:** xây / nâng cấp được, **đi lên được** (không chặn đường); thả thổ dân vào thì lên đứng chơi trên sân (disco để Đợt 4).
- **Thiếu người phụ trách:** Bếp / Lò rèn đã xây mà không ai phụ trách thì ngừng + **icon cảnh báo trên mái** + dòng đỏ trong bảng. Chạm công trình sản xuất đã đủ người thì thổ dân cắm biển icon việc ✕.
- Hình tạm mới: 15 hình công trình (5 × 3 cấp), 3 cỡ móng, mũ công trường, icon cảnh báo / kho / nâng cấp / ✓ / lưu / tải, mặt trời / mặt trăng, pháo giấy — sinh bằng `tools/gen_building_art.py`.

**3. Ngày đêm & lưu game**
- **Ánh sáng** đổi liên tục theo giờ (`world/day_night.gd`, CanvasModulate + dải màu: bình minh hồng → trưa trắng → chiều vàng → hoàng hôn đỏ cam → đêm xanh tím). Mặt trời mọc 0.125, lặn 0.875 (ngày 3 phút, đêm 1 phút).
- **Bóng đổ theo mặt trời** cho cây, đá, bụi, củi, công trình, thổ dân, thú (`world/shadow_layer.gd`): sáng bóng dài về tây, trưa ngắn sau chân, chiều dài về đông, đêm tắt. Vật đứng yên dùng chung một shader chiếu bóng (đổi giờ = đặt một tham số); thổ dân / thú chép từng mảnh của khung cutout sang node bóng. Không Light2D.
- **Ánh lửa ban đêm** ở lửa trại, bếp, lò rèn (sprite cộng sáng, lập loè, trên CanvasLayer riêng không bị làm tối). **Đồng hồ mặt trời** nhỏ cạnh chữ "Ngày N".
- **Lưu / tải** (`world/save_game.gd`, `user://save.json`): seed + ngày giờ + kho chung; trạng thái từng cây / đá / bụi / củi / đá cuội; mọi công trình (cấp, lượt xây dở + vật liệu đã đổ, đồ riêng, đơn rèn); thổ dân (dữ liệu, chỉ số, kỹ năng, **đồ nghề đang giữ**, vị trí, điểm neo, **việc đang nhớ**). **Tự lưu đầu mỗi ngày**; nút Lưu / Tải trên HUD (Tải phải bấm 2 lần trong 3 giây — "Chắc chưa?"). Tải = dựng lại cả cảnh.

**Khác**
- HUD gọn lại: lưu / tải xuống hàng dưới. Bảng debug góc trên-trái tự ẩn sau 8 giây (hiện lại khi bấm F9).
- Lớp UI chính chuyển lên CanvasLayer `layer = 10` (trên ánh lửa).
- Test: 69 test (thêm `test_buildings.gd`, 13 test: luật đặt, thợ xây khuân rồi mới xây + mũ + ăn mừng, chờ vật liệu, huỷ móng trả vật liệu, nâng cấp vẫn chạy cấp cũ, lều 2 chỗ + ngủ đất khi hết chỗ, bếp nấu + ăn ở bếp + cảnh báo thiếu người, sức chứa kho + biển kho đầy, lò rèn rèn rìu rồi người khác lấy dùng, ngày đêm + bóng, lưu/tải đủ thứ, controller đặt móng + chọn công trình). Test cũ: thêm Kho cấp 3 vào bài 3 chặt 2 đập (hang chỉ chứa 30). Soi cảnh báo strict: sạch (test + chạy game). Kiểm tra thêm luồng Lưu → Tải thật (dựng lại cảnh) bằng script tạm: giữ đúng seed, kho, thổ dân.
- Công cụ chụp màn hình thêm `--buildings`, `--ui`, `--times`.

### Quyết định
- **Hang đá là kho tạm, lửa trại chỉ cất món chín** (bạn chốt). Kho chung cộng dồn sức chứa, khuân về chỗ gần nhất (không tách kho từng nơi — đỡ rối cho người chơi casual).
- **Kho đầy thì thôi việc + biển cái kho ✕** (không đứng chờ): người chơi thấy ngay vì sao, và không có ai đứng ôm khúc gỗ mãi.
- **Chỉ huỷ được móng / lượt nâng cấp đang dở**, trả lại hết vật liệu đã khuân tới; công trình xong thì không phá / dời (MVP).
- **Ngủ trong lều = chui vào lều** (ẩn đi, lều bay Zzz, chạm lều để xem ai đang ngủ).
- **Ván mới tay trắng**, Lò rèn cấp 1 rẻ (15 gỗ 10 đá): 2–3 người nhặt củi + đá cuội vài phút là xây được rồi rèn rìu.
- **Vật liệu không trừ lúc đặt móng** — thợ xây khuân từ kho tới, nên luôn đặt được trước rồi kiếm vật liệu sau.
- Lửa trại tối đa 1 người nấu (một nồi); thả người thứ hai thì họ cắm biển.
- Thợ rèn trừ đơn ngay khi bắt đầu một món (hai thợ không rèn trùng); bị ngắt thì trả đơn + vật liệu.
- Bếp / lò rèn đang nâng cấp vẫn nấu / rèn; chạm vào lúc đó là giao việc xây.
- Sân nhảy đi lên được; thả thổ dân vào thì đứng chơi trên sân (chưa có disco).
- Cảnh báo thiếu người đặt **trên mái** chứ không lơ lửng phía trên (công trình đứng sát nhau thì dễ tưởng là của công trình phía sau).
- Tải game dựng lại cả cảnh (reload) thay vì xoá từng thứ — chắc chắn không sót tham chiếu cũ.

### Còn biết
- **Ván mới chưa tự tải ván đã lưu** — mở game là ván mới, bấm nút Tải để chơi tiếp (màn hình bắt đầu ở Đợt 6).
- Thú không được lưu (tải lại thì đàn thú mới); việc đang làm dở (một lượt) cũng không lưu — tải xong thổ dân làm lượt mới của việc đang nhớ.
- Bóng đổ của các vật chồng lên nhau thì đậm hơn một chút (không gộp bóng).
- Ban đêm bong bóng / số bay "+10 gỗ" cũng tối theo (nằm trong thế giới).
- Bóng mờ khi đặt nhà lúc đầu đặt giữa màn hình; trên cảm ứng phải chạm để dời.
- Thổ dân đang ngủ trong lều không chạm được (chạm lều để xem tên).
- Huỷ móng khi thợ đang xây thì thợ cắm biển "búa ✕" (giống "hết việc xây").
- Công trình hư hại (cannibal) để Đợt 5.
- Thanh HUD khá dài: ở màn hình hẹp có thể chạm cạnh trái (chưa có setting "Cỡ giao diện").

### Số nên tinh chỉnh (đề xuất, ở `data/buildings.gd`, `data/tools.gd`, `data/balance.gd`)
- **Hang đá** 30 gỗ / 30 đá / 15 thức ăn. Nếu thấy người mới bị đầy kho quá sớm → 50 / 50 / 20.
- **Chi phí** cấp 1 → 2 → 3: Lều 20g → 40g 15đ → 60g 40đ; Bếp 25g 10đ → 40g 25đ → 60g 50đ; Kho 30g 10đ → 60g 30đ → 120g 60đ; Lò rèn 15g 10đ → 40g 30đ → 70g 60đ; Sân nhảy 20g 10đ → 40g 25đ → 60g 45đ. (Mỗi cây = 30 gỗ, mỗi đá tảng = 16 đá.)
- **Thời gian xây** (1 thợ cấp 1): Lều 20/30/45 giây, Bếp 25/35/50, Kho 30/45/60, Lò rèn 25/40/55, Sân nhảy 20/30/45. Mỗi chuyến khuân 10 gỗ / 5 đá (`BUILD_CARRY`).
- **Rèn:** rìu 4g 2đ, cuốc 3g 4đ, giáo 5g 1đ; 12 giây / món (`FORGE_SECONDS`). Lò chứa mỗi món 2 / 4 / 6.
- **Bếp:** món chín 6 / 10 / 16, thức ăn thô +30 / +60 / +120, nấu 5 giây (`COOK_SECONDS_KITCHEN`).
- **Lều:** 2 / 3 / 4 chỗ, hồi ×1.5 / ×2 / ×2.5.
- **Bóng:** dài nhất 3× (`SHADOW_LENGTH_MAX`), ngắn nhất 0.3×, độ đậm 0.26 (`SHADOW_ALPHA`), ép dẹt 0.45 (`SHADOW_DEPTH_SQUASH`). Ánh sáng: các mốc màu ở `DayNight.LIGHT_KEYS`.

---

## Đợt 2.2 — Gộp tài nguyên, đồ nghề, củi & đá cuội (2026-10-02)

**Trạng thái:** xong, chờ chạy thử và duyệt — chưa commit.

### Đã làm
- **3 tài nguyên chung:** gỗ, đá, thức ăn (icon đùi thịt). Thanh tài nguyên còn 3 ô.
  - Bên trong, thổ dân khuân **món** (`ResourceDefs.ITEMS`): giỏ quả, con cá, nguyên con thú, khúc gỗ (= 10 gỗ), bó củi (1), đá (1), xô đá cuội (1 mỗi viên). Tới kho thì quy ra tài nguyên chung.
  - Kho nhớ thức ăn gồm bao nhiêu quả/cá/thịt (`GameState.add_resource(id, n, item)` / `take_one()`), lúc ăn cầm đúng món trên tay.
- **Đồ riêng của công trình** (`Building.stock`, có sức chứa, bày hình quanh công trình):
  - Món chín cất ở lửa trại (tối đa 4 bát quanh lửa), không còn trên thanh tài nguyên.
  - Đầu bếp lấy thức ăn thô nấu thành món chín; bếp đầy thì đứng chờ.
  - Dân đói ăn món chín trước, hết thì ăn thức ăn thô.
- **Đồ nghề** (`data/tools.gd`: rìu, cuốc, giáo):
  - Chặt cây cần rìu, đập đá tảng cần cuốc, săn cần giáo. Thiếu thì thổ dân cắm biển vẽ món đó gạch chéo, không nhận việc.
  - Có thì tự đi lấy (`TaskFetchTool`) và giữ luôn (`VillagerStatus.tool`). Việc tay không thì đeo đồ nghề sau lưng; việc cần món khác thì về đổi.
  - Chưa có lò rèn: **F10** (bản debug) thêm 1 rìu, 1 cuốc, 1 giáo vào lửa trại.
- **Việc theo `job_id`** (JobDefs): thêm **nhặt củi** và **nhặt đá cuội** (kỹ năng Hái lượm, tay không). Nhặt đủ 3 bó/viên gần nhau rồi mới khuân về.
- **Đồ cầm tay đúng việc:**
  - Hái quả: cầm giỏ, khuân giỏ quả về.
  - Câu cá: cần câu riêng, động tác quăng cần, dây câu + phao vẽ bằng code, khuân cá về.
  - Săn: cầm giáo, hạ thú, vác **nguyên con chổng vó** trên đầu về.
  - Chặt cây: khuân khúc gỗ. Nhặt đá cuội: xách xô.
- **Thiên nhiên** (`NatureSpawner`):
  - Củi rơi dần dưới tán cây (tối đa 20), đá cuội lăn ra quanh đá tảng (tối đa 14).
  - **Vách đá lớn** (3 cái, phía bãi đá, không khai thác được) thỉnh thoảng lăn ra đá tảng — chỉ khi số đá tảng ít hơn lúc đầu.
  - Gốc cây chỉ mọc lại khi số cây ít hơn lúc đầu.
- **Tấm biển:** đứng thì cắm xuống đất trước mặt (tay vịn), ngồi thì hai tay giơ lên, đang đi thì cất. Rảnh mà vừa cắm biển thì đứng yên cạnh biển (`TaskWait`), không đi dạo mất.
- **Spec:** mục 9.2 viết lại, thêm mục 9.4 Lò rèn & đồ nghề (chọn số lượng rèn, rìu/cuốc/giáo trong chiến đấu), xây nhà có khuân vật liệu + mũ công trường (mục 9.3), bảng con số mục 13.
- Hình mới: `icons/res_food`, `props/basket`, `basket_berries`, `bucket`, `bucket_pebbles`, `log`, `twig_bundle`, `fishing_rod`, `env/twigs`, `env/pebbles`, `env/cliff`.
- Test: thêm đồ nghề (thiếu → biển, lấy, giữ khi nhặt đá, đổi món), củi theo mẻ + giới hạn thiên nhiên, biển cắm/giơ. Test runner thêm `-- --only=<tên>`.
- **Đổi tên spec `MVP_PROMPT.md` → `GAME_DESIGN.md`** (giờ là tài liệu thiết kế cả game, không chỉ là prompt dựng MVP). Cập nhật các mục 4, 5, 6, 7, 8, 9, 11, 12 theo Đợt 2.1–2.2; thêm Đợt 2.1, 2.2 vào mục 12; Đợt 3 thêm lò rèn và xây có khuân vật liệu. Các mục cũ hơn trong DEVLOG vẫn ghi tên cũ.

### Quyết định
- **Thức ăn thô ăn được luôn** (no căng): không có đầu bếp vẫn không ai đói cạnh kho đầy. Món chín chỉ thêm vui.
- **Cần câu không cần rèn** (lò rèn chỉ làm rìu, cuốc, giáo theo spec).
- **Mỗi cây 3 khúc gỗ = 30 gỗ** (trước là 9). Chi phí công trình Đợt 3 (10–30 gỗ) sẽ phải tăng hoặc giữ — cần xem lại khi làm Đợt 3.
- Đồ nghề không hỏng.

## Đợt 2.1 — Thổ dân "nói" bằng hình + luật ăn mới (2026-10-02)

**Trạng thái:** xong, chờ chạy thử và duyệt — chưa commit.

### Đã làm
- **Tooltip** (theme): nền kem, viền nâu, chữ nâu đậm cỡ 16 thay cho nền xám tối mặc định khó đọc.
- **Bỏ hết chữ trên đầu thổ dân.** Ba kiểu "lời nói" bằng hình:
  - Bong bóng nói (1–2 icon): cảm xúc, lên cấp, tán gẫu (icon ngẫu nhiên: quả, đá, tim, sao, "?"…).
  - Mây nghĩ (`ui/thought_bubble`): đói (đùi thịt, giữ suốt lúc đi tới bếp), buồn ngủ, nghỉ tay (Lười), "lát nữa" (icon việc / "…"), không tới được ("?").
  - Tấm biển (`props/sign`, vẽ trong `VillagerRig`, hai tay giơ lên): đói lả (đùi thịt), hết cây/đá/quả/thú (icon việc ✕), bếp chưa có gì nấu (đùi thịt ✕), đình công (icon việc ✕, giữ tới khi hết đình công).
  - Nhận lệnh: nhún + mặt tươi, không bong bóng.
  - API mới trên `Villager`: `emote` / `chatter` / `think` / `clear_bubble` / `hold_sign` / `lower_sign`; bỏ `say()` và 30 key `BUBBLE_*`.
- **Luật ăn mới:**
  - Đói < 50 → chỉ đi ăn ở bếp (lửa trại), vừa đi vừa nghĩ tới đùi thịt. Bỏ `BushFoodSource`: thổ dân không tự đi hái quả ăn nữa.
  - Bếp hết đồ: người rảnh ngồi bệt nũng nịu (`TaskSulk`, hoạt họa `pout`), thỉnh thoảng nghĩ tới đùi thịt. Người đang làm việc được giao thì làm tiếp, chỉ thỉnh thoảng nghĩ.
  - Đói = 0 thì ai cũng ngồi giơ biển đùi thịt.
  - Vừa mệt vừa đói mà bếp hết đồ thì đi ngủ trước.
  - Ăn một phần ở bếp: no căng 100, +6 giải trí (món chín +10 nữa), +10 thể lực.
  - Ván mới có sẵn 8 quả ở lửa trại.
- Hình mới: `ui/thought_bubble`, `props/sign`, `icons/cross`, `icons/question`, `icons/dots` (ASSET_SPEC + `art_specs`).
- Spec: cập nhật `MVP_PROMPT.md` / `CLAUDE.md` (đầu file, mục 2, 3.1, 5.2, 5.3, 5.5, 6.1, 6.2, 13).
- Test: 53 test (thêm: ngồi dỗi → giơ biển → có đồ thì đi ăn, no căng, thể lực chỉ +10; người đang làm việc không ngồi dỗi; hết quả thì giơ biển). Công cụ chụp màn hình thêm `--hungry`.

### Quyết định
- **Người đang được giao việc không ngồi dỗi khi bếp hết đồ** (chỉ dỗi khi đói lả). Nếu ai cũng bỏ việc để dỗi thì người hái quả cũng ngồi dỗi, làng kẹt luôn.
- **`EAT_ENERGY = 10`:** làm việc nặng thì giữa hai bữa (Đói 100 → 50) mất ~120 giây, cũng là ~50 thể lực. Ăn chỉ bù ~20% nên vẫn phải ngủ.
- **Một quả cũng làm no căng** (đúng "đồ bếp hồi 100%"). Hệ đồ ăn còn chờ chốt (gộp thịt/cá/quả) nên chưa cân lại.

## Đợt 2 — Lao động & tài nguyên (2026-10-02)

**Trạng thái:** xong, chờ chạy thử và duyệt — chưa commit (chủ project tự commit).

### Đã làm
- **Giao việc** chỉ qua `NormalController` → `Commands.assign_job(villager_id, target)`. Chạm (hoặc kéo-thả thổ dân) vào cây → chặt, đá → đập, bụi quả → hái, chỗ câu cá → câu, lợn rừng/hươu → săn, lửa trại → nấu ăn. Chạm mặt đất trống → `Commands.move_villager()`: đi tới đó, đặt điểm neo mới, bỏ việc. Ra lệnh xong thì bỏ chọn.
- **`Job` (việc được ghi nhớ) tách khỏi `Task` (lượt đang làm).** Bộ não bước 6 tạo lượt tiếp theo mỗi khi rảnh: làm → khuân về kho → làm tiếp. Đói/mệt/đình công chỉ thay Task, Job vẫn còn nên xong là tự quay lại. Đang khuân dở mà bị ngắt thì lượt sau khuân nốt (`TaskDeliver`). Thêm mức ưu tiên `WORK` (IDLE < WORK < NEED < SCRIPTED).
- **Hết tài nguyên:** tìm cái tương tự gần nhất trong bán kính (8 ô; hái quả và săn 14 ô), bỏ qua cái người khác đã nhận. Không còn thì thôi việc, đứng chờ tại chỗ (điểm neo = chỗ đang đứng), bong bóng "Hết cây rồi!" / "Hết đá rồi!" / "Hết quả rồi!" / "Hết thú rồi!". Không tới được 3 lần liền → "Không tới được!".
- **Dữ liệu:** `data/jobs.gd` (mỗi việc: mục tiêu, giây, sản lượng, hoạt họa, đồ nghề, bụi, chữ), `data/resources.gd` (gỗ, đá, quả, thịt sống, cá sống, món chín). Lửa trại có thêm cờ `material_storage` và `cook_station` — Đợt 3 chỉ cần gắn cờ cho Kho/Bếp.
- **Tài nguyên trên map:** cây chặt 3 lượt thành gốc, ~3 ngày sau mọc lại; đá đập 4 lượt thì vỡ vụn biến mất (ô đó thành lối đi); vật rung lên mỗi nhát. Chỗ câu cá không cạn.
- **Thú** (`world/animal.gd`): 4 con (lợn rừng, hươu) lang thang trên đồng cỏ, gặm cỏ; thợ săn tới gần thì giật mình đứng im (❗). Bị săn: ngất, sao quay, "bụp" biến mất → 3 thịt; 2 phút sau con mới xuất hiện.
- **Nấu ăn ở lửa trại** (`TaskCook`): lấy 1 thịt/cá sống → 10 giây → 1 món chín. Chưa có gì thì đứng chờ cạnh lửa, thỉnh thoảng nhắc "Chưa có gì để nấu...". Dân đói ăn món chín trước (hồi 60 Đói + vui thêm), rồi tới quả; thịt/cá sống không ăn.
- **Kỹ năng:** làm việc tích kinh nghiệm theo giây (việc thích ×2), đủ 90/180/300/480 thì lên cấp: bong bóng "Lên cấp!", sao bung ra, thông báo nổi. Cấp hiện tại nằm ở `VillagerStatus` (lưu được), `VillagerData.skills` chỉ còn là cấp khởi đầu. Cấp ảnh hưởng tốc độ làm qua `Task.work_speed()`.
- **Đình công** (Giải trí = 0): quăng đồ nghề (đồ văng ra rơi xuống đất), dậm chân, 💢, thông báo "{tên} đình công!". Trong lúc đó 💢 luôn trên đầu, chỉ đứng chơi tại chỗ, giao việc thì nhớ nhưng nói "Không làm!". Giải trí hồi ≥ 40 thì "Làm tiếp thôi!" và quay lại việc.
- **Lười** nghỉ tay giữa chừng (35% mỗi lượt, 4 giây, ngồi, "Nghỉ tí...") rồi tự làm tiếp.
- **Hoạt họa mới:** chặt (giơ rìu ra sau đầu rồi bổ), đập đá (nện búa), câu cá, nấu (khuấy nồi), vung giáo, dậm chân đình công, khuân đồ (hai tay giơ đồ trên đầu, dùng chung với đi/đứng). Đồ nghề cầm tay dùng lại icon kỹ năng, xoay theo cánh tay. Thổ dân ưu tiên đứng bên trái/phải vật khi chặt/đập.
- **Phản hồi:** icon việc trên đầu; đường chấm chấm chạy tới nơi được giao + vòng vàng dưới mục tiêu (cho người đang chọn và 3 giây sau mỗi lệnh); rê chuột lên mục tiêu khi đang chọn người → sáng vòng; kéo-thả có đường kéo; cờ nhỏ ở chỗ bảo đi tới; bong bóng "Ugh!" / "Đi đây!" / "Lát nữa nhé!" (đang ăn/ngủ); bụi khi chặt/đập; số bay "+3 gỗ" ở kho (`fx/fx_layer.gd`).
- **HUD Normal:** thanh tài nguyên góc trên-phải (icon + số theo `Loc.number`, chỉ tính đồ đã vào kho, số nảy khi tăng, tooltip tên), "Ngày N", 4 nút tạm dừng/×1/×2/×3. Phím Space (tạm dừng ↔ chạy lại đúng tốc độ cũ), 1–3. Ra lệnh được cả khi đang tạm dừng.
- **Thông báo nổi** (`ui/common/toast.tscn`) nghe `EventBus.village_event(key, args, icon)` — chỉ mang key, sẵn để làm nhật ký làng Đợt 4.
- **Bảng thông tin:** thêm dòng "Việc được giao: …" (hoặc gợi ý cách giao việc / "Đang đình công"), sao kỹ năng cập nhật ngay khi lên cấp.
- **Đồng hồ ngày** đơn giản trong `GameState` (4 phút một ngày, phát `day_changed`) — ánh sáng ngày đêm vẫn để Đợt 3.
- **Hình mới:** `icons/res_wood`, `res_stone`, `res_meat`, `res_fish`, `res_meal`, `icons/angry`, `animals/boar`, `animals/deer`, `fx/dust`, `ui/speed_pause`, `speed_1..3`, `ui/target_ring`, `ui/move_marker` (ASSET_SPEC.md + `data/art_specs.gd`).
- **Test:** 51 test (thêm `test_jobs.gd`, 11 test). Mô phỏng 5 phút: 3 chặt + 2 đập + 1 người không giao việc — gỗ/đá tăng mỗi phút (lần chạy gần nhất: gỗ 30 → 60 → 72 → 96 → 114, đá 8 → 14 → 18 → 22 → 30), watchdog im lặng, không ai bỏ việc, người rảnh không rời điểm neo. Thêm: ăn xong quay lại việc cũ, hết bụi thì dừng + bong bóng, đình công rồi làm lại, săn → nấu ra món chín, câu cá, controller chạm/kéo giao việc + đặt điểm neo, HUD + tạm dừng, tham số `*_key` được dịch. Soi cảnh báo strict: sạch.
- Công cụ chụp màn hình thêm `--jobs` (giao 2 chặt, 1 đập, 1 hái ngay khi ra khỏi hang, chụp thêm `work.png`).

### Quyết định
- **Ra lệnh xong thì bỏ chọn** — tránh lỡ chạm mặt đất làm người đó bỏ việc. Đường chấm chấm vẫn hiện 3 giây để thấy họ đi đâu.
- **Chạm mặt đất = bỏ việc** và đi tới đó.
- **Đá vỡ hết thì biến mất**, cây thành gốc rồi mọc lại.
- **Mỗi cây/đá/bụi/chỗ câu/con thú chỉ một người làm**; giao nhiều người vào cùng một cây thì người sau tự sang cây gần đó.
- **Đầu bếp không có gì nấu thì đứng chờ** (mỗi lượt chờ 6 giây cho watchdog khỏi tưởng kẹt), không bỏ việc.
- **Cấp kỹ năng chỉ tăng tốc độ**, không tăng sản lượng.
- **Hái quả tìm bụi tương tự trong 14 ô** (không phải 8): bụi trên map cách nhau ~9–13 ô nên 8 ô làm người hái dừng sau đúng một bụi.
- Quả hái về cất ở lửa trại → dân đói lấy ở đó trước (đúng như `StoredFoodSource` đã chuẩn bị).
- Thú và đá vỡ **không bị xoá khỏi cây node** (chỉ ẩn) để Job/Reservations không bao giờ giữ node đã giải phóng. Thú dựng bằng code (`Animal.new()`), không cần `animal.tscn`.
- `Loc.t`: tham số tên kết thúc `_key` là key dịch khác (`{"job_key": "JOB_CHOP"}` → `{job}`) — để thông báo/nhật ký chỉ lưu key. Thêm key `RES_<ID>_NOUN` (viết thường) để ghép vào câu.
- Phím Space/1–3 do `NormalController` xử lý (chạy cả khi tạm dừng); nút bấm ở HUD; cả hai gọi `Commands`.

### Còn biết
- **Đình công khá thường** khi làm việc không thích liên tục: theo spec giải trí 100 → 0 trong 1 ngày làm việc (4 phút), nên một người làm miệt mài sẽ đình công sau chừng 5–6 phút chơi, và đứng chơi hồi lại 40 giải trí mất 1–4 phút (tán gẫu thì nhanh). Xem phần số nên chỉnh.
- **Ngủ hơi thường** lúc mới làm việc: thể lực khởi đầu 60–100 mà làm việc hết sạch trong 1 ngày → vài phút đầu đã có người đi ngủ (đúng spec).
- Thợ săn đứng chéo/dưới con thú lúc vung giáo (thú đứng sững trước khi người tới đúng bên cạnh) — trông vẫn ổn.
- Thợ câu đứng trên bờ, chưa có dây câu/phao vẽ xuống nước.
- Đầu bếp đứng sát lửa trại hơi chồng hình với ngọn lửa.
- Khi 5 người cùng giao đồ ở lửa trại có lúc đứng chồng lên nhau một chút.
- Đồ đang khuân dở mà người chơi bảo đi chỗ khác (chạm mặt đất) thì đồ đó mất.
- Chưa có nút "thôi việc" trong bảng thông tin (chạm mặt đất là cách bỏ việc).
- Bảng debug góc trên-trái vẫn hiện ở bản debug, nằm cạnh HUD.

### Số nên tinh chỉnh (đề xuất)
- `FUN_DECAY_WORK` (100/ngày) → thử 100 / 2 ngày nếu thấy đình công quá thường; hoặc tăng `FUN_RESTORE_IDLE` (0,15/giây) để hết giận nhanh hơn.
- `ENERGY_DECAY_WORK` (100/ngày) → 100 / 1,5 ngày nếu thấy ngủ nhiều quá.
- `SKILL_XP_TO_NEXT` = 90/180/300/480 giây làm việc: lên cấp 2 khá sớm (~1,5 phút, việc thích ~45 giây) cho người chơi thấy ngay; cấp 5 cần ~17 phút làm một việc.
- `COOK_SECONDS_CAMPFIRE` = 10, `HUNT_SECONDS` = 4, `MEAT_PER_HUNT` = 3, `FISH_SECONDS` = 10: một thợ săn nuôi được ~1 đầu bếp; câu cá chậm hơn săn.
- `ANIMAL_COUNT` = 4, `ANIMAL_RESPAWN_SECONDS` = 120.
- `LAZY_BREAK_CHANCE` = 0,35.

---

## Đợt 1.5 — Tái cấu trúc đa chế độ + hành vi "nghe lời" (2026-10-01 → 10-02)

**Trạng thái:** đã duyệt (chuyển sang Đợt 2).

Gồm hai phần: (A) tái cấu trúc theo MVP_PROMPT mục 3.2 (2026-10-01), (B) áp dụng thiết kế mới chốt ngày 2026-10-02 sau khi chơi lại game gốc (thổ dân nghe lời, 4 chỉ số, kỹ năng + việc thích).

### Phần B — Thiết kế mới (2026-10-02)

**Tài liệu:** MVP_PROMPT.md viết lại các mục 2, 3.2, 4, 5.x, 6.x, 7, 8, 9.x, 10, 11, 12, 13, God mode; CLAUDE.md = bản copy y nguyên + phụ lục ghi chú kỹ thuật. Quyết định chốt thêm: ngày đêm chỉ để trang trí (ánh sáng đổi theo giờ, đổ bóng theo mặt trời — Đợt 3), dân số khởi đầu 4 / tối đa 50, hẹn hò tỉ lệ ~10% mỗi lần kiểm tra và có em bé ngay, việc thích chỉ thưởng không phạt.

**Đã làm trong code:**
- **Thổ dân nghe lời** (`villager_autonomy = OBEDIENT`): mỗi người có **điểm neo** (chỗ đứng sau khi ra khỏi hang). Rảnh thì chỉ làm hoạt cảnh trong bán kính `IDLE_RADIUS_CELLS` = 3 ô: dạo vài bước (`TaskStroll`, thay `TaskWander` đi khắp làng), ngồi, gãi, hái hoa dưới chân, tán gẫu với người đứng gần (`IDLE_CHAT_RANGE_CELLS` = 3). Ra xa (sau khi ăn/ngủ) thì tự đi về (`TaskReturn`).
- **Chỉ tự rời chỗ khi:** Đói < 50 → đi ăn; Thể lực < 50% → đi ngủ. Bỏ "ăn vặt khi rảnh"; bỏ bước Lãng mạn mang hoa đi tặng (thành hoạt cảnh hẹn hò ở Đợt 4).
- **Nguồn đồ ăn / chỗ ngủ cắm thêm được:** `FoodSource` (`BushFoodSource` hái quả, `StoredFoodSource` lấy đồ cất ở lửa trại — đang trống tới Đợt 2), `SleepSpot` (ngủ đất cạnh lửa trại ×1). `WorldFinder.find_food_for()` / `find_bed_for()` chọn nguồn; Đợt 3 chỉ cần thêm Bếp/Lều. Lửa trại có cờ `food_storage` trong `data/buildings.gd`.
- **4 chỉ số dạng dữ liệu** (`data/needs.gd`): Máu, Đói, Thể lực, Giải trí — icon, màu, ngưỡng cảnh báo, tốc độ theo hoạt động (rảnh / làm việc / ngủ). `VillagerNeeds.step()` chạy theo `GameModeConfig.enabled_needs` (tắt chỉ số nào thì nó đứng yên và ẩn khỏi bảng). Luật dính nhau: việc nặng đói ×1.5, làm việc thích giải trí giảm ×0.25 (việc khác bình thường), Siêng năng giảm chậm hơn, Đói = 0 thì mất máu.
- **Chạm đáy:** Thể lực = 0 → gục ngủ tại chỗ tới 30% rồi đi tìm chỗ ngủ (`TaskSleep` kiểu `collapsed`). Máu = 0 → ngất 20 giây, sao quay quanh đầu, tỉnh dậy với 20 máu + chút no rồi đi ăn ngay (`TaskKnockedOut`; độ khó Thường có thể chết — Đợt 5).
- **Kỹ năng + việc thích** (`data/skills.gd`): 9 loại việc, cấp khởi đầu 1–2 ngẫu nhiên (+1 theo tính cách, tối đa 3), đúng một việc thích. Thay hoàn toàn `best_job`. `Task.work_speed()` tính theo cấp kỹ năng; hái quả nhanh hơn khi kỹ năng Hái lượm cao. Lên cấp: Đợt 2.
- **`GameModeConfig`** thêm `villager_autonomy` (OBEDIENT / AUTONOMOUS) và `enabled_needs`; `GameState.get_mode()` trả luật mặc định = Normal khi chưa nạp chế độ (test). Bộ não đọc cờ autonomy, nhánh AUTONOMOUS để sẵn chỗ.
- **Hiển thị:** bảng thông tin thay chữ bằng **icon + thanh nhỏ** cho 4 chỉ số (thanh đỏ khi dưới ngưỡng, tên nằm trong tooltip) và **lưới kỹ năng** (icon + sao cấp + tim việc thích). Trên đầu: icon chỉ số thấp nhấp nháy (ẩn khi đang ngủ/ngất), sao quay khi ngất.
- **Khởi đầu 4 thổ dân** (2 nam, 2 nữ). Thể lực khởi đầu 60–100 để không ai vừa ra khỏi hang đã đi ngủ.
- **Hình mới:** `icons/stat_health`, `stat_energy`, `stat_fun`, 9 `icons/skill_*`.
- **Test:** 40 test. Mới: `test_needs.gd` (tốc độ theo hoạt động, việc nặng, việc thích không phạt, tắt chỉ số, đói mất máu, cờ chế độ, gục ngủ và ngất trong thế giới thật). Mô phỏng 5 phút: 4 người, rảnh thì không ai ra xa điểm neo, có tự đi ăn, không còn ăn vặt.

**Quyết định:**
- Điểm neo đặt ở ô thổ dân đi tới sau khi ra khỏi hang (quanh lửa trại); Đợt 2 chạm mặt đất trống → đặt điểm neo mới.
- Icon cảnh báo trên đầu ẩn lúc đang ngủ/ngất (đã có chữ Z / sao) cho đỡ rối.
- Ngưỡng nhấp nháy: Máu < 50, Đói < 50, Thể lực < 50, Giải trí < 20.
- Đình công (giải trí = 0) chưa viết vì chưa có việc để bỏ — Đợt 2.

**Còn biết:**
- Làng "tĩnh" hơn cuối Đợt 1 — đúng thiết kế: chưa giao việc thì dân chỉ quanh quẩn lửa trại.
- Hiếm khi thấy đi ngủ: đứng chơi gần như không mất thể lực. Sẽ thấy rõ khi có việc (Đợt 2).
- Kho ở lửa trại còn trống nên dân đói vẫn đi hái bụi quả (có thể xa vùng dạo chơi) rồi tự quay về.

### Phần A — Tái cấu trúc (2026-10-01)

Chỉ tái cấu trúc theo MVP_PROMPT mục 3.2, không thêm tính năng. Game chạy y như cuối Đợt 1.

### Rà soát (Bước 1) — các chỗ vi phạm đã tìm thấy
- Lõi tự dịch chữ (`Loc.t` trong brain/task, 8 chỗ) và ra lệnh thẳng cho phần hiển thị bong bóng.
- Chưa có API chung `Commands`; `World.spawn_villager` nhận vị trí pixel thay vì ô.
- Chưa có tầng Controller: `SelectionController` nằm trong `world/` và tự nghe InputRouter.
- Chưa có `GameModeConfig`; `main` gắn cứng mọi thứ, không qua cơ chế chọn chế độ.
- `VillagerData` là RefCounted, ngoại hình lưu chỉ số, trộn lẫn trạng thái lúc chơi (nhu cầu), `id` do hàm random cấp.
- UI chưa chia `ui/common/` – `ui/normal/`.

### Đã sửa (Bước 2)
- **`VillagerData` thành `Resource`** — chỉ còn "bản thiết kế": `display_name`, `gender`, `age_stage` (đổi tên từ `stage`), `appearance`, `voice_pitch`, `traits`, `best_job`. Ngoại hình lưu **ID mảnh** (`head_02`, `face_01`, `hair_03`, `body_01`, `accessory_02` hoặc `""`) + **mã màu** `#RRGGBB` cho da/áo/tóc.
- **`VillagerStatus`** (mới) giữ trạng thái lúc chơi: No, Năng lượng, Vui, Máu, Sức đánh, `mood()`. Nhu cầu ban đầu do lõi đặt lúc spawn (RNG gieo theo seed map), không còn do hàm random.
- **`VillagerFactory.create()`** chỉ trả về `VillagerData` (bỏ tham số id).
- **`World.spawn_villager(data, cell, status = null)`** là cách duy nhất tạo thổ dân; lõi cấp `id`, có bảng tra `get_villager(id)`.
- **Autoload `Commands`**: `spawn_villager(data, cell) -> id`, `get_villager(id)`, `set_game_speed(speed)`. Hoạt cảnh chui ra khỏi hang cũng đi qua `Commands.spawn_villager`.
- **Lõi không tự dịch, không ra lệnh cho phần hiển thị**: brain/task gọi `villager.say(key, args, icon)`, `emote(icon)`, `show_heart()`; `Villager` phát signal, `Overhead` nghe rồi mới dịch. Icon việc trên đầu và chữ Z khi ngủ do `Overhead` tự đọc từ thổ dân. Bảng thông tin tự dịch `activity_key/args`.
- **`GameModeConfig`** (`modes/game_mode_config.gd`) với 7 cờ theo spec + `id`, `name_key`, `starts_with_tribe`, `controller_scene`, `hud_scene`. **`modes/normal_mode.tres`** là chế độ Normal.
- **`PlayerController`** (lớp gốc) + **`NormalController`** (`modes/controllers/`) — chuyển nguyên logic chọn/rê/nhấn giữ/huỷ từ `SelectionController` cũ (đã xoá).
- **`main.gd` → `start_game(mode)`**: `GameState.new_game(mode)`, dựng World, gắn controller + HUD theo config, chạy hoạt cảnh mở đầu nếu `starts_with_tribe`. Có `--mode=<đường dẫn .tres>` trên dòng lệnh.
- **UI**: `ui/common/` (bảng thông tin, bảng debug), `ui/normal/hud.tscn` (HUD Normal, đang trống — Đợt 2 thêm tài nguyên/tốc độ).
- Hình mặt đổi tên `face_<kiểu>_<biểu cảm>` (vd `face_01_happy`) để `face` trong ngoại hình là một ID mảnh thật.
- Save/load: chưa có lưu ván chơi (Đợt 3); `VillagerData.to_dict/from_dict` và `VillagerStatus.to_dict/from_dict` đã theo cấu trúc mới, có test đi qua JSON.
- Test: 33 test (thêm `test_modes.gd`: cờ của Normal, khởi động nạp đúng controller + HUD, `Commands.spawn_villager` đúng ô / từ chối ô bị chặn; thêm test ngoại hình là ID mảnh + mã màu, VillagerStatus lưu/đọc). Test mô phỏng 5 phút vẫn qua.
- Tài liệu: CLAUDE.md thêm mục kiến trúc + quy tắc không tự commit; ASSET_SPEC cập nhật tên file mặt.

### Quyết định
- Camera và bảng debug vẫn nghe thẳng InputRouter — kéo/zoom bản đồ giống nhau ở mọi chế độ.
- Task vẫn gọi thẳng `villager.rig.play(...)` (hoạt họa là một phần của thổ dân); tách hết hoạt họa khỏi lõi vượt quá phạm vi "chỉ tái cấu trúc".
- `starts_with_tribe` là cờ thêm ngoài 7 cờ bắt buộc, để chế độ Thần Linh có thể bắt đầu với map trống.

### Còn biết
- Cùng một seed giờ cho ngoại hình bộ lạc **khác** so với Đợt 1 (thứ tự bốc số ngẫu nhiên đổi vì thêm ô `face`). Hành vi không đổi.
- Test `test_modes` cố ý tạo thổ dân trên ô bị chặn nên Output có một dòng WARNING "ô … bị chặn" — đúng như mong đợi.

---

## Đợt 1 — Thổ dân sống động (2026-10-01)

**Trạng thái:** đã duyệt (chuyển sang Đợt 1.5).

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
