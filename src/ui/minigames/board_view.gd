class_name BoardView
extends MinigameView
## Board Meeting: watch which departments speak, then tap them in the same order.

const DEPT_KEYS: Array[String] = ["BOARD_SALES", "BOARD_HR", "BOARD_IT", "BOARD_FINANCE"]
const DEPT_COLORS: Array[Color] = [
	Color(0.95, 0.6, 0.4),
	Color(0.6, 0.8, 0.95),
	Color(0.6, 0.9, 0.6),
	Color(0.95, 0.85, 0.45),
]

const GAP_RATIO: float = 0.35

var _buttons: Array[Button] = []
var _sequence: Array[int] = []
var _round: int = 0
var _show_index: int = 0
var _show_timer: float = 0.0
var _input_index: int = 0
var _showing: bool = false


func _title_key() -> String:
	return "MINIGAME_BOARD"


func _build(body: VBoxContainer) -> void:
	var grid := GridContainer.new()
	grid.columns = 2
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 24)
	grid.add_theme_constant_override("v_separation", 24)
	body.add_child(grid)
	for i: int in BoardLogic.DEPARTMENTS:
		var button := make_button(tr(DEPT_KEYS[i]), 360)
		button.size_flags_vertical = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_on_dept_pressed.bind(i))
		grid.add_child(button)
		_buttons.append(button)
	_start_round()


func _process(delta: float) -> void:
	if is_done() or not _showing:
		return
	_show_timer -= delta
	if _show_timer > 0.0:
		return
	_show_index += 1
	if _show_index >= _sequence.size() * 2:
		_showing = false
		_highlight_all()
		set_status(tr("BOARD_YOUR_TURN"))
		return
	# Even steps light a department, odd steps are a short gap so repeats are visible.
	var lit: bool = _show_index % 2 == 0
	_show_timer = BoardLogic.SHOW_STEP_S[difficulty] * (1.0 if lit else GAP_RATIO)
	_highlight(_sequence[int(_show_index / 2.0)] if lit else -1)


func _on_dept_pressed(dept: int) -> void:
	if is_done() or _showing:
		return
	if dept != _sequence[_input_index]:
		finish(BoardLogic.score(_round))
		return
	_input_index += 1
	if _input_index < _sequence.size():
		return
	_round += 1
	if _round >= BoardLogic.ROUNDS:
		finish(BoardLogic.score(_round))
		return
	_start_round()


func _start_round() -> void:
	_sequence = BoardLogic.make_sequence(rng, BoardLogic.sequence_length(difficulty, _round))
	_input_index = 0
	_show_index = 0
	_showing = true
	_show_timer = BoardLogic.SHOW_STEP_S[difficulty]
	_highlight(_sequence[0])
	set_status(tr("BOARD_WATCH").format({"n": _round + 1, "total": BoardLogic.ROUNDS}))


func _highlight_all() -> void:
	for i: int in _buttons.size():
		paint(_buttons[i], DEPT_COLORS[i])


func _highlight(dept: int) -> void:
	for i: int in _buttons.size():
		paint(_buttons[i], DEPT_COLORS[i] if i == dept else DEPT_COLORS[i].darkened(0.75))
