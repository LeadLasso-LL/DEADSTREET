extends SceneTree
var errors=[]
var checks=0
func _initialize():call_deferred("run")
func expect(ok: bool,label_value: String):
 checks+=1
 if not ok:errors.append(label_value);push_error(label_value)
func click(control: Control):
 var at=control.get_global_transform_with_canvas()*(control.size*.5)
 var motion=InputEventMouseMotion.new();motion.position=at;motion.global_position=at;root.push_input(motion,true)
 var down=InputEventMouseButton.new();down.button_index=MOUSE_BUTTON_LEFT;down.pressed=true;down.button_mask=MOUSE_BUTTON_MASK_LEFT;down.position=at;down.global_position=at;root.push_input(down,true)
 var up=InputEventMouseButton.new();up.button_index=MOUSE_BUTTON_LEFT;up.position=at;up.global_position=at;root.push_input(up,true)
 await process_frame;await process_frame
func run():
 root.size=Vector2i(1920,1080);DisplayServer.window_set_size(root.size)
 var scene=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(scene)
 for i in range(8):await process_frame
 var menu=scene.menu_panels;var builder=menu.builder
 for id in ["doble_ocho","river_bridge","whittaker_estate","harold"]:
  await click(builder.map_selector.choices[id].button)
  expect(builder.config.map_id==id,"Mouse selects map "+id)
  expect(builder.map_selector.hero.texture!=null,"Native thumbnail "+id)
  expect(builder.map_option.selected==builder.Maps.IDS.find(id),"Dropdown synchronized "+id)
 builder.config.attacker.units[0].tier=3;builder.changed()
 await click(menu.tabs.factions);expect(menu.active_tab=="factions","Faction tab")
 await click(menu.tabs.arsenal);expect(menu.active_tab=="arsenal","Arsenal tab")
 await click(menu.tabs.vehicles);expect(menu.active_tab=="vehicles","Vehicles tab")
 await click(menu.tabs.battle_setup);expect(builder.config.attacker.units[0].tier==3,"Tab switch preserves loadout")
 await click(builder.convoy_strips.attacker.edit)
 expect(menu.has_node("VehicleFleet"),"Mouse opens convoy")
 if not menu.has_node("VehicleFleet"):
  FileAccess.open("res://tools/sandbox_maps_20260915/clicks.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"errors":errors}));quit(1);return
 var fleet=menu.get_node("VehicleFleet")
 fleet.selected=[];fleet.refresh_convoy()
 var id="bayou"
 await click(fleet.model_buttons[id].button);expect(fleet.selected==[id],"Image click adds vehicle")
 await click(fleet.model_buttons[id].button);expect(fleet.selected.size()==2,"Second image click")
 await click(fleet.apply_button);expect(not is_instance_valid(fleet),"Apply closes picker")
 expect(builder.config.attacker.vehicles==[id,id],"Apply saves convoy")
 await click(builder.start_button)
 for i in range(10):await process_frame
 expect(scene.battle!=null,"Mouse starts selected battle")
 scene.return_to_setup();await process_frame
 expect(builder.config.attacker.units[0].tier==3,"Battle return preserves edited tier")
 var result={"checks":checks,"errors":errors}
 FileAccess.open("res://tools/sandbox_maps_20260915/clicks.json",FileAccess.WRITE).store_string(JSON.stringify(result,"\t"));print("MOUSE_CHECK ",JSON.stringify(result));quit(0 if errors.is_empty() else 1)
