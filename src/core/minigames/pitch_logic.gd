class_name PitchLogic
extends RefCounted
## Pitch Timing: a needle sweeps left and right; stop it inside the green zone.

const ROUNDS: int = 8
const ZONE_WIDTH: Array[float] = [0.25, 0.15, 0.08]
const BASE_SPEED: Array[float] = [0.6, 0.85, 1.1]
const SPEED_STEP: float = 0.08


## Needle speed (track widths per second) for a round, getting faster each round.
static func speed(difficulty: int, round_index: int) -> float:
	return BASE_SPEED[difficulty] * (1.0 + SPEED_STEP * round_index)


## Needle position 0..1 after [param t] seconds, bouncing between the ends.
static func needle_at(t: float, speed_per_s: float) -> float:
	var travel: float = fposmod(t * speed_per_s, 2.0)
	return travel if travel <= 1.0 else 2.0 - travel


static func is_hit(needle: float, zone_center: float, difficulty: int) -> bool:
	return absf(needle - zone_center) <= ZONE_WIDTH[difficulty] / 2.0


static func score(hits: int) -> float:
	return clampf(float(hits) / ROUNDS, 0.0, 1.0)
