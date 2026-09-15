extends SceneTree
const Scenario=preload("res://tools/yard_finish_20260915/capture_config.gd")
const C=preload("res://battle/geometry/doble_ocho_catalog.gd")
const Setup=preload("res://gameplay/doble_ocho_setup.gd")
const Nav=preload("res://battle/navigation/battle_navigation_service.gd")
const Body=preload("res://battle/vehicles/battle_vehicle_body_service.gd")
const Exit=preload("res://battle/vehicles/battle_vehicle_exit_service.gd")
const Fixture=preload("res://gameplay/arsenal_battle_fixture.gd")
var errors=[]
var checks=0
var out="res://tools/yard_finish_20260915/"
func _initialize():call_deferred("run")
func check(ok: bool,message: String):
 checks+=1
 if not ok:errors.append(message);push_error(message)
func settle(frames=12):
 for i in range(frames):await process_frame
func run():
 if "--bake" in OS.get_cmdline_user_args():
  var vp=SubViewport.new();vp.size=Vector2i(4096,2304);vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(vp)
  var art=preload("res://gameplay/doble_ocho_art.gd").new();art.bake_mode=true;vp.add_child(art)
  vp.canvas_transform=Transform2D(0,Vector2(1536,960))
  await settle(4);await RenderingServer.frame_post_draw
  DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://assets/art/doble_ocho"))
  var im=vp.get_texture().get_image();var result=im.save_png("res://assets/art/doble_ocho/ground.png")
  print("YARD_BAKE ",result," ",im.get_size());quit(result);return
 root.size=Vector2i(1440,900);DisplayServer.window_set_size(root.size)
 var scene=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(scene);await settle(2)
 scene.seed_value=91517
 await scene.start_battle(false,Scenario.config())
 scene.set_process(false)
 if scene.battle==null:push_error(scene.note.text);quit(1);return
 var b=scene.battle;var view=scene.runtime.get_node("TacticalBattleView")
 check(b.participants.size()==14,"fourteen actual participants")
 check(b.battlefield_geometry.is_valid(),"valid native geometry")
 var routes=[]
 for pair in [[Vector2(24,36.8),Vector2(49,25)],[Vector2(59.8,22),Vector2(65,10)],[Vector2(94,53),Vector2(94,36)],[Vector2(49,38),Vector2(88,37)],[Vector2(75,24),C.ENTRANCE]]:
  var path=Nav.find_path(b,pair[0],pair[1]);check(path.success,"route "+str(pair));routes.append({"from":str(pair[0]),"to":str(pair[1]),"success":path.success})
 for slot in b.battlefield_geometry.cover_slots.values():check(Nav.is_reachable(b,C.ENTRANCE,slot.position),"reachable "+slot.cover_slot_id)
 var manifest=[];var positions=[]
 for v in b.vehicles.values():
  var occupants=[]
  for p in b.participants.values():
   if p.transport_vehicle_id==v.battle_vehicle_id:occupants.append(p.participant_id)
  manifest.append({"vehicle":v.vehicle_type_id,"occupants":occupants,"count":occupants.size(),"position":str(v.battle_position)})
 for p in b.participants.values():
  check(p.has_battle_position and p.has_occupied_cover_slot(),"opening cover "+p.participant_id)
  positions.append({"id":p.participant_id,"position":str(p.battle_position),"slot":p.occupied_cover_slot_id,"flanker":p.get_meta("doble_ocho_flanker",false)})
  for q in b.participants.values():
   if p.participant_id<q.participant_id:check(p.battle_position.distance_to(q.battle_position)>=2.399,"body spacing "+p.participant_id+" / "+q.participant_id)
  if p.side_id==b.attacker_side_id:
   var route=Exit.route(b,b.get_vehicle(p.transport_vehicle_id),p.battle_position,bool(p.get_meta("transport_bed",false)))
   check(not route.is_empty() and route.path.success,"real transport exit "+p.participant_id)
 view.battle_presentation.skip_to_ready()
 check(Fixture.begin_review(scene.runtime,b).success,"normal battle starts")
 b.tactical_paused=true;await settle(24);await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(out+"first_pass.png")
 var report={"checks":checks,"errors":errors,"routes":routes,"manifest":manifest,"positions":positions}
 FileAccess.open(out+"first_pass.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"));print("YARD_REVIEW ",JSON.stringify(report))
 quit(0 if errors.is_empty() else 1)

