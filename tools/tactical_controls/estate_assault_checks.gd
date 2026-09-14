extends SceneTree
const Fixture=preload("res://gameplay/arsenal_battle_fixture.gd")
const Setup=preload("res://gameplay/estate_battle_setup.gd")
const Director=preload("res://tools/tactical_controls/estate_director.gd")
const Body=preload("res://battle/vehicles/battle_vehicle_body_service.gd")
const Vehicle=preload("res://battle/core/battle_vehicle.gd")
const Exit=preload("res://battle/vehicles/battle_vehicle_exit_service.gd")
const Nav=preload("res://battle/navigation/battle_navigation_service.gd")
class View extends Node2D:
 var _dusk_zoom=1.
 var _dusk_pan=Vector2.ZERO
 var deployment_controller
 func _frame_camera():pass
 func _is_dusk_street():return false
var errors=[]
var checks=0
func _initialize():call_deferred("run")
func check(ok,label):
 checks+=1
 if not ok and label not in errors:errors.append(label);printerr("ASSAULT_FAIL ",label)
func run():
 var runtime=load("res://gameplay/gameplay_runtime.gd").new()
 runtime.game_state=load("res://gameplay/starter_world_service.gd").create()
 runtime.game_flow_controller=load("res://core/game_flow_controller.gd").create(runtime.game_state).controller
 var view=View.new();view.name="TacticalBattleView";runtime.add_child(view)
 var f=Fixture.setup(runtime,Director.config(),false,Director.SEED,true)
 check(f.has("battle"),"fixture setup")
 if not f.has("battle"):print(f);quit(1);return
 var b=f.battle;var covered=0;var fence=0;var vehicle_cover=0;var flankers=[];var starts=[]
 for p in b.participants.values():
  if p.side_id!=b.attacker_side_id:continue
  check(not p.occupied_cover_slot_id.is_empty(),"attacker opening cover "+p.participant_id)
  if not p.occupied_cover_slot_id.is_empty():
   covered+=1
   if "fence" in p.occupied_cover_slot_id or "service_gate" in p.occupied_cover_slot_id:fence+=1
   else:vehicle_cover+=1
  var route=Exit.route(b,b.get_vehicle(p.transport_vehicle_id),p.battle_position,bool(p.get_meta("transport_bed",false)))
  check(not route.is_empty() and route.path.success,"dismount route "+p.participant_id)
  if bool(p.get_meta("estate_flanker",false)):flankers.append(p.participant_id)
  starts.append({"id":p.participant_id,"position":str(p.battle_position),"cover":p.occupied_cover_slot_id,"flanker":bool(p.get_meta("estate_flanker",false))})
 check(covered==16,"all sixteen start in occupied cover")
 check(fence>0 and vehicle_cover>0,"both fence and vehicles used")
 check(flankers.size()==4,"all four Vigil passengers flank")
 var manifests=[];var passengers=[]
 for v in b.vehicles.values():
  if v.side_id!=b.attacker_side_id:continue
  var assigned=[];var seats=[]
  for unit in b.participants.values():
   if unit.transport_vehicle_id!=v.battle_vehicle_id:continue
   assigned.append(unit.participant_id);seats.append(int(unit.get_meta("transport_seat",-1)))
   check(unit.participant_id not in passengers,"passenger assigned only once "+unit.participant_id);passengers.append(unit.participant_id)
   check(bool(unit.get_meta("estate_flanker",false))==(v.vehicle_type_id=="vigil"),"whole Vigil fireteam flanks "+unit.participant_id)
  var expected={"aegis":7,"watchdog":5,"vigil":4}[v.vehicle_type_id]
  assigned.sort();seats.sort();var declared=v.get_meta("convoy_occupants",[]);declared.sort()
  check(assigned.size()==expected,"vehicle passenger count "+v.vehicle_type_id)
  check(assigned==declared,"arrival manifest matches participants "+v.vehicle_type_id)
  check(seats==range(expected),"unique consecutive seats "+v.vehicle_type_id)
  manifests.append({"vehicle":v.vehicle_type_id,"count":assigned.size(),"seats":seats,"participants":assigned})
 check(passengers.size()==16,"all sixteen passengers accounted for")
 var dir=Director.new();dir.setup(b,null)
 check(dir.flank_paths.size()==4,"four planned flank paths")
 for path in dir.flank_paths:check(path.valid,"flank path "+path.id)
 for crossing in [[Vector2(73,110.5),Vector2(90,99.5)],[Vector2(90,99.5),Vector2(76,97.5)]]:
  var route=Nav.find_path(b,crossing[0],crossing[1]);check(route!=null and route.success,"garage gate route "+str(crossing))
 var vehicles=[];var final=[]
 for v in b.vehicles.values():
  if v.side_id==b.attacker_side_id:
   vehicles.append(v);final.append({"id":v.battle_vehicle_id,"position":str(v.battle_position),"facing":str(v.facing_direction)})
   check(absf(v.facing_direction.y)>.1,"angled assault parking "+v.battle_vehicle_id)
 for frame in range(18,106):
  var clock=frame*.1;var poses=[]
  for v in vehicles:
   var pose=Setup.arrival_pose(v,clock,8.+float(v.get_meta("convoy_slot",0))*1.1)
   var proxy=Vehicle.new(v.battle_vehicle_id,"","","",v.vehicle_type_id);proxy.battle_position=pose.position;proxy.has_battle_position=true;proxy.set_facing_direction(pose.facing);poses.append(proxy)
   var profile=Body.profile_for_vehicle(v)
   for id in b.battlefield_geometry.get_sorted_obstacle_ids():
    if id in ["boundary_north","boundary_south"]:continue
    if id.begins_with(v.battle_vehicle_id+'__door'):continue # Hinged parts of this vehicle, not scenery.
    var obstacle=b.battlefield_geometry.get_obstacle(id)
    if obstacle.blocks_movement:check(not Body.pose_intersects_rect(pose.position,pose.facing,profile,obstacle.bounds),"arrival scenery collision "+v.battle_vehicle_id+" "+id)
  for i in range(poses.size()):
   for j in range(i+1,poses.size()):check(not Body.bodies_intersect(poses[i],poses[j]),"arrival vehicle collision %d/%d"%[i,j])
 var residents=[]
 for v in b.vehicles.values():
  if v.side_id!=b.defender_side_id:continue
  residents.append({"vehicle":v.vehicle_type_id,"position":str(v.battle_position)})
  if v.vehicle_type_id=="workhorse":check(v.battle_position.is_equal_approx(Vector2(116,74)),"white Workhorse relocated onto paved circle")
 var report={"resident_vehicles":residents,"passenger_manifests":manifests,"checks":checks,"errors":errors,"covered_attackers":covered,"fence_cover":fence,"vehicle_cover":vehicle_cover,"flankers":flankers,"flank_paths":dir.flank_paths,"vehicle_poses":final,"opening_units":starts}
 FileAccess.open("C:/Users/brand/OneDrive/Documents/dead-street/tools/tactical_controls/hud_fixed_20260914/assault.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
 print("ESTATE_ASSAULT ",JSON.stringify(report));runtime.free();quit(0 if errors.is_empty() else 1)
