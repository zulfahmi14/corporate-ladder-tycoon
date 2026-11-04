---
name: idle-economy
description: Idle game economy math for this project - big numbers, exponential cost curves, income per second, prestige formula, offline earnings cap, boosts and balance simulation. Use when writing DESIGN.md numbers, economy code, or tuning balance.
---

# Idle economy

## Numbers
- Store money as `float` (double, ~1e308) - enough for this game's range;
  switch to mantissa/exponent only if design exceeds 1e300.
- Display via one formatter (see localization). Never show raw floats.

## Standard formulas (tune constants in DESIGN.md, data tables in src/data)
- Upgrade cost: `cost(n) = base * growth^n`, growth 1.07-1.15.
- Buy k levels: `base * growth^n * (growth^k - 1) / (growth - 1)`.
- Max affordable: `floor(log(money*(g-1)/(base*g^n) + 1) / log(g))`.
- Coworker income: `rate * count * milestone_mult`, milestones x2 at 25/50/100...
- Total income/sec = `sum(coworkers) * rank_mult * prestige_mult * boost_mult`.
- Prestige (promotion) points: `floor(k * (lifetime_earnings / threshold)^0.5)`,
  each point +X% permanent income. Sqrt keeps it from exploding.
- Offline: `income_per_sec * min(elapsed, cap) * offline_eff` with cap
  (e.g. 2 h base, upgradable to 8 h) and efficiency < 1 (e.g. 50%);
  rewarded ad doubles the result. Clamp elapsed >= 0 (clock tampering).
- Boosts multiply, durations add, with a max (no infinite stacking).

## Pacing targets for commuter play (validate by simulation)
- First upgrade in < 10 s, first coworker < 1 min, first promotion ~15-25 min
  active play, CEO in ~2-3 weeks of daily 2x15 min sessions.
- Each session should end with something "almost affordable" (hook).

## Simulation is mandatory
- `tools/sim/` script models an active + idle player (taps/sec, check-ins
  per day, greedy cheapest-ROI purchase) and prints time-to-rank table.
- Run it on every numbers change and paste the table into DESIGN.md.
- Core formulas live in `src/core` and are shared by game and sim (or
  mirrored with a test asserting identical outputs).
