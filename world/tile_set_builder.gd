class_name TileSetBuilder
## Dựng TileSet bằng code từ các hình trong ArtLibrary (mỗi hình một nguồn),
## nên thay art cho nền/nước cũng chỉ cần bỏ file cùng tên vào assets/art/.


## Kích thước một ô trong ảnh art (2× so với ô trên màn hình).
static func art_tile_size() -> Vector2i:
	var side: int = roundi(Balance.TILE_SIZE / ArtLibrary.ART_SCALE)
	return Vector2i(side, side)


## `keys_by_source`: id nguồn → key hình. Mỗi hình đúng một ô.
static func build(keys_by_source: Dictionary[int, String]) -> TileSet:
	var tile_set: TileSet = TileSet.new()
	tile_set.tile_size = art_tile_size()
	for source_id: int in keys_by_source:
		var source: TileSetAtlasSource = TileSetAtlasSource.new()
		source.texture = ArtLibrary.get_texture(keys_by_source[source_id])
		source.texture_region_size = art_tile_size()
		source.create_tile(Vector2i.ZERO)
		tile_set.add_source(source, source_id)
	return tile_set
