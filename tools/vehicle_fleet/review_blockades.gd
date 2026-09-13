extends SceneTree
var errors=[]
var output="res://tools/vehicle_fleet/blockade_review/"
func _initialize():call_deferred("run")
func capture(name):
 await process_frame;await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(output+name+".png")
func run():
 root.size=Vector2i(1152,860);DisplayServer.window_set_size(Vector2i(1152,860));DirAccess.make_dir_recursive_absolute(output)
 for index in [13,14]:
  var review=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(review);await create_timer(.35).timeout
  review.open_vehicle_fleet();var panel=review.surface.get_node("VehicleFleet");panel.open_encounter_lab();var lab=panel.get_node("EncounterLab")
  lab.picker.select(index);lab.execute(false);lab.execute(false);await capture("lab_"+str(index))
  if lab.play_button.disabled:errors.append("disabled battle button "+str(index))
  lab.play_button.pressed.emit();await create_timer(6.).timeout
  if review.runtime==null or review.battle==null:errors.append("missing real battle "+str(index))
  else:
   var view=review.runtime.get_node("TacticalBattleView");view._dusk_zoom=1.05;view._dusk_pan=Vector2.ZERO;view._frame_camera()
   if not view.battle_presentation.last_path_errors.is_empty():errors.append("arrival paths "+str(index))
   if index==13 and not review.battle.battlefield_geometry.has_cover_object("roadwarden_screen_0"):errors.append("missing tactical barrier")
   if view._dusk_blockade_nodes.size()!=(2 if index==13 else 0):errors.append("barrier visuals "+str(index))
   await capture("arrival_"+str(index));await create_timer(7.).timeout;await capture("battle_"+str(index))
  review.queue_free();await process_frame
 var report={"engine":Engine.get_version_info().string,"errors":errors,"scenarios":2,"models":["roadwarden","bloodhound"]}
 var f=FileAccess.open(output+"report.json",FileAccess.WRITE);f.store_string(JSON.stringify(report,"  "));print("BLOCKADE_NATIVE ",report);quit(0 if errors.is_empty() else 1)
