extends RefCounted
# Isolated weapon review: a fresh starter world per run, no campaign save writes.
const Weapons=preload("res://battle/combat/battle_weapon_catalog.gd")
const Starter=preload("res://gameplay/starter_world_service.gd")
const Mission=preload("res://campaign/missions/mission_request.gd")
const Deployment=preload("res://campaign/actions/deployment_request.gd")
const Launch=preload("res://campaign/missions/neighborhood_hq_attack_service.gd")
const Factions=preload("res://battle/identity/faction_unit_catalog.gd")
const Identity=preload("res://battle/identity/tactical_identity_factory.gd")
const Tiers=preload("res://battle/combat/battle_unit_tier_catalog.gd")
const Models=preload("res://campaign/vehicles/vehicle_model_catalog.gd")
const Fleet=preload("res://campaign/vehicles/vehicle_fleet_service.gd")
const AI=preload("res://battle/ai/battle_deployment_ai_service.gd")
static func setup(runtime: Node, loadouts: Dictionary, sniper_test: bool, seed_value: int, full_roster: bool = false) -> Dictionary:
 var state=runtime.game_state
 if full_roster:state.get_map_location(Starter.HQ_ID).garrison_capacity=5
 # This sandbox equips one Mercer specialist; it does not choose the campaign cap.
 if str(loadouts.get("defender",{}).get("specialist",""))=="mercer_dual_glock":
  for soldier in state.soldiers.values():
   if soldier.faction_id=="rival_gang" and soldier.weapon_type_id=="pistol":
    soldier.specialist_id="mercer_dual_glock"
    break
 # Recruit the review role before battle construction; never turn a live rifleman into a sniper.
 if sniper_test and not full_roster:
  state.get_soldier(Starter.SOLDIER_ID).weapon_type_id="sniper"
  state.get_soldier(Starter.RIVAL_RIFLE_ID).weapon_type_id="sniper"
 Starter._add_keep_soldier(state,"player_arsenal_shotgun","shotgun",1.3,25.)
 Starter._add_hq_soldier(state,"rival_arsenal_shotgun","shotgun",1.3,25.)
 var soldiers: Array[String]=Starter.debug_attacker_soldier_ids();soldiers.append("player_arsenal_shotgun")
 var vehicles: Array[String]=[Starter.VEHICLE_ID]
 if full_roster:
  Starter._add_keep_soldier(state,"player_arsenal_sniper","sniper",1.9,35.)
  Starter._add_hq_soldier(state,"rival_arsenal_sniper","sniper",1.9,35.)
  if state.get_soldier("rival_arsenal_sniper").garrison_hq_id!=Starter.HQ_ID:return {"error":"review sniper recruitment"}
  soldiers.append("player_arsenal_sniper")
 var convoy: Array=loadouts.get("attacker",{}).get("vehicles",["bayou","bayou"] if full_roster else ["bayou"])
 var transport=Models.convoy(convoy,soldiers.size())
 if not transport.valid:return {"error":transport.get("error","Insufficient transport")}
 vehicles.clear()
 for index in range(convoy.size()):
  var vehicle_id="sandbox_transport_%02d"%index
  var v=Fleet.create(vehicle_id,Starter.PLAYER_FACTION_ID,str(convoy[index]))
  if v==null:return {"error":"Unknown vehicle"}
  state.add_vehicle(v);state.assign_vehicle_to_stronghold(v.id,Starter.KEEP_ID);vehicles.append(v.id)
 for soldier in state.soldiers.values():
  var side: String="attacker" if soldier.faction_id==Starter.PLAYER_FACTION_ID else "defender"
  soldier.unit_tier=int(loadouts.get(side,{}).get("unit_tiers",{}).get(soldier.weapon_type_id,1))
  var armor_id: String=str(loadouts.get(side,{}).get("armor",{}).get(soldier.weapon_type_id,""))
  if not soldier.Armor.valid(armor_id):return {"error":"unknown armor"}
  soldier.armor_id=armor_id
 var deployment=Deployment.new(Starter.DEBUG_FORCE_ID,Starter.PLAYER_FACTION_ID,Starter.KEEP_ID,Starter.HQ_ID,soldiers,vehicles,10.)
 var launched=Launch.launch_from_stronghold(state,Mission.new(Starter.DEBUG_MISSION_ID,"capture_neighborhood_hq",deployment))
 if launched==null or not launched.success:return {"error":"review launch"}
 for i in range(20):
  runtime.advance_campaign_turn()
  var entered=runtime.enter_battle()
  if entered!=null and entered.success:break
 var session=runtime.get_current_session()
 if session==null or session.battle_state==null:return {"error":"review session"}
 var b=session.battle_state;b.apply_combat_seed(seed_value)
 if full_roster and b.participants.size()!=10:return {"error":"review requires five units per side"}
 for p in b.participants.values():
  var side="attacker" if p.side_id==b.attacker_side_id else "defender"
  var faction_id: String=Factions.canonical_id(str(loadouts.get(side,{}).get("faction","orlov" if side=="attacker" else "mercer")))
  if faction_id.is_empty():return {"error":"unknown faction"}
  p.identity=Identity.make(p.participant_id,faction_id,p.weapon_type)
  if not p.specialist_id.is_empty() and faction_id!="mercer":return {"error":"Mercer specialist requires Mercer Saints"}
  var tier: int=int(loadouts.get(side,{}).get("unit_tiers",{}).get(p.weapon_type,1))
  if not Tiers.set_for_setup(b,p,tier):return {"error":"invalid unit tier"}
  var id: String=str(loadouts.get(side,{}).get(p.weapon_type,Weapons.default_model(p.weapon_type)))
  if not Weapons.equip_for_setup(b,p,id):return {"error":"review equip "+id}
 var controller=runtime.tactical_deployment_controller
 controller.choose_arrival("far")
 if not controller.place_unplaced_in_cover():
  var fallback=AI.apply_and_commit_side(b,b.attacker_side_id,b.defender_side_id)
  if fallback==null or not fallback.success:return {"error":"review deployment: "+("no result" if fallback==null else fallback.error_code)}
 var committed=controller.try_commit_attacker() if not b.is_side_deployment_committed(b.attacker_side_id) else preload("res://battle/core/battle_deployment_commit_result.gd").succeeded(b.attacker_side_id)
 if committed==null or not committed.success:return {"error":"review commit: "+("no result" if committed==null else committed.error_code)}
 for side in [b.attacker_side_id,b.defender_side_id]:
  if not b.is_side_deployment_committed(side):
   var other=b.defender_side_id if side==b.attacker_side_id else b.attacker_side_id
   var placed=AI.apply_and_commit_side(b,side,other)
   if placed==null or not placed.success:return {"error":"review defender placement"}
 runtime.set_process(false)
 var view=runtime.get_node("TacticalBattleView");view._dusk_zoom=1.30;view._dusk_pan=Vector2(-5,-30);view._frame_camera()
 return {"battle":b}

static func begin_review(runtime, b):
 var result=runtime.begin_current_battle()
 if result!=null and result.success:
  # Begin applies pending deployment orders. Release only after those have been applied.
  for p in b.participants.values():
   if p.side_id==b.attacker_side_id:p.clear_player_tactical_intent()
 return result
