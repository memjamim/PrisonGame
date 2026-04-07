extends Control

@onready var inmate_button: Button = $CenterContainer/VBoxContainer/InmateButton
@onready var guard_button: Button = $CenterContainer/VBoxContainer/GuardButton


const INMATE_INTRO: Array[String] = [
	"[center]Inmate intro panel one.[/center]",
	"[center]Inmate intro panel two.[/center]",
]
const GUARD_INTRO: Array[String] = [
	"[center]Guard intro panel one.[/center]",
	"[center]Guard intro panel two.[/center]",
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
