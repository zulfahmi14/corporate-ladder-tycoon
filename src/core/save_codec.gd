class_name SaveCodec
extends RefCounted
## Save file format: {"version": N, "state": {...}}. Migrations upgrade old versions.

const CURRENT_VERSION: int = 2


static func encode(state: PlayerState) -> String:
	return JSON.stringify({"version": CURRENT_VERSION, "state": state.to_dict()})


## Returns null when the text is not a valid save (caller falls back to backup).
static func decode(text: String) -> PlayerState:
	var json := JSON.new()
	if json.parse(text) != OK:
		return null
	var parsed: Variant = json.data
	if not parsed is Dictionary:
		return null
	var root: Dictionary = parsed
	var version: Variant = root.get("version")
	var state: Variant = root.get("state")
	if not (version is float or version is int) or not state is Dictionary:
		return null
	if int(version) > CURRENT_VERSION:
		return null  # Saved by a newer build; refuse rather than corrupt it.
	return PlayerState.from_dict(_migrate(state, int(version)))


static func _migrate(state: Dictionary, version: int) -> Dictionary:
	var out: Dictionary = state.duplicate()
	if version < 2:
		# v1 had a list of owned coworkers and a yen promotion requirement. The merge
		# office starts a fresh run at the same rank; XP, careers and settings are kept.
		for key: String in ["yen", "run_earned", "owned", "coffee_level", "pc_level", "desk_level"]:
			out.erase(key)
	return out
