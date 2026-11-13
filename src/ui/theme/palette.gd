class_name Palette
extends RefCounted
## The game's colours in one place: warm background, dark purple ink, candy accents.

const INK := Color("3b2e5a")
const INK_SOFT := Color("7a6a96")
const CARD := Color("fffaf2")
const CARD_EDGE := Color("f0dcc4")
const BG_TOP := Color("ffe0b0")
const BG_BOTTOM := Color("ffa7bd")
const SHADOW := Color(0.35, 0.18, 0.25, 0.22)

const BLUE := Color("4d8dff")
const PURPLE := Color("9b6bff")
const ORANGE := Color("ff9a3d")
const GREEN := Color("35c27c")
const GOLD := Color("ffc93a")
const GOLD_DARK := Color("d99a12")
const RED := Color("ff5a6a")
const TEAL := Color("22c1c3")
const PINK := Color("ff7eb3")

## Shirt colour per coworker level (1..12).
const LEVEL: Array[Color] = [
	Color("8ecbff"),
	Color("6fdc8c"),
	Color("ffb15e"),
	Color("b88cff"),
	Color("ff7eb3"),
	Color("22c1c3"),
	Color("ff6b6b"),
	Color("5b7cfa"),
	Color("a3d65c"),
	Color("ff8f3d"),
	Color("8a5cf5"),
	Color("ffc93a"),
]
const SKIN: Array[Color] = [
	Color("ffd9b8"), Color("f3c29b"), Color("d99b74"), Color("ffe6cc"), Color("b97a57")
]
const HAIR: Array[Color] = [
	Color("3b2a20"), Color("6b4226"), Color("23202e"), Color("b5651d"), Color("e2b54c")
]
const WOOD := Color("c98b52")
const WOOD_DARK := Color("9c6536")
const SCREEN := Color("2d3561")
const SCREEN_GLOW := Color("7fd4ff")
