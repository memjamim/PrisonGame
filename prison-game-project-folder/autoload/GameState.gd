extends Node

const GRID_SIZE := 10

const GOOD_WORDS := [
	"HOPE", "TRUST", "MERCY", "PEACE",
	"LIGHT", "TRUTH", "GRACE", "UNITY"
]

const EVIL_WORDS := [
	"GREED", "HATE", "LIES", "CRUEL",
	"FEAR", "ENVY", "RAGE", "DOOM"
]

const GOOD_TARGET := 4
const EVIL_TARGET := 4

const INMATE_GOOD_PASSPHRASE := "SUNLIGHT"
const INMATE_EVIL_PASSPHRASE := "SHADOW"

const GUARD_REPLY_FOR_GOOD := "KEYTURN"
const GUARD_REPLY_FOR_EVIL := "LOCKPAST"

var chosen_alignment: String = ""   # "good" or "evil"
var inmate_phrase_revealed: String = ""
var guard_phrase_revealed: String = ""

var found_good: Array[String] = []
var found_evil: Array[String] = []

func reset_run() -> void:
	chosen_alignment = ""
	inmate_phrase_revealed = ""
	guard_phrase_revealed = ""
	found_good.clear()
	found_evil.clear()

func get_words_for_alignment(alignment: String) -> Array[String]:
	if alignment == "good":
		return GOOD_WORDS
	return EVIL_WORDS

func get_target_for_alignment(alignment: String) -> int:
	if alignment == "good":
		return GOOD_TARGET
	return EVIL_TARGET

func get_inmate_phrase_for_alignment(alignment: String) -> String:
	if alignment == "good":
		return INMATE_GOOD_PASSPHRASE
	return INMATE_EVIL_PASSPHRASE

func get_guard_reply_for_alignment(alignment: String) -> String:
	if alignment == "good":
		return GUARD_REPLY_FOR_GOOD
	return GUARD_REPLY_FOR_EVIL

func try_accept_guard_input(entered_phrase: String) -> Dictionary:
	var cleaned := entered_phrase.strip_edges().to_upper()

	if cleaned == INMATE_GOOD_PASSPHRASE:
		return {
			"ok": true,
			"alignment": "good",
			"reply": GUARD_REPLY_FOR_GOOD
		}
	elif cleaned == INMATE_EVIL_PASSPHRASE:
		return {
			"ok": true,
			"alignment": "evil",
			"reply": GUARD_REPLY_FOR_EVIL
		}

	return {
		"ok": false,
		"alignment": "",
		"reply": ""
	}
