extends Control

const INMATE_GOOD_END: Array[String] = [
	"[center]You chose mercy. The world is lighter for it.[/center]",
]
const INMATE_EVIL_END: Array[String] = [
	"[center]You chose cruelty. The walls close tighter.[/center]",
]
const GUARD_GOOD_END: Array[String] = [
	"[center]You helped the inmate find hope.[/center]",
]
const GUARD_EVIL_END: Array[String] = [
	"[center]You helped the inmate embrace darkness.[/center]",
]

@onready var center: CenterContainer = $CenterContainer
@onready var choice_label: Label = $CenterContainer/VBoxContainer/Label2
@onready var inmate_phrase_label: Label = $CenterContainer/VBoxContainer/Label3
@onready var guard_phrase_label: Label = $CenterContainer/VBoxContainer/Label4
@onready var back_button: Button = $CenterContainer/VBoxContainer/Button

func _ready() -> void:
	center.visible = false
	Dialogue.play_moral(
		INMATE_GOOD_END, INMATE_EVIL_END,
		GUARD_GOOD_END, GUARD_EVIL_END,
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
