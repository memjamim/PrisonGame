extends Node2D

const TILE_SIZE = 16
const COVERAGE = 0.15
const ZONE_SIZE = 16
const BASE_SEED = 42

@export var walls: TileMapLayer

var _textures: Array = []

func _ready() -> void:
	_load_textures()
	if _textures.is_empty():
		push_error("GraffitiPlacer: no textures found in res://assets/scaled/")
		return
	_place()

func _load_textures() -> void:
	var dir = DirAccess.open("res://assets/scaled/")
	if dir == null:
		return
	dir.list_dir_begin()
	var fname = dir.get_next()
	while fname != "":
		if fname.ends_with(".png"):
			_textures.append(load("res://assets/scaled/" + fname))
		fname = dir.get_next()

func _place() -> void:
	var rng = RandomNumberGenerator.new()
	
	for tile in walls.get_used_cells():
		var zone = Vector2i(floori(float(tile.x) / ZONE_SIZE), floori(float(tile.y) / ZONE_SIZE))
		
		rng.seed = BASE_SEED + hash(tile)
		if rng.randf() > COVERAGE:
			continue
		
		rng.seed = BASE_SEED + hash(zone)
		var tex_idx = rng.randi() % _textures.size()
		var hue = rng.randf()
		
		var sprite = Sprite2D.new()
		sprite.texture = _textures[tex_idx]
		sprite.position = walls.to_global(walls.map_to_local(tile))
		
		var mat = ShaderMaterial.new()
		mat.shader = preload("res://shaders/graffiti_hue.gdshader")
		mat.set_shader_parameter("hue_shift", hue)
		sprite.material = mat
		
		add_child(sprite)
