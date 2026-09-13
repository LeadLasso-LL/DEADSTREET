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
 sound=preload("res://gameplay/tactical_battle_audio.gd").new();view.add_child(sound);sound.setup(view)
func reset(b):
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
  var planned=Nav.find_path(battle,origin,p.battle_position)
  if attacking and not p.transport_vehicle_id.is_empty():
   var vehicle=battle.get_vehicle(p.transport_vehicle_id)
   var exit=preload("res://battle/vehicles/battle_vehicle_exit_service.gd").route(battle,vehicle,p.battle_position)
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
  var start=5.8+n*.35 if attacking else 3.4+n*.45
  var duration=maxf(.35,length/5.0)
  routes[id]={"points":points,"length":length,"start":start,"duration":duration,"attacking":attacking,"distance":0.}
  intro_duration=maxf(intro_duration,start+duration+.6)
func _process(delta):
 if view==null:return
 var b=view._battle_state();visible=view.visible and view._is_dusk_street() and b!=null
 sound.enabled=visible and audio_enabled
 if not visible:return
 if current_battle_id!=b.get_instance_id():reset(b)
 var size=view.get_viewport_rect().size;var factor=size.x/1152.;surface.scale=Vector2.ONE*factor;surface.size=size/factor;shade.size=surface.size
 deployment_panel.visible=stage=="deployment" and not all_committed()
 for choice in arrival_buttons:
  arrival_buttons[choice].set_pressed_no_signal(b.arrival_choice==choice)
  arrival_buttons[choice].disabled=b.is_side_deployment_committed(b.attacker_side_id)
 arrival_status.text={"close":"Closer contact. Less room before the first exchange.","medium":"Balanced approach with nearby street cover.","far":"More space to organize. A longer advance to contact."}.get(b.arrival_choice,"")
 if stage=="deployment" and b.battle_phase=="deployment" and all_committed():begin_arrival()
 if b.battle_phase=="active" and stage!="active":
  stage="active";routes={};sound.set_engine(Vector2.ZERO,false)
  if not start_played:sound.play("start",Vector2(32,28),-19.);start_played=true
 if b.battle_phase=="resolved" and stage!="ending":
  stage="ending";end_clock=0.;original_zoom=view._dusk_zoom;original_pan=view._dusk_pan;build_results();outro.build(battle,preload("res://battle/geometry/harold_street_catalog.gd").OBJECTIVE_ENTRANCE)
 if stage=="arrival":
  clock+=delta
  if clock>=5.4 and not door_played:
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
func apply_poses():
 if view==null or battle==null:return
 for id in view._dusk_vehicle_nodes:
  var node=view._dusk_vehicle_nodes[id];var v=battle.get_vehicle(id)
  if v==null:continue
  node.door_open=1.;node.visible=true
  if stage in ["arrival","ready"] and str(preload("res://campaign/vehicles/vehicle_model_catalog.gd").model(v.vehicle_type_id).get("vehicle_class",""))!="two_wheelers":
   var progress=smoothstep(2.2,5.3,clock)
   var offset=Vector2((1.-progress)*38*8,0)
   var visual_bounds: Rect2=node.prop[1];visual_bounds.position.x+=offset.x/8.;node.prop[1]=visual_bounds
   node.position+=offset;node.door_open=smoothstep(5.35,5.9,clock)
   if stage=="arrival" and v.vehicle_type_id!="yardbird":sound.set_engine(v.battle_position+Vector2(offset.x/8,0),clock>2.1 and clock<5.85,lerpf(1.35,.75,progress))
  node.queue_redraw()
 if stage=="ending":
  outro.apply(view,end_clock)
  return
 if stage!="arrival":
  for node in view.actor_presenter._unit_nodes.values():node.visible=true
  return
 for id in routes:
  if not view.actor_presenter._unit_nodes.has(id):continue
  var node=view.actor_presenter._unit_nodes[id];var route=routes[id];var p=battle.get_participant(id)
  node.visible=clock>=float(route.start)
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
func update_markers():
 for p in battle.participants.values():
  var id=p.participant_id
  if not view.actor_presenter._unit_nodes.has(id):continue
  var node=view.actor_presenter._unit_nodes[id]
  if not markers.has(id):
   var badge=TextureRect.new();surface.add_child(badge);badge.mouse_filter=Control.MOUSE_FILTER_IGNORE;badge.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;badge.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
   badge.texture=Factions.for_side(battle,p.side_id).emblem;Factions.style_emblem(badge);markers[id]=badge
  var badge=markers[id];badge.visible=identifiers_enabled and p.is_alive and node.visible and stage!="deployment" and not results_visible()
  var lift=-29. if p.is_alive else -8.
  if p.is_alive and (p.has_occupied_cover_slot() or p.is_wounded):lift=-21.
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
  draw_string(p.font,Vector2(12,17).lerp(Vector2(30,29),t),"MERCER HEIGHTS  /  HAROLD AVE.",HORIZONTAL_ALIGNMENT_LEFT,-1,int(lerpf(10,14,t)),muted)
  draw_string(p.font,Vector2(60,45).lerp(Vector2(155,90),t),str(p.attacker.get("short_name",p.attacker.name)),HORIZONTAL_ALIGNMENT_LEFT,-1,title_size(p,str(p.attacker.get("short_name",p.attacker.name)),t,155.),ink)
  draw_string(p.font,Vector2(343,45).lerp(Vector2(775,90),t),str(p.defender.get("short_name",p.defender.name)),HORIZONTAL_ALIGNMENT_LEFT,-1,title_size(p,str(p.defender.get("short_name",p.defender.name)),t,126.),ink)
  draw_string(p.font,Vector2(60,65).lerp(Vector2(155,147),t),"HAROLD APARTMENTS",HORIZONTAL_ALIGNMENT_LEFT,-1,int(lerpf(10,17,t)),muted)
  draw_string(p.font,Vector2(343,65).lerp(Vector2(775,117),t),"DEFENDING",HORIZONTAL_ALIGNMENT_LEFT,-1,int(lerpf(8,11,t)),muted)
  draw_string(p.font,Vector2(219,45).lerp(Vector2(155,117),t),"ATTACKING",HORIZONTAL_ALIGNMENT_LEFT,-1,int(lerpf(8,11,t)),muted)

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
