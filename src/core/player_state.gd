class_name PlayerState
extends RefCounted
## Everything that is saved. Plain data; rules live in GameRules.

var yen: float = 0.0
var run_earned: float = 0.0
## Coworker level per desk (0 = empty desk).
var board: Array[int] = []
## Unclaimed yen waiting on each desk.
var bubbles: Array[float] = []
var hires: int = 0
var run_started: bool = false
var coffee_level: int = 0
var pc_level: int = 0
var desk_level: int = 0
var rank: int = 0
var xp: int = 0
var careers: int = 0
var actions_left: int = EconomyData.ACTIONS_PER_DAY
var action_day: int = -1
var ad_actions_used_day: int = -1
var stamina: float = EconomyData.STAMINA_MAX
var ad_2x_left_s: float = 0.0
var nomikai_buff_s: float = 0.0
var last_seen_unix: float = 0.0
var installed_unix: float = 0.0
var last_interstitial_unix: float = 0.0
var last_rewarded_unix: float = 0.0
var minigame_last_play: Array[float] = []
var sound_on: bool = true
var music_on: bool = true


func _init() -> void:
	minigame_last_play.resize(MinigameData.KEYS.size())
	minigame_last_play.fill(0.0)
	reset_run()


## Clears everything a promotion resets; the board grows with rank.
func reset_run() -> void:
	yen = 0.0
	run_earned = 0.0
	var size: int = Economy.board_size(rank)
	board.clear()
	board.resize(size)
	board.fill(0)
	bubbles.clear()
	bubbles.resize(size)
	bubbles.fill(0.0)
	hires = 0
	run_started = false
	coffee_level = 0
	pc_level = 0
	desk_level = 0
	nomikai_buff_s = 0.0


func to_dict() -> Dictionary:
	return {
		"yen": yen,
		"run_earned": run_earned,
		"board": board.duplicate(),
		"bubbles": bubbles.duplicate(),
		"hires": hires,
		"run_started": run_started,
		"coffee_level": coffee_level,
		"pc_level": pc_level,
		"desk_level": desk_level,
		"rank": rank,
		"xp": xp,
		"careers": careers,
		"actions_left": actions_left,
		"action_day": action_day,
		"ad_actions_used_day": ad_actions_used_day,
		"stamina": stamina,
		"ad_2x_left_s": ad_2x_left_s,
		"nomikai_buff_s": nomikai_buff_s,
		"last_seen_unix": last_seen_unix,
		"installed_unix": installed_unix,
		"last_interstitial_unix": last_interstitial_unix,
		"last_rewarded_unix": last_rewarded_unix,
		"minigame_last_play": minigame_last_play.duplicate(),
		"sound_on": sound_on,
		"music_on": music_on,
	}


## Builds a state from untrusted data: wrong types or ranges fall back to safe values.
static func from_dict(data: Dictionary) -> PlayerState:
	var s := PlayerState.new()
	s.rank = int(_num(data, "rank", 0.0, 0.0, EconomyData.CEO_RANK))
	s.reset_run()  # board size depends on rank
	s.yen = _num(data, "yen", 0.0, 0.0, INF)
	s.run_earned = _num(data, "run_earned", 0.0, 0.0, INF)
	_fill_ints(data.get("board", []), s.board, EconomyData.MAX_LEVEL)
	_fill_floats(data.get("bubbles", []), s.bubbles)
	for i: int in s.board.size():
		if s.board[i] == 0:
			s.bubbles[i] = 0.0
	s.hires = int(_num(data, "hires", 0.0, 0.0, 1.0e6))
	s.run_started = _flag(data, "run_started", false)
	s.coffee_level = int(_num(data, "coffee_level", 0.0, 0.0, 1.0e6))
	s.pc_level = int(_num(data, "pc_level", 0.0, 0.0, EconomyData.PC_MAX_LEVEL))
	s.desk_level = int(_num(data, "desk_level", 0.0, 0.0, 1.0e6))
	s.xp = int(_num(data, "xp", 0.0, 0.0, 1.0e9))
	s.careers = int(_num(data, "careers", 0.0, 0.0, 1.0e6))
	s.actions_left = int(_num(data, "actions_left", EconomyData.ACTIONS_PER_DAY, 0.0, 1.0e6))
	s.action_day = int(_num(data, "action_day", -1.0, -1.0, 1.0e9))
	s.ad_actions_used_day = int(_num(data, "ad_actions_used_day", -1.0, -1.0, 1.0e9))
	s.stamina = _num(data, "stamina", EconomyData.STAMINA_MAX, 0.0, EconomyData.STAMINA_MAX)
	s.ad_2x_left_s = _num(data, "ad_2x_left_s", 0.0, 0.0, EconomyData.AD_2X_MAX_STACK_S)
	s.nomikai_buff_s = _num(data, "nomikai_buff_s", 0.0, 0.0, EconomyData.NOMIKAI_BUFF_S)
	s.last_seen_unix = _num(data, "last_seen_unix", 0.0, 0.0, INF)
	s.installed_unix = _num(data, "installed_unix", 0.0, 0.0, INF)
	s.last_interstitial_unix = _num(data, "last_interstitial_unix", 0.0, 0.0, INF)
	s.last_rewarded_unix = _num(data, "last_rewarded_unix", 0.0, 0.0, INF)
	_fill_floats(data.get("minigame_last_play", []), s.minigame_last_play)
	s.sound_on = _flag(data, "sound_on", true)
	s.music_on = _flag(data, "music_on", true)
	return s


static func _fill_ints(raw: Variant, target: Array[int], hi: int) -> void:
	if raw is Array:
		for i: int in mini((raw as Array).size(), target.size()):
			target[i] = int(_clean(raw[i], 0.0, 0.0, hi))


static func _fill_floats(raw: Variant, target: Array[float]) -> void:
	if raw is Array:
		for i: int in mini((raw as Array).size(), target.size()):
			target[i] = _clean(raw[i], 0.0, 0.0, INF)


static func _flag(data: Dictionary, key: String, fallback: bool) -> bool:
	var value: Variant = data.get(key, fallback)
	return value if value is bool else fallback


static func _num(data: Dictionary, key: String, fallback: float, lo: float, hi: float) -> float:
	return _clean(data.get(key, fallback), fallback, lo, hi)


static func _clean(value: Variant, fallback: float, lo: float, hi: float) -> float:
	if not (value is float or value is int):
		return fallback
	var f: float = float(value)
	if is_nan(f) or is_inf(f):
		return fallback
	return clampf(f, lo, hi)
