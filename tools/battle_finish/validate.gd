extends SceneTree
const Scenario=preload("res://tools/battle_showcase/scenario.gd")
const Sim=preload("res://battle/runtime/battle_runtime_service.gd")
const Movement=preload("res://battle/runtime/battle_movement_service.gd")
const Nav=preload("res://battle/navigation/battle_navigation_service.gd")
var checks=0
var problems=[]
var reports=[]
var visual=false
func _initialize():
 visual="--visual" in OS.get_cmdline_user_args()
 DirAccess.make_dir_recursive_absolute("res://tools/battle_finish/results")
 call_deferred("run")
func verify(ok,message):
 checks+=1
 if not ok:problems.append(message);push_error(message)
func capture(name):
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://tools/battle_finish/results/"+name+".png")
func run():
 for fixture in ["enter_objective","check_comrades","regroup"]:
  var runtime=load("res://gameplay/gameplay_runtime.tscn").instantiate();root.add_child(runtime);await process_frame
  var setup=Scenario.setup(runtime,2011,false,"medium")
  verify(setup.has("battle"),"fixture deployment "+fixture)
  if not setup.has("battle"):quit(1);return
  var b=setup.battle;var view=runtime.get_node("TacticalBattleView");var d=view.battle_presentation
  d.set_process(false);d.sound.set_process(false);view.set_process(false)
  view._sync_actor_presenter();d._process(0.)
  if fixture=="enter_objective":test_movement(b)
  var win=b.attacker_side_id if fixture=="enter_objective" else b.defender_side_id
  var index=0;var before={}
  for p in b.participants.values():
   p.is_alive=p.side_id==win;p.vitality=1.3 if p.is_alive else 0.;p.is_wounded=false
   p.clear_navigation_path();p.set_movement_intent(Vector2.ZERO)
   if p.side_id==win:
    if fixture=="check_comrades" and index==0:p.is_alive=false;p.vitality=0.
    elif index==1:p.is_wounded=true;p.vitality=.6
    index+=1
   before[p.participant_id]={"position":p.battle_position,"health":p.vitality,"alive":p.is_alive,"wounded":p.is_wounded}
  Sim.advance(b,1./30.);view._sync_actor_presenter();d._process(0.)
  verify(b.battle_phase=="resolved","fixture resolves "+fixture)
  verify(b.get_winning_side_id()==win,"correct winner "+fixture)
  verify(d.outro.kind==fixture,"outro branch "+fixture)
  verify(d.outro.errors.is_empty(),"legal ending routes "+fixture+str(d.outro.errors))
  verify(not d.results_visible() and not d.result_root.visible,"result hidden at resolution")
  for id in d.outro.routes:
   var route=d.outro.routes[id];var p=b.get_participant(id)
   var expected="enter" if fixture=="enter_objective" or (fixture=="regroup" and p.is_wounded) else ("kneel" if fixture=="check_comrades" else "guard")
   verify(route.action==expected,"correct survivor action "+id)
   for n in range(1,route.points.size()):verify(Nav.is_reachable(b,route.points[n-1],route.points[n]),"walkable segment "+id)
  if visual:
   view._dusk_zoom=1.55;view._dusk_pan=Vector2(0,-25);view._frame_camera()
   await capture(fixture+"_start")
  # Review every presentation step, then inspect the settled poses before results.
  while d.end_clock<d.outro.duration-.1:
   view._sync_actor_presenter();d._process(minf(.05,d.outro.duration-.1-d.end_clock))
   if d.end_clock>=d.outro.duration-.101:break
  verify(not d.results_visible(),"whole ending remains unobscured "+fixture)
  for id in d.outro.routes:
   var r=d.outro.routes[id];var node=view.actor_presenter._unit_nodes[id];var body=node.get_node("body")
   if r.action=="enter":verify(not node.visible,"entrant crosses doorway and disappears "+id)
   elif r.action=="kneel":verify(node.visible and str(body.animation).begins_with("check_comrade"),"kneeling beside comrade "+id)
   else:verify(node.visible and str(body.animation).begins_with("aim") and r.facing.y>0.,"healthy survivor guards outward "+id)
  if visual:await capture(fixture+"_settled")
  view._sync_actor_presenter();d._process(1.5)
  verify(d.results_visible() and d.result_root.visible,"results appear afterward "+fixture)
  verify(not d.continue_button.disabled,"Continue available after result fade")
  for p in b.participants.values():
   var old=before[p.participant_id]
   verify(p.battle_position==old.position and p.vitality==old.health and p.is_alive==old.alive and p.is_wounded==old.wounded,"outro preserves canonical state "+p.participant_id)
  if visual:await capture(fixture+"_results")
  reports.append({"kind":fixture,"duration":d.outro.duration,"routes":d.outro.routes,"errors":d.outro.errors})
  runtime.queue_free();await process_frame;await process_frame
 FileAccess.open("res://tools/battle_finish/results/checks.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"problems":problems,"outcomes":reports},"  "))
 print("FINISH_VALIDATION checks=",checks," problems=",problems)
 quit(0 if problems.is_empty() else 1)
func test_movement(b):
 var p=b.participants.values()[0]
 var old={"position":p.battle_position,"speed":p.movement_speed,"occupied":p.occupied_cover_slot_id,"reserved":p.reserved_cover_slot_id}
 p.occupied_cover_slot_id="";p.reserved_cover_slot_id="";p.clear_player_tactical_intent()
 var slot=b.battlefield_geometry.get_cover_slot(old.occupied)
 verify(slot!=null,"cover speed fixture has destination")
 if slot==null:return
 p.battle_position=Vector2(40,30);p.set_movement_speed(4.)
 var points: Array[Vector2]=[Vector2(42,30),slot.position]
 p.set_navigation_path(slot.position,points);p.set_movement_intent(Vector2.RIGHT);p.set_movement_target_position(Vector2(42,30))
 verify(Movement.cover_hustle_multiplier(b,p)==1.,"ordinary move retains speed")
 Movement._advance_participant(b,p,.1);var ordinary=p.battle_position.x-40.
 p.battle_position=Vector2(40,30);p.reserved_cover_slot_id=slot.cover_slot_id
 verify(is_equal_approx(Movement.cover_hustle_multiplier(b,p),1.18),"reserved cover grants eighteen percent")
 Movement._advance_participant(b,p,.1);var hustle=p.battle_position.x-40.
 verify(is_equal_approx(hustle/ordinary,1.18),"measured movement is eighteen percent faster")
 verify(p.movement_speed==4.,"base movement speed unchanged")
 p.battle_position=Vector2(40,30);p.is_wounded=true;p.movement_speed=2.
 Movement._advance_participant(b,p,.1)
 verify(is_equal_approx(p.battle_position.x-40.,.236),"wounded base penalty preserved during cover run")
 p.occupied_cover_slot_id=slot.cover_slot_id
 verify(Movement.cover_hustle_multiplier(b,p)==1.,"no boost while occupying cover")
 p.occupied_cover_slot_id="";p.navigation_destination=Vector2(42,30)
 verify(Movement.cover_hustle_multiplier(b,p)==1.,"unrelated destination cannot inherit stale cover boost")
 p.navigation_destination=slot.position;p.is_alive=false
 verify(Movement.cover_hustle_multiplier(b,p)==1.,"dead participant never hustles")
 p.is_alive=true;p.clear_navigation_path();p.set_movement_intent(Vector2.ZERO);p.is_wounded=false
 p.battle_position=old.position;p.movement_speed=old.speed;p.occupied_cover_slot_id=old.occupied;p.reserved_cover_slot_id=old.reserved
