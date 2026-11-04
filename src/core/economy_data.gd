class_name EconomyData
extends RefCounted
## Balance constants approved in the design doc (D-7).
## Mirror of tools/sim/economy.py; tests/test_economy_parity.gd keeps them in sync.

# Ranks: promotion requirement is yen earned in the current run.
const RANK_KEYS: Array[String] = [
	"RANK_INTERN",
	"RANK_STAFF",
	"RANK_SECTION_CHIEF",
	"RANK_MANAGER",
	"RANK_DIRECTOR",
	"RANK_CEO",
]
const RANK_REQUIREMENTS: Array[float] = [5.0e8, 3.0e11, 3.0e13, 2.0e15, 1.0e17, 5.0e18]
const RANK_INCOME_MULT: Array[float] = [1.0, 2.0, 4.0, 8.0, 16.0, 32.0]
const CEO_RANK: int = 5

# Coworkers: one more tier unlocks per rank.
const COWORKER_KEYS: Array[String] = [
	"COWORKER_PART_TIMER",
	"COWORKER_KOUHAI",
	"COWORKER_SENPAI",
	"COWORKER_TEAM_LEADER",
	"COWORKER_SALES_ACE",
	"COWORKER_SYSTEMS_ENGINEER",
	"COWORKER_CONSULTANT",
	"COWORKER_BOARD_ADVISOR",
]
const COWORKER_BASE_COSTS: Array[float] = [15.0, 120.0, 1.3e3, 1.4e4, 1.6e5, 2.0e6, 2.5e7, 3.5e8]
const COWORKER_BASE_INCOME: Array[float] = [0.5, 3.0, 20.0, 120.0, 750.0, 5.0e3, 3.2e4, 2.2e5]
const COWORKER_GROWTH: float = 1.15
const UNLOCKED_AT_INTERN: int = 3
const MILESTONES: Array[int] = [10, 25, 50, 100, 150, 200]

# Upgrades.
const COFFEE_BASE_COST: float = 10.0
const COFFEE_GROWTH: float = 1.6
const PC_BASE_COST: float = 500.0
const PC_GROWTH: float = 4.0
const PC_MAX_LEVEL: int = 10
const PC_TAP_SHARE_PER_LEVEL: float = 0.02
const DESK_BASE_COST: float = 1.0e3
const DESK_GROWTH: float = 12.0
const DESK_MULT_PER_LEVEL: float = 1.5

# Prestige.
const XP_PER_PROMOTION_K: float = 10.0
const XP_INCOME_BONUS: float = 0.02
const FOUNDER_BONUS: float = 0.5

# Overtime.
const STAMINA_MAX: float = 100.0
const OVERTIME_DRAIN_PER_S: float = 1.0
const STAMINA_REGEN_PER_S: float = 1.0 / 30.0
const OVERTIME_MULT: float = 2.0
const OVERTIME_AD_MULT: float = 3.0

# Nomikai.
const NOMIKAI_EVERY_ACTIVE_S_MIN: float = 480.0
const NOMIKAI_EVERY_ACTIVE_S_MAX: float = 720.0
const NOMIKAI_EVENING_S_MIN: float = 240.0
const NOMIKAI_EVENING_S_MAX: float = 360.0
const NOMIKAI_INSTANT_SECONDS: float = 300.0
const NOMIKAI_BUFF_MULT: float = 1.25
const NOMIKAI_BUFF_S: float = 600.0
const NOMIKAI_INVITE_TIMEOUT_S: float = 60.0

# Offline.
const OFFLINE_BASE_CAP_H: float = 2.0
const OFFLINE_MAX_CAP_H: float = 8.0
const OFFLINE_EFFICIENCY: float = 0.5

# Rewarded 2x income.
const AD_2X_MULT: float = 2.0
const AD_2X_DURATION_S: float = 30.0 * 60.0
const AD_2X_MAX_STACK_S: float = 2.0 * 60.0 * 60.0
