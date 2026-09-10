extends RefCounted
# Recording scenario: campaign launch and legal deployments, with ordinary live combat.
const Starter = preload("res://gameplay/starter_world_service.gd")
const Mission = preload("res://campaign/missions/mission_request.gd")
const Deployment = preload("res://campaign/actions/deployment_request.gd")
const Launch = preload("res://campaign/missions/neighborhood_hq_attack_service.gd")
const AI = preload("res://battle/ai/battle_deployment_ai_service.gd")
const Force = preload("res://battle/core/battle_force_command_service.gd")
const HudQuery = preload("res://gameplay/tactical_unit_hud_query.gd")

static func setup(runtime: Node,seed_value: int,defer_start: bool=false) -> Dictionary:
 var state=runtime.game_state
 Starter._add_keep_soldier(state,"player_showcase_shotgun","shotgun",1.3,25.)
 Starter._add_hq_soldier(state,"rival_showcase_shotgun","shotgun",1.3,25.)
 var soldiers: Array[String]=Starter.debug_attacker_soldier_ids()
 soldiers.append("player_showcase_shotgun")
 var vehicles: Array[String]=[Starter.VEHICLE_ID]
 var deployment=Deployment.new(Starter.DEBUG_FORCE_ID,Starter.PLAYER_FACTION_ID,Starter.KEEP_ID,Starter.HQ_ID,soldiers,vehicles,10.)
 var launched=Launch.launch_from_stronghold(state,Mission.new(Starter.DEBUG_MISSION_ID,"capture_neighborhood_hq",deployment))
 if launched==null or not launched.success:return {"error":"launch"}
 for i in range(20):
  runtime.advance_campaign_turn()
  var entered=runtime.enter_battle()
  if entered!=null and entered.success:break
 var session=runtime.get_current_session()
 if session==null or session.battle_state==null:return {"error":"session"}
 var battle=session.battle_state
 battle.apply_combat_seed(seed_value)
 var controller=runtime.tactical_deployment_controller
 var occupied: Array[Vector2]=[]
 var preferred={"rifle":Vector2(49,26),"smg":Vector2(54.15,33.35),"pistol":Vector2(60,26),"shotgun":Vector2(50,33)}
 var cover_for={"rifle":"cover_north_car_4","smg":"cover_south_car_5","pistol":"cover_north_car_5","shotgun":"cover_south_car_4"}
 var participant_ids=battle.participants.keys()
 participant_ids.sort()
 for id in participant_ids:
  var p=battle.get_participant(id)
  if p.side_id!=battle.attacker_side_id:continue
  controller.select_participant(id)
  var point: Vector2=preferred[p.weapon_type]
  var placed=controller.try_place_selected(point)
  if placed==null or not placed.success:
   var ok=false
   for y in [30.,31.,28.,26.,22.]:
    if ok:break
    for x in [43.,45.,47.,49.,51.,53.]:
     point=Vector2(x,y)
     var crowded=false
     for used in occupied:
      if used.distance_to(point)<1.8:crowded=true
     if crowded:continue
     placed=controller.try_place_selected(point)
     if placed!=null and placed.success:ok=true;break
   if not ok:return {"error":"placement "+id}
  var cover=controller.try_place_selected_cover(cover_for[p.weapon_type])
  if cover==null or not cover.success:return {"error":"starting cover "+id}
  occupied.append(battle.get_participant(id).battle_position)
 var committed=controller.try_commit_attacker()
 if committed==null or not committed.success:return {"error":"attacker commit"}
 for side in [battle.attacker_side_id,battle.defender_side_id]:
  if not battle.is_side_deployment_committed(side):
   var other=battle.defender_side_id if side==battle.attacker_side_id else battle.attacker_side_id
   var result=AI.apply_and_commit_side(battle,side,other)
   if result==null or not result.success:return {"error":"defender commit"}
 var counts={}
 for p in battle.participants.values():
  if not counts.has(p.side_id):counts[p.side_id]={}
  counts[p.side_id][p.weapon_type]=int(counts[p.side_id].get(p.weapon_type,0))+1
  var expected="russian_organized_crime" if p.side_id==battle.attacker_side_id else "local_street_gang"
  if p.identity.gang_archetype_id!=expected:return {"error":"identity "+p.participant_id}
 for side in counts:
  for weapon in ["smg","rifle","pistol","shotgun"]:
   if counts[side].get(weapon,0)!=1:return {"error":"roster "+side+" "+weapon}
 if battle.participants.size()!=8:return {"error":"participant count"}
 var nav=preload("res://battle/navigation/battle_navigation_service.gd")
 for p in battle.participants.values():
  if not nav.is_reachable(battle,p.battle_position,Vector2(40,30)):return {"error":"unreachable start "+p.participant_id}
 if not defer_start:
  runtime.skip_battle_cinematics=true
  var begin=runtime.begin_current_battle()
  if begin==null or not begin.success:return {"error":"begin"}
 runtime.set_process(false)
 command(battle,battle.attacker_side_id,"hold")
 var view=runtime.get_node("TacticalBattleView")
 view._dusk_zoom=1.30;view._dusk_pan=Vector2(-5,-30);view._frame_camera()
 return {"battle":battle,"roster":counts,"seed":seed_value}

static func command(battle,side: String,id: String) -> void:
 for force_id in battle.get_sorted_tactical_force_ids():
  var force=battle.get_tactical_force(force_id)
  if force.side_id==side:Force.set_command(battle,force_id,id)

static func direct(runtime,battle,t: float,previous: float) -> void:
 # Only orders and timing are staged. Hits, damage, wounds and victory are simulated.
 if previous<8. and t>=8.:command(battle,battle.attacker_side_id,"focus_right")
 if previous<15. and t>=15.:command(battle,battle.attacker_side_id,"push")
 if previous<28. and t>=28.:command(battle,battle.defender_side_id,"push")

 # Bounding advances use actual cover orders, not a rush across the open road.
 for timing in [4.,14.,24.]:
  if previous<timing and t>=timing:
   var cover_targets={"rifle":"cover_north_car_3","smg":"cover_south_car_3","pistol":"cover_north_bin_east","shotgun":"cover_south_bin_east"} if timing<10 else {"rifle":"cover_north_car_2","smg":"cover_south_car_2","pistol":"cover_service_cabinet","shotgun":"cover_south_car_3"}
   for p in battle.participants.values():
    if p.side_id!=battle.attacker_side_id or not p.is_alive or p.is_wounded:continue
    if runtime.tactical_orders_controller.select_participant(p.participant_id):
     runtime.tactical_orders_controller.issue_cover(cover_targets[p.weapon_type])
   runtime.tactical_orders_controller.clear_selection()
 # Release the defenders' individual anchors for a late counterattack if the fight continues.
 if previous<24. and t>=24.:
  for p in battle.participants.values():
   if p.side_id!=battle.defender_side_id or not p.is_alive or p.is_wounded:continue
   p.set_defend_position(false);p.clear_defend_position_anchor()
   var target=Vector2(31,28 if p.weapon_type in ["rifle","smg"] else 21.5)
   var path=preload("res://battle/navigation/battle_navigation_service.gd").find_path(battle,p.battle_position,target)
   if path.success:
    preload("res://battle/geometry/battle_cover_service.gd").release_all_for_participant(battle,p.participant_id)
    p.set_navigation_path(path.destination,path.waypoints,p.NAVIGATION_SOURCE_EXTERNAL)
    p.set_player_move_intent()

 # A late close-range push breaks a cover stalemate using ordinary move orders.
 for timing in [34.,42.,50.]:
  if previous<timing and t>=timing:
   command(battle,battle.attacker_side_id,"push")
   for p in battle.participants.values():
    if p.side_id!=battle.attacker_side_id or not p.is_alive or p.is_wounded:continue
    if runtime.tactical_orders_controller.select_participant(p.participant_id):
     runtime.tactical_orders_controller.issue_move(Vector2(32. if timing<40 else 20.,28. if p.weapon_type in ["rifle","smg"] else 21.5))
   runtime.tactical_orders_controller.clear_selection()
