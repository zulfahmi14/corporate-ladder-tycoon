class_name MinigameHub
extends Control
## Mini game menu: pick a game and difficulty, play it, collect the reward.

signal closed

var _menu: VBoxContainer
var _rows: VBoxContainer
var _result: VBoxContainer
var _result_label: Label
var _view: MinigameView
var _playing_game: int = -1
var _playing_difficulty: int = 0
var _refresh_timer: float = 0.0
var _row_status: Array[Label] = []
var _row_buttons: Array[HBoxContainer] = []
var _difficulty_buttons: Array = []  # Array of Array[Button], one per game


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(GameTheme.background())
	_build_menu()
	_build_result()
	_refresh()


func _process(delta: float) -> void:
	_refresh_timer -= delta
	if _refresh_timer <= 0.0 and _menu.visible:
		_refresh_timer = 1.0
		_refresh()


func _build_menu() -> void:
	_menu = _page()
	_menu.add_child(MinigameView.make_label(tr("MINIGAMES_TITLE"), 64))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_menu.add_child(scroll)
	_rows = VBoxContainer.new()
	_rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_rows.add_theme_constant_override("separation", 40)
	scroll.add_child(_rows)
	var back := MinigameView.make_button(tr("BACK_BUTTON"), 140)
	back.pressed.connect(func() -> void: closed.emit())
	_menu.add_child(back)


func _build_result() -> void:
	_result = _page()
	_result_label = MinigameView.make_label("", 56)
	_result_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_result_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_result.add_child(_result_label)
	var ok := MinigameView.make_button(tr("COLLECT_BUTTON"), 180)
	ok.pressed.connect(_show_menu)
	_result.add_child(ok)
	_result.visible = false


func _page() -> VBoxContainer:
	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 32)
	MinigameView.add_page(self, page)
	return page


func _refresh() -> void:
	if _row_status.is_empty():
		for game: int in MinigameRules.count():
			_rows.add_child(_make_row(game))
	var s: PlayerState = GameState.state
	var now: float = Clock.now_unix()
	for game: int in MinigameRules.count():
		_update_row(s, game, now)


## Builds a row once; _update_row changes its text in place so taps are never lost.
func _make_row(game: int) -> VBoxContainer:
	var row := VBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	row.add_child(MinigameView.make_label(tr(MinigameData.NAME_KEYS[game]), 48))
	var status := MinigameView.make_label("", 36)
	row.add_child(status)
	_row_status.append(status)
	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 16)
	var row_buttons: Array[Button] = []
	for diff: int in MinigameData.DIFFICULTY_MULT.size():
		var button := MinigameView.make_button("", 150)
		MinigameView.paint(button, [Palette.GREEN, Palette.BLUE, Palette.RED][diff])
		button.pressed.connect(_start.bind(game, diff))
		buttons.add_child(button)
		row_buttons.append(button)
	row.add_child(buttons)
	_row_buttons.append(buttons)
	_difficulty_buttons.append(row_buttons)
	return row


func _update_row(s: PlayerState, game: int, now: float) -> void:
	var status: Label = _row_status[game]
	var buttons: HBoxContainer = _row_buttons[game]
	if not MinigameRules.is_unlocked(s, game):
		var rank_name: String = tr(EconomyData.RANK_KEYS[MinigameData.UNLOCK_RANK[game]])
		status.text = tr("MINIGAME_LOCKED").format({"rank": rank_name})
		status.visible = true
		buttons.visible = false
		return
	var wait: float = MinigameRules.cooldown_left(s, game, now)
	status.visible = wait > 0.0
	buttons.visible = wait <= 0.0
	if wait > 0.0:
		var secs: int = ceili(wait)
		status.text = tr("MINIGAME_COOLDOWN").format(
			{"time": "%d:%02d" % [floori(secs / 60.0), secs % 60]}
		)
		return
	var row_buttons: Array[Button] = _difficulty_buttons[game]
	for diff: int in row_buttons.size():
		var best: float = MinigameRules.reward(s, game, diff, 1.0)
		row_buttons[diff].text = (
			"%s\n%s" % [tr(MinigameData.DIFFICULTY_KEYS[diff]), NumberFormat.yen(best)]
		)


func _start(game: int, diff: int) -> void:
	_playing_game = game
	_playing_difficulty = diff
	_menu.visible = false
	_view = _make_view(game)
	_view.setup(diff, int(Time.get_ticks_usec()))
	_view.finished.connect(_on_finished)
	add_child(_view)


static func _make_view(game: int) -> MinigameView:
	match game:
		1:
			return InboxView.new()
		2:
			return ExpenseView.new()
		3:
			return PitchView.new()
		4:
			return BoardView.new()
		_:
			return HankoView.new()


func _on_finished(score: float) -> void:
	var amount: float = MinigameRules.finish(
		GameState.state, _playing_game, _playing_difficulty, score, Clock.now_unix()
	)
	GameState.mark_dirty()
	_view.queue_free()
	_view = null
	_result_label.text = tr("MINIGAME_RESULT").format(
		{"score": roundi(score * 100.0), "amount": NumberFormat.yen(maxf(amount, 0.0))}
	)
	_result.visible = true


func _show_menu() -> void:
	_result.visible = false
	_menu.visible = true
	_refresh()
