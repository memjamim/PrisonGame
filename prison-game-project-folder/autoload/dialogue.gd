extends Node

const _SCENE = preload("res://scenes/DialogueScreen.tscn")

func play(inmate_panels: Array[String], guard_panels: Array[String], on_finish: Callable = Callable()) -> void:
	var panels = inmate_panels if GameManager.current_role == GameManager.Role.INMATE else guard_panels
	if panels.is_empty():
		if on_finish.is_valid():
			on_finish.call()
		return
	var dlg = _SCENE.instantiate()
	dlg.process_mode = Node.PROCESS_MODE_ALWAYS
	dlg.setup(panels)
	if on_finish.is_valid():
		dlg.dialogue_finished.connect(on_finish)
	get_tree().root.add_child(dlg)
	
func play_moral(
	inmate_good: Array[String], inmate_evil: Array[String],
	guard_good: Array[String], guard_evil: Array[String],
	on_finish: Callable = Callable()
) -> void:
	var is_inmate = GameManager.current_role == GameManager.Role.INMATE
	var is_good = GameState.chosen_alignment == "good"
	var panels: Array[String]
	if is_inmate:
		panels = inmate_good if is_good else inmate_evil
	else:
		panels = guard_good if is_good else guard_evil
	if panels.is_empty():
		if on_finish.is_valid():
			on_finish.call()
		return
	var dlg = _SCENE.instantiate()
	dlg.process_mode = Node.PROCESS_MODE_ALWAYS
	dlg.setup(panels)
	if on_finish.is_valid():
		dlg.dialogue_finished.connect(on_finish)
	get_tree().root.add_child(dlg)
