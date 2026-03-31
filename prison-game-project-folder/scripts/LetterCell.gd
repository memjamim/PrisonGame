extends Button

signal hovered_while_dragging(row: int, col: int)
signal drag_started(row: int, col: int)
signal drag_released()

var row: int = -1
var col: int = -1
var is_found: bool = false
var is_selected: bool = false

func setup(letter: String, p_row: int, p_col: int) -> void:
	text = letter
	row = p_row
	col = p_col
	focus_mode = Control.FOCUS_NONE

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			drag_started.emit(row, col)
		else:
			drag_released.emit()

func _on_mouse_entered() -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		hovered_while_dragging.emit(row, col)

func refresh_visual() -> void:
	if is_found:
		modulate = Color(0.6, 1.0, 0.6)
	elif is_selected:
		modulate = Color(0.7, 0.85, 1.0)
	else:
		modulate = Color(1, 1, 1)
