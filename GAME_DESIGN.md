# GAME_DESIGN — Tribe Vibes (Bộ Lạc Chill)

> **Tên game: Tribe Vibes** (tiếng Việt: **Bộ Lạc Chill**). Tên chỉ được khai báo ở **hai chỗ**: `application/config/name = "Tribe Vibes"` trong `project.godot`, và key dịch `GAME_TITLE` trong `i18n/strings.csv` (cột `vi` = `Bộ Lạc Chill`, cột `en` = `Tribe Vibes`). Không viết cứng tên game ở bất kỳ chỗ nào khác (màn hình bắt đầu, tiêu đề cửa sổ, tên file save…), để sau này đổi tên hay thêm phụ đề chỉ cần sửa hai chỗ đó.

> Tài liệu thiết kế game (trước đây tên `MVP_PROMPT.md`): luật chơi, hành vi thổ dân, tài nguyên, công trình, các đợt làm việc của một game colony-sim tiền sử lấy cảm hứng từ **Prehistoric Tribes** (Gear Games / THQ Wireless, 2008). Đây là **nguồn chính** — mọi quyết định thiết kế mới ghi vào đây.
> Đặt file ở thư mục gốc project. `CLAUDE.md` là bản copy y nguyên của file này (cộng phụ lục ghi chú kỹ thuật cho Claude ở cuối) để Claude Code tự đọc mỗi phiên.

> **Cập nhật thiết kế 2026-10-02** (sau khi chơi lại game gốc): thổ dân **nghe lời** — rảnh thì chỉ dạo quanh chỗ đứng, chỉ tự rời chỗ khi đói, mệt hoặc muốn tìm bạn đời; 4 chỉ số hiển thị bằng icon; kỹ năng theo từng việc + một việc thích; tìm bạn đời qua tặng hoa; công trình có diện tích, 3 cấp, nhiều thợ xây và người phụ trách. Các quyết định này ưu tiên hơn mọi spec cũ.

> **Cập nhật thiết kế 2026-10-02 (lần 2):** thổ dân **không nói chữ**, chỉ "nói" bằng hình: **bong bóng nghĩ** (mây) khi muốn gì đó, **giơ tấm biển** vẽ hình khi cần người chơi ra tay, tán gẫu bằng icon (mục 6.2). Đói < 50 thì **chỉ đi ăn ở bếp** (không tự hái quả); bếp hết đồ thì **ngồi bệt nũng nịu**, đói lả thì giơ biển vẽ đồ ăn. Ăn ở bếp no căng, cộng chút vui và thể lực (mục 5.2, 5.3).

> **Cập nhật thiết kế 2026-10-02 (lần 3) — tài nguyên & đồ nghề:** người chơi chỉ để ý **3 tài nguyên chung: gỗ, đá, thức ăn** (icon đùi thịt). Bên trong game nhớ món cụ thể (quả / cá / thịt, khúc gỗ / bó củi, đá tảng / đá cuội) để vẽ cho đúng. **Món chín và vũ khí là đồ riêng của công trình** (bếp, lò rèn), không nằm trên thanh tài nguyên. **Rìu, cuốc, giáo** rèn ở lò rèn: không có thì chỉ nhặt bằng tay (củi, đá cuội, hái quả, câu cá). Xây nhà: thợ xây đội mũ, khuân vật liệu từ kho tới đủ rồi mới xây. Tấm biển: đứng thì cắm xuống đất, ngồi thì giơ hai tay (mục 6.2, 9).

---

## 0. Cách làm việc (đọc trước)

- Làm **từng đợt** theo mục 12. Xong một đợt thì **dừng lại**, báo cáo, chờ mình chạy thử và đồng ý rồi mới làm đợt tiếp.
- **Không tự `git commit` / `git push`.** Mình tự commit.
- Báo cáo cuối mỗi đợt gồm:
  1. Đã làm gì (ngắn gọn).
  2. Cách chơi thử để kiểm tra (bấm gì, chờ gì, sẽ thấy gì).
  3. Lỗi hoặc hạn chế còn biết.
  4. Những con số nên tinh chỉnh.
- Trước khi báo xong, **tự kiểm tra lỗi** bằng Godot headless (nếu có lệnh `godot` trong PATH):
  - `godot --headless --path . --editor --quit` để import tài nguyên và bắt lỗi parse.
  - `godot --headless --path . --quit-after 600` để chạy game khoảng 10 giây và bắt lỗi runtime.
  - Đọc output, sửa hết lỗi (**errors**) và cảnh báo (**warnings**) liên quan tới code của mình. Nếu cú pháp lệnh ở Godot 4.7 khác thì tự điều chỉnh.
- Không cài plugin hay addon bên thứ ba khi chưa hỏi mình. Chỉ dùng tính năng có sẵn của Godot.
- Khi không chắc một quyết định thiết kế thì chọn phương án **đơn giản, dễ thương, dễ hiểu cho người chơi casual**, ghi lại trong báo cáo, rồi làm tiếp.
- Tạo và luôn cập nhật file `DEVLOG.md`: mỗi đợt một mục, ghi những gì đã làm và các quyết định đã chọn.

---

## 1. Bối cảnh & mục tiêu

- Người chơi chính là **bạn gái mình**. Cô ấy thích game đơn giản, không phải nghĩ nhiều, hình đẹp và dễ thương. Nhưng game **quá đơn giản thì cô ấy chơi một lúc là chán**.
- Vì vậy mục tiêu là một colony-sim kiểu **"RimWorld rất nhẹ"**: thổ dân có tên, cá tính, làm trò ngộ nghĩnh, còn người chơi chỉ cần chạm để giao việc và xây nhà.
- Bám sát cơ chế và tinh thần của Prehistoric Tribes, nhưng **không dùng tên, hình, âm thanh hay logo gốc**. Chỉ lấy cảm hứng từ cơ chế.
- Tông game: **hài hước, ấm áp, tinh nghịch**. Thổ dân hơi ngố nhưng đáng yêu, không bạo lực máu me. Bị đánh thì ngất, hiện sao bay quanh đầu.

---

## 2. Game gốc — những gì cần bám theo

Các chi tiết dưới đây đã được xác minh qua trang chính thức của Gear Games và bài review của Pocket Gamer (2008), cộng quan sát khi chơi lại.

**Cốt truyện mở đầu:** kỷ băng hà kết thúc, cả bộ lạc chui ra khỏi hang và bắt đầu dựng làng. Game có tối đa khoảng **50 thổ dân**.

**Thổ dân "có đầu óc riêng":** lúc rảnh họ luôn bận làm gì đó **tại chỗ**, như nói chuyện với nhau, ăn trưa, hái hoa, gãi mông, đi disco. Người chơi giữ cho họ no, ấm, an toàn, và giao các việc như thu hoạch, săn bắn, câu cá, nấu ăn.

**Quan sát khi chơi lại (2026-10-02):** thổ dân trong Prehistoric Tribes **đứng chờ lệnh khi rảnh, không tự đi kiếm việc**. Họ chỉ lảng vảng quanh chỗ đang đứng và làm trò; muốn có gỗ, có đồ ăn thì người chơi phải giao việc. Tribe Vibes chế độ Normal theo đúng kiểu này (xem mục 5.2).

**Vòng lặp chính:**
1. Dựng **lều ngủ**, nơi thổ dân nghỉ ngơi và cũng là nơi họ "yêu nhau" để có thêm người.
2. Xây thêm **bếp**, **kho**, **kho vũ khí** (làm vũ khí đánh bộ lạc ăn thịt người), và cả **phòng tập thể lực** (gym).
3. Muốn xây thì phải có tài nguyên (gỗ, đá). Muốn sống thì phải tìm, săn và chế biến thức ăn.
4. Các bộ lạc ăn thịt người kéo đến **theo đợt** để phá nhà và tấn công dân. Sau mỗi đợt phải sửa nhà và gây lại dân số.
5. Rèn dân bằng vũ khí tốt hơn và cho họ tập luyện để tăng chỉ số. Đặt **bẫy lưới** để phòng thủ.
6. Khám phá vùng đất xung quanh để mở thêm khu vực mới.

**Điều khiển:** chủ yếu là chạm/click. Chạm một thổ dân để xem trạng thái, rồi chạm vào vật thể (ví dụ cái cây) để họ đi làm việc đó. Game gốc có kéo-thả thổ dân và bản đồ dạng lưới.

**Chiến đấu:** đơn giản, chỉ cần dàn quân vào vị trí rồi xem họ tự đánh. Thắng hay thua phụ thuộc vào chỉ số đã rèn từ trước.

**Điểm yếu của game gốc, cần sửa:**
- Người chơi khó biết thổ dân có làm theo lệnh không.
- Thổ dân hay **bỏ dở việc** (ví dụ xây nhà dở dang) mà không báo gì.
- Người chơi phải kéo màn hình theo dõi xem họ có đi đúng chỗ không.

**Cách sửa:** luôn có **phản hồi rõ ràng**: icon việc đang làm trên đầu, đường đi chấm chấm tới nơi được giao, bong bóng nghĩ / tấm biển vẽ hình giải thích khi bỏ việc (nghĩ tới đùi thịt, nghĩ tới giấc ngủ, giơ biển vẽ cái cây gạch chéo). Họ có thể lười một chút cho đáng yêu, nhưng **luôn tự quay lại làm tiếp** và người chơi luôn thấy được vì sao.

---

## 3. Kỹ thuật bắt buộc

| Mục | Quyết định |
|---|---|
| Engine | Godot **4.7.x**, bản Standard |
| Ngôn ngữ | **GDScript**, dùng static typing (`var hunger: float`, `func f(x: int) -> void`). Không dùng C# (để còn xuất được bản Web) |
| Renderer | **Compatibility** (chạy được trên Web và điện thoại yếu) |
| Góc nhìn | 2D top-down 3/4, map dạng lưới |
| Khung hình | Ngang 16:9, độ phân giải gốc **1280×720**, `stretch/mode = canvas_items`, `aspect = expand` |
| Nền tảng | PC (chạy từ editor), **Web** (bản chính để gửi đi), Android sau này |
| Map | `TileMapLayer` (không dùng `TileMap` cũ), mỗi ô 64×64 px |
| Tìm đường | `AStarGrid2D`, chỉ tính lại khi đổi mục tiêu hoặc map thay đổi |
| Ngôn ngữ trong game | Mọi chữ hiển thị phải đi qua autoload `Loc` (bọc quanh `tr()`). File `i18n/strings.csv` có cột `keys,vi,en`. Mặc định `vi`; cột `en` được để trống. Chi tiết ở mục 3.1 |
| Font | Một font tròn, dễ thương, **có đủ dấu tiếng Việt**, giấy phép OFL. Gợi ý: **Nunito** hoặc **Baloo 2**, tải từ `github.com/google/fonts`. Kèm file `OFL.txt`. Kiểm tra bằng câu "Thổ dân đói bụng quá! Ừ, ở đây ấm áp." |
| Lưu game | `user://save.json`, tự lưu mỗi ngày trong game, có nút lưu thủ công |

### 3.1 Khung đa ngôn ngữ (làm ngay từ Đợt 0)

Bản đầu chỉ có tiếng Việt, nhưng code phải sẵn sàng để thêm tiếng Anh (hoặc ngôn ngữ khác) bằng cách **chỉ thêm một cột vào CSV và một file tên**, không phải sửa code.

1. **Không viết chữ cứng trong code hay scene.** Mọi chữ người chơi nhìn thấy đều là key, ví dụ `UI_BUILD`, `TOAST_BABY_BORN`, `TRAIT_LAZY_NAME`, `TRAIT_LAZY_DESC`. Đặt key theo tiền tố nhóm: `UI_`, `TOAST_`, `TRAIT_`, `JOB_`, `BUILDING_`, `RES_`, `GOAL_`, `LOG_`. (Thổ dân không nói chữ nên không có nhóm bong bóng thoại.)
2. **Không ghép chuỗi.** Dùng chỗ giữ chỗ có tên:
   ```gdscript
   # CSV: TOAST_BABY_BORN,"{name} chào đời!","{name} was born!"
   Loc.t("TOAST_BABY_BORN", {"name": baby.display_name})
   ```
   Không bao giờ viết `name + " chào đời!"`.
3. **Số nhiều.** Dùng hai key riêng `_ONE` và `_OTHER` cho câu có số đếm. Gọi qua `Loc.plural("RES_WOOD_COUNT", n)`. Tiếng Việt thì hai cột có thể giống nhau.
4. **Autoload `Loc`** (`autoload/loc.gd`) bọc quanh `tr()` / `TranslationServer`:
   - `t(key, args := {})`
   - `plural(key, n, args := {})`
   - `number(n)`: định dạng số theo ngôn ngữ (vi: `1.250`, en: `1,250`).
   - `set_language(code)`: đổi ngôn ngữ, lưu vào setting, phát signal `language_changed`.
   - `available_languages()`: đọc từ các cột có trong CSV.
   - Thiếu bản dịch thì **dùng tiếng Việt thay thế** và ghi cảnh báo trong log debug, không hiện key trống ra màn hình.
5. **Đổi ngôn ngữ thì UI cập nhật ngay**, không cần khởi động lại. Các node UI nghe `language_changed`, hoặc dùng chế độ tự dịch của Control.
6. **Không vẽ chữ vào hình.** Biển hiệu, nút bấm, thẻ nhiệm vụ đều dùng `Label` đè lên texture. Ghi rõ quy tắc này trong `ASSET_SPEC.md`.
7. **UI co giãn theo độ dài chữ.** Dùng container (`HBoxContainer`, `MarginContainer`…) và tự giãn, không đặt chiều rộng cứng cho nút hay bảng. Chữ quá dài thì xuống dòng hoặc thu nhỏ, không bị cắt.
8. **Bộ tên theo ngôn ngữ:** `data/names/names_vi.gd`, `data/names/names_en.gd` (để trống hoặc vài tên mẫu). Tên được chọn khi thổ dân sinh ra và lưu vào save, **không đổi** khi người chơi đổi ngôn ngữ.
9. **Dữ liệu game chỉ lưu key**, không lưu chữ đã dịch. Ví dụ save lưu `trait: "LAZY"` và nhật ký làng lưu `{key, args}`, khi hiển thị mới dịch. Như vậy đổi ngôn ngữ thì cả nhật ký cũ cũng đổi theo.
10. **Font:** font chính phải có đủ chữ Việt lẫn Latin cơ bản. Cấu hình sẵn chỗ gắn font dự phòng (`fallbacks`) trong Theme để sau này thêm ngôn ngữ khác.
11. Giữ file CSV gọn: mỗi dòng một key, sắp xếp theo nhóm, ghi chú bằng dòng bắt đầu bằng `#` nếu Godot hỗ trợ (không hỗ trợ thì tạo file `i18n/README.md` mô tả các nhóm key).

### 3.2 Kiến trúc đa chế độ (chừa chỗ ngay từ bây giờ)

Sau MVP, game sẽ có **2 chế độ** dùng chung một lõi:
- **Normal (Bộ Lạc)**: kiểu RTS/colony. Điều khiển từng thổ dân, giao việc, xây dựng, có nhiệm vụ, có thể thua. Thổ dân **nghe lời**: không có lệnh thì chỉ dạo quanh chỗ đứng.
- **God (Thần Linh)**: kiểu sandbox, giống WorldBox. Không điều khiển trực tiếp, chỉ dùng phép thần, tự tạo và thả nhân vật, không có nhiệm vụ, không thua. Thổ dân **tự lập**: tự kiếm việc kiểu RimWorld.

MVP **chỉ làm chế độ Normal**, nhưng code phải chia đúng 3 tầng để sau này cắm chế độ God vào mà không phải viết lại:

```
UI / HUD            → mỗi chế độ một scene riêng (NormalHUD; sau này GodHUD)
Player Controller   → diễn giải lệnh từ InputRouter (NormalController; sau này GodController)
Simulation Core     → world, villager, AI, nhu cầu, kỹ năng, tài nguyên, công trình, kẻ thù, ngày đêm, lưu game
                      KHÔNG biết đang ở chế độ nào — chỉ đọc cờ trong GameModeConfig
```

**Quy tắc bắt buộc:**
1. **Code của core không gọi thẳng vào UI.** Muốn báo gì thì phát signal qua `EventBus`.
2. **Mọi hành động của người chơi đi qua một API chung của core** (autoload `Commands`), ví dụ `assign_job(villager_id, target)`, `assign_staff(villager_id, building_id)`, `place_building(type, cell)`, `upgrade_building(building_id)`, `spawn_villager(data, cell)`, `apply_effect(effect_id, cell)`. UI và controller không sửa thẳng dữ liệu của thổ dân.
3. **Cùng một lệnh từ `InputRouter`, mỗi controller hiểu một kiểu.** Ví dụ chạm vào cây: `NormalController` giao việc chặt cây, sau này `GodController` thả phép đang chọn vào chỗ đó.
4. **Luật chơi đọc từ `GameModeConfig`** (một `Resource`), không viết cứng `if` rải rác. Ít nhất có:
   - Các cờ: `allow_direct_commands`, `goals_enabled`, `raids_auto`, `can_lose`, `god_powers_enabled`, `god_powers_unlimited`, `character_creator_enabled`.
   - `villager_autonomy`: `obedient` (Normal — chỉ làm việc được giao, rảnh thì dạo quanh chỗ đứng, xem mục 5.2) hoặc `autonomous` (God — tự kiếm việc kiểu RimWorld, làm sau MVP).
   - `enabled_needs`: danh sách nhu cầu đang bật (`health`, `hunger`, `energy`, `fun`) — hệ nhu cầu viết dạng dữ liệu (`data/needs.gd`), chế độ nào muốn tắt nhu cầu nào thì bỏ khỏi danh sách.
   MVP chỉ có một file `normal_mode.tres`.
5. **Màn hình bắt đầu nạp chế độ** bằng cách chọn `GameModeConfig`, rồi nạp controller và HUD tương ứng. MVP chỉ có nút Normal, nhưng luồng nạp phải đi qua cơ chế này.

**Dữ liệu nhân vật tách riêng (`VillagerData`):**
- Một `Resource` chứa toàn bộ thông tin để tạo một thổ dân: `appearance` (ID từng mảnh như `hair_03`, `face_02`, cùng màu da, màu áo), `display_name`, `gender`, `traits`, `skills` (cấp 1–5 cho từng loại việc, xem mục 5.4), `favorite_job` (đúng một việc thích), `age_stage`.
- Ngoại hình lưu bằng **ID mảnh**, không lưu đường dẫn ảnh, để thay art thật vẫn hiển thị đúng.
- Hàm sinh ngẫu nhiên chỉ **tạo ra một `VillagerData`**. Core chỉ có một cách tạo thổ dân: `spawn_villager(data, cell)`. Sau này trình tạo nhân vật của God mode cũng chỉ việc tạo ra một `VillagerData` rồi gọi cùng hàm đó.
- Lưu game lưu `VillagerData` cộng trạng thái hiện tại (`VillagerStatus`: các chỉ số, điểm kinh nghiệm kỹ năng; cộng vị trí, việc đang làm, việc được giao đang nhớ).

---

## 4. Cấu trúc project

```
res://
├─ project.godot
├─ GAME_DESIGN.md / CLAUDE.md / DEVLOG.md / ASSET_SPEC.md
├─ autoload/
│  ├─ game_state.gd      # tài nguyên, dân số, ngày giờ, tốc độ game, độ khó, chế độ đang chơi
│  ├─ event_bus.gd       # signal toàn cục (villager_born, raid_started, resource_changed…)
│  ├─ input_router.gd    # gom chuột + cảm ứng thành lệnh chung (xem mục 8)
│  ├─ loc.gd             # đa ngôn ngữ (xem mục 3.1)
│  ├─ commands.gd        # API chung của core cho mọi hành động người chơi (xem mục 3.2)
│  └─ save_system.gd
├─ modes/
│  ├─ game_mode_config.gd   # Resource: các cờ luật chơi (xem mục 3.2)
│  ├─ normal_mode.tres      # cấu hình chế độ Normal (MVP chỉ có file này)
│  └─ controllers/
│     └─ normal_controller.gd   # diễn giải lệnh InputRouter → Commands (sau này thêm god_controller.gd)
├─ data/
│  ├─ balance.gd         # MỌI con số cân bằng game nằm ở đây, dễ chỉnh
│  ├─ needs.gd           # định nghĩa 4 chỉ số (icon, luật tăng/giảm, ngưỡng) dạng dữ liệu
│  ├─ skills.gd          # định nghĩa các kỹ năng (icon, việc nặng hay nhẹ)
│  ├─ jobs.gd            # các việc giao được (mục tiêu, sản lượng, đồ cầm tay, đồ nghề bắt buộc) — nhiều việc chung một kỹ năng
│  ├─ resources.gd       # 3 tài nguyên chung + các "món" khuân về (giỏ quả, khúc gỗ, xô đá cuội…) + đồ riêng của công trình
│  ├─ tools.gd           # đồ nghề rèn: rìu, cuốc, giáo (mục 9.4)
│  ├─ buildings.gd       # định nghĩa công trình (diện tích, 3 cấp, chi phí, người phụ trách, chức năng, kho riêng)
│  ├─ traits.gd          # định nghĩa tính cách
│  └─ names/
│     ├─ names_vi.gd     # bộ tên thổ dân tiếng Việt
│     └─ names_en.gd     # để trống / vài tên mẫu
├─ world/
│  ├─ world.tscn/.gd     # map, sinh địa hình, quản lý lưới + AStarGrid2D
│  ├─ resource_node.tscn # cây, đá tảng, bụi quả, chỗ câu cá, củi, đá cuội
│  ├─ nature_spawner.gd  # củi rơi, đá cuội lăn ra, đá tảng từ vách đá, cây mọc lại — có giới hạn
│  └─ animal.tscn        # thú để săn
├─ villager/
│  ├─ villager_data.gd   # Resource: ngoại hình (ID mảnh), tên, giới tính, tính cách, kỹ năng, việc thích… (xem mục 3.2)
│  ├─ villager_status.gd # trạng thái lúc chơi: 4 chỉ số, kinh nghiệm kỹ năng, đồ nghề đang giữ
│  ├─ villager.tscn/.gd  # dữ liệu + máy trạng thái
│  ├─ villager_rig.tscn/.gd   # bộ khung cutout + animation theo code
│  ├─ villager_brain.gd  # chọn việc theo villager_autonomy (mục 5.2)
│  ├─ job.gd             # việc được giao mà thổ dân ghi nhớ
│  └─ tasks/             # từng việc cụ thể đang làm (chặt, khuân, ăn, ngủ, ngồi dỗi, lấy đồ nghề…)
├─ buildings/
│  └─ building.tscn/.gd  # một scene chung, cấu hình theo data
├─ enemies/
│  └─ cannibal.tscn/.gd
├─ ui/
│  ├─ common/            # dùng chung mọi chế độ
│  │  ├─ toast.tscn      # thông báo nổi ("Bé Tí chào đời!")
│  │  ├─ villager_panel.tscn   # chỉ số + kỹ năng bằng icon
│  │  └─ building_panel.tscn   # cấp, người phụ trách, nút nâng cấp
│  └─ normal/            # HUD riêng của chế độ Normal (sau này thêm ui/god/)
│     ├─ hud.tscn        # thanh tài nguyên, ngày, nút tốc độ
│     ├─ build_menu.tscn
│     └─ goals_panel.tscn
├─ fx/                   # bụi, tim, sao, số bay "+10 gỗ"
├─ assets/
│  ├─ placeholder/       # SVG tạm do Claude vẽ
│  ├─ art/               # art thật, ghi đè dần (cùng tên file)
│  ├─ audio/
│  └─ fonts/
└─ i18n/strings.csv
```

**Nguyên tắc code:**
- **Đặt tên bằng tiếng Anh** cho mọi thứ trong code: biến, hàm, class, signal, tên file, tên node, key dịch thuật. Theo chuẩn GDScript: `snake_case` cho biến, hàm và file; `PascalCase` cho class và node; `UPPER_SNAKE_CASE` cho hằng số và enum. Ví dụ `var hunger: float`, `func assign_job()`, `class_name Villager`, `signal villager_born`. Không dùng tiếng Việt, kể cả không dấu (`doi_bung`, `tho_dan`).
- **Comment viết bằng tiếng Việt, ngắn gọn**, giải thích *vì sao* chứ không lặp lại code làm gì, để mình đọc hiểu và tự sửa được.
- **Chữ hiển thị trong game** chỉ nằm trong `i18n/strings.csv` (xem mục 3.1).
- Script nhỏ, mỗi file một việc.
- Các phần giao tiếp với nhau bằng signal qua `EventBus`.
- Không có "god object".
- Code đọc tài nguyên qua một hàm `ArtLibrary.get_texture("villager/head_01")`: ưu tiên `assets/art/`, không có thì lấy `assets/placeholder/`. Nhờ vậy thay art không phải sửa code.

---

## 5. Thổ dân (phần quan trọng nhất)

### 5.1 Dữ liệu mỗi thổ dân

- **Tên** ngẫu nhiên từ bộ tên của ngôn ngữ đang dùng (`data/names/names_vi.gd`). Tên ngắn, hài, kiểu tiền sử: Ú Ù, Bạp, Tèo Đá, Mít, Lù Khù, Gù, Bô Bô, Nhím, Đá Cuội, Sún…
- **Giới tính** (nam/nữ) và **giai đoạn**: em bé → trẻ con → người lớn.
- **Ngoại hình** ngẫu nhiên: màu da, kiểu tóc, mặt, màu áo lông, phụ kiện (xương cài tóc, lông chim).
- **1–2 tính cách** (trait), mỗi cái dễ đọc và có hiệu ứng thấy được ngay:

| Tính cách | Hiệu ứng |
|---|---|
| Lười | Làm chậm hơn 20%, hay nghỉ giữa chừng (bong bóng 😴) rồi tự làm tiếp |
| Háu ăn | Đói nhanh hơn, ăn thì giải trí tăng gấp đôi |
| Khoẻ như trâu | Kỹ năng Chặt cây/Đập đá/Chiến đấu khởi đầu cao hơn, đánh đau hơn |
| Nhát gan | Thấy cannibal là chạy về lều |
| Mê nhảy | Ở sân nhảy thì giải trí hồi nhanh hơn |
| Lãng mạn | Hay đi tìm bạn đời (mục 10), hay hái hoa tặng người khác |
| Ham chơi | Rảnh là trêu người khác hoặc đuổi bướm (trong vùng dạo chơi nhỏ) |
| Siêng năng | Làm nhanh hơn 15%, giải trí giảm chậm hơn khi làm việc |

- **4 chỉ số** (mục 5.3), **kỹ năng theo từng việc** và **một việc thích** (mục 5.4).
- **Tâm trạng** = trung bình có trọng số của các chỉ số, chỉ để chọn nét mặt cười/mếu (không hiện số).
- **Sức đánh**: dùng cho chiến đấu, tăng nhờ đồ nghề đang giữ (rìu, cuốc, giáo — mục 9.4) và kỹ năng Chiến đấu.
- **Đồ nghề đang giữ**: không có, hoặc đúng một món (rìu / cuốc / giáo). Giữ luôn cho tới khi đổi món khác (mục 9.4).

### 5.2 Hành vi: thổ dân nghe lời (`villager_autonomy = obedient`)

Đây là hành vi của chế độ Normal, đúng như game gốc: **không có lệnh thì không tự kiếm việc**.

- **Rảnh (không có việc):** chỉ dạo chơi trong một vùng **rất nhỏ** quanh "điểm neo" (chỗ đứng lúc hết việc hoặc chỗ người chơi thả họ xuống), bán kính khoảng 2–3 ô (`IDLE_RADIUS_CELLS` trong `balance.gd`). Làm hoạt cảnh tại chỗ (mục 5.5). **Không tự nhận việc, không đi lung tung.**
- **Chỉ tự rời vùng dạo chơi trong 3 trường hợp:**
  1. **Đói < 50** → tự đi tới **Bếp có đồ ăn** (trước khi có Bếp: lửa trại), **vừa đi vừa nghĩ tới đồ ăn** (mây nghĩ đùi thịt). Không tự đi hái quả. Ăn xong quay lại chỗ cũ / việc cũ.
     - **Bếp hết đồ:** người đang rảnh **ngồi bệt nũng nịu** tại chỗ, thỉnh thoảng nghĩ tới đùi thịt, tới khi bếp có đồ thì đứng dậy đi ăn. Người đang làm việc được giao thì **làm tiếp** (có khi chính họ đang kiếm đồ ăn về), chỉ thỉnh thoảng nghĩ tới đồ ăn.
     - **Đói = 0:** ai cũng bỏ việc, ngồi bệt và **giơ tấm biển vẽ đồ ăn** (không còn sức nghĩ nữa).
     - Ván mới có sẵn ít thức ăn ở lửa trại (`START_FOOD`) để người chơi kịp giao người đi kiếm đồ ăn.
  2. **Thể lực < 50%** → tự đi tìm **Lều còn chỗ** để ngủ (không có lều còn chỗ: ngủ đất cạnh lửa trại, hồi chậm hơn). Ngủ đủ thì quay lại việc cũ.
  3. **Muốn tìm bạn đời** (mục 10).
- **Được giao việc:** việc đó thành **việc hiện tại** và **tự lặp lại** (chặt → khuân về kho → chặt tiếp). Hết tài nguyên thì tìm loại tương tự gần nhất trong bán kính hợp lý (`JOB_SEARCH_RADIUS_CELLS`); không có thì dừng, đứng yên tại chỗ, **cắm biển vẽ icon việc đó gạch chéo** ("hết cây rồi"); thiếu đồ nghề thì cắm biển vẽ món đó gạch chéo; không tới được thì nghĩ dấu "?". Luôn có **icon việc đang làm** trên đầu.
- **Bị ngắt quãng** (đói, buồn ngủ, tìm bạn đời, chạy trốn) thì **ghi nhớ việc đang làm** và tự quay lại sau. Không bao giờ bỏ việc âm thầm.
- **Máy trạng thái** dùng enum đơn giản: `IDLE`, `MOVING`, `WORKING`, `CARRYING`, `EATING`, `SLEEPING`, `SOCIAL`, `FLEEING`, `FIGHTING`, `KNOCKED_OUT`, `STRIKING` (đình công). Không dùng plugin.
- Mỗi thổ dân "suy nghĩ" mỗi 0.3–0.6 giây, lệch giờ ngẫu nhiên để không dồn CPU vào cùng một frame. **Thứ tự ưu tiên:**
  1. Nguy hiểm (cannibal ở gần) → chạy trốn hoặc tự vệ.
  2. Máu = 0 → ngất (mục 5.3). Thể lực = 0 → gục ngủ tại chỗ.
  3. Giải trí = 0 → đình công (mục 5.3).
  4. Đói < 50 → đi ăn ở bếp (bếp hết đồ thì ngồi dỗi, xem trên). Thể lực < 50% → đi ngủ. Luôn có bong bóng nghĩ / tấm biển giải thích.
  5. Muốn tìm bạn đời (khi đủ điều kiện mục 10, chỉ lúc rảnh hoặc giữa hai lượt việc).
  6. Việc người chơi giao → làm, xong một lượt thì lặp lại.
  7. Rảnh → dạo chơi trong vùng nhỏ + hoạt cảnh tại chỗ.
- **Đặt chỗ (reservation):** một cái cây, một chỗ trong lều, một suất ăn ở bếp chỉ được một người nhận, tránh 5 người cùng chạy tới một chỗ.
- **Chế độ `autonomous`** (God, sau MVP): thêm bước "tự kiếm việc của làng" (xây công trình dở, khuân đồ về kho, đi hái lượm…) giữa bước 6 và 7, và vùng dạo chơi rộng hơn. Code bộ não đọc `villager_autonomy` để bật/tắt bước này, không viết hai bộ não riêng.

### 5.3 Bốn chỉ số (hiển thị bằng ICON + thanh nhỏ, không dùng chữ)

Hệ nhu cầu viết dạng dữ liệu (`data/needs.gd`: icon, tốc độ tăng/giảm, ngưỡng), chế độ nào bật nhu cầu nào thì khai báo trong `GameModeConfig.enabled_needs`. Mọi chỉ số chạy 0–100.

| Chỉ số | Icon | Luật |
|---|---|---|
| **Máu** | ❤ | Đói = 0 → máu giảm dần. Máu = 0: độ khó **Dễ** chỉ **ngất** (nằm, sao quay quanh đầu), ăn lại thì hồi và tỉnh; độ khó **Thường** thì **chết** (bia mộ nhỏ dễ thương). Bị đánh cũng mất máu (mục 11). Không đói thì hồi chậm. |
| **Đói** | 🍖 | 100 = no căng. Giảm theo thời gian, **nhanh hơn khi làm việc nặng** (chặt, đập đá, xây, săn, rèn, chiến đấu). **< 50** → tự đi ăn ở bếp. Ăn một phần ở bếp (quả hay món chín) là **no căng 100**, cộng chút giải trí (món chín vui hơn) và **chút thể lực** (`EAT_ENERGY`, nhỏ hơn hẳn thể lực mất giữa hai bữa — ăn không thay được ngủ). |
| **Thể lực** | ⚡ | Giảm khi làm việc (đứng chơi gần như không giảm). **< 50%** → tự đi tìm lều còn chỗ để ngủ. **= 0** → gục ngủ tại chỗ cho đến khi hồi 30%, rồi tự đi tìm lều ngủ tiếp. Ngủ trong lều hồi nhanh hơn ngủ đất; lều cấp cao hồi nhanh hơn nữa. Ngủ đủ (gần 100%) thì dậy. |
| **Giải trí** | 🎉 | Giảm khi làm việc với tốc độ bình thường; **làm việc thích thì giảm rất chậm** (làm việc khác không bị phạt thêm gì). Hồi khi rảnh, tán gẫu, ở sân nhảy, ăn món ngon. **= 0 → đình công:** quăng đồ nghề, bong bóng 💢, toast "{tên} đình công!", rồi **giơ biển vẽ việc đang làm gạch chéo** suốt lúc đình công, từ chối việc và chỉ đứng chơi; **hồi ≥ 40% thì tự làm lại** việc cũ. |

- Bảng thông tin và tooltip chỉ dùng **icon + thanh nhỏ** cho 4 chỉ số (có thể đổi màu thanh khi thấp), không ghi chữ "No", "Năng lượng"…
- Khi chỉ số tụt dưới ngưỡng, icon tương ứng nhấp nháy trên đầu thổ dân.

### 5.4 Kỹ năng & việc thích (hiển thị bằng icon)

- **Các kỹ năng**, mỗi loại một icon riêng (`data/skills.gd`): Chặt cây 🪓, Đập đá ⛏, Hái lượm 🧺, Săn 🏹, Câu cá 🎣, Nấu ăn 🍲, Xây 🔨, Rèn ⚒, Chiến đấu 🦴. (Icon vẽ SVG, không dùng emoji font.)
- **Một kỹ năng có thể gồm nhiều việc** (`data/jobs.gd`): Hái lượm = hái quả, nhặt củi, nhặt đá cuội. Làm việc nào cũng luyện kỹ năng đó.
- **Cấp 1–5** cho từng việc, hiện bằng sao nhỏ cạnh icon trong bảng thông tin. Giá trị khởi đầu ngẫu nhiên, thiên theo tính cách (vd Khoẻ như trâu → Chặt cây/Đập đá/Chiến đấu cao hơn).
- **Lên cấp:** làm việc đó đủ lâu (tích kinh nghiệm) thì lên cấp. Cấp cao làm nhanh hơn và/hoặc ra nhiều hơn (con số ở `balance.gd`).
- **Việc thích ❤:** mỗi thổ dân có **đúng một** việc thích (không có việc ghét). Chỉ là **thưởng**, không có phạt: làm việc thích thì **kinh nghiệm lên nhanh hơn** và **giải trí giảm chậm hơn**; làm việc khác thì mọi thứ bình thường. Bảng thông tin đánh dấu tim cạnh icon việc đó.
- Thay cho "việc giỏi nhất" ở bản spec cũ.

### 5.5 Hoạt cảnh rảnh rỗi (linh hồn của game gốc)

Chỉ diễn ra **trong vùng dạo chơi nhỏ** quanh điểm neo. Chọn ngẫu nhiên, có trọng số theo tính cách, mỗi cái kéo dài 3–10 giây:
- **Tán gẫu** với người **đang ở gần**: hai người quay mặt vào nhau, bong bóng nói chứa **1–2 hình ngẫu nhiên** (quả, đá, tim, ngôi sao, dấu ?…) thay cho chữ, kèm tiếng lẩm bẩm.
- **Hái hoa dưới chân**: cúi xuống, đứng lên cầm bông hoa. (Mang hoa đi tặng là hoạt cảnh tìm bạn đời — mục 10.)
- **Gãi mông**: tinh nghịch, nhanh, có hiệu ứng "gãi gãi".
- **Ngồi phơi nắng** hoặc ngáp.
- **Dạo vài bước** quanh chỗ đứng.
- **Đuổi bướm** (Ham chơi) — không chạy ra khỏi vùng nhỏ.
- **Trẻ con chơi đùa** đuổi nhau quanh lều. Em bé bò lổm ngổm quanh lều.
- **Nhảy disco** chỉ khi đang đứng ở sân nhảy (người chơi thả thổ dân vào sân nhảy để "đi chơi" — xem mục 9.3).
- Không còn "ăn vặt khi rảnh": chỉ đi ăn khi Đói < 50.

---

## 6. Hoạt họa & cảm giác "dễ thương"

### 6.1 Khung cutout

- Mỗi thổ dân là một `Node2D` gồm các `Sprite2D` con, thứ tự vẽ từ sau ra trước: (tấm biển), `leg_back`, `arm_back`, `back_item` (đồ nghề đeo sau lưng), `body`, `leg_front`, `head`, `face`, `hair`, `accessory`, `arm_front`, `held_item`, `carry_item` (đồ khuân trên đầu).
- Tỉ lệ **chibi**: đầu chiếm khoảng 45% chiều cao. Cả nhân vật cao khoảng **72 px** ở độ phân giải gốc.
- **Animation chủ yếu tạo bằng code** (tween, sin/cos), không vẽ từng frame:
  - Đi: thân nảy lên xuống, chân và tay đưa qua lại, nghiêng nhẹ theo hướng đi.
  - Đứng yên: thở (thân phồng xẹp 2–3%), **chớp mắt** ngẫu nhiên (đổi texture mặt).
  - Squash & stretch khi dừng lại, nhảy lên, hoặc đặt đồ xuống.
  - Lật ngang (`scale.x = -1`) theo hướng đi.
- **Danh sách animation bắt buộc:** idle, walk, run (khi chạy trốn), chop (vung rìu), mine (gõ búa), gather (cúi hái), carry (hai tay giơ đồ trên đầu: giỏ quả, khúc gỗ, bó củi, xô đá cuội, con cá, **nguyên con thú chổng vó**), fish (quăng cần rồi chờ, dây câu + phao vẽ bằng code, giật nhẹ khi cá cắn), eat, sleep (nằm, có "Zzz"), collapse (gục xuống ngủ khi thể lực = 0), talk, pick_flower, give_flower, scratch, dance, love (tim bay ra), pout (ngồi bệt nũng nịu, đá chân), sign (đứng thì cắm biển xuống đất một tay vịn, ngồi thì hai tay giơ biển lên), strike (quăng đồ nghề, dậm chân, 💢), attack (vung / đâm / ném theo món đang cầm), hurt (giật lùi, nháy trắng), knocked_out (nằm, sao quay quanh đầu), baby_crawl, celebrate (nhảy cẫng lên khi xong việc lớn, lên cấp).

### 6.2 Phản hồi và "juice"

- **Icon trên đầu** cho biết đang làm gì (icon của loại việc, giỏ, xô, bó củi, đĩa thức ăn, Zzz, tim, đồ nghề đang đi lấy).
- **Thổ dân không nói chữ.** Mọi "lời nói" đều là hình (icon SVG, không dùng emoji font), theo 3 kiểu:
  - **Bong bóng nói** (khung tròn, 1–2 icon): cảm xúc tức thời — vui ♪, giận 💢, yêu ❤, sợ ❗, lên cấp (icon kỹ năng), tán gẫu.
  - **Bong bóng nghĩ** (đám mây có chấm tròn dẫn xuống đầu): đang **muốn** gì đó — đùi thịt (đói, đang đi ăn / ngồi dỗi), Zzz (buồn ngủ, nghỉ tay), icon việc (được giao việc lúc đang bận: "lát nữa"), "…" (bảo đi đâu lúc đang bận), "?" (không tới được).
  - **Tấm biển** (vẽ hình, có thể gạch chéo ✕): **cần người chơi ra tay** — đói lả (đùi thịt), bếp chưa có gì để nấu (đùi thịt ✕), hết cây/đá/quả/thú (icon việc ✕), thiếu đồ nghề (rìu/cuốc/giáo ✕), đình công (icon việc ✕, giữ suốt lúc đình công); Đợt 3: thiếu vật liệu xây (đứng trước công trình, gỗ/đá ✕).
    - **Đứng thì cắm biển xuống đất** ngay trước mặt, một tay vịn; **ngồi thì hai tay giơ biển lên**; đang đi thì cất biển. **Không bao giờ để biển lơ lửng trên đầu.**
    - Đang rảnh mà vừa cắm biển thì đứng yên cạnh biển một lúc cho người chơi kịp thấy, không đi dạo mất.
  - Nhận lệnh thì nhún một cái, mặt tươi lên (không bong bóng). Chữ chỉ còn ở bảng thông tin, tooltip và toast.
- **Icon chỉ số nhấp nháy** trên đầu khi một chỉ số dưới ngưỡng.
- **Số bay lên** khi khuân đồ về kho, tính theo tài nguyên chung: "+10 gỗ" (một khúc gỗ), "+3 đá" (xô đá cuội). Sao bay lên khi lên cấp kỹ năng.
- **Đồ riêng của công trình bày ra cho thấy**: bát món chín quanh bếp, rìu/cuốc/giáo dựng cạnh lò rèn — nhìn là biết còn bao nhiêu.
- **Bụi** khi chặt cây, đập đá hoặc dừng chạy.
- **Công trình** mọc lên dần khi xây, nảy "bụp" khi xong hoặc lên cấp, có pháo giấy. Công trình sản xuất thiếu người phụ trách thì hiện **icon cảnh báo** phía trên.
- **Ngày và đêm** (chỉ để **trang trí và tính ngày**; thổ dân đi ngủ theo **Thể lực**, không theo giờ):
  - **Ánh sáng mặt trời đổi liên tục theo giờ**: `CanvasModulate` lấy màu từ một dải màu theo giờ trong ngày (bình minh hồng nhạt → trưa sáng trắng → chiều vàng cam → hoàng hôn đỏ cam → đêm xanh tím), chuyển mượt, không nhảy bậc.
  - **Đổ bóng theo mặt trời**: cây, đá, bụi, công trình, thổ dân, thú đều có bóng trên mặt đất. Hướng và độ dài bóng xoay theo vị trí mặt trời: sáng sớm bóng dài đổ về phía tây, trưa bóng ngắn ngay dưới chân, chiều bóng dài đổ về phía đông; đêm bóng mờ dần. Nhìn bóng là **ước được mấy giờ** (như đồng hồ mặt trời).
  - Bóng làm nhẹ cho Web: dùng chính hình của vật, tô đen bán trong suốt, xiên/kéo bằng transform (hoặc shader nhỏ) theo một "góc mặt trời" chung — không dùng Light2D/Occluder. Bóng của thổ dân đi theo khung cutout.
  - Có thể thêm một **đồng hồ mặt trời nhỏ** cạnh lửa trại hoặc trên HUD (mặt trời/mặt trăng chạy theo cung) để người chơi đọc giờ nhanh.
  - Ban đêm lửa trại sáng (sprite phát sáng cộng màu, không dùng Light2D để Web chạy nhẹ).
- **Camera** di chuyển và zoom mượt, có giới hạn trong map.

### 6.3 Âm thanh

- Giai đoạn MVP: tiếng "lẩm bẩm" tạo bằng code (vài âm ngắn đổi cao độ ngẫu nhiên, mỗi thổ dân một cao độ riêng), cộng hiệu ứng CC0 từ Kenney nếu tải được.
- Tạo bus âm thanh `Master`, `Music`, `SFX`, `Voice` để chỉnh âm lượng riêng.

---

## 7. Hình tạm (placeholder) & quy cách asset

- Claude **tự vẽ toàn bộ hình tạm bằng SVG** trong `assets/placeholder/`. Hình phải dễ thương, không được là ô vuông xám: viền nâu đậm 3 px, màu ấm, bo tròn.
- **Bảng màu gợi ý:** cỏ `#8BC34A`/`#7CB342`, đất `#C8A27A`, nước `#4FC3F7`, gỗ `#8D6E63`, đá `#9E9E9E`, viền `#4E342E`, da thổ dân `#F2C29B`/`#D9A066`/`#A9714B`, áo lông `#A1887F`/`#FFB74D`/`#E57373`.
- Bộ phận thổ dân, mỗi loại vài biến thể để ghép ngẫu nhiên:
  - `villager/head_01..03.svg`
  - `villager/face_01_happy`, `face_01_sad`, `face_01_blink`, `face_01_sleep`, `face_01_surprised` (mỗi bộ mặt đủ 5 biểu cảm)
  - `villager/hair_01..05`
  - `villager/body_01..03` (áo lông)
  - `villager/arm.svg`, `villager/leg.svg`
  - `villager/accessory_01..03`
- Môi trường: cây (2 loại), gốc cây, đá tảng (2 cỡ), **vách đá lớn**, **củi trên đất**, **đá cuội trên đất**, bụi quả (có quả / hết quả), hoa, cỏ trang trí, ô nước, hang đá xuất phát, lửa trại.
- Đồ cầm tay & đồ khuân: giỏ (rỗng / đầy quả), xô (rỗng / đầy đá cuội), cần câu, khúc gỗ, bó củi, tấm biển (mặt để trống). Rìu, cuốc, giáo dùng chung hình với icon kỹ năng.
- Công trình: lều ngủ, bếp, kho, lò rèn, sân nhảy. Mỗi cái **3 cấp**, mỗi cấp có 3 trạng thái: móng (đang xây/nâng cấp), hoàn thành, hư hại. Hình phủ đúng **diện tích** của công trình (mục 9.3).
- Thú: lợn rừng, hươu nhỏ. Kẻ thù: cannibal (mặt nạ xương, sơn chiến), kèm biến thể màu.
- **Không cần vẽ bóng đổ** cho từng vật: game tự tạo bóng theo mặt trời từ chính hình của vật (mục 6.2). Bóng elip nhỏ dưới chân trong hình tạm vẫn giữ làm "bóng tiếp đất".
- Icon:
  - 4 chỉ số: ❤ máu, 🍖 đói, ⚡ thể lực, 🎉 giải trí.
  - Mỗi loại việc/kỹ năng (mục 5.4), sao cấp, tim việc thích.
  - 3 tài nguyên chung (gỗ, đá, thức ăn = đùi thịt), từng món thức ăn (quả, cá, thịt), món chín.
  - Mỗi cảm xúc (gồm 💢), dấu ✕, dấu ?, dấu "…", mây suy nghĩ, cảnh báo thiếu người phụ trách, nút tốc độ, nút nâng cấp.
- **Viết `ASSET_SPEC.md`**: một bảng liệt kê **mọi** file gồm đường dẫn, kích thước khuyến nghị (px), điểm neo hoặc điểm xoay (ví dụ: tay xoay ở vai), và ghi chú. Mục đích là sau này mình vẽ PNG cùng tên, bỏ vào `assets/art/`, và game tự dùng mà không phải sửa code.

---

## 8. Điều khiển: hỗ trợ cả chuột lẫn cảm ứng

`InputRouter` nhận sự kiện thô từ chuột và cảm ứng, rồi phát ra **lệnh chung** để phần còn lại của game không cần biết người chơi dùng gì:

| Lệnh | Chuột | Cảm ứng |
|---|---|---|
| `select` | Click trái | Chạm |
| `command_target` (giao việc, xây, phụ trách công trình, hoặc di chuyển tới chỗ) | Click trái vào mục tiêu khi đang chọn thổ dân | Chạm vào mục tiêu khi đang chọn thổ dân |
| `drag_assign` (kéo thổ dân thả vào cây, công trình…) | Giữ chuột trái kéo từ thổ dân | Giữ ngón tay kéo từ thổ dân |
| `pan` | Kéo chuột ở chỗ trống / phím WASD / chuột giữa | Kéo một ngón ở chỗ trống |
| `zoom` | Lăn chuột | Chụm hai ngón |
| `inspect` (xem thông tin nhanh) | Rê chuột lên | Nhấn giữ 0.4 s |
| `cancel` | Chuột phải / Esc | Nút ✕ trên màn hình |
| Tạm dừng / tốc độ | Space, phím 1–3 | Nút trên HUD |

- Giao thổ dân cho một công trình: chạm/kéo vào **móng** → đi xây; vào **công trình sản xuất** đã xong → làm người phụ trách (đầu bếp, thợ rèn…); vào **sân nhảy** → đi chơi; vào **lều** → đi ngủ. Chạm vào **mặt đất trống** → đi tới đó và đặt điểm neo dạo chơi ở đó.
- Chạm vào một công trình (khi không chọn thổ dân) → bảng công trình: cấp, người phụ trách, nút nâng cấp, đồ đang cất (lò rèn: thêm nút −/+ đặt số rìu/cuốc/giáo muốn rèn).
- **Tự nhận biết** kiểu điều khiển từ sự kiện gần nhất và phát signal `input_mode_changed`. UI dùng signal đó để hiện hoặc ẩn nút ✕, chỉnh cỡ tooltip.
- Phân biệt chạm với kéo bằng ngưỡng khoảng 10 px. Vùng chạm mỗi thổ dân **lớn hơn hình vẽ** (tối thiểu 48×48 px) để dễ chạm trên điện thoại.
- Có setting **"Cỡ giao diện"** (80–150%).
- Không có tính năng nào **chỉ** dùng được bằng rê chuột hoặc chuột phải.

---

## 9. Thế giới, tài nguyên & công trình (phạm vi MVP)

### 9.1 Map

- Map khoảng **48×36 ô**, sinh ngẫu nhiên theo seed nhưng luôn đảm bảo các điểm sau:
  - Hang đá xuất phát và lửa trại ở giữa.
  - Rừng cây ở một phía, bãi đá ở phía khác (có vài **vách đá lớn** 3×2 ô, mỗi vách có sẵn đá tảng sát chân), rải rác bụi quả.
  - Củi nằm sẵn dưới tán cây, đá cuội nằm sẵn quanh đá tảng.
  - Một hồ hoặc suối nhỏ có chỗ câu cá.
  - Đồng cỏ có thú đi lang thang.
  - Một cạnh map là hướng cannibal kéo đến.
- Có chế độ đặt seed cố định để test.

### 9.2 Tài nguyên

**Người chơi chỉ cần biết 3 tài nguyên chung** (thanh tài nguyên trên HUD): **Gỗ**, **Đá**, **Thức ăn** (icon đùi thịt). Bên trong game nhớ thổ dân khuân về **món** gì để vẽ cho đúng; tới kho thì quy ra tài nguyên chung.

| Tài nguyên chung | Món khuân về (hình trên đầu) | Nguồn | Cần đồ nghề? |
|---|---|---|---|
| **Thức ăn** | Giỏ quả | Hái ở bụi (cầm giỏ đi hái). Bụi mọc lại quả sau 1 ngày | Không |
| | Con cá | Câu ở hồ (cầm cần câu, quăng cần, phao nổi) | Không (cần câu không cần rèn) |
| | Nguyên con thú (vác chổng vó trên đầu) | Săn thú | **Giáo** |
| **Gỗ** | Bó củi = 1 gỗ | Củi rơi dần dưới tán cây (ngẫu nhiên, có giới hạn), nhặt tay, đủ một bó mới khuân về | Không |
| | Khúc gỗ = 10 gỗ | Chặt cây. Cây hết khúc thì thành gốc; gốc chỉ mọc lại khi số cây ít hơn lúc đầu (không mọc tràn map) | **Rìu** |
| **Đá** | Xô đá cuội = 1 đá mỗi viên | Đá cuội lăn ra dần quanh đá tảng (ngẫu nhiên, có giới hạn), nhặt tay bỏ vào xô | Không |
| | Đá | Đập đá tảng. Đá tảng lăn ra dần từ **vách đá lớn** (phần của map, không khai thác được), chỉ khi số đá tảng ít hơn lúc đầu | **Cuốc** |

- Thức ăn thô **ăn được luôn** (no căng) — không ai chết đói cạnh kho đầy chỉ vì chưa có đầu bếp. Kho nhớ có bao nhiêu phần là quả/cá/thịt; lấy ra ăn thì cầm đúng món trên tay.
- **Đồ riêng của công trình** (không nằm trên thanh tài nguyên chung):
  - **Món chín** của **Bếp**: đầu bếp lấy thức ăn thô trong kho nấu thành món chín, cất ngay ở bếp, tối đa theo cấp bếp (bày quanh bếp cho thấy còn bao nhiêu). Dân đói đến bếp ăn món chín trước (vui hơn), hết thì ăn thức ăn thô. Trước khi có Bếp, lửa trại là "bếp tạm" (chứa tối đa 4 món chín, nấu chậm).
  - **Rìu, cuốc, giáo** của **Lò rèn** (mục 9.4).
- Gỗ, đá **khuân về Kho** (ban đầu là lửa trại). Thức ăn **khuân về Bếp** (ban đầu là lửa trại). Thanh tài nguyên chỉ tính đồ đã nằm trong kho/bếp.

### 9.3 Công trình MVP

**Quy tắc chung:**
1. Mỗi công trình chiếm **diện tích riêng** trên lưới (2×2, 3×3, 3×4…), không đè lên nhau, không đè lên cây/đá/nước.
2. **Xây:** nhiều công nhân cùng xây một lúc, tối đa **max(1, số ô ÷ 2)** người (2×2 → 2 người, 3×3 → 4 người, 3×4 → 6 người). Thêm người thì xây nhanh hơn; kỹ năng Xây cao thì nhanh hơn. Người xây do người chơi giao (chế độ Normal không có ai tự đi xây).
3. **Mọi công trình có 3 cấp.** Nâng cấp tốn tài nguyên và thời gian xây (giống xây mới, cũng cần công nhân). Trong lúc nâng cấp công trình vẫn hoạt động ở cấp cũ.
4. **Công trình sản xuất** (Bếp → đầu bếp, Lò rèn → thợ rèn, …) phải có **dân phụ trách** mới hoạt động. Số người phụ trách tối đa: cấp 1 = 1, cấp 2 = 2, cấp 3 = 3. Người phụ trách làm việc tại công trình; kỹ năng tương ứng ảnh hưởng tốc độ sản xuất. Không có người phụ trách → công trình ngừng, hiện icon cảnh báo.
5. Lửa trại có sẵn, 1×1, không nâng cấp, không cần người phụ trách để chứa đồ (nhưng muốn nấu ở lửa trại thì phải giao ai đó nấu). Cất được tối đa 4 món chín.
6. **Kho riêng của công trình:** món chín ở bếp, rìu/cuốc/giáo ở lò rèn — không tính vào thanh tài nguyên chung, có sức chứa theo cấp, bày hình ra cho thấy.

| Công trình | Diện tích | Chi phí cấp 1 → 2 → 3 (gợi ý) | Chức năng theo cấp |
|---|---|---|---|
| Lửa trại (có sẵn) | 1×1 | — | Kho + bếp tạm ban đầu, nấu chậm, chứa 4 món chín, chỗ tụ tập buổi tối |
| Lều ngủ | 2×2 | 10 gỗ → 15 gỗ 5 đá → 20 gỗ 15 đá | Chỗ ngủ 2 / 3 / 4. Hồi thể lực ×1.5 / ×2 / ×2.5 so với ngủ đất. Cần lều còn chỗ thì cặp đôi mới có em bé (giới hạn dân số cố định 50) |
| Bếp | 2×2 | 12 gỗ 6 đá → 15 gỗ 10 đá → 20 gỗ 20 đá | Đầu bếp 1 / 2 / 3. Nhận thức ăn thô, nấu thành món chín cất tại bếp (sức chứa tăng theo cấp), dân đói đến đây ăn |
| Kho | 3×3 | 15 gỗ → 20 gỗ 10 đá → 30 gỗ 25 đá | Điểm cất gỗ/đá (đỡ phải đi xa). Sức chứa 100 / 200 / 400 mỗi loại |
| Lò rèn | 3×2 | 10 gỗ 10 đá → 15 gỗ 15 đá → 20 gỗ 25 đá | Thợ rèn 1 / 2 / 3. Rèn rìu, cuốc, giáo theo số lượng người chơi đặt (mục 9.4), cất tại lò |
| Sân nhảy | 3×3 | 8 gỗ 4 đá → 12 gỗ 8 đá → 16 gỗ 12 đá | Nhảy cùng lúc 4 / 6 / 8 người. Hồi giải trí nhanh, cấp cao nhanh hơn |

- Chọn công trình trong menu → hiện **bóng mờ** đúng diện tích đi theo con trỏ hoặc ngón tay (xanh = đặt được, đỏ = không). Chạm lần nữa để đặt, có nút xác nhận hoặc huỷ trên cảm ứng.
- Đặt xong thì thành **móng**. Người chơi giao công nhân → họ **đội mũ công trường**, đi tới kho lấy vật liệu, khuân đổ vào công trường, lặp lại tới khi **đủ vật liệu thì mới bắt đầu xây**. Có thanh tiến độ cho cả phần vật liệu lẫn phần xây. Kho không đủ vật liệu thì thợ xây đứng trước công trình, cắm biển vẽ gỗ/đá gạch chéo.
- Công trình bị cannibal đánh sẽ **hư hại** và mất chức năng cho đến khi được sửa (giao người sửa).
- **Chi phí ở bảng trên là số cũ** (lúc 1 lượt chặt = 3 gỗ). Giờ 1 khúc gỗ = 10 gỗ, mỗi cây 30 gỗ — cân lại chi phí khi làm Đợt 3.
- Thêm sau MVP: phòng tập (gym), bẫy lưới, lều tù trưởng, bãi cát cho trẻ con.

### 9.4 Lò rèn & đồ nghề

- Lò rèn làm **3 món**: **rìu**, **cuốc**, **giáo** (tốn gỗ + đá, con số ở `balance.gd`). Người chơi chạm lò rèn → bảng có 3 món, mỗi món nút **−/+** để đặt **số lượng muốn làm**; thợ rèn làm lần lượt tới đủ.
- Đồ đã rèn **cất tại lò rèn**, hình lò rèn bày đúng số món đang có (vd 2 cái rìu dựng cạnh lò).
- **Không có đồ nghề thì chỉ nhặt bằng tay**: nhặt củi, nhặt đá cuội, hái quả, câu cá. Chạm cây / đá tảng / con thú mà làng chưa có rìu / cuốc / giáo thì thổ dân cắm biển vẽ món đó gạch chéo.
- **Lấy & giữ đồ nghề:** giao việc cần đồ nghề mà lò rèn còn món phù hợp → thổ dân tự tới lấy, rồi **giữ luôn**. Giao việc không cần đồ nghề (nhặt đá cuội…) thì vẫn giữ món cũ, **đeo sau lưng**, cầm xô/giỏ đi làm. Chỉ khi được giao việc cần món **khác** (đang cầm giáo mà được giao chặt cây) mới về lò rèn **đổi** món.
- Công dụng:

| Món | Làm việc | Chiến đấu (Đợt 5) |
|---|---|---|
| Rìu | Chặt cây ra khúc gỗ (10 gỗ) | Cận chiến, sát thương lớn, **không xuyên giáp** |
| Cuốc | Đập đá tảng | Cận chiến, sát thương vừa, **xuyên giáp** |
| Giáo | Săn thú (bắt buộc) | **Ném** khi địch ở xa, **đâm** khi ở gần |

- Cần câu, giỏ, xô **không cần rèn** — ai cũng có.
- Đồ nghề không hỏng (có thể thêm độ bền sau MVP).
- Chưa có lò rèn (làm ở Đợt 3): bản debug bấm **F10** để thêm 1 rìu, 1 cuốc, 1 giáo vào lửa trại thử.

---

## 10. Dân số, tìm bạn đời & em bé

- Bắt đầu với **4 thổ dân** người lớn (2 nam, 2 nữ), cùng chui ra từ hang theo hoạt cảnh: lần lượt ló đầu ra, dụi mắt, vươn vai.
- **Giới hạn dân số: 50** (cố định, `MAX_POPULATION`). Lều không quyết định giới hạn, nhưng muốn có em bé thì phải có lều còn chỗ.
- **Điều kiện tìm bạn đời:** người lớn; giải trí cao (> 70, `MATE_MIN_FUN`); chưa có đôi hoặc đã có đôi; có lều còn chỗ; dân số chưa chạm 50.
- **Tỉ lệ thấp:** đủ điều kiện chưa chắc đã đi hẹn hò. Mỗi lần kiểm tra (khoảng mỗi 30 giây game khi đang rảnh, `MATE_CHECK_SECONDS`) chỉ có **~10%** (`MATE_CHANCE`) đi tìm bạn đời. Người Lãng mạn có tỉ lệ cao hơn (×2).
- **Hoạt cảnh:** tự đi hái một bông hoa → mang tặng một người khác giới cũng đủ điều kiện (ưu tiên bạn đời nếu đã có đôi) → tim bay ra → cùng đi vào lều → lều rung nhẹ, tim bay lên (dễ thương, không có gì nhạy cảm) → ra là **có em bé ngay sau buổi hẹn hò**. Toast thông báo tên em bé. Lần đầu thì hai người thành **cặp đôi** cố định, có biểu tượng tim nhỏ khi đứng gần nhau. Không có thời gian chờ giữa hai lần có con — tỉ lệ 10% đã đủ giữ nhịp.
- Đây là một trong 3 lý do thổ dân tự rời chỗ (mục 5.2); xong thì quay lại chỗ/việc cũ.
- **Em bé → trẻ con → người lớn** theo thời gian trong game (`balance.gd`). Trẻ con không làm việc, chỉ chơi quanh lều.
- Đây là **phần thưởng cho việc chăm dân tốt**: dân vui thì làng đông. Phải làm cho người chơi cảm nhận rõ điều này.

---

## 11. Mối đe doạ & chiến đấu

- **Đói**: Đói = 0 thì mất máu dần. Icon 🍖 nhấp nháy, toast cảnh báo "Làng sắp hết đồ ăn!".
- **Máu = 0** (vì đói hoặc bị đánh):
  - **Dễ** (mặc định): chỉ **ngất** (nằm, sao quay quanh đầu). Ăn lại / được cứu thì hồi và tỉnh. **Không ai chết.** Cannibal yếu hơn.
  - **Thường**: chết (đói), hoặc ngất quá lâu mà không ai cứu thì mất vĩnh viễn (đánh nhau). Hiện một bia mộ nhỏ dễ thương.
- **Cannibal tấn công theo đợt**:
  - Đợt đầu vào khoảng **ngày 5**, sau đó cứ vài ngày một đợt, mỗi đợt mạnh dần.
  - Trước khi tấn công: tiếng tù và, toast cảnh báo, mũi tên ở rìa màn hình chỉ hướng kẻ địch đến (khoảng 20 giây để chuẩn bị).
  - Cannibal nhắm vào công trình và dân gần nhất.
  - Dân đang giữ rìu / cuốc / giáo **tự vệ** khi địch tới gần (đây là "nguy hiểm", ưu tiên 1, không phải tự kiếm việc). Người chơi chọn một nhóm dân rồi chạm vào một chỗ để **dàn quân** ở đó.
  - Đánh nhau tự động theo món đang giữ (mục 9.4): rìu đánh đau nhưng không xuyên giáp, cuốc xuyên giáp, giáo ném từ xa rồi đâm khi tới gần. Sát thương dựa vào món, sức đánh và kỹ năng Chiến đấu. Tay không thì chỉ đẩy nhau.
  - Cannibal hết máu thì bỏ chạy, vừa chạy vừa lăn lộn cho hài.
- **Độ khó** chọn khi bắt đầu game: Dễ (mặc định) hoặc Thường (xem trên).
- Thêm sau MVP: bệnh tật và pháp sư đối phương, hổ răng kiếm, bẫy lưới, phòng tập tăng chỉ số, phản công vào làng địch.

---

## 12. Các đợt làm việc

Mỗi đợt kết thúc bằng một bản **chơi được**, và có tiêu chí "xong" rõ ràng.

### Đợt 0 — Dựng khung
- Cài đặt `project.godot`: tên game `Tribe Vibes`, renderer Compatibility, 1280×720, stretch, các autoload, input map, i18n CSV (có sẵn key `GAME_TITLE`: vi = `Bộ Lạc Chill`, en = `Tribe Vibes`), font.
- Tạo cấu trúc thư mục, `EventBus`, `GameState`, `InputRouter`, `ArtLibrary`, `Loc`. Khung đa ngôn ngữ chạy được đầy đủ theo mục 3.1. Thêm tạm một phím debug (F9) để đổi qua lại vi/en, kiểm tra UI không vỡ khi cột `en` còn trống (phải hiện tiếng Việt thay thế).
- Sinh map dạng lưới có cỏ, nước, cây, đá, bụi quả, hang, lửa trại (hình tạm SVG).
- Camera di chuyển và zoom được bằng cả chuột lẫn cảm ứng.
- Tạo `ASSET_SPEC.md`, `DEVLOG.md`.
- **Xong khi:** bấm F5 thấy một map dễ thương, kéo và zoom mượt, không có lỗi trong Output.

### Đợt 1 — Thổ dân sống động
- Khung cutout, ghép ngoại hình ngẫu nhiên, animation theo code (idle, walk, chớp mắt, hướng nhìn).
- 6 thổ dân chui ra từ hang. Có tên, tính cách, các thanh nhu cầu. *(Thiết kế mới: 4 thổ dân — đổi ở Đợt 1.5.)*
- Tìm đường bằng `AStarGrid2D`, có đặt chỗ.
- Hoạt cảnh rảnh rỗi: tán gẫu, hái hoa, gãi, ngồi, ăn quả.
- Tự đi hái quả mọng và ăn khi đói. Ngủ ngoài trời cạnh lửa trại khi mệt.
- Chạm vào thổ dân → bảng thông tin (chân dung, tên, tính cách, thanh nhu cầu, việc đang làm).
- **Xong khi:** ngồi xem 5 phút thấy làng "sống", mỗi người một kiểu, không ai chết đói khi còn quả.
- *(Đã làm xong. Hành vi "đi lang thang khắp làng" và "ăn vặt khi rảnh" được thay ở Đợt 1.5 theo thiết kế mới.)*

### Đợt 1.5 — Tái cấu trúc đa chế độ + hành vi "nghe lời"
> Đợt chèn thêm vì Đợt 0–1 được làm trước khi có mục 3.2 và trước khi chốt thiết kế 2026-10-02.

**Phần tái cấu trúc (đã xong):** `VillagerData` (Resource, ID mảnh), `VillagerStatus`, `spawn_villager(data, cell)`, `GameModeConfig` + `normal_mode.tres`, autoload `Commands`, `NormalController`, `ui/common/` + `ui/normal/`.

**Phần áp dụng thiết kế mới (chỉ những gì đã có ở Đợt 0–1):**
- Mục 5.2: bỏ đi lang thang xa → dạo chơi trong vùng nhỏ quanh điểm neo; chỉ tự rời chỗ khi đói/mệt. Chưa có Bếp và Lều nên: đói thì hái/ăn quả hoặc lấy đồ ăn ở lửa trại, mệt thì ngủ cạnh lửa trại; viết sẵn chỗ để Đợt 3 đổi sang Bếp/Lều mà không phải viết lại.
- Mục 5.3: đủ 4 chỉ số máu/đói/thể lực/giải trí theo luật mới, hệ nhu cầu dạng dữ liệu bật/tắt theo `GameModeConfig.enabled_needs`, bảng thông tin dùng icon + thanh nhỏ thay chữ. (Đình công và gục ngủ có thể chưa thấy vì chưa có việc làm, nhưng luật đã viết sẵn.)
- Mục 5.4 (một phần): kỹ năng (cấp theo từng việc) và việc thích trong `VillagerData`, hiển thị icon trên bảng thông tin. Logic lên cấp để Đợt 2.
- Cờ `villager_autonomy` (và `enabled_needs`) trong `GameModeConfig`.
- Khởi đầu với 4 thổ dân (2 nam, 2 nữ) thay vì 6.
- **Xong khi:** bấm F5, thổ dân chui ra khỏi hang rồi chỉ lảng vảng quanh lửa trại làm trò, tự đi ăn khi đói < 50, tự đi ngủ khi thể lực < 50%; bảng thông tin hiện 4 chỉ số và kỹ năng bằng icon; không có lỗi trong Output; code tuân thủ đủ 5 quy tắc của mục 3.2.

### Đợt 2 — Lao động & tài nguyên
- Giao việc bằng chạm (chọn người rồi chạm mục tiêu) và bằng **kéo-thả** thổ dân vào mục tiêu. Toàn bộ logic diễn giải nằm trong `NormalController`, việc giao việc thực sự đi qua `Commands.assign_job()` (mục 3.2). Chạm mặt đất trống → đi tới đó, đặt điểm neo mới.
- Các việc: chặt cây, đập đá, hái quả, săn thú, câu cá, khuân về kho, nấu ở lửa trại.
- Việc tự lặp lại; hết tài nguyên thì tìm cái tương tự gần nhất, không có thì dừng + giơ biển "hết cây" (cây gạch chéo). Bị ngắt quãng thì nhớ việc và tự quay lại.
- Kỹ năng: tích kinh nghiệm, lên cấp (sao bay lên), cấp ảnh hưởng tốc độ/sản lượng; việc thích lên cấp nhanh hơn.
- Chỉ số gắn với việc: việc nặng làm đói nhanh hơn, làm việc giảm thể lực và giải trí (việc không thích giảm giải trí nhanh hơn); thể lực = 0 thì gục; giải trí = 0 thì đình công.
- Icon việc trên đầu, đường chấm chấm tới mục tiêu, số bay "+3 gỗ", HUD tài nguyên.
- Nút tốc độ: tạm dừng, ×1, ×2, ×3.
- **Xong khi:** giao 3 người chặt gỗ và 2 người đập đá, số trong kho tăng đều, không ai đứng đơ; người không được giao vẫn đứng chơi quanh chỗ cũ.

### Đợt 2.1 — Thổ dân "nói" bằng hình + luật ăn mới (đã xong)
- Bỏ hết chữ trên đầu thổ dân: bong bóng nói (icon), mây nghĩ, tấm biển (mục 6.2). Tán gẫu bằng hình.
- Đói < 50 chỉ đi ăn ở bếp; bếp hết đồ thì ngồi bệt nũng nịu, đói lả thì giơ biển (mục 5.2). Ăn ở bếp no căng, cộng chút vui và thể lực.
- Tooltip nền sáng dễ đọc.

### Đợt 2.2 — Gộp tài nguyên, đồ nghề, củi & đá cuội (đã xong)
- 3 tài nguyên chung gỗ/đá/thức ăn, bên trong nhớ món để vẽ đúng (mục 9.2). Món chín là đồ riêng của bếp.
- Đồ cầm tay đúng việc: giỏ, xô, cần câu (quăng cần, dây + phao), giáo; vác nguyên con thú về.
- Rìu/cuốc/giáo bắt buộc cho chặt cây/đập đá tảng/săn; thổ dân tự lấy, giữ, đeo sau lưng, đổi khi cần (mục 9.4). Chưa có lò rèn nên dùng F10 để thử.
- Nhặt củi, nhặt đá cuội bằng tay theo mẻ; củi, đá cuội, đá tảng (từ vách đá), cây tự hồi lại có giới hạn.
- Tấm biển cắm đất khi đứng, giơ tay khi ngồi.

### Đợt 3 — Xây dựng, nâng cấp & ngày đêm
- Menu xây, bóng mờ đúng **diện tích** khi đặt, móng, giao công nhân (nhiều người, tối đa theo diện tích): thợ xây **đội mũ công trường**, khuân vật liệu từ kho đổ vào công trường tới đủ rồi mới xây; thanh tiến độ, hiệu ứng hoàn thành.
- **Lò rèn**: bảng đặt số lượng rìu/cuốc/giáo, thợ rèn làm lần lượt, đồ bày quanh lò; bỏ F10 khỏi bản chơi.
- Năm công trình MVP, mỗi cái **3 cấp** + nâng cấp; bảng công trình (cấp, người phụ trách, nút nâng cấp).
- Lều: chỗ ngủ và tốc độ hồi thể lực theo cấp; thổ dân mệt tự tìm lều còn chỗ. Bếp: đầu bếp nấu, dân đói tự đến bếp ăn. Công trình sản xuất cần người phụ trách, thiếu thì ngừng + icon cảnh báo.
- Đổi chỗ "ngủ cạnh lửa trại / ăn ở lửa trại" của Đợt 1.5 sang Lều / Bếp.
- Chu kỳ ngày đêm (trang trí + đếm ngày): ánh sáng mặt trời đổi liên tục theo giờ, mọi vật và thổ dân đổ bóng theo hướng mặt trời để ước được giờ (mục 6.2), có thể thêm đồng hồ mặt trời nhỏ.
- Tự lưu mỗi ngày, có lưu và tải thủ công.
- Cân lại chi phí công trình theo đơn vị gỗ mới (1 khúc = 10 gỗ).
- **Xong khi:** xây và nâng cấp được cả năm công trình, có đầu bếp thì bếp nấu ra món chín và dân đói tự đến ăn, dân mệt tự vào lều ngủ, rèn được rìu rồi giao chặt cây được.

### Đợt 4 — Tìm bạn đời & dân số
- Hoạt cảnh tìm bạn đời (tỉ lệ ~10% mỗi lần kiểm tra; hái hoa → tặng → vào lều → có em bé ngay), cặp đôi, em bé, lớn lên, giới hạn dân số 50 (mục 10).
- Toast thông báo và một **nhật ký làng** ngắn ("Ngày 3: Bạp và Mít thành đôi").
- Sân nhảy hoạt động: thả thổ dân vào để đi chơi, có hoạt cảnh disco, hồi giải trí.
- **Xong khi:** chơi khoảng 15 phút với dân vui vẻ thì có ít nhất 2 em bé chào đời và lớn lên.

### Đợt 5 — Cannibal & chiến đấu
- Rìu / cuốc / giáo dùng làm vũ khí theo mục 9.4 (ném giáo, xuyên giáp…).
- Đợt tấn công: cảnh báo, kẻ địch kéo đến, phá nhà, tự vệ, dàn quân, ngất/chết theo độ khó, sửa nhà.
- Chọn độ khó Dễ hoặc Thường.
- **Xong khi:** sống sót qua 2 đợt tấn công ở độ khó Dễ. Nhà bị phá sửa được. Không crash.

### Đợt 6 — Đánh bóng & gửi đi
- **Nhiệm vụ ngắn** kiểu game gốc, hiện thành thẻ: "Dựng 2 lều", "Có 10 người", "Nấu 5 món chín", "Nâng lều lên cấp 2", "Sống sót đợt tấn công đầu tiên"…, có phần thưởng nhỏ.
- Màn hình bắt đầu ("Chạm để bắt đầu", vì trình duyệt chặn âm thanh trước lần chạm đầu tiên), chọn độ khó, hướng dẫn nhẹ dạng mũi tên chỉ ở vài bước đầu (nhất là "chạm thổ dân rồi chạm cây để giao việc", vì thổ dân không tự làm).
- Setting: âm lượng từng bus, cỡ giao diện, ngôn ngữ.
- Âm thanh, hiệu ứng, cân bằng lại các con số.
- Cấu hình preset xuất Web (tắt Thread Support), tự kiểm tra cỡ file và tốc độ tải.
- **Xong khi:** gửi link Web cho người chơi thật, họ tự hiểu cách chơi trong 2 phút đầu và muốn chơi tiếp.

---

## 13. Con số khởi điểm (đặt trong `data/balance.gd`)

| Thông số | Giá trị đầu |
|---|---|
| Một ngày trong game | 4 phút thật (ngày 3 phút, đêm 1 phút) |
| Tốc độ đi | 90 px/giây (×1.3 khi chạy trốn) |
| Bán kính dạo chơi khi rảnh | 2–3 ô quanh điểm neo (`IDLE_RADIUS_CELLS`) |
| Bán kính tìm tài nguyên tương tự khi hết | khoảng 8 ô quanh chỗ làm cũ (`JOB_SEARCH_RADIUS_CELLS`) |
| Đói giảm | 100 → 0 trong khoảng 1.5 ngày khi rảnh; ×1.5 khi làm việc nặng |
| Ngưỡng tự đi ăn | Đói < 50 |
| Ăn ở bếp | No căng 100; +6 giải trí (món chín +10 nữa); +10 thể lực (`EAT_ENERGY`) |
| Đồ ăn có sẵn khi bắt đầu | 8 thức ăn (quả) ở lửa trại (`START_FOOD`) |
| Món chín ở lửa trại | Tối đa 4 (`CAMPFIRE_MEAL_CAPACITY`) |
| Thể lực giảm khi làm việc | 100 → 0 trong khoảng 1 ngày làm liên tục; rảnh gần như không giảm |
| Ngưỡng tự đi ngủ | Thể lực < 50% |
| Gục ngủ tại chỗ | Thể lực = 0, ngủ đến 30% rồi tự đi tìm lều |
| Thể lực hồi khi ngủ đất | 100 trong khoảng 60 giây; lều ×1.5 / ×2 / ×2.5 theo cấp |
| Giải trí giảm khi làm việc | 100 → 0 trong khoảng 1 ngày làm liên tục; việc thích ×0.25 (việc khác bình thường, không phạt) |
| Đình công | Giải trí = 0; tự làm lại khi hồi ≥ 40 |
| Máu giảm khi Đói = 0 | 100 → 0 trong khoảng 0.5 ngày |
| Cấp kỹ năng | 1–5; mỗi cấp nhanh hơn ~10%; kinh nghiệm cần tăng dần; việc thích nhận kinh nghiệm ×2 (việc khác ×1) |
| Chặt cây (cần rìu) | 10 giây → 1 khúc gỗ = 10 gỗ; mỗi cây 3 khúc |
| Nhặt củi (tay) | 1.5 giây mỗi bó (1 gỗ), đủ 3 bó mới khuân về; củi dưới tán cây tối đa 20 bó, rơi thêm ~10 giây một bó |
| Đập đá tảng (cần cuốc) | 8 giây → 4 đá; mỗi tảng 4 lượt |
| Nhặt đá cuội (tay) | 1.5 giây mỗi viên (1 đá), đủ 3 viên mới khuân về; tối đa 14 viên, lăn thêm ~14 giây một viên |
| Đá tảng mới / cây mọc lại | Đá tảng lăn ra từ vách ~90 giây một lần, cây mọc lại từ gốc ~45 giây một lần — chỉ khi ít hơn số lúc đầu |
| Săn (cần giáo) | Vác nguyên con về = 4 thức ăn |
| Hái 1 bụi quả | 3 giây → 2 thức ăn. Mọc lại sau 1 ngày |
| Nấu 1 món | 5 giây ở bếp (chia theo số đầu bếp + kỹ năng), 10 giây ở lửa trại |
| Thợ xây tối đa | max(1, số ô ÷ 2) |
| Người phụ trách tối đa | cấp 1 = 1, cấp 2 = 2, cấp 3 = 3 |
| Dân số | Khởi đầu 4 (2 nam, 2 nữ); tối đa 50 |
| Tìm bạn đời | Giải trí > 70; kiểm tra mỗi ~30 giây khi rảnh, tỉ lệ 10% (Lãng mạn ×2); có em bé ngay sau hẹn hò, không thời gian chờ |
| Ngày đêm & bóng | Dải màu ánh sáng theo giờ; bóng dài nhất lúc bình minh/hoàng hôn (~3× chiều cao vật), ngắn nhất lúc trưa (~0.3×), mờ dần về đêm |
| Em bé → trẻ con → người lớn | 1 ngày → 2 ngày |
| Đợt cannibal đầu tiên | Ngày 5, 3 kẻ địch, mỗi đợt sau thêm 1–2 |
| Thời gian cảnh báo trước khi tấn công | 20 giây |

Đây chỉ là điểm xuất phát. Sau mỗi đợt, đề xuất chỉnh lại dựa trên cảm giác chơi.

---

## 14. Ngoài phạm vi MVP (chưa làm)

Bệnh tật và pháp sư, hổ răng kiếm, phòng tập và hệ thống chỉ số chi tiết, bẫy lưới, khám phá vùng mới, chiến dịch nhiều màn, mùa đông, quan hệ bạn bè và thù ghét, trang trí làng, bản Android, tiếng Anh đầy đủ, nhạc nền riêng, việc ghét.

Kiến trúc nên **chừa chỗ** cho các tính năng này (dữ liệu tách riêng, công trình cấu hình bằng data, sự kiện qua `EventBus`), nhưng không viết trước.

### Sau MVP: Chế độ Thần Linh (God mode)

Chưa làm, chỉ ghi lại để định hướng. Kiến trúc ở mục 3.2 là để chuẩn bị cho phần này.

- **Phép thần trong chế độ Normal** (làm trước, có thanh năng lượng hồi dần):
  - Mưa: bụi quả mọc lại ngay.
  - Thả đùi gà từ trên trời xuống (hồi Đói).
  - Sét đánh cannibal: ngất kiểu hài, không chết.
  - Mũi tên tình yêu: bắn vào hai thổ dân là họ thành đôi (bỏ qua bước hái hoa).
  - Cù lét: thổ dân lăn ra cười, tăng giải trí (gỡ đình công).
- **Chế độ Thần Linh riêng**:
  - `god_mode.tres` (`villager_autonomy = autonomous`), `GodController`, `ui/god/`.
  - Thổ dân **tự lập**: tự kiếm việc kiểu RimWorld (xây công trình dở, khuân đồ, hái lượm…), dạo chơi rộng hơn.
  - Không giao việc trực tiếp, không nhiệm vụ, không thua. Có thể tắt bớt nhu cầu qua `enabled_needs`.
  - Phép thần không giới hạn, có thêm các phép như tự thả cannibal hay thú hoang vào map.
- **Trình tạo nhân vật**:
  - Chọn tóc, mặt, áo, màu da, phụ kiện bằng nút ◀ ▶; đặt tên, chọn giới tính, tính cách, việc thích, chỉnh kỹ năng khởi đầu; có nút 🎲 ngẫu nhiên.
  - Xem trước nhân vật đang nhún nhảy (dùng lại `villager_rig`), rồi thả xuống map qua `spawn_villager()`.
  - Mở rộng sau: bảng màu tự do, lưu mẫu nhân vật, tạo sẵn gia đình.
  - Muốn trình tạo nhân vật vui thì cần **nhiều mảnh art** (khoảng 8–10 kiểu tóc, 6 mặt, 6 áo…).
