class_name ChatSession
extends RefCounted
## Một cuộc tán gẫu giữa hai người. Hai TaskChat cùng giữ một session này để biết
## khi nào bắt đầu nói, ai đang nói, và khi một bên bỏ đi thì bên kia cũng thôi.

var initiator: Villager
var partner: Villager
var talking: bool = false
var ended: bool = false
var talk_left: float = 0.0
## Lượt nói: true = người rủ đang nói.
var initiator_speaking: bool = true


func _init(from: Villager, to: Villager) -> void:
	initiator = from
	partner = to


func other(villager: Villager) -> Villager:
	return partner if villager == initiator else initiator
