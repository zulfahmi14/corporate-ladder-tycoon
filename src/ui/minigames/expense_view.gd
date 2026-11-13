class_name ExpenseView
extends MinigameView
## Expense Report: pick the right total for each set of receipts.

var _question: Dictionary = {}
var _index: int = 0
var _correct: int = 0
var _time_left: float = 0.0
var _sum_label: Label
var _timer_bar: ProgressBar
var _choices: Array[Button] = []


func _title_key() -> String:
	return "MINIGAME_EXPENSE"


func _build(body: VBoxContainer) -> void:
	_sum_label = make_label("", 64)
	_sum_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_sum_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	body.add_child(_sum_label)
	_timer_bar = ProgressBar.new()
	_timer_bar.show_percentage = false
	_timer_bar.custom_minimum_size = Vector2(0, 32)
	body.add_child(_timer_bar)
	for i: int in 3:
		var button := make_button("", 180)
		button.pressed.connect(_answer.bind(i))
		body.add_child(button)
		_choices.append(button)
	_show_question()


func _process(delta: float) -> void:
	if is_done():
		return
	_time_left -= delta
	_timer_bar.value = 100.0 * _time_left / ExpenseLogic.TIME_PER_QUESTION_S[difficulty]
	if _time_left <= 0.0:
		_next()


func _answer(choice: int) -> void:
	if is_done():
		return
	var picked: int = (_question["choices"] as Array)[choice]
	if picked == int(_question["answer"]):
		_correct += 1
	_next()


func _next() -> void:
	_index += 1
	if _index >= ExpenseLogic.QUESTION_COUNT:
		finish(ExpenseLogic.score(_correct))
		return
	_show_question()


func _show_question() -> void:
	_question = ExpenseLogic.make_question(rng, difficulty)
	var parts: PackedStringArray = []
	for term: int in _question["terms"]:
		parts.append("¥%d" % term)
	_sum_label.text = " + ".join(parts) + " = ?"
	var choices: Array = _question["choices"]
	for i: int in _choices.size():
		_choices[i].text = "¥%d" % int(choices[i])
	_time_left = ExpenseLogic.TIME_PER_QUESTION_S[difficulty]
	set_status(
		tr("MINIGAME_STATUS_PROGRESS").format(
			{"n": _index + 1, "total": ExpenseLogic.QUESTION_COUNT, "score": _correct}
		)
	)
