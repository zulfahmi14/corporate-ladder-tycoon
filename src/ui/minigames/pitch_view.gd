class_name PitchView
extends MinigameView
## Pitch Timing: stop the sweeping needle inside the green zone.

const PAUSE_S: float = 0.7

var _round: int = 0
var _hits: int = 0
var _t: float = 0.0
var _zone_center: float = 0.5
var _pause_left: float = 0.0
var _track: ColorRect
var _zone: ColorRect
var _needle: ColorRect
var _feedback: Label


func _title_key() -> String:
	return "MINIGAME_PITCH"


func _build(body: VBoxContainer) -> void:
	_feedback = make_label("", 48)
	body.add_child(_feedback)
	_track = ColorRect.new()
	_track.color = Palette.CARD_EDGE
	_track.custom_minimum_size = Vector2(0, 160)
	body.add_child(_track)
	_zone = ColorRect.new()
	_zone.color = GOOD_COLOR
	_track.add_child(_zone)
	_needle = ColorRect.new()
	_needle.color = Palette.INK
	_track.add_child(_needle)
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(spacer)
	var stop := make_button(tr("PITCH_STOP_BUTTON"), 360)
	stop.pressed.connect(_on_stop)
	body.add_child(stop)
	_start_round()


func _process(delta: float) -> void:
	if is_done():
		return
	if _pause_left > 0.0:
		_pause_left -= delta
		if _pause_left <= 0.0:
			_round += 1
			if _round >= PitchLogic.ROUNDS:
				finish(PitchLogic.score(_hits))
				return
			_start_round()
		return
	_t += delta
	_layout()


func _on_stop() -> void:
	if is_done() or _pause_left > 0.0:
		return
	var needle: float = PitchLogic.needle_at(_t, PitchLogic.speed(difficulty, _round))
	var hit: bool = PitchLogic.is_hit(needle, _zone_center, difficulty)
	if hit:
		_hits += 1
	_feedback.text = tr("PITCH_HIT") if hit else tr("PITCH_MISS")
	_pause_left = PAUSE_S


func _start_round() -> void:
	var half: float = PitchLogic.ZONE_WIDTH[difficulty] / 2.0
	_zone_center = rng.randf_range(half, 1.0 - half)
	_t = rng.randf_range(0.0, 1.0)
	_feedback.text = ""
	set_status(
		tr("MINIGAME_STATUS_PROGRESS").format(
			{"n": _round + 1, "total": PitchLogic.ROUNDS, "score": _hits}
		)
	)
	_layout()


func _layout() -> void:
	var w: float = _track.size.x
	var h: float = _track.size.y
	var zone_w: float = PitchLogic.ZONE_WIDTH[difficulty] * w
	_zone.position = Vector2(_zone_center * w - zone_w / 2.0, 0.0)
	_zone.size = Vector2(zone_w, h)
	var needle: float = PitchLogic.needle_at(_t, PitchLogic.speed(difficulty, _round))
	_needle.position = Vector2(needle * w - 4.0, 0.0)
	_needle.size = Vector2(8.0, h)
