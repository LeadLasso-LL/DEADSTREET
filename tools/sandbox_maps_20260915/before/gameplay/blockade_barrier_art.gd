extends Node2D
## Steel screen and kickstand, using the street's pixel scale and ground anchor.
func _ready():texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
func _draw():
 draw_colored_polygon(PackedVector2Array([Vector2(-4,5),Vector2(5,3),Vector2(9,8),Vector2(-1,11)]),Color("#111a1ddd"))
 draw_line(Vector2(-5,7),Vector2(6,4),Color("#707c7b"),2.)
 draw_line(Vector2(-1,10),Vector2(7,7),Color("#929e99"),2.)
 var face=PackedVector2Array([Vector2(-4,-12),Vector2(2,-14),Vector2(4,5),Vector2(-2,7)])
 draw_colored_polygon(face,Color("#425158"))
 draw_polyline(PackedVector2Array([face[0],face[1],face[2],face[3],face[0]]),Color("#abb8b0"),1.)
 draw_line(Vector2(-3,-10),Vector2(3,3),Color("#899791"),1.)
 draw_line(Vector2(1,-12),Vector2(-1,5),Color("#28383d"),1.)
 draw_line(Vector2(-3,-9),Vector2(2,-11),Color("#d3b671"),2.)
 draw_line(Vector2(1,-8),Vector2(6,6),Color("#768780"),1.)
 draw_rect(Rect2(-2,-5,1,2),Color("#b7bfb0"))
