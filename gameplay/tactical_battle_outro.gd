extends RefCounted
# Deterministic presentation routes. Never changes battle positions, health, or outcome.
const Nav=preload("res://battle/navigation/battle_navigation_service.gd")
const Visual=preload("res://battle/presentation/tactical_participant_visual.gd")
var routes={}
var duration=6.0
var errors=[]
var kind=""
var footsteps={}
func build(b,entrance: Vector2,view=null):
 routes={};errors=[];footsteps={};duration=6.0
 var winners=[];var fallen=[]
 var winning=b.get_winning_side_id()
 for p in b.participants.values():
  if p.side_id!=winning:continue
  if p.is_alive:winners.append(p)
  else:fallen.append(p)
 winners.sort_custom(func(a,c):return a.participant_id<c.participant_id)
 kind="enter_objective" if winning==b.attacker_side_id else ("check_comrades" if not fallen.is_empty() else "regroup")
 var bridge=b.battlefield_geometry.authored_layout_id=="river_suspension_bridge_v1"
 if bridge and winning==b.attacker_side_id:kind="secure_crossing"
 var yard=b.battlefield_geometry.authored_layout_id in ["doble_ocho_yard_v1","freight_exchange_v1"]
 var estate=b.battlefield_geometry.authored_layout_id in ["whittaker_estate_v1","doble_ocho_yard_v1","freight_exchange_v1"]
 if yard and winning==b.attacker_side_id:kind="secure_yard"
 if b.battlefield_geometry.authored_layout_id=="freight_exchange_v1" and winning==b.attacker_side_id:kind="loot_freight"
 var assigned={};var occupied=[];var guard_index=0
 for i in range(winners.size()):
  var p=winners[i];var target=entrance+Vector2(0,.35);var action="enter";var facing=Vector2.UP
  var snapshot={}
  if view!=null and view.actor_presenter._unit_nodes.has(p.participant_id):
   var node=view.actor_presenter._unit_nodes[p.participant_id];var body=node.get_node("body")
   snapshot={"position":node.position,"animation":body.animation,"frame":body.frame,"rotation":body.rotation}
   node.set_meta("outro_owned",true)
  var local_comrade=false
  if estate and winning==b.defender_side_id and not p.is_wounded:
   for corpse in fallen:
    if p.battle_position.distance_to(corpse.battle_position)<=8. and not assigned.has(corpse.participant_id):local_comrade=true;break
  if estate and winning==b.defender_side_id and not local_comrade:
   target=p.battle_position;action="guard";facing=Visual.presentation_facing(b,p)
  elif kind=="check_comrades":
   var best=null;var cost=INF
   for corpse in fallen:
    if estate and (p.battle_position.distance_to(corpse.battle_position)>8. or assigned.has(corpse.participant_id)):continue
    var score=p.battle_position.distance_to(corpse.battle_position)+float(assigned.get(corpse.participant_id,0))*20.
    if score<cost:best=corpse;cost=score
   var candidates=[]
   for angle in [0.,PI,.5*PI,1.5*PI,.25*PI,.75*PI,1.25*PI,1.75*PI]:
    candidates.append(best.battle_position+Vector2(cos(angle),sin(angle))*2.1)
   var nearest=INF;var selected=Vector2.INF
   for point in candidates:
    var crowded=false
    for taken in occupied:
     if point.distance_to(taken)<2.4:crowded=true
    if crowded:continue
    var path=Nav.find_path(b,p.battle_position,point)
    if path.success and p.battle_position.distance_to(point)<nearest:selected=point;nearest=p.battle_position.distance_to(point)
   if selected==Vector2.INF:
    # A fallen teammate can be hemmed in by cover or earlier helpers. Try a
    # wider ring and other teammates before declaring the whole outro blocked.
    # The normal nearest-comrade choice above remains unchanged when reachable.
    var alternatives=fallen.duplicate()
    alternatives.sort_custom(func(a,c):return p.battle_position.distance_to(a.battle_position)+float(assigned.get(a.participant_id,0))*20.<p.battle_position.distance_to(c.battle_position)+float(assigned.get(c.participant_id,0))*20.)
    for corpse in alternatives:
     if estate and (p.battle_position.distance_to(corpse.battle_position)>8. or assigned.has(corpse.participant_id)):continue
     for radius in [2.1,3.3]:
      for n in range(16):
       var point=corpse.battle_position+Vector2.from_angle(float(n)*TAU/16.)*radius
       var crowded=false
       for taken in occupied:
        if point.distance_to(taken)<2.4:crowded=true;break
       if crowded:continue
       var path=Nav.find_path(b,p.battle_position,point)
       if path.success and p.battle_position.distance_to(point)<nearest:selected=point;nearest=p.battle_position.distance_to(point);best=corpse
      if selected!=Vector2.INF:break
     if selected!=Vector2.INF:break
   if selected!=Vector2.INF:
    target=selected
    assigned[best.participant_id]=int(assigned.get(best.participant_id,0))+1
   else:
    target=p.battle_position
    if not estate:errors.append(p.participant_id+": no reachable comrade position")
   facing=(best.battle_position-target).normalized();action="kneel" if selected!=Vector2.INF else "guard";occupied.append(target)
  elif kind=="regroup" and not p.is_wounded:
   # The landing is between the full-height stair walls; face outward down the street.
   target=entrance+Vector2(-1.1+(guard_index%2)*2.2,1.6+floorf(guard_index/2.)*1.9)
   facing=Vector2(-.35+(guard_index%2)*.7,1).normalized();action="guard";guard_index+=1
  if kind=="loot_freight":
   var loot=_freight_loot_target(b,p,occupied)
   if not loot.is_empty():
    target=loot.point;facing=loot.facing;action="loot";occupied.append(target)
   else:
    target=p.battle_position;action="guard";errors.append(p.participant_id+": no reachable freight door")
  elif (bridge or yard) and kind!="check_comrades":
   # Hold reachable individual positions; nobody fades through a nonexistent doorway.
   target=p.battle_position;action="guard";facing=Vector2.RIGHT if winning==b.attacker_side_id else Vector2.LEFT
  var stationary=target.is_equal_approx(p.battle_position)
  var plan=Nav.find_path(b,p.battle_position,target)
  var points: Array[Vector2]=[p.battle_position]
  if plan.success:points.append_array(plan.waypoints)
  else:errors.append(p.participant_id+": blocked outro route");action="guard";target=p.battle_position
  var length=0.
  for n in range(1,points.size()):length+=points[n-1].distance_to(points[n])
  var start=.9+i*.25;var travel=maxf(.25,length/(2.2 if p.is_wounded else 4.2))
  routes[p.participant_id]={"points":points,"start":start,"travel":travel,"length":length,"action":action,"facing":facing,"wounded":p.is_wounded,"snapshot":snapshot,"stationary":stationary}
  # Freight winners can still be walking when results appear; retain the former hold timing.
  duration=maxf(duration,start+.25+2.0 if kind=="loot_freight" else start+travel+(3.2 if action=="kneel" else 2.0))
func _freight_loot_target(b,p,occupied: Array) -> Dictionary:
 var candidates=[]
 for row in preload("res://battle/geometry/freight_exchange_catalog.gd").props():
  if row[2]!="boxcar":continue
  var box: Rect2=row[1]
  for offset in [0.,-2.6,2.6,-5.2,5.2]:
   for side in [-1.,1.]:
    var point=Vector2(box.get_center().x+offset,box.get_center().y+side*(box.size.y*.5+1.8))
    candidates.append({"point":point,"facing":Vector2(0,-side)})
 candidates.sort_custom(func(a,c):return p.battle_position.distance_squared_to(a.point)<p.battle_position.distance_squared_to(c.point))
 for candidate in candidates:
  var crowded=false
  for taken in occupied:
   if candidate.point.distance_to(taken)<2.4:crowded=true;break
  if crowded:continue
  if Nav.find_path(b,p.battle_position,candidate.point).success:return candidate
 return {}
func apply(view,time: float):
 for id in routes:
  if not view.actor_presenter._unit_nodes.has(id):continue
  var node=view.actor_presenter._unit_nodes[id];var r=routes[id]
  var u=clampf((time-float(r.start))/float(r.travel),0.,1.)
  var distance=float(r.length)*u;var remaining=distance
  var point: Vector2=r.points[0];var facing: Vector2=r.facing
  for i in range(1,r.points.size()):
   var a: Vector2=r.points[i-1];var z: Vector2=r.points[i];var length=a.distance_to(z)
   facing=(z-a).normalized()
   if remaining<=length:point=a.lerp(z,remaining/maxf(length,.001));break
   remaining-=length;point=z
  var arrived=time>=float(r.start)+float(r.travel)
  var foot=int(distance/.85)
  if foot>int(footsteps.get(id,0)) and not arrived:
   view.battle_presentation.sound.play("step"+str(absi(id.hash()+foot)%4),point,-23.,foot)
  footsteps[id]=foot
  if arrived:facing=r.facing
  node.position=point*Vector2(8,6);node.visible=true;node.modulate.a=1.
  var snapshot=r.get("snapshot",{})
  if not snapshot.is_empty():
   if bool(r.get("stationary",false)):node.position=snapshot.position
   else:node.position+=(snapshot.position-r.points[0]*Vector2(8,6))*(1.-smoothstep(float(r.start),float(r.start)+.35,time))
  var body=node.get_node("body");body.rotation=0.
  if time<float(r.start) and not snapshot.is_empty():
   body.animation=snapshot.animation;body.pause();body.frame=snapshot.frame;body.rotation=snapshot.rotation
   continue
  var clip="wounded_idle" if r.wounded else "idle"
  if time>=float(r.start) and not arrived:clip="wounded_walk" if r.wounded else "walk"
  elif arrived:
   match r.action:
    "enter":node.modulate.a=1.-smoothstep(0.,.65,time-float(r.start)-float(r.travel));node.visible=node.modulate.a>.01
    "kneel":
     clip="check_comrade"
     # Settle into a kneel and lean toward the fallen teammate.
     body.rotation=0.
    "guard":clip="wounded_idle" if r.wounded else "aim"
  var name=clip+"_"+Visual.implemented_direction_id(facing,"")
  if body.sprite_frames.has_animation(name):
   body.animation=name;body.pause()
   var count=body.sprite_frames.get_frame_count(name)
   body.frame=int(distance/2.7*count)%count if not arrived else (mini(count-1,int((time-float(r.start)-float(r.travel))*10.)) if r.action=="kneel" else 0)
