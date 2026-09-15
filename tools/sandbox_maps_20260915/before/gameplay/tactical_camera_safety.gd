extends Node
# Runs after actor, presentation and HUD updates. Camera only; never moves units.
var view
var last_bounds=Rect2()
var last_safe=Rect2()
var held_position=Vector2.ZERO
var held_zoom=Vector2.ONE
var held_battle=0
var checked_frames=0
var violations=0
func setup(p_view):
 view=p_view;process_priority=1000
func body_world_rect(node) -> Rect2:
 var body=node.get_node_or_null("body")
 if body==null or body.sprite_frames==null:return Rect2(node.global_position-Vector2(12,30),Vector2(24,34))
 var texture=body.sprite_frames.get_frame_texture(body.animation,body.frame)
 if texture==null:return Rect2(node.global_position,Vector2.ONE)
 var size=texture.get_size()
 var box=Rect2(body.offset-(size*.5 if body.centered else Vector2.ZERO),size)
 return body.global_transform*box
func safe_rect() -> Rect2:
 var size=view.get_viewport_rect().size
 var factor=size.x/1152.
 var top=12.*factor;var bottom=size.y-12.*factor
 var hud=view.get_node_or_null("CommandHudLayer")
 if hud!=null and hud.get_child_count()>0:
  var control=hud.get_child(0)
  if control.visible:bottom=minf(bottom,control.surface.get_global_transform_with_canvas().origin.y-10.*factor)
 var p=view.battle_presentation
 if p!=null and p.context.visible:
  var box=p.context.get_global_transform_with_canvas()*Rect2(Vector2.ZERO,p.context.size)
  top=maxf(top,box.end.y+12.*factor)
 return Rect2(Vector2(12.*factor,top),Vector2(size.x-24.*factor,maxf(48.*factor,bottom-top)))
func _process(_delta):
 if view==null or not view.visible or view._camera==null or not view._camera.enabled:return
 var b=view._battle_state()
 if b==null or not view._is_dusk_street():return
 var p=view.battle_presentation
 if p==null:return
 if p.results_visible():
  if held_battle==b.get_instance_id():
   view._camera.position=held_position;view._camera.zoom=held_zoom;view._camera.force_update_scroll()
  return
 var found=false;var bounds=Rect2()
 for id in view.actor_presenter._unit_nodes:
  var unit=b.get_participant(id);var node=view.actor_presenter._unit_nodes[id]
  if unit==null or not unit.is_alive or not node.visible:continue
  var box=body_world_rect(node).grow(5.)
  bounds=bounds.merge(box) if found else box;found=true
 for rider in p.convoy_riders.values():
  if not rider.is_visible_in_tree():continue
  var box=rider.global_transform*Rect2(-18,-28,36,38)
  bounds=bounds.merge(box) if found else box;found=true
 if not found:return
 view._frame_camera()
 var camera=view._camera;var size=view.get_viewport_rect().size;var safe=safe_rect()
 var zoom=minf(camera.zoom.x,minf(safe.size.x/maxf(bounds.size.x,1.),safe.size.y/maxf(bounds.size.y,1.)))
 zoom=maxf(.025,zoom);camera.zoom=Vector2.ONE*zoom
 # Closest valid camera center to the requested pan; zoom only when required.
 var lower=bounds.end-(safe.end-size*.5)/zoom
 var upper=bounds.position-(safe.position-size*.5)/zoom
 camera.position=Vector2(clampf(camera.position.x,lower.x,upper.x),clampf(camera.position.y,lower.y,upper.y))
 camera.force_update_scroll()
 held_position=camera.position;held_zoom=camera.zoom;held_battle=b.get_instance_id()
 p.update_markers()
 last_bounds=bounds;last_safe=safe;checked_frames+=1
 var screen=Rect2((bounds.position-camera.position)*zoom+size*.5,bounds.size*zoom)
 if not safe.grow(.1).encloses(screen):violations+=1
