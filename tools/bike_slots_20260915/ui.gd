extends SceneTree
var errors=[]
var checks=0
var out="res://tools/bike_slots_20260915/"
func _initialize():call_deferred("run")
func expect(ok: bool,label: String):
 checks+=1
 if not ok:errors.append(label);push_error(label)
func click(control: Control):
 var at=control.get_global_transform_with_canvas()*(control.size*.5)
 var down=InputEventMouseButton.new();down.button_index=MOUSE_BUTTON_LEFT;down.button_mask=MOUSE_BUTTON_MASK_LEFT;down.pressed=true;down.position=at;down.global_position=at;root.push_input(down,true)
 var up=InputEventMouseButton.new();up.button_index=MOUSE_BUTTON_LEFT;up.position=at;up.global_position=at;root.push_input(up,true)
 await process_frame;await process_frame
func shot(name: String):
 for i in range(5):await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(out+name+".png")
func run():
 root.size=Vector2i(1920,1080);DisplayServer.window_set_size(root.size)
 var scene=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(scene)
 for i in range(8):await process_frame
 var menu=scene.menu_panels;var builder=menu.builder
 expect(menu.title_art.texture is AtlasTexture,"Approved title visual loaded")
 expect(menu.title_art.position.y+menu.title_art.size.y<menu.tabs.battle_setup.position.y,"Title above navigation")
 await shot("menu_title")
 builder.config.attacker.faction="mercer";builder.config.attacker.units=[];builder.config.attacker.vehicles=[]
 for i in range(16):builder.config.attacker.units.append(builder.Config.unit())
 builder.changed();builder.open_fleet()
 var fleet=menu.get_node("VehicleFleet")
 await click(fleet.class_buttons.two_wheelers)
 expect(fleet.packing_hint.visible and "Up to 2" in fleet.packing_hint.text,"Default two-wheeler explanation")
 await click(fleet.model_buttons.ironhorse.button);await click(fleet.model_buttons.ironhorse.button)
 expect(fleet.convoy_row.cells[0].get_child_count()>2,"Two images fill first slot")
 expect(fleet.Formation.slots(fleet.selected,"mercer").size()==1,"Two click selections occupy one slot")
 await shot("two_bike_rule")
 for faction in ["stateline","blacktop","zangyaku","bitian","nbpd","trc"]:
  fleet.faction_id=faction;fleet.selected=[];fleet.refresh_models();fleet.refresh_convoy()
  for i in range(3):await process_frame
  expect(fleet.packing_hint.visible and "Up to 4" in fleet.packing_hint.text,"Bonus explanation "+faction)
  for i in range(4):await click(fleet.model_buttons.ironhorse.button)
  expect(fleet.selected==["ironhorse","ironhorse","ironhorse","ironhorse"] and fleet.Formation.slots(fleet.selected,faction).size()==1,"Four clicked bikes in one slot "+faction)
 await shot("four_bike_rule")
 await click(fleet.class_buttons.passenger_cars)
 expect(not fleet.packing_hint.visible,"Explanation hidden outside Two-Wheelers")
 fleet.queue_free();await process_frame
 root.size=Vector2i(1280,720);DisplayServer.window_set_size(root.size)
 await shot("menu_title_1280")
 var result={"checks":checks,"errors":errors}
 FileAccess.open(out+"ui.json",FileAccess.WRITE).store_string(JSON.stringify(result,"\t"));print("BIKE_UI_CHECK ",JSON.stringify(result));quit(0 if errors.is_empty() else 1)
