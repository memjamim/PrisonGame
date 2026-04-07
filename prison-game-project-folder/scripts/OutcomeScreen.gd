extends Control

const GOOD_END: Array[String] = [
	"It's been a while since I was put into this cell.\nAs I suspected, escape from this cell is proving to be nearly impossible.",
	"Guards constantly patrol the corridors and the cell proves to be incredibly sturdy.",
	"Despite this, I wait.\nI hold out hoping that my situation will change one day.",
	"I wait for another opportunity.\nUntil then I remain patient.",
	"Until then, I keep writing in my journal.",
]

const EVIL_END: Array[String] = [
	"It's been a while since I was put into this cell.\nI've lost count of the days. All I know is that I've been here for a long time.",
	"Every day is the same.\nA guard comes and gives me food.\nI sleep.\nI wake.\nI write.",
	"I've long since given up on getting out of here.\nThere's just no way I was getting out of this place.\nBetter to accept that now.",
	"Why was I put in here again?\nI was sure I didn't do anything wrong.",
	"The days continue to pass.\nI continue to write.\nThe days pass me by.",
]

@onready var center: CenterContainer = $CenterContainer
@onready var choice_label: Label = $CenterContainer/VBoxContainer/Label2
@onready var inmate_phrase_label: Label = $CenterContainer/VBoxContainer/Label3
@onready var guard_phrase_label: Label = $CenterContainer/VBoxContainer/Label4
@onready var back_button: Button = $CenterContainer/VBoxContainer/Button

func _ready() -> void:
	center.visible = false
	Dialogue.play_moral(
		GOOD_END, EVIL_END,
		GOOD_END, EVIL_END,
		_show_results)

func _show_results() -> void:
	center.visible = true

	if GameState.chosen_alignment != "":
		choice_label.text = "Choice made: %s" % GameState.chosen_alignment.capitalize()
	else:
		choice_label.text = "No choice recorded."

	inmate_phrase_label.text = "Your passphrase: %s" % GameState.inmate_phrase_revealed
	guard_phrase_label.text = "Guard reply: %s" % GameState.guard_phrase_revealed

	back_button.pressed.connect(_on_back_pressed)

func _on_back_pressed() -> void:
	GameManager.reset()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
