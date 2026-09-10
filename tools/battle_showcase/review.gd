extends SceneTree
const Scenario=preload("res://tools/battle_showcase/scenario.gd")
const RuntimeService=preload("res://battle/runtime/battle_runtime_service.gd")
var runtime: Node
var battle
var active=false
var time=0.
var elapsed_after=0.
var seed_value=2001
var out="res://tools/battle_showcase/results"
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
var title: Label
var subtitle: Label
func _initialize():
 var args=OS.get_cmdline_user_args()
 for arg in args:
  if arg.begins_with("--seed="):seed_value=int(arg.split("=")[1])
  if arg=="--hold":hold=true
  if arg=="--recording":recording=true
  if arg=="--sample":fast=true;sample_seeds.assign([2001,2002,2003,2004,2005,2006])
 DirAccess.make_dir_recursive_absolute(out)
 call_deferred("start")
func start():
 if fast and not sample_seeds.is_empty():seed_value=sample_seeds.pop_front()
 runtime=load("res://gameplay/gameplay_runtime.tscn").instantiate();root.add_child(runtime)
 await process_frame
 var result=Scenario.setup(runtime,seed_value)
 if not result.has("battle"):push_error("SHOWCASE_FAILED "+str(result));quit(1);return
 battle=result.battle
 if recording:make_recording_title()
 for p in battle.participants.values():positions[p.participant_id]=p.battle_position;distances[p.participant_id]=0.
 active=true
 print("SHOWCASE_READY seed=",seed_value," roster=",result.roster)
func step(dt: float):
 var previous=time;time+=dt
 if battle.battle_phase=="active":
  Scenario.direct(runtime,battle,time,previous)
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
 if recording and prelude<2.:
  prelude+=1./30.;return false
 if recording:
  title.text="DEAD STREET"
  subtitle.text="ORLOV BRATVA  vs  MERCER SAINTS   /   4v4"
  if battle.battle_phase=="resolved":
   subtitle.text=("MERCER SAINTS HOLD THE BLOCK" if battle.get_winning_side_id()==battle.defender_side_id else "ORLOV BRATVA TAKE THE BLOCK")
 for i in range(12 if fast else 1):
  step(1./30.)
  if time>=65. or elapsed_after>=3.5:
   if hold:
    if not captured.has("held"):captured["held"]=true;save_report();capture("final")
    active=false;root.title="Dead Street - 4v4 showcase review (paused)";return false
   finish();return false
 if not fast:
  for second in [1,5,10,20,30]:
   if time>=second and not captured.has(second):captured[second]=true;capture(str(second))
 return false
func make_recording_title():
 var layer=CanvasLayer.new();layer.layer=40;root.add_child(layer)
 var box=Panel.new();layer.add_child(box);box.position=Vector2(24,18);box.size=Vector2(386,64)
 var theme=StyleBoxFlat.new();theme.bg_color=Color(.05,.08,.09,.88);theme.border_color=Color("#706b54");theme.border_width_bottom=2
 box.add_theme_stylebox_override("panel",theme)
 var font=SystemFont.new();font.font_names=PackedStringArray(["Arial"]);font.font_weight=700
 title=Label.new();box.add_child(title);title.position=Vector2(14,7);title.text="DEAD STREET  /  HAROLD APARTMENTS"
 title.add_theme_font_override("font",font);title.add_theme_font_size_override("font_size",16);title.add_theme_color_override("font_color",Color("#e5dfc8"))
 subtitle=Label.new();box.add_child(subtitle);subtitle.position=Vector2(14,33);subtitle.text="ORLOV BRATVA  vs  MERCER SAINTS   /   4v4"
 subtitle.add_theme_font_override("font",font);subtitle.add_theme_font_size_override("font_size",12);subtitle.add_theme_color_override("font_color",Color("#a3b2aa"))
 box.scale=Vector2.ONE*root.get_visible_rect().size.x/1152.
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
 var report={"seed":seed_value,"duration":battle.elapsed_time_seconds,"phase":battle.battle_phase,"winner":battle.get_winning_side_id(),"alive":alive,"deaths":deaths,"shots":seen.size(),"transitions":transitions,"distance":distances,"cover_ticks":cover_ticks,"death_variants":variants,"events":events}
 FileAccess.open(out+"/seed_%d.json"%seed_value,FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
 print("SHOWCASE_RESULT ",seed_value," duration=",report.duration," alive=",alive," shots=",seen.size()," max_travel=",max_distance)
 return report
func finish():
 active=false
 var report=save_report()
 if fast:
  sample_results.append({"seed":seed_value,"duration":report.duration,"phase":report.phase,"alive":report.alive,"shots":report.shots,"wound_death_events":transitions.size(),"cover_ticks":cover_ticks})
  if not sample_seeds.is_empty():
   runtime.queue_free();time=0.;elapsed_after=0.;seen={};events=[];transitions=[];last_states={};distances={};positions={};cover_ticks=0;captured={}
   call_deferred("start");return
  FileAccess.open(out+"/selection.json",FileAccess.WRITE).store_string(JSON.stringify(sample_results,"  "))
 quit()
