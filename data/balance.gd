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

# --- Camera ---
const CAMERA_ZOOM_MIN: float = 0.5
const CAMERA_ZOOM_MAX: float = 2.0
const CAMERA_ZOOM_SMOOTHING: float = 12.0 # càng lớn zoom càng nhanh tới đích
const CAMERA_KEY_PAN_SPEED: float = 700.0 # px/giây khi zoom = 1

# --- Tài nguyên trên map ---
const TREE_USES: int = 3 # lượt chặt mỗi cây
const WOOD_PER_CHOP: int = 3
const CHOP_SECONDS: float = 6.0
const ROCK_USES: int = 4
const STONE_PER_MINE: int = 2
const MINE_SECONDS: float = 8.0
const BUSH_BERRIES_PER_PICK: int = 2
const PICK_SECONDS: float = 3.0

# --- Thời gian ---
const MAX_GAME_SPEED: int = 3
const DAY_LENGTH_SECONDS: float = 240.0 # một ngày trong game = 4 phút thật

# --- Thổ dân: dân số ban đầu ---
const START_VILLAGERS: int = 6 # nửa nam nửa nữ
const INTRO_INTERVAL: float = 1.3 # giây giữa hai người chui ra khỏi hang
const SECOND_TRAIT_CHANCE: float = 0.5
const BEST_JOB_BONUS: float = 1.25 # làm việc giỏi nhất nhanh hơn 25%

# --- Thổ dân: di chuyển & suy nghĩ ---
const WALK_SPEED: float = 90.0 # px/giây
const FLEE_SPEED_MULT: float = 1.3
const THINK_INTERVAL_MIN: float = 0.3 # giây
const THINK_INTERVAL_MAX: float = 0.6
const LANE_JITTER: float = 10.0 # px lệch khỏi tâm ô để nhiều người không đi chồng lên nhau

# --- Thổ dân: nhu cầu (0..100) ---
const HUNGER_DECAY: float = 100.0 / (1.5 * DAY_LENGTH_SECONDS) # no → đói trong 1.5 ngày
const ENERGY_DECAY_IDLE: float = 100.0 / (2.5 * DAY_LENGTH_SECONDS)
const ENERGY_DECAY_WORK: float = 100.0 / DAY_LENGTH_SECONDS # làm liên tục thì hết sức trong 1 ngày
const ENERGY_RESTORE_SLEEP: float = 2.5 # mỗi giây khi ngủ
const ENERGY_RESTORE_SIT: float = 0.4
const FUN_DECAY: float = 0.12
const FUN_DECAY_UNCOMFORTABLE: float = 0.15 # thêm khi đói hoặc mệt
const HUNGER_URGENT: float = 20.0 # dưới mức này bỏ mọi thứ đi ăn
const HUNGER_SNACK: float = 60.0 # dưới mức này rảnh là đi ăn vặt
const HUNGER_WAKE: float = 10.0 # đang ngủ mà đói tới mức này thì dậy đi ăn
const ENERGY_URGENT: float = 15.0 # dưới mức này đi ngủ
const ENERGY_TIRED: float = 40.0 # dưới mức này rảnh thì hay ngồi nghỉ
const ENERGY_WAKE: float = 95.0
const UNCOMFORTABLE_LEVEL: float = 30.0
const HEALTH_STARVE_LOSS: float = 0.3 # mỗi giây khi No = 0
const HEALTH_REGEN: float = 0.2 # mỗi giây khi không đói
const MOOD_WEIGHT_HUNGER: float = 0.35
const MOOD_WEIGHT_ENERGY: float = 0.25
const MOOD_WEIGHT_FUN: float = 0.4
const MOOD_HAPPY: float = 65.0 # trên mức này mặt cười
const MOOD_SAD: float = 35.0 # dưới mức này mặt mếu
const START_HUNGER_MIN: float = 55.0
const START_HUNGER_MAX: float = 90.0
const START_ENERGY_MIN: float = 45.0
const START_ENERGY_MAX: float = 100.0
const START_FUN_MIN: float = 50.0
const START_FUN_MAX: float = 80.0

# --- Ăn uống ---
const BERRY_HUNGER: float = 20.0 # một quả mọng hồi bao nhiêu No
const BUSH_REGROW_SECONDS: float = DAY_LENGTH_SECONDS # bụi ra quả lại sau 1 ngày
const EAT_SECONDS: float = 2.0
const FUN_EAT: float = 6.0

# --- Hoạt cảnh rảnh rỗi ---
const IDLE_MIN_SECONDS: float = 3.0
const IDLE_MAX_SECONDS: float = 10.0
const CHAT_RANGE_CELLS: float = 8.0
const FUN_CHAT: float = 3.0 # mỗi giây đang tán gẫu
const FUN_SIT: float = 1.5 # mỗi giây ngồi phơi nắng
const FUN_FLOWER: float = 10.0
const FUN_GIVE_FLOWER: float = 12.0 # cho cả người tặng lẫn người nhận
const FUN_SCRATCH: float = 5.0
const FLOWER_RANGE_CELLS: float = 7.0
const WANDER_RANGE_CELLS: int = 5
const VILLAGE_ROAM_RADIUS: float = 10.0 # đi xa hơn thì dạo lại về phía làng
const SLEEP_SPOT_MIN_RING: float = 1.5 # ô quanh lửa trại để ngủ ngoài trời
const SLEEP_SPOT_MAX_RING: float = 4.5

# --- Gỡ lỗi ---
const WATCHDOG_SECONDS: float = 40.0 # một việc kéo dài hơn thế (trừ ngủ) là đáng ngờ
