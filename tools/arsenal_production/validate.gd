extends SceneTree
const Weapons=preload("res://battle/combat/battle_weapon_catalog.gd")
const State=preload("res://battle/core/battle_state.gd")
const Side=preload("res://battle/core/battle_side.gd")
const Unit=preload("res://battle/core/battle_participant.gd")
const Geometry=preload("res://battle/geometry/battlefield_geometry.gd")
const Obstacle=preload("res://battle/geometry/battle_obstacle.gd")
const Move=preload("res://battle/runtime/battle_movement_service.gd")
const Targets=preload("res://battle/combat/battle_target_selection_service.gd")
const Behavior=preload("res://battle/combat/battle_combat_behavior_service.gd")
const Bands=preload("res://battle/combat/battle_combat_behavior_catalog.gd")
const Fire=preload("res://battle/combat/battle_fire_control_service.gd")
const Attack=preload("res://battle/combat/battle_attack_resolution_service.gd")
const Consequence=preload("res://battle/combat/battle_combat_consequence_service.gd")
const Runtime=preload("res://battle/runtime/battle_runtime_service.gd")
var checks=0
var failures: Array[String]=[]
func verify(ok: bool, message: String):
 checks+=1
 if not ok:failures.append(message)
func fixture():
 var b=State.new("arsenal_fixture","skirmish","test","test","a","d")
 b.battlefield_geometry=Geometry.new();var g=b.battlefield_geometry
 g.width=100;g.height=60;g.attacker_deployment_rect=Rect2(0,0,49,60);g.defender_deployment_rect=Rect2(51,0,49,60)
 b.add_side(Side.new("a","faction_a","force_a",true));b.add_side(Side.new("d","faction_d","force_d",false))
 return b
func unit(b,id: String,side: String,model: String,at: Vector2):
 var d=Weapons.get_model(model);var p=Unit.new(id,id,"faction_"+side,side,d.weapon_type_id)
 b.add_participant(p);b.get_side(side).add_participant_id(id)
 p.has_battle_position=true;p.battle_position=at;p.movement_speed=3.6
 verify(Weapons.equip_for_setup(b,p,model),"setup equip "+model)
 return p
func _initialize():call_deferred("run")
func run():
 verify(Weapons.model_data().models.size()==30,"30 weapon models")
 for kind in ["pistol","smg","rifle","shotgun","sniper"]:
  var tiers={1:0,2:0,3:0}
  for id in Weapons.models_for_class(kind):
   var d=Weapons.get_model(id);verify(d!=null and d.has_valid_combat_profile(),"valid model "+id)
   tiers[d.tier]+=1
   verify(d.movement_multiplier>=.75 and d.movement_multiplier<=1.25,"weight bounds "+id)
   var b=fixture();var p=unit(b,"source","a",id,Vector2(10,30));unit(b,"target","d","glock_17",Vector2(60,30))
   verify(not Weapons.equip_for_setup(b,p,"rem700" if kind!="sniper" else "glock_17"),"wrong class rejected "+id)
   var profile=Bands.for_participant(p)
   verify(profile!=null and profile.preferred_max_distance<d.max_range,"AI band within model range "+id)
   b.battle_phase="active";p.set_movement_intent(Vector2.RIGHT)
   verify(not Weapons.equip_for_setup(b,p,id),"active swap rejected "+id)
   Move.advance(b,1.)
   verify(absf(p.battle_position.x-10.-3.6*d.movement_multiplier)<.001,"actual weighted movement "+id)
   p.battle_position=Vector2(10,30);p.movement_speed=1.8;Move.advance(b,1.)
   verify(absf(p.battle_position.x-10.-1.8*d.movement_multiplier)<.001,"wounded weighted movement "+id)
  verify(tiers=={1:2,2:2,3:2},"two models per tier "+kind)
 var b=fixture();var sniper=unit(b,"sniper","a","rem700",Vector2(10,30))
 var far=unit(b,"far","d","ak47",Vector2(65,30));var medium=unit(b,"medium","d","ak47",Vector2(45,10));var near=unit(b,"near","d","uzi",Vector2(30,30))
 b.battle_phase="active";Targets.advance(b);verify(sniper.target_participant_id=="far","sniper chooses farthest valid target")
 medium.battle_position=Vector2(69,10);Targets.advance(b);verify(sniper.target_participant_id=="far","sniper retains valid acquisition")
 near.battle_position=Vector2(18,30);Targets.advance(b);verify(sniper.target_participant_id=="near","nearby threat overrides distant target")
 near.battle_position=Vector2(30,30);sniper.clear_target_participant();medium.battle_position=Vector2(45,10)
 b.battlefield_geometry.add_obstacle(Obstacle.new("wall",Rect2(40,29,2,4),true,true));b.clear_los_cache();Targets.advance(b)
 verify(sniper.target_participant_id=="medium","sniper avoids blocked far target")
 sniper.velocity=Vector2(1,0);Behavior._update_sniper_aim(b,sniper);verify(sniper.has_sniper_aim() and not sniper.sniper_aim_engagement_active,"movement breaks aim")
 sniper.velocity=Vector2.ZERO;Behavior._update_sniper_aim(b,sniper);verify(sniper.has_sniper_aim(),"stationary sniper must settle")
 b=fixture();sniper=unit(b,"sniper","a","awm",Vector2(10,30));var target=unit(b,"target","d","ak47",Vector2(50,30));b.battle_phase="active"
 var shot=Attack.resolve_attack(b,"sniper","target",.999)
 verify(shot.shot_executed and not target.is_alive,"high-trauma sniper critical can kill healthy unit")
 target.is_alive=true;target.is_wounded=true;target.vitality=.50
 Consequence.apply_trauma(b,target,.02);verify(target.is_alive and is_equal_approx(target.vitality,.48),"wounded status never automatically kills")
 var report={"checks":checks,"failures":failures}
 FileAccess.open("res://tools/arsenal_production/validation.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
 print("ARSENAL_VALIDATION ",JSON.stringify(report));quit(0 if failures.is_empty() else 1)
