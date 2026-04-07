extends Control

const INMATE_NULL: Array[String] = []
const GUARD_DIALOGUE: Array[String] = []

@onready var good_words_label: Label = $MarginContainer/VBoxContainer/Label2
@onready var evil_words_label: Label = $MarginContainer/VBoxContainer/Label3
@onready var passphrase_input: LineEdit = $MarginContainer/VBoxContainer/LineEdit
@onready var submit_button: Button = $MarginContainer/VBoxContainer/Button
@onready var result_label: Label = $MarginContainer/VBoxContainer/Label5
@onready var back_button: Button = $MarginContainer/VBoxContainer/Button2

var _reply_shown: bool = false

func _ready() -> void:
	GameState.chosen_alignment = ""
	good_words_label.text = "Good words:\n" + ", ".join(GameState.GOOD_WORDS_2)
	evil_words_label.text = "Evil words:\n" + ", ".join(GameState.EVIL_WORDS_2)
	submit_button.pressed.connect(_on_submit_pressed)
	back_button.pressed.connect(_on_back_pressed)

func _on_submit_pressed() -> void:
	if _reply_shown:
		GameState.advance_stage()
		Dialogue.play(INMATE_NULL, GUARD_DIALOGUE, func():
			get_tree().change_scene_to_file("res://scenes/OutcomeScreen.tscn"))
		return

	var result := GameState.try_accept_dual_guard_input(passphrase_input.text)
	if result["ok"]:
		_reply_shown = true
		GameState.chosen_alignment = result["alignment"]
		result_label.text = "Matched side: %s\nSend this back to the inmate:\n%s" % [
			result["alignment"].capitalize(), result["reply"]]
	else:
		result_label.text = "That passphrase is not valid for this wordsearch."

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
