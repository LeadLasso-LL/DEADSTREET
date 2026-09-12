extends SceneTree
var errors=[]
func _initialize():call_deferred("run")
func check(ok,message):
 if not ok:errors.append(message)
func run():
 root.size=Vector2i(1152,860)
 var panel=load("res://gameplay/vehicle_fleet_panel.gd").new();panel.faction_id="trc";root.add_child(panel)
 await process_frame;await process_frame
 for pair in [["two_wheelers",12],["passenger_cars",19],["utility_vehicles",13],["heavy_transports",16]]:
  panel.class_buttons[pair[0]].pressed.emit();await process_frame
  check(panel.selected_class==pair[0],"class button capture "+pair[0])
  check(panel.grid.get_child_count()==pair[1],"model count "+pair[0])
 panel.selected=[];panel.refresh_convoy();check(panel.apply_button.disabled,"empty convoy rejected")
 panel.class_buttons["two_wheelers"].pressed.emit();await process_frame
 for i in range(2):panel.grid.get_child(i).get_child(0).get_children().back().pressed.emit()
 check(panel.selected==["yardbird","putter"],"add button captures actual model")
 check(panel.apply_button.disabled,"two single seats insufficient")
 panel.class_buttons["heavy_transports"].pressed.emit();await process_frame
 panel.grid.get_child(1).get_child(0).get_children().back().pressed.emit()
 check(not panel.apply_button.disabled,"mixed convoy accepted")
 panel.convoy_row.get_child(0).pressed.emit();await process_frame
 check(panel.selected==["putter","shuttle"],"remove correct model")
 panel.preferred.button_pressed=true;await process_frame
 check(panel.grid.get_child_count()==3,"TRC suggestions filter")
 check(panel.selected==["putter","shuttle"],"preferences do not restrict selected fleet")
 print("FLEET_PANEL ",errors)
 panel.queue_free();await process_frame
 quit(0 if errors.is_empty() else 1)
