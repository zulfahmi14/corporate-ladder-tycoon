extends TestSuite


func test_roundtrip_keeps_fields() -> void:
	var s := PlayerState.new()
	s.rank = 2
	s.reset_run()
	s.yen = 12345.5
	s.board[3] = 7
	s.bubbles[3] = 42.0
	s.xp = 42
	s.actions_left = 17
	s.sound_on = false
	var back: PlayerState = SaveCodec.decode(SaveCodec.encode(s))
	assert_true(back != null)
	assert_near(back.yen, 12345.5)
	assert_eq(back.board.size(), Economy.board_size(2))
	assert_eq(back.board[3], 7)
	assert_near(back.bubbles[3], 42.0)
	assert_eq(back.xp, 42)
	assert_eq(back.actions_left, 17)
	assert_eq(back.sound_on, false)


func test_garbage_is_rejected() -> void:
	assert_true(SaveCodec.decode("not json") == null)
	assert_true(SaveCodec.decode("[1,2]") == null)
	assert_true(SaveCodec.decode('{"version": 99, "state": {}}') == null)


func test_bad_values_are_sanitized() -> void:
	var text := '{"version": 2, "state": {"yen": -5, "rank": 99, "board": ["x", 30], "xp": "lots"}}'
	var s: PlayerState = SaveCodec.decode(text)
	assert_near(s.yen, 0.0)
	assert_eq(s.rank, EconomyData.CEO_RANK)
	assert_eq(s.board[0], 0)
	assert_eq(s.board[1], EconomyData.MAX_LEVEL)
	assert_eq(s.xp, 0)


func test_v1_save_keeps_rank_and_xp_but_starts_fresh_board() -> void:
	var text := '{"version": 1, "state": {"yen": 9e9, "rank": 1, "xp": 10, "owned": [5, 3]}}'
	var s: PlayerState = SaveCodec.decode(text)
	assert_eq(s.rank, 1)
	assert_eq(s.xp, 10)
	assert_near(s.yen, 0.0)
	assert_eq(s.board.count(0), s.board.size())
	assert_true(not s.run_started)
