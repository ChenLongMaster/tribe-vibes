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
