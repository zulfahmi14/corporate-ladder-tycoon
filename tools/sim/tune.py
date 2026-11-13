"""Find each rank's base hire cost so promotions land on TARGET_DAYS (no-ads player)."""
import economy as E
import sim

TARGET_DAYS = [0.34, 3.0, 6.5, 11.0, 17.0]  # day of promotion out of rank i

for i, target in enumerate(TARGET_DAYS):
    lo, hi = 1.0, 1e30
    for _ in range(40):
        mid = (lo * hi) ** 0.5
        E.HIRE_BASE_COST[i] = mid
        log, _ = sim.run(False, days=int(target) + 4, stop_rank=i + 1)
        day = log[i + 1][1] if len(log) > i + 1 else 99
        if day > target:
            hi = mid
        else:
            lo = mid
    E.HIRE_BASE_COST[i] = float(f"{lo:.2g}")
    print(E.RANKS[i][0], f"{E.HIRE_BASE_COST[i]:.2g}", flush=True)
print("HIRE_BASE_COST =", E.HIRE_BASE_COST)
