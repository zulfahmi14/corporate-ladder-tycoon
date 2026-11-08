class_name Economy
extends RefCounted
## Pure economy formulas for the merge office. No state, no nodes.


static func board_size(rank: int) -> int:
	return EconomyData.BOARD_COLS * (EconomyData.BOARD_ROWS_BASE + rank)


static func hire_level(rank: int) -> int:
	return rank + 1


## Cost of the next hire when [param hires] were already made this run.
static func hire_cost(rank: int, hires: int) -> float:
	return EconomyData.HIRE_BASE_COST[rank] * pow(EconomyData.HIRE_GROWTH, hires)


static func level_income(level: int) -> float:
	if level < 1 or level > EconomyData.MAX_LEVEL:
		return 0.0
	return EconomyData.LEVEL_INCOME[level - 1]


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


## Coffee (+10% each, additive) times Better desk (x1.5 each).
static func upgrade_mult(coffee_level: int, desk_level: int) -> float:
	return (1.0 + EconomyData.COFFEE_BONUS * coffee_level) * pow(EconomyData.DESK_MULT, desk_level)


## How many seconds of income a bubble holds while the app is open.
static func bubble_cap_s(pc_level: int) -> float:
	return EconomyData.BUBBLE_ACTIVE_CAP_S + EconomyData.PC_CAP_S_PER_LEVEL * pc_level


static func offline_cap_s(rank: int, careers: int) -> float:
	if careers > 0:
		return EconomyData.OFFLINE_MAX_CAP_H * 3600.0
	return (EconomyData.OFFLINE_BASE_CAP_H + rank) * 3600.0


## Coworkers at the goal level or higher.
static func goal_progress(board: Array[int], rank: int) -> int:
	var count: int = 0
	for level: int in board:
		if level >= EconomyData.GOAL_LEVEL[rank]:
			count += 1
	return count


static func goal_met(board: Array[int], rank: int) -> bool:
	return goal_progress(board, rank) >= EconomyData.GOAL_COUNT[rank]


## Desks next to [param i] (up, down, left, right) on a board of [param size].
static func neighbors(i: int, size: int) -> Array[int]:
	var cols: int = EconomyData.BOARD_COLS
	var out: Array[int] = []
	if i - cols >= 0:
		out.append(i - cols)
	if i + cols < size:
		out.append(i + cols)
	if i % cols > 0:
		out.append(i - 1)
	if i % cols < cols - 1:
		out.append(i + 1)
	return out


static func are_neighbors(a: int, b: int, size: int) -> bool:
	return neighbors(a, size).has(b)


## Day number for the daily action limit: days roll over at 04:00 local time.
static func action_day(local_unix: float) -> int:
	return floori((local_unix - EconomyData.ACTIONS_RESET_HOUR * 3600.0) / 86400.0)
