extends TestSuite


func _rng() -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1234
	return rng


func _count(s: PlayerState, level: int) -> int:
	return s.board.count(level)


func test_start_run_seats_starting_team_once() -> void:
	var s := PlayerState.new()
	GameRules.start_run(s, _rng())
	GameRules.start_run(s, _rng())
	assert_eq(_count(s, 1), EconomyData.STARTING_TEAM)


func test_hire_seats_at_random_free_desk_and_charges() -> void:
	var s := PlayerState.new()
	s.yen = 1.0e6
	var desk: int = GameRules.hire(s, _rng())
	assert_true(desk >= 0)
	assert_eq(s.board[desk], 1)
	assert_near(s.yen, 1.0e6 - EconomyData.HIRE_BASE_COST[0])
	assert_eq(s.hires, 1)


func test_hire_fails_when_poor_or_full() -> void:
	var s := PlayerState.new()
	assert_eq(GameRules.hire(s, _rng()), -1)
	s.yen = 1.0e30
	s.board.fill(1)
	assert_eq(GameRules.hire(s, _rng()), -1)


func test_merge_neighbours_levels_up_and_keeps_bubbles() -> void:
	var s := PlayerState.new()
	s.board[0] = 2
	s.board[1] = 2
	s.bubbles[0] = 10.0
	s.bubbles[1] = 5.0
	assert_eq(GameRules.desk_action(s, 0, 1), GameRules.DeskResult.MERGED)
	assert_eq(s.board[1], 3)
	assert_eq(s.board[0], 0)
	assert_near(s.bubbles[1], 15.0, 1e-9, "stored yen carries over (below new capacity)")
	assert_eq(s.actions_left, EconomyData.ACTIONS_PER_DAY - 1)


func test_merge_needs_neighbours() -> void:
	var s := PlayerState.new()
	s.board[0] = 2
	s.board[2] = 2
	assert_eq(GameRules.desk_action(s, 0, 2), GameRules.DeskResult.NOT_NEIGHBORS)
	assert_eq(s.actions_left, EconomyData.ACTIONS_PER_DAY, "failed merge costs nothing")


func test_move_costs_one_action_and_seats_never_swap() -> void:
	var s := PlayerState.new()
	s.board[0] = 1
	s.board[5] = 3
	assert_eq(GameRules.desk_action(s, 0, 10), GameRules.DeskResult.MOVED)
	assert_eq(s.board[10], 1)
	assert_eq(GameRules.desk_action(s, 10, 5), GameRules.DeskResult.OCCUPIED)
	assert_eq(s.board[5], 3)
	assert_eq(s.board[10], 1)
	assert_eq(s.actions_left, EconomyData.ACTIONS_PER_DAY - 1)


func test_no_actions_left_blocks_moves() -> void:
	var s := PlayerState.new()
	s.board[0] = 1
	s.actions_left = 0
	assert_eq(GameRules.desk_action(s, 0, 1), GameRules.DeskResult.NO_ACTIONS)
	assert_eq(s.board[0], 1)


func test_top_level_cannot_merge() -> void:
	var s := PlayerState.new()
	s.board[0] = EconomyData.MAX_LEVEL
	s.board[1] = EconomyData.MAX_LEVEL
	assert_eq(GameRules.desk_action(s, 0, 1), GameRules.DeskResult.MAX_LEVEL)


func test_actions_refill_on_new_day_and_ad_once_per_day() -> void:
	var s := PlayerState.new()
	GameRules.refresh_actions(s, 100)
	s.actions_left = 3
	GameRules.refresh_actions(s, 100)
	assert_eq(s.actions_left, 3)
	GameRules.grant_ad_actions(s)
	GameRules.grant_ad_actions(s)
	assert_eq(s.actions_left, 3 + EconomyData.ACTIONS_AD_BONUS)
	GameRules.refresh_actions(s, 101)
	assert_eq(s.actions_left, EconomyData.ACTIONS_PER_DAY)
	assert_true(GameRules.can_buy_ad_actions(s))


func test_bubble_fills_in_level_time_and_only_full_can_be_claimed() -> void:
	var s := PlayerState.new()
	s.board[0] = 3
	var cap: float = Economy.level_income(3) * 60.0  # Senpai fills in 60 s
	assert_near(GameRules.capacity(s, 0), cap)
	GameRules.fill_bubbles(s, 30.0)
	assert_near(GameRules.bubble_fraction(s, 0), 0.5)
	assert_near(GameRules.claim(s, 0), 0.0, 1e-9, "half-full bubble cannot be claimed")
	GameRules.fill_bubbles(s, 1000.0)
	assert_near(s.bubbles[0], cap, 1e-9, "a full bubble stops growing")
	assert_near(GameRules.claim(s, 0), cap)
	assert_near(s.yen, cap)
	assert_near(s.bubbles[0], 0.0)


func test_faster_pc_shortens_fill_time() -> void:
	assert_near(Economy.fill_seconds(3, 0), 60.0)
	assert_near(Economy.fill_seconds(3, 10), 36.0)


func test_away_time_fills_bubbles_once_and_pays_welcome_back_lump() -> void:
	var s := PlayerState.new()
	s.board[0] = 1
	s.last_seen_unix = 1000.0
	var added: float = GameRules.fill_offline(s, 1000.0 + 100000.0)
	assert_near(added, 0.5 * 2.0 * 3600.0 * 0.5)
	assert_true(GameRules.bubble_full(s, 0))
	assert_near(s.away_pending, added)
	assert_near(GameRules.collect_away(s, true), added * 2.0)
	assert_near(s.away_pending, 0.0)
	s.last_seen_unix = 5000.0
	assert_near(GameRules.fill_offline(s, 10.0), 0.0, 1e-9, "clock moved back pays nothing")


func test_stuck_only_when_full_without_pairs() -> void:
	var s := PlayerState.new()
	for i: int in s.board.size():
		s.board[i] = 1 + (i + int(i / 4.0)) % 2  # checkerboard of Lv1 and Lv2
	assert_true(GameRules.is_stuck(s))
	s.board[1] = 1  # now desk 0 and 1 are both Lv1 neighbours
	assert_true(not GameRules.is_stuck(s))
	s.board[1] = 2
	s.board[19] = 0
	assert_true(not GameRules.is_stuck(s), "an empty desk means a move is possible")


func test_fire_only_when_stuck_and_charges_by_level() -> void:
	var s := PlayerState.new()
	s.board[0] = 1
	s.yen = 1.0e9
	assert_near(GameRules.fire(s, 0), -1.0, 1e-9, "not stuck: cannot fire")
	for i: int in s.board.size():
		s.board[i] = 1 + (i + int(i / 4.0)) % 2
	assert_true(GameRules.fire_cost(s, 1) > GameRules.fire_cost(s, 0), "Lv2 costs more than Lv1")
	var fee: float = GameRules.fire(s, 0)
	assert_near(fee, Economy.level_income(1) * EconomyData.FIRE_SEVERANCE_S)
	assert_eq(s.board[0], 0)
	assert_near(s.yen, 1.0e9 - fee)


func test_fire_needs_enough_yen() -> void:
	var s := PlayerState.new()
	for i: int in s.board.size():
		s.board[i] = 1 + (i + int(i / 4.0)) % 2
	assert_near(GameRules.fire(s, 0), -1.0)
	assert_eq(s.board[0], 1)


func test_promotion_needs_goal_and_resets_board() -> void:
	var s := PlayerState.new()
	assert_eq(GameRules.promote(s, _rng()), -1)
	s.board[0] = 4
	s.board[7] = 5
	s.yen = 99.0
	assert_eq(GameRules.promote(s, _rng()), EconomyData.XP_PER_PROMOTION)
	assert_eq(s.rank, 1)
	assert_eq(s.board.size(), Economy.board_size(1))
	assert_eq(_count(s, 2), EconomyData.STARTING_TEAM, "new run seats Lv2 starters")
	assert_near(s.yen, 0.0)


func test_found_company_only_from_ceo_goal() -> void:
	var s := PlayerState.new()
	s.rank = EconomyData.CEO_RANK
	s.reset_run()
	assert_true(not GameRules.found_company(s, _rng()))
	s.board[0] = 10
	s.board[1] = 11
	assert_true(GameRules.found_company(s, _rng()))
	assert_eq(s.rank, 0)
	assert_eq(s.careers, 1)


func test_upgrades_raise_income() -> void:
	var s := PlayerState.new()
	s.board[0] = 3
	var before: float = GameRules.income_ps(s)
	s.yen = 1.0e9
	assert_true(GameRules.buy_coffee(s) and GameRules.buy_desk(s))
	assert_near(GameRules.income_ps(s), before * 1.1 * 1.5)
