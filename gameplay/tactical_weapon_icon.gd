extends Control
# Approved monochrome class silhouettes, drawn at native HUD resolution.
var weapon_type: String = "rifle":
	set(value):
		if weapon_type != value:
			weapon_type = value
			queue_redraw()
var ink: Color = Color("#e5e1cf")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

func polygon(points: Array) -> void:
	var packed = PackedVector2Array()
	for p in points:
		packed.append(Vector2(p[0], p[1]))
	draw_colored_polygon(packed, ink)

func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, size / Vector2(40, 36))
	match weapon_type:
		"pistol":
			polygon([[3,9],[35,9],[35,17],[19,17],[17,29],[7,29],[11,17],[3,17]])
			draw_rect(Rect2(21,18,8,6),ink,false,2)
		"smg":
			for i in range(3):
				var x = 6.0 + i * 12.0
				var y = 13.0 - i * 4.0
				draw_rect(Rect2(x,y+5,6,14),ink)
				polygon([[x,y+5],[x+3,y],[x+6,y+5]])
		"rifle":
			polygon([[2,15],[11,16],[13,12],[27,12],[28,9],[30,9],[30,12],[39,12],[39,16],[27,16],[25,20],[18,20],[15,27],[11,26],[12,20],[2,22]])
			polygon([[21,19],[27,19],[27,24],[31,29],[26,32],[22,27]])
		"shotgun":
			polygon([[2,16],[13,13],[13,23],[2,20]])
			for p in [Vector2(20,18),Vector2(27,12),Vector2(27,24),Vector2(35,6),Vector2(35,18),Vector2(35,30)]:
				draw_circle(p,2.7,ink)
		"sniper":
			draw_arc(Vector2(20,18),12,0,TAU,40,ink,2.5,true)
			draw_line(Vector2(20,0),Vector2(20,12),ink,2.5,true)
			draw_line(Vector2(20,24),Vector2(20,36),ink,2.5,true)
			draw_line(Vector2(2,18),Vector2(14,18),ink,2.5,true)
			draw_line(Vector2(26,18),Vector2(38,18),ink,2.5,true)
			draw_circle(Vector2(20,18),2,ink)
