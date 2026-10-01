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
var _held_item: Sprite2D


func _init() -> void:
	_build_nodes()


## Dựng ngoại hình từ chỉ số trong VillagerData.appearance.
func setup(appearance: Dictionary) -> void:
	var skin: Color = VillagerPalette.pick(VillagerPalette.SKIN, appearance.get("skin", 0))
	var back_skin: Color = skin * Color(BACK_LIMB_SHADE, BACK_LIMB_SHADE, BACK_LIMB_SHADE)
	_set_part(_head_sprite, "villager/head_%02d" % (int(appearance.get("head", 0)) + 1), skin)
	_set_part(_hair, "villager/hair_%02d" % (int(appearance.get("hair", 0)) + 1),
		VillagerPalette.pick(VillagerPalette.HAIR, appearance.get("hair_color", 0)))
	_set_part(_torso, "villager/body_%02d" % (int(appearance.get("body", 0)) + 1),
		VillagerPalette.pick(VillagerPalette.FUR, appearance.get("fur", 0)))
	_set_part(_arm_front, "villager/arm", skin)
	_set_part(_arm_back, "villager/arm", back_skin)
	_set_part(_leg_front, "villager/leg", skin)
	_set_part(_leg_back, "villager/leg", back_skin)
	var accessory: int = appearance.get("accessory", -1)
	_accessory.visible = accessory >= 0
	if _accessory.visible:
		_set_part(_accessory, "villager/accessory_%02d" % (accessory + 1), Color.WHITE)
	for face_name: String in [FACE_HAPPY, FACE_SAD, FACE_BLINK, FACE_SLEEP, FACE_SURPRISED]:
		_faces[face_name] = ArtLibrary.get_texture("villager/face_" + face_name)
	_set_part(_face, "villager/face_" + FACE_HAPPY, Color.WHITE)
	_blink_timer = randf_range(BLINK_MIN, BLINK_MAX)


func play(anim_name: StringName) -> void:
	if anim == anim_name:
		return
	anim = anim_name
	_anim_time = 0.0


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


## Cầm một vật trên tay (key hình), "" để bỏ xuống.
func set_held_item(key: String) -> void:
	_held_item.visible = not key.is_empty()
	if _held_item.visible:
		ArtLibrary.setup_sprite(_held_item, key)
		_held_item.scale *= HELD_ITEM_SCALE


func _set_squash(value: float) -> void:
	_squash = value


func _process(delta: float) -> void:
	_anim_time += delta
	if anim == ANIM_WALK or anim == ANIM_RUN:
		_walk_phase += move_speed * delta * WALK_PHASE_PER_PIXEL
	_update_blink(delta)
	_reset_pose()
	_animate(_anim_time)
	_pose.scale = _pose_scale * Vector2(1.0 + _squash, 1.0 - _squash)
	_face.texture = _faces.get(_current_face(), _face.texture)
	_place_held_item()


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
		ANIM_SLEEP:
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
		_:
			_breathe(breathe)


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
		ANIM_RUB_EYES, ANIM_SCRATCH:
			return FACE_BLINK
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


func _set_part(sprite: Sprite2D, key: String, color: Color) -> void:
	ArtLibrary.setup_sprite(sprite, key)
	sprite.modulate = color


func _build_nodes() -> void:
	_shadow = Sprite2D.new()
	add_child(_shadow)
	ArtLibrary.setup_sprite(_shadow, "villager/shadow")
	_flip = Node2D.new()
	add_child(_flip)
	_pose = Node2D.new()
	_flip.add_child(_pose)
	# Thứ tự vẽ từ sau ra trước theo spec.
	_leg_back = _add_sprite(_pose, HIP_BACK)
	_arm_back = _add_sprite(_pose, SHOULDER_BACK)
	_torso = _add_sprite(_pose, TORSO_BOTTOM)
	_leg_front = _add_sprite(_pose, HIP_FRONT)
	_head = Node2D.new()
	_head.position = NECK
	_pose.add_child(_head)
	_head_sprite = _add_sprite(_head, Vector2.ZERO)
	_face = _add_sprite(_head, Vector2.ZERO)
	_hair = _add_sprite(_head, Vector2.ZERO)
	_accessory = _add_sprite(_head, Vector2.ZERO)
	_arm_front = _add_sprite(_pose, SHOULDER_FRONT)
	_held_item = _add_sprite(_pose, SHOULDER_FRONT)
	_held_item.visible = false


func _add_sprite(parent: Node, pos: Vector2) -> Sprite2D:
	var sprite: Sprite2D = Sprite2D.new()
	sprite.position = pos
	parent.add_child(sprite)
	return sprite
