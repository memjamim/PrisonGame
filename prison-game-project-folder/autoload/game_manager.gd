extends Node

enum Role { NONE, INMATE, GUARD }

signal level_completed
signal phrase_exchange_started
signal phrase_rejected
signal sequence_complete

var current_role: Role = Role.NONE
var _finishing: bool = false

func set_role(r: Role) -> void:
	current_role = r

func finish_level() -> void:
	if _finishing:
		return
	_finishing = true
	level_completed.emit()

func begin_phrase_exchange() -> void:
	phrase_exchange_started.emit()

func get_inmate_display_phrase() -> String:
	if GameState.current_stage_uses_single_password():
		return GameState.reveal_single_inmate_phrase()
	if GameState.current_stage_uses_dual_passwords():
		return GameState.reveal_dual_inmate_phrase(GameState.chosen_alignment)
	return ""

func submit_guard_input(entered: String) -> String:
	if GameState.current_stage_uses_single_password():
		return GameState.try_accept_single_guard_input(entered)
	if GameState.current_stage_uses_dual_passwords():
		var result = GameState.try_accept_dual_guard_input(entered)
		if result["ok"]:
			return result["reply"]
	return ""

func submit_inmate_confirm(entered: String) -> bool:
	if GameState.current_stage_uses_single_password():
		return GameState.try_confirm_single_inmate_reply(entered)
	if GameState.current_stage_uses_dual_passwords():
		return GameState.try_confirm_dual_inmate_reply(entered)
	return false

func complete_sequence() -> void:
	GameState.advance_stage()
	_finishing = false
	sequence_complete.emit()

func reset() -> void:
	_finishing = false
	GameState.reset_run()
