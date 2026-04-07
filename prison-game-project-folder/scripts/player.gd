extends CharacterBody2D

const SPAWN_POINTS = [
	Vector2i(50, 78),
	Vector2i(56, 63),
	Vector2i(23, 72),
	Vector2i(5, 78),
]

const TILE_SIZE = 16
const INITIAL_DELAY = 0.25
const REPEAT_RATE   = 0.1

@export var walls: TileMapLayer
@export var obstacles: TileMapLayer

var _move_timer: float = 0.0
var _initial_moved: bool = false
var _last_dir: Vector2i = Vector2i.ZERO

func _ready() -> void:
	if walls == null:
		push_error("Player: Walls TileMapLayer not assigned!")
		return
	randomize()
	var spawn = SPAWN_POINTS[randi() % SPAWN_POINTS.size()]
	global_position = walls.to_global(walls.map_to_local(spawn))
	_setup_camera()
	$FogOfWar.recompute(spawn)

func _setup_camera() -> void:
	var cam = $Camera2D
	var vp = get_viewport_rect().size
	var zoom_val = min(vp.x, vp.y) / (8.0 * 2.0 * TILE_SIZE)
	cam.zoom = Vector2(zoom_val, zoom_val)

func _get_dir() -> Vector2i:
	if Input.is_key_pressed(KEY_UP):    return Vector2i(0, -1)
	if Input.is_key_pressed(KEY_DOWN):  return Vector2i(0, 1)
	if Input.is_key_pressed(KEY_LEFT):  return Vector2i(-1, 0)
	if Input.is_key_pressed(KEY_RIGHT): return Vector2i(1, 0)
	return Vector2i.ZERO

func _process(delta: float) -> void:
	var dir = _get_dir()

	if dir == Vector2i.ZERO:
		_last_dir = Vector2i.ZERO
		_move_timer = 0.0
		_initial_moved = false
		return

	if dir != _last_dir:
		_last_dir = dir
		_move_timer = 0.0
		_initial_moved = false
		_try_move(dir)
		return

	_move_timer += delta
	var threshold = INITIAL_DELAY if not _initial_moved else REPEAT_RATE
	if _move_timer >= threshold:
		_initial_moved = true
		_move_timer = 0.0
		_try_move(dir)

func _try_move(dir: Vector2i) -> void:
	var target_global = global_position + Vector2(dir) * TILE_SIZE
	var target_tile = walls.local_to_map(walls.to_local(target_global))
	var wall_stuck = walls.get_cell_source_id(target_tile) != -1
	var obstacle_stuck = obstacles != null and obstacles.get_cell_source_id(target_tile) != -1
	if wall_stuck or obstacle_stuck:
		return
	global_position = target_global
	$Sprite2D.rotation = Vector2(dir).angle()
	$FogOfWar.recompute(walls.local_to_map(walls.to_local(global_position)))
	
	if walls.local_to_map(walls.to_local(global_position)).y <= 4:
		GameManager.finish_level()
