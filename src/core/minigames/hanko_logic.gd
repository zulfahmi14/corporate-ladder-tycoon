class_name HankoLogic
extends RefCounted
## Hanko Stamp: documents pop up; stamp approved ones, leave rejected ones.

const DURATION_S: float = 20.0
const LIFETIME_S: Array[float] = [1.6, 1.1, 0.75]
const SPAWN_EVERY_S: Array[float] = [0.9, 0.7, 0.5]
const REJECT_CHANCE: Array[float] = [0.2, 0.3, 0.4]
const GRID_CELLS: int = 9


## Score 0..1: correct stamps minus wrong stamps, over approved documents shown.
static func score(stamped_good: int, stamped_bad: int, good_shown: int) -> float:
	if good_shown <= 0:
		return 0.0
	return clampf(float(stamped_good - stamped_bad) / good_shown, 0.0, 1.0)
