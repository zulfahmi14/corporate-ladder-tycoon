"""Balance simulator: commuter player, greedy best-payback purchases.

Usage: python3 tools/sim/sim.py [--ads] [--csv]
Prints time to reach each rank (days, active minutes).
"""
import random
import sys

import economy as E

TAPS_PER_S = 1.5          # average while a session is open (taps half the time)
DAY = [                   # (start hour, active minutes): two commutes + two peeks
    (8.0, 15), (12.5, 2), (18.5, 15), (22.0, 2),
]


class Player:
    def __init__(self, ads: bool):
        self.ads = ads
        self.xp = 0
        self.careers = 0
        self.rank = 0
        self.reset_run()
        self.stamina = E.STAMINA_MAX
        self.ad_2x_left = 0.0
        self.nomikai_buff = 0.0
        self.next_nomikai = random.uniform(*E.NOMIKAI_EVERY_ACTIVE_S)
        self.active_s = 0.0

    def reset_run(self):
        self.money = 0.0
        self.run_earned = 0.0
        self.owned = [0] * len(E.COWORKERS)
        self.lv = {k: 0 for k in E.UPGRADES}

    # --- income
    def perm_mult(self):
        return (E.RANKS[self.rank][2] * (1 + E.XP_INCOME_BONUS * self.xp)
                * (1 + E.FOUNDER_BONUS * self.careers))

    def coworker_ps(self, owned=None, desk=None):
        owned = owned or self.owned
        desk = self.lv["desk"] if desk is None else desk
        raw = sum(n * inc * E.milestone_mult(n)
                  for n, (_, _, inc) in zip(owned, E.COWORKERS))
        return raw * 1.5 ** desk * self.perm_mult()

    def tap_value(self, coffee=None, pc=None, ps=None):
        coffee = self.lv["coffee"] if coffee is None else coffee
        pc = self.lv["pc"] if pc is None else pc
        ps = self.coworker_ps() if ps is None else ps
        return (1 + coffee) * self.perm_mult() + 0.02 * pc * ps

    def active_ps(self):
        return self.coworker_ps() + TAPS_PER_S * self.tap_value()

    # --- greedy shop: buy the best payback option if affordable
    def options(self):
        base_ps = self.active_ps()
        opts = []
        for i, (_, cost0, _) in enumerate(E.COWORKERS):
            if i >= E.UNLOCKED_AT_INTERN + self.rank:
                break
            cost = E.coworker_cost(cost0, self.owned[i])
            o = list(self.owned); o[i] += 1
            gain = self.coworker_ps(owned=o) + TAPS_PER_S * self.tap_value(
                ps=self.coworker_ps(owned=o)) - base_ps
            opts.append((cost, gain, ("cw", i)))
        for k, (_, _, cap) in E.UPGRADES.items():
            if cap is not None and self.lv[k] >= cap:
                continue
            cost = E.upgrade_cost(k, self.lv[k])
            lv = dict(self.lv); lv[k] += 1
            ps = self.coworker_ps(desk=lv["desk"])
            gain = ps + TAPS_PER_S * self.tap_value(lv["coffee"], lv["pc"], ps) - base_ps
            opts.append((cost, gain, ("up", k)))
        return opts

    def shop(self):
        while True:
            opts = [o for o in self.options() if o[1] > 0]
            cost, gain, item = min(opts, key=lambda o: o[0] / o[1])
            if cost > self.money:
                return
            self.money -= cost
            if item[0] == "cw":
                self.owned[item[1]] += 1
            else:
                self.lv[item[1]] += 1

    def earn(self, amount):
        self.money += amount
        self.run_earned += amount

    def try_promote(self, log, t_day):
        req = E.RANKS[self.rank][1]
        if req is None:
            return
        if self.run_earned >= req:
            self.xp += E.xp_for_promotion(self.run_earned, req)
            self.rank += 1
            self.reset_run()
            log.append((E.RANKS[self.rank][0], t_day, self.active_s / 60, self.xp))

    # --- one active second
    def tick(self):
        mult = 1.0
        if self.ad_2x_left > 0:
            mult *= E.AD_2X_MULT
            self.ad_2x_left -= 1
        if self.stamina >= E.STAMINA_MAX:
            self.overtime = True
        if getattr(self, "overtime", False):
            mult *= E.OVERTIME_AD_MULT if getattr(self, "ot_ad", False) else E.OVERTIME_MULT
            self.stamina -= E.OVERTIME_DRAIN_PER_S
            if self.stamina <= 0:
                self.stamina, self.overtime, self.ot_ad = 0, False, False
        else:
            self.stamina = min(E.STAMINA_MAX, self.stamina + E.STAMINA_REGEN_PER_S)
        cw = self.coworker_ps()
        if self.nomikai_buff > 0:
            cw *= E.NOMIKAI_BUFF_MULT
            self.nomikai_buff -= 1
        self.earn((cw + TAPS_PER_S * self.tap_value()) * mult)
        self.active_s += 1
        if self.active_s >= self.next_nomikai:
            self.earn(self.coworker_ps() * E.NOMIKAI_INSTANT_SECONDS)
            self.nomikai_buff = E.NOMIKAI_BUFF_S
            self.next_nomikai = self.active_s + random.uniform(*E.NOMIKAI_EVERY_ACTIVE_S)

    def offline(self, seconds):
        self.stamina = min(E.STAMINA_MAX, self.stamina + seconds * E.STAMINA_REGEN_PER_S)
        capped = min(seconds, E.offline_cap_s(self.rank, self.careers))
        gain = self.coworker_ps() * capped * E.OFFLINE_EFFICIENCY
        if self.ads:
            gain *= 2
        self.earn(gain)


def run(ads: bool, days: int = 40, seed: int = 1, stop_rank: int = 99):
    random.seed(seed)
    p = Player(ads)
    log = [("Intern", 0.0, 0.0, 0)]
    last_end_h = None
    for d in range(days):
        for start_h, minutes in DAY:
            t_h = d * 24 + start_h
            if last_end_h is not None:
                p.offline((t_h - last_end_h) * 3600)
            p.shop()
            p.try_promote(log, t_h / 24)
            if ads and minutes >= 10:
                p.ad_2x_left = E.AD_2X_DURATION_S     # one 2x ad per commute
                if p.stamina < E.STAMINA_MAX:          # one overtime-boost ad
                    p.stamina, p.overtime, p.ot_ad = E.STAMINA_MAX, True, True
            for s in range(minutes * 60):
                p.tick()
                if s % 10 == 0:
                    p.shop()
                    p.try_promote(log, (t_h + s / 3600) / 24)
            p.ad_2x_left = 0  # timer is real-time; simplification: lost when closing
            last_end_h = t_h + minutes / 60
        if p.rank >= min(stop_rank, len(E.RANKS) - 1):
            break
    return log, p


if __name__ == "__main__":
    ads = "--ads" in sys.argv
    log, p = run(ads)
    if "--csv" in sys.argv:
        print("rank,day,active_min,xp")
        for name, day, mins, xp in log:
            print(f"{name},{day:.2f},{mins:.0f},{xp}")
    else:
        print(f"{'Rank':15} {'Day':>6} {'Active min':>11} {'XP':>5}")
        for name, day, mins, xp in log:
            print(f"{name:15} {day:6.1f} {mins:11.0f} {xp:5d}")
