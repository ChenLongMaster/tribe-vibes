class_name SunDial
extends Control
## Đồng hồ mặt trời nhỏ trên HUD: mặt trời chạy theo cung từ trái (mọc) sang phải (lặn), đêm
## thì mặt trăng chạy cung riêng. Đọc GameState.time_of_day — chỉ để người chơi ước giờ nhanh.

const DIAL_SIZE: Vector2 = Vector2(64, 36)
const ICON_SIZE: float = 18.0
const ARC_COLOR: Color = Color("#A1887F")
const GROUND_COLOR: Color = Color("#4E342E")


func _ready() -> void:
	custom_minimum_size = DIAL_SIZE
	mouse_filter = Control.MOUSE_FILTER_PASS
	tooltip_text = Loc.t("UI_SUN_DIAL")
	Loc.language_changed.connect(func(_code: String) -> void: tooltip_text = Loc.t("UI_SUN_DIAL"))


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var base: Vector2 = Vector2(size.x * 0.5, size.y - 4.0)
	var radius: float = minf(size.x * 0.5 - ICON_SIZE * 0.5, size.y - ICON_SIZE * 0.5 - 4.0)
	draw_arc(base, radius, PI, TAU, 24, ARC_COLOR, 2.0, true)
	draw_line(Vector2(2, base.y), Vector2(size.x - 2.0, base.y), GROUND_COLOR, 2.0)
	var t: float = GameState.time_of_day
	var sun: float = (t - Balance.SUNRISE) / (Balance.SUNSET - Balance.SUNRISE)
	var night: bool = sun <= 0.0 or sun >= 1.0
	var along: float = sun
	if night:
		# Đêm: mặt trăng đi từ lúc lặn tới lúc mọc.
		var night_length: float = 1.0 - (Balance.SUNSET - Balance.SUNRISE)
		along = fposmod(t - Balance.SUNSET, 1.0) / night_length
	var angle: float = PI + PI * clampf(along, 0.0, 1.0)
	var at: Vector2 = base + Vector2(cos(angle), sin(angle)) * radius
	var icon: Texture2D = ArtLibrary.get_texture("ui/moon" if night else "ui/sun")
	draw_texture_rect(icon, Rect2(at - Vector2(ICON_SIZE, ICON_SIZE) * 0.5, Vector2(ICON_SIZE, ICON_SIZE)), false)
