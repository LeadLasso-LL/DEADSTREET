extends "res://tools/freight_clarity_20260915/showcase.gd"
func _initialize():
 var monitor=Monitor.new();monitor.owner_script=self;root.add_child.call_deferred(monitor)
 super._initialize()
func shot(name_value: String):
 flags[name_value]=true
 await process_frame
class Monitor extends Node:
 var owner_script
 var rows=[]
 var active_frames=0
 func _ready():process_priority=2000
 func _process(_delta):
  var s=owner_script
  if not is_instance_valid(s.view) or not is_instance_valid(s.presentation):return
  if s.presentation.stage!="active":return
  active_frames+=1
  var camera=s.view._camera
  var units=[]
  for id in s.view.actor_presenter._unit_nodes:
   var node=s.view.actor_presenter._unit_nodes[id];var body=node.get_node("body")
   units.append({"id":id,"world":[node.global_position.x,node.global_position.y],"body":[body.position.x,body.position.y],"clip":body.animation,"frame":body.frame})
  rows.append({"camera":[camera.position.x,camera.position.y,camera.zoom.x],"units":units})
  if active_frames>=180:
   var path="res://tools/freight_stability_20260915/"+("after" if "--after" in OS.get_cmdline_user_args() else "before")+"_motion.json"
   FileAccess.open(path,FileAccess.WRITE).store_string(JSON.stringify(rows))
   print("MOTION_CAPTURED ",active_frames);get_tree().quit()
