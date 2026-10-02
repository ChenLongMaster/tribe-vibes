# DEVLOG — Tribe Vibes (Bộ Lạc Chill)

Mỗi đợt một mục: đã làm gì, chọn gì và vì sao. Mục mới nhất ở trên cùng.

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
