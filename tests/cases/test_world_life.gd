extends TestCase
## Thế giới sinh động: gió chạy, cá bơi mà không lên bờ, lửa đổi khung hình.

const WORLD_SCENE: PackedScene = preload("res://world/world.tscn")
const SIMULATED_FRAMES: int = 240


func test_wind_fish_and_flame() -> void:
	var world: World = WORLD_SCENE.instantiate()
	host.add_child(world)
	world.build(42)
	var data: MapData = world.map_data
	var water_life: WaterLife = world.get_water_life()
	check(water_life.fish_count() >= 2, "Hồ phải có ít nhất 2 con cá")

	# Tua nhanh để cá kịp bơi nhiều chặng và gợn sóng kịp sinh ra.
	Engine.time_scale = 4.0
	var flame_textures: Dictionary[Texture2D, bool] = {}
	var flame: Sprite2D = _find_campfire(world).get_node("ExtraSprite")
	for i: int in SIMULATED_FRAMES:
		await host.get_tree().process_frame
		flame_textures[flame.texture] = true
		for child: Node in water_life.get_children():
			if child is Fish:
				var cell: Vector2i = WorldGrid.world_to_cell((child as Fish).position)
				if not data.is_water(cell):
					failures.append("Cá bơi lên bờ ở ô %s" % cell)
					break
	Engine.time_scale = 1.0

	check(world.get_wind().time > 0.0, "Đồng hồ gió phải chạy")
	check(water_life.get_child_count() > water_life.fish_count(), "Phải có gợn sóng trên mặt hồ")
	check(flame_textures.size() >= 3, "Ngọn lửa phải đổi qua nhiều khung hình")
	world.queue_free()
	await host.get_tree().process_frame


func _find_campfire(world: World) -> Building:
	for child: Node in world.get_node("Entities").get_children():
		if child is Building and (child as Building).building_id == &"campfire":
			return child
	return null
