class_name Animal
extends Node2D
## Thú để săn (lợn rừng, hươu): lang thang trên đồng cỏ, đứng gặm cỏ, thấy thợ săn tới
## gần thì giật mình đứng sững (❗). Bị săn thì ngất kiểu hoạt hình (sao quay), thợ săn vác
## nguyên con về — không máu me. Một lúc sau có con mới xuất hiện ở đồng cỏ.
## Thú không chặn đường và không bị xoá khỏi cây node (chỉ ẩn đi) để không ai giữ
## tham chiếu tới node đã giải phóng.

enum State { GRAZE, WALK, ALERT, KNOCKED, GONE }

const SPECIES: Array[StringName] = [&"boar", &"deer"]
const ART_DIR: String = "animals/"
## Vùng chạm quanh thân (so với chân) — rộng hơn hình cho dễ chạm.
const HIT_RECT: Rect2 = Rect2(-40, -62, 80, 72)
const ALERT_HOLD_SECONDS: float = 2.5
const KNOCKED_SECONDS: float = 1.4
const ALERT_ICON_OFFSET: Vector2 = Vector2(0, -66)
const STAR_COUNT: int = 3
const STAR_RADIUS: Vector2 = Vector2(18, 6)
const STAR_SPEED: float = 4.0
const STAR_SCALE: float = 0.6
const WALK_BOB: float = 2.5
const MAX_WANDER_TRIES: int = 8

var species: StringName = &"boar"
var state: State = State.GRAZE

var _world: World
var _path: PackedVector2Array = PackedVector2Array()
var _path_index: int = 0
var _timer: float = 0.0
var _time: float = 0.0
var _facing: float = 1.0
var _body: Node2D
var _sprite: Sprite2D
var _alert_icon: Sprite2D
var _stars: Array[Sprite2D] = []


func setup(world: World, animal_species: StringName, cell: Vector2i) -> void:
	_world = world
	species = animal_species
	position = WorldGrid.cell_to_world(cell)


func _ready() -> void:
	_body = Node2D.new()
	add_child(_body)
	_sprite = Sprite2D.new()
	ArtLibrary.setup_sprite(_sprite, art_key())
	_body.add_child(_sprite)
	_alert_icon = Sprite2D.new()
	ArtLibrary.setup_sprite(_alert_icon, "icons/scared")
	_alert_icon.position = ALERT_ICON_OFFSET
	_alert_icon.visible = false
	add_child(_alert_icon)
	for i: int in STAR_COUNT:
		var star: Sprite2D = Sprite2D.new()
		ArtLibrary.setup_sprite(star, "icons/star")
		star.scale *= STAR_SCALE
		star.visible = false
		add_child(star)
		_stars.append(star)
	_time = randf() * 10.0
	_set_facing(1.0 if randf() < 0.5 else -1.0)
	_graze()


## Hình đổ bóng theo mặt trời (ShadowLayer).
func shadow_sources() -> Array[Sprite2D]:
	return [_sprite]


## Còn săn được không (đang lang thang, chưa bị săn).
func is_huntable() -> bool:
	return state == State.GRAZE or state == State.WALK or state == State.ALERT


func art_key() -> String:
	return ART_DIR + String(species)


## Thợ săn nhấc con thú đã ngất lên vai: biến khỏi đồng cỏ (không "bụp"), chờ con mới.
func carry_off() -> void:
	if state != State.KNOCKED:
		return
	_update_stars(false)
	visible = false
	state = State.GONE
	_timer = Balance.ANIMAL_RESPAWN_SECONDS


func current_cell() -> Vector2i:
	return WorldGrid.world_to_cell(position)


func hit_test(world_point: Vector2) -> bool:
	return visible and is_huntable() and HIT_RECT.has_point(world_point - position)


## Thợ săn tới gần: giật mình đứng im, quay về phía người đó. Gọi liên tục khi người đó
## còn ở gần — ngừng gọi một lúc thì thú lại đi gặm cỏ.
func alert(from: Vector2) -> void:
	if not is_huntable():
		return
	if state != State.ALERT:
		state = State.ALERT
		_path = PackedVector2Array()
		_alert_icon.visible = true
		_alert_icon.scale = Vector2.ZERO
		var tween: Tween = _alert_icon.create_tween()
		tween.tween_property(_alert_icon, "scale", Vector2(ArtLibrary.ART_SCALE, ArtLibrary.ART_SCALE), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_set_facing(from.x - position.x)
	_timer = ALERT_HOLD_SECONDS


## Bị săn trúng: ngất, sao quay, rồi biến mất. Trả về false nếu đã bị ai săn rồi.
func knock_out() -> bool:
	if not is_huntable():
		return false
	state = State.KNOCKED
	_alert_icon.visible = false
	_timer = KNOCKED_SECONDS
	_body.rotation = 0.0
	var tween: Tween = _body.create_tween()
	tween.tween_property(_body, "rotation", -PI * 0.5 * _facing, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	return true


func _process(delta: float) -> void:
	_time += delta
	_timer -= delta
	match state:
		State.GRAZE:
			# Cúi đầu gặm cỏ: nghiêng nhẹ ra trước theo nhịp.
			_body.rotation = 0.06 * _facing * (0.5 + 0.5 * sin(_time * 2.0))
			_body.position.y = 0.0
			if _timer <= 0.0:
				_wander()
		State.WALK:
			_body.rotation = 0.0
			_body.position.y = -absf(sin(_time * 9.0)) * WALK_BOB
			_follow_path(delta)
		State.ALERT:
			_body.rotation = 0.0
			_body.position.y = 0.0
			_alert_icon.position.y = ALERT_ICON_OFFSET.y - absf(sin(_time * 8.0)) * 3.0
			if _timer <= 0.0:
				_alert_icon.visible = false
				_graze()
		State.KNOCKED:
			_update_stars(true)
			# Không ai tới vác (thợ săn bị ngắt) thì tự "bụp" biến mất như cũ.
			if _timer <= -Balance.HUNT_PICKUP_SECONDS * 3.0:
				_vanish()
		State.GONE:
			if _timer <= 0.0:
				_respawn()


func _graze() -> void:
	state = State.GRAZE
	_timer = randf_range(Balance.ANIMAL_GRAZE_MIN, Balance.ANIMAL_GRAZE_MAX)


func _wander() -> void:
	var from_cell: Vector2i = current_cell()
	var reach: int = Balance.ANIMAL_WANDER_CELLS
	for attempt: int in MAX_WANDER_TRIES:
		var cell: Vector2i = from_cell + Vector2i(randi_range(-reach, reach), randi_range(-reach, reach))
		if cell == from_cell or not _world.map_data.meadow_rect.has_point(cell) or _world.grid.is_blocked(cell):
			continue
		var points: PackedVector2Array = _world.grid.find_path(from_cell, cell)
		if points.size() < 2:
			continue
		_path = points
		_path_index = 1
		state = State.WALK
		return
	_graze()


func _follow_path(delta: float) -> void:
	if _path_index >= _path.size():
		_graze()
		return
	var target: Vector2 = _path[_path_index]
	var to_target: Vector2 = target - position
	var step: float = Balance.ANIMAL_WALK_SPEED * delta
	if absf(to_target.x) > 0.5:
		_set_facing(to_target.x)
	if to_target.length() <= step:
		position = target
		_path_index += 1
	else:
		position += to_target.normalized() * step


func _vanish() -> void:
	EventBus.work_impact.emit(position + Vector2(0, -20), JobDefs.IMPACT_POOF)
	_update_stars(false)
	visible = false
	state = State.GONE
	_timer = Balance.ANIMAL_RESPAWN_SECONDS


# Con mới xuất hiện ở một chỗ trống ngẫu nhiên trên đồng cỏ.
func _respawn() -> void:
	var cell: Vector2i = _world.finder.random_meadow_cell()
	if cell == World.INVALID_CELL:
		_timer = Balance.ANIMAL_GRAZE_MAX
		return
	position = WorldGrid.cell_to_world(cell)
	_body.rotation = 0.0
	visible = true
	scale = Vector2(0.2, 0.2)
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_graze()


func _update_stars(on: bool) -> void:
	for i: int in _stars.size():
		var star: Sprite2D = _stars[i]
		star.visible = on
		if on:
			var angle: float = _time * STAR_SPEED + TAU * i / _stars.size()
			star.position = Vector2(cos(angle) * STAR_RADIUS.x, sin(angle) * STAR_RADIUS.y - 30.0)


func _set_facing(direction: float) -> void:
	if absf(direction) < 0.01:
		return
	_facing = signf(direction)
	_body.scale.x = _facing
