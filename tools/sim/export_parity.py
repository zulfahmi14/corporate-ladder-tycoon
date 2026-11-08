"""Write tests/fixtures/economy_parity.json from the Python economy.

Run after any change to economy.py; the Godot parity test reads the file.
"""
import json
import os
import random

import economy as E
import sim

OUT = os.path.join(os.path.dirname(__file__), "..", "..", "tests", "fixtures", "economy_parity.json")

rng = random.Random(7)
cases = []
for _ in range(25):
    p = sim.Player(False, random.Random(rng.random()))
    p.rank = rng.randint(0, 5)
    p.reset_run()
    p.xp, p.careers, p.hires = rng.randint(0, 200), rng.randint(0, 3), rng.randint(0, 120)
    p.board = [rng.choice([0, 0] + list(range(1, E.MAX_LEVEL + 1))) for _ in p.board]
    p.lv = {"coffee": rng.randint(0, 30), "pc": rng.randint(0, 10), "desk": rng.randint(0, 8)}
    cases.append({
        "rank": p.rank, "xp": p.xp, "careers": p.careers, "hires": p.hires,
        "board": p.board, "coffee": p.lv["coffee"], "desk": p.lv["desk"],
        "perm": E.perm_mult(p.rank, p.xp, p.careers),
        "upgrade_mult": E.upgrade_mult(p.lv["coffee"], p.lv["desk"]),
        "hire_cost": E.hire_cost(p.rank, p.hires),
        "goal_progress": E.goal_progress(p.board, p.rank),
        "income_ps": p.income_ps(),
    })

constants = {
    "rank_income_mult": [r[1] for r in E.RANKS],
    "goal_level": [g[0] for g in E.GOALS],
    "goal_count": [g[1] for g in E.GOALS],
    "hire_base_cost": E.HIRE_BASE_COST,
    "level_income": [lv[1] for lv in E.LEVELS],
    "hire_growth": E.HIRE_GROWTH,
    "starting_team": E.STARTING_TEAM,
    "actions_per_day": E.ACTIONS_PER_DAY,
    "actions_ad_bonus": E.ACTIONS_AD_BONUS,
    "bubble_active_cap_s": E.BUBBLE_ACTIVE_CAP_S,
    "pc_cap_s_per_level": E.PC_CAP_S_PER_LEVEL,
    "coffee_bonus": E.COFFEE_BONUS,
    "desk_mult": E.DESK_MULT,
    "xp_per_promotion": E.XP_PER_PROMOTION,
    "offline_efficiency": E.OFFLINE_EFFICIENCY,
    "board_cols": E.BOARD_COLS,
    "board_rows_base": E.BOARD_ROWS_BASE,
    "minigame_keys": [m[0] for m in E.MINIGAMES],
    "minigame_unlock_rank": [m[1] for m in E.MINIGAMES],
    "minigame_base_seconds": [m[2] for m in E.MINIGAMES],
    "minigame_difficulty_mult": list(E.MINIGAME_DIFFICULTY_MULT),
    "minigame_cooldown_s": E.MINIGAME_COOLDOWN_S,
    "minigame_basis_per_mult": E.MINIGAME_BASIS_PER_MULT,
}
with open(OUT, "w") as f:
    json.dump({"constants": constants, "cases": cases}, f, indent=1)
print("wrote", os.path.normpath(OUT), len(cases), "cases")
