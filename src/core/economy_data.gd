class_name EconomyData
extends RefCounted
## Balance constants for the merge office (design D-11).
## Mirror of tools/sim/economy.py; tests/test_economy_parity.gd keeps them in sync.

const RANK_KEYS: Array[String] = [
	"RANK_INTERN",
	"RANK_STAFF",
	"RANK_SECTION_CHIEF",
	"RANK_MANAGER",
	"RANK_DIRECTOR",
	"RANK_CEO",
]
const RANK_INCOME_MULT: Array[float] = [1.0, 2.0, 4.0, 8.0, 16.0, 32.0]
const CEO_RANK: int = 5
## Goal to leave each rank: GOAL_COUNT coworkers at GOAL_LEVEL or higher. CEO = found a company.
const GOAL_LEVEL: Array[int] = [4, 6, 7, 8, 9, 10]
const GOAL_COUNT: Array[int] = [2, 3, 3, 3, 3, 2]

const LEVEL_KEYS: Array[String] = [
	"LEVEL_PART_TIMER",
	"LEVEL_KOUHAI",
	"LEVEL_SENPAI",
	"LEVEL_TEAM_LEADER",
	"LEVEL_SALES_ACE",
	"LEVEL_SYSTEMS_ENGINEER",
	"LEVEL_CONSULTANT",
	"LEVEL_PROJECT_LEAD",
	"LEVEL_DEPARTMENT_HEAD",
	"LEVEL_EXECUTIVE",
	"LEVEL_VICE_PRESIDENT",
	"LEVEL_BOARD_ADVISOR",
]
const LEVEL_INCOME: Array[float] = [
	0.5, 1.5, 4.5, 13.5, 40.5, 121.5, 364.5, 1093.5, 3280.5, 9841.5, 29524.5, 88573.5
]
const MAX_LEVEL: int = 12

const HIRE_BASE_COST: Array[float] = [540.0, 2.6e5, 4.4e6, 1.0e8, 1.6e9, 8.0e6]
const HIRE_GROWTH: float = 1.06
const STARTING_TEAM: int = 4

const BOARD_COLS: int = 4
const BOARD_ROWS_BASE: int = 5

const ACTIONS_PER_DAY: int = 200
const ACTIONS_AD_BONUS: int = 50
const ACTIONS_RESET_HOUR: int = 4

const BUBBLE_ACTIVE_CAP_S: float = 30.0
const BUBBLE_SHOW_S: float = 3.0
const PC_CAP_S_PER_LEVEL: float = 15.0

const COFFEE_BASE_COST: float = 50.0
const COFFEE_GROWTH: float = 1.9
const COFFEE_BONUS: float = 0.10
const PC_BASE_COST: float = 500.0
const PC_GROWTH: float = 4.0
const PC_MAX_LEVEL: int = 10
const DESK_BASE_COST: float = 1.0e3
const DESK_GROWTH: float = 12.0
const DESK_MULT: float = 1.5

const XP_PER_PROMOTION: int = 10
const XP_INCOME_BONUS: float = 0.02
const FOUNDER_BONUS: float = 0.5

const STAMINA_MAX: float = 100.0
const OVERTIME_DRAIN_PER_S: float = 1.0
const STAMINA_REGEN_PER_S: float = 1.0 / 30.0
const OVERTIME_MULT: float = 2.0
const OVERTIME_AD_MULT: float = 3.0

const NOMIKAI_INSTANT_SECONDS: float = 300.0
const NOMIKAI_BUFF_MULT: float = 1.25
const NOMIKAI_BUFF_S: float = 600.0

const OFFLINE_BASE_CAP_H: float = 2.0
const OFFLINE_MAX_CAP_H: float = 8.0
const OFFLINE_EFFICIENCY: float = 0.5

const AD_2X_MULT: float = 2.0
const AD_2X_DURATION_S: float = 30.0 * 60.0
const AD_2X_MAX_STACK_S: float = 2.0 * 60.0 * 60.0
