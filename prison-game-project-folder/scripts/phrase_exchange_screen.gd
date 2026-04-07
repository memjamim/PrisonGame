extends Control

@onready var prompt_label: Label   = $CenterContainer/VBoxContainer/PromptLabel
@onready var reveal_label: Label   = $CenterContainer/VBoxContainer/RevealLabel
@onready var input_field: LineEdit = $CenterContainer/VBoxContainer/InputField
@onready var submit_btn: Button    = $CenterContainer/VBoxContainer/SubmitButton
@onready var confirm_btn: Button   = $CenterContainer/VBoxContainer/ConfirmButton
@onready var error_label: Label    = $CenterContainer/VBoxContainer/ErrorLabel

func _ready() -> void:
	reveal_label.visible = false
	confirm_btn.visible  = false
	error_label.visible  = false

	submit_btn.pressed.connect(_on_submit)
	confirm_btn.pressed.connect(_on_confirm)

	if GameManager.current_role == GameManager.Role.INMATE:
		prompt_label.text = "Say this to your guard:\n\n" + GameManager.get_inmate_display_phrase()
		input_field.placeholder_text = "Type the reply you heard..."
	else:
		prompt_label.text = "Type what the inmate said:"
		input_field.placeholder_text = "Enter phrase..."

func _on_submit() -> void:
	error_label.visible = false
	if GameManager.current_role == GameManager.Role.INMATE:
		if GameManager.submit_inmate_confirm(input_field.text):
			queue_free()
			GameManager.complete_sequence()
		else:
			_show_error()
	else:
		var reply = GameManager.submit_guard_input(input_field.text)
		if reply != "":
			input_field.visible  = false
			submit_btn.visible   = false
			reveal_label.text    = "Read this to your inmate:\n\n" + reply
			reveal_label.visible = true
			confirm_btn.visible  = true
		else:
			_show_error()

func _on_confirm() -> void:
	queue_free()
	GameManager.complete_sequence()

func _show_error() -> void:
	error_label.visible = true
	error_label.text = "Incorrect. Try again."
