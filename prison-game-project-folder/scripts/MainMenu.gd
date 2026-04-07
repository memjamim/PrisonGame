extends Control

@onready var inmate_button: Button = $CenterContainer/VBoxContainer/InmateButton
@onready var guard_button: Button = $CenterContainer/VBoxContainer/GuardButton


const INMATE_INTRO: Array[String] = [
	"I wake up on an uncomfortable mattress.\nThis is not my usual room. It's a prison cell.",
	"Still dazed from waking, I remember why I'm here.\nI was taken in by the police for reasons they didn't explain.",
	"They didn't let me see my lawyer or even give me a trial.\nThey simply locked me up for seemingly no reason.",
	"Unbelievable...",
	"",
	"The prison is louder than I expected.\nSome of the fellow prisoners rage against their cells, demanding to be released.\nI thought this behavior to be foolish.",
	"They locked us in here for crimes we didn't commit.\nThere's less than no reason for them to listen to our pleas now.",
	"",
	"There's not much to do in my cell besides laying in my bed.\nThere's a desk in the corner of the cell, one I didn't spot until now due to the lightning being just above abyss.\nIt's small.",
	"It can hardly be called a desk but next to it is a pen and quaint journal.\nI flip through the pages, thinking it must have belonged to the previous unforunate resident.",
	"It's empty inside... The pen is also unused...",
	"",
	"With nothing else to do, I sat down with the journal, I might as well write in it.\nThere's nothing else to do after all.",
	"Putting pen to paper, words flow onto the page from me...",
]
const GUARD_INTRO: Array[String] = [
	"~THE SELF~",
	"You wake in cold cell, on a stiff mattress.\nThe cell cramped. If you stretched out your arms, you could almost touch both walls.",
	"",
	"What a ridiculous situation I've gotten in...\nAfter taking a nice stroll through the park last night, you were abrputly accosted by the police.",
	"No trial, no lawyer, no reason.\nYou were simply put here, if there was a reason -- you'd never know.",
	"",
	"You look out the cell and see an unending supercomplex of identical cells\nAll victims like me?",
	"",
	"Your attention comes back to your accomodations.\nSearching for anything else that could have been missed, a small desk forms out of the inky black.",
	"A top it a pen and pad.\nWith nothing but time you begin to write thinking of what words suit you."
]

func _ready() -> void:
	inmate_button.pressed.connect(_on_inmate_pressed)
	guard_button.pressed.connect(_on_guard_pressed)

func _on_inmate_pressed() -> void:
	GameState.reset_run()
	GameManager.set_role(GameManager.Role.INMATE)
	Dialogue.play(INMATE_INTRO, GUARD_INTRO, func(): get_tree().change_scene_to_file("res://scenes/InmateScreen.tscn"))

func _on_guard_pressed() -> void:
	GameManager.set_role(GameManager.Role.GUARD)
	Dialogue.play(INMATE_INTRO, GUARD_INTRO, func(): get_tree().change_scene_to_file("res://scenes/GuardScreen.tscn"))
