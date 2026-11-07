class_name PlayerState
extends RefCounted
## Everything that is saved. Plain data; rules live in GameRules.

var yen: float = 0.0
var run_earned: float = 0.0
var owned: Array[int] = []
var coffee_level: int = 0
var pc_level: int = 0
var desk_level: int = 0
var rank: int = 0
var xp: int = 0
var careers: int = 0
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


## Clears everything a promotion resets.
func reset_run() -> void:
	yen = 0.0
	run_earned = 0.0
	owned.clear()
	owned.resize(EconomyData.COWORKER_BASE_COSTS.size())
	owned.fill(0)
	coffee_level = 0
	pc_level = 0
	desk_level = 0
	nomikai_buff_s = 0.0


func to_dict() -> Dictionary:
	return {
		"yen": yen,
		"run_earned": run_earned,
		"owned": owned.duplicate(),
		"coffee_level": coffee_level,
		"pc_level": pc_level,
		"desk_level": desk_level,
		"rank": rank,
		"xp": xp,
		"careers": careers,
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
	s.yen = _num(data, "yen", 0.0, 0.0, INF)
	s.run_earned = _num(data, "run_earned", 0.0, 0.0, INF)
	var raw_owned: Variant = data.get("owned", [])
	if raw_owned is Array:
		for i: int in mini(raw_owned.size(), s.owned.size()):
			s.owned[i] = int(_clean(raw_owned[i], 0.0, 0.0, 1.0e6))
	s.coffee_level = int(_num(data, "coffee_level", 0.0, 0.0, 1.0e6))
	s.pc_level = int(_num(data, "pc_level", 0.0, 0.0, EconomyData.PC_MAX_LEVEL))
	s.desk_level = int(_num(data, "desk_level", 0.0, 0.0, 1.0e6))
	s.rank = int(_num(data, "rank", 0.0, 0.0, EconomyData.CEO_RANK))
	s.xp = int(_num(data, "xp", 0.0, 0.0, 1.0e9))
	s.careers = int(_num(data, "careers", 0.0, 0.0, 1.0e6))
	s.stamina = _num(data, "stamina", EconomyData.STAMINA_MAX, 0.0, EconomyData.STAMINA_MAX)
	s.ad_2x_left_s = _num(data, "ad_2x_left_s", 0.0, 0.0, EconomyData.AD_2X_MAX_STACK_S)
	s.nomikai_buff_s = _num(data, "nomikai_buff_s", 0.0, 0.0, EconomyData.NOMIKAI_BUFF_S)
	s.last_seen_unix = _num(data, "last_seen_unix", 0.0, 0.0, INF)
	s.installed_unix = _num(data, "installed_unix", 0.0, 0.0, INF)
	s.last_interstitial_unix = _num(data, "last_interstitial_unix", 0.0, 0.0, INF)
	s.last_rewarded_unix = _num(data, "last_rewarded_unix", 0.0, 0.0, INF)
	var raw_plays: Variant = data.get("minigame_last_play", [])
	if raw_plays is Array:
		for i: int in mini(raw_plays.size(), s.minigame_last_play.size()):
			s.minigame_last_play[i] = _clean(raw_plays[i], 0.0, 0.0, INF)
	s.sound_on = _flag(data, "sound_on", true)
	s.music_on = _flag(data, "music_on", true)
	return s


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
