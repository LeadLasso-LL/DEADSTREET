extends RefCounted
# Deterministic presentation routes. Never changes battle positions, health, or outcome.
const Nav=preload("res://battle/navigation/battle_navigation_service.gd")
const Visual=preload("res://battle/presentation/tactical_participant_visual.gd")
var routes={}
var duration=6.0
var errors=[]
var kind=""
var footsteps={}
func build(b,entrance: Vector2):
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
 var assigned={};var occupied=[];var guard_index=0
 for i in range(winners.size()):
  var p=winners[i];var target=entrance+Vector2(0,.35);var action="enter";var facing=Vector2.UP
  if kind=="check_comrades":
   var best=null;var cost=INF
   for corpse in fallen:
    var score=p.battle_position.distance_to(corpse.battle_position)+float(assigned.get(corpse.participant_id,0))*20.
    if score<cost:best=corpse;cost=score
   assigned[best.participant_id]=int(assigned.get(best.participant_id,0))+1
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
   if selected!=Vector2.INF:target=selected
   else:target=p.battle_position;errors.append(p.participant_id+": no reachable comrade position")
   facing=(best.battle_position-target).normalized();action="kneel";occupied.append(target)
  elif kind=="regroup" and not p.is_wounded:
   # The landing is between the full-height stair walls; face outward down the street.
   target=entrance+Vector2(-1.1+(guard_index%2)*2.2,1.6+floorf(guard_index/2.)*1.9)
   facing=Vector2(-.35+(guard_index%2)*.7,1).normalized();action="guard";guard_index+=1
  if bridge and kind!="check_comrades":
   # Hold reachable individual positions; nobody fades through a nonexistent doorway.
   target=p.battle_position;action="guard";facing=Vector2.RIGHT if winning==b.attacker_side_id else Vector2.LEFT
  var plan=Nav.find_path(b,p.battle_position,target)
  var points: Array[Vector2]=[p.battle_position]
  if plan.success:points.append_array(plan.waypoints)
  else:errors.append(p.participant_id+": blocked outro route");action="guard";target=p.battle_position
  var length=0.
  for n in range(1,points.size()):length+=points[n-1].distance_to(points[n])
  var start=.9+i*.25;var travel=maxf(.25,length/(2.2 if p.is_wounded else 4.2))
  routes[p.participant_id]={"points":points,"start":start,"travel":travel,"length":length,"action":action,"facing":facing,"wounded":p.is_wounded}
  duration=maxf(duration,start+travel+(3.2 if action=="kneel" else 2.0))
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
  var body=node.get_node("body");body.rotation=0.
  var clip="idle"
  if time>=float(r.start) and not arrived:clip="wounded_walk" if r.wounded else "walk"
  elif arrived:
   match r.action:
    "enter":node.modulate.a=1.-smoothstep(0.,.65,time-float(r.start)-float(r.travel));node.visible=node.modulate.a>.01
    "kneel":
     clip="check_comrade"
     # Settle into a kneel and lean toward the fallen teammate.
     body.rotation=0.
    "guard":clip="aim"
  var name=clip+"_"+Visual.implemented_direction_id(facing,"")
  if body.sprite_frames.has_animation(name):
   body.animation=name;body.pause()
   var count=body.sprite_frames.get_frame_count(name)
   body.frame=int(distance/2.7*count)%count if not arrived else (mini(count-1,int((time-float(r.start)-float(r.travel))*10.)) if r.action=="kneel" else 0)
