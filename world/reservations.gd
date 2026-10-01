class_name Reservations
extends RefCounted
## Đặt chỗ: một bụi quả, một chỗ ngủ… chỉ một người nhận, tránh cả làng ùa vào một chỗ.
## Key là bất cứ thứ gì định danh được chỗ đó (node, ô lưới…).

var _owners: Dictionary = {}


func reserve(key: Variant, owner: Object) -> bool:
	var owner_id: int = owner.get_instance_id()
	if _owners.has(key) and _owners[key] != owner_id:
		return false
	_owners[key] = owner_id
	return true


func release(key: Variant, owner: Object) -> void:
	if key != null and _owners.get(key, 0) == owner.get_instance_id():
		_owners.erase(key)


func is_taken_by_other(key: Variant, owner: Object) -> bool:
	return _owners.has(key) and _owners[key] != owner.get_instance_id()


func release_all(owner: Object) -> void:
	var owner_id: int = owner.get_instance_id()
	for key: Variant in _owners.keys():
		if _owners[key] == owner_id:
			_owners.erase(key)
