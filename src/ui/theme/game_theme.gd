class_name GameTheme
extends RefCounted
## Builds the game's Theme in code: rounded font, candy buttons, cards, progress bars.

const FONT_PATH := "res://assets/fonts/mplus-rounded-1c/MPLUSRounded1c-ExtraBold.ttf"
const RADIUS: int = 28


static func build(font_size: int) -> Theme:
	var t := Theme.new()
	var font: Font = load(FONT_PATH)
	if font != null:
		t.default_font = font
	t.default_font_size = font_size
	t.set_color("font_color", "Label", Palette.INK)
	t.set_stylebox("normal", "Button", candy(Palette.CARD))
	t.set_stylebox("hover", "Button", candy(Palette.CARD))
	t.set_stylebox("focus", "Button", candy(Palette.CARD))
	t.set_stylebox("pressed", "Button", candy(Palette.CARD.darkened(0.08), true))
	t.set_stylebox("disabled", "Button", candy(Palette.CARD.darkened(0.12)))
	for key: String in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		t.set_color(key, "Button", Palette.INK)
	t.set_color("font_disabled_color", "Button", Palette.INK_SOFT)
	t.set_stylebox("background", "ProgressBar", card(Palette.CARD_EDGE, 12, false))
	t.set_stylebox("fill", "ProgressBar", card(Palette.GREEN, 12, false))
	t.set_stylebox("panel", "PanelContainer", card(Palette.CARD))
	return t


## Rounded box with a soft shadow.
static func card(color: Color, radius: int = RADIUS, shadow: bool = true) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.set_corner_radius_all(radius)
	box.content_margin_left = 20
	box.content_margin_right = 20
	box.content_margin_top = 12
	box.content_margin_bottom = 12
	if shadow:
		box.shadow_color = Palette.SHADOW
		box.shadow_size = 10
		box.shadow_offset = Vector2(0, 6)
	return box


## Candy button: rounded, with a darker bottom edge that flattens when pressed.
static func candy(color: Color, pressed: bool = false) -> StyleBoxFlat:
	var box := card(color, RADIUS, not pressed)
	box.border_color = color.darkened(0.22)
	box.border_width_bottom = 2 if pressed else 10
	box.content_margin_top = 14 if pressed else 10
	return box


## Full-screen warm gradient used behind every screen.
static func background() -> TextureRect:
	var gradient := Gradient.new()
	gradient.set_color(0, Palette.BG_TOP)
	gradient.set_color(1, Palette.BG_BOTTOM)
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill_from = Vector2(0, 0)
	texture.fill_to = Vector2(0, 1)
	var rect := TextureRect.new()
	rect.texture = texture
	rect.stretch_mode = TextureRect.STRETCH_SCALE
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rect
