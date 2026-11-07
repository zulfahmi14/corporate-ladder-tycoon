extends TestSuite
## Compares GDScript formulas with tools/sim/economy.py via a generated fixture.
## Regenerate: python3 tools/sim/export_parity.py

const FIXTURE := "res://tests/fixtures/economy_parity.json"


func test_constants_and_formulas_match_python() -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(FIXTURE))
	var c: Dictionary = data["constants"]
	assert_eq(EconomyData.RANK_REQUIREMENTS.size(), (c["rank_requirements"] as Array).size())
	for i: int in EconomyData.RANK_REQUIREMENTS.size():
		assert_near(EconomyData.RANK_REQUIREMENTS[i], c["rank_requirements"][i])
		assert_near(EconomyData.RANK_INCOME_MULT[i], c["rank_income_mult"][i])
	for i: int in EconomyData.COWORKER_BASE_COSTS.size():
		assert_near(EconomyData.COWORKER_BASE_COSTS[i], c["coworker_costs"][i])
		assert_near(EconomyData.COWORKER_BASE_INCOME[i], c["coworker_income"][i])
	for case: Dictionary in data["cases"]:
		var owned: Array[int] = []
		for n: Variant in case["owned"]:
			owned.append(int(n))
		var perm: float = Economy.permanent_mult(case["rank"], case["xp"], case["careers"])
		var ps: float = Economy.coworker_income(owned, case["desk"], perm)
		assert_near(perm, case["perm"], 1e-9, "perm %s" % case)
		assert_near(ps, case["coworker_ps"], 1e-9, "ps %s" % case)
		var tap: float = Economy.tap_value(case["coffee"], case["pc"], ps, perm)
		assert_near(tap, case["tap"], 1e-9, "tap %s" % case)


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
	assert_near(MinigameData.TAP_EQUIV_PER_S, c["minigame_tap_equiv_per_s"])
