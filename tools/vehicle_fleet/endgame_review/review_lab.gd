extends SceneTree
func _initialize():call_deferred("run")
func run():
 root.size=Vector2i(1152,860);DisplayServer.window_set_size(Vector2i(1152,860))
 var review=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(review)
 await create_timer(.3).timeout
 review.open_vehicle_fleet()
 var panel=review.surface.get_node("VehicleFleet");panel.open_encounter_lab()
 var lab=panel.get_node("EncounterLab");lab.picker.select(7);lab.execute(false);lab.execute(false)
 await create_timer(.2).timeout;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://tools/vehicle_fleet/endgame_review/encounter_lab.png")
 assert(lab.outcome.text.contains("Replacement"))
 print("ENCOUNTER_NATIVE_UI_PASS")
 review.queue_free();await process_frame;quit()
