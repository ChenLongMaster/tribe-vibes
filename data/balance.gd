class_name Balance
## MỌI con số cân bằng game nằm ở đây. Muốn game dễ/khó, nhanh/chậm hơn thì sửa
## file này, không cần đụng vào code khác. Đơn vị ghi ở cuối mỗi dòng.

# --- Bản đồ ---
const MAP_WIDTH: int = 48 # ô
const MAP_HEIGHT: int = 36 # ô
const TILE_SIZE: int = 64 # px mỗi ô (ở độ phân giải gốc)
## >= 0 thì luôn dùng seed này (để test lặp lại được). -1 = ngẫu nhiên mỗi ván.
const DEBUG_FIXED_SEED: int = -1

const MAP_NOISE_FREQUENCY: float = 0.09
const VILLAGE_CLEAR_RADIUS: float = 5.5 # ô quanh lửa trại không có cây/đá
const LAKE_RADIUS_X_MIN: int = 5 # ô
const LAKE_RADIUS_X_MAX: int = 7
const LAKE_RADIUS_Y_MIN: int = 3
const LAKE_RADIUS_Y_MAX: int = 4
const LAKE_EDGE_MARGIN: int = 6 # khoảng cách tâm hồ tới mép map
const LAKE_CENTER_JITTER: int = 6 # hồ lệch trái/phải ngẫu nhiên tối đa
const LAKE_WOBBLE: float = 0.45 # độ cong queo của bờ hồ (0 = elip tròn)
const FOREST_MAX_DENSITY: float = 0.42 # 0..1, quá ~0.4 thì rừng thành bức tường không đi vào được
const FOREST_START: float = 0.15 # 0 = giữa map, 1 = mép rừng
const LONE_TREE_CHANCE: float = 0.025
const ROCK_START: float = 0.3
const ROCK_CHANCE: float = 0.3
const ROCK_NOISE_THRESHOLD: float = 0.15 # -1..1, cao hơn = cụm đá nhỏ và thưa hơn
const ROCK_BIG_CHANCE: float = 0.4
const BUSH_COUNT_VILLAGE: int = 10
const BUSH_COUNT_MEADOW: int = 4
const BUSH_RING_MIN: float = 4.5 # ô tính từ giữa làng
const BUSH_RING_MAX: float = 11.0
const BUSH_MIN_SPACING: float = 2.0 # ô
const FISHING_SPOT_COUNT: int = 4
const FISHING_SPOT_MIN_SPACING: float = 3.0 # ô
const MEADOW_HALF_WIDTH: int = 10 # ô
const MEADOW_DEPTH: int = 9 # ô
const DECOR_TUFT_CHANCE: float = 0.12
const DECOR_FLOWER_CHANCE: float = 0.04
const MEADOW_TUFT_CHANCE: float = 0.15
const MEADOW_FLOWER_CHANCE: float = 0.25
const DIRT_PATCH_COUNT: int = 3
const GRASS_PATCH_COUNT: int = 30 # mảng cỏ sáng/tối trang trí nền
const CLIFF_COUNT: int = 3 # vách đá lớn ở phía bãi đá (không khai thác được, sinh ra đá tảng)
const CLIFF_MIN_SPACING: float = 6.0 # ô
const CLIFF_SIDE_START: float = 0.55 # 0 = giữa map, 1 = mép — vách đá nằm sâu phía bãi đá
const BOULDERS_PER_CLIFF: int = 2 # đá tảng nằm sẵn sát chân mỗi vách lúc mới sinh map

# --- Camera ---
const CAMERA_ZOOM_MIN: float = 0.5
const CAMERA_ZOOM_MAX: float = 2.0
const CAMERA_ZOOM_SMOOTHING: float = 12.0 # càng lớn zoom càng nhanh tới đích
const CAMERA_KEY_PAN_SPEED: float = 700.0 # px/giây khi zoom = 1 (phím và chuột sát mép)
const CAMERA_EDGE_SCROLL_PX: float = 8.0 # chuột cách mép màn hình chừng này thì bản đồ trượt

# --- Tài nguyên trên map ---
const WOOD_PER_LOG: int = 10 # 1 khúc gỗ (chặt cây) = 10 bó củi (nhặt tay)
const TREE_USES: int = 3 # mỗi cây chặt ra chừng này khúc gỗ rồi thành gốc
const CHOP_SECONDS: float = 10.0 # chặt ra một khúc gỗ (cần rìu)
const ROCK_USES: int = 4 # đá tảng đập chừng này lượt thì vỡ hết
const STONE_PER_MINE: int = 4 # mỗi lượt đập đá tảng (cần cuốc)
const MINE_SECONDS: float = 8.0
## Giao đập đá tảng mà làng chưa có cuốc: tự nhặt đá cuội nằm trong chừng này ô quanh tảng đá
## đó (không có mới cắm biển "cần cuốc").
const TOOL_FALLBACK_RADIUS_CELLS: float = 3.0
const BUSH_BERRIES_PER_PICK: int = 2
const PICK_SECONDS: float = 3.0
const TWIG_PICK_SECONDS: float = 1.5 # nhặt một bó củi (tay không)
const PEBBLE_PICK_SECONDS: float = 1.5 # nhặt một viên đá cuội (tay không, bỏ vào xô)
const LOOSE_PICK_BATCH: int = 3 # nhặt đủ chừng này bó củi / viên đá cuội gần nhau rồi mới khuân về
## Củi rơi dưới tán cây, đá cuội lăn ra từ đá tảng — mọc thêm dần, có giới hạn để map không đầy.
const TWIG_START: int = 12
const TWIG_MAX: int = 20
const TWIG_SPAWN_SECONDS: float = 10.0 # trung bình chừng này giây rơi thêm một bó (nếu chưa đủ)
const PEBBLE_START: int = 8
const PEBBLE_MAX: int = 14
const PEBBLE_SPAWN_SECONDS: float = 14.0
## Đá tảng thỉnh thoảng lăn ra từ vách đá, chỉ khi số đá tảng còn ít hơn lúc đầu.
const BOULDER_SPAWN_SECONDS: float = 90.0
## Gốc cây mọc lại thành cây — chỉ khi số cây còn ít hơn lúc đầu (không mọc tràn map).
const TREE_REGROW_CHECK_SECONDS: float = 45.0 # mỗi chừng này giây thử cho một gốc mọc lại
const STUMP_MIN_SECONDS: float = DAY_LENGTH_SECONDS # gốc phải để ít nhất chừng này mới mọc lại
const FISH_SECONDS: float = 10.0 # câu một con cá
const FISH_PER_CATCH: int = 1
const HUNT_SECONDS: float = 4.0 # đứng cạnh con thú vung giáo bao lâu thì nó ngất
const MEAT_PER_HUNT: int = 4 # vác nguyên con thú về = chừng này phần thức ăn
const HUNT_PICKUP_SECONDS: float = 1.0 # thú ngất (sao quay) một chút rồi mới bị vác lên vai
const COOK_SECONDS_CAMPFIRE: float = 10.0 # nấu một món ở lửa trại (bếp tạm, chậm)
const COOK_SECONDS_KITCHEN: float = 5.0 # nấu một món ở Bếp (mỗi đầu bếp nấu riêng một nồi)
const CAMPFIRE_MEAL_CAPACITY: int = 4 # lửa trại chỉ cất chừng này món chín (Bếp cất nhiều hơn, theo cấp)
const CAMPFIRE_COOKS: int = 1 # lửa trại chỉ một người nấu

# --- Kho ---
## Hang đá là kho tạm lúc đầu: cất được ít thôi, đủ để người mới không bị kẹt nhưng muốn
## phát triển thì phải xây Kho (gỗ, đá) và Bếp (thức ăn). Sức chứa của Kho/Bếp ở data/buildings.gd.
const CAVE_WOOD_CAPACITY: int = 30
const CAVE_STONE_CAPACITY: int = 30
const CAVE_FOOD_CAPACITY: int = 15

# --- Xây dựng ---
## Mỗi chuyến thợ xây khuân từ kho ra công trường tối đa chừng này.
const BUILD_CARRY: Dictionary[StringName, int] = {&"wood": 10, &"stone": 5}
const BUILD_WAIT_SECONDS: float = 5.0 # kho thiếu vật liệu: đứng chờ trước công trình rồi thử lại
const BUILD_SEARCH_RADIUS_CELLS: float = 10.0 # xây xong thì tìm công trình dở khác trong bán kính này

# --- Lò rèn ---
const FORGE_SECONDS: float = 12.0 # rèn một món ở cấp 1 (chia theo kỹ năng Rèn)
const FORGE_MAX_ORDER: int = 9 # đặt rèn tối đa chừng này món mỗi loại

# --- Thú để săn ---
const ANIMAL_COUNT: int = 4 # số thú lang thang trên đồng cỏ cùng lúc
const ANIMAL_WALK_SPEED: float = 38.0 # px/giây
const ANIMAL_WANDER_CELLS: int = 3 # mỗi lần đi tối đa chừng này ô
const ANIMAL_GRAZE_MIN: float = 2.0 # giây đứng gặm cỏ giữa hai lần đi
const ANIMAL_GRAZE_MAX: float = 6.0
const ANIMAL_ALERT_CELLS: float = 2.5 # thợ săn tới gần chừng này thì thú giật mình đứng im
const ANIMAL_RESPAWN_SECONDS: float = 120.0 # bị săn xong bao lâu thì có con mới ở đồng cỏ

# --- Thời gian ---
const MAX_GAME_SPEED: int = 3
const START_HOUR_FRACTION: float = 0.25 # ván mới bắt đầu lúc sáng (0 = nửa đêm, 0.5 = trưa)
const DAY_LENGTH_SECONDS: float = 240.0 # một ngày trong game = 4 phút thật
## Mặt trời mọc / lặn (tỉ lệ của ngày): ngày 3 phút, đêm 1 phút.
const SUNRISE: float = 0.125
const SUNSET: float = 0.875
## Bóng đổ: dài nhất lúc mặt trời sát chân trời (tính theo chiều cao vật), ngắn nhất lúc trưa.
const SHADOW_LENGTH_MAX: float = 3.0
const SHADOW_LENGTH_MIN: float = 0.3
const SHADOW_ALPHA: float = 0.26 # độ đậm của bóng giữa trưa
## Bóng ép dẹt theo góc nhìn 3/4 (chiều dọc màn hình ngắn hơn).
const SHADOW_DEPTH_SQUASH: float = 0.45

# --- Thổ dân: dân số ---
const START_VILLAGERS: int = 4 # nửa nam nửa nữ
## Ra khỏi hang đã có sẵn ít thức ăn (quả) ở lửa trại — đủ vài bữa để người chơi kịp giao
## người đi kiếm đồ ăn (thổ dân không tự đi hái).
const START_FOOD: int = 8
const MAX_POPULATION: int = 50
const INTRO_INTERVAL: float = 1.3 # giây giữa hai người chui ra khỏi hang
const SECOND_TRAIT_CHANCE: float = 0.5

# --- Thổ dân: di chuyển & suy nghĩ ---
const WALK_SPEED: float = 90.0 # px/giây
const FLEE_SPEED_MULT: float = 1.3
const THINK_INTERVAL_MIN: float = 0.3 # giây
const THINK_INTERVAL_MAX: float = 0.6
const LANE_JITTER: float = 10.0 # px lệch khỏi tâm ô để nhiều người không đi chồng lên nhau

# --- Hành vi "nghe lời" (chế độ Normal) ---
## Rảnh thì đứng yên tại điểm neo. Chán rồi mới đi hái hoa trong bán kính này, hái xong quay về.
const IDLE_RADIUS_CELLS: float = 3.0
const IDLE_CHAT_RANGE_CELLS: float = 1.6 # chỉ tán gẫu với người đứng sát bên (không đi tìm nhau)
## Đứng chờ lệnh chừng này giây (chỉ làm trò tại chỗ) rồi mới chán: ngồi, ngủ gật, hái hoa.
const IDLE_BORED_SECONDS: float = 30.0
const NAP_MIN_SECONDS: float = 8.0 # chán quá nằm ngủ gật tại chỗ
const NAP_MAX_SECONDS: float = 15.0
const JOB_SEARCH_RADIUS_CELLS: float = 8.0 # hết tài nguyên thì tìm cái tương tự trong bán kính này
const HUNT_SEARCH_RADIUS_CELLS: float = 14.0 # thú chạy lung tung nên tìm rộng hơn
const GATHER_SEARCH_RADIUS_CELLS: float = 14.0 # bụi quả mọc thưa (cách nhau ~9–13 ô) nên tìm rộng hơn
const JOB_MAX_FAILURES: int = 3 # không tới được mục tiêu chừng này lần liền thì thôi
const LAZY_BREAK_SECONDS: float = 4.0 # Lười nghỉ tay giữa chừng bao lâu
const LAZY_BREAK_CHANCE: float = 0.35 # mỗi lượt làm, Lười có chừng này khả năng nghỉ giữa chừng

# --- 4 chỉ số (0..100) ---
const HUNGER_DECAY: float = 100.0 / (1.5 * DAY_LENGTH_SECONDS) # no → đói trong 1.5 ngày
const HEAVY_WORK_HUNGER_MULT: float = 1.5 # việc nặng (chặt, đập đá, xây…) làm đói nhanh hơn
const HUNGER_EAT_BELOW: float = 50.0 # dưới mức này tự đi ăn
const HUNGER_WAKE: float = 20.0 # đang ngủ mà đói tới mức này thì dậy đi ăn
const ENERGY_DECAY_IDLE: float = 100.0 / (10.0 * DAY_LENGTH_SECONDS) # đứng chơi gần như không mệt
const ENERGY_DECAY_WORK: float = 100.0 / DAY_LENGTH_SECONDS # làm liên tục thì hết sức trong 1 ngày
const ENERGY_RESTORE_GROUND: float = 100.0 / 60.0 # ngủ đất: đầy trong ~60 giây
const ENERGY_RESTORE_SIT: float = 0.4 # ngồi phơi nắng cũng hồi chút sức
const ENERGY_SLEEP_BELOW: float = 50.0 # dưới mức này tự đi tìm chỗ ngủ
const ENERGY_COLLAPSE_WAKE: float = 30.0 # gục ngủ tại chỗ tới mức này rồi mới đi tìm chỗ ngủ
const ENERGY_WAKE: float = 95.0 # ngủ đủ
const ENERGY_TIRED: float = 60.0 # dưới mức này rảnh thì hay ngồi nghỉ
const FUN_RESTORE_IDLE: float = 0.15 # rảnh thì giải trí hồi dần
const FUN_DECAY_WORK: float = 100.0 / DAY_LENGTH_SECONDS # làm liên tục thì hết giải trí trong 1 ngày
const FAVORITE_FUN_DECAY_MULT: float = 0.25 # làm việc thích thì giải trí giảm rất chậm
const STRIKE_RESUME_FUN: float = 40.0 # đình công tới khi giải trí hồi lại mức này
const STRIKE_STOMP_SECONDS: float = 2.5 # quăng đồ nghề, dậm chân bao lâu
const UNCOMFORTABLE_LEVEL: float = 30.0 # Đói trên mức này thì máu tự hồi
const HEALTH_STARVE_LOSS: float = 100.0 / (0.5 * DAY_LENGTH_SECONDS) # Đói = 0: hết máu trong ~0.5 ngày
const HEALTH_REGEN: float = 0.2
const KNOCKOUT_SECONDS: float = 20.0 # độ khó Dễ: hết máu thì ngất chừng này rồi tỉnh
const KNOCKOUT_WAKE_HEALTH: float = 20.0
const KNOCKOUT_WAKE_HUNGER: float = 10.0 # tỉnh dậy còn chút sức để đi tới chỗ ăn
const ALERT_HEALTH_BELOW: float = 50.0 # icon chỉ số nhấp nháy trên đầu dưới các mức này
const ALERT_FUN_BELOW: float = 20.0
const FUN_FACE_HAPPY: float = 60.0 # icon giải trí: từ mức này trở lên là mặt vui
const FUN_FACE_OK: float = 30.0 # từ mức này là mặt bình thường, dưới nữa là bực bội đỏ mặt
const MOOD_WEIGHT_HUNGER: float = 0.35
const MOOD_WEIGHT_ENERGY: float = 0.25
const MOOD_WEIGHT_FUN: float = 0.4
const MOOD_HAPPY: float = 65.0 # trên mức này mặt cười
const MOOD_SAD: float = 35.0 # dưới mức này mặt mếu
const START_HUNGER_MIN: float = 55.0
const START_HUNGER_MAX: float = 90.0
const START_ENERGY_MIN: float = 60.0 # đủ cao để không ai vừa ra khỏi hang đã đi ngủ
const START_ENERGY_MAX: float = 100.0
const START_FUN_MIN: float = 50.0
const START_FUN_MAX: float = 80.0

# --- Kỹ năng ---
const SKILL_MIN_LEVEL: int = 1
const SKILL_MAX_LEVEL: int = 5
const SKILL_START_RANDOM_MAX: int = 2 # cấp khởi đầu ngẫu nhiên 1..2
const SKILL_START_CAP: int = 3 # cộng thêm theo tính cách nhưng không quá mức này
const SKILL_SPEED_PER_LEVEL: float = 0.1 # mỗi cấp trên 1 làm nhanh hơn 10%
const FAVORITE_XP_MULT: float = 2.0 # làm việc thích lên cấp nhanh gấp đôi
## Kinh nghiệm (giây làm việc) cần để lên cấp tiếp theo: 1→2, 2→3, 3→4, 4→5.
const SKILL_XP_TO_NEXT: Array[float] = [90.0, 180.0, 300.0, 480.0]

# --- Ăn uống ---
const BUSH_REGROW_SECONDS: float = DAY_LENGTH_SECONDS # bụi ra quả lại sau 1 ngày
const STORED_FOOD_FETCH_SECONDS: float = 1.0 # lấy đồ ăn có sẵn ở lửa trại/bếp
const EAT_SECONDS: float = 2.0
const FUN_EAT: float = 6.0
const KITCHEN_MEAL_HUNGER: float = 100.0 # ăn một phần ở bếp là no căng
## Ăn xong đỡ mệt chút. Phải nhỏ hơn hẳn thể lực mất giữa hai bữa (làm việc nặng: Đói
## 100 → 50 mất ~120 giây, cũng là ~50 thể lực) — để không ai "sống bằng ăn" mà khỏi ngủ.
const EAT_ENERGY: float = 10.0
const FUN_COOKED_MEAL: float = 10.0 # ăn món chín thì vui thêm chừng này

# --- Hoạt cảnh rảnh rỗi ---
const IDLE_MIN_SECONDS: float = 3.0
const IDLE_MAX_SECONDS: float = 10.0
const FUN_CHAT: float = 3.0 # mỗi giây đang tán gẫu
const FUN_SIT: float = 1.5 # mỗi giây ngồi phơi nắng
const FUN_FLOWER: float = 10.0
const FUN_SCRATCH: float = 5.0
const SLEEP_SPOT_MIN_RING: float = 1.5 # ô quanh lửa trại để ngủ đất
const SLEEP_SPOT_MAX_RING: float = 4.5

# --- Gỡ lỗi ---
const WATCHDOG_SECONDS: float = 40.0 # một việc kéo dài hơn thế (trừ ngủ, ngất) là đáng ngờ
