"""Write tests/fixtures/economy_parity.json from the Python economy.

Run after any change to economy.py; the Godot parity test reads the file.
"""
import json
import os
import random

import economy as E
import sim

OUT = os.path.join(os.path.dirname(__file__), "..", "..", "tests", "fixtures", "economy_parity.json")

random.seed(7)
cases = []
for _ in range(25):
    p = sim.Player(False)
    p.rank = random.randint(0, 5)
    p.xp = random.randint(0, 200)
    p.careers = random.randint(0, 3)
    p.owned = [random.randint(0, 220) for _ in E.COWORKERS]
    p.lv = {"coffee": random.randint(0, 60), "pc": random.randint(0, 10), "desk": random.randint(0, 12)}
    cases.append({
        "rank": p.rank, "xp": p.xp, "careers": p.careers, "owned": p.owned,
        "coffee": p.lv["coffee"], "pc": p.lv["pc"], "desk": p.lv["desk"],
        "perm": p.perm_mult(), "coworker_ps": p.coworker_ps(), "tap": p.tap_value(),
    })

constants = {
    "rank_requirements": [r[1] for r in E.RANKS[:-1]] + [E.FOUND_COMPANY_REQUIREMENT],
    "rank_income_mult": [r[2] for r in E.RANKS],
    "coworker_costs": [c[1] for c in E.COWORKERS],
    "coworker_income": [c[2] for c in E.COWORKERS],
}
with open(OUT, "w") as f:
    json.dump({"constants": constants, "cases": cases}, f, indent=1)
print("wrote", os.path.normpath(OUT), len(cases), "cases")
