extends TestSuite
## Compares GDScript formulas with tools/sim/economy.py via a generated fixture.
## Regenerate: python3 tools/sim/export_parity.py

const FIXTURE := "res://tests/fixtures/economy_parity.json"


func test_constants_and_formulas_match_python() -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(FIXTURE))
	var c: Dictionary = data["constants"]
	for i: int in EconomyData.RANK_INCOME_MULT.size():
		assert_near(EconomyData.RANK_INCOME_MULT[i], c["rank_income_mult"][i])
		assert_eq(EconomyData.GOAL_LEVEL[i], int(c["goal_level"][i]))
		assert_eq(EconomyData.GOAL_COUNT[i], int(c["goal_count"][i]))
		assert_near(EconomyData.HIRE_BASE_COST[i], c["hire_base_cost"][i])
	assert_eq(EconomyData.LEVEL_INCOME.size(), (c["level_income"] as Array).size())
	for i: int in EconomyData.LEVEL_INCOME.size():
		assert_near(EconomyData.LEVEL_INCOME[i], c["level_income"][i])
	var scalars: Dictionary = {
		"hire_growth": EconomyData.HIRE_GROWTH,
		"starting_team": EconomyData.STARTING_TEAM,
		"actions_per_day": EconomyData.ACTIONS_PER_DAY,
		"actions_ad_bonus": EconomyData.ACTIONS_AD_BONUS,
		"bubble_active_cap_s": EconomyData.BUBBLE_ACTIVE_CAP_S,
		"pc_cap_s_per_level": EconomyData.PC_CAP_S_PER_LEVEL,
		"coffee_bonus": EconomyData.COFFEE_BONUS,
		"desk_mult": EconomyData.DESK_MULT,
		"xp_per_promotion": EconomyData.XP_PER_PROMOTION,
		"offline_efficiency": EconomyData.OFFLINE_EFFICIENCY,
		"board_cols": EconomyData.BOARD_COLS,
		"board_rows_base": EconomyData.BOARD_ROWS_BASE,
	}
	for key: String in scalars:
		assert_near(float(scalars[key]), float(c[key]), 1e-9, key)
	for case: Dictionary in data["cases"]:
		var perm: float = Economy.permanent_mult(case["rank"], case["xp"], case["careers"])
		assert_near(perm, case["perm"], 1e-9, "perm %s" % case)
		var mult: float = Economy.upgrade_mult(case["coffee"], case["desk"])
		assert_near(mult, case["upgrade_mult"], 1e-9, "upgrade %s" % case)
		assert_near(
			Economy.hire_cost(case["rank"], case["hires"]),
			case["hire_cost"],
			1e-9,
			"hire %s" % case
		)
		var board: Array[int] = []
		for lv: Variant in case["board"]:
			board.append(int(lv))
		assert_eq(Economy.goal_progress(board, case["rank"]), int(case["goal_progress"]))
		var income: float = 0.0
		for lv: int in board:
			income += Economy.level_income(lv) * perm * mult
		assert_near(income, case["income_ps"], 1e-9, "income %s" % case)


func test_minigame_constants_match_python() -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(FIXTURE))
	var c: Dictionary = data["constants"]
	assert_eq(MinigameData.KEYS.size(), (c["minigame_keys"] as Array).size())
	for i: int in MinigameData.KEYS.size():
		assert_eq(MinigameData.KEYS[i], c["minigame_keys"][i])
		assert_eq(MinigameData.UNLOCK_RANK[i], int(c["minigame_unlock_rank"][i]))
		assert_near(MinigameData.BASE_SECONDS[i], c["minigame_base_seconds"][i])
	for i: int in MinigameData.DIFFICULTY_MULT.size():
		assert_near(MinigameData.DIFFICULTY_MULT[i], c["minigame_difficulty_mult"][i])
	assert_near(MinigameData.COOLDOWN_S, c["minigame_cooldown_s"])
	assert_near(MinigameData.BASIS_PER_MULT, c["minigame_basis_per_mult"])
