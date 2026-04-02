extends Node2D

const TILE_SIZE = 16
const VIS_RADIUS = 6
const DRAW_RADIUS = 15
const FADE_TILES = 3
const ALPHA_NEAR = 0.15   # alpha on the first dark ring right at the edge
const ALPHA_FAR  = 0.98   # alpha at FADE_TILES rings out (and beyond)

@export var walls: TileMapLayer

var _visible: Dictionary = {}
var _fog_dist: Dictionary = {}  # dark tile -> distance from nearest visible tile

func recompute(player_tile: Vector2i) -> void:
	_visible.clear()
	_fog_dist.clear()

	# BFS 1: visible flood fill
	_visible[player_tile] = true
	var queue: Array = [[player_tile, 0]]
	var head = 0
	while head < queue.size():
		var tile: Vector2i = queue[head][0]
		var depth: int = queue[head][1]
		head += 1
		if depth >= VIS_RADIUS:
			continue
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var next = tile + d
			if _visible.has(next):
				continue
			_visible[next] = true
			if walls.get_cell_source_id(next) == -1:
				queue.append([next, depth + 1])

	# BFS 2: flood outward from visible boundary, track distance
	var fog_queue: Array = []
	for vis_tile in _visible.keys():
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var neighbor = vis_tile + d
			if not _visible.has(neighbor) and not _fog_dist.has(neighbor):
				_fog_dist[neighbor] = 0  # ring 0 = immediately adjacent to light
				fog_queue.append([neighbor, 0])

	var fhead = 0
	while fhead < fog_queue.size():
		var tile: Vector2i = fog_queue[fhead][0]
		var dist: int = fog_queue[fhead][1]
		fhead += 1
		if dist >= FADE_TILES - 1:
			continue
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var next = tile + d
			if _visible.has(next) or _fog_dist.has(next):
				continue
			_fog_dist[next] = dist + 1
			fog_queue.append([next, dist + 1])
	queue_redraw()

func _draw() -> void:
	if walls == null:
		return
	var player_tile = walls.local_to_map(walls.to_local(get_parent().global_position))
	for x in range(-DRAW_RADIUS, DRAW_RADIUS + 1):
		for y in range(-DRAW_RADIUS, DRAW_RADIUS + 1):
			var tile = player_tile + Vector2i(x, y)
			if _visible.has(tile):
				continue
			var alpha: float
			if _fog_dist.has(tile):
				var t = float(_fog_dist[tile]) / float(FADE_TILES - 1)
				alpha = lerp(ALPHA_NEAR, ALPHA_FAR, t)
			else:
				alpha = ALPHA_FAR
			draw_rect(
				Rect2(
					Vector2(x * TILE_SIZE - TILE_SIZE / 2, y * TILE_SIZE - TILE_SIZE / 2),
					Vector2(TILE_SIZE, TILE_SIZE)
				),
				Color(0, 0, 0, alpha)
			)
