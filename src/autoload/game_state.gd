extends Node
## Owns the live PlayerState: fills bubbles, handles the daily actions, saves,
## and adds offline earnings to the bubbles on start.

signal changed
signal offline_earned(amount: float)

var state: PlayerState
var rng := RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()
	var now: float = Clock.now_unix()
	state = SaveSystem.load_state()
	if state == null:
		state = PlayerState.new()
		state.installed_unix = now
	elif state.last_seen_unix > 0.0:
		var amount: float = GameRules.fill_offline(state, now)
		if amount > 0.0:
			offline_earned.emit.call_deferred(amount)
	GameRules.start_run(state, rng)
	GameRules.refresh_actions(state, Economy.action_day(Clock.now_local_unix()))
	state.last_seen_unix = now


func _process(delta: float) -> void:
	GameRules.fill_bubbles(state, delta)
	state.ad_2x_left_s = maxf(0.0, state.ad_2x_left_s - delta)
	state.last_seen_unix = Clock.now_unix()
	changed.emit()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		state.last_seen_unix = Clock.now_unix()
		SaveSystem.save_now(state)
	elif what == NOTIFICATION_APPLICATION_RESUMED:
		var amount: float = GameRules.fill_offline(state, Clock.now_unix())
		state.last_seen_unix = Clock.now_unix()
		if amount > 0.0:
			offline_earned.emit(amount)


## Call after any player action so it is saved soon.
func mark_dirty() -> void:
	GameRules.refresh_actions(state, Economy.action_day(Clock.now_local_unix()))
	SaveSystem.request_save(state)
	changed.emit()
