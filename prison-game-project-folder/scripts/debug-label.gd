extends Label

@export var player: CharacterBody2D
@export var walls: TileMapLayer

func _process(_delta: float) -> void:
	if player == null or walls == null:
		return
	var tile = walls.local_to_map(walls.to_local(player.global_position))
	text = "tile: (%d, %d)" % [tile.x, tile.y]
