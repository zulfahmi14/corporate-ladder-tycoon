extends TestSuite


func test_roundtrip_keeps_fields() -> void:
	var s := PlayerState.new()
	s.yen = 12345.5
	s.owned[2] = 7
	s.rank = 3
	s.xp = 42
	s.sound_on = false
	var back: PlayerState = SaveCodec.decode(SaveCodec.encode(s))
	assert_true(back != null)
	assert_near(back.yen, 12345.5)
	assert_eq(back.owned[2], 7)
	assert_eq(back.rank, 3)
	assert_eq(back.xp, 42)
	assert_eq(back.sound_on, false)


func test_garbage_is_rejected() -> void:
	assert_true(SaveCodec.decode("not json") == null)
	assert_true(SaveCodec.decode("[1,2]") == null)
	assert_true(SaveCodec.decode('{"version": 99, "state": {}}') == null)


func test_bad_values_are_sanitized() -> void:
	var text := '{"version": 1, "state": {"yen": -5, "rank": 99, "owned": ["x", 3], "xp": "lots"}}'
	var s: PlayerState = SaveCodec.decode(text)
	assert_near(s.yen, 0.0)
	assert_eq(s.rank, EconomyData.CEO_RANK)
	assert_eq(s.owned[0], 0)
	assert_eq(s.owned[1], 3)
	assert_eq(s.xp, 0)
