class_name MinigameData
extends RefCounted
## Mini game constants. Mirror of MINIGAMES in tools/sim/economy.py (parity test).

enum Difficulty { EASY, NORMAL, HARD }

const KEYS: Array[String] = ["hanko", "inbox", "expense", "pitch", "board"]
const NAME_KEYS: Array[String] = [
	"MINIGAME_HANKO",
	"MINIGAME_INBOX",
	"MINIGAME_EXPENSE",
	"MINIGAME_PITCH",
	"MINIGAME_BOARD",
]
const UNLOCK_RANK: Array[int] = [0, 1, 2, 3, 4]
const BASE_SECONDS: Array[float] = [30.0, 45.0, 60.0, 90.0, 120.0]
const DIFFICULTY_MULT: Array[float] = [1.0, 2.0, 4.0]
const DIFFICULTY_KEYS: Array[String] = ["DIFFICULTY_EASY", "DIFFICULTY_NORMAL", "DIFFICULTY_HARD"]
const COOLDOWN_S: float = 300.0
const BASIS_PER_MULT: float = 3.0
