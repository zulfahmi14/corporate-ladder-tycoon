class_name SaveCodec
extends RefCounted
## Save file format: {"version": N, "state": {...}}. Migrations upgrade old versions.

const CURRENT_VERSION: int = 1


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
	# Version 1 is the first format; add "if version < N" steps here later.
	assert(version <= CURRENT_VERSION)
	return state
