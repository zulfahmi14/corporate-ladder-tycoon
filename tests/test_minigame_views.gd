extends TestSuite
## Smoke test: every mini game screen runs to the end at every difficulty without errors.

const FRAME_S: float = 1.0 / 30.0
const MAX_FRAMES: int = 30 * 120

var _score: float = -1.0


func _on_finished(score: float) -> void:
	_score = score


func _play(view: MinigameView, diff: int, press: Callable) -> float:
	_score = -1.0
	view.setup(diff, 42)
	view.finished.connect(_on_finished)
	var root: Window = (Engine.get_main_loop() as SceneTree).root
	root.add_child(view)
	# The runner works inside SceneTree._initialize, where _ready is not fired for new nodes;
	# in the game the hub adds views to a live tree, so this only stands in for the engine.
	if not view.is_node_ready():
		view._ready()
	for frame: int in MAX_FRAMES:
		if view.is_done():
			break
		view._process(FRAME_S)
		if frame % 20 == 0:
			press.call()
	root.remove_child(view)
	view.free()
	return _score


func _check(make: Callable, press_method: String, arg: Variant) -> void:
	for diff: int in 3:
		var view: MinigameView = make.call()
		var press := func() -> void:
			if not view.is_done():
				if arg == null:
					view.call(press_method)
				else:
					view.call(press_method, arg)
		var score: float = _play(view, diff, press)
		assert_true(score >= 0.0 and score <= 1.0, "difficulty %d score %s" % [diff, score])


func test_hanko_runs_to_end() -> void:
	_check(func() -> MinigameView: return HankoView.new(), "_on_cell_pressed", 4)


func test_inbox_runs_to_end() -> void:
	_check(func() -> MinigameView: return InboxView.new(), "_answer", true)


func test_expense_runs_to_end() -> void:
	_check(func() -> MinigameView: return ExpenseView.new(), "_answer", 0)


func test_pitch_runs_to_end() -> void:
	_check(func() -> MinigameView: return PitchView.new(), "_on_stop", null)


func test_board_runs_to_end() -> void:
	_check(func() -> MinigameView: return BoardView.new(), "_on_dept_pressed", 0)


func test_hub_builds_rows_once_and_updates_in_place() -> void:
	if GameState.state == null:
		GameState.state = PlayerState.new()  # autoload _ready does not run in the runner
	var hub := MinigameHub.new()
	var root: Window = (Engine.get_main_loop() as SceneTree).root
	root.add_child(hub)
	if not hub.is_node_ready():
		hub._ready()
	var first: Node = hub._rows.get_child(0)
	hub._refresh()
	hub._refresh()
	assert_eq(hub._rows.get_child_count(), MinigameRules.count())
	assert_true(hub._rows.get_child(0) == first, "rows must not be rebuilt")
	root.remove_child(hub)
	hub.free()
