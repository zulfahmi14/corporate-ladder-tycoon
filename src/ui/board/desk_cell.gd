class_name DeskCell
extends Control
## One desk on the office board: draws a cute coworker at a desk with a monitor,
## the fill bar and the coin bubble; claims on tap; drag and drop between desks.

signal tapped(desk: int)
signal dropped(from: int, to: int)

const BUBBLE_COLOR := Palette.GOLD
const FIRE_COLOR := Palette.RED
const MERGE_GLOW := Color("ffffff")
const FILL_STEPS: float = 40.0

var desk: int = 0
var level: int = 0
var bubble_text: String = ""
var can_merge: bool = false
var goal_level: bool = false
var fill: float = 0.0
var fire_text: String = ""


func _init(index: int) -> void:
	desk = index
	custom_minimum_size = Vector2(230, 220)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_PASS


## Redraws only when something visible changed (fill is rounded to 40 steps).
func show_state(
	new_level: int,
	new_bubble: String,
	new_fill: float,
	mergeable: bool,
	at_goal: bool,
	new_fire_text: String
) -> void:
	var stepped: float = floorf(new_fill * FILL_STEPS) / FILL_STEPS
	if (
		new_level == level
		and new_bubble == bubble_text
		and is_equal_approx(stepped, fill)
		and mergeable == can_merge
		and at_goal == goal_level
		and new_fire_text == fire_text
	):
		return
	level = new_level
	bubble_text = new_bubble
	fill = stepped
	can_merge = mergeable
	goal_level = at_goal
	fire_text = new_fire_text
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	var mb := event as InputEventMouseButton
	if mb != null and mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
		tapped.emit(desk)


func _get_drag_data(_at: Vector2) -> Variant:
	if level == 0:
		return null
	var preview := Label.new()
	preview.text = "Lv%d" % level
	preview.add_theme_font_size_override("font_size", 52)
	preview.add_theme_color_override("font_color", Palette.LEVEL[level - 1])
	preview.add_theme_color_override("font_outline_color", Palette.INK)
	preview.add_theme_constant_override("outline_size", 12)
	var holder := Control.new()
	holder.add_child(preview)
	preview.position = Vector2(-40, -100)  # above the finger so it stays visible
	set_drag_preview(holder)
	return {"from_desk": desk}


func _can_drop_data(_at: Vector2, data: Variant) -> bool:
	return data is Dictionary and (data as Dictionary).has("from_desk")


func _drop_data(_at: Vector2, data: Variant) -> void:
	var from: int = int((data as Dictionary)["from_desk"])
	if from != desk:
		dropped.emit(from, desk)


func _draw() -> void:
	var r := Rect2(Vector2(6, 6), size - Vector2(12, 12))
	var tile_color: Color = Palette.CARD if level > 0 else Palette.CARD.darkened(0.06)
	draw_style_box(GameTheme.card(tile_color, 26, level > 0), r)
	if can_merge:
		var glow := GameTheme.card(Color(0, 0, 0, 0), 26, false)
		glow.border_color = Palette.TEAL
		glow.set_border_width_all(6)
		draw_style_box(glow, r)
	var font: Font = get_theme_default_font()
	if level > 0:
		_draw_coworker(r)
		_draw_desk(r)
		_draw_name_and_bar(r, font)
		if goal_level:
			_draw_star(r.position + Vector2(30, 30), 18.0)
	else:
		_draw_desk(r)
	if fire_text != "":
		_draw_pill(r, fire_text, FIRE_COLOR, Color.WHITE, font)
	elif bubble_text != "":
		_draw_pill(r, bubble_text, BUBBLE_COLOR, Palette.INK, font)


func _draw_coworker(r: Rect2) -> void:
	var w: float = r.size.x
	var h: float = r.size.y
	var c := r.position + Vector2(w * 0.5, h * 0.33)
	var head: float = h * 0.13
	var shirt: Color = Palette.LEVEL[level - 1]
	var skin: Color = Palette.SKIN[desk % Palette.SKIN.size()]
	var hair: Color = Palette.HAIR[(desk * 7 + level) % Palette.HAIR.size()]
	# Body (rounded shoulders) behind the desk.
	draw_circle(c + Vector2(0, head * 2.1), head * 1.25, shirt)
	draw_rect(Rect2(c + Vector2(-head * 1.25, head * 2.1), Vector2(head * 2.5, head * 1.2)), shirt)
	draw_colored_polygon(  # white collar
		PackedVector2Array(
			[
				c + Vector2(-head * 0.5, head * 0.95),
				c + Vector2(head * 0.5, head * 0.95),
				c + Vector2(0, head * 1.55)
			]
		),
		Color.WHITE
	)
	if level >= 4:  # tie
		draw_colored_polygon(
			PackedVector2Array(
				[
					c + Vector2(-head * 0.16, head * 1.2),
					c + Vector2(head * 0.16, head * 1.2),
					c + Vector2(head * 0.22, head * 2.3),
					c + Vector2(0, head * 2.6),
					c + Vector2(-head * 0.22, head * 2.3)
				]
			),
			Palette.RED if level < 10 else Palette.GOLD_DARK
		)
	# Head, hair, face.
	draw_circle(c, head, skin)
	draw_arc(c, head, PI * 1.05, PI * 1.95, 24, hair, head * 0.55)
	draw_circle(c + Vector2(-head * 0.38, head * 0.05), head * 0.12, Palette.INK)
	draw_circle(c + Vector2(head * 0.38, head * 0.05), head * 0.12, Palette.INK)
	draw_arc(c + Vector2(0, head * 0.25), head * 0.3, PI * 0.15, PI * 0.85, 12, Palette.INK, 3.0)
	draw_circle(c + Vector2(-head * 0.62, head * 0.35), head * 0.13, Color(1, 0.5, 0.6, 0.45))
	draw_circle(c + Vector2(head * 0.62, head * 0.35), head * 0.13, Color(1, 0.5, 0.6, 0.45))
	if level >= 7:  # glasses
		draw_arc(c + Vector2(-head * 0.38, head * 0.05), head * 0.26, 0, TAU, 16, Palette.INK, 3.0)
		draw_arc(c + Vector2(head * 0.38, head * 0.05), head * 0.26, 0, TAU, 16, Palette.INK, 3.0)
	if level == EconomyData.MAX_LEVEL:  # crown for the top level
		var top := c + Vector2(0, -head * 1.05)
		draw_colored_polygon(
			PackedVector2Array(
				[
					top + Vector2(-head * 0.6, 0),
					top + Vector2(-head * 0.6, -head * 0.6),
					top + Vector2(-head * 0.3, -head * 0.25),
					top + Vector2(0, -head * 0.7),
					top + Vector2(head * 0.3, -head * 0.25),
					top + Vector2(head * 0.6, -head * 0.6),
					top + Vector2(head * 0.6, 0)
				]
			),
			Palette.GOLD
		)


func _draw_desk(r: Rect2) -> void:
	var w: float = r.size.x
	var h: float = r.size.y
	var top := r.position + Vector2(w * 0.08, h * 0.62)
	draw_rect(Rect2(top, Vector2(w * 0.84, h * 0.07)), Palette.WOOD)
	draw_rect(Rect2(top + Vector2(0, h * 0.07), Vector2(w * 0.84, h * 0.03)), Palette.WOOD_DARK)
	if level == 0:
		return
	# Monitor on the right side of the desk, coffee mug on the left.
	var mon := Rect2(r.position + Vector2(w * 0.66, h * 0.44), Vector2(w * 0.24, h * 0.16))
	draw_rect(mon, Palette.INK)
	draw_rect(mon.grow(-4), Palette.SCREEN)
	draw_rect(
		Rect2(mon.position + Vector2(8, 8), Vector2(mon.size.x * 0.5, 4)), Palette.SCREEN_GLOW
	)
	draw_rect(
		Rect2(mon.position + Vector2(8, 18), Vector2(mon.size.x * 0.3, 4)), Palette.SCREEN_GLOW
	)
	if level >= 3:
		var mug := Rect2(r.position + Vector2(w * 0.12, h * 0.53), Vector2(w * 0.08, h * 0.09))
		draw_rect(mug, Palette.LEVEL[(level + 3) % Palette.LEVEL.size()])
		draw_arc(
			mug.position + Vector2(mug.size.x, mug.size.y * 0.5),
			mug.size.y * 0.3,
			-PI * 0.5,
			PI * 0.5,
			8,
			Palette.INK_SOFT,
			3.0
		)


func _draw_name_and_bar(r: Rect2, font: Font) -> void:
	var w: float = r.size.x
	var h: float = r.size.y
	var bar := Rect2(r.position + Vector2(w * 0.12, h * 0.75), Vector2(w * 0.76, 12))
	draw_style_box(GameTheme.card(Palette.CARD_EDGE, 6, false), bar)
	if fill > 0.0:
		var filled := Rect2(bar.position, Vector2(maxf(bar.size.x * fill, 12.0), bar.size.y))
		draw_style_box(GameTheme.card(Palette.LEVEL[level - 1].darkened(0.1), 6, false), filled)
	var name_text: String = "Lv%d %s" % [level, tr(EconomyData.LEVEL_KEYS[level - 1])]
	draw_string(
		font,
		r.position + Vector2(0, h * 0.95),
		name_text,
		HORIZONTAL_ALIGNMENT_CENTER,
		w,
		22,
		Palette.INK
	)


func _draw_star(center: Vector2, radius: float) -> void:
	var points := PackedVector2Array()
	for i: int in 10:
		var a: float = -PI / 2.0 + i * PI / 5.0
		var rr: float = radius if i % 2 == 0 else radius * 0.45
		points.append(center + Vector2(cos(a), sin(a)) * rr)
	draw_colored_polygon(points, Palette.GOLD)
	draw_polyline(points + PackedVector2Array([points[0]]), Palette.GOLD_DARK, 2.0)


func _draw_pill(r: Rect2, text: String, bg: Color, ink: Color, font: Font) -> void:
	var pill := Rect2(r.position + Vector2(r.size.x * 0.24, 4), Vector2(r.size.x * 0.74, 44))
	var box := GameTheme.card(bg, 22, true)
	box.border_color = bg.darkened(0.25)
	box.border_width_bottom = 5
	draw_style_box(box, pill)
	draw_circle(
		pill.position + Vector2(24, 21),
		13,
		Palette.GOLD_DARK if bg == BUBBLE_COLOR else bg.darkened(0.3)
	)
	draw_string(
		font, pill.position + Vector2(16, 30), "¥", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE
	)
	draw_string(
		font,
		pill.position + Vector2(36, 31),
		text,
		HORIZONTAL_ALIGNMENT_CENTER,
		pill.size.x - 40,
		24,
		ink
	)
