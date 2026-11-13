class_name GameRules
extends RefCounted
## Actions that change a PlayerState. Pure: randomness comes in as an RNG, time as numbers.

enum DeskResult { MERGED, MOVED, OCCUPIED, NO_ACTIONS, NOT_NEIGHBORS, MAX_LEVEL, INVALID }


static func perm_mult(s: PlayerState) -> float:
	return Economy.permanent_mult(s.rank, s.xp, s.careers)


static func income_mult(s: PlayerState) -> float:
	return perm_mult(s) * Economy.upgrade_mult(s.coffee_level, s.desk_level)


## Yen per second the coworker at [param desk] produces before temporary boosts.
static func desk_rate(s: PlayerState, desk: int) -> float:
	return Economy.level_income(s.board[desk]) * income_mult(s)


static func income_ps(s: PlayerState) -> float:
	var total: float = 0.0
	for desk: int in s.board.size():
		total += desk_rate(s, desk)
	return total


## Temporary multiplier from the 2x-income ad.
static func boost_mult(s: PlayerState) -> float:
	return EconomyData.AD_2X_MULT if s.ad_2x_left_s > 0.0 else 1.0


static func earn(s: PlayerState, amount: float) -> void:
	if amount <= 0.0 or is_nan(amount):
		return
	s.yen += amount
	s.run_earned += amount


## Seats the free starting team at random desks once per run.
static func start_run(s: PlayerState, rng: RandomNumberGenerator) -> void:
	if s.run_started:
		return
	s.run_started = true
	for i: int in EconomyData.STARTING_TEAM:
		_seat_random(s, rng, Economy.hire_level(s.rank))


## Full size of the bubble at [param desk].
static func capacity(s: PlayerState, desk: int) -> float:
	var level: int = s.board[desk]
	if level == 0:
		return 0.0
	return desk_rate(s, desk) * EconomyData.FILL_S[level - 1]


## Bubbles fill toward their capacity, then stop until they are tapped.
static func fill_bubbles(s: PlayerState, seconds: float) -> void:
	var boost: float = boost_mult(s)
	for desk: int in s.board.size():
		var level: int = s.board[desk]
		if level == 0:
			continue
		var cap: float = capacity(s, desk)
		var speed: float = cap / Economy.fill_seconds(level, s.pc_level)
		s.bubbles[desk] = minf(cap, s.bubbles[desk] + speed * seconds * boost)


static func bubble_full(s: PlayerState, desk: int) -> bool:
	return s.board[desk] > 0 and s.bubbles[desk] >= capacity(s, desk) * 0.9999


## 0..1 for the progress bar under each coworker.
static func bubble_fraction(s: PlayerState, desk: int) -> float:
	var cap: float = capacity(s, desk)
	return clampf(s.bubbles[desk] / cap, 0.0, 1.0) if cap > 0.0 else 0.0


## Tapping a full bubble collects it; a partly filled one cannot be collected yet.
static func claim(s: PlayerState, desk: int) -> float:
	if not bubble_full(s, desk):
		return 0.0
	var amount: float = s.bubbles[desk]
	s.bubbles[desk] = 0.0
	earn(s, amount)
	return amount


## Time away: every bubble fills (once), and 50% of income for the capped time
## waits in away_pending for the "Welcome back" button. Returns the amount added.
static func fill_offline(s: PlayerState, now_unix: float) -> float:
	var elapsed: float = clampf(
		now_unix - s.last_seen_unix, 0.0, Economy.offline_cap_s(s.rank, s.careers)
	)
	if elapsed <= 0.0:
		return 0.0
	var amount: float = income_ps(s) * elapsed * EconomyData.OFFLINE_EFFICIENCY
	s.away_pending += amount
	fill_bubbles(s, elapsed)
	return amount


static func collect_away(s: PlayerState, doubled: bool) -> float:
	var amount: float = s.away_pending * (2.0 if doubled else 1.0)
	s.away_pending = 0.0
	earn(s, amount)
	return amount


## Stuck: every desk is taken and no neighbouring pair can merge.
static func is_stuck(s: PlayerState) -> bool:
	var size: int = s.board.size()
	for desk: int in size:
		var level: int = s.board[desk]
		if level == 0:
			return false
		if level < EconomyData.MAX_LEVEL:
			for n: int in Economy.neighbors(desk, size):
				if s.board[n] == level:
					return false
	return true


static func fire_cost(s: PlayerState, desk: int) -> float:
	return desk_rate(s, desk) * EconomyData.FIRE_SEVERANCE_S


## Fires the coworker at [param desk] when the office is stuck. Returns the
## severance paid, or -1 if not stuck, empty desk, or not enough yen.
static func fire(s: PlayerState, desk: int) -> float:
	if not is_stuck(s) or s.board[desk] == 0:
		return -1.0
	var fee: float = fire_cost(s, desk)
	if fee > s.yen:
		return -1.0
	s.yen -= fee
	s.board[desk] = 0
	s.bubbles[desk] = 0.0
	return fee


static func free_desks(s: PlayerState) -> Array[int]:
	var out: Array[int] = []
	for desk: int in s.board.size():
		if s.board[desk] == 0:
			out.append(desk)
	return out


static func hire_cost(s: PlayerState) -> float:
	return Economy.hire_cost(s.rank, s.hires)


## Hires at a random free desk. Returns the desk, or -1 (no money or no free desk).
static func hire(s: PlayerState, rng: RandomNumberGenerator) -> int:
	var cost: float = hire_cost(s)
	if cost > s.yen or free_desks(s).is_empty():
		return -1
	s.yen -= cost
	s.hires += 1
	return _seat_random(s, rng, Economy.hire_level(s.rank))


## Resets the daily action counter when a new day (04:00 local) starts.
static func refresh_actions(s: PlayerState, day: int) -> void:
	if day != s.action_day:
		s.action_day = day
		s.actions_left = EconomyData.ACTIONS_PER_DAY


## Rewarded ad: +50 actions, once per day.
static func can_buy_ad_actions(s: PlayerState) -> bool:
	return s.ad_actions_used_day != s.action_day


static func grant_ad_actions(s: PlayerState) -> void:
	if can_buy_ad_actions(s):
		s.ad_actions_used_day = s.action_day
		s.actions_left += EconomyData.ACTIONS_AD_BONUS


## Drag from one desk to another: move to an empty desk or merge with an identical
## neighbour (each costs one desk action). Seats never swap.
static func desk_action(s: PlayerState, from: int, to: int) -> DeskResult:
	var size: int = s.board.size()
	if from == to or from < 0 or to < 0 or from >= size or to >= size or s.board[from] == 0:
		return DeskResult.INVALID
	if s.actions_left <= 0:
		return DeskResult.NO_ACTIONS
	var result: DeskResult
	if s.board[to] == 0:
		result = DeskResult.MOVED
		s.board[to] = s.board[from]
		s.bubbles[to] = s.bubbles[from]
		s.board[from] = 0
		s.bubbles[from] = 0.0
	elif s.board[to] == s.board[from]:
		if s.board[to] >= EconomyData.MAX_LEVEL:
			return DeskResult.MAX_LEVEL
		if not Economy.are_neighbors(from, to, size):
			return DeskResult.NOT_NEIGHBORS
		result = DeskResult.MERGED
		var stored: float = s.bubbles[to] + s.bubbles[from]
		s.board[to] += 1
		s.bubbles[to] = minf(capacity(s, to), stored)  # what was earned carries over
		s.board[from] = 0
		s.bubbles[from] = 0.0
	else:
		return DeskResult.OCCUPIED
	s.actions_left -= 1
	return result


static func buy_coffee(s: PlayerState) -> bool:
	return _pay(s, Economy.coffee_cost(s.coffee_level)) and _inc(s, "coffee_level")


static func buy_pc(s: PlayerState) -> bool:
	if s.pc_level >= EconomyData.PC_MAX_LEVEL:
		return false
	return _pay(s, Economy.pc_cost(s.pc_level)) and _inc(s, "pc_level")


static func buy_desk(s: PlayerState) -> bool:
	return _pay(s, Economy.desk_cost(s.desk_level)) and _inc(s, "desk_level")


static func can_promote(s: PlayerState) -> bool:
	return s.rank < EconomyData.CEO_RANK and Economy.goal_met(s.board, s.rank)


## Promotion = prestige reset (yen, board and bubbles reset; XP and rank kept).
## Returns XP gained, or -1 if the goal is not met.
static func promote(s: PlayerState, rng: RandomNumberGenerator) -> int:
	if not can_promote(s):
		return -1
	s.xp += EconomyData.XP_PER_PROMOTION
	s.rank += 1
	s.reset_run()
	start_run(s, rng)
	return EconomyData.XP_PER_PROMOTION


## "Found your own company": back to Intern with +1 career. Returns success.
static func found_company(s: PlayerState, rng: RandomNumberGenerator) -> bool:
	if s.rank != EconomyData.CEO_RANK or not Economy.goal_met(s.board, s.rank):
		return false
	s.xp += EconomyData.XP_PER_PROMOTION
	s.careers += 1
	s.rank = 0
	s.reset_run()
	start_run(s, rng)
	return true


static func _seat_random(s: PlayerState, rng: RandomNumberGenerator, level: int) -> int:
	var free: Array[int] = free_desks(s)
	if free.is_empty():
		return -1
	var desk: int = free[rng.randi_range(0, free.size() - 1)]
	s.board[desk] = level
	s.bubbles[desk] = 0.0
	return desk


static func _pay(s: PlayerState, cost: float) -> bool:
	if cost > s.yen:
		return false
	s.yen -= cost
	return true


static func _inc(s: PlayerState, field: String) -> bool:
	s.set(field, int(s.get(field)) + 1)
	return true
