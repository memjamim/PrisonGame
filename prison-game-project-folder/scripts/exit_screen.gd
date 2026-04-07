extends ColorRect

const PEX_SCENE = preload("res://scenes/PhraseExchangeScreen.tscn")

const GUARD_NULL: Array[String] = []

const CONFINEMENT_EXIST: Array[String] = [
	"After winding around this labyrinth of a prison, I finally managed to reach my destination.\nFreedom is right in front of my eyes when suddenly the alarms go off.",
	"I tried to contact the guard. Radio silence.\nEither the guard led me into a trap or they've also been captured.",
	"Either way, it didn't matter much.\nI was quickly surrounded by guards and dragged away.",
	"I'm back in a cell, an even smaller one this time.\nThe guards threw me into solitary confinement.",
	"The noise of my previous cell has been replaced by a deep silence.\nThe escape was nearly a success but I probably won't have another chance at it again.",
	"On top of the bed laid a familiar object.\nIt was the journal I was writing in before.\nThat guard must have gotten it into this room somehow.",
	"With nothing else to do, I began to write.",
]

const CONFINEMENT_DEFEAT: Array[String] = [
	"After winding around this labyrinth of a prison, I finally managed to reach my destination.\nFreedom is right in front of my eyes when suddenly the alarms go off.",
	"I tried to contact the guard. Radio silence.\nEither the guard led me into a trap or they've also been captured.",
	"Either way, it didn't matter much.\nI was quickly surrounded by guards and dragged away.",
	"I'm back in a cell, an even smaller one this time.\nThe guards threw me into solitary confinement.",
	"The noise of my previous cell has been replaced by a deep silence.\nThe escape was nearly a success but I probably won't have another chance at it again.",
	"I sighed.\nI knew the escape attempt was hopeless.\nI shouldn't have listened to that guard.",
	"All that effort, just to end up here.\nI collapse onto my small bed.",
	"To my surprise, there was already something on the bed.\nIt was the journal I was writing in.\nThat guard must have gotten this into this cell somehow.",
	"I lay there staring at the journal for a bit then decided to get up.\nWith nothing but time on my hands now, I began to write.",
]

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	color = Color.BLACK

	GameState.advance_stage()  # MAZE -> WORDSEARCH_2

	GameManager.sequence_complete.connect(_on_sequence_complete)

	var pex = PEX_SCENE.instantiate()
	add_child(pex)

func _on_sequence_complete() -> void:
	var panels: Array[String] = CONFINEMENT_EXIST if GameState.chosen_alignment == "good" else CONFINEMENT_DEFEAT
	Dialogue.play(panels, GUARD_NULL, func():
		get_tree().change_scene_to_file("res://scenes/InmateScreen2.tscn"))
