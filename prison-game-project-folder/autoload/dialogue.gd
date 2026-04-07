extends Node

const _SCENE = preload("res://scenes/DialogueScreen.tscn")

func play(inmate_panels: Array[String], guard_panels: Array[String], on_finish: Callable = Callable()) -> void:
	var panels = inmate_panels if GameManager.current_role == GameManager.Role.INMATE else guard_panels
	if panels.is_empty():
		if on_finish.is_valid():
			on_finish.call()
		return
	var dlg = _SCENE.instantiate()
	dlg.setup(panels)
	if on_finish.is_valid():
		dlg.dialogue_finished.connect(on_finish)
	get_tree().root.add_child(dlg)
