extends TestSuite


func test_tap_earns_one_yen_at_start() -> void:
	var s := PlayerState.new()
	assert_near(GameRules.tap(s), 1.0)
	assert_near(s.yen, 1.0)
	assert_near(s.run_earned, 1.0)


func test_buy_coworker_spends_yen_and_fails_when_poor() -> void:
	var s := PlayerState.new()
	assert_true(not GameRules.buy_coworker(s, 0, 1))
	s.yen = 100.0
	assert_true(GameRules.buy_coworker(s, 0, 1))
	assert_eq(s.owned[0], 1)
	assert_near(s.yen, 85.0)


func test_locked_coworker_cannot_be_bought() -> void:
	var s := PlayerState.new()
	s.yen = 1.0e12
	assert_true(not GameRules.buy_coworker(s, 3, 1))


func test_pc_upgrade_stops_at_max_level() -> void:
	var s := PlayerState.new()
	s.yen = 1.0e15
	s.pc_level = EconomyData.PC_MAX_LEVEL
	assert_true(not GameRules.buy_pc(s))


func test_promote_resets_run_and_keeps_xp() -> void:
	var s := PlayerState.new()
	s.owned[0] = 50
	GameRules.earn(s, EconomyData.RANK_REQUIREMENTS[0])
	assert_eq(GameRules.promote(s), 10)
	assert_eq(s.rank, 1)
	assert_eq(s.xp, 10)
	assert_eq(s.owned[0], 0)
	assert_near(s.yen, 0.0)


func test_promote_refused_below_requirement() -> void:
	var s := PlayerState.new()
	GameRules.earn(s, 1.0)
	assert_eq(GameRules.promote(s), -1)
	assert_eq(s.rank, 0)


func test_found_company_only_from_ceo() -> void:
	var s := PlayerState.new()
	GameRules.earn(s, 1.0e30)
	assert_true(not GameRules.found_company(s))
	s.rank = EconomyData.CEO_RANK
	assert_true(GameRules.found_company(s))
	assert_eq(s.rank, 0)
	assert_eq(s.careers, 1)


func test_collect_offline_doubles_with_ad() -> void:
	var s := PlayerState.new()
	s.owned[0] = 10
	s.last_seen_unix = 1000.0
	var plain: float = GameRules.collect_offline(s, 4600.0, false)
	var doubled: float = GameRules.collect_offline(s, 4600.0, true)
	assert_true(plain > 0.0)
	assert_near(doubled, plain * 2.0)
