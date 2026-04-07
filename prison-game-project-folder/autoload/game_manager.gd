extends Node

signal level_completed
signal phrase_exchange_started(inmate_phrase: String)
signal phrase_accepted(guard_reply: String)
signal phrase_rejected
signal sequence_complete

enum Role {NONE, INMATE, GUARD}
var current_role: Role = Role.NONE

var _finishing: bool = false

func finish_level() -> void:
	if _finishing:
		return
	_finishing = true
	emit_signal("level_completed")

func set_role(r: Role) -> void:
	current_role = r

func begin_phrase_exchange() -> void:
	emit_signal("phrase_exchange_started", GameState.EXIT_INMATE_PHRASE)
	
func submit_reply(entered: String) -> void:
	if GameState.try_accept_exit_reply(entered):
		emit_signal("phrase_accepted", GameState.EXIT_GUARD_REPLY)
	else:
		emit_signal("phrase_Rejected")

func reset() -> void:
	_finishing = false
