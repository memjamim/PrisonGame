extends Control

const MAP_TEXTURE = preload("res://assets/maze_map.png")

const INMATE_NULL: Array[String] = []

const GUARD_CONFINEMENT_EXIST: Array[String] = [
	"The prisoner has finally made it to their destination.\nRight in front is our path to escape when suddenly the alarms go off.",
	"Panic sets in. We've been found out.\nI tried to contact the prisoner. Nothing.",
	"Soon I'm surrounded by guards.\nI'm taken away.",
	"~THE SELF~",
	"You are taken to a new cell, even smaller than the one you previously resided in.\nYou can easily touch both walls if you put your arms out.",
	"You were so close to escaping. The exit was right there.\nThe cell block you're in now is solitary confinement.",
	"It's so quiet here. Every action you take reverberates around the halls.\nYou start thinking.",
	"Why did things not work out?\nIs there a way out of here?\nYour mind races.",
	"On the bed lies the journal you wrote in in the previous cell.\nYou don't know how it ended up here but you're grateful.",
	"With nothing else to do here, you began to write.",
]

const GUARD_CONFINEMENT_DEFEAT: Array[String] = [
	"The prisoner has finally made it to their destination.\nRight in front is our path to escape when suddenly the alarms go off.",
	"Panic sets in. We've been found out.\nI tried to contact the prisoner. Nothing.",
	"Soon I'm surrounded by guards.\nI'm taken away.",
	"~THE SELF~",
	"You are taken to a new cell, even smaller than the one you previously resided in.\nYou can easily touch both walls if you put your arms out.",
	"Why did you even think about escaping?\nYou knew it was hopeless from the start.",
	"So why did those words spur you to action?\nIt was a hopeless argument.\nYou knew it was hopeless and tried anyway.\nLook where that got you.",
	"You're tired.\nSo tired in fact that you don't see the journal on the bed before collapsing onto it.",
	"You get up after realizing what you laid on top of.\nYou take the journal and begin writing.\nYou have all the time in the world to do that now.",
]

@onready var map_panel: PanelContainer   = $VBoxContainer/MapPanel
@onready var map_image: TextureRect      = $VBoxContainer/MapPanel/ScrollContainer/MapImage
@onready var phrase_panel: VBoxContainer = $VBoxContainer/PhrasePanel
@onready var phrase_button: Button       = $VBoxContainer/TopBar/PhraseButton
@onready var phrase_input: LineEdit      = $VBoxContainer/PhrasePanel/PhraseInput
@onready var submit_btn: Button          = $VBoxContainer/PhrasePanel/SubmitButton
@onready var reply_label: Label          = $VBoxContainer/PhrasePanel/ReplyLabel
@onready var confirm_btn: Button         = $VBoxContainer/PhrasePanel/ConfirmButton
@onready var error_label: Label          = $VBoxContainer/PhrasePanel/ErrorLabel

func _ready() -> void:
	_fit_window_to_image()
	_setup_map()
	_setup_border()

	reply_label.visible  = false
	confirm_btn.visible  = false
	error_label.visible  = false
	phrase_input.placeholder_text = "Type what the inmate said..."

	phrase_button.pressed.connect(_toggle_view)
	submit_btn.pressed.connect(_on_submit)
	confirm_btn.pressed.connect(_on_confirm)

func _fit_window_to_image() -> void:
	var img_size = MAP_TEXTURE.get_size()
	var screen   = Vector2(DisplayServer.screen_get_size())
	# leave room for top bar and OS chrome
	var available = screen - Vector2(40, 120)
	var scale = minf(available.x / img_size.x, available.y / img_size.y)
	scale = minf(scale, 1.0)  # never upscale
	var win_size = Vector2i(img_size * scale) + Vector2i(40, 120)
	DisplayServer.window_set_size(win_size)
	# center on screen
	var center = DisplayServer.screen_get_size() / 2
	DisplayServer.window_set_position(center - win_size / 2)

func _setup_map() -> void:
	var img_size = MAP_TEXTURE.get_size()
	map_image.texture            = MAP_TEXTURE
	map_image.expand_mode        = TextureRect.EXPAND_KEEP_SIZE
	map_image.stretch_mode       = TextureRect.STRETCH_KEEP
	map_image.custom_minimum_size = img_size

func _setup_border() -> void:
	var style = StyleBoxFlat.new()
	style.bg_color         = Color(0.08, 0.08, 0.08, 1.0)
	style.border_width_top    = 2
	style.border_width_bottom = 2
	style.border_width_left   = 2
	style.border_width_right  = 2
	style.border_color     = Color(0.55, 0.55, 0.55, 1.0)
	map_panel.add_theme_stylebox_override("panel", style)

func _toggle_view() -> void:
	var on_map = map_panel.visible
	map_panel.visible    = not on_map
	phrase_panel.visible = on_map
	phrase_button.text   = "Back to Map" if on_map else "Phrase Exchange"

func _on_submit() -> void:
	error_label.visible = false
	var reply = GameManager.submit_guard_input(phrase_input.text)
	if reply != "":
		phrase_input.visible = false
		submit_btn.visible   = false
		reply_label.text     = "Read this to your inmate:\n\n" + reply
		reply_label.visible  = true
		confirm_btn.visible  = true
	else:
		error_label.visible = true
		error_label.text    = "Incorrect. Try again."

func _on_confirm() -> void:
	confirm_btn.disabled = true
	reply_label.text    += "\n\n[Confirmed]"
	GameManager.complete_sequence()
	var panels: Array[String] = GUARD_CONFINEMENT_EXIST if GameState.chosen_alignment == "good" else GUARD_CONFINEMENT_DEFEAT
	Dialogue.play(INMATE_NULL, panels, func():
		get_tree().change_scene_to_file("res://scenes/GuardScreen2.tscn"))
