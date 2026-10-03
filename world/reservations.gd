class_name Reservations
extends RefCounted
## Đặt chỗ: một chỗ ngủ, một suất ăn, một mỏ tài nguyên… chỉ nhận đủ số người cho phép (mặc
## định một người; bụi quả to, bãi sỏi… cho vài người làm chung), tránh cả làng ùa vào một chỗ.
## Key là bất cứ thứ gì định danh được chỗ đó (node, ô lưới…).

## key → danh sách instance id người đang giữ chỗ.
var _owners: Dictionary = {}


## Giữ chỗ cho `owner`; `capacity` = tối đa mấy người cùng giữ. false nếu đã đủ người.
func reserve(key: Variant, owner: Object, capacity: int = 1) -> bool:
	var owner_id: int = owner.get_instance_id()
	var holders: Array = _owners.get(key, [])
	if holders.has(owner_id):
		return true
	if holders.size() >= capacity:
		return false
	holders.append(owner_id)
	_owners[key] = holders
	return true


func release(key: Variant, owner: Object) -> void:
	if key == null or not _owners.has(key):
		return
	var holders: Array = _owners[key]
	holders.erase(owner.get_instance_id())
	if holders.is_empty():
		_owners.erase(key)


## Chỗ này đã đủ người (không tính `owner`) chưa.
func is_taken_by_other(key: Variant, owner: Object, capacity: int = 1) -> bool:
	var holders: Array = _owners.get(key, [])
	var others: int = holders.size() - (1 if holders.has(owner.get_instance_id()) else 0)
	return others >= capacity


func release_all(owner: Object) -> void:
	var owner_id: int = owner.get_instance_id()
	for key: Variant in _owners.keys():
		var holders: Array = _owners[key]
		holders.erase(owner_id)
		if holders.is_empty():
			_owners.erase(key)
