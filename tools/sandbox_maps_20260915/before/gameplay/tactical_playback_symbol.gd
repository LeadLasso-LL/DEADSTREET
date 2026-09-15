extends Control
# Transport symbols are geometry, independent of font glyph coverage.
var mode: int = 0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _draw() -> void:
	var ink = Color("#e5e1cf")
	if mode == 0:
		draw_rect(Rect2(18, 8, 4, 13), ink)
		draw_rect(Rect2(27, 8, 4, 13), ink)
	elif mode == 1:
		for x in [12, 25]:
			draw_colored_polygon(PackedVector2Array([Vector2(x,14.5),Vector2(x+10,8),Vector2(x+10,21)]), ink)
	elif mode == 2:
		draw_colored_polygon(PackedVector2Array([Vector2(20,8),Vector2(31,14.5),Vector2(20,21)]), ink)
	else:
		for x in [13, 26]:
			draw_colored_polygon(PackedVector2Array([Vector2(x,8),Vector2(x+10,14.5),Vector2(x,21)]), ink)
