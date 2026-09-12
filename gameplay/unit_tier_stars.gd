extends Control

const GOLD := Color("#c6a75d")
var tier: int = 1:
	set(value):
		tier = clampi(value, 0, 3)
		queue_redraw()

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(32, 12)

func _draw() -> void:
	for i in range(tier):
		var points := PackedVector2Array()
		for point in range(10):
			var angle: float = -PI/2.0+point*PI/5.0
			var radius: float = 4.6 if point%2 == 0 else 2.0
			points.append(Vector2(5+i*11, 6)+Vector2(cos(angle), sin(angle))*radius)
		draw_colored_polygon(points, GOLD)
