extends Node

const GRID_SIZE := 10

const GOOD_WORDS := [
	 "PERSIST", "ENDURE", "WAITING", "SELF"
]

const EVIL_WORDS := [
	"CAGED", "TRAPPED", "CONTROL", "OPPRESS"
]

const GOOD_WORDS_2 := [
	"SURVIVE", "RESIST", "WILL", "EXIST"
]

const EVIL_WORDS_2 := [
	"CORNERED", "SILENCE", "CONFINED", "MALAISE"
]

const GOOD_TARGET := 4
const EVIL_TARGET := 4

enum Stage {
	WORDSEARCH_1,
	MAZE,
	WORDSEARCH_2
}

var current_stage: Stage = Stage.WORDSEARCH_1

# wordsearch stages: good/evil
const DUAL_STAGE_PASSWORDS := {
	Stage.WORDSEARCH_1: {
		"good_inmate": "SCRIBE",
		"evil_inmate": "MOROSE",
		"good_guard": "ENLIGHTENMENT",
		"evil_guard": "GALLOWS"
	},
	Stage.WORDSEARCH_2: {
		"good_inmate": "TOMORROW",
		"evil_inmate": "FORGOTTEN",
		"good_guard": "CHERISHED",
		"evil_guard": "ABANDON"
	}
}

# non-wordsearch stages: one password only
const SINGLE_STAGE_PASSWORDS := {
	Stage.MAZE: {
		"inmate": "FREEDOM?",
		"guard": "ENSNARED"
	}
}

var chosen_alignment: String = ""   # "good" or "evil"
var inmate_phrase_revealed: String = ""
var guard_phrase_revealed: String = ""

var found_good: Array[String] = []
var found_evil: Array[String] = []

func reset_run() -> void:
	current_stage = Stage.WORDSEARCH_1
	chosen_alignment = ""
	inmate_phrase_revealed = ""
	guard_phrase_revealed = ""
	found_good.clear()
	found_evil.clear()

func reset_stage_state() -> void:
	chosen_alignment = ""
	inmate_phrase_revealed = ""
	guard_phrase_revealed = ""
	found_good.clear()
	found_evil.clear()

func advance_stage() -> void:
	if current_stage == Stage.WORDSEARCH_1:
		current_stage = Stage.MAZE
	elif current_stage == Stage.MAZE:
		current_stage = Stage.WORDSEARCH_2

	reset_stage_state()

func get_words_for_alignment(alignment: String) -> Array[String]:
	if alignment == "good":
		return GOOD_WORDS
	return EVIL_WORDS

func get_target_for_alignment(alignment: String) -> int:
	if alignment == "good":
		return GOOD_TARGET
	return EVIL_TARGET

# WORDSEARCH DUAL PASSWORD

func reveal_dual_inmate_phrase(alignment: String) -> String:
	if not DUAL_STAGE_PASSWORDS.has(current_stage):
		return ""

	var data = DUAL_STAGE_PASSWORDS[current_stage]

	chosen_alignment = alignment

	if alignment == "good":
		inmate_phrase_revealed = data["good_inmate"]
	else:
		inmate_phrase_revealed = data["evil_inmate"]

	return inmate_phrase_revealed

func try_accept_dual_guard_input(entered_phrase: String) -> Dictionary:
	var cleaned := entered_phrase.strip_edges().to_upper()

	if not DUAL_STAGE_PASSWORDS.has(current_stage):
		return {
			"ok": false,
			"alignment": "",
			"reply": ""
		}

	var data = DUAL_STAGE_PASSWORDS[current_stage]

	if cleaned == data["good_inmate"]:
		return {
			"ok": true,
			"alignment": "good",
			"reply": data["good_guard"]
		}

	if cleaned == data["evil_inmate"]:
		return {
			"ok": true,
			"alignment": "evil",
			"reply": data["evil_guard"]
		}

	return {
		"ok": false,
		"alignment": "",
		"reply": ""
	}

func try_confirm_dual_inmate_reply(entered_phrase: String) -> bool:
	var cleaned := entered_phrase.strip_edges().to_upper()

	if not DUAL_STAGE_PASSWORDS.has(current_stage):
		return false

	var data = DUAL_STAGE_PASSWORDS[current_stage]

	if chosen_alignment == "good" and cleaned == data["good_guard"]:
		guard_phrase_revealed = cleaned
		return true

	if chosen_alignment == "evil" and cleaned == data["evil_guard"]:
		guard_phrase_revealed = cleaned
		return true

	return false

# SINGLE PASSWORD

func reveal_single_inmate_phrase() -> String:
	if not SINGLE_STAGE_PASSWORDS.has(current_stage):
		return ""

	var data = SINGLE_STAGE_PASSWORDS[current_stage]
	inmate_phrase_revealed = data["inmate"]
	return inmate_phrase_revealed

func try_accept_single_guard_input(entered_phrase: String) -> String:
	var cleaned := entered_phrase.strip_edges().to_upper()

	if not SINGLE_STAGE_PASSWORDS.has(current_stage):
		return ""

	var data = SINGLE_STAGE_PASSWORDS[current_stage]

	if cleaned == data["inmate"]:
		return data["guard"]

	return ""

func try_confirm_single_inmate_reply(entered_phrase: String) -> bool:
	var cleaned := entered_phrase.strip_edges().to_upper()

	if not SINGLE_STAGE_PASSWORDS.has(current_stage):
		return false

	var data = SINGLE_STAGE_PASSWORDS[current_stage]

	if cleaned == data["guard"]:
		guard_phrase_revealed = cleaned
		return true

	return false

# HELPERS

func current_stage_uses_dual_passwords() -> bool:
	return DUAL_STAGE_PASSWORDS.has(current_stage)

func current_stage_uses_single_password() -> bool:
	return SINGLE_STAGE_PASSWORDS.has(current_stage)
