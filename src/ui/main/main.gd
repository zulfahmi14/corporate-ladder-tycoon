extends Control
## Main screen: yen, rank, tap to work, promotion, hiring, and the mini game hub.

const FONT_SIZE: int = 40

var _rank_label: Label
var _yen_label: Label
var _income_label: Label
var _promote_button: Button
var _hire_list: VBoxContainer
var _hire_buttons: Array[Button] = []
var _hub: MinigameHub


func _ready() -> void:
	var t := Theme.new()
	t.default_font_size = FONT_SIZE
	theme = t
	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 28)
	MinigameView.add_page(self, page)
	_rank_label = MinigameView.make_label("", 44)
	page.add_child(_rank_label)
	_yen_label = MinigameView.make_label("", 96)
	page.add_child(_yen_label)
	_income_label = MinigameView.make_label("", 40)
	page.add_child(_income_label)
	var tap := MinigameView.make_button(tr("MAIN_TAP_BUTTON"), 360)
	tap.add_theme_font_size_override("font_size", 64)
	tap.pressed.connect(_on_tap)
	page.add_child(tap)
	var games := MinigameView.make_button(tr("MAIN_MINIGAMES_BUTTON"), 150)
	games.pressed.connect(_open_hub)
	page.add_child(games)
	_promote_button = MinigameView.make_button("", 150)
	MinigameView.paint(_promote_button, MinigameView.GOOD_COLOR)
	_promote_button.pressed.connect(_on_promote)
	page.add_child(_promote_button)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	page.add_child(scroll)
	_hire_list = VBoxContainer.new()
	_hire_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_hire_list.add_theme_constant_override("separation", 16)
	scroll.add_child(_hire_list)
	for i: int in EconomyData.COWORKER_KEYS.size():
		var hire := MinigameView.make_button("", 120)
		hire.pressed.connect(_on_hire.bind(i))
		_hire_list.add_child(hire)
		_hire_buttons.append(hire)
	GameState.changed.connect(_refresh)
	_refresh()


func _on_tap() -> void:
	GameRules.tap(GameState.state)
	GameState.mark_dirty()


func _on_hire(index: int) -> void:
	if GameRules.buy_coworker(GameState.state, index, 1):
		GameState.mark_dirty()


func _on_promote() -> void:
	if GameRules.promote(GameState.state) >= 0:
		GameState.mark_dirty()


func _open_hub() -> void:
	if _hub != null:
		return
	_hub = MinigameHub.new()
	_hub.closed.connect(_close_hub)
	add_child(_hub)


func _close_hub() -> void:
	_hub.queue_free()
	_hub = null


func _refresh() -> void:
	var s: PlayerState = GameState.state
	_rank_label.text = tr(EconomyData.RANK_KEYS[s.rank])
	_yen_label.text = NumberFormat.yen(s.yen)
	_income_label.text = tr("MAIN_INCOME_PER_SEC").format(
		{"amount": NumberFormat.yen(GameRules.coworker_ps(s))}
	)
	var can_promote: bool = (
		s.rank < EconomyData.CEO_RANK and Economy.can_promote(s.rank, s.run_earned)
	)
	_promote_button.visible = can_promote
	if can_promote:
		_promote_button.text = tr("MAIN_PROMOTE_BUTTON").format(
			{"rank": tr(EconomyData.RANK_KEYS[s.rank + 1])}
		)
	for i: int in _hire_buttons.size():
		var button: Button = _hire_buttons[i]
		button.visible = Economy.is_coworker_unlocked(i, s.rank)
		if button.visible:
			button.text = (
				tr("MAIN_HIRE_BUTTON")
				. format(
					{
						"name": tr(EconomyData.COWORKER_KEYS[i]),
						"owned": s.owned[i],
						"cost": NumberFormat.yen(Economy.coworker_cost(i, s.owned[i])),
					}
				)
			)
			button.disabled = Economy.coworker_cost(i, s.owned[i]) > s.yen
