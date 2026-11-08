"""Balance simulator for the merge office: a commuter player.

Usage: python3 tools/sim/sim.py [--ads] [--csv]
Prints the day and active minutes at each promotion, and daily desk actions used.
"""
import random
import sys

import economy as E

DAY = [(8.0, 15), (12.5, 2), (18.5, 15), (22.0, 2)]  # (start hour, active minutes)
CLAIM_EVERY_S = 8          # a player taps bubbles every few seconds
DECIDE_EVERY_S = 10        # hire / merge / upgrade checks
MINIGAME_PLAY_S = 25
MINIGAME_DIFFICULTY = 1
MINIGAME_SCORE = 0.75


def neighbors(i: int, size: int) -> list:
    c, cols = i % E.BOARD_COLS, E.BOARD_COLS
    out = []
    if i - cols >= 0:
        out.append(i - cols)
    if i + cols < size:
        out.append(i + cols)
    if c > 0:
        out.append(i - 1)
    if c < cols - 1:
        out.append(i + 1)
    return out


class Player:
    def __init__(self, ads: bool, rng: random.Random):
        self.ads, self.rng = ads, rng
        self.rank = 0
        self.rank, self.xp, self.careers = 0, 0, 0
        self.stamina, self.ad_2x_left, self.nomikai_buff = E.STAMINA_MAX, 0.0, 0.0
        self.overtime = self.ot_ad = False
        self.active_s, self.now_s = 0.0, 0.0
        self.next_nomikai = rng.uniform(*E.NOMIKAI_EVERY_ACTIVE_S)
        self.minigame_ready_at = {}
        self.hire_times = {}
        self.actions_left, self.actions_used_today, self.daily_used = E.ACTIONS_PER_DAY, 0, []
        self.reset_run()

    def reset_run(self):
        self.board = [0] * E.board_size(self.rank)
        self.bubbles = [0.0] * len(self.board)
        self.yen, self.hires = 0.0, 0
        self.lv = {k: 0 for k in E.UPGRADES}
        self.nomikai_buff = 0.0
        for cell in self.rng.sample(range(len(self.board)), E.STARTING_TEAM):
            self.board[cell] = E.hire_level(self.rank)

    # --- income
    def mult(self):
        return E.perm_mult(self.rank, self.xp, self.careers) * E.upgrade_mult(
            self.lv["coffee"], self.lv["desk"])

    def desk_rate(self, i):
        return E.level_income(self.board[i]) * self.mult() if self.board[i] else 0.0

    def income_ps(self):
        return sum(self.desk_rate(i) for i in range(len(self.board)))

    def fill_active(self, seconds, boost):
        cap_s = E.bubble_cap_s(self.lv["pc"])
        for i in range(len(self.board)):
            r = self.desk_rate(i)
            if r and self.bubbles[i] < r * cap_s:
                self.bubbles[i] = min(r * cap_s, self.bubbles[i] + r * seconds * boost)

    def claim(self):
        self.yen += sum(self.bubbles)
        self.bubbles = [0.0] * len(self.board)

    # --- board actions
    def spend_action(self):
        if self.actions_left <= 0:
            return False
        self.actions_left -= 1
        self.actions_used_today += 1
        return True

    def best_board_action(self):
        """Merge an adjacent pair, else bring a twin next to its pair. Lowest level first."""
        size = len(self.board)
        for level in range(1, E.MAX_LEVEL):
            cells = [i for i in range(size) if self.board[i] == level]
            for a in cells:
                for b in neighbors(a, size):
                    if self.board[b] == level:
                        return ("merge", a, b)
            if len(cells) >= 2:
                for a in cells:
                    for b in cells:
                        if a == b:
                            continue
                        for n in neighbors(b, size):
                            if n != a and self.board[n] == 0:
                                return ("move", a, n)
                        for n in neighbors(b, size):
                            if n != a and self.board[n] != level:
                                return ("swap", a, n)
        return None

    def do_board(self):
        while self.actions_left > 0:
            act = self.best_board_action()
            if act is None or not self.spend_action():
                return
            kind, a, b = act
            if kind == "merge":
                self.bubbles[b] += self.bubbles[a]
                self.board[b] += 1
                self.board[a], self.bubbles[a] = 0, 0.0
            elif kind == "move":
                self.board[b], self.board[a] = self.board[a], 0
                self.bubbles[b], self.bubbles[a] = self.bubbles[a], 0.0
            else:
                self.board[a], self.board[b] = self.board[b], self.board[a]
                self.bubbles[a], self.bubbles[b] = self.bubbles[b], self.bubbles[a]

    # --- spending
    def shop(self):
        while True:
            free = [i for i in range(len(self.board)) if self.board[i] == 0]
            cost = E.hire_cost(self.rank, self.hires)
            if free and self.yen >= cost:
                self.yen -= cost
                self.hires += 1
                self.hire_times.setdefault(self.rank, []).append(self.active_s)
                self.board[self.rng.choice(free)] = E.hire_level(self.rank)
                continue
            best = None
            base_ps = self.income_ps()
            for key, (_, _, cap) in E.UPGRADES.items():
                if key == "pc" or (cap is not None and self.lv[key] >= cap):
                    continue
                c = E.upgrade_cost(key, self.lv[key])
                self.lv[key] += 1
                gain = self.income_ps() - base_ps
                self.lv[key] -= 1
                if gain > 0 and c / gain < 20 * 60 and (best is None or c / gain < best[0]):
                    best = (c / gain, c, key)
            if best is None or best[1] > self.yen:
                return
            self.yen -= best[1]
            self.lv[best[2]] += 1

    def try_promote(self, log, day):
        if self.rank < len(E.RANKS) - 1 and E.goal_met(self.board, self.rank):
            self.xp += E.XP_PER_PROMOTION
            self.rank += 1
            self.reset_run()
            log.append((E.RANKS[self.rank][0], day, self.active_s / 60, self.xp))

    # --- time
    def tick(self):
        boost = E.AD_2X_MULT if self.ad_2x_left > 0 else 1.0
        self.ad_2x_left = max(0.0, self.ad_2x_left - 1)
        if self.stamina >= E.STAMINA_MAX:
            self.overtime = True
        if self.overtime:
            boost *= E.OVERTIME_AD_MULT if self.ot_ad else E.OVERTIME_MULT
            self.stamina -= E.OVERTIME_DRAIN_PER_S
            if self.stamina <= 0:
                self.stamina, self.overtime, self.ot_ad = 0, False, False
        else:
            self.stamina = min(E.STAMINA_MAX, self.stamina + E.STAMINA_REGEN_PER_S)
        if self.nomikai_buff > 0:
            boost *= E.NOMIKAI_BUFF_MULT
            self.nomikai_buff -= 1
        self.fill_active(1, boost)
        self.active_s += 1
        if self.active_s >= self.next_nomikai:
            self.yen += self.income_ps() * E.NOMIKAI_INSTANT_SECONDS
            self.nomikai_buff = E.NOMIKAI_BUFF_S
            self.next_nomikai = self.active_s + self.rng.uniform(*E.NOMIKAI_EVERY_ACTIVE_S)

    def play_minigames(self):
        spent = 0
        for key, rank, base_s in E.MINIGAMES:
            if rank > self.rank or self.minigame_ready_at.get(key, 0) > self.now_s + spent:
                continue
            basis = self.income_ps() + E.MINIGAME_BASIS_PER_MULT * E.perm_mult(
                self.rank, self.xp, self.careers)
            reward = (basis * base_s * E.MINIGAME_DIFFICULTY_MULT[MINIGAME_DIFFICULTY]
                      * MINIGAME_SCORE)
            if self.ad_2x_left > 0:
                reward *= E.AD_2X_MULT
            self.yen += reward
            self.fill_active(MINIGAME_PLAY_S, 1.0)
            spent += MINIGAME_PLAY_S
            self.minigame_ready_at[key] = self.now_s + spent + E.MINIGAME_COOLDOWN_S
        return spent

    def offline(self, seconds):
        self.stamina = min(E.STAMINA_MAX, self.stamina + seconds * E.STAMINA_REGEN_PER_S)
        t = min(seconds, E.offline_cap_s(self.rank, self.careers)) * E.OFFLINE_EFFICIENCY
        for i in range(len(self.board)):
            self.bubbles[i] += self.desk_rate(i) * t * (2 if self.ads else 1)

    def new_day(self):
        self.daily_used.append(self.actions_used_today)
        self.actions_used_today = 0
        self.actions_left = E.ACTIONS_PER_DAY + (E.ACTIONS_AD_BONUS if self.ads else 0)


def run(ads: bool, days: int = 40, seed: int = 1, stop_rank: int = 99, minigames: bool = True):
    rng = random.Random(seed)
    p = Player(ads, rng)
    log = [("Intern", 0.0, 0.0, 0)]
    last_end_h = None
    for d in range(days):
        if d > 0:
            p.new_day()
        for start_h, minutes in DAY:
            t_h = d * 24 + start_h
            if last_end_h is not None:
                p.offline((t_h - last_end_h) * 3600)
            if ads and minutes >= 10:
                p.ad_2x_left = E.AD_2X_DURATION_S
                if p.stamina < E.STAMINA_MAX:
                    p.stamina, p.overtime, p.ot_ad = E.STAMINA_MAX, True, True
            s = 0
            while s < minutes * 60:
                p.now_s = t_h * 3600 + s
                if s % CLAIM_EVERY_S == 0:
                    p.claim()
                if s % DECIDE_EVERY_S == 0:
                    p.shop()
                    p.do_board()
                    p.try_promote(log, (t_h + s / 3600) / 24)
                    if minigames:
                        played = p.play_minigames()
                        if played:
                            s += played
                            p.active_s += played
                            continue
                p.tick()
                s += 1
            p.claim()
            p.ad_2x_left = 0
            last_end_h = t_h + minutes / 60
        if p.rank >= min(stop_rank, len(E.RANKS) - 1):
            break
    p.daily_used.append(p.actions_used_today)
    return log, p


if __name__ == "__main__":
    ads = "--ads" in sys.argv
    log, p = run(ads, minigames="--no-minigames" not in sys.argv)
    if "--csv" in sys.argv:
        print("rank,day,active_min,xp")
        for name, day, mins, xp in log:
            print(f"{name},{day:.2f},{mins:.0f},{xp}")
    else:
        print(f"{'Rank':15} {'Day':>6} {'Active min':>11} {'XP':>5}")
        for name, day, mins, xp in log:
            print(f"{name:15} {day:6.1f} {mins:11.0f} {xp:5d}")
        for r, times in p.hire_times.items():
            gaps = [b - a for a, b in zip(times, times[1:])]
            gaps.sort()
            med = gaps[len(gaps) // 2] if gaps else 0
            print(f"  {E.RANKS[r][0]:14} hires {len(times):3}  median gap {med:5.0f} s  "
                  f"90th pct gap {gaps[int(len(gaps) * 0.9)] if gaps else 0:5.0f} s (active time)")
        used = p.daily_used
        print(f"desk actions/day: median {sorted(used)[len(used) // 2]}, max {max(used)}, "
              f"limit {E.ACTIONS_PER_DAY}, days at limit {sum(u >= E.ACTIONS_PER_DAY for u in used)}")
