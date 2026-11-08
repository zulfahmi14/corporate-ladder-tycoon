extends TestSuite


func test_board_grows_one_row_per_rank() -> void:
	assert_eq(Economy.board_size(0), 20)
	assert_eq(Economy.board_size(5), 40)


func test_hire_cost_grows_per_hire() -> void:
	assert_near(Economy.hire_cost(0, 0), EconomyData.HIRE_BASE_COST[0])
	assert_near(Economy.hire_cost(0, 2), EconomyData.HIRE_BASE_COST[0] * 1.06 * 1.06)


func test_each_level_earns_three_times_the_last() -> void:
	for level: int in range(2, EconomyData.MAX_LEVEL + 1):
		assert_near(Economy.level_income(level), Economy.level_income(level - 1) * 3.0)
	assert_near(Economy.level_income(0), 0.0)


func test_goal_counts_coworkers_at_or_above_goal_level() -> void:
	var board: Array[int] = [4, 5, 3, 0, 4]
	assert_eq(Economy.goal_progress(board, 0), 3)
	assert_true(Economy.goal_met(board, 0))
	assert_true(not Economy.goal_met(board, 1))


func test_neighbors_respect_edges() -> void:
	var size: int = 20
	assert_eq(Economy.neighbors(0, size), [4, 1] as Array[int])
	assert_true(Economy.are_neighbors(3, 7, size))
	assert_true(not Economy.are_neighbors(3, 4, size), "row wrap is not a neighbour")
	assert_eq(Economy.neighbors(19, size).size(), 2)


func test_upgrade_mult_combines_coffee_and_desk() -> void:
	assert_near(Economy.upgrade_mult(2, 1), 1.2 * 1.5)


func test_action_day_rolls_over_at_four_am() -> void:
	var day_start: float = 20000.0 * 86400.0
	assert_eq(Economy.action_day(day_start + 3.9 * 3600.0), Economy.action_day(day_start - 3600.0))
	assert_true(Economy.action_day(day_start + 4.1 * 3600.0) > Economy.action_day(day_start))


func test_offline_cap_grows_with_rank_and_maxes_for_founders() -> void:
	assert_near(Economy.offline_cap_s(0, 0), 2.0 * 3600.0)
	assert_near(Economy.offline_cap_s(5, 0), 7.0 * 3600.0)
	assert_near(Economy.offline_cap_s(0, 1), 8.0 * 3600.0)
