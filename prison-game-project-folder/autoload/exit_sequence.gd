extends CanvasLayer

var _overlay: ColorRect

func _ready() -> void:
	layer = 100
	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 0)
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_overlay)
	GameManager.level_completed.connect(_begin)

func _begin() -> void:
	var tween = create_tween()
	tween.tween_property(_overlay, "color:a", 1.0, 1.5)
	tween.tween_callback(_on_fade_complete)

func _on_fade_complete() -> void:
	# -- ADD FUTURE STEPS HERE --
	# e.g. show co-op code UI, load next scene, play sound, etc.
	pass
