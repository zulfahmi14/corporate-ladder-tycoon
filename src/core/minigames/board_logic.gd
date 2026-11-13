class_name BoardLogic
extends RefCounted
## Board Meeting: watch which departments speak, then repeat the order.

const DEPARTMENTS: int = 4
const ROUNDS: int = 6
const START_LENGTH: Array[int] = [3, 4, 5]
const SHOW_STEP_S: Array[float] = [0.8, 0.6, 0.45]


static func sequence_length(difficulty: int, round_index: int) -> int:
	return START_LENGTH[difficulty] + round_index


static func make_sequence(rng: RandomNumberGenerator, length: int) -> Array[int]:
	var seq: Array[int] = []
	for i: int in length:
		seq.append(rng.randi_range(0, DEPARTMENTS - 1))
	return seq


static func score(rounds_cleared: int) -> float:
	return clampf(float(rounds_cleared) / ROUNDS, 0.0, 1.0)
