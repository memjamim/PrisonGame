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

func _on_level_completed() -> void:
	_overlay.show()
	_overlay.color.a = 0.0
	var tween = create_tween()
	tween.tween_property(_overlay, "color:a", 1.0, 1.5)
	tween.tween_callback(func():
		get_tree().change_scene_to_file("res://scenes/ExitScreen.tscn")
		_overlay.call_deferred("hide")
)
