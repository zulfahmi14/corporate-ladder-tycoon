extends TestSuite
## Smoke test: the real main screen handles hire, claim, merge, overlays and promotion.


func _main() -> Control:
	GameState.state = PlayerState.new()  # autoload _ready does not run in the runner
	GameState.rng.seed = 99
	GameRules.start_run(GameState.state, GameState.rng)
	var main: Control = load("res://src/ui/main/main.tscn").instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(main)
	if not main.is_node_ready():
		main._ready()
	return main


func _done(main: Control) -> void:
	main.get_parent().remove_child(main)
	main.free()


func test_hire_claim_merge_and_promote_through_the_screen() -> void:
	var main := _main()
	var s: PlayerState = GameState.state
	assert_eq(main.get("_cells").size(), s.board.size())
	s.yen = 1.0e9
	main.call("_on_hire")
	assert_eq(s.hires, 1)
	var desk: int = s.board.find(1)
	GameRules.fill_bubbles(s, 5.0)
	var yen_before: float = s.yen
	main.call("_on_desk_tapped", desk)
	assert_near(s.yen, yen_before, 1e-9, "a filling bubble cannot be collected")
	GameRules.fill_bubbles(s, 60.0)
	main.call("_on_desk_tapped", desk)
	assert_true(s.yen > yen_before, "tapping a full bubble pays")
	s.board.fill(0)
	s.board[0] = 3
	s.board[1] = 3
	main.call("_on_desk_dropped", 0, 1)
	assert_eq(s.board[1], 4)
	s.board[5] = 4
	main.call("_refresh")
	assert_true(main.get("_promote_button").visible)
	main.call("_on_promote")
	assert_eq(s.rank, 1)
	main.call("_refresh")
	assert_eq(main.get("_cells").size(), Economy.board_size(1))
	_done(main)


func test_overlays_open_and_close() -> void:
	var main := _main()
	main.call("_open_overlay", true)
	assert_true(main.get("_overlay") is UpgradesPanel)
	main.call("_close_overlay")
	main.call("_open_overlay", false)
	assert_true(main.get("_overlay") is MinigameHub)
	main.call("_close_overlay")
	_done(main)


func test_full_office_and_no_actions_show_toasts() -> void:
	var main := _main()
	var s: PlayerState = GameState.state
	s.board.fill(1)
	s.yen = 1.0e9
	main.call("_on_hire")
	assert_true(String(main.get("_toast").text) != "")
	s.actions_left = 0
	main.call("_on_desk_dropped", 0, 1)
	assert_eq(s.board[0], 1, "no actions: nothing merges")
	_done(main)


func test_stuck_office_shows_fire_and_fires_on_tap() -> void:
	var main := _main()
	var s: PlayerState = GameState.state
	for i: int in s.board.size():
		s.board[i] = 1 + (i + int(i / 4.0)) % 2
	s.yen = 1.0e6
	main.call("_refresh")
	assert_true(main.get("_fire_button").visible)
	main.call("_on_fire_button")
	main.call("_on_desk_tapped", 0)
	assert_eq(s.board[0], 0)
	main.call("_refresh")
	assert_true(not main.get("_fire_button").visible, "free desk: no longer stuck")
	_done(main)


func test_welcome_back_button_collects_away_earnings() -> void:
	var main := _main()
	var s: PlayerState = GameState.state
	s.away_pending = 500.0
	main.call("_refresh")
	assert_true(main.get("_away_button").visible)
	main.call("_on_collect_away")
	assert_near(s.yen, 500.0)
	main.call("_refresh")
	assert_true(not main.get("_away_button").visible)
	_done(main)
