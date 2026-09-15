extends Node2D
const Models=preload("res://campaign/vehicles/vehicle_model_catalog.gd")
var model_id="bayou"
var facing=Vector2.LEFT
var door_open=0.
var prop: Array=[]
func _ready():texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
func _draw():
	var image=Models.sprite(model_id,facing,door_open)
	if image==null:return
	# Keep the source ground-centre anchor; use the same tactical scale as road traffic.
	draw_texture_rect(image,Rect2(Vector2(-320,-330)*.2*Models.TACTICAL_SCALE,Vector2(640,480)*.2*Models.TACTICAL_SCALE),false)
