class_name MinigameView
extends Control
## Base for mini game screens. Subclasses build their UI in _build() and call finish(score).

signal finished(score: float)

const GOOD_COLOR := Palette.GREEN
const BAD_COLOR := Palette.RED
const DIM_COLOR := Color("efe3f2")
const MARGIN_SIDE: int = 48
const MARGIN_TOP: int = 120
const MARGIN_BOTTOM: int = 96

var difficulty: int = MinigameData.Difficulty.NORMAL
var rng := RandomNumberGenerator.new()

var _done: bool = false
var _status: Label
var _body: VBoxContainer


func setup(diff: int, seed_value: int) -> void:
	difficulty = diff
	rng.seed = seed_value


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var root := VBoxContainer.new()
	add_page(self, root)
	root.add_theme_constant_override("separation", 24)
	root.add_child(make_label(tr(_title_key()), 56))
	root.add_child(make_label(tr(_title_key() + "_HOW"), 32))
	_status = make_label("", 40)
	root.add_child(_status)
	_body = VBoxContainer.new()
	_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_body.add_theme_constant_override("separation", 24)
	root.add_child(_body)
	_build(_body)


## Subclass hook: translation key of the game name (also used for "<key>_HOW").
func _title_key() -> String:
	return ""


## Subclass hook: add the game's controls to [param body].
func _build(_body_box: VBoxContainer) -> void:
	pass


func set_status(text: String) -> void:
	_status.text = text


func is_done() -> bool:
	return _done


## Ends the game once; later calls are ignored.
func finish(score: float) -> void:
	if _done:
		return
	_done = true
	finished.emit(clampf(score, 0.0, 1.0))


static func make_label(text: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	return label


## Adds [param page] to [param parent] filling the screen inside the safe margins.
static func add_page(parent: Control, page: Control) -> void:
	page.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	page.offset_left = MARGIN_SIDE
	page.offset_right = -MARGIN_SIDE
	page.offset_top = MARGIN_TOP
	page.offset_bottom = -MARGIN_BOTTOM
	parent.add_child(page)


## Candy-style fill colour for a button (readable text picked from the fill brightness).
static func paint(button: Button, color: Color) -> void:
	button.add_theme_stylebox_override("normal", GameTheme.candy(color))
	button.add_theme_stylebox_override("hover", GameTheme.candy(color))
	button.add_theme_stylebox_override("focus", GameTheme.candy(color))
	button.add_theme_stylebox_override("pressed", GameTheme.candy(color.darkened(0.1), true))
	button.add_theme_stylebox_override("disabled", GameTheme.candy(color.lerp(Color.WHITE, 0.55)))
	var ink: Color = Palette.INK if color.get_luminance() > 0.6 else Color.WHITE
	for key: String in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		button.add_theme_color_override(key, ink)
	button.add_theme_color_override("font_disabled_color", Color(1, 1, 1, 0.85))


static func make_button(text: String, min_height: float) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, min_height)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return button
