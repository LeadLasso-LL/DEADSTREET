extends SceneTree
const Scenario=preload("res://tools/battle_showcase/scenario.gd")
const Card=preload("res://gameplay/tactical_unit_card.gd")
var checks=0
var problems=[]
func verify(ok: bool,why: String):
 checks+=1
 if not ok:problems.append(why)
func _initialize():call_deferred("run")
func run():
 var runtime=load("res://gameplay/gameplay_runtime.tscn").instantiate();root.add_child(runtime)
 await process_frame
 var setup=Scenario.setup(runtime,2005,true)
 verify(setup.has("battle"),"legal covered deployment")
 if not setup.has("battle"):print(setup);quit(1);return
 var b=setup.battle;var view=runtime.get_node("TacticalBattleView");var director=view.battle_presentation
 director.set_process(false);director.sound.set_process(false);director._process(0.)
 verify(director.stage=="arrival","arrival begins after commitment")
 verify(not runtime.begin_current_battle().success,"combat blocked during intro")
 var before={}
 for p in b.participants.values():
  before[p.participant_id]={"position":p.battle_position,"vitality":p.vitality}
  if p.side_id==b.attacker_side_id:verify(p.has_occupied_cover_slot(),"attacker starts in cover "+p.participant_id)
 verify(director.last_path_errors.is_empty(),"all disembarking/reacting routes navigate around obstacles")
 verify(director.attacker.emblem!=null and director.defender.emblem!=null,"both original emblems loaded")
 for i in range(300):
  view._sync_actor_presenter();director._process(.05)
  if i==30:
   for car in view._dusk_vehicle_nodes.values():verify(car.door_open==0.,"doors closed while approaching")
 verify(director.stage=="ready","arrival ends ready to start")
 verify(b.elapsed_time_seconds==0.,"no combat time during arrival")
 verify(b.combat_feedback_events.is_empty(),"no shots during arrival")
 for p in b.participants.values():
  verify(p.battle_position==before[p.participant_id].position,"arrival preserves deployed position "+p.participant_id)
  verify(p.vitality==before[p.participant_id].vitality,"arrival preserves health "+p.participant_id)
 verify(runtime.begin_current_battle().success,"Start Battle activates simulation")
 director._process(0.)
 director.identifiers_enabled=false;director.update_markers()
 for marker in director.markers.values():verify(not marker.visible,"identifier off")
 director.identifiers_enabled=true;director.update_markers()
 for marker in director.markers.values():verify(marker.visible,"identifier on")
 # Each real attack event plays once; mute must not replay a backlog.
 var sound=director.sound;sound.enabled=true;sound._process(0.)
 var sequence=10000
 for p in b.participants.values():
  if p.side_id!=b.attacker_side_id:continue
  var event=preload("res://battle/combat/battle_attack_event.gd").new(p.participant_id)
  event.sequence_id=sequence;sequence+=1;b.combat_feedback_events.append(event)
 sound._process(0.);verify(sound.shots_played==4,"four weapon events sounded")
 sound._process(0.);verify(sound.shots_played==4,"events never replay on later frames")
 sound.enabled=false
 var silent=preload("res://battle/combat/battle_attack_event.gd").new(b.participants.keys()[0]);silent.sequence_id=sequence;b.combat_feedback_events.append(silent)
 sound._process(0.);sound.enabled=true;sound._process(0.);verify(sound.shots_played==4,"muted events do not replay after unmute")
 for stream in sound.streams.values():verify(stream!=null and stream.data.size()>0,"nonempty audio asset")
 b.combat_feedback_events.clear()
 # Controlled result fixture checks shared rendering against both sides' true states.
 var i=0
 for p in b.participants.values():
  if p.side_id==b.attacker_side_id:p.is_alive=false;p.vitality=0.
  else:
   p.is_wounded=i%2==0;p.vitality=.6 if p.is_wounded else 1.5;i+=1
 runtime._process(1./30.);verify(b.battle_phase=="resolved","normal runtime resolves eliminated side");director._process(2.9)
 verify(director.result_cards.size()==8,"eight result cards")
 for panel in director.result_root.get_children():
  if panel is Panel:
   for emblem in panel.get_children():
    if emblem is TextureRect:verify(emblem.size==Vector2(62,62),"result emblems stay inside header")
 var holders=Control.new();root.add_child(holders)
 for p in b.participants.values():
  var expected=Card.build(holders,Vector2.ZERO,director.font);Card.update(expected,p,"",false)
  var actual=director.result_cards[p.participant_id]
  for key in ["status","role","gun"]:verify(actual[key].text==expected[key].text,"same HUD "+key+" "+p.participant_id)
  verify(actual.health.size==expected.health.size,"same health "+p.participant_id)
  verify(actual.portrait.modulate==expected.portrait.modulate,"same wound/death tint "+p.participant_id)
 director.audio_enabled=false;director._process(.1);verify(not director.sound.enabled,"HUD mute binding")
 verify(not director.results_acknowledged,"results await Continue")
 runtime._process(.1)
 verify(runtime.game_flow_controller.get_current_mode()=="tactical_pending_handoff","result enters pending handoff")
 runtime._process(10.)
 verify(runtime.game_flow_controller.get_current_mode()=="tactical_pending_handoff","result remains until Continue")
 director._process(director.outro.duration+2.);director.continue_button.pressed.emit();runtime._process(.1)
 verify(runtime.game_flow_controller.get_current_mode()=="campaign","Continue returns to campaign")
 print("PRESENTATION_VALIDATION checks=",checks," problems=",problems)
 FileAccess.open("res://tools/battle_showcase/results/presentation_checks.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"problems":problems},"  "))
 runtime.queue_free();holders.queue_free();await process_frame;await process_frame
 quit(0 if problems.is_empty() else 1)
