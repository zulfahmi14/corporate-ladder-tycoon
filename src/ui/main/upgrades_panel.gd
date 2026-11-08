class_name UpgradesPanel
extends Control
## Overlay listing the three upgrades with their next cost.

signal closed

var _buttons: Array[Button] = []


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color(0.16, 0.17, 0.2)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 32)
	MinigameView.add_page(self, page)
	page.add_child(MinigameView.make_label(tr("UPGRADES_TITLE"), 64))
	for i: int in 3:
		var button := MinigameView.make_button("", 200)
		button.pressed.connect(_buy.bind(i))
		page.add_child(button)
		_buttons.append(button)
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_child(spacer)
	var back := MinigameView.make_button(tr("BACK_BUTTON"), 140)
	back.pressed.connect(func() -> void: closed.emit())
	page.add_child(back)
	GameState.changed.connect(_refresh)
	_refresh()


func _buy(i: int) -> void:
	var s: PlayerState = GameState.state
	var ok: bool = false
	match i:
		0:
			ok = GameRules.buy_coffee(s)
		1:
			ok = GameRules.buy_pc(s)
		_:
			ok = GameRules.buy_desk(s)
	if ok:
		GameState.mark_dirty()


func _refresh() -> void:
	var s: PlayerState = GameState.state
	_set_row(0, "UPGRADE_COFFEE", s.coffee_level, Economy.coffee_cost(s.coffee_level), false)
	var pc_maxed: bool = s.pc_level >= EconomyData.PC_MAX_LEVEL
	_set_row(1, "UPGRADE_PC", s.pc_level, Economy.pc_cost(s.pc_level), pc_maxed)
	_set_row(2, "UPGRADE_DESK", s.desk_level, Economy.desk_cost(s.desk_level), false)


func _set_row(i: int, key: String, level: int, cost: float, maxed: bool) -> void:
	var cost_text: String = tr("MAX_LEVEL") if maxed else NumberFormat.yen(cost)
	_buttons[i].text = tr(key).format({"level": level, "cost": cost_text})
	_buttons[i].disabled = maxed or cost > GameState.state.yen
