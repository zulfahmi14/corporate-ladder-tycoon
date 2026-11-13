"""Economy constants and formulas for Corporate Ladder Tycoon (merge office, D-11).

Single source for the balance simulator; the Godot code in src/core mirrors
these values and tests/test_economy_parity.gd checks it via a fixture.
"""

# --- Ranks: (name, income multiplier). Promotion = board goal below.
RANKS = [
    ("Intern", 1.0),
    ("Staff", 2.0),
    ("Section Chief", 4.0),
    ("Manager", 8.0),
    ("Director", 16.0),
    ("CEO", 32.0),
]
# Goal to leave each rank: (level, count) coworkers at that level or higher on the board.
# The CEO goal is "Found your own company".
GOALS = [(4, 2), (6, 3), (7, 3), (8, 3), (9, 3), (10, 2)]

# --- Coworker levels (index 0 = Lv1): (name, income per second)
LEVELS = [
    ("Part-timer", 0.5),
    ("Kouhai", 1.5),
    ("Senpai", 4.5),
    ("Team leader", 13.5),
    ("Sales ace", 40.5),
    ("Systems engineer", 121.5),
    ("Consultant", 364.5),
    ("Project lead", 1093.5),
    ("Department head", 3280.5),
    ("Executive", 9841.5),
    ("Vice president", 29524.5),
    ("Board advisor", 88573.5),
]  # each level earns 3x the one below; a merge turns 2 coworkers into 1.5x their income
MAX_LEVEL = len(LEVELS)

# --- Hiring: hired level = rank + 1; cost = base[rank] * growth ^ hires this run
# Goals sit 4 levels above the hire level (Intern: 3 above), so a rank takes ~48 hires.
HIRE_BASE_COST = [540.0, 2.6e5, 4.4e6, 1.0e8, 1.6e9, 8.0e6]  # tuned by tune.py
HIRE_GROWTH = 1.06
STARTING_TEAM = 4  # free coworkers at the hire level, seated randomly at the start of each run

# --- Board: 4 columns, 5 rows at Intern, one more row per rank
BOARD_COLS = 4
BOARD_ROWS_BASE = 5

# --- Desk actions (move or merge cost 1); hiring, claiming and firing are free
ACTIONS_PER_DAY = 200
ACTIONS_AD_BONUS = 50          # one rewarded ad per day
ACTIONS_RESET_HOUR = 4         # local time

# --- Bubbles: each desk fills a bubble of fixed size, then waits until tapped (D-12)
# capacity = level income x fill seconds; production stops while a full bubble waits.
FILL_S = [20, 30, 60, 90, 120, 180, 240, 300, 420, 600, 900, 1200]  # per level
PC_FILL_SPEEDUP = 0.04         # Faster PC: bubbles fill 4% faster per level (max 10)

# --- Firing: only when the office is stuck (full, no matching neighbours)
FIRE_SEVERANCE_S = 600         # severance = 10 minutes of that coworker's income

# --- Upgrades: (base cost, growth, max level)
UPGRADES = {
    "coffee": (50.0, 1.9, None),   # +10% coworker income per level (additive)
    "pc": (500.0, 4.0, 10),        # bubbles fill 4% faster per level
    "desk": (1.0e3, 12.0, None),   # x1.5 coworker income per level
}
COFFEE_BONUS = 0.10
DESK_MULT = 1.5

# --- Experience (prestige, never resets)
XP_PER_PROMOTION = 10
XP_INCOME_BONUS = 0.02
FOUNDER_BONUS = 0.5

# --- Overtime
STAMINA_MAX = 100
OVERTIME_DRAIN_PER_S = 1.0
STAMINA_REGEN_PER_S = 1 / 30
OVERTIME_MULT = 2.0
OVERTIME_AD_MULT = 3.0

# --- Nomikai event
NOMIKAI_EVERY_ACTIVE_S = (480, 720)
NOMIKAI_INSTANT_SECONDS = 300
NOMIKAI_BUFF_MULT = 1.25
NOMIKAI_BUFF_S = 600

# --- Offline
OFFLINE_BASE_CAP_H = 2
OFFLINE_MAX_CAP_H = 8
OFFLINE_EFFICIENCY = 0.5

# --- Rewarded 2x income
AD_2X_MULT = 2.0
AD_2X_DURATION_S = 30 * 60
AD_2X_MAX_STACK_S = 2 * 60 * 60

# --- Mini games: (key, unlock rank, base reward seconds)
# reward = (coworker income/s + 3 * permanent mult) * base_s * difficulty mult * score
MINIGAMES = [
    ("hanko", 0, 30),
    ("inbox", 1, 45),
    ("expense", 2, 60),
    ("pitch", 3, 90),
    ("board", 4, 120),
]
MINIGAME_DIFFICULTY_MULT = (1.0, 2.0, 4.0)
MINIGAME_COOLDOWN_S = 5 * 60
MINIGAME_BASIS_PER_MULT = 3.0


def board_size(rank: int) -> int:
    return BOARD_COLS * (BOARD_ROWS_BASE + rank)


def hire_level(rank: int) -> int:
    return rank + 1


def hire_cost(rank: int, hires: int) -> float:
    return HIRE_BASE_COST[rank] * HIRE_GROWTH ** hires


def upgrade_cost(key: str, level: int) -> float:
    base, growth, _ = UPGRADES[key]
    return base * growth ** level


def perm_mult(rank: int, xp: int, careers: int) -> float:
    return RANKS[rank][1] * (1 + XP_INCOME_BONUS * xp) * (1 + FOUNDER_BONUS * careers)


def upgrade_mult(coffee: int, desk: int) -> float:
    return (1 + COFFEE_BONUS * coffee) * DESK_MULT ** desk


def level_income(level: int) -> float:
    return LEVELS[level - 1][1]


def fill_seconds(level: int, pc: int) -> float:
    return FILL_S[level - 1] * (1 - PC_FILL_SPEEDUP * pc)


def offline_cap_s(rank: int, careers: int) -> float:
    if careers > 0:
        return OFFLINE_MAX_CAP_H * 3600
    return (OFFLINE_BASE_CAP_H + rank) * 3600


def goal_progress(board: list, rank: int) -> int:
    level, _ = GOALS[rank]
    return sum(1 for lv in board if lv >= level)


def goal_met(board: list, rank: int) -> bool:
    return goal_progress(board, rank) >= GOALS[rank][1]
