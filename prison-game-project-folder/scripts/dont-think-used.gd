extends CanvasLayer

const _PEX_SCENE = preload("res://scenes/PhraseExchangeScreen.tscn")

const INMATE_OUTRO: Array[String] = [
	"[center]Placeholder inmate outro panel one.[/center]",
	"[center]Placeholder inmate outro panel two.[/center]",
]
const GUARD_OUTRO: Array[String] = []

var _overlay: ColorRect

func _ready() -> void:
	layer = 100
	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 0)
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_overlay)

	GameManager.level_completed.connect(_on_level_completed)
	GameManager.phrase_exchange_started.connect(_on_phrase_exchange_started)
	GameManager.sequence_complete.connect(_on_sequence_complete)

func _on_level_completed() -> void:
	# inmate only - guard never emits level_completed
	var tween = create_tween()
	tween.tween_property(_overlay, "color:a", 1.0, 1.5)
	tween.tween_callback(GameManager.begin_phrase_exchange)

func _on_phrase_exchange_started() -> void:
	var pex = _PEX_SCENE.instantiate()
	get_tree().root.add_child(pex)

func _on_sequence_complete() -> void:
	Dialogue.play(INMATE_OUTRO, GUARD_OUTRO, func():
		get_tree().change_scene_to_file("res://scenes/WordSearch2Screen.tscn")
	)
