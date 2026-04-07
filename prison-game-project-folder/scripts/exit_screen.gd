extends ColorRect

const PEX_SCENE = preload("res://scenes/PhraseExchangeScreen.tscn")

const INMATE_OUTRO: Array[String] = [
	"[center]Placeholder inmate outro panel one.[/center]",
	"[center]Placeholder inmate outro panel two.[/center]",
]
const GUARD_OUTRO: Array[String] = []

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	color = Color.BLACK

	GameState.advance_stage()  # MAZE -> WORDSEARCH_2

	GameManager.sequence_complete.connect(_on_sequence_complete)

	var pex = PEX_SCENE.instantiate()
	add_child(pex)

func _on_sequence_complete() -> void:
	Dialogue.play(INMATE_OUTRO, GUARD_OUTRO, func():
		get_tree().change_scene_to_file("res://scenes/InmateScreen2.tscn")
)
