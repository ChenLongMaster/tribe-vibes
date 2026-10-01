# MVP_PROMPT — Tribe Vibes (Bộ Lạc Chill)

> **Tên game: Tribe Vibes** (tiếng Việt: **Bộ Lạc Chill**). Tên chỉ được khai báo ở **hai chỗ**: `application/config/name = "Tribe Vibes"` trong `project.godot`, và key dịch `GAME_TITLE` trong `i18n/strings.csv` (cột `vi` = `Bộ Lạc Chill`, cột `en` = `Tribe Vibes`). Không viết cứng tên game ở bất kỳ chỗ nào khác (màn hình bắt đầu, tiêu đề cửa sổ, tên file save…), để sau này đổi tên hay thêm phụ đề chỉ cần sửa hai chỗ đó.

> File này hướng dẫn Claude dựng project Godot và xây bản MVP chơi được của một game colony-sim tiền sử, lấy cảm hứng từ **Prehistoric Tribes** (Gear Games / THQ Wireless, 2008).
> Đặt file ở thư mục gốc project. Có thể copy thành `CLAUDE.md` để Claude Code tự đọc mỗi phiên.

---

## 0. Cách làm việc (đọc trước)

- Làm **từng đợt** theo mục 12. Xong một đợt thì **dừng lại**, báo cáo, chờ mình chạy thử và đồng ý rồi mới làm đợt tiếp.
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
- Vì vậy mục tiêu là một colony-sim kiểu **"RimWorld rất nhẹ"**: thổ dân có tên, cá tính, tự sống và làm trò ngộ nghĩnh, còn người chơi chỉ cần chạm để giao việc và xây nhà.
- Bám sát cơ chế và tinh thần của Prehistoric Tribes, nhưng **không dùng tên, hình, âm thanh hay logo gốc**. Chỉ lấy cảm hứng từ cơ chế.
- Tông game: **hài hước, ấm áp, tinh nghịch**. Thổ dân hơi ngố nhưng đáng yêu, không bạo lực máu me. Bị đánh thì ngất, hiện sao bay quanh đầu.

---

## 2. Game gốc — những gì cần bám theo

Các chi tiết dưới đây đã được xác minh qua trang chính thức của Gear Games và bài review của Pocket Gamer (2008).

**Cốt truyện mở đầu:** kỷ băng hà kết thúc, cả bộ lạc chui ra khỏi hang và bắt đầu dựng làng. Game có tối đa khoảng **50 thổ dân**.

**Thổ dân "có đầu óc riêng":** lúc rảnh họ luôn bận làm gì đó, như nói chuyện với nhau, ăn trưa, hái hoa, gãi mông, đi disco. Người chơi giữ cho họ no, ấm, an toàn, và giao các việc như thu hoạch, săn bắn, câu cá, nấu ăn.

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

**Cách sửa:** luôn có **phản hồi rõ ràng**: icon việc đang làm trên đầu, đường đi chấm chấm tới nơi được giao, bong bóng giải thích khi bỏ việc ("đói quá!", "buồn ngủ..."). Họ có thể lười một chút cho đáng yêu, nhưng **luôn tự quay lại làm tiếp** và người chơi luôn thấy được vì sao.

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

1. **Không viết chữ cứng trong code hay scene.** Mọi chữ người chơi nhìn thấy đều là key, ví dụ `UI_BUILD`, `TOAST_BABY_BORN`, `TRAIT_LAZY_NAME`, `TRAIT_LAZY_DESC`. Đặt key theo tiền tố nhóm: `UI_`, `TOAST_`, `TRAIT_`, `JOB_`, `BUILDING_`, `RES_`, `GOAL_`, `LOG_`, `BUBBLE_`.
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
- **Normal (Bộ Lạc)**: kiểu RTS/colony. Điều khiển từng thổ dân, giao việc, xây dựng, có nhiệm vụ, có thể thua.
- **God (Thần Linh)**: kiểu sandbox, giống WorldBox. Không điều khiển trực tiếp, chỉ dùng phép thần, tự tạo và thả nhân vật, không có nhiệm vụ, không thua.

MVP **chỉ làm chế độ Normal**, nhưng code phải chia đúng 3 tầng để sau này cắm chế độ God vào mà không phải viết lại:

```
UI / HUD            → mỗi chế độ một scene riêng (NormalHUD; sau này GodHUD)
Player Controller   → diễn giải lệnh từ InputRouter (NormalController; sau này GodController)
Simulation Core     → world, villager, AI, nhu cầu, tài nguyên, công trình, kẻ thù, ngày đêm, lưu game
                      KHÔNG biết đang ở chế độ nào
```

**Quy tắc bắt buộc:**
1. **Code của core không gọi thẳng vào UI.** Muốn báo gì thì phát signal qua `EventBus`.
2. **Mọi hành động của người chơi đi qua một API chung của core** (gợi ý: autoload `Commands` hoặc class `WorldAPI`), ví dụ `assign_job(villager_id, target)`, `place_building(type, cell)`, `spawn_villager(data, cell)`, `apply_effect(effect_id, cell)`. UI và controller không sửa thẳng dữ liệu của thổ dân.
3. **Cùng một lệnh từ `InputRouter`, mỗi controller hiểu một kiểu.** Ví dụ chạm vào cây: `NormalController` giao việc chặt cây, sau này `GodController` thả phép đang chọn vào chỗ đó.
4. **Luật chơi đọc từ `GameModeConfig`** (một `Resource`), không viết cứng `if` rải rác. Ít nhất có các cờ: `allow_direct_commands`, `goals_enabled`, `raids_auto`, `can_lose`, `god_powers_enabled`, `god_powers_unlimited`, `character_creator_enabled`. MVP chỉ có một file `normal_mode.tres`.
5. **Màn hình bắt đầu nạp chế độ** bằng cách chọn `GameModeConfig`, rồi nạp controller và HUD tương ứng. MVP chỉ có nút Normal, nhưng luồng nạp phải đi qua cơ chế này.

**Dữ liệu nhân vật tách riêng (`VillagerData`):**
- Một `Resource` chứa toàn bộ thông tin để tạo một thổ dân: `appearance` (ID từng mảnh như `hair_03`, `face_02`, cùng màu da, màu áo), `display_name`, `gender`, `traits`, `best_job`, `age_stage`.
- Ngoại hình lưu bằng **ID mảnh**, không lưu đường dẫn ảnh, để thay art thật vẫn hiển thị đúng.
- Hàm sinh ngẫu nhiên chỉ **tạo ra một `VillagerData`**. Core chỉ có một cách tạo thổ dân: `spawn_villager(data, cell)`. Sau này trình tạo nhân vật của God mode cũng chỉ việc tạo ra một `VillagerData` rồi gọi cùng hàm đó.
- Lưu game lưu `VillagerData` cộng trạng thái hiện tại (nhu cầu, vị trí, việc đang làm).

---

## 4. Cấu trúc project

```
res://
├─ project.godot
├─ MVP_PROMPT.md / CLAUDE.md / DEVLOG.md / ASSET_SPEC.md
├─ autoload/
│  ├─ game_state.gd      # tài nguyên, dân số, ngày giờ, tốc độ game, độ khó
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
│  ├─ buildings.gd       # định nghĩa công trình (chi phí, kích thước, chức năng)
│  ├─ traits.gd          # định nghĩa tính cách
│  └─ names/
│     ├─ names_vi.gd     # bộ tên thổ dân tiếng Việt
│     └─ names_en.gd     # để trống / vài tên mẫu
├─ world/
│  ├─ world.tscn/.gd     # map, sinh địa hình, quản lý lưới + AStarGrid2D
│  ├─ resource_node.tscn # cây, đá, bụi quả, chỗ câu cá
│  └─ animal.tscn        # thú để săn
├─ villager/
│  ├─ villager_data.gd   # Resource: ngoại hình (ID mảnh), tên, giới tính, tính cách… (xem mục 3.2)
│  ├─ villager.tscn/.gd  # dữ liệu + máy trạng thái
│  ├─ villager_rig.tscn/.gd   # bộ khung cutout + animation theo code
│  └─ villager_brain.gd  # chọn việc (utility AI đơn giản)
├─ buildings/
│  └─ building.tscn/.gd  # một scene chung, cấu hình theo data
├─ enemies/
│  └─ cannibal.tscn/.gd
├─ ui/
│  ├─ common/            # dùng chung mọi chế độ
│  │  ├─ toast.tscn      # thông báo nổi ("Bé Tí chào đời!")
│  │  └─ villager_panel.tscn
│  └─ normal/            # HUD riêng của chế độ Normal (sau này thêm ui/god/)
│     ├─ hud.tscn        # thanh tài nguyên, ngày, nút tốc độ
│     ├─ build_menu.tscn
│     └─ goals_panel.tscn
├─ fx/                   # bụi, tim, sao, số bay "+3 gỗ"
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
| Háu ăn | Đói nhanh hơn, ăn thì vui gấp đôi |
| Khoẻ như trâu | Chặt cây/đập đá nhanh hơn, đánh đau hơn |
| Nhát gan | Thấy cannibal là chạy về lều |
| Mê nhảy | Rảnh là ra sân nhảy, ở đó vui nhanh hơn |
| Lãng mạn | Dễ yêu, hay hái hoa tặng người khác |
| Ham chơi | Rảnh là trêu người khác hoặc đuổi bướm |
| Siêng năng | Làm nhanh hơn 15%, ít nghỉ |

- **Nhu cầu** (0–100):
  - **No**: giảm dần theo thời gian; về 0 thì mất máu.
  - **Năng lượng**: giảm khi làm việc, hồi khi ngủ.
  - **Vui**: tăng khi chơi, nhảy, tán gẫu, được ăn ngon; giảm khi đói, mệt, làm việc lâu.
- **Tâm trạng** = trung bình có trọng số của ba nhu cầu, hiển thị bằng mặt cười/mếu.
- **Việc giỏi nhất**: chọn ngẫu nhiên, làm việc đó nhanh hơn 25%. Hiện ngôi sao cạnh tên việc trong bảng thông tin.
- **Máu** và **sức đánh**: dùng cho chiến đấu, tăng nhờ vũ khí.

### 5.2 Hành vi (máy trạng thái + chọn việc)

- Máy trạng thái dùng enum đơn giản: `IDLE`, `MOVING`, `WORKING`, `CARRYING`, `EATING`, `SLEEPING`, `SOCIAL`, `FLEEING`, `FIGHTING`, `KNOCKED_OUT`. Không dùng plugin.
- Mỗi thổ dân "suy nghĩ" mỗi 0.3–0.6 giây, lệch giờ ngẫu nhiên để không dồn CPU vào cùng một frame. Thứ tự ưu tiên:
  1. Nguy hiểm (cannibal ở gần) → chạy trốn hoặc đánh nhau.
  2. Nhu cầu khẩn cấp (No < 20, Năng lượng < 15) → đi ăn hoặc đi ngủ. Hiện bong bóng giải thích.
  3. Việc người chơi giao → làm. Khi xong một lượt thì lặp lại cùng việc đó (ví dụ chặt hết cây này thì tìm cây gần nhất).
  4. Việc chung của làng (xây công trình đang dở, khuân đồ về kho).
  5. Rảnh → **hoạt cảnh rảnh rỗi** (mục 5.3).
- **Đặt chỗ (reservation):** một cái cây hoặc một chỗ trong lều chỉ được một người nhận, tránh 5 người cùng chạy tới một cây.
- Khi bị ngắt giữa chừng (đói, buồn ngủ) thì **ghi nhớ việc đang làm** và tự quay lại sau. Không bao giờ bỏ việc âm thầm.

### 5.3 Hoạt cảnh rảnh rỗi (linh hồn của game gốc)

Chọn ngẫu nhiên, có trọng số theo tính cách, mỗi cái kéo dài 3–10 giây:
- **Tán gẫu**: hai người quay mặt vào nhau, bong bóng thoại chứa ký tự vô nghĩa ("Ugga bugga!", "Bùm ba la?"), kèm tiếng lẩm bẩm.
- **Hái hoa**: cúi xuống, đứng lên cầm bông hoa. Người Lãng mạn thì mang hoa tặng người khác (hiện tim nhỏ).
- **Gãi mông**: tinh nghịch, nhanh, có hiệu ứng "gãi gãi".
- **Ngồi phơi nắng** hoặc ngáp.
- **Nhảy disco** ở sân nhảy (khi đã xây).
- **Đuổi bướm** (Ham chơi).
- **Ngồi ăn vặt** quả mọng.
- **Trẻ con chơi đùa** đuổi nhau. Em bé bò lổm ngổm quanh lều.

---

## 6. Hoạt họa & cảm giác "dễ thương"

### 6.1 Khung cutout

- Mỗi thổ dân là một `Node2D` gồm các `Sprite2D` con, thứ tự vẽ từ sau ra trước: `leg_back`, `arm_back`, `body`, `leg_front`, `head`, `face`, `hair`, `accessory`, `arm_front`, `held_item`.
- Tỉ lệ **chibi**: đầu chiếm khoảng 45% chiều cao. Cả nhân vật cao khoảng **72 px** ở độ phân giải gốc.
- **Animation chủ yếu tạo bằng code** (tween, sin/cos), không vẽ từng frame:
  - Đi: thân nảy lên xuống, chân và tay đưa qua lại, nghiêng nhẹ theo hướng đi.
  - Đứng yên: thở (thân phồng xẹp 2–3%), **chớp mắt** ngẫu nhiên (đổi texture mặt).
  - Squash & stretch khi dừng lại, nhảy lên, hoặc đặt đồ xuống.
  - Lật ngang (`scale.x = -1`) theo hướng đi.
- **Danh sách animation bắt buộc:** idle, walk, run (khi chạy trốn), chop (vung rìu), mine (gõ búa), gather (cúi hái), carry (giơ đồ trên đầu), eat, sleep (nằm, có "Zzz"), talk, pick_flower, scratch, dance, love (tim bay ra), attack (vung chùy), hurt (giật lùi, nháy trắng), knocked_out (nằm, sao quay quanh đầu), baby_crawl, celebrate (nhảy cẫng lên khi xong việc lớn).

### 6.2 Phản hồi và "juice"

- **Icon trên đầu** cho biết đang làm gì (rìu, búa, quả, đĩa thức ăn, Zzz, tim, chùy).
- **Bong bóng cảm xúc** khi có chuyện: đói 🍖, buồn ngủ 😴, vui ♪, yêu ❤, sợ ❗. Vẽ thành icon SVG, không dùng emoji font.
- **Số bay lên** khi khuân đồ về kho: "+3 gỗ".
- **Bụi** khi chặt cây, đập đá hoặc dừng chạy.
- **Công trình** mọc lên dần khi xây, nảy "bụp" khi xong, có pháo giấy.
- **Ngày và đêm**: `CanvasModulate` đổi màu dần (sáng → cam lúc hoàng hôn → xanh tím lúc đêm). Ban đêm thì lửa trại sáng (sprite phát sáng cộng màu, không dùng Light2D để Web chạy nhẹ).
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
  - `villager/face_happy`, `face_sad`, `face_blink`, `face_sleep`, `face_surprised`
  - `villager/hair_01..05`
  - `villager/body_01..03` (áo lông)
  - `villager/arm.svg`, `villager/leg.svg`
  - `villager/accessory_01..03`
- Môi trường: cây (2 loại), gốc cây, đá (2 cỡ), bụi quả (có quả / hết quả), hoa, cỏ trang trí, ô nước, hang đá xuất phát, lửa trại.
- Công trình: lều ngủ, bếp, kho, kho vũ khí, sân nhảy. Mỗi cái có 3 trạng thái: móng (đang xây), hoàn thành, hư hại.
- Thú: lợn rừng, hươu nhỏ. Kẻ thù: cannibal (mặt nạ xương, sơn chiến), kèm biến thể màu.
- Icon: mỗi tài nguyên, mỗi việc, mỗi cảm xúc, nút tốc độ.
- **Viết `ASSET_SPEC.md`**: một bảng liệt kê **mọi** file gồm đường dẫn, kích thước khuyến nghị (px), điểm neo hoặc điểm xoay (ví dụ: tay xoay ở vai), và ghi chú. Mục đích là sau này mình vẽ PNG cùng tên, bỏ vào `assets/art/`, và game tự dùng mà không phải sửa code.

---

## 8. Điều khiển: hỗ trợ cả chuột lẫn cảm ứng

`InputRouter` nhận sự kiện thô từ chuột và cảm ứng, rồi phát ra **lệnh chung** để phần còn lại của game không cần biết người chơi dùng gì:

| Lệnh | Chuột | Cảm ứng |
|---|---|---|
| `select` | Click trái | Chạm |
| `command_target` (giao việc hoặc di chuyển tới chỗ) | Click trái vào mục tiêu khi đang chọn thổ dân | Chạm vào mục tiêu khi đang chọn thổ dân |
| `drag_assign` (kéo thổ dân thả vào cây, công trình…) | Giữ chuột trái kéo từ thổ dân | Giữ ngón tay kéo từ thổ dân |
| `pan` | Kéo chuột ở chỗ trống / phím WASD / chuột giữa | Kéo một ngón ở chỗ trống |
| `zoom` | Lăn chuột | Chụm hai ngón |
| `inspect` (xem thông tin nhanh) | Rê chuột lên | Nhấn giữ 0.4 s |
| `cancel` | Chuột phải / Esc | Nút ✕ trên màn hình |
| Tạm dừng / tốc độ | Space, phím 1–3 | Nút trên HUD |

- **Tự nhận biết** kiểu điều khiển từ sự kiện gần nhất và phát signal `input_mode_changed`. UI dùng signal đó để hiện hoặc ẩn nút ✕, chỉnh cỡ tooltip.
- Phân biệt chạm với kéo bằng ngưỡng khoảng 10 px. Vùng chạm mỗi thổ dân **lớn hơn hình vẽ** (tối thiểu 48×48 px) để dễ chạm trên điện thoại.
- Có setting **"Cỡ giao diện"** (80–150%).
- Không có tính năng nào **chỉ** dùng được bằng rê chuột hoặc chuột phải.

---

## 9. Thế giới, tài nguyên & công trình (phạm vi MVP)

### 9.1 Map

- Map khoảng **48×36 ô**, sinh ngẫu nhiên theo seed nhưng luôn đảm bảo các điểm sau:
  - Hang đá xuất phát và lửa trại ở giữa.
  - Rừng cây ở một phía, bãi đá ở phía khác, rải rác bụi quả.
  - Một hồ hoặc suối nhỏ có chỗ câu cá.
  - Đồng cỏ có thú đi lang thang.
  - Một cạnh map là hướng cannibal kéo đến.
- Có chế độ đặt seed cố định để test.

### 9.2 Tài nguyên

| Tài nguyên | Nguồn | Ghi chú |
|---|---|---|
| Quả mọng | Hái ở bụi | Ăn sống được, hồi No ít. Bụi mọc lại quả sau một thời gian |
| Thịt sống | Săn thú | Phải nấu ở bếp (hoặc lửa trại) mới ăn được |
| Cá sống | Câu ở hồ | Phải nấu |
| Món chín | Nấu ở bếp | Hồi No nhiều và tăng Vui |
| Gỗ | Chặt cây | Cây hết thì thành gốc, mọc lại rất chậm |
| Đá | Đập đá | |
| Vũ khí (chùy) | Làm ở kho vũ khí từ gỗ và đá | Trang bị thì tăng sức đánh |

Đồ thu được phải **khuân về kho** (ban đầu là lửa trại). Thanh tài nguyên trên HUD chỉ tính đồ đã nằm trong kho.

### 9.3 Công trình MVP

| Công trình | Chi phí (gợi ý) | Chức năng |
|---|---|---|
| Lửa trại (có sẵn) | — | Kho ban đầu, nấu ăn chậm, chỗ tụ tập buổi tối |
| Lều ngủ | 10 gỗ | 2 chỗ ngủ. **Tăng giới hạn dân số**. Nơi các cặp đôi có em bé |
| Bếp | 12 gỗ, 6 đá | Nấu thịt và cá thành món chín, nhanh hơn lửa trại |
| Kho | 15 gỗ | Thêm điểm cất đồ (đỡ phải đi xa), tăng sức chứa |
| Kho vũ khí | 10 gỗ, 10 đá | Làm chùy, trang bị cho dân |
| Sân nhảy | 8 gỗ, 4 đá | Chỗ vui chơi. Thổ dân nhảy disco ở đây để tăng Vui |

- Chọn công trình trong menu → hiện **bóng mờ** đi theo con trỏ hoặc ngón tay (xanh = đặt được, đỏ = không). Chạm lần nữa để đặt, có nút xác nhận hoặc huỷ trên cảm ứng.
- Đặt xong thì thành **móng**. Dân rảnh hoặc dân được giao sẽ khuân vật liệu tới rồi xây. Có thanh tiến độ.
- Công trình bị cannibal đánh sẽ **hư hại** và mất chức năng cho đến khi được sửa.
- Thêm sau MVP: phòng tập (gym), bẫy lưới, lều tù trưởng, bãi cát cho trẻ con.

---

## 10. Dân số, tình yêu & em bé

- Bắt đầu với **6 thổ dân** người lớn (3 nam, 3 nữ), cùng chui ra từ hang theo hoạt cảnh: lần lượt ló đầu ra, dụi mắt, vươn vai.
- Giới hạn dân số = số chỗ trong lều × hệ số, **tối đa 50**.
- **Yêu nhau**: hai người lớn khác giới, Tâm trạng của cả hai > 70, và có chỗ trống trong lều. Họ nắm tay đi về lều, tim bay ra (lều rung nhẹ, hiện tim, kiểu dễ thương, không có gì nhạy cảm). Sau đó thành **cặp đôi** cố định, có biểu tượng tim nhỏ khi đứng gần nhau.
- **Em bé** chào đời sau một khoảng thời gian, có toast thông báo kèm tên ngẫu nhiên. Em bé → trẻ con → người lớn theo thời gian trong game (xem `balance.gd`). Trẻ con không làm việc, chỉ chơi.
- Đây là **phần thưởng cho việc chăm dân tốt**: dân vui thì làng đông. Phải làm cho người chơi cảm nhận rõ điều này.

---

## 11. Mối đe doạ & chiến đấu

- **Đói**: No về 0 thì mất máu dần. Bong bóng 🍖 nhấp nháy, toast cảnh báo "Làng sắp hết đồ ăn!".
- **Cannibal tấn công theo đợt**:
  - Đợt đầu vào khoảng **ngày 5**, sau đó cứ vài ngày một đợt, mỗi đợt mạnh dần.
  - Trước khi tấn công: tiếng tù và, toast cảnh báo, mũi tên ở rìa màn hình chỉ hướng kẻ địch đến (khoảng 20 giây để chuẩn bị).
  - Cannibal nhắm vào công trình và dân gần nhất.
  - Dân có trang bị chùy sẽ **tự động ra đánh** khi địch tới gần. Người chơi có thể chọn một nhóm dân rồi chạm vào một chỗ để **dàn quân** ở đó.
  - Đánh nhau tự động: đứng gần, vung chùy theo nhịp, sát thương dựa vào sức đánh.
  - Hết máu thì **ngất** (nằm, có sao quay quanh đầu).
  - Cannibal hết máu thì bỏ chạy, vừa chạy vừa lăn lộn cho hài.
- **Độ khó** (chọn khi bắt đầu game):
  - **Dễ** (mặc định): dân ngất rồi tự tỉnh, **không ai chết**. Cannibal yếu hơn.
  - **Thường**: dân ngất quá lâu mà không ai cứu thì mất vĩnh viễn (hiện một bia mộ nhỏ dễ thương).
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
- 6 thổ dân chui ra từ hang. Có tên, tính cách, các thanh nhu cầu.
- Tìm đường bằng `AStarGrid2D`, có đặt chỗ.
- Hoạt cảnh rảnh rỗi: tán gẫu, hái hoa, gãi, ngồi, ăn quả.
- Tự đi hái quả mọng và ăn khi đói. Ngủ ngoài trời cạnh lửa trại khi mệt.
- Chạm vào thổ dân → bảng thông tin (chân dung, tên, tính cách, thanh nhu cầu, việc đang làm).
- **Xong khi:** ngồi xem 5 phút thấy làng "sống", mỗi người một kiểu, không ai chết đói khi còn quả.

### Đợt 1.5 — Tái cấu trúc theo kiến trúc đa chế độ
> Đợt chèn thêm vì Đợt 0–1 được làm trước khi có mục 3.2. **Chỉ tái cấu trúc, không thêm tính năng, hành vi game phải giữ nguyên.**
- **Bước 1 — Rà soát:** đọc toàn bộ code hiện tại, đối chiếu với mục 3.2, liệt kê các chỗ vi phạm (core gọi thẳng UI, UI sửa thẳng dữ liệu villager, luật chơi viết cứng, ngoại hình lưu bằng đường dẫn ảnh…) kèm kế hoạch sửa. **Dừng lại cho mình duyệt.**
- **Bước 2 — Sửa** theo kế hoạch đã duyệt:
  - Tạo `VillagerData`, chuyển hàm random sang tạo `VillagerData`, có `spawn_villager(data, cell)`.
  - Tạo `GameModeConfig` + `normal_mode.tres`; màn hình (hoặc scene) khởi động nạp chế độ qua cơ chế này.
  - Tạo autoload `Commands` làm API chung; tách `NormalController` khỏi code xử lý input hiện có.
  - Chuyển HUD và bảng thông tin vào `ui/normal/` và `ui/common/`.
  - Cập nhật save/load nếu cấu trúc dữ liệu đổi.
- Chạy kiểm tra headless, cập nhật `DEVLOG.md` (mục "Đợt 1.5").
- **Xong khi:** bấm F5 game chạy **y như cuối Đợt 1** (thổ dân đi lại, hái quả, ăn, ngủ, bảng thông tin), không có lỗi trong Output, và code tuân thủ đủ 5 quy tắc của mục 3.2.

### Đợt 2 — Lao động & tài nguyên
- Giao việc bằng chạm (chọn người rồi chạm mục tiêu) và bằng **kéo-thả** thổ dân vào mục tiêu. Toàn bộ logic diễn giải nằm trong `NormalController`, việc giao việc thực sự đi qua `Commands.assign_job()` (mục 3.2).
- Các việc: chặt cây, đập đá, hái quả, săn thú, câu cá, khuân về kho, nấu ở lửa trại.
- Icon việc trên đầu, đường chấm chấm tới mục tiêu, số bay "+3 gỗ", HUD tài nguyên.
- Bị ngắt quãng thì nhớ việc và tự quay lại. Hiện bong bóng giải thích.
- Nút tốc độ: tạm dừng, ×1, ×2, ×3.
- **Xong khi:** giao 3 người chặt gỗ và 2 người đập đá, số trong kho tăng đều, không ai đứng đơ.

### Đợt 3 — Xây dựng & ngày đêm
- Menu xây, bóng mờ khi đặt, móng, khuân vật liệu, thanh tiến độ, hiệu ứng hoàn thành.
- Năm công trình MVP và chức năng của từng cái.
- Chu kỳ ngày đêm. Ban đêm thổ dân về lều ngủ (không đủ lều thì ngủ ngoài trời và kém vui hơn).
- Tự lưu mỗi ngày, có lưu và tải thủ công.
- **Xong khi:** xây được cả năm công trình, bếp nấu ra món chín, đêm xuống mọi người về lều.

### Đợt 4 — Tình yêu & dân số
- Tâm trạng tổng hợp, yêu nhau, cặp đôi, em bé, lớn lên, giới hạn dân số theo lều.
- Toast thông báo và một **nhật ký làng** ngắn ("Ngày 3: Bạp và Mít thành đôi").
- Sân nhảy hoạt động, có hoạt cảnh disco.
- **Xong khi:** chơi khoảng 15 phút với dân vui vẻ thì có ít nhất 2 em bé chào đời và lớn lên.

### Đợt 5 — Cannibal & chiến đấu
- Kho vũ khí làm chùy, trang bị cho dân.
- Đợt tấn công: cảnh báo, kẻ địch kéo đến, phá nhà, đánh nhau tự động, dàn quân, ngất, sửa nhà.
- Chọn độ khó Dễ hoặc Thường.
- **Xong khi:** sống sót qua 2 đợt tấn công ở độ khó Dễ. Nhà bị phá sửa được. Không crash.

### Đợt 6 — Đánh bóng & gửi đi
- **Nhiệm vụ ngắn** kiểu game gốc, hiện thành thẻ: "Dựng 2 lều", "Có 10 người", "Nấu 5 món chín", "Sống sót đợt tấn công đầu tiên"…, có phần thưởng nhỏ.
- Màn hình bắt đầu ("Chạm để bắt đầu", vì trình duyệt chặn âm thanh trước lần chạm đầu tiên), chọn độ khó, hướng dẫn nhẹ dạng mũi tên chỉ ở vài bước đầu.
- Setting: âm lượng từng bus, cỡ giao diện, ngôn ngữ.
- Âm thanh, hiệu ứng, cân bằng lại các con số.
- Cấu hình preset xuất Web (tắt Thread Support), tự kiểm tra cỡ file và tốc độ tải.
- **Xong khi:** gửi link Web cho người chơi thật, họ tự hiểu cách chơi trong 2 phút đầu và muốn chơi tiếp.

---

## 13. Con số khởi điểm (đặt trong `data/balance.gd`)

| Thông số | Giá trị đầu |
|---|---|
| Một ngày trong game | 4 phút thật (ngày 3 phút, đêm 1 phút) |
| No giảm | 100 → 0 trong khoảng 1.5 ngày |
| Năng lượng giảm khi làm việc | 100 → 0 trong khoảng 1 ngày |
| Tốc độ đi | 90 px/giây (×1.3 khi chạy trốn) |
| Chặt 1 cây | 6 giây → 3 gỗ (cây có 3 lượt) |
| Đập 1 tảng đá | 8 giây → 2 đá (đá có 4 lượt) |
| Hái 1 bụi quả | 3 giây → 2 quả. Mọc lại sau 1 ngày |
| Nấu 1 món | 5 giây ở bếp, 10 giây ở lửa trại |
| Yêu nhau → có em bé | 0.5 ngày |
| Em bé → trẻ con → người lớn | 1 ngày → 2 ngày |
| Đợt cannibal đầu tiên | Ngày 5, 3 kẻ địch, mỗi đợt sau thêm 1–2 |
| Thời gian cảnh báo trước khi tấn công | 20 giây |

Đây chỉ là điểm xuất phát. Sau mỗi đợt, đề xuất chỉnh lại dựa trên cảm giác chơi.

---

## 14. Ngoài phạm vi MVP (chưa làm)

Bệnh tật và pháp sư, hổ răng kiếm, phòng tập và hệ thống chỉ số chi tiết, bẫy lưới, khám phá vùng mới, chiến dịch nhiều màn, mùa đông, quan hệ bạn bè và thù ghét, trang trí làng, bản Android, tiếng Anh đầy đủ, nhạc nền riêng.

Kiến trúc nên **chừa chỗ** cho các tính năng này (dữ liệu tách riêng, công trình cấu hình bằng data, sự kiện qua `EventBus`), nhưng không viết trước.

### Sau MVP: Chế độ Thần Linh (God mode)

Chưa làm, chỉ ghi lại để định hướng. Kiến trúc ở mục 3.2 là để chuẩn bị cho phần này.

- **Phép thần trong chế độ Normal** (làm trước, có thanh năng lượng hồi dần):
  - Mưa: bụi quả mọc lại ngay.
  - Thả đùi gà từ trên trời xuống.
  - Sét đánh cannibal: ngất kiểu hài, không chết.
  - Mũi tên tình yêu: bắn vào hai thổ dân là họ thành đôi.
  - Cù lét: thổ dân lăn ra cười, tăng Vui.
- **Chế độ Thần Linh riêng**:
  - `god_mode.tres`, `GodController`, `ui/god/`.
  - Không giao việc trực tiếp, không nhiệm vụ, không thua.
  - Phép thần không giới hạn, có thêm các phép như tự thả cannibal hay thú hoang vào map.
- **Trình tạo nhân vật**:
  - Chọn tóc, mặt, áo, màu da, phụ kiện bằng nút ◀ ▶; đặt tên, chọn giới tính và tính cách; có nút 🎲 ngẫu nhiên.
  - Xem trước nhân vật đang nhún nhảy (dùng lại `villager_rig`), rồi thả xuống map qua `spawn_villager()`.
  - Mở rộng sau: bảng màu tự do, lưu mẫu nhân vật, tạo sẵn gia đình.
  - Muốn trình tạo nhân vật vui thì cần **nhiều mảnh art** (khoảng 8–10 kiểu tóc, 6 mặt, 6 áo…).
