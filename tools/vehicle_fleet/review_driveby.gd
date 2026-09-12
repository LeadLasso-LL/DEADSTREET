extends SceneTree
var errors=[]
var output="res://tools/vehicle_fleet/driveby_review/"
func _initialize():call_deferred("run")
func capture(name):
 await process_frame;await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(output+name+".png")
func run():
 root.size=Vector2i(1152,860);DisplayServer.window_set_size(Vector2i(1152,860));DirAccess.make_dir_recursive_absolute(output)
 var review=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(review);await create_timer(.4).timeout
 review.open_vehicle_fleet();var panel=review.surface.get_node("VehicleFleet");panel.open_encounter_lab();var lab=panel.get_node("EncounterLab")
 for index in [11,12]:
  lab.scenarios.reset();lab.picker.select(index);lab.execute(false);await capture("driveby_"+str(index))
  lab.execute(false)
  if not lab.outcome.text.contains("Road movement completed"):errors.append("continuation "+str(index))
 panel.queue_free();await process_frame
 review.loadouts.attacker.faction="mercer44";review.loadouts.attacker.vehicles=["revenant","nocturne"]
 await review.start_battle(false);await create_timer(6.).timeout
 var view=review.runtime.get_node("TacticalBattleView");view._dusk_zoom=.82;view._dusk_pan=Vector2.ZERO;view._frame_camera()
 if not view.battle_presentation.last_path_errors.is_empty():errors.append("arrival paths")
 if view._dusk_vehicle_nodes.size()!=2:errors.append("vehicle count")
 await capture("arrival");await create_timer(7.).timeout;await capture("battle")
 var report={"engine":Engine.get_version_info().string,"errors":errors,"scenarios":1,"models":["revenant","nocturne"],"lab_scenarios":2}
 var file=FileAccess.open(output+"report.json",FileAccess.WRITE);file.store_string(JSON.stringify(report,"  "));print("DRIVEBY_NATIVE ",report)
 review.queue_free();await process_frame;quit(0 if errors.is_empty() else 1)
