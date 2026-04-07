@tool
extends EditorScript

func _run():
	var scene: PackedScene = load("res://scenes/maze1.tscn")
	var instance: Node = scene.instantiate()
	var layer: TileMapLayer = instance.get_node("Walls")

	var tileset: TileSet = layer.tile_set
	var source: TileSetAtlasSource = tileset.get_source(0)
	var size: Vector2i = source.get_atlas_grid_size()
	var zeroed := 0

	for x in size.x:
		for y in size.y:
			var coords := Vector2i(x, y)
			if not source.has_tile(coords):
				continue

			# Get TileData object, then call get_probability()
			var tile_data: TileData = source.get_tile_data(coords, 0)
			if tile_data.get_probability() <= 2.0:
				tile_data.set_probability(0.0)
				zeroed += 1

	var packed := PackedScene.new()
	packed.pack(instance)
	ResourceSaver.save(packed, "res://scenes/maze1.tscn")

	print("Zeroed ", zeroed, " tiles")
	instance.free()
