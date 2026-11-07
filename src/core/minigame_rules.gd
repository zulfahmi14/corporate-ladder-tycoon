class_name MinigameRules
extends RefCounted
## Unlocks, cooldowns and rewards for mini games. Pure functions over PlayerState.


static func count() -> int:
	return MinigameData.KEYS.size()


static func is_unlocked(s: PlayerState, game: int) -> bool:
	return s.careers > 0 or s.rank >= MinigameData.UNLOCK_RANK[game]


## Seconds until the game can be played again (0 = ready).
static func cooldown_left(s: PlayerState, game: int, now_unix: float) -> float:
	var last: float = s.minigame_last_play[game]
	if last <= 0.0 or now_unix < last:
		return 0.0  # never played, or the clock went backwards: do not lock the player out
	return maxf(0.0, last + MinigameData.COOLDOWN_S - now_unix)


## Income basis: what one second of active play is worth (coworkers + 3 taps).
static func basis(s: PlayerState) -> float:
	return GameRules.coworker_ps(s) + MinigameData.TAP_EQUIV_PER_S * GameRules.tap_value(s)


## Reward for a finished game; [param score] is 0..1.
static func reward(s: PlayerState, game: int, difficulty: int, score: float) -> float:
	return (
		basis(s)
		* MinigameData.BASE_SECONDS[game]
		* MinigameData.DIFFICULTY_MULT[difficulty]
		* clampf(score, 0.0, 1.0)
		* GameRules.boost_mult(s)
	)


## Pays the reward and starts the cooldown. Returns the amount, or -1 if not allowed.
static func finish(
	s: PlayerState, game: int, difficulty: int, score: float, now_unix: float
) -> float:
	if not is_unlocked(s, game) or cooldown_left(s, game, now_unix) > 0.0:
		return -1.0
	var amount: float = reward(s, game, difficulty, score)
	GameRules.earn(s, amount)
	s.minigame_last_play[game] = now_unix
	return amount
