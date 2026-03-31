extends Control

@onready var inmate_button: Button = $CenterContainer/VBoxContainer/InmateButton
@onready var guard_button: Button = $CenterContainer/VBoxContainer/GuardButton

func _ready() -> void:
	inmate_button.pressed.connect(_on_inmate_pressed)
	guard_button.pressed.connect(_on_guard_pressed)

func _on_inmate_pressed() -> void:
	GameState.reset_run()
	get_tree().change_scene_to_file("res://scenes/InmateScreen.tscn")

func _on_guard_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/GuardScreen.tscn")
