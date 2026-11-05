"""Find rank requirements that hit target promotion days (no-ads player)."""
import economy as E
import sim

TARGET_DAYS = [0.78, 3.0, 6.5, 11.0, 18.0]  # day of promotion out of rank i (0.78 = first evening commute)

reqs = [r[1] for r in E.RANKS]
for i, target in enumerate(TARGET_DAYS):
    lo, hi = 1e3, 1e40
    for _ in range(28):
        mid = (lo * hi) ** 0.5
        reqs[i] = mid
        E.RANKS[:] = [(n, reqs[j], m) for j, (n, _, m) in enumerate(E.RANKS)]
        log, _ = sim.run(False, days=int(target) + 3, stop_rank=i + 1)
        day = log[i + 1][1] if len(log) > i + 1 else 99
        if day > target:
            hi = mid
        else:
            lo = mid
    reqs[i] = float(f"{lo:.1e}")
    E.RANKS[:] = [(n, reqs[j], m) for j, (n, _, m) in enumerate(E.RANKS)]
    print(E.RANKS[i][0], f"{reqs[i]:.1e}")
