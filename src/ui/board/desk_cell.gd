class_name DeskCell
extends Control
## One desk on the office board: draws the coworker and its "+¥" bubble,
## claims the bubble on tap, and supports drag and drop between desks.

signal tapped(desk: int)
signal dropped(from: int, to: int)

const LEVEL_COLORS: Array[Color] = [
	Color(0.6, 0.78, 0.95),
	Color(0.55, 0.86, 0.6),
	Color(0.95, 0.68, 0.45),
	Color(0.78, 0.6, 0.95),
	Color(0.96, 0.84, 0.36),
	Color(0.45, 0.85, 0.85),
	Color(0.95, 0.55, 0.65),
	Color(0.65, 0.7, 0.98),
	Color(0.85, 0.9, 0.45),
	Color(0.98, 0.6, 0.35),
	Color(0.75, 0.75, 0.8),
	Color(1.0, 0.82, 0.2),
]
const TILE_COLOR := Color(0.24, 0.25, 0.3)
const DESK_COLOR := Color(0.47, 0.35, 0.24)
const BUBBLE_COLOR := Color(0.98, 0.84, 0.3)
const GLOW_COLOR := Color(1.0, 1.0, 1.0, 0.85)

var desk: int = 0
var level: int = 0
var bubble_text: String = ""
var can_merge: bool = false
var goal_level: bool = false


func _init(index: int) -> void:
	desk = index
	custom_minimum_size = Vector2(230, 210)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_PASS


func show_state(new_level: int, new_bubble: String, mergeable: bool, at_goal: bool) -> void:
	if (
		new_level == level
		and new_bubble == bubble_text
		and mergeable == can_merge
		and at_goal == goal_level
	):
		return
	level = new_level
	bubble_text = new_bubble
	can_merge = mergeable
	goal_level = at_goal
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
	preview.add_theme_font_size_override("font_size", 48)
	preview.add_theme_color_override("font_color", LEVEL_COLORS[level - 1])
	var holder := Control.new()
	holder.add_child(preview)
	preview.position = Vector2(-40, -90)  # above the finger so it stays visible
	set_drag_preview(holder)
	return {"from_desk": desk}


func _can_drop_data(_at: Vector2, data: Variant) -> bool:
	return data is Dictionary and (data as Dictionary).has("from_desk")


func _drop_data(_at: Vector2, data: Variant) -> void:
	var from: int = int((data as Dictionary)["from_desk"])
	if from != desk:
		dropped.emit(from, desk)


func _draw() -> void:
	var r := Rect2(Vector2(4, 4), size - Vector2(8, 8))
	draw_rect(r, TILE_COLOR)
	if can_merge:
		draw_rect(r, GLOW_COLOR, false, 4.0)
	var w: float = r.size.x
	var h: float = r.size.y
	draw_rect(
		Rect2(r.position + Vector2(w * 0.12, h * 0.68), Vector2(w * 0.76, h * 0.08)), DESK_COLOR
	)
	var font: Font = get_theme_default_font()
	if level > 0:
		var color: Color = LEVEL_COLORS[level - 1]
		var center := r.position + Vector2(w / 2.0, h * 0.34)
		draw_circle(center, h * 0.14, color)
		draw_rect(Rect2(center + Vector2(-w * 0.2, h * 0.1), Vector2(w * 0.4, h * 0.2)), color)
		var name_text: String = "Lv%d %s" % [level, tr(EconomyData.LEVEL_KEYS[level - 1])]
		draw_string(
			font,
			r.position + Vector2(0, h * 0.94),
			name_text,
			HORIZONTAL_ALIGNMENT_CENTER,
			w,
			22,
			Color.WHITE
		)
		if goal_level:
			draw_circle(r.position + Vector2(22, 22), 12, BUBBLE_COLOR)  # counts toward the goal
	if bubble_text != "":
		var pill := Rect2(r.position + Vector2(w * 0.38, 6), Vector2(w * 0.6, 40))
		draw_rect(pill, BUBBLE_COLOR)
		draw_string(
			font,
			pill.position + Vector2(0, 30),
			bubble_text,
			HORIZONTAL_ALIGNMENT_CENTER,
			pill.size.x,
			24,
			Color(0.15, 0.12, 0.05)
		)
