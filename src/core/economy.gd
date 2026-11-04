class_name Economy
extends RefCounted
## Pure economy formulas. No state, no nodes: everything here is unit tested.


## Cost of the next coworker of type [param index] when [param owned] are owned.
static func coworker_cost(index: int, owned: int) -> float:
	return EconomyData.COWORKER_BASE_COSTS[index] * pow(EconomyData.COWORKER_GROWTH, owned)


## Total cost of buying [param count] coworkers starting from [param owned].
static func coworker_bulk_cost(index: int, owned: int, count: int) -> float:
	if count <= 0:
		return 0.0
	var g: float = EconomyData.COWORKER_GROWTH
	return coworker_cost(index, owned) * (pow(g, count) - 1.0) / (g - 1.0)


## How many coworkers [param money] can buy (the "Max" button).
static func coworker_max_affordable(index: int, owned: int, money: float) -> int:
	var first: float = coworker_cost(index, owned)
	if money < first:
		return 0
	var g: float = EconomyData.COWORKER_GROWTH
	var count: int = floori(log(money * (g - 1.0) / first + 1.0) / log(g))
	# Float rounding can overshoot by one; never sell what the player cannot pay for.
	while count > 0 and coworker_bulk_cost(index, owned, count) > money:
		count -= 1
	return count


## Each milestone reached doubles that coworker type's income.
static func milestone_mult(owned: int) -> float:
	var reached: int = 0
	for milestone: int in EconomyData.MILESTONES:
		if owned >= milestone:
			reached += 1
	return pow(2.0, reached)


static func is_coworker_unlocked(index: int, rank: int) -> bool:
	return index < EconomyData.UNLOCKED_AT_INTERN + rank


static func coffee_cost(level: int) -> float:
	return EconomyData.COFFEE_BASE_COST * pow(EconomyData.COFFEE_GROWTH, level)


static func pc_cost(level: int) -> float:
	return EconomyData.PC_BASE_COST * pow(EconomyData.PC_GROWTH, level)


static func desk_cost(level: int) -> float:
	return EconomyData.DESK_BASE_COST * pow(EconomyData.DESK_GROWTH, level)


## Permanent multiplier M = 2^rank * (1 + 0.02 XP) * (1 + 0.5 careers).
static func permanent_mult(rank: int, xp: int, careers: int) -> float:
	return (
		EconomyData.RANK_INCOME_MULT[rank]
		* (1.0 + EconomyData.XP_INCOME_BONUS * xp)
		* (1.0 + EconomyData.FOUNDER_BONUS * careers)
	)


## Coworker income per second before temporary boosts.
static func coworker_income(owned: Array[int], desk_level: int, perm: float) -> float:
	var raw: float = 0.0
	for i: int in owned.size():
		raw += owned[i] * EconomyData.COWORKER_BASE_INCOME[i] * milestone_mult(owned[i])
	return raw * pow(EconomyData.DESK_MULT_PER_LEVEL, desk_level) * perm


## Yen earned by one tap.
static func tap_value(coffee_level: int, pc_level: int, coworker_ps: float, perm: float) -> float:
	return (1.0 + coffee_level) * perm + EconomyData.PC_TAP_SHARE_PER_LEVEL * pc_level * coworker_ps


static func can_promote(rank: int, run_earned: float) -> bool:
	return run_earned >= EconomyData.RANK_REQUIREMENTS[rank]


## XP = floor(10 * sqrt(E / R)); waiting past the requirement pays more.
static func xp_for_promotion(rank: int, run_earned: float) -> int:
	return floori(
		EconomyData.XP_PER_PROMOTION_K * sqrt(run_earned / EconomyData.RANK_REQUIREMENTS[rank])
	)


static func offline_cap_s(rank: int, careers: int) -> float:
	if careers > 0:
		return EconomyData.OFFLINE_MAX_CAP_H * 3600.0
	return (EconomyData.OFFLINE_BASE_CAP_H + rank) * 3600.0


## Offline payout; negative elapsed time (clock moved back) pays nothing.
static func offline_earnings(
	coworker_ps: float, elapsed_s: float, rank: int, careers: int
) -> float:
	var t: float = clampf(elapsed_s, 0.0, offline_cap_s(rank, careers))
	return coworker_ps * t * EconomyData.OFFLINE_EFFICIENCY
