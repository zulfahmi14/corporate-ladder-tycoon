extends Control
## Placeholder main screen for Phase 3: proves tap, hire and save work on a phone.

@onready var _yen_label: Label = %YenLabel
@onready var _income_label: Label = %IncomeLabel
@onready var _tap_button: Button = %TapButton
@onready var _hire_button: Button = %HireButton


func _ready() -> void:
	_tap_button.text = tr("MAIN_TAP_BUTTON")
	_tap_button.pressed.connect(_on_tap)
	_hire_button.pressed.connect(_on_hire)
	GameState.changed.connect(_refresh)
	_refresh()


func _on_tap() -> void:
	GameRules.tap(GameState.state)
	GameState.mark_dirty()


func _on_hire() -> void:
	if GameRules.buy_coworker(GameState.state, 0, 1):
		GameState.mark_dirty()


func _refresh() -> void:
	var s: PlayerState = GameState.state
	_yen_label.text = NumberFormat.yen(s.yen)
	_income_label.text = tr("MAIN_INCOME_PER_SEC").format(
		{"amount": NumberFormat.yen(GameRules.coworker_ps(s))}
	)
	_hire_button.text = (
		tr("MAIN_HIRE_BUTTON")
		. format(
			{
				"name": tr(EconomyData.COWORKER_KEYS[0]),
				"cost": NumberFormat.yen(Economy.coworker_cost(0, s.owned[0])),
			}
		)
	)
