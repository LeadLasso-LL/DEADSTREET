extends RefCounted
# Showcase fixture: veteran estate garrison defends against TRC; combat and contextual orders remain live.
const SEED=9146
const Config=preload("res://gameplay/sandbox_force_config.gd")
const Force=preload("res://battle/core/battle_force_command_service.gd")
var orders
var b
var queue={}
var log=[]
var seen={}
var last_shot={}
var next_check=2.0
var pushes=0
var held=false
var withdrawn=false
var released=false
var counterattack=false
var deselect_at=-1.0
const Armor=preload("res://campaign/equipment/armor_catalog.gd")
static func config() -> Dictionary:
 var c={"map_id":"whittaker_estate","attacker":{"faction":"trc","vehicles":["aegis","watchdog","vigil"],"units":[]},"defender":{"faction":"whittaker","vehicles":["mesa","outlander","workhorse"],"units":[]}}
 c.attacker["vehicle_occupants"]=[{"units":7,"bed":0},{"units":5,"bed":0},{"units":4,"bed":0}]
 var attack=["pistol","pistol","smg","smg","smg","shotgun","shotgun","shotgun","rifle","rifle","rifle","rifle","rifle","rifle","sniper","sniper"]
 var defense=["pistol","pistol","smg","smg","shotgun","shotgun","shotgun","shotgun","rifle","rifle","rifle","rifle","rifle","sniper","sniper","sniper"]
 var guns={"attacker":{"pistol":"glock_17","smg":"mp5","shotgun":"benelli_m4","rifle":"m4a1","sniper":"awm"},"defender":{"pistol":"m1911","smg":"mac10","shotgun":"rem870","rifle":"m4a1","sniper":"awm"}}
 for side in ["attacker","defender"]:
  for kind in (attack if side=="attacker" else defense):
   var row=Config.unit(kind);row.weapon=guns[side][kind];row.tier=1 if side=="attacker" else 3
   row.armor="patrol_vest" if side=="attacker" else "reinforced_carrier"
   c[side].units.append(row)
 return c
func setup(battle,controller):
 b=battle;orders=controller
 for id in b.get_sorted_tactical_force_ids():
  Force.set_command(b,id,"push" if b.get_tactical_force(id).side_id==b.attacker_side_id else "hold")
func healthy(side: String) -> Array:
 var units=[]
 for p in b.participants.values():
  if p.side_id==side and p.is_alive and not p.is_wounded:units.append(p)
 units.sort_custom(func(a,z):return a.participant_id<z.participant_id)
 return units
func choose(ids: Array):
 orders.clear_selection()
 for id in ids:orders.select_participant(id,true)
func stage(command: String,ids: Array,line: float,why: String):
 if ids.is_empty():return
 choose(ids);orders.command_selected(command)
 var t=b.elapsed_time_seconds
 if command in ["push","fall_back"]:
  queue={"command":command,"ids":ids,"from":orders.line_x,"line":line,"start":t,"why":why}
 else:
  log.append({"time":t,"command":command,"reason":why,"feedback":orders.last_command_feedback.duplicate(),"ids":ids})
  deselect_at=t+2.0
func tick():
 var t=b.elapsed_time_seconds
 for e in b.combat_feedback_events:
  if seen.has(e.sequence_id):continue
  seen[e.sequence_id]=true
  if not e.source_participant_id.is_empty():last_shot[e.source_participant_id]=t
 if not queue.is_empty():
  var u=clampf((t-float(queue.start))/1.05,0.,1.)
  orders.set_line_x(lerpf(queue.from,queue.line,smoothstep(0.,1.,u)))
  if u>=1.0:
   var result=orders.commit_line()
   log.append({"time":t,"command":queue.command,"reason":queue.why,"line":queue.line,"accepted":result.accepted,"failed":result.failed})
   queue={};deselect_at=t+2.8
  return
 if deselect_at>0.0 and t>=deselect_at:orders.clear_selection();deselect_at=-1.0
 if t<next_check:return
 next_check=t+2.0
 var own=healthy(b.attacker_side_id);var enemy=healthy(b.defender_side_id)
 if own.is_empty() or enemy.is_empty():return
 # The garrison holds its prepared line, then counterattacks a broken assault.
 # This changes normal force tactics; casualty and victory services stay authoritative.
 if not counterattack and own.size()<=8 and enemy.size()>=own.size()+2:
  counterattack=true
  var defenders=[]
  for unit in enemy:defenders.append(unit.participant_id)
  var result=preload("res://battle/combat/battle_player_command_service.gd").issue(b,defenders,"push",56.)
  log.append({"time":t,"event":"defender_counterattack","reason":"TRC assault has lost half its effective strength","result":result})
 var front_enemy=180.0
 for e in enemy:front_enemy=minf(front_enemy,e.battle_position.x)
 # Save an isolated forward element only if locally outnumbered and damaged.
 if not withdrawn:
  for p in own:
   if p.vitality/p.max_vitality>.7 or p.current_player_group_command()!="":continue
   var friends=0;var hostiles=0
   for q in own:
    if q.battle_position.distance_to(p.battle_position)<14.:friends+=1
   for e in enemy:
    if e.battle_position.distance_to(p.battle_position)<18.:hostiles+=1
   if hostiles>=friends+2:
    withdrawn=true;stage("fall_back",[p.participant_id],p.battle_position.x-10.,"Damaged forward fighter locally outnumbered");return
 # Hold firing support only after it has actually established contact from cover.
 if not held and t>5.0:
  var support=[]
  for p in own:
   if p.weapon_type in ["rifle","sniper"] and not p.occupied_cover_slot_id.is_empty() and t-float(last_shot.get(p.participant_id,-100.0))<2.5:support.append(p.participant_id)
  if support.size()>=2:
   held=true;stage("hold",support,NAN,"Firing support has established covered overwatch");return
 if held and t>24.0:
  var stale=[]
  for p in own:
   if p.current_player_group_command()=="hold" and t-float(last_shot.get(p.participant_id,-100.0))>13.0:stale.append(p.participant_id)
  if not stale.is_empty():released=true;stage("clear",stale,NAN,"Overwatch has lost contact; allow support to reposition");return
 # Bring assault troops into contact, or exploit a numerical opening. No fixed
 # demonstration sequence and no command sent merely to display its icon.
 if pushes<4:
  var movers=[];var x=0.0;var recent=-100.0
  for p in own:
   if p.weapon_type in ["pistol","smg","shotgun"] and p.current_player_group_command().is_empty():
    movers.append(p.participant_id);x+=p.battle_position.x;recent=maxf(recent,float(last_shot.get(p.participant_id,-100.0)))
  if movers.size()>=2:
   x/=movers.size()
   var stalled=t-recent>7.0 and front_enemy-x>16.0
   var advantage=own.size()>=enemy.size()+2 and front_enemy-x>12.0
   if (stalled or advantage) and t>2.0+pushes*18.0:
    var line=minf(front_enemy-5.,x+24.)
    pushes+=1;stage("push",movers,line,"Advance assault element through cover to establish contact" if stalled else "Exploit local numerical advantage");return
