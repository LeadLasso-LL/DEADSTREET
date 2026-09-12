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
	# One ground-centre anchor at 40 source pixels/unit, rendered at 8 world pixels/unit.
	draw_texture_rect(image,Rect2(Vector2(-320,-330)*.2,Vector2(640,480)*.2),false)
