extends Node
## Owns the live PlayerState: ticks income, saves, and pays offline earnings.

signal changed
signal offline_collected(amount: float)

var state: PlayerState


func _ready() -> void:
	var now: float = Clock.now_unix()
	state = SaveSystem.load_state()
	if state == null:
		state = PlayerState.new()
		state.installed_unix = now
	elif state.last_seen_unix > 0.0:
		var amount: float = GameRules.collect_offline(state, now, false)
		if amount > 0.0:
			offline_collected.emit.call_deferred(amount)
	state.last_seen_unix = now


func _process(delta: float) -> void:
	var ps: float = GameRules.coworker_ps(state) * GameRules.boost_mult(state)
	GameRules.earn(state, ps * delta)
	state.ad_2x_left_s = maxf(0.0, state.ad_2x_left_s - delta)
	state.last_seen_unix = Clock.now_unix()
	changed.emit()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		state.last_seen_unix = Clock.now_unix()
		SaveSystem.save_now(state)


## Call after any player action so it is saved soon.
func mark_dirty() -> void:
	SaveSystem.request_save(state)
	changed.emit()
