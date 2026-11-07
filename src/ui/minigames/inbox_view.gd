class_name InboxView
extends MinigameView
## Inbox Sort: tap Work or Spam for each email before its timer runs out.

var _emails: Array[Dictionary] = []
var _index: int = 0
var _correct: int = 0
var _time_left: float = 0.0
var _subject: Label
var _timer_bar: ProgressBar


func _title_key() -> String:
	return "MINIGAME_INBOX"


func _build(body: VBoxContainer) -> void:
	_emails = InboxLogic.make_emails(rng)
	_subject = make_label("", 52)
	_subject.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_subject.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	body.add_child(_subject)
	_timer_bar = ProgressBar.new()
	_timer_bar.show_percentage = false
	_timer_bar.custom_minimum_size = Vector2(0, 32)
	body.add_child(_timer_bar)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 24)
	body.add_child(row)
	var work := make_button(tr("INBOX_WORK_BUTTON"), 300)
	paint(work, GOOD_COLOR)
	work.pressed.connect(_answer.bind(true))
	row.add_child(work)
	var spam := make_button(tr("INBOX_SPAM_BUTTON"), 300)
	paint(spam, BAD_COLOR)
	spam.pressed.connect(_answer.bind(false))
	row.add_child(spam)
	_show_email()


func _process(delta: float) -> void:
	if is_done():
		return
	_time_left -= delta
	_timer_bar.value = 100.0 * _time_left / InboxLogic.TIME_PER_EMAIL_S[difficulty]
	if _time_left <= 0.0:
		_next()


func _answer(said_work: bool) -> void:
	if is_done():
		return
	if said_work == bool(_emails[_index]["is_work"]):
		_correct += 1
	_next()


func _next() -> void:
	_index += 1
	if _index >= _emails.size():
		finish(InboxLogic.score(_correct))
		return
	_show_email()


func _show_email() -> void:
	_subject.text = tr(String(_emails[_index]["key"]))
	_time_left = InboxLogic.TIME_PER_EMAIL_S[difficulty]
	set_status(
		tr("MINIGAME_STATUS_PROGRESS").format(
			{"n": _index + 1, "total": _emails.size(), "score": _correct}
		)
	)
