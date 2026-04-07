extends Control

@onready var good_words_label: Label = $MarginContainer/VBoxContainer/Label2
@onready var evil_words_label: Label = $MarginContainer/VBoxContainer/Label3
@onready var passphrase_input: LineEdit = $MarginContainer/VBoxContainer/LineEdit
@onready var submit_button: Button = $MarginContainer/VBoxContainer/Button
@onready var result_label: Label = $MarginContainer/VBoxContainer/Label5
@onready var back_button: Button = $MarginContainer/VBoxContainer/Button2

func _ready() -> void:
	good_words_label.text = "Good words:\n" + ", ".join(GameState.GOOD_WORDS)
	evil_words_label.text = "Evil words:\n" + ", ".join(GameState.EVIL_WORDS)

	submit_button.pressed.connect(_on_submit_pressed)
	back_button.pressed.connect(_on_back_pressed)

func _on_submit_pressed() -> void:
	var result := GameState.try_accept_dual_guard_input(passphrase_input.text) # Use a line like this for the password handshakes for other classes

	if result["ok"]:
		var alignment: String = result["alignment"]
		var reply: String = result["reply"]

		result_label.text = "Matched side: %s\nSend this back to the inmate:\n%s" % [
			alignment.capitalize(),
			reply
		]
	else:
		result_label.text = "That passphrase is not valid for this wordsearch."

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
