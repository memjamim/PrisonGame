extends Node2D

const TILE_SIZE = 16
const BASE_SEED = 42
const ZONE_SIZE = 16
const LANDMARK_SCALE = 3

@export var export_mode: bool = false

func _ready() -> void:
	if not export_mode:
		return
	get_node("Player").visible = false
	get_node("DebugLayer").visible = false
	get_node("DebugLayer/TileCoordLabel").queue_free()
	_export_map()

func _add_landmarks(target: Node, walls: TileMapLayer) -> void:
	var textures: Array = []
	var dir = DirAccess.open("res://assets/scaled/")
	if dir == null:
		push_error("Could not open res://assets/scaled/")
		return
	dir.list_dir_begin()
	var fname = dir.get_next()
	while fname != "":
		if fname.ends_with(".png"):
			textures.append(load("res://assets/scaled/" + fname))
		fname = dir.get_next()
	if textures.is_empty():
		push_error("No textures found")
		return

	var zones: Dictionary = {}
	for tile in walls.get_used_cells():
		var zone = Vector2i(floori(float(tile.x) / ZONE_SIZE), floori(float(tile.y) / ZONE_SIZE))
		if not zones.has(zone):
			zones[zone] = []
		zones[zone].append(tile)

	var zone_rng = RandomNumberGenerator.new()
	var tile_rng = RandomNumberGenerator.new()
	var shader = preload("res://shaders/graffiti_hue.gdshader")

	for zone in zones.keys():
		var tiles = zones[zone]
		if tiles.is_empty():
			continue

		zone_rng.seed = BASE_SEED + hash(zone)
		var tex_idx = zone_rng.randi() % textures.size()
		var hue = zone_rng.randf()

		tile_rng.seed = hash(zone) ^ 0xDEADBEEF
		var landmark_tile = tiles[tile_rng.randi() % tiles.size()]

		var sprite = Sprite2D.new()
		sprite.texture = textures[tex_idx]
		sprite.scale = Vector2(LANDMARK_SCALE, LANDMARK_SCALE)
		sprite.position = walls.to_global(walls.map_to_local(landmark_tile))
		sprite.z_index = 10

		var mat = ShaderMaterial.new()
		mat.shader = shader
		mat.set_shader_parameter("hue_shift", hue)
		sprite.material = mat

		target.add_child(sprite)  # <- was add_child(sprite), now goes to correct node


func _export_map() -> void:
	var walls: TileMapLayer = get_node("Walls")
	var rect = walls.get_used_rect()
	var px_size = Vector2i(rect.size.x * TILE_SIZE, rect.size.y * TILE_SIZE)

	var subvp = SubViewport.new()
	subvp.size = px_size
	subvp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	subvp.transparent_bg = false
	subvp.disable_3d = true
	add_child(subvp)

	# fresh maze instance inside the subviewport
	var maze2 = load("res://scenes/maze1.tscn").instantiate()
	maze2.export_mode = false 
	subvp.add_child(maze2)
	maze2.get_node("Player").visible = false
	maze2.get_node("Player/Camera2D").enabled = false 
	maze2.get_node("DebugLayer").visible = false
	maze2.get_node("Obstacles").visible = false

	var w2: TileMapLayer = maze2.get_node("Walls")

	var cam = Camera2D.new()
	maze2.add_child(cam)
	var top_left = w2.to_global(w2.map_to_local(rect.position))
	cam.global_position = top_left + Vector2(px_size) / 2.0
	cam.zoom = Vector2.ONE
	cam.make_current()

	_add_landmarks(maze2, w2)

	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw

	var img = subvp.get_texture().get_image()
	img.save_png("user://maze_map.png")
	print("Saved: ", OS.get_user_data_dir(), "/maze_map.png")
	get_tree().quit()
