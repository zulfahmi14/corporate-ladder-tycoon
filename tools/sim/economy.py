"""Economy constants and formulas for Corporate Ladder Tycoon.

Single source for the balance simulator; the Godot code in src/core must
mirror these values (a test will compare outputs).
"""
import math

# --- Ranks: (name, run earnings needed to be promoted OUT of this rank, income mult)
RANKS = [
    ("Intern", 5.0e8, 1.0),
    ("Staff", 3.0e11, 2.0),
    ("Section Chief", 3.0e13, 4.0),
    ("Manager", 2.0e15, 8.0),
    ("Director", 1.0e17, 16.0),
    ("CEO", None, 32.0),  # CEO: "Found your own company" (career reset)
]

# --- Coworkers: (name, base cost, base income/s). Cost growth per owned.
COWORKERS = [
    ("Part-timer", 15, 0.5),
    ("Kouhai", 120, 3),
    ("Senpai", 1.3e3, 20),
    ("Team leader", 1.4e4, 120),
    ("Sales ace", 1.6e5, 750),
    ("Systems engineer", 2.0e6, 5.0e3),
    ("Consultant", 2.5e7, 3.2e4),
    ("Board advisor", 3.5e8, 2.2e5),
]
COWORKER_GROWTH = 1.15
UNLOCKED_AT_INTERN = 3  # one more coworker tier unlocks per rank
MILESTONES = (10, 25, 50, 100, 150, 200)  # each doubles that coworker's income

# --- Upgrades: (key, base cost, growth, max level)
UPGRADES = {
    "coffee": (10, 1.6, None),       # +1 base yen per tap per level
    "pc": (500, 4.0, 10),            # +2% of income/s added to each tap per level
    "desk": (1.0e3, 12.0, None),     # x1.5 coworker income per level
}

FOUND_COMPANY_REQUIREMENT = 5.0e18  # CEO run earnings to "Found your own company"

# --- Experience (prestige currency, never resets)
XP_PER_PROMOTION_K = 10        # xp = floor(K * sqrt(run_earnings / requirement))
XP_INCOME_BONUS = 0.02         # +2% all income per XP
FOUNDER_BONUS = 0.5            # +50% all income per completed career (CEO reset)

# --- Overtime
STAMINA_MAX = 100
OVERTIME_DRAIN_PER_S = 1.0     # 100 s of overtime from full
STAMINA_REGEN_PER_S = 1 / 30   # full refill in 50 min
OVERTIME_MULT = 2.0            # all income while overtime is on
OVERTIME_AD_MULT = 3.0         # rewarded "overtime boost": refill + x3 for that bar

# --- Nomikai event
NOMIKAI_EVERY_ACTIVE_S = (480, 720)  # appears after 8-12 min of active play
NOMIKAI_INSTANT_SECONDS = 300        # instant reward = 5 min of income/s
NOMIKAI_BUFF_MULT = 1.25             # +25% coworker income ...
NOMIKAI_BUFF_S = 600                 # ... for 10 min

# --- Offline
OFFLINE_BASE_CAP_H = 2         # +1 h per rank above Intern (CEO = 7 h)
OFFLINE_MAX_CAP_H = 8          # founders get 8 h
OFFLINE_EFFICIENCY = 0.5       # rewarded ad doubles the result

# --- Rewarded "2x income"
AD_2X_MULT = 2.0
AD_2X_DURATION_S = 30 * 60
AD_2X_MAX_STACK_S = 2 * 60 * 60


# --- Mini games: (key, unlock rank, base reward seconds)
# reward = (coworker income/s + 3 * tap value) * base_s * difficulty mult * score (0..1)
MINIGAMES = [
    ("hanko", 0, 30),     # Hanko Stamp: tap approved documents, skip rejected ones
    ("inbox", 1, 45),     # Inbox Sort: work or spam
    ("expense", 2, 60),   # Expense Report: quick sums
    ("pitch", 3, 90),     # Pitch Timing: stop the needle in the zone
    ("board", 4, 120),    # Board Meeting: repeat the sequence
]
MINIGAME_DIFFICULTY_MULT = (1.0, 2.0, 4.0)  # Easy, Normal, Hard
MINIGAME_COOLDOWN_S = 5 * 60   # per game; real time, also passes while offline
MINIGAME_TAP_EQUIV_PER_S = 3.0  # taps/s counted in the reward basis


def coworker_cost(base: float, owned: int) -> float:
    return base * COWORKER_GROWTH ** owned


def milestone_mult(owned: int) -> float:
    return 2.0 ** sum(1 for m in MILESTONES if owned >= m)


def upgrade_cost(key: str, level: int) -> float:
    base, growth, _ = UPGRADES[key]
    return base * growth ** level


def xp_for_promotion(run_earnings: float, requirement: float) -> int:
    return int(XP_PER_PROMOTION_K * math.sqrt(run_earnings / requirement))


def offline_cap_s(rank: int, careers: int) -> float:
    if careers > 0:
        return OFFLINE_MAX_CAP_H * 3600
    return (OFFLINE_BASE_CAP_H + rank) * 3600
