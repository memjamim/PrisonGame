extends Control

const MAP_TEXTURE = preload("res://assets/maze_map.png")

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
	get_tree().change_scene_to_file("res://scenes/GuardScreen2.tscn")
