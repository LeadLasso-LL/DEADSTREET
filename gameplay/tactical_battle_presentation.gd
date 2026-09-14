extends CanvasLayer
# Arrival/outro are visual-only. Canonical deployment and combat remain authoritative.
const Factions=preload("res://gameplay/battle_faction_identity.gd")
const Card=preload("res://gameplay/tactical_unit_card.gd")
const Nav=preload("res://battle/navigation/battle_navigation_service.gd")
const Visual=preload("res://battle/presentation/tactical_participant_visual.gd")
const ROLES=["smg","rifle","pistol","shotgun","sniper"]
var view: Node
var surface: Control
var context: Context
var shade: ColorRect
var start_button: Button
var result_root: Control
var result_cards={}
var markers={}
var sound: Node
var convoy_audio=preload("res://gameplay/tactical_convoy_audio.gd").new()
var convoy_riders={}
var visual_vehicle_poses={}
const Formation=preload("res://campaign/vehicles/convoy_formation_catalog.gd")
var font: SystemFont
var identifiers_enabled=true
var audio_enabled=true
var stage="deployment"
var clock=0.
var end_clock=0.
var ready_clock=0.
var current_battle_id=0
var battle
var attacker={}
var defender={}
var routes={}
var intro_duration=10.
var door_played=false
var start_played=false
var original_zoom=1.3
var original_pan=Vector2.ZERO
var last_path_errors=[]
var result_snapshot={}
var results_acknowledged=false
var continue_button: Button
var deployment_panel: Panel
var arrival_buttons={}
var arrival_status: Label
var outro=preload("res://gameplay/tactical_battle_outro.gd").new()
func setup(p_view):
 view=p_view;layer=35
 surface=Control.new();add_child(surface);surface.mouse_filter=Control.MOUSE_FILTER_IGNORE
 font=SystemFont.new();font.font_names=PackedStringArray(["Arial"]);font.font_weight=600
 shade=ColorRect.new();surface.add_child(shade);shade.color=Color(0.025,.035,.04,0);shade.mouse_filter=Control.MOUSE_FILTER_IGNORE
 context=Context.new();context.owner_presentation=self;surface.add_child(context);context.mouse_filter=Control.MOUSE_FILTER_IGNORE
 start_button=Button.new();surface.add_child(start_button);start_button.text="START BATTLE";start_button.size=Vector2(210,42);start_button.focus_mode=Control.FOCUS_NONE
 start_button.add_theme_font_override("font",font);start_button.add_theme_font_size_override("font_size",16)
 start_button.add_theme_stylebox_override("normal",Card.style(Color("#314b3d"),Color("#86a98a")))
 start_button.pressed.connect(func():view.get_parent().begin_current_battle())
 deployment_panel=Panel.new();surface.add_child(deployment_panel);deployment_panel.position=Vector2(18,18);deployment_panel.size=Vector2(372,151)
 deployment_panel.add_theme_stylebox_override("panel",Card.style(Color("#111b20"),Color("#59695f")))
 Card.label(deployment_panel,Vector2(14,8),Vector2(340,18),"ARRIVAL DISTANCE",11,Color("#c9d2c4"),font)
 var index=0
 for choice in ["close","medium","far"]:
  var button=Button.new();deployment_panel.add_child(button);button.text=choice.to_upper();button.position=Vector2(14+index*116,31);button.size=Vector2(108,28);button.toggle_mode=true;button.focus_mode=Control.FOCUS_NONE
  button.pressed.connect(func():view.deployment_controller.choose_arrival(choice))
  arrival_buttons[choice]=button;index+=1
 var auto_button=Button.new();deployment_panel.add_child(auto_button);auto_button.text="AUTO COVER";auto_button.position=Vector2(14,108);auto_button.size=Vector2(166,28);auto_button.focus_mode=Control.FOCUS_NONE
 auto_button.pressed.connect(func():view.deployment_controller.place_unplaced_in_cover())
 var deploy_button=Button.new();deployment_panel.add_child(deploy_button);deploy_button.text="CONFIRM DEPLOYMENT";deploy_button.position=Vector2(190,108);deploy_button.size=Vector2(168,28);deploy_button.focus_mode=Control.FOCUS_NONE
 deploy_button.pressed.connect(func():
  if view.deployment_controller.place_unplaced_in_cover():view.deployment_controller.try_commit_attacker()
 )
 arrival_status=Card.label(deployment_panel,Vector2(14,68),Vector2(344,32),"",10,Color("#a6b1a5"),font)
 sound=preload("res://gameplay/tactical_battle_audio.gd").new();view.add_child(sound);sound.setup(view);convoy_audio.setup(view)
func reset(b):
 for rider in convoy_riders.values():
  if is_instance_valid(rider):rider.queue_free()
 convoy_riders.clear();visual_vehicle_poses.clear()
 sound.results_music_mix=0.
 battle=b;current_battle_id=b.get_instance_id();stage="deployment";clock=0.;end_clock=0.;intro_duration=10.;routes={};door_played=false;start_played=false;ready_clock=0.;result_snapshot={};results_acknowledged=false
 attacker=Factions.for_side(b,b.attacker_side_id);defender=Factions.for_side(b,b.defender_side_id)
 for marker in markers.values():marker.queue_free()
 markers.clear()
 if result_root!=null:result_root.queue_free();result_root=null
 result_cards={}
func all_committed() -> bool:
 return battle.is_side_deployment_committed(battle.attacker_side_id) and battle.is_side_deployment_committed(battle.defender_side_id)
func is_arriving() -> bool:return stage=="arrival"
func can_start() -> bool:return stage=="ready" or stage=="active"
func results_visible() -> bool:return stage=="ending" and end_clock>=outro.duration
func skip_to_ready():
 if battle==null and view._battle_state()!=null:reset(view._battle_state())
 stage="ready";clock=intro_duration;routes={};apply_poses()
func is_bridge() -> bool:return battle!=null and battle.battlefield_geometry.authored_layout_id=="river_suspension_bridge_v1"
func begin_arrival():
 stage="arrival";clock=0.;routes={};last_path_errors=[];original_zoom=view._dusk_zoom;original_pan=view._dusk_pan
 if view.deployment_controller!=null:view.deployment_controller.apply_pending_cover_to_live()
 var arrival=arrival_center()
 for v in battle.vehicles.values():
  if v.side_id==battle.attacker_side_id:arrival=v.battle_position;break
 var counts={battle.attacker_side_id:0,battle.defender_side_id:0}
 var ids=battle.participants.keys();ids.sort()
 for id in ids:
  var p=battle.get_participant(id);var n=int(counts[p.side_id]);counts[p.side_id]=n+1
  var attacking=p.side_id==battle.attacker_side_id
  var origin=arrival+Vector2(-.35 if n<2 else 1.05,1.95 if n%2==0 else -1.95) if attacking else Vector2(25.,15.3)
  if is_bridge() and not attacking:origin=p.battle_position
  var planned=Nav.find_path(battle,origin,p.battle_position)
  if attacking and not p.transport_vehicle_id.is_empty():
   var vehicle=battle.get_vehicle(p.transport_vehicle_id)
   var exit=preload("res://battle/vehicles/battle_vehicle_exit_service.gd").route(battle,vehicle,p.battle_position,bool(p.get_meta("transport_bed",false)))
   if not exit.is_empty():origin=exit.origin;planned=exit.path
   else:planned=null
  var points: Array[Vector2]=[origin]
  if planned!=null and planned.success:
   points.append_array(planned.waypoints)
  else:
   # Keep an invalid route stationary rather than walking through scenery.
   points=[p.battle_position];last_path_errors.append(id)
  var length=0.
  for i in range(1,points.size()):length+=points[i-1].distance_to(points[i])
  var start=5.8+n*.35 if attacking else (0. if is_bridge() else 3.4+n*.45)
  if attacking:
   var transport=battle.get_vehicle(p.transport_vehicle_id)
   start=vehicle_stop_time(transport)+.7+float(p.get_meta("transport_seat",n))*.52
  var duration=maxf(.35,length/5.0)
  routes[id]={"points":points,"length":length,"start":start,"duration":duration,"attacking":attacking,"distance":0.}
  intro_duration=maxf(intro_duration,start+duration+.6)
 prepare_riders()
func _process(delta):
 if view==null:return
 var b=view._battle_state();visible=view.visible and view._is_dusk_street() and b!=null
 sound.enabled=visible and audio_enabled
 if not visible:
  convoy_audio.sync(b,{},false,0.,0.)
  return
 if current_battle_id!=b.get_instance_id():reset(b)
 var size=view.get_viewport_rect().size;var factor=size.x/1152.;surface.scale=Vector2.ONE*factor;surface.size=size/factor;shade.size=surface.size
 deployment_panel.visible=stage=="deployment" and not all_committed()
 for choice in arrival_buttons:
  arrival_buttons[choice].visible=not is_bridge()
  arrival_buttons[choice].set_pressed_no_signal(b.arrival_choice==choice)
  arrival_buttons[choice].disabled=b.is_side_deployment_committed(b.attacker_side_id)
 arrival_status.text={"close":"Closer contact. Less room before the first exchange.","medium":"Balanced approach with nearby street cover.","far":"More space to organize. A longer advance to contact."}.get(b.arrival_choice,"")
 if is_bridge():arrival_status.text="WEST APPROACH / Convoy stops behind the traffic queue."
 if stage=="deployment" and b.battle_phase=="deployment" and all_committed():begin_arrival()
 if b.battle_phase=="active" and stage!="active":
  stage="active";routes={};sound.set_engine(Vector2.ZERO,false)
  if not start_played:sound.play("start",Vector2(32,28),-19.);start_played=true
 if b.battle_phase=="resolved" and stage!="ending":
  stage="ending";end_clock=0.;original_zoom=view._dusk_zoom;original_pan=view._dusk_pan;build_results();outro.build(battle,Vector2(170,28) if is_bridge() else preload("res://battle/geometry/harold_street_catalog.gd").OBJECTIVE_ENTRANCE)
 if stage=="arrival":
  clock+=delta
  if clock>=6.6 and not door_played:
   door_played=true
   for transport in battle.vehicles.values():
    if int(preload("res://campaign/vehicles/vehicle_model_catalog.gd").model(transport.vehicle_type_id).get("doors",4))>0:
     sound.play("door",arrival_center(),-11.);break
  if clock>=intro_duration:stage="ready";ready_clock=0.;sound.set_engine(Vector2.ZERO,false)
 elif stage=="ready":ready_clock+=delta
 elif stage=="ending":
  end_clock+=delta
  var u=smoothstep(0.,5.,end_clock);view._dusk_zoom=lerpf(original_zoom,original_zoom*.94,u);view._dusk_pan=original_pan.lerp(original_pan+Vector2(0,-5),u);view._frame_camera()
  if end_clock>.75:b.combat_feedback_events.clear()
  result_root.modulate.a=smoothstep(outro.duration,outro.duration+1.2,end_clock)
  continue_button.disabled=end_clock<outro.duration+1.2
 # Match the result card fade; the comrade/entry animation retains the normal mix.
 sound.results_music_mix=smoothstep(outro.duration,outro.duration+1.2,end_clock) if stage=="ending" else 0.
 var expand=1.-smoothstep(2.6,4.4,clock) if stage=="arrival" else 0.
 context.expansion=expand;context.position=Vector2(18,18).lerp(Vector2(56,150),expand);context.size=Vector2(476,78).lerp(Vector2(1040,210),expand)
 context.visible=stage!="deployment";context.queue_redraw()
 shade.color.a=.20*expand if stage=="arrival" else (.57*smoothstep(outro.duration,outro.duration+1.2,end_clock) if stage=="ending" else 0.)
 start_button.visible=stage=="ready";start_button.position=Vector2(471,surface.size.y-70)
 if result_root!=null:result_root.position=Vector2(56,118);result_root.visible=results_visible()
 apply_poses();update_markers()
func convoy_radio_battle_mix() -> float:
 # The convoy radio recedes during the final two arrival seconds, before combat.
 # Keep that quieter mix throughout ready/combat/outro, independent of camera motion.
 if stage=="arrival":return smoothstep(maxf(0.,intro_duration-2.),intro_duration,clock)
 return 1.0 if stage in ["ready","active","ending"] else 0.0
func apply_poses():
 if view==null or battle==null:return
 visual_vehicle_poses.clear()
 var engine_set=false
 for id in view._dusk_vehicle_nodes:
  var node=view._dusk_vehicle_nodes[id];var v=battle.get_vehicle(id)
  if v==null:continue
  node.door_open=1.;node.visible=true
  var at=v.battle_position
  if stage in ["arrival","ready"] and (not is_bridge() or v.side_id==battle.attacker_side_id):
   var stop=vehicle_stop_time(v);var progress=smoothstep(1.6,stop,clock)
   var offset=Vector2((1.-progress)*55.*(-1. if is_bridge() else 1.),0)
   at+=offset;node.position=at*Vector2(8,6)
   node.door_open=smoothstep(stop+.05,stop+.65,clock)
   if stage=="arrival" and v.vehicle_type_id!="yardbird" and not engine_set:
    sound.set_engine(at,clock>1.5 and clock<stop+.8,lerpf(1.35,.75,progress));engine_set=true
  visual_vehicle_poses[id]=at
  node.queue_redraw()
 convoy_audio.sync(battle,visual_vehicle_poses,audio_enabled and visible,sound.gun_duck,sound.results_music_mix,convoy_radio_battle_mix())
 for id in convoy_riders:
  var rider=convoy_riders[id];var route=routes.get(id,{})
  rider.visible=stage=="arrival" and not route.is_empty() and clock<float(route.start)-.65
  rider.phase=clock;rider.riding=clock<6.5;rider.queue_redraw()
 if stage=="ending":
  outro.apply(view,end_clock)
  return
 if stage!="arrival":
  for node in view.actor_presenter._unit_nodes.values():node.visible=true
  return
 for id in routes:
  if not view.actor_presenter._unit_nodes.has(id):continue
  var node=view.actor_presenter._unit_nodes[id];var route=routes[id];var p=battle.get_participant(id)
  var dismount_start=float(route.start)-.65
  node.visible=clock>=dismount_start
  if bool(route.attacking) and clock>=dismount_start and clock<float(route.start):
   var vehicle=battle.get_vehicle(p.transport_vehicle_id)
   if vehicle!=null:
    var t=clampf((clock-dismount_start)/.65,0.,1.)
    var origin: Vector2=route.points[0]*Vector2(8,6)
    var anchor=visual_vehicle_poses.get(vehicle.battle_vehicle_id,vehicle.battle_position)*Vector2(8,6)
    if convoy_riders.has(id):anchor+=convoy_riders[id].position+Vector2(0,9.)
    else:anchor=origin+Vector2(-3.,-1.)
    node.position=anchor.lerp(origin,smoothstep(0.,1.,t));node.position.y-=sin(t*PI)*2.
    var body=node.get_node("body");var dir=Visual.implemented_direction_id(vehicle.facing_direction,"")
    var clip=("cover_tucked_idle_" if t<.55 else "walk_")+dir
    if body.sprite_frames.has_animation(clip):body.animation=clip;body.pause();body.frame=0
    continue
  var progress=clampf((clock-float(route.start))/float(route.duration),0.,1.)
  if progress>=1.:continue
  var target_distance=float(route.length)*progress
  var point: Vector2=route.points[0];var direction=Vector2.DOWN
  var remaining=target_distance
  for i in range(1,route.points.size()):
   var a: Vector2=route.points[i-1];var z: Vector2=route.points[i];var length=a.distance_to(z)
   direction=(z-a).normalized()
   if remaining<=length:point=a.lerp(z,remaining/maxf(length,.001));break
   remaining-=length;point=z
  node.position=point*Vector2(8,6)
  var body=node.get_node("body");var dir=Visual.implemented_direction_id(direction,"")
  var clip=("walk_" if clock>=float(route.start) else "idle_")+dir
  if body.sprite_frames.has_animation(clip):
   body.animation=clip;body.pause();body.frame=int(target_distance/2.7*body.sprite_frames.get_frame_count(clip))%body.sprite_frames.get_frame_count(clip)
  if target_distance-float(route.distance)>.85:
   route.distance=target_distance;sound.play("step"+str(sound.cursor%4),point,-22.,sound.cursor)
func vehicle_stop_time(vehicle) -> float:
 return 6.5+float(vehicle.get_meta("convoy_slot",0))*.18 if vehicle!=null else 6.5
func prepare_riders():
 for id in routes:
  var p=battle.get_participant(id)
  if p.side_id!=battle.attacker_side_id:continue
  var v=battle.get_vehicle(p.transport_vehicle_id)
  if v==null or not view._dusk_vehicle_nodes.has(v.battle_vehicle_id) or not view.actor_presenter._unit_nodes.has(id):continue
  var bike=Formation.motorcycle(v.vehicle_type_id);var bed=bool(p.get_meta("transport_bed",false))
  if not bike and not bed:continue
  var rider=preload("res://gameplay/tactical_convoy_rider.gd").new()
  view._dusk_vehicle_nodes[v.battle_vehicle_id].add_child(rider)
  var seat=int(p.get_meta("transport_seat",0))
  rider.setup(view.actor_presenter._unit_nodes[id].get_node("body"),bike and seat>0,bed)
  rider.heading=1. if v.facing_direction.x>=0. else -1.
  if bed:
   var bed_index=0
   for previous in convoy_riders:
    var q=battle.get_participant(previous)
    if q.transport_vehicle_id==p.transport_vehicle_id and q.get_meta("transport_bed",false):bed_index+=1
   rider.position=Vector2(-28.8+bed_index*9.6,-16.+bed_index*4.5)
  else:rider.position=Vector2(-5.4 if seat>0 else 1.3,-8.)
  rider.position.x*=rider.heading;rider.visible=false;convoy_riders[id]=rider
func update_markers():
 for p in battle.participants.values():
  var id=p.participant_id
  if not view.actor_presenter._unit_nodes.has(id):continue
  var node=view.actor_presenter._unit_nodes[id]
  if not markers.has(id):
   var badge=preload("res://gameplay/tactical_emblem_marker.gd").new();surface.add_child(badge)
   badge.emblem.texture=Factions.for_side(battle,p.side_id).emblem;Factions.style_emblem(badge.emblem);markers[id]=badge
  var badge=markers[id];badge.visible=identifiers_enabled and p.is_alive and node.visible and stage!="deployment" and not results_visible()
  badge.set_selected(view.orders_controller!=null and view.orders_controller.is_selected(id))
  var lift=-26. if p.is_alive else -8.
  if p.is_alive and (p.has_occupied_cover_slot() or p.is_wounded):lift=-19.
  var at=node.get_global_transform_with_canvas()*Vector2(0,lift)
  badge.position=at/surface.scale.x-Vector2(8,17);badge.size=Vector2(16,16);badge.modulate.a=1. if p.is_alive else .55
func build_results():
 result_root=Control.new();surface.add_child(result_root);result_root.mouse_filter=Control.MOUSE_FILTER_IGNORE;result_root.modulate.a=0.
 var winner=battle.get_winning_side_id()
 for column in range(2):
  var faction=attacker if column==0 else defender;var side: String=faction.side
  var win=side==winner;var color=Color("#8abb91") if win else Color("#d26d75")
  var panel=Panel.new();result_root.add_child(panel);panel.position=Vector2(column*532,0);panel.size=Vector2(508,390);panel.add_theme_stylebox_override("panel",Card.style(Color("#111b20"),Color("#465c50") if win else Color("#64444c")))
  var emblem=TextureRect.new();panel.add_child(emblem);emblem.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;emblem.texture=faction.emblem;emblem.position=Vector2(24,20);emblem.size=Vector2(62,62);emblem.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS;Factions.style_emblem(emblem)
  var title_points=22
  while title_points>10 and font.get_string_size(faction.name,HORIZONTAL_ALIGNMENT_LEFT,-1,title_points).x>382:title_points-=1
  Card.label(panel,Vector2(104,23),Vector2(382,27),faction.name,title_points,Color("#e1e1d5"),font)
  Card.label(panel,Vector2(104,55),Vector2(375,24),"VICTORY" if win else ("DEFEAT" if not winner.is_empty() else "DRAW"),16,color,font)
  var units=[]
  for p in battle.participants.values():
   if p.side_id==side:units.append(p)
  units.sort_custom(func(a,b):return ROLES.find(a.weapon_type)<ROLES.find(b.weapon_type))
  result_snapshot[side]=[]
  var scroll=ScrollContainer.new();panel.add_child(scroll);scroll.position=Vector2(16,102);scroll.size=Vector2(476,272);scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
  var grid=GridContainer.new();scroll.add_child(grid);grid.columns=3 if units.size()>4 else 2;grid.add_theme_constant_override("h_separation",10);grid.add_theme_constant_override("v_separation",10)
  for i in range(units.size()):
   var holder=Control.new();grid.add_child(holder);holder.custom_minimum_size=Vector2(144,126)
   var card=Card.build(holder,Vector2.ZERO,font);Card.update(card,units[i],"",false);result_cards[units[i].participant_id]=card
   result_snapshot[side].append({"id":units[i].participant_id,"state":card.status.text,"health_width":card.health.size.x,"role":card.role.text,"weapon":card.gun.text,"tint":str(card.portrait.modulate)})
 var done=Button.new();result_root.add_child(done);done.text="CONTINUE";done.position=Vector2(426,410);done.size=Vector2(188,36);done.focus_mode=Control.FOCUS_NONE
 done.add_theme_font_override("font",font);done.add_theme_font_size_override("font_size",12);done.add_theme_stylebox_override("normal",Card.style(Color("#273a32"),Color("#77927c")))
 done.pressed.connect(func():
  results_acknowledged=true
  var session=view.get_parent().get_current_session()
  if session!=null:session.result_presentation_elapsed_seconds=maxf(session.result_presentation_elapsed_seconds,end_clock)
 )
 continue_button=done
class Context extends Control:
 var owner_presentation
 var expansion=0.
 func _draw():
  var p=owner_presentation
  if p.attacker.is_empty():return
  var t=expansion
  draw_style_box(Card.style(Color(.055,.082,.094,.95),Color("#6c705e")),Rect2(Vector2.ZERO,size))
  var left=Rect2(Vector2(10,27).lerp(Vector2(30,53),t),Vector2(42,42).lerp(Vector2(104,104),t))
  var right=Rect2(Vector2(294,27).lerp(Vector2(650,53),t),Vector2(42,42).lerp(Vector2(104,104),t))
  if p.attacker.emblem!=null:draw_emblem(p.attacker.emblem,left)
  if p.defender.emblem!=null:draw_emblem(p.defender.emblem,right)
  var ink=Color("#e3e1d3");var muted=Color("#a6b1a5")
  draw_string(p.font,Vector2(12,17).lerp(Vector2(30,29),t),("RIVER CROSSING  /  SUSPENSION BRIDGE" if p.is_bridge() else "MERCER HEIGHTS  /  HAROLD AVE."),HORIZONTAL_ALIGNMENT_LEFT,-1,int(lerpf(10,14,t)),muted)
  draw_string(p.font,Vector2(60,45).lerp(Vector2(155,90),t),str(p.attacker.get("short_name",p.attacker.name)),HORIZONTAL_ALIGNMENT_LEFT,-1,title_size(p,str(p.attacker.get("short_name",p.attacker.name)),t,155.),ink)
  draw_string(p.font,Vector2(343,45).lerp(Vector2(775,90),t),str(p.defender.get("short_name",p.defender.name)),HORIZONTAL_ALIGNMENT_LEFT,-1,title_size(p,str(p.defender.get("short_name",p.defender.name)),t,126.),ink)
  draw_string(p.font,Vector2(60,65).lerp(Vector2(155,117),t),"ATTACKING",HORIZONTAL_ALIGNMENT_LEFT,-1,int(lerpf(8,11,t)),muted)
  draw_string(p.font,Vector2(343,65).lerp(Vector2(775,117),t),"DEFENDING",HORIZONTAL_ALIGNMENT_LEFT,-1,int(lerpf(8,11,t)),muted)
  var location="ROAD BLOCKADE" if p.is_bridge() else "HAROLD APARTMENTS"
  var location_size=int(lerpf(8,12,t))
  var location_width=p.font.get_string_size(location,HORIZONTAL_ALIGNMENT_LEFT,-1,location_size).x
  draw_string(p.font,Vector2(size.x-lerpf(12.,30.,t)-location_width,lerpf(17.,29.,t)),location,HORIZONTAL_ALIGNMENT_LEFT,-1,location_size,muted)


 func draw_emblem(texture: Texture2D,area: Rect2) -> void:
  var points=PackedVector2Array();var uvs=PackedVector2Array()
  for i in range(64):
   var normal=Vector2.from_angle(float(i)*TAU/64.)
   points.append(area.get_center()+normal*area.size*.5)
   uvs.append(Vector2(.5,.5)+normal*.5)
  draw_polygon(points,PackedColorArray([Color.WHITE]),uvs,texture)
 func title_size(p,title: String,t: float,compact_width: float) -> int:
  var points: int=int(lerpf(12,23,t));var width: float=lerpf(compact_width,390.,t)
  while points>8 and p.font.get_string_size(title,HORIZONTAL_ALIGNMENT_LEFT,-1,points).x>width:points-=1
  return points

func arrival_center() -> Vector2:
 if battle!=null:
  for v in battle.vehicles.values():
   if v.side_id==battle.attacker_side_id:return v.battle_position
 return Vector2(49,28)
