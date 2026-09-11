extends SceneTree
const Weapons=preload("res://battle/combat/battle_weapon_catalog.gd")
const Specials=preload("res://battle/combat/battle_specialist_catalog.gd")
const State=preload("res://battle/core/battle_state.gd")
const Side=preload("res://battle/core/battle_side.gd")
const Unit=preload("res://battle/core/battle_participant.gd")
const Soldier=preload("res://campaign/units/soldier.gd")
const Geometry=preload("res://battle/geometry/battlefield_geometry.gd")
const Fire=preload("res://battle/combat/battle_fire_control_service.gd")
const Attack=preload("res://battle/combat/battle_attack_resolution_service.gd")
const Move=preload("res://battle/runtime/battle_movement_service.gd")
const Presenter=preload("res://gameplay/tactical_actor_presenter.gd")
const Identity=preload("res://battle/identity/tactical_identity_factory.gd")
const Anim=preload("res://battle/presentation/tactical_unit_animation_catalog.gd")
var checks=0
var failures: Array[String]=[]
func verify(ok: bool, message: String):
 checks+=1
 if not ok:failures.append(message)
func fixture():
 var b=State.new("mercer_fixture","skirmish","test","test","a","d")
 b.battlefield_geometry=Geometry.new();var g=b.battlefield_geometry
 g.width=100;g.height=60;g.attacker_deployment_rect=Rect2(0,0,49,60);g.defender_deployment_rect=Rect2(51,0,49,60)
 b.add_side(Side.new("a","rival_gang","force_a",true));b.add_side(Side.new("d","player_gang","force_d",false))
 return b
func unit(b,id: String,side: String,at: Vector2,special=false):
 var p=Unit.new(id,id,"rival_gang" if side=="a" else "player_gang",side,"pistol")
 if special:p.specialist_id=Specials.MERCER_DUAL_GLOCK
 b.add_participant(p);b.get_side(side).add_participant_id(id)
 p.has_battle_position=true;p.battle_position=at;p.movement_speed=3.6
 verify(Weapons.equip_for_setup(b,p,"glock_17"),"setup "+id)
 return p
func _initialize():call_deferred("run")
func run():
 var normal=Weapons.get_model("glock_17")
 var b=fixture();var p=unit(b,"dual","a",Vector2(10,30),true)
 var target=unit(b,"target","d",Vector2(18,30))
 var d=Weapons.for_participant(p)
 verify(d!=normal and d.has_valid_combat_profile(),"valid independent specialist definition")
 verify(d.max_range==20. and d.shots_per_second==3.5 and d.magazine_capacity==24 and d.reload_seconds==3.,"approved cadence, range, capacity and reload")
 verify(is_equal_approx(1.-d.miss_probability,(1.-normal.miss_probability)*.9),"hit probability is multiplied by .90")
 verify(d.solid_trauma==normal.solid_trauma and d.critical_trauma==normal.critical_trauma and d.graze_trauma==normal.graze_trauma,"no damage bonus per bullet")
 verify(p.vitality==target.vitality,"normal vitality")
 verify(is_equal_approx(d.movement_multiplier,normal.movement_multiplier*.95),"approved movement tradeoff")
 verify(normal.magazine_capacity==12 and normal.shots_per_second==2.5 and normal.max_range==24.,"ordinary Glock unchanged")
 var other_pistol=""
 for model in Weapons.models_for_class("pistol"):
  if model!="glock_17":other_pistol=model;break
 verify(not Weapons.equip_for_setup(b,p,other_pistol),"specialist rejects a different pistol")
 target.specialist_id=Specials.MERCER_DUAL_GLOCK
 verify(Weapons.for_participant(target)==null,"wrong faction rejected")
 target.specialist_id=""
 b.battle_phase="active"
 verify(not Weapons.equip_for_setup(b,p,"glock_17"),"active equip rejected")
 for i in range(24):
  verify(Fire.commit_shot(p,d),"shot "+str(i))
  verify(p.weapon_state.last_fired_hand==i%2,"alternate individual hand "+str(i))
  verify(not Fire.commit_shot(p,d),"cooldown enforced "+str(i))
  Fire._advance_participant_weapon(p,d.cooldown_seconds())
 verify(p.weapon_state.is_reloading and p.weapon_state.ammo_in_magazine==0,"both magazines empty starts reload")
 var remaining=p.weapon_state.reload_remaining_seconds
 Fire._advance_participant_weapon(p,remaining-.01)
 verify(p.weapon_state.is_reloading and not Fire.commit_shot(p,d),"cannot fire before reload completes")
 Fire._advance_participant_weapon(p,.02)
 verify(not p.weapon_state.is_reloading and p.weapon_state.ammo_in_magazine==24,"reload restores combined capacity")
 for hand in range(2):
  var shot=Attack.resolve_attack(b,"dual","target",.5)
  verify(shot.shot_executed,"real attack resolves for hand "+str(hand))
  verify(b.combat_feedback_events.back().weapon_hand==hand,"attack event carries firing hand")
  Fire._advance_participant_weapon(p,1.)
 p.battle_position=Vector2(10,30);p.set_movement_intent(Vector2.RIGHT)
 Move.advance(b,1.)
 verify(is_equal_approx(p.battle_position.x,10.+3.6*d.movement_multiplier),"actual movement uses specialist weight")
 var first=Soldier.new("one","rival_gang","keep","pistol",1.,10.)
 var second=Soldier.new("two","rival_gang","keep","pistol",1.,10.,"hq")
 var third=Soldier.new("three","rival_gang","keep","pistol",1.,10.)
 var state={"soldiers":{"one":first,"two":second,"three":third}}
 verify(Specials.assign_soldier(state,first,Specials.MERCER_DUAL_GLOCK,2),"assign from force/keep pool")
 verify(Specials.assign_soldier(state,second,Specials.MERCER_DUAL_GLOCK,2),"assign from garrison pool")
 verify(Specials.faction_count(state,"rival_gang")==2,"faction-wide count includes garrison")
 verify(not Specials.assign_soldier(state,third,Specials.MERCER_DUAL_GLOCK,2),"configured cap enforced across locations")
 var restored=Soldier.new();restored.from_dict(first.to_dict())
 verify(restored.specialist_id==first.specialist_id and restored.strategic_strength==first.strategic_strength,"specialist survives serialization without tier/strength boost")
 if not OS.get_cmdline_user_args().has("--runtime-only"):
  check_presenter(b,p,target)
  verify(Anim.mercer_manifest().get("variants",{}).size()==7,"all six sniper models and specialist bound")
  for model in ["rem700","sks","svd","ssg69","awm","psg1","dual_glock"]:
   var v="mercer_"+model
   var frames=Anim.frames_for(v)
   verify(frames!=null,"frames load "+v)
   if frames==null:continue
   for direction in Anim.DIRECTION_IDS_8:
    for clip in Anim.bound_clip_ids():
     if model!="dual_glock" and clip.ends_with("_left"):continue
     var name=Anim.animation_name(clip,direction)
     verify(frames.has_animation(name) and frames.get_frame_count(name)==Anim.clip_frame_count(clip),"complete "+v+" "+name)
   verify(FileAccess.file_exists(Anim.atlas_path(v,"portraits")),"portrait "+v)
  verify(Anim.variant_for("local_street_gang","sniper","awm")=="mercer_awm","Mercer sniper outfit routing")
  verify(Anim.variant_for("russian_organized_crime","sniper","awm")!="mercer_awm","other faction outfit retained")
  verify(Anim.variant_for("local_street_gang","pistol","glock_17")!="mercer_dual_glock","ordinary pistol outfit retained")
 var report={"checks":checks,"failures":failures}
 FileAccess.open("res://tools/faction_design/mercer_validation.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
 print("MERCER_VALIDATION ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)

func check_presenter(b,p,target):
 var holder=Node2D.new();root.add_child(holder)
 var presenter=Presenter.new();presenter.bind_root(holder,8.);presenter.bind_unit_root(holder)
 p.velocity=Vector2.ZERO;p.clear_movement_intent();p.clear_navigation_path()
 p.identity=Identity.make(p.participant_id,"local_street_gang","pistol")
 verify(presenter._ensure_unit_node(b,p),"specialist creates actual retained sprite")
 p.weapon_state=Weapons.state_for_participant(p)
 for hand in range(2):
  b.elapsed_time_seconds+=.4
  var shot=Attack.resolve_attack(b,p.participant_id,target.participant_id,.5)
  verify(shot.shot_executed,"presenter test shot")
  presenter._apply_unit_transform(b,p)
  verify(presenter._unit_clips.get(p.participant_id)==("fire" if hand==0 else "fire_left"),"event selects correct recoil clip")
  var point=presenter.shot_muzzle_position(p.participant_id)
  verify(is_finite(point.x) and is_finite(point.y),"firing muzzle resolves")
  Fire._advance_participant_weapon(p,.4)
 holder.queue_free()
