extends Node
## Single source of wall-clock time so tests and debugging can fake it.

var fixed_unix: float = -1.0


func now_unix() -> float:
	if fixed_unix >= 0.0:
		return fixed_unix
	return Time.get_unix_time_from_system()


func is_evening() -> bool:
	var hour: int = Time.get_datetime_dict_from_system().get("hour", 0)
	return hour >= 18
