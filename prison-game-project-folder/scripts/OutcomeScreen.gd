extends Control

@onready var choice_label: Label = $CenterContainer/VBoxContainer/Label2
@onready var inmate_phrase_label: Label = $CenterContainer/VBoxContainer/Label3
@onready var guard_phrase_label: Label = $CenterContainer/VBoxContainer/Label4
@onready var back_button: Button = $CenterContainer/VBoxContainer/Button

func _ready() -> void:
	var choice_text := "No choice recorded."
	if GameState.chosen_alignment != "":
		choice_text = "Choice made: %s" % GameState.chosen_alignment.capitalize()

	choice_label.text = choice_text
	inmate_phrase_label.text = "Your passphrase: %s" % GameState.inmate_phrase_revealed
	guard_phrase_label.text = "Guard reply: %s" % GameState.guard_phrase_revealed

	back_button.pressed.connect(_on_back_pressed)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
