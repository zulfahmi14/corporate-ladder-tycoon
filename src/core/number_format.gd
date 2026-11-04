class_name NumberFormat
extends RefCounted
## Short number display with 3 significant digits: 999, 1.23K, 45.6M, 789B.

const SUFFIXES: Array[String] = ["", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc"]


static func short(value: float) -> String:
	if is_nan(value) or is_inf(value):
		return "?"
	if value < 0.0:
		return "-" + short(-value)
	if value < 1000.0:
		return str(floori(value))
	var tier: int = floori(log(value) / log(1000.0))
	var scaled: float = value / pow(1000.0, tier)
	# Rounding can turn 999.96K into "1000K"; move to the next suffix instead.
	if snappedf(scaled, _step(scaled)) >= 1000.0:
		tier += 1
		scaled /= 1000.0
	if tier >= SUFFIXES.size():
		return String.num_scientific(value)
	return _digits(scaled) + SUFFIXES[tier]


static func yen(value: float) -> String:
	return "¥" + short(value)


static func _step(scaled: float) -> float:
	if scaled < 10.0:
		return 0.01
	if scaled < 100.0:
		return 0.1
	return 1.0


static func _digits(scaled: float) -> String:
	if scaled < 10.0:
		return "%.2f" % scaled
	if scaled < 100.0:
		return "%.1f" % scaled
	return "%d" % roundi(scaled)
