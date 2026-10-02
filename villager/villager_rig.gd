class_name VillagerRig
extends Node2D
## Khung cutout của thổ dân: các Sprite2D ghép lại, hoạt họa hoàn toàn bằng code
## (sin/cos + tween), không vẽ từng frame. Gốc toạ độ = chỗ chân chạm đất.
##
## Cấu trúc: Rig → Flip (lật trái/phải) → Pose (nảy, nghiêng, co giãn) → các bộ phận.
## Mọi xoay đặt bên trong Flip nên khi lật hướng, động tác tự lật theo.

const ANIM_IDLE: StringName = &"idle"
const ANIM_WALK: StringName = &"walk"
const ANIM_RUN: StringName = &"run"
const ANIM_GATHER: StringName = &"gather"
const ANIM_EAT: StringName = &"eat"
const ANIM_SLEEP: StringName = &"sleep"
const ANIM_TALK: StringName = &"talk"
const ANIM_SCRATCH: StringName = &"scratch"
const ANIM_SIT: StringName = &"sit"
const ANIM_YAWN: StringName = &"yawn"
const ANIM_STRETCH: StringName = &"stretch"
const ANIM_RUB_EYES: StringName = &"rub_eyes"
const ANIM_CELEBRATE: StringName = &"celebrate"
const ANIM_HOLD: StringName = &"hold"
const ANIM_KNOCKED_OUT: StringName = &"knocked_out"
const ANIM_CHOP: StringName = &"chop"
const ANIM_MINE: StringName = &"mine"
const ANIM_FISH: StringName = &"fish"
const ANIM_COOK: StringName = &"cook"
const ANIM_ATTACK: StringName = &"attack"
const ANIM_STRIKE: StringName = &"strike"
const ANIM_POUT: StringName = &"pout"
## Gõ búa (xây nhà, rèn): nhịp nhanh, nhẹ hơn đập đá.
const ANIM_HAMMER: StringName = &"hammer"

## Thư mục mảnh trong ArtLibrary — ID mảnh ghép sau thành key hình, vd "villager/hair_03".
const PIECE_DIR: String = "villager/"

const FACE_HAPPY: String = "happy"
const FACE_SAD: String = "sad"
const FACE_BLINK: String = "blink"
const FACE_SLEEP: String = "sleep"
const FACE_SURPRISED: String = "surprised"

## Vị trí khớp (px hiển thị, gốc = chân). Đổi ở đây nếu art thật có tỉ lệ khác.
const HIP_BACK: Vector2 = Vector2(-4, -14)
const HIP_FRONT: Vector2 = Vector2(5, -14)
const SHOULDER_BACK: Vector2 = Vector2(-9, -29)
const SHOULDER_FRONT: Vector2 = Vector2(9, -29)
const TORSO_BOTTOM: Vector2 = Vector2(0, -9)
const NECK: Vector2 = Vector2(0, -31)
const HAND_DISTANCE: float = 13.0
const BACK_LIMB_SHADE: float = 0.85 # tay chân phía sau tối hơn chút cho có chiều sâu
const HELD_ITEM_SCALE: float = 0.7
## Đồ khuân giơ trên đầu: mép dưới của hình đặt sát đỉnh đầu (y so với chân).
const CARRY_HEAD_TOP: float = -65.0
const CARRY_ITEM_SCALE: float = 1.1
## Xác thú vác chổng vó trên đầu — hình thú to nên thu nhỏ lại. Hình thú có khoảng trống
## phía trên lưng, lật ngược thì khoảng đó nằm dưới — hạ xuống cho lưng chạm tay.
const CARCASS_SCALE: float = 0.85
const CARCASS_SINK: float = 24.0
## Tấm biển (px hiển thị): ngồi thì hai tay giơ lên trên đầu (gốc cán ở hai bàn tay); đứng
## thì cắm xuống đất ngay trước mặt, một tay vịn. Icon vẽ giữa mặt biển.
const SIGN_RAISED_POS: Vector2 = Vector2(0, -50)
const SIGN_PLANTED_POS: Vector2 = Vector2(21, 3)
const SIGN_PLANTED_ARM: float = -1.25
const SIGN_ICON_POS: Vector2 = Vector2(0, -31)
const SIGN_ICON_SCALE: float = 1.1
## Mũ công trường của thợ xây: đội trên tóc (toạ độ trong khung đầu, gốc ở cổ).
const HAT_POS: Vector2 = Vector2.ZERO
const HAT_KEY: String = "villager/hard_hat"
## Đồ nghề đeo sau lưng khi không dùng (giáo, rìu, cuốc), xiên chéo qua lưng.
const BACK_ITEM_POS: Vector2 = Vector2(-7, -21)
const BACK_ITEM_ROTATION: float = -0.5
## Câu cá: quăng cần ra trong FISH_CAST_SECONDS đầu, phao nổi trước mặt.
const FISH_CAST_SECONDS: float = 0.7
const FISH_BOBBER_POS: Vector2 = Vector2(46, 14)
## Đầu cần câu tính từ tâm hình `props/fishing_rod` (px của file hình).
const ROD_TIP_TEXTURE_OFFSET: Vector2 = Vector2(16, -18)
## Ngồi (dỗi, phơi nắng) thì giơ biển; đi thì cất biển; còn lại cắm biển xuống đất.
const SEATED_ANIMS: Array[StringName] = [ANIM_SIT, ANIM_POUT]

enum SignPose { HIDDEN, PLANTED, RAISED }
## Đồ nghề nghiêng theo tay (rad) — hình rìu, cuốc vẽ chéo nên xoay thêm cho thẳng tay.
const TOOL_TILT: float = 0.6
## Nhịp vung (giây) của chặt, đập, vung giáo — khớp "swing" trong data/jobs.gd.
const CHOP_PERIOD: float = 0.9
const MINE_PERIOD: float = 0.8
const ATTACK_PERIOD: float = 0.55
const HAMMER_PERIOD: float = 0.6
const THROW_SECONDS: float = 0.7

const BLINK_MIN: float = 2.0 # giây
const BLINK_MAX: float = 5.0
const BLINK_DURATION: float = 0.12
const WALK_PHASE_PER_PIXEL: float = 0.11

## Hướng nhìn: 1 = phải, -1 = trái.
var facing: float = 1.0
## Tốc độ di chuyển hiện tại (px/giây) — chân bước nhanh chậm theo.
var move_speed: float = 0.0
var anim: StringName = ANIM_IDLE

var _anim_time: float = 0.0
var _walk_phase: float = 0.0
var _squash: float = 0.0
var _pose_scale: Vector2 = Vector2.ONE
var _base_face: String = FACE_HAPPY
var _flash_face: String = ""
var _flash_time: float = 0.0
var _blink_timer: float = 3.0
var _blink_time: float = 0.0
var _faces: Dictionary[String, Texture2D] = {}

var _shadow: Sprite2D
var _flip: Node2D
var _pose: Node2D
var _leg_back: Sprite2D
var _leg_front: Sprite2D
var _arm_back: Sprite2D
var _arm_front: Sprite2D
var _torso: Sprite2D
var _head: Node2D
var _head_sprite: Sprite2D
var _face: Sprite2D
var _hair: Sprite2D
var _accessory: Sprite2D
var _hat: Sprite2D
var _held_item: Sprite2D
var _held_is_tool: bool = false
var _held_key: String = ""
var _back_item: Sprite2D
var _back_key: String = ""
var _carry_item: Sprite2D
var _fishing_line: FishingLine
var _sign_pose: SignPose = SignPose.HIDDEN
var _sign: Node2D
var _sign_icon: Sprite2D
var _sign_cross: Sprite2D
var _sign_wanted: bool = false
var _sign_time: float = 0.0


func _init() -> void:
	_build_nodes()


## Dựng ngoại hình từ ID mảnh và mã màu trong VillagerData.appearance.
func setup(data: VillagerData) -> void:
	var skin: Color = Color(data.look("skin"))
	var back_skin: Color = skin * Color(BACK_LIMB_SHADE, BACK_LIMB_SHADE, BACK_LIMB_SHADE)
	_set_part(_head_sprite, PIECE_DIR + data.look("head"), skin)
	_set_part(_hair, PIECE_DIR + data.look("hair"), Color(data.look("hair_color")))
	_set_part(_torso, PIECE_DIR + data.look("body"), Color(data.look("fur")))
	_set_part(_arm_front, PIECE_DIR + "arm", skin)
	_set_part(_arm_back, PIECE_DIR + "arm", back_skin)
	_set_part(_leg_front, PIECE_DIR + "leg", skin)
	_set_part(_leg_back, PIECE_DIR + "leg", back_skin)
	var accessory: String = data.look("accessory")
	_accessory.visible = not accessory.is_empty()
	if _accessory.visible:
		_set_part(_accessory, PIECE_DIR + accessory, Color.WHITE)
	# Mỗi bộ mặt (vd "face_01") có đủ các biểu cảm: face_01_happy, face_01_sad…
	var face_set: String = PIECE_DIR + data.look("face")
	for face_name: String in [FACE_HAPPY, FACE_SAD, FACE_BLINK, FACE_SLEEP, FACE_SURPRISED]:
		_faces[face_name] = ArtLibrary.get_texture("%s_%s" % [face_set, face_name])
	_set_part(_face, "%s_%s" % [face_set, FACE_HAPPY], Color.WHITE)
	_blink_timer = randf_range(BLINK_MIN, BLINK_MAX)


func play(anim_name: StringName) -> void:
	if anim == anim_name:
		return
	anim = anim_name
	_anim_time = 0.0


## Đang nằm (ngủ, ngất) — bong bóng trên đầu dời xuống theo đầu.
func is_lying() -> bool:
	return anim == ANIM_SLEEP or anim == ANIM_KNOCKED_OUT


func set_facing(direction: float) -> void:
	if absf(direction) < 0.01:
		return
	facing = signf(direction)
	_flip.scale.x = facing


## Mặt nền theo tâm trạng: vui hay buồn.
func set_mood_face(happy: bool) -> void:
	_base_face = FACE_HAPPY if happy else FACE_SAD


## Hiện một nét mặt trong chốc lát (vd ngạc nhiên khi thấy đói).
func flash_face(face_name: String, seconds: float) -> void:
	_flash_face = face_name
	_flash_time = seconds


## Co giãn kiểu hoạt hình (dừng chân, đặt đồ xuống…): dương = bẹt ra, âm = vươn cao.
func squash(amount: float = 0.14, duration: float = 0.25) -> void:
	var tween: Tween = create_tween()
	tween.tween_method(_set_squash, amount, 0.0, duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Cầm một vật trên tay (key hình), "" để bỏ xuống. `is_tool` = đồ nghề (rìu, cuốc…)
## thì nghiêng theo tay khi vung.
func set_held_item(key: String, is_tool: bool = false) -> void:
	_held_item.visible = not key.is_empty()
	_held_is_tool = is_tool
	_held_key = key
	_held_item.rotation = 0.0
	if _held_item.visible:
		ArtLibrary.setup_sprite(_held_item, key)
		_held_item.scale *= HELD_ITEM_SCALE


## Đồ nghề đang giữ mà không cầm trên tay thì đeo sau lưng ("" = không có gì).
func set_back_item(key: String) -> void:
	_back_key = key
	if not key.is_empty():
		ArtLibrary.setup_sprite(_back_item, key)
		_back_item.scale *= HELD_ITEM_SCALE


## Đội / bỏ mũ công trường (thợ xây).
func set_hard_hat(on: bool) -> void:
	if _hat.visible == on:
		return
	_hat.visible = on
	if on:
		ArtLibrary.setup_sprite(_hat, HAT_KEY)
		_hat.position = HAT_POS


func has_hard_hat() -> bool:
	return _hat.visible


## Các mảnh đổ bóng theo mặt trời (không tính bóng elip dưới chân).
func shadow_sources() -> Array[Sprite2D]:
	var result: Array[Sprite2D] = []
	_collect_sprites(_flip, result)
	return result


func _collect_sprites(node: Node, result: Array[Sprite2D]) -> void:
	for child: Node in node.get_children():
		if child is Sprite2D:
			result.append(child as Sprite2D)
		_collect_sprites(child, result)


## Giơ một món đồ trên đầu để khuân (key hình), "" để đặt xuống. Hai tay giơ lên đỡ.
## `upside_down` = vác ngửa (xác thú chổng vó), hình to nên thu nhỏ lại.
func set_carry_item(key: String, upside_down: bool = false) -> void:
	_carry_item.visible = not key.is_empty()
	if not _carry_item.visible:
		return
	ArtLibrary.setup_sprite(_carry_item, key)
	_carry_item.scale *= CARCASS_SCALE if upside_down else CARRY_ITEM_SCALE
	_carry_item.flip_v = upside_down
	# Mép dưới hình (dù lật hay không) đặt sát đỉnh đầu.
	var below_pivot: float = (1.0 - ArtSpecs.pivot(key).y) * _carry_item.texture.get_size().y * _carry_item.scale.y
	_carry_item.position = Vector2(0, CARRY_HEAD_TOP - below_pivot + (CARCASS_SINK if upside_down else 0.0))


func is_carrying() -> bool:
	return _carry_item.visible


## Giơ tấm biển vẽ `icon_key` (có dấu ✕ nếu `crossed`) trong `seconds` giây (INF = tới khi
## lower_sign()). Đang khuân đồ hoặc đang nằm thì tạm giấu biển, xong lại giơ tiếp.
func show_sign(icon_key: String, crossed: bool, seconds: float) -> void:
	ArtLibrary.setup_sprite(_sign_icon, icon_key)
	_sign_icon.scale *= SIGN_ICON_SCALE
	_sign_cross.visible = crossed
	_sign_wanted = true
	_sign_time = seconds
	squash(-0.1)


func lower_sign() -> void:
	_sign_wanted = false


func has_sign() -> bool:
	return _sign.visible


## Biển đang vẽ dấu ✕ ("hết rồi / không làm") hay chỉ vẽ món cần.
func is_sign_crossed() -> bool:
	return _sign_cross.visible


## Biển đang giơ cao trên đầu (lúc ngồi) — bong bóng trên đầu phải nhích lên cho khỏi đè.
func is_sign_raised() -> bool:
	return _sign.visible and _sign_pose == SignPose.RAISED


## Quăng một món đồ (đồ nghề khi đình công): bay vòng lên rồi rơi xuống đất, mờ dần.
func throw_item(key: String) -> void:
	var item: Sprite2D = Sprite2D.new()
	ArtLibrary.setup_sprite(item, key)
	item.scale *= HELD_ITEM_SCALE
	var start: Vector2 = (SHOULDER_FRONT + Vector2(0, -HAND_DISTANCE)) * Vector2(facing, 1)
	item.position = start
	add_child(item)
	var land: Vector2 = Vector2(facing * 46.0, -4.0)
	var peak: Vector2 = Vector2(facing * 24.0, -64.0)
	var tween: Tween = item.create_tween()
	tween.set_parallel(true)
	tween.tween_property(item, "rotation", facing * TAU * 1.5, THROW_SECONDS)
	var fly: Callable = func(t: float) -> void:
		item.position = start.lerp(peak, t).lerp(peak.lerp(land, t), t)
	tween.tween_method(fly, 0.0, 1.0, THROW_SECONDS)
	tween.chain().tween_property(item, "modulate:a", 0.0, 0.6).set_delay(0.6)
	tween.chain().tween_callback(item.queue_free)


func _set_squash(value: float) -> void:
	_squash = value


func _process(delta: float) -> void:
	_anim_time += delta
	if anim == ANIM_WALK or anim == ANIM_RUN:
		_walk_phase += move_speed * delta * WALK_PHASE_PER_PIXEL
	_update_blink(delta)
	if _sign_wanted:
		_sign_time -= delta
		if _sign_time <= 0.0:
			_sign_wanted = false
	_sign_pose = _current_sign_pose()
	_sign.visible = _sign_pose != SignPose.HIDDEN
	_back_item.visible = not _back_key.is_empty() and _back_key != _held_key and not is_lying()
	_reset_pose()
	_animate(_anim_time)
	_pose.scale = _pose_scale * Vector2(1.0 + _squash, 1.0 - _squash)
	_face.texture = _faces.get(_current_face(), _face.texture)
	_place_held_item()
	_place_sign()
	_update_fishing_line()


func _current_sign_pose() -> SignPose:
	if not _sign_wanted or _carry_item.visible or is_lying() or anim == ANIM_WALK or anim == ANIM_RUN:
		return SignPose.HIDDEN
	return SignPose.RAISED if SEATED_ANIMS.has(anim) else SignPose.PLANTED


func _place_sign() -> void:
	match _sign_pose:
		SignPose.RAISED:
			_sign.position = _pose.position + SIGN_RAISED_POS
			_sign.rotation = 0.06 * sin(_anim_time * 5.0)
		SignPose.PLANTED:
			_sign.position = SIGN_PLANTED_POS
			_sign.rotation = 0.0


# Dây câu nối đầu cần tới phao trước mặt (chỉ khi đã quăng cần xong).
func _update_fishing_line() -> void:
	var fishing: bool = anim == ANIM_FISH and _held_item.visible and _anim_time > FISH_CAST_SECONDS
	_fishing_line.visible = fishing
	if not fishing:
		return
	var tip_local: Vector2 = _held_item.position + (ROD_TIP_TEXTURE_OFFSET * _held_item.scale).rotated(_held_item.rotation)
	_fishing_line.tip = _pose.transform * tip_local
	_fishing_line.bobber = FISH_BOBBER_POS + Vector2(0, 1.5 * sin(_anim_time * 2.2))
	_fishing_line.queue_redraw()


func _reset_pose() -> void:
	_pose.position = Vector2.ZERO
	_pose.rotation = 0.0
	_pose_scale = Vector2.ONE
	_leg_back.rotation = 0.0
	_leg_front.rotation = 0.0
	_arm_back.rotation = 0.12
	_arm_front.rotation = -0.12
	_head.position = NECK
	_head.rotation = 0.0
	_head.scale = Vector2.ONE
	_shadow.scale = Vector2(ArtLibrary.ART_SCALE, ArtLibrary.ART_SCALE)


func _animate(t: float) -> void:
	var breathe: float = sin(t * 2.4)
	match anim:
		ANIM_WALK, ANIM_RUN:
			var running: bool = anim == ANIM_RUN
			var swing: float = sin(_walk_phase)
			var amp: float = 0.8 if running else 0.55
			_leg_front.rotation = -swing * amp
			_leg_back.rotation = swing * amp
			_arm_front.rotation = swing * amp * 0.8 - 0.1
			_arm_back.rotation = -swing * amp * 0.8 + 0.1
			_pose.position.y = -absf(cos(_walk_phase)) * (4.0 if running else 2.5)
			_pose.rotation = 0.12 if running else 0.05
			_head.rotation = -0.03 * swing
		ANIM_GATHER:
			var bend: float = 0.5 + 0.5 * sin(t * 3.0)
			_pose.rotation = 0.25 + 0.2 * bend
			_arm_front.rotation = -0.9 - 0.4 * bend
			_arm_back.rotation = -0.5
			_head.rotation = 0.1
		ANIM_EAT:
			_arm_front.rotation = -2.3 + 0.25 * sin(t * 9.0)
			_head.scale.y = 1.0 + 0.035 * sin(t * 18.0)
			_breathe(breathe)
		ANIM_SLEEP, ANIM_KNOCKED_OUT:
			# Nằm ngửa, đầu quay ra sau; nhấc lên để nửa người không chìm xuống đất.
			_pose.rotation = -1.5
			_pose.position = Vector2(30, -10)
			_pose_scale.x = 1.0 + 0.03 * sin(t * 1.6)
			_shadow.scale.x *= 1.9
		ANIM_TALK:
			_arm_front.rotation = -0.7 + 0.5 * sin(t * 5.0)
			_head.rotation = 0.08 * sin(t * 6.5)
			_pose.position.y = -absf(sin(t * 6.5)) * 1.2
			_breathe(breathe)
		ANIM_SCRATCH:
			_arm_back.rotation = 0.9 + 0.35 * sin(t * 16.0)
			_pose.position.x = 1.5 * sin(t * 16.0)
			_head.rotation = -0.08
		ANIM_SIT:
			_pose.position.y = 7.0
			_leg_front.rotation = -1.35
			_leg_back.rotation = -1.25
			_arm_front.rotation = -0.3
			_arm_back.rotation = -0.2
			_breathe(breathe)
		ANIM_POUT:
			# Ngồi bệt nũng nịu: đá chân thay nhau, người đung đưa, đầu nghiêng cúi.
			var kick: float = sin(t * 5.0)
			_pose.position.y = 7.0
			_leg_front.rotation = -1.35 + 0.3 * maxf(kick, 0.0)
			_leg_back.rotation = -1.25 + 0.3 * maxf(-kick, 0.0)
			_arm_front.rotation = -0.5 + 0.12 * sin(t * 2.5)
			_arm_back.rotation = -0.3
			_pose.rotation = 0.06 * sin(t * 1.6)
			_head.rotation = 0.18 + 0.06 * sin(t * 1.6)
		ANIM_YAWN, ANIM_STRETCH:
			var reach: float = minf(t * 3.0, 1.0)
			_arm_front.rotation = lerpf(-0.12, -2.9, reach)
			_arm_back.rotation = lerpf(0.12, 2.9, reach)
			_pose_scale.y = 1.0 + 0.06 * reach
			_head.rotation = -0.15 * reach
		ANIM_RUB_EYES:
			_arm_front.rotation = -2.5 + 0.25 * sin(t * 12.0)
			_arm_back.rotation = 2.5 - 0.25 * sin(t * 12.0 + 1.0)
			_head.rotation = 0.05 * sin(t * 6.0)
		ANIM_CELEBRATE:
			var jump: float = absf(sin(t * 6.0))
			_pose.position.y = -jump * 10.0
			_arm_front.rotation = -2.6 + 0.3 * sin(t * 12.0)
			_arm_back.rotation = 2.6 - 0.3 * sin(t * 12.0)
			_shadow.scale *= 1.0 - jump * 0.3
		ANIM_HOLD:
			_arm_front.rotation = -1.1
			_breathe(breathe)
		ANIM_CHOP:
			# Vung rìu: giơ chậm ra sau đầu rồi bổ nhanh về phía trước.
			var swing: float = _swing(t, CHOP_PERIOD)
			_arm_front.rotation = lerpf(-1.0, -3.3, swing)
			_arm_back.rotation = _arm_front.rotation + 0.35
			_pose.rotation = lerpf(0.14, -0.1, swing)
			_head.rotation = lerpf(0.05, -0.08, swing)
		ANIM_MINE:
			# Gõ búa đập đá: hai tay giơ thẳng lên đầu rồi nện xuống, người khom theo.
			var pound: float = _swing(t, MINE_PERIOD)
			_arm_front.rotation = lerpf(-0.7, -3.0, pound)
			_arm_back.rotation = _arm_front.rotation + 0.25
			_pose.rotation = lerpf(0.22, -0.05, pound)
			_pose.position.y = lerpf(1.5, -1.0, pound)
		ANIM_HAMMER:
			# Gõ búa lách cách: tay giơ ngang đầu rồi gõ xuống, người hơi khom.
			var tap: float = _swing(t, HAMMER_PERIOD)
			_arm_front.rotation = lerpf(-0.9, -2.4, tap)
			_arm_back.rotation = -0.6
			_pose.rotation = lerpf(0.16, 0.04, tap)
			_head.rotation = 0.1
		ANIM_ATTACK:
			# Vung giáo nhanh, chồm người tới.
			var jab: float = _swing(t, ATTACK_PERIOD)
			_arm_front.rotation = lerpf(-1.2, -2.9, jab)
			_arm_back.rotation = -0.6
			_pose.rotation = lerpf(0.2, 0.0, jab)
			_pose.position.x = lerpf(3.0, -1.0, jab)
		ANIM_FISH:
			# Quăng cần: giơ cần ra sau đầu rồi vung ra trước. Sau đó chĩa cần ra, thỉnh
			# thoảng giật nhẹ khi cá cắn câu.
			var tug: float = maxf(sin(t * 0.9), 0.0) ** 8.0
			if t < FISH_CAST_SECONDS:
				var cast: float = t / FISH_CAST_SECONDS
				tug = 0.0
				if cast < 0.45:
					_arm_front.rotation = lerpf(-1.35, -2.9, cast / 0.45)
				else:
					_arm_front.rotation = lerpf(-2.9, -1.35, smoothstep(0.45, 1.0, cast))
			else:
				_arm_front.rotation = -1.35 - 0.35 * tug
			_arm_back.rotation = -0.9 - 0.2 * tug
			_pose.rotation = -0.05 * tug
			_breathe(breathe)
		ANIM_COOK:
			# Khuấy nồi: tay quay vòng, người hơi cúi, đầu ngó xuống.
			_arm_front.rotation = -1.0 + 0.35 * sin(t * 7.0)
			_arm_back.rotation = -0.5
			_pose.rotation = 0.12
			_pose.position.y = -absf(sin(t * 7.0)) * 1.0
			_head.rotation = 0.12
		ANIM_STRIKE:
			# Dậm chân giận dỗi: hai chân thay nhau, tay vung loạn xạ, lắc đầu.
			var stomp: float = sin(t * 11.0)
			_leg_front.rotation = 0.5 * maxf(stomp, 0.0)
			_leg_back.rotation = -0.5 * maxf(-stomp, 0.0)
			_arm_front.rotation = -2.5 + 0.5 * sin(t * 14.0)
			_arm_back.rotation = 2.5 - 0.5 * sin(t * 14.0 + 1.3)
			_pose.position.y = -absf(stomp) * 3.0
			_head.rotation = 0.15 * sin(t * 9.0)
		_:
			_breathe(breathe)
	if _carry_item.visible:
		# Khuân đồ: hai tay giơ lên đỡ món đồ trên đầu (chồng lên dáng đi/đứng).
		_arm_front.rotation = -2.75 + 0.06 * sin(t * 6.0)
		_arm_back.rotation = 2.75 - 0.06 * sin(t * 6.0)
	elif _sign_pose == SignPose.RAISED:
		# Ngồi giơ biển: hai tay giơ thẳng lên cầm cán, lắc nhẹ cho người chơi để ý.
		_arm_front.rotation = -2.95 + 0.08 * sin(t * 5.0)
		_arm_back.rotation = 2.95 - 0.08 * sin(t * 5.0)
	elif _sign_pose == SignPose.PLANTED:
		# Đứng cạnh biển cắm dưới đất, một tay vịn mép biển.
		_arm_front.rotation = SIGN_PLANTED_ARM


# Nhịp vung 0..1 trong một chu kỳ: giơ lên từ từ (0 → 1) rồi bổ xuống thật nhanh (1 → 0).
func _swing(t: float, period: float) -> float:
	var phase: float = fmod(t, period) / period
	if phase < 0.72:
		return smoothstep(0.0, 0.72, phase)
	return 1.0 - smoothstep(0.72, 0.82, phase)


func _breathe(breathe: float) -> void:
	_pose_scale.y *= 1.0 + 0.02 * breathe
	_head.position.y += 0.6 * breathe
	_arm_front.rotation += 0.04 * breathe
	_arm_back.rotation -= 0.04 * breathe


func _current_face() -> String:
	if _flash_time > 0.0:
		return _flash_face
	match anim:
		ANIM_SLEEP:
			return FACE_SLEEP
		ANIM_YAWN:
			return FACE_SURPRISED
		ANIM_RUB_EYES, ANIM_SCRATCH, ANIM_KNOCKED_OUT:
			return FACE_BLINK
		ANIM_STRIKE, ANIM_POUT:
			return FACE_SAD
		ANIM_CELEBRATE, ANIM_EAT:
			return FACE_HAPPY
	if _blink_time > 0.0:
		return FACE_BLINK
	return _base_face


func _update_blink(delta: float) -> void:
	_flash_time -= delta
	_blink_time -= delta
	_blink_timer -= delta
	if _blink_timer <= 0.0:
		_blink_timer = randf_range(BLINK_MIN, BLINK_MAX)
		_blink_time = BLINK_DURATION


func _place_held_item() -> void:
	if _held_item.visible:
		_held_item.position = SHOULDER_FRONT + Vector2(0, HAND_DISTANCE).rotated(_arm_front.rotation)
		if _held_is_tool:
			_held_item.rotation = _arm_front.rotation + TOOL_TILT


func _set_part(sprite: Sprite2D, key: String, color: Color) -> void:
	ArtLibrary.setup_sprite(sprite, key)
	sprite.modulate = color


func _build_nodes() -> void:
	_shadow = Sprite2D.new()
	add_child(_shadow)
	ArtLibrary.setup_sprite(_shadow, "villager/shadow")
	_flip = Node2D.new()
	add_child(_flip)
	# Biển vẽ sau người: ngồi giơ biển thì cán nằm sau đầu, đứng thì người đứng trước biển.
	_sign = Node2D.new()
	_sign.visible = false
	_flip.add_child(_sign)
	_pose = Node2D.new()
	_flip.add_child(_pose)
	# Thứ tự vẽ từ sau ra trước theo spec (đồ nghề sau lưng nằm sau thân).
	_leg_back = _add_sprite(_pose, HIP_BACK)
	_arm_back = _add_sprite(_pose, SHOULDER_BACK)
	_back_item = _add_sprite(_pose, BACK_ITEM_POS)
	_back_item.rotation = BACK_ITEM_ROTATION
	_back_item.visible = false
	_torso = _add_sprite(_pose, TORSO_BOTTOM)
	_leg_front = _add_sprite(_pose, HIP_FRONT)
	_head = Node2D.new()
	_head.position = NECK
	_pose.add_child(_head)
	_head_sprite = _add_sprite(_head, Vector2.ZERO)
	_face = _add_sprite(_head, Vector2.ZERO)
	_hair = _add_sprite(_head, Vector2.ZERO)
	_accessory = _add_sprite(_head, Vector2.ZERO)
	_hat = _add_sprite(_head, HAT_POS)
	_hat.visible = false
	_arm_front = _add_sprite(_pose, SHOULDER_FRONT)
	_held_item = _add_sprite(_pose, SHOULDER_FRONT)
	_held_item.visible = false
	_carry_item = _add_sprite(_pose, Vector2(0, CARRY_HEAD_TOP))
	_carry_item.visible = false
	_fishing_line = FishingLine.new()
	_fishing_line.visible = false
	_flip.add_child(_fishing_line)
	ArtLibrary.setup_sprite(_add_sprite(_sign, Vector2.ZERO), "props/sign")
	_sign_icon = _add_sprite(_sign, SIGN_ICON_POS)
	_sign_cross = _add_sprite(_sign, SIGN_ICON_POS)
	ArtLibrary.setup_sprite(_sign_cross, "icons/cross")
	_sign_cross.scale *= SIGN_ICON_SCALE


func _add_sprite(parent: Node, pos: Vector2) -> Sprite2D:
	var sprite: Sprite2D = Sprite2D.new()
	sprite.position = pos
	parent.add_child(sprite)
	return sprite
