extends Node
## Atomic local save: write save.tmp, keep the old file as save.bak, then rename.

const SAVE_PATH := "user://save.json"
const TMP_PATH := "user://save.tmp"
const BACKUP_PATH := "user://save.bak"
const DEBOUNCE_S := 2.0

var _timer: Timer
var _pending: PlayerState


func _ready() -> void:
	_ensure_timer()


## Saves 2 seconds after the last request.
func request_save(state: PlayerState) -> void:
	_pending = state
	_ensure_timer()
	if _timer.is_inside_tree():
		_timer.start()


## Saves now (used when the app is paused or closed).
func save_now(state: PlayerState) -> void:
	_pending = state
	if _timer != null and _timer.is_inside_tree():
		_timer.stop()
	_flush()


## Loads the save, falling back to the backup, then to a fresh state.
func load_state() -> PlayerState:
	for path: String in [SAVE_PATH, BACKUP_PATH]:
		if not FileAccess.file_exists(path):
			continue
		var state: PlayerState = SaveCodec.decode(FileAccess.get_file_as_string(path))
		if state != null:
			return state
		push_error("Save file unreadable: %s" % path)
	return null


## Created on first use, so saving works even if called before _ready.
func _ensure_timer() -> void:
	if _timer != null:
		return
	_timer = Timer.new()
	_timer.one_shot = true
	_timer.wait_time = DEBOUNCE_S
	_timer.timeout.connect(_flush)
	add_child(_timer)


func _flush() -> void:
	if _pending == null:
		return
	var file := FileAccess.open(TMP_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Cannot write save: %s" % FileAccess.get_open_error())
		return
	file.store_string(SaveCodec.encode(_pending))
	file.close()
	var dir := DirAccess.open("user://")
	if dir.file_exists("save.json"):
		dir.rename("save.json", "save.bak")
	dir.rename("save.tmp", "save.json")
	_pending = null
