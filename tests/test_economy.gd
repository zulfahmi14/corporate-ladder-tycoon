extends TestSuite


func test_coworker_cost_grows_by_growth_factor() -> void:
	assert_near(Economy.coworker_cost(0, 0), 15.0)
	assert_near(Economy.coworker_cost(0, 1), 15.0 * 1.15)


func test_coworker_bulk_cost_equals_sum_of_singles() -> void:
	var total: float = 0.0
	for n: int in 10:
		total += Economy.coworker_cost(2, 5 + n)
	assert_near(Economy.coworker_bulk_cost(2, 5, 10), total, 1e-9)


func test_coworker_max_affordable_never_overspends() -> void:
	for money: float in [0.0, 14.9, 15.0, 1000.0, 1.0e9, 1.0e15]:
		var n: int = Economy.coworker_max_affordable(0, 3, money)
		assert_true(Economy.coworker_bulk_cost(0, 3, n) <= money, "money %s" % money)
		assert_true(Economy.coworker_bulk_cost(0, 3, n + 1) > money, "money %s" % money)


func test_milestone_mult_doubles_per_milestone() -> void:
	assert_near(Economy.milestone_mult(9), 1.0)
	assert_near(Economy.milestone_mult(10), 2.0)
	assert_near(Economy.milestone_mult(200), 64.0)


func test_coworker_unlocks_one_tier_per_rank() -> void:
	assert_true(Economy.is_coworker_unlocked(2, 0))
	assert_true(not Economy.is_coworker_unlocked(3, 0))
	assert_true(Economy.is_coworker_unlocked(7, 5))


func test_xp_is_ten_at_requirement_and_twenty_at_four_times() -> void:
	var req: float = EconomyData.RANK_REQUIREMENTS[0]
	assert_eq(Economy.xp_for_promotion(0, req), 10)
	assert_eq(Economy.xp_for_promotion(0, req * 4.0), 20)


func test_offline_earnings_capped_and_clamped() -> void:
	assert_near(Economy.offline_earnings(10.0, 3600.0, 0, 0), 10.0 * 3600.0 * 0.5)
	assert_near(Economy.offline_earnings(10.0, 99999.0, 0, 0), 10.0 * 2.0 * 3600.0 * 0.5)
	assert_near(Economy.offline_earnings(10.0, 99999.0, 0, 1), 10.0 * 8.0 * 3600.0 * 0.5)
	assert_near(Economy.offline_earnings(10.0, -500.0, 3, 0), 0.0)
