extends Control

const LetterCellScene := preload("res://scenes/LetterCell.tscn")

@onready var puzzle_grid: GridContainer = $MarginContainer/HBoxContainer/VBoxContainer/PuzzleGrid

@onready var good_words_label: Label = $MarginContainer/HBoxContainer/VBoxContainer2/GoodWordsLabel
@onready var evil_words_label: Label = $MarginContainer/HBoxContainer/VBoxContainer2/EvilWordsLabel

@onready var good_progress_text: Label = $MarginContainer/HBoxContainer/VBoxContainer2/GoodProgressText
@onready var good_bar: ProgressBar = $MarginContainer/HBoxContainer/VBoxContainer2/GoodBar
@onready var evil_progress_text: Label = $MarginContainer/HBoxContainer/VBoxContainer2/EvilProgressText
@onready var evil_bar: ProgressBar = $MarginContainer/HBoxContainer/VBoxContainer2/EvilBar
@onready var inmate_phrase_label: Label = $MarginContainer/HBoxContainer/VBoxContainer2/InmatePhraseLabel
@onready var guard_phrase_input: LineEdit = $MarginContainer/HBoxContainer/VBoxContainer2/GuardPhraseInput
@onready var submit_guard_phrase_button: Button = $MarginContainer/HBoxContainer/VBoxContainer2/SubmitGuardPhraseButton
@onready var guard_phrase_result_label: Label = $MarginContainer/HBoxContainer/VBoxContainer2/GuardPhraseResultLabel
@onready var status_label: Label = $MarginContainer/HBoxContainer/VBoxContainer2/StatusLabel
@onready var back_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/BackButton

var board: Array = []
var cells: Array = []

var dragging := false
var drag_path: Array[Vector2i] = []

func _ready() -> void:
	puzzle_grid.columns = GameState.GRID_SIZE

	good_bar.max_value = GameState.GOOD_TARGET
	evil_bar.max_value = GameState.EVIL_TARGET
	good_bar.show_percentage = false
	evil_bar.show_percentage = false

	_apply_bar_styles()
	_hide_word_lists_from_inmate()

	submit_guard_phrase_button.pressed.connect(_on_submit_guard_phrase_pressed)
	back_button.pressed.connect(_on_back_pressed)

	_generate_board()
	_build_grid()
	_refresh_sidebar()

func _apply_bar_styles() -> void:
	var background := StyleBoxFlat.new()
	background.bg_color = Color(0.14, 0.14, 0.14, 1.0)
	background.corner_radius_top_left = 4
	background.corner_radius_top_right = 4
	background.corner_radius_bottom_left = 4
	background.corner_radius_bottom_right = 4

	var good_fill := StyleBoxFlat.new()
	good_fill.bg_color = Color(0.25, 0.78, 0.35, 1.0)
	good_fill.corner_radius_top_left = 4
	good_fill.corner_radius_top_right = 4
	good_fill.corner_radius_bottom_left = 4
	good_fill.corner_radius_bottom_right = 4

	var evil_fill := StyleBoxFlat.new()
	evil_fill.bg_color = Color(0.85, 0.25, 0.25, 1.0)
	evil_fill.corner_radius_top_left = 4
	evil_fill.corner_radius_top_right = 4
	evil_fill.corner_radius_bottom_left = 4
	evil_fill.corner_radius_bottom_right = 4

	good_bar.add_theme_stylebox_override("background", background)
	evil_bar.add_theme_stylebox_override("background", background)

	good_bar.add_theme_stylebox_override("fill", good_fill)
	evil_bar.add_theme_stylebox_override("fill", evil_fill)

func _hide_word_lists_from_inmate() -> void:
	if is_instance_valid(good_words_label):
		good_words_label.visible = false
	if is_instance_valid(evil_words_label):
		evil_words_label.visible = false

func _generate_board() -> void:
	board.clear()
	for y in GameState.GRID_SIZE:
		var row: Array[String] = []
		for x in GameState.GRID_SIZE:
			row.append("")
		board.append(row)

	var all_words: Array[String] = []
	all_words.append_array(GameState.GOOD_WORDS)
	all_words.append_array(GameState.EVIL_WORDS)

	for word in all_words:
		_place_word(word)

	_fill_empty_cells()

func _place_word(word: String) -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()

	var directions := [
		Vector2i(1, 0), Vector2i(-1, 0),
		Vector2i(0, 1), Vector2i(0, -1),
		Vector2i(1, 1), Vector2i(-1, -1),
		Vector2i(1, -1), Vector2i(-1, 1)
	]

	for attempt in 200:
		var dir: Vector2i = directions[rng.randi_range(0, directions.size() - 1)]
		var sx := rng.randi_range(0, GameState.GRID_SIZE - 1)
		var sy := rng.randi_range(0, GameState.GRID_SIZE - 1)

		if _can_place_word(word, sx, sy, dir):
			for i in word.length():
				var x := sx + dir.x * i
				var y := sy + dir.y * i
				board[y][x] = word.substr(i, 1)
			return

	push_warning("Could not place word: %s" % word)

func _can_place_word(word: String, sx: int, sy: int, dir: Vector2i) -> bool:
	for i in word.length():
		var x := sx + dir.x * i
		var y := sy + dir.y * i

		if x < 0 or y < 0 or x >= GameState.GRID_SIZE or y >= GameState.GRID_SIZE:
			return false

		var existing: String = board[y][x]
		var letter := word.substr(i, 1)

		if existing != "" and existing != letter:
			return false

	return true

func _fill_empty_cells() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	const LETTERS := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

	for y in GameState.GRID_SIZE:
		for x in GameState.GRID_SIZE:
			if board[y][x] == "":
				board[y][x] = LETTERS.substr(rng.randi_range(0, LETTERS.length() - 1), 1)

func _build_grid() -> void:
	cells.clear()

	for child in puzzle_grid.get_children():
		child.queue_free()

	for y in GameState.GRID_SIZE:
		var row_cells: Array = []
		for x in GameState.GRID_SIZE:
			var cell = LetterCellScene.instantiate()
			cell.setup(board[y][x], y, x)
			cell.drag_started.connect(_on_cell_drag_started)
			cell.hovered_while_dragging.connect(_on_cell_hovered)
			cell.drag_released.connect(_on_cell_drag_released)
			puzzle_grid.add_child(cell)
			row_cells.append(cell)
		cells.append(row_cells)

func _on_cell_drag_started(row: int, col: int) -> void:
	dragging = true
	drag_path.clear()
	drag_path.append(Vector2i(col, row))
	_refresh_selection_visuals()

func _on_cell_hovered(row: int, col: int) -> void:
	if not dragging:
		return

	var start: Vector2i = drag_path[0]
	var current := Vector2i(col, row)

	if current == start:
		drag_path = [start]
		_refresh_selection_visuals()
		return

	var delta := current - start
	var step := Vector2i.ZERO

	if delta.x == 0:
		step = Vector2i(0, sign(delta.y))
	elif delta.y == 0:
		step = Vector2i(sign(delta.x), 0)
	elif abs(delta.x) == abs(delta.y):
		step = Vector2i(sign(delta.x), sign(delta.y))
	else:
		return

	var new_path: Array[Vector2i] = []
	var pos := start
	new_path.append(pos)

	while pos != current:
		pos += step
		new_path.append(pos)

	drag_path = new_path
	_refresh_selection_visuals()

func _on_cell_drag_released() -> void:
	if not dragging:
		return

	dragging = false
	_check_selected_word()
	drag_path.clear()
	_refresh_selection_visuals()

func _refresh_selection_visuals() -> void:
	for y in cells.size():
		for x in cells[y].size():
			var cell = cells[y][x]
			cell.is_selected = false
			cell.refresh_visual()

	for pos in drag_path:
		var cell = cells[pos.y][pos.x]
		if not cell.is_found:
			cell.is_selected = true
		cell.refresh_visual()

func _check_selected_word() -> void:
	var selected := ""
	for pos in drag_path:
		selected += board[pos.y][pos.x]

	var reversed := ""
	for i in range(selected.length() - 1, -1, -1):
		reversed += selected.substr(i, 1)

	if _try_register_word(selected):
		return
	if _try_register_word(reversed):
		return

	status_label.text = "That selection is not one of the hidden words."

func _try_register_word(word: String) -> bool:
	if word in GameState.GOOD_WORDS and not (word in GameState.found_good):
		GameState.found_good.append(word)
		_mark_current_path_found("good")
		status_label.text = "Word found."
		_after_word_found("good")
		return true

	if word in GameState.EVIL_WORDS and not (word in GameState.found_evil):
		GameState.found_evil.append(word)
		_mark_current_path_found("evil")
		status_label.text = "Word found."
		_after_word_found("evil")
		return true

	return false

func _mark_current_path_found(alignment: String) -> void:
	for pos in drag_path:
		var cell = cells[pos.y][pos.x]
		cell.is_found = true
		cell.is_selected = false
		cell.found_alignment = alignment
		cell.refresh_visual()

func _after_word_found(alignment: String) -> void:
	if alignment == "good":
		if GameState.found_good.size() >= GameState.GOOD_TARGET and GameState.chosen_alignment == "":
			GameState.chosen_alignment = "good"
			GameState.inmate_phrase_revealed = GameState.INMATE_GOOD_PASSPHRASE
			status_label.text = "Good path chosen. Give your passphrase to the guard."
	elif alignment == "evil":
		if GameState.found_evil.size() >= GameState.EVIL_TARGET and GameState.chosen_alignment == "":
			GameState.chosen_alignment = "evil"
			GameState.inmate_phrase_revealed = GameState.INMATE_EVIL_PASSPHRASE
			status_label.text = "Evil path chosen. Give your passphrase to the guard."

	_refresh_sidebar()

func _refresh_sidebar() -> void:
	good_bar.value = GameState.found_good.size()
	evil_bar.value = GameState.found_evil.size()

	good_progress_text.text = "Good progress: %d / %d" % [
		GameState.found_good.size(),
		GameState.GOOD_TARGET
	]

	evil_progress_text.text = "Evil progress: %d / %d" % [
		GameState.found_evil.size(),
		GameState.EVIL_TARGET
	]

	if GameState.inmate_phrase_revealed == "":
		inmate_phrase_label.text = "---"
	else:
		inmate_phrase_label.text = GameState.inmate_phrase_revealed

	if GameState.guard_phrase_revealed != "":
		guard_phrase_result_label.text = "Guard reply accepted: %s" % GameState.guard_phrase_revealed
	else:
		guard_phrase_result_label.text = "---"

func _on_submit_guard_phrase_pressed() -> void:
	var entered := guard_phrase_input.text.strip_edges().to_upper()

	if GameState.chosen_alignment == "":
		status_label.text = "You must fill either the good or evil bar first."
		return

	if entered == "":
		status_label.text = "Enter the guard's reply passphrase."
		return

	var expected = GameState.get_guard_reply_for_alignment(GameState.chosen_alignment)

	if entered == expected:
		GameState.guard_phrase_revealed = entered
		get_tree().change_scene_to_file("res://scenes/OutcomeScreen.tscn")
	else:
		status_label.text = "That guard reply does not match your chosen path."

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
