extends CanvasLayer

var _overlay: ColorRect

func _ready() -> void:
	layer = 100
	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 0)
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_overlay)
	GameManager.level_completed.connect(_on_level_completed)
	GameManager.sequence_complete.connect(_on_sequence_complete)

func _on_level_completed() -> void:
	var tween = create_tween()
	tween.tween_property(_overlay, "color:a", 1.0, 1.5)
	tween.tween_callback(GameManager.begin_phrase_exchange)

func _on_sequence_complete() -> void:
	pass  # get_tree().change_scene_to_file("res://scenes/next.tscn")
