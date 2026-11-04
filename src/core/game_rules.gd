class_name GameRules
extends RefCounted
## Actions that change a PlayerState. Pure: no nodes, no clock, no randomness.


static func perm_mult(s: PlayerState) -> float:
	return Economy.permanent_mult(s.rank, s.xp, s.careers)


static func coworker_ps(s: PlayerState) -> float:
	return Economy.coworker_income(s.owned, s.desk_level, perm_mult(s))


static func tap_value(s: PlayerState) -> float:
	return Economy.tap_value(s.coffee_level, s.pc_level, coworker_ps(s), perm_mult(s))


static func earn(s: PlayerState, amount: float) -> void:
	if amount <= 0.0 or is_nan(amount):
		return
	s.yen += amount
	s.run_earned += amount


## Yen earned for one tap; returns the amount.
static func tap(s: PlayerState) -> float:
	var amount: float = tap_value(s) * boost_mult(s)
	earn(s, amount)
	return amount


## Temporary multiplier from the 2x-income ad (overtime is applied by the caller).
static func boost_mult(s: PlayerState) -> float:
	return EconomyData.AD_2X_MULT if s.ad_2x_left_s > 0.0 else 1.0


static func buy_coworker(s: PlayerState, index: int, count: int) -> bool:
	if count <= 0 or not Economy.is_coworker_unlocked(index, s.rank):
		return false
	var cost: float = Economy.coworker_bulk_cost(index, s.owned[index], count)
	if cost > s.yen:
		return false
	s.yen -= cost
	s.owned[index] += count
	return true


static func buy_coffee(s: PlayerState) -> bool:
	return _pay(s, Economy.coffee_cost(s.coffee_level)) and _inc(s, "coffee_level")


static func buy_pc(s: PlayerState) -> bool:
	if s.pc_level >= EconomyData.PC_MAX_LEVEL:
		return false
	return _pay(s, Economy.pc_cost(s.pc_level)) and _inc(s, "pc_level")


static func buy_desk(s: PlayerState) -> bool:
	return _pay(s, Economy.desk_cost(s.desk_level)) and _inc(s, "desk_level")


## Promotion = prestige reset. Returns XP gained, or -1 if not allowed.
static func promote(s: PlayerState) -> int:
	if s.rank >= EconomyData.CEO_RANK or not Economy.can_promote(s.rank, s.run_earned):
		return -1
	var gained: int = Economy.xp_for_promotion(s.rank, s.run_earned)
	s.xp += gained
	s.rank += 1
	s.reset_run()
	return gained


## "Found your own company": back to Intern with +1 career. Returns success.
static func found_company(s: PlayerState) -> bool:
	if s.rank != EconomyData.CEO_RANK or not Economy.can_promote(s.rank, s.run_earned):
		return false
	s.xp += Economy.xp_for_promotion(s.rank, s.run_earned)
	s.careers += 1
	s.rank = 0
	s.reset_run()
	return true


## Pays offline earnings for the gap since last_seen_unix; returns the amount.
static func collect_offline(s: PlayerState, now_unix: float, doubled: bool) -> float:
	var amount: float = Economy.offline_earnings(
		coworker_ps(s), now_unix - s.last_seen_unix, s.rank, s.careers
	)
	if doubled:
		amount *= 2.0
	earn(s, amount)
	return amount


static func _pay(s: PlayerState, cost: float) -> bool:
	if cost > s.yen:
		return false
	s.yen -= cost
	return true


static func _inc(s: PlayerState, field: String) -> bool:
	s.set(field, int(s.get(field)) + 1)
	return true
