extends Node

signal dialogue_finished

@onready var panel_label: RichTextLabel = $MarginContainer/VBoxContainer/PanelLabel
@onready var back_hint: Label           = $MarginContainer/VBoxContainer/NavRow/BackHint
@onready var continue_hint: Label       = $MarginContainer/VBoxContainer/NavRow/ContinueHint

var _panels: Array[String] = []
var _current: int = 0

func setup(panels: Array[String]) -> void:
	_panels = panels

func _ready() -> void:
	if _panels.is_empty():
		dialogue_finished.emit()
		queue_free()
		return
	_show_panel(0)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_LEFT, KEY_BACKSPACE:
				_go(-1)
			KEY_RIGHT, KEY_ENTER, KEY_KP_ENTER, KEY_SPACE:
				_go(1)
		return
	if event is InputEventMouseButton and event.pressed:
		match (event as InputEventMouseButton).button_index:
			MOUSE_BUTTON_LEFT:  _go(1)
			MOUSE_BUTTON_RIGHT: _go(-1)

func _go(dir: int) -> void:
	_current = clampi(_current + dir, 0, _panels.size())
	if _current >= _panels.size():
		queue_free()
		dialogue_finished.emit()
		return
	_show_panel(_current)

func _show_panel(index: int) -> void:
	panel_label.text = _panels[index]
	back_hint.visible = index > 0
	back_hint.text = "[ Left Arrow / Right Click to go Back ]"
	var is_last = index == _panels.size() - 1
	continue_hint.text = "[ Enter or Click to Finish ]" if is_last else "[ Enter or Click to Continue ]"
