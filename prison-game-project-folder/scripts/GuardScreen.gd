extends Control

const INMATE_NULL: Array[String] = []

const GUARD_EXIST: Array[String] = [
	"I am making my nightly patrols.\nI let out a sigh.\nWhat a dull existence this is.",
	"I was put on guard duty nearly a decade ago.\nI quickly realized that this job had no future.",
	"I'm stuck here doing the same thing every day.\nI can't leave, I can't get promoted, I can't see my family.\nI'm trapped as much as these prisoners are.",
	"I reached the last block of my nightly patrol, the quota block.\nI always feel terrible walking through this area.",
	"The quota block is for prisoners captured to fill police quota.\nMany of these prisoners were just unlucky.",
	"I see someone moving about still despite the hour.\nI saw a prisoner tucking something away under their bed.",
	"\"Excuse me but what did you just hide away?\"\nThe prisoner stares at me in shock and hands me a small book.",
	"I skim the contents. It appears to be a journal.\nFrom the content of this journal I can tell, this prisoner is strong willed.",
	"If it's this person, then maybe we can escape.\nI've secretly acquired a map of the prison but to escape, I need an assistant.",
	"I offer my plan to the prisoner.\nHe looked shocked at first but then accepted my proposal.",
	"I would guide the prisoner around with the map I have and have them help us escape.\nOur escape attempt begins.",
]

const GUARD_DEFEAT: Array[String] = [
	"I am making my nightly patrols.\nI let out a sigh.\nWhat a dull existence this is.",
	"I was put on guard duty nearly a decade ago.\nI quickly realized that this job had no future.",
	"I'm stuck here doing the same thing every day.\nI can't leave, I can't get promoted, I can't see my family.\nI'm trapped as much as these prisoners are.",
	"I reached the last block of my nightly patrol, the quota block.\nI always feel terrible walking through this area.",
	"The quota block is for prisoners captured to fill police quota.\nMany of these prisoners were just unlucky.",
	"I see someone moving about still despite the hour.\nI saw a prisoner tucking something away under their bed.",
	"\"Excuse me but what did you just hide away?\"\nThe prisoner stares at me in shock and hands me a small book.",
	"I skim the contents. It appears to be a journal.\nReading through the contents, I feel pity for the prisoner.",
	"Newly captured, confused, self doubt.\nI wonder if all prisoners feel the same when they first arrive.",
	"Feeling remorseful, I offer the prisoner an escape plan.\nI've actually held onto a map of the prison for some time now.\nThe issue is that I need someone to help me get out.",
	"The prisoner turns away from me, defeated.\nThe prisoner rambles about the pointlessness of escaping, a feeling I am all too familiar with.",
	"\"Please you have nothing else to lose.\"\nI can see the prisoner give in to these words.",
	"I would guide the prisoner around with the map I have and have them help us escape.\nOur escape attempt begins.",
]
@onready var good_words_label: Label = $MarginContainer/VBoxContainer/Label2
@onready var evil_words_label: Label = $MarginContainer/VBoxContainer/Label3
@onready var passphrase_input: LineEdit = $MarginContainer/VBoxContainer/LineEdit
@onready var submit_button: Button = $MarginContainer/VBoxContainer/Button
@onready var result_label: Label = $MarginContainer/VBoxContainer/Label5
@onready var back_button: Button = $MarginContainer/VBoxContainer/Button2


var _reply_shown: bool = false

func _ready() -> void:
	good_words_label.text = "Good words:\n" + ", ".join(GameState.GOOD_WORDS)
	evil_words_label.text = "Evil words:\n" + ", ".join(GameState.EVIL_WORDS)

	submit_button.pressed.connect(_on_submit_pressed)
	back_button.pressed.connect(_on_back_pressed)

func _on_submit_pressed() -> void:
	if _reply_shown:
		GameState.advance_stage()
		var panels: Array[String] = GUARD_EXIST if GameState.chosen_alignment == "good" else GUARD_DEFEAT
		Dialogue.play(INMATE_NULL, panels, func():
			get_tree().change_scene_to_file("res://scenes/MapViewer.tscn"))
		return
	var result := GameState.try_accept_dual_guard_input(passphrase_input.text) # Use a line like this for the password handshakes for other classes

	if result["ok"]:
		_reply_shown = true
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
	
func _on_exit_button_pressed() -> void:
	GameManager.begin_phrase_exchange()
