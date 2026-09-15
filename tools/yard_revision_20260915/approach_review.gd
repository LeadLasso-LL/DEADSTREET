extends SceneTree
const Scenario=preload("res://gameplay/doble_ocho_scenario.gd")
const Setup=preload("res://gameplay/doble_ocho_setup.gd")
const C=preload("res://battle/geometry/doble_ocho_catalog.gd")
const Body=preload("res://battle/vehicles/battle_vehicle_body_service.gd")
var errors=[]
var checks=0
func _initialize():call_deferred("run")
func run():
 var scene=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(scene);await process_frame
 await scene.start_battle(false,Scenario.config());scene.set_process(false)
 var b=scene.battle
 if b==null:push_error(scene.note.text);quit(1);return
 for v in b.vehicles.values():
  var stop=8.4+int(v.get_meta("convoy_slot",0))*1.7
  var hits={}
  for frame in range(1,int(stop*120)+1):
   var clock=float(frame)/120.;var pose=Setup.arrival_pose(v,clock,stop)
   for row in C.props():
    checks+=1
    if Body.pose_intersects_rect(pose.position,pose.facing,Body.profile_for_vehicle(v),row[1]):hits[row[0]]=clock
  if not hits.is_empty():errors.append({"vehicle":v.vehicle_type_id,"hits":hits})
 var report={"checks":checks,"errors":errors}
 FileAccess.open("res://tools/yard_revision_20260915/approach_review.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
 print("APPROACH_REVIEW ",JSON.stringify(report));quit(0 if errors.is_empty() else 1)
