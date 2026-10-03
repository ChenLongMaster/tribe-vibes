class_name DecorLayer
extends Node2D
## Cây cỏ trang trí phủ kín map (hoa, khóm cỏ, cỏ cao, dương xỉ, bụi lá, lau sậy, nấm). Hàng
## nghìn cái nên KHÔNG dùng mỗi cái một Sprite2D: mỗi loại hình là một MultiMeshInstance2D (một
## lệnh vẽ cho mọi cái cùng hình), lay theo gió bằng material chung. Nằm dưới thổ dân, không
## chạm được. Chỗ đặt công trình (sân) thì giấu đi những cái nằm trong đó.

## {mesh: MultiMesh, index: int} theo ô — để giấu khi có sân đè lên.
var _by_cell: Dictionary[Vector2i, Array] = {}
var _meshes: Dictionary[String, MultiMeshInstance2D] = {}
## Ô đã giấu trang trí (hoa ở đó không còn để hái).
var _hidden: Dictionary[Vector2i, bool] = {}


## `items`: MapData.decor (kind, variant, pos). `key_of` trả key hình cho một item.
func build(items: Array[Dictionary], key_of: Callable, sway: Material) -> void:
	var groups: Dictionary[String, Array] = {}
	for item: Dictionary in items:
		var key: String = key_of.call(item)
		if not groups.has(key):
			groups[key] = []
		groups[key].append(item)
	for key: String in groups:
		var texture: Texture2D = ArtLibrary.get_texture(key)
		if texture == null:
			continue
		var list: Array = groups[key]
		var multimesh: MultiMesh = MultiMesh.new()
		multimesh.transform_format = MultiMesh.TRANSFORM_2D
		multimesh.use_colors = true
		multimesh.mesh = _quad(texture, ArtSpecs.pivot(key))
		multimesh.instance_count = list.size()
		for index: int in list.size():
			var item: Dictionary = list[index]
			var pos: Vector2 = item["pos"]
			var flip: float = -1.0 if int(pos.x * 7.0 + pos.y * 3.0) % 2 == 0 else 1.0
			var size: float = ArtLibrary.ART_SCALE * float(item.get("scale", 1.0))
			multimesh.set_instance_transform_2d(index, Transform2D(0.0, Vector2(size * flip, size), 0.0, pos))
			# Màu lệch nhẹ từng cái cho đỡ giống hệt nhau.
			var shade: float = 0.9 + fposmod(pos.x * 0.013 + pos.y * 0.029, 0.18)
			multimesh.set_instance_color(index, Color(shade, shade, shade))
			var cell: Vector2i = WorldGrid.world_to_cell(pos)
			if not _by_cell.has(cell):
				_by_cell[cell] = []
			_by_cell[cell].append({"mesh": multimesh, "index": index})
		var instance: MultiMeshInstance2D = MultiMeshInstance2D.new()
		instance.multimesh = multimesh
		instance.texture = texture
		instance.material = sway
		instance.name = key.get_file()
		add_child(instance)
		_meshes[key] = instance


## Giấu trang trí trong các ô này (vd sân công trình mới).
func hide_cells(cells: Array[Vector2i]) -> void:
	for cell: Vector2i in cells:
		if _hidden.has(cell):
			continue
		_hidden[cell] = true
		for entry: Dictionary in _by_cell.get(cell, []):
			(entry["mesh"] as MultiMesh).set_instance_transform_2d(int(entry["index"]), Transform2D(0.0, Vector2.ZERO, 0.0, Vector2.ZERO))


func is_hidden(cell: Vector2i) -> bool:
	return _hidden.has(cell)


func mesh_count() -> int:
	return _meshes.size()


# Hình chữ nhật đúng cỡ texture, gốc ở điểm neo (chân) — như Sprite2D sau setup_sprite.
static func _quad(texture: Texture2D, pivot: Vector2) -> ArrayMesh:
	var size: Vector2 = texture.get_size()
	var origin: Vector2 = -size * pivot
	var vertices: PackedVector2Array = PackedVector2Array([
		origin, origin + Vector2(size.x, 0), origin + size, origin + Vector2(0, size.y)])
	var uvs: PackedVector2Array = PackedVector2Array([Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)])
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = PackedInt32Array([0, 1, 2, 0, 2, 3])
	var mesh: ArrayMesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh
