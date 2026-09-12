extends Control
const MIDNIGHT_BLUE := Color("#162b50")
const SILVER := Color("#b9c0cb")
var tier: int = 0:
 set(value):
  tier=clampi(value,0,3)
  queue_redraw()
func _ready() -> void:
 mouse_filter=Control.MOUSE_FILTER_IGNORE
 custom_minimum_size=Vector2(32,9)
func _draw() -> void:
 for i in range(tier):
  var center:=Vector2(5+i*11,4.5)
  draw_circle(center,3.8,SILVER)
  draw_circle(center,2.5,MIDNIGHT_BLUE)
