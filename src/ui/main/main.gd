extends Control
## Main screen: the merge office. Tap bubbles to collect, drag to move or merge,
## hire to fill desks, reach the promotion goal.

const FONT_SIZE: int = 36
const TOAST_S: float = 2.5

var _rank_label: Label
var _yen_label: Label
var _income_label: Label
var _goal_label: Label
var _actions_label: Label
var _promote_button: Button
var _away_button: Button
var _fire_button: Button
var _fire_mode: bool = false
var _hire_button: Button
var _grid: GridContainer
var _cells: Array[DeskCell] = []
var _toast: Label
var _toast_left: float = 0.0
var _overlay: Control


func _ready() -> void:
	var t := Theme.new()
	t.default_font_size = FONT_SIZE
	theme = t
	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 12)
	MinigameView.add_page(self, page)
	_rank_label = MinigameView.make_label("", 36)
	page.add_child(_rank_label)
	_yen_label = MinigameView.make_label("", 80)
	page.add_child(_yen_label)
	_income_label = MinigameView.make_label("", 32)
	page.add_child(_income_label)
	_goal_label = MinigameView.make_label("", 32)
	page.add_child(_goal_label)
	_promote_button = MinigameView.make_button("", 120)
	MinigameView.paint(_promote_button, MinigameView.GOOD_COLOR)
	_promote_button.pressed.connect(_on_promote)
	page.add_child(_promote_button)
	_away_button = MinigameView.make_button("", 120)
	MinigameView.paint(_away_button, DeskCell.BUBBLE_COLOR)
	_away_button.pressed.connect(_on_collect_away)
	page.add_child(_away_button)
	_actions_label = MinigameView.make_label("", 28)
	page.add_child(_actions_label)
	_fire_button = MinigameView.make_button("", 110)
	MinigameView.paint(_fire_button, DeskCell.FIRE_COLOR)
	_fire_button.pressed.connect(_on_fire_button)
	page.add_child(_fire_button)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	page.add_child(scroll)
	_grid = GridContainer.new()
	_grid.columns = EconomyData.BOARD_COLS
	_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_grid)
	page.add_child(_build_bottom_bar())
	_toast = MinigameView.make_label("", 32)
	_toast.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_toast.offset_top = -330
	_toast.offset_bottom = -260
	_toast.offset_left = -500
	_toast.offset_right = 500
	add_child(_toast)
	GameState.changed.connect(_refresh)
	GameState.offline_earned.connect(_on_offline_earned)
	_refresh()


func _build_bottom_bar() -> HBoxContainer:
	var bar := HBoxContainer.new()
	bar.add_theme_constant_override("separation", 16)
	_hire_button = MinigameView.make_button("", 150)
	MinigameView.paint(_hire_button, Color(0.35, 0.58, 0.9))
	_hire_button.pressed.connect(_on_hire)
	bar.add_child(_hire_button)
	var upgrades := MinigameView.make_button(tr("MAIN_UPGRADES_BUTTON"), 150)
	upgrades.pressed.connect(_open_overlay.bind(true))
	bar.add_child(upgrades)
	var games := MinigameView.make_button(tr("MAIN_MINIGAMES_BUTTON"), 150)
	games.pressed.connect(_open_overlay.bind(false))
	bar.add_child(games)
	return bar


func _process(delta: float) -> void:
	if _toast_left > 0.0:
		_toast_left -= delta
		if _toast_left <= 0.0:
			_toast.text = ""


func _rebuild_board_if_needed(size: int) -> void:
	if _cells.size() == size:
		return
	for cell: DeskCell in _cells:
		cell.queue_free()
	_cells.clear()
	for i: int in size:
		var cell := DeskCell.new(i)
		cell.tapped.connect(_on_desk_tapped)
		cell.dropped.connect(_on_desk_dropped)
		_grid.add_child(cell)
		_cells.append(cell)


func _on_desk_tapped(desk: int) -> void:
	var s: PlayerState = GameState.state
	if _fire_mode:
		_fire_at(desk)
		return
	if not GameRules.bubble_full(s, desk):
		return
	var amount: float = GameRules.claim(s, desk)
	_float_text(_cells[desk], "+" + NumberFormat.yen(amount))
	GameState.mark_dirty()


func _on_desk_dropped(from: int, to: int) -> void:
	var result: GameRules.DeskResult = GameRules.desk_action(GameState.state, from, to)
	match result:
		GameRules.DeskResult.MERGED:
			_float_text(_cells[to], tr("MERGE_DONE"))
			Input.vibrate_handheld(40)
		GameRules.DeskResult.NO_ACTIONS:
			_show_toast(tr("TOAST_NO_ACTIONS"))
		GameRules.DeskResult.NOT_NEIGHBORS:
			_show_toast(tr("TOAST_NOT_NEIGHBORS"))
		GameRules.DeskResult.MAX_LEVEL:
			_show_toast(tr("TOAST_MAX_LEVEL"))
		GameRules.DeskResult.OCCUPIED:
			_show_toast(tr("TOAST_OCCUPIED"))
	GameState.mark_dirty()


func _on_hire() -> void:
	var s: PlayerState = GameState.state
	var desk: int = GameRules.hire(s, GameState.rng)
	if desk < 0:
		if GameRules.free_desks(s).is_empty():
			_show_toast(tr("TOAST_OFFICE_FULL"))
		return
	_float_text(_cells[desk], tr("HIRE_DONE"))
	GameState.mark_dirty()


func _on_promote() -> void:
	if GameRules.promote(GameState.state, GameState.rng) >= 0:
		Input.vibrate_handheld(120)
		_show_toast(
			tr("TOAST_PROMOTED").format({"rank": tr(EconomyData.RANK_KEYS[GameState.state.rank])})
		)
		GameState.mark_dirty()


func _on_collect_away() -> void:
	var amount: float = GameRules.collect_away(GameState.state, false)
	if amount > 0.0:
		_float_text(_away_button, "+" + NumberFormat.yen(amount))
		GameState.mark_dirty()


func _on_fire_button() -> void:
	_fire_mode = not _fire_mode
	if _fire_mode:
		_show_toast(tr("TOAST_FIRE_PICK"))
	_refresh()


func _fire_at(desk: int) -> void:
	var s: PlayerState = GameState.state
	if s.board[desk] == 0:
		return
	var fee: float = GameRules.fire(s, desk)
	if fee < 0.0:
		_show_toast(tr("TOAST_FIRE_TOO_POOR"))
		return
	_fire_mode = false
	_float_text(_cells[desk], "-" + NumberFormat.yen(fee))
	GameState.mark_dirty()


func _on_offline_earned(amount: float) -> void:
	_show_toast(tr("TOAST_OFFLINE").format({"amount": NumberFormat.yen(amount)}))


func _open_overlay(upgrades: bool) -> void:
	if _overlay != null:
		return
	if upgrades:
		var panel := UpgradesPanel.new()
		panel.closed.connect(_close_overlay)
		_overlay = panel
	else:
		var hub := MinigameHub.new()
		hub.closed.connect(_close_overlay)
		_overlay = hub
	add_child(_overlay)


func _close_overlay() -> void:
	_overlay.queue_free()
	_overlay = null


func _show_toast(text: String) -> void:
	_toast.text = text
	_toast_left = TOAST_S


func _float_text(cell: Control, text: String) -> void:
	var label := MinigameView.make_label(text, 34)
	label.add_theme_color_override("font_color", DeskCell.BUBBLE_COLOR)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	label.size = Vector2(cell.size.x, 50)
	label.global_position = cell.global_position + Vector2(0, 20)
	var tween := label.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "global_position:y", label.global_position.y - 90, 0.7)
	tween.tween_property(label, "modulate:a", 0.0, 0.7)
	tween.chain().tween_callback(label.queue_free)


func _refresh() -> void:
	var s: PlayerState = GameState.state
	_rebuild_board_if_needed(s.board.size())
	_rank_label.text = tr(EconomyData.RANK_KEYS[s.rank])
	_yen_label.text = NumberFormat.yen(s.yen)
	_income_label.text = tr("MAIN_INCOME_PER_SEC").format(
		{"amount": NumberFormat.yen(GameRules.income_ps(s))}
	)
	_refresh_goal(s)
	_actions_label.text = tr("MAIN_ACTIONS").format(
		{"left": s.actions_left, "max": EconomyData.ACTIONS_PER_DAY}
	)
	var cost: float = GameRules.hire_cost(s)
	var full: bool = GameRules.free_desks(s).is_empty()
	_hire_button.text = (
		tr("MAIN_OFFICE_FULL")
		if full
		else tr("MAIN_HIRE_BUTTON").format({"cost": NumberFormat.yen(cost)})
	)
	_hire_button.disabled = full or cost > s.yen
	_away_button.visible = s.away_pending > 0.0
	_away_button.text = tr("MAIN_WELCOME_BACK").format({"amount": NumberFormat.yen(s.away_pending)})
	var stuck: bool = GameRules.is_stuck(s)
	if not stuck:
		_fire_mode = false
	_fire_button.visible = stuck
	_fire_button.text = tr("MAIN_FIRE_CANCEL") if _fire_mode else tr("MAIN_FIRE_BUTTON")
	var goal: int = EconomyData.GOAL_LEVEL[s.rank]
	for desk: int in _cells.size():
		var level: int = s.board[desk]
		var ready: bool = GameRules.bubble_full(s, desk)
		var bubble: String = "+" + NumberFormat.yen(s.bubbles[desk]) if ready else ""
		var fire_text: String = ""
		if _fire_mode and level > 0:
			fire_text = "-" + NumberFormat.yen(GameRules.fire_cost(s, desk))
		_cells[desk].show_state(
			level,
			bubble,
			GameRules.bubble_fraction(s, desk),
			_has_twin_neighbor(s, desk),
			level >= goal,
			fire_text
		)


func _refresh_goal(s: PlayerState) -> void:
	var level: int = EconomyData.GOAL_LEVEL[s.rank]
	_goal_label.text = (
		tr("MAIN_GOAL")
		. format(
			{
				"count": EconomyData.GOAL_COUNT[s.rank],
				"level": level,
				"name": tr(EconomyData.LEVEL_KEYS[level - 1]),
				"have":
				mini(Economy.goal_progress(s.board, s.rank), EconomyData.GOAL_COUNT[s.rank]),
			}
		)
	)
	var ready: bool = GameRules.can_promote(s)
	_promote_button.visible = ready
	if ready:
		_promote_button.text = tr("MAIN_PROMOTE_BUTTON").format(
			{"rank": tr(EconomyData.RANK_KEYS[s.rank + 1])}
		)


static func _has_twin_neighbor(s: PlayerState, desk: int) -> bool:
	var level: int = s.board[desk]
	if level == 0 or level >= EconomyData.MAX_LEVEL:
		return false
	for n: int in Economy.neighbors(desk, s.board.size()):
		if s.board[n] == level:
			return true
	return false
