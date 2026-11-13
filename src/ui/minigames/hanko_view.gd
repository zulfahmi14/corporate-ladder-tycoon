class_name HankoView
extends MinigameView
## Hanko Stamp: tap approved documents before they disappear; avoid rejected ones.

enum Cell { EMPTY, GOOD, BAD }

var _buttons: Array[Button] = []
var _cells: Array[int] = []
var _life: Array[float] = []
var _elapsed: float = 0.0
var _spawn_timer: float = 0.0
var _good_shown: int = 0
var _stamped_good: int = 0
var _stamped_bad: int = 0


func _title_key() -> String:
	return "MINIGAME_HANKO"


func _build(body: VBoxContainer) -> void:
	var grid := GridContainer.new()
	grid.columns = 3
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 16)
	grid.add_theme_constant_override("v_separation", 16)
	body.add_child(grid)
	for i: int in HankoLogic.GRID_CELLS:
		var button := make_button("", 180)
		button.size_flags_vertical = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_on_cell_pressed.bind(i))
		grid.add_child(button)
		_buttons.append(button)
		_cells.append(Cell.EMPTY)
		_life.append(0.0)
		_show_cell(i)


func _process(delta: float) -> void:
	if is_done():
		return
	_elapsed += delta
	for i: int in _cells.size():
		if _cells[i] != Cell.EMPTY:
			_life[i] -= delta
			if _life[i] <= 0.0:
				_clear(i)
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_timer = HankoLogic.SPAWN_EVERY_S[difficulty]
		_spawn()
	var left: float = maxf(0.0, HankoLogic.DURATION_S - _elapsed)
	set_status(
		tr("MINIGAME_STATUS_TIME_SCORE").format(
			{"time": "%.0f" % left, "score": _stamped_good - _stamped_bad}
		)
	)
	if left <= 0.0:
		finish(HankoLogic.score(_stamped_good, _stamped_bad, _good_shown))


func _spawn() -> void:
	var empty: Array[int] = []
	for i: int in _cells.size():
		if _cells[i] == Cell.EMPTY:
			empty.append(i)
	if empty.is_empty():
		return
	var cell: int = empty[rng.randi_range(0, empty.size() - 1)]
	var bad: bool = rng.randf() < HankoLogic.REJECT_CHANCE[difficulty]
	_cells[cell] = Cell.BAD if bad else Cell.GOOD
	_life[cell] = HankoLogic.LIFETIME_S[difficulty]
	if not bad:
		_good_shown += 1
	_show_cell(cell)


func _on_cell_pressed(cell: int) -> void:
	if is_done() or _cells[cell] == Cell.EMPTY:
		return
	if _cells[cell] == Cell.GOOD:
		_stamped_good += 1
	else:
		_stamped_bad += 1
	_clear(cell)


func _clear(cell: int) -> void:
	_cells[cell] = Cell.EMPTY
	_show_cell(cell)


func _show_cell(cell: int) -> void:
	var button: Button = _buttons[cell]
	match _cells[cell]:
		Cell.GOOD:
			button.text = tr("HANKO_GOOD_DOC")
			paint(button, GOOD_COLOR)
		Cell.BAD:
			button.text = tr("HANKO_BAD_DOC")
			paint(button, BAD_COLOR)
		_:
			button.text = ""
			paint(button, DIM_COLOR)
