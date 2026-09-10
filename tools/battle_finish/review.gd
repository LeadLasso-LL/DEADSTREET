extends SceneTree
const Scenario=preload("res://tools/battle_showcase/scenario.gd")
const RuntimeService=preload("res://battle/runtime/battle_runtime_service.gd")
var runtime: Node
var battle
var active=false
var time=0.
var elapsed_after=0.
var seed_value=2011
var out="res://tools/battle_finish/results"
var seen={}
var events=[]
var transitions=[]
var last_states={}
var distances={}
var positions={}
var cover_ticks=0
var captured={}
var hold=false
var fast=false
var sample_seeds: Array[int]=[]
var sample_results=[]
var recording=false
var prelude=0.
var battle_started=false
var title: Label
var subtitle: Label
func _initialize():
 var args=OS.get_cmdline_user_args()
 for arg in args:
  if arg.begins_with("--seed="):seed_value=int(arg.split("=")[1])
  if arg=="--hold":hold=true
  if arg=="--fast":fast=true
  if arg=="--recording":recording=true
  if arg=="--sample":fast=true;sample_seeds.assign([2002,2003,2005])
 DirAccess.make_dir_recursive_absolute(out)
 call_deferred("start")
func start():
 if fast and not sample_seeds.is_empty():seed_value=sample_seeds.pop_front()
 runtime=load("res://gameplay/gameplay_runtime.tscn").instantiate();root.add_child(runtime)
 await process_frame
 var result=Scenario.setup(runtime,seed_value,not fast,"medium")
 if not result.has("battle"):push_error("SHOWCASE_FAILED "+str(result));quit(1);return
 battle=result.battle

 for p in battle.participants.values():positions[p.participant_id]=p.battle_position;distances[p.participant_id]=0.
 active=true
 print("SHOWCASE_READY seed=",seed_value," roster=",result.roster)
func step(dt: float):
 var previous=time;time+=dt
 if battle.battle_phase=="active":
  # Player commits to Push after the covered opening; defending AI is unscripted.
  if previous<4. and time>=4.:
   for p in battle.participants.values():
    if p.side_id==battle.attacker_side_id:p.clear_player_tactical_intent()
   Scenario.command(battle,battle.attacker_side_id,"focus_left")
  RuntimeService.advance(battle,dt)
 else:
  elapsed_after+=dt
  # The simulation clock stops on resolution; let the last transient markers clear.
  if elapsed_after>.75:battle.combat_feedback_events.clear()
 for event in battle.combat_feedback_events:
  if seen.has(event.sequence_id):continue
  seen[event.sequence_id]=true
  var p=battle.get_participant(event.source_participant_id)
  events.append({"time":time,"source":event.source_participant_id,"weapon":p.weapon_type if p!=null else "","x":p.battle_position.x if p!=null else 32.})
 for p in battle.participants.values():
  var id=p.participant_id
  distances[id]=float(distances.get(id,0.))+p.battle_position.distance_to(positions.get(id,p.battle_position));positions[id]=p.battle_position
  if p.has_occupied_cover_slot():cover_ticks+=1
  var state="dead" if not p.is_alive else ("wounded" if p.is_wounded else "active")
  if last_states.get(id,"active")!=state:transitions.append({"time":time,"unit":id,"side":p.side_id,"state":state})
  last_states[id]=state
func _process(_delta: float) -> bool:
 if not active:return false
 if not battle_started:
  if fast:battle_started=true
  else:
   var director=runtime.get_node("TacticalBattleView").battle_presentation
   for moment in [1.,3.5,5.7,8.5]:
    var key="intro_"+str(moment)
    if director.clock>=moment and not captured.has(key):captured[key]=true;capture(key)
   if director.stage=="ready" and director.ready_clock>.7:
    var began=runtime.begin_current_battle();battle_started=began!=null and began.success
   return false
 for i in range(12 if fast else 1):
  step(1./30.)
  if not fast and elapsed_after>3. and not captured.has("outro"):captured["outro"]=true;capture("outro")
  if not fast and elapsed_after>=runtime.get_node("TacticalBattleView").battle_presentation.outro.duration+4. and not captured.has("results"):captured["results"]=true;capture("results")
  if (time>=180. and battle.battle_phase=="active") or elapsed_after>=(2. if fast else runtime.get_node("TacticalBattleView").battle_presentation.outro.duration+8.):
   if hold:
    if not captured.has("held"):captured["held"]=true;save_report();capture("final")
    active=false;root.title="Dead Street - 4v4 showcase review (paused)";return false
   finish();return false
 if not fast:
  for second in [1,5,10,20,30,40]:
   if time>=second and not captured.has(second):captured[second]=true;capture(str(second))
 return false
func capture(name: String):
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(out+"/seed_%d_%s.png"%[seed_value,name])
func save_report() -> Dictionary:
 var alive={};var deaths={};var variants={};var max_distance=0.
 for p in battle.participants.values():
  alive[p.side_id]=int(alive.get(p.side_id,0))+(1 if p.is_alive else 0)
  deaths[p.side_id]=int(deaths.get(p.side_id,0))+(0 if p.is_alive else 1)
  variants[p.participant_id]="backward" if absi(p.participant_id.hash())%2==0 else "original"
  max_distance=maxf(max_distance,float(distances[p.participant_id]))
 var report={"outro_kind":runtime.get_node("TacticalBattleView").battle_presentation.outro.kind,"outro_duration":runtime.get_node("TacticalBattleView").battle_presentation.outro.duration,"outro_errors":runtime.get_node("TacticalBattleView").battle_presentation.outro.errors,"ai_decisions":battle.strength_events,"seed":seed_value,"duration":battle.elapsed_time_seconds,"phase":battle.battle_phase,"winner":battle.get_winning_side_id(),"alive":alive,"deaths":deaths,"shots":seen.size(),"transitions":transitions,"distance":distances,"cover_ticks":cover_ticks,"death_variants":variants,"events":events,"audio_shots":runtime.get_node("TacticalBattleView").battle_presentation.sound.shots_played,"results":runtime.get_node("TacticalBattleView").battle_presentation.result_snapshot}
 FileAccess.open(out+"/seed_%d.json"%seed_value,FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
 print("SHOWCASE_RESULT ",seed_value," duration=",report.duration," alive=",alive," shots=",seen.size()," max_travel=",max_distance)
 return report
func finish():
 active=false
 var report=save_report()
 if fast:
  sample_results.append({"ai_decisions":battle.strength_events,"seed":seed_value,"duration":report.duration,"phase":report.phase,"alive":report.alive,"shots":report.shots,"wound_death_events":transitions.size(),"cover_ticks":cover_ticks})
  if not sample_seeds.is_empty():
   runtime.queue_free();battle_started=false;time=0.;elapsed_after=0.;seen={};events=[];transitions=[];last_states={};distances={};positions={};cover_ticks=0;captured={}
   call_deferred("start");return
  FileAccess.open(out+"/selection.json",FileAccess.WRITE).store_string(JSON.stringify(sample_results,"  "))
 runtime.queue_free();await process_frame;await process_frame
 quit()
