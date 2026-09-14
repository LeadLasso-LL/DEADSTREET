extends SceneTree
const OUT="C:/Users/brand/OneDrive/Documents/dead-street/tools/sandbox_glossaries_20260914/"
const Factions=preload("res://battle/identity/faction_unit_catalog.gd")
const Weapons=preload("res://battle/combat/battle_weapon_catalog.gd")
const Vehicles=preload("res://campaign/vehicles/vehicle_model_catalog.gd")
var scene
var menu
var checks=0
var errors=[]
var fast=false
var preview_end_seconds=0.0
func _initialize():call_deferred("run")
func check(ok: bool, message: String):
	checks+=1
	if not ok:errors.append(message);printerr("GLOSSARY_FAIL ",message)
func frames(count: int):
	for i in range(count):await process_frame
func pause(seconds: float):await frames(3 if fast else int(seconds*30))
func move(point: Vector2):
	var e=InputEventMouseMotion.new();e.position=point;e.global_position=point;Input.parse_input_event(e);await frames(3)
func click(control: Control):
	var point=control.get_global_rect().get_center();await move(point)
	for down in [true,false]:
		var e=InputEventMouseButton.new();e.position=point;e.global_position=point;e.button_index=MOUSE_BUTTON_LEFT;e.pressed=down
		Input.parse_input_event(e);await process_frame
	await frames(3)
func wheel(control: Control, down: bool, count: int):
	var point=control.get_global_rect().get_center();await move(point)
	for i in range(count):
		for pressed in [true,false]:
			var e=InputEventMouseButton.new();e.position=point;e.global_position=point;e.button_index=MOUSE_BUTTON_WHEEL_DOWN if down else MOUSE_BUTTON_WHEEL_UP;e.pressed=pressed
			Input.parse_input_event(e);await process_frame
	await frames(3)
func key(code: Key):
	for down in [true,false]:
		var e=InputEventKey.new();e.keycode=code;e.pressed=down;Input.parse_input_event(e);await process_frame
	await frames(3)
func shot(name: String):
	await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(OUT+name+".png")
func tab(id: String):
	await click(menu.tabs[id]);check(menu.active_tab==id,"tab opens "+id)
func item(page,id: String):
	page.list_scroll.ensure_control_visible(page.item_buttons[id]);await frames(3);await click(page.item_buttons[id]);check(page.selected_id==id,"click selects "+id)
func class_tab(page,id: String):
	await click(page.class_buttons[id]);check(page.selected_class==id,"class click "+id)
func labels_fit(node: Node, context: String):
	for child in node.get_children():
		if child is Label:
			check(child.get_line_count()*child.get_line_height()<=child.size.y+3,"text fits "+context+" "+child.text.left(38))
		labels_fit(child,context)
func set_option(option: OptionButton,id: String):
	for i in range(option.item_count):
		if str(option.get_item_metadata(i))==id:option.select(i);option.item_selected.emit(i);return
func run():
	fast="--fast" in OS.get_cmdline_user_args()
	root.size=Vector2i(1440,1000);DisplayServer.window_set_size(root.size)
	scene=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(scene);await frames(12)
	menu=scene.menu_panels
	check(menu!=null and menu.active_tab=="battle_setup","Battle Setup opens first")
	check(menu.tabs.keys()==["battle_setup","factions","arsenal","vehicles","tutorial"],"all five tabs in requested order")
	var builder=menu.builder
	builder.map_option.select(1);builder.map_option.item_selected.emit(1)
	set_option(builder.faction_options.attacker,"mercer");set_option(builder.faction_options.defender,"orlov")
	builder.row_widgets.attacker[0].tier.select(2);builder.row_widgets.attacker[0].tier.item_selected.emit(2)
	var armor=builder.row_widgets.defender[1].armor;armor.select(1);armor.item_selected.emit(1)
	await frames(5)
	var setup=builder.config.duplicate(true)
	check(setup.map_id=="river_bridge" and setup.attacker.units.size()==5 and setup.defender.units.size()==5,"configured bridge 5v5")
	await shot("battle_setup");await pause(2.)
	await tab("factions");var factions=menu.pages.factions
	await item(factions,"mercer");await shot("faction_mercer");await pause(6.)
	await item(factions,"orlov");await shot("faction_orlov");await pause(6.)
	await item(factions,"trc");await shot("faction_trc");await pause(6.)
	await tab("arsenal");var arsenal=menu.pages.arsenal
	await item(arsenal,"desert_eagle");await shot("arsenal_pistol");await pause(4.)
	await class_tab(arsenal,"rifle");await item(arsenal,"scar_h");await shot("arsenal_rifle");await pause(4.)
	await wheel(arsenal.detail_scroll,true,10);check(arsenal.detail_scroll.scroll_vertical>0,"gun detailed specs scroll");await shot("arsenal_specs");await pause(4.)
	await class_tab(arsenal,"sniper");await item(arsenal,"awm");await pause(4.)
	await tab("vehicles");var vehicles=menu.pages.vehicles
	await item(vehicles,"yardbird");await shot("vehicle_bicycle");await pause(3.)
	await class_tab(vehicles,"passenger_cars");await item(vehicles,"bayou");await shot("vehicle_car");await pause(4.)
	await class_tab(vehicles,"utility_vehicles");await pause(2.);await class_tab(vehicles,"heavy_transports");await item(vehicles,"roadwarden");await shot("vehicle_roadwarden");await pause(4.)
	await wheel(vehicles.detail_scroll,true,15);check(vehicles.detail_scroll.scroll_vertical>0,"vehicle abilities scroll");await shot("vehicle_ability");await pause(5.)
	await class_tab(vehicles,"heavy_transports");await item(vehicles,"custodian");await pause(4.)
	await wheel(vehicles.detail_scroll,true,12);await shot("vehicle_service");await pause(4.)
	await click(menu.tabs.tutorial);await frames(5)
	var tutorial=scene.get_node_or_null("SandboxTutorial")
	check(tutorial!=null and tutorial.regions.size()>100,"Tutorial retained with actual battlefield and HUD")
	if tutorial!=null:
		await pause(2.)
		for i in range(tutorial.regions.size()):
			if tutorial.regions[i].id=="push":
				await move(tutorial.canvas.position+tutorial.region_rect(i).get_center());break
		check(tutorial.tip.visible,"tutorial hover still works");await pause(3.);await key(KEY_ESCAPE)
	check(not scene.has_node("SandboxTutorial"),"Tutorial closes to menu")
	await tab("battle_setup");check(builder.config==setup and scene.custom_loadouts==setup,"all setup selections survive every tab and tutorial")
	await pause(2.)
	preview_end_seconds=Engine.get_process_frames()/30.0
	# All catalogue content is exercised after the review segment.
	menu.show_tab("factions");await frames(3)
	check(factions.data.size()==23,"23 faction profiles")
	for id in Factions.all_ids():
		factions.show_faction(id);await frames(2)
		check(not factions.selected_faction_rows.description.is_empty(),"description "+id)
		check(factions.detail_labels.title.text==Factions.display_name(id),"canonical name "+id)
		check(factions.detail.get_child(0).texture!=null,"emblem "+id)
		check(factions.unit_images.size()==5,"five classes "+id)
		for role in factions.CLASSES:
			var picture=factions.unit_images[role]
			check(picture.texture!=null and picture.texture.get_width()>0,"paired portrait "+id+" "+role)
			check(Weapons.get_model(picture.get_meta("weapon")).weapon_type_id==role,"weapon matches class "+id+" "+role)
		labels_fit(factions.detail,id)
	for id in ["mercer44","union_sur","lombardia"]:check(factions.leader_for(id)=="Undisclosed","conditional leader not spoiled "+id)
	factions.search.text="Mac11";factions.search.text_changed.emit("Mac11");await frames(3)
	check(factions.item_buttons.size()==1 and factions.item_buttons.has("mercer"),"leader search returns fixed leader")
	factions.search.text="no-such-faction";factions.search.text_changed.emit(factions.search.text);await frames(3)
	check(factions.item_buttons.is_empty(),"empty search result handled")
	factions.search.text="";factions.search.text_changed.emit("");await frames(3)
	check(factions.item_buttons.size()==23,"clearing search restores all factions")
	var guns=0
	menu.show_tab("arsenal");await frames(3)
	for kind in arsenal.CLASSES:
		arsenal.choose_class(kind);await frames(3)
		for id in arsenal.visible_models.duplicate():
			guns+=1;arsenal.show_equipment(id);await frames(2)
			check(arsenal.active_texture.texture!=null,"weapon image "+id)
			check(arsenal.detail_labels.title.text==Weapons.get_model(id).display_name,"weapon name "+id)
			check(arsenal.detail_labels.size()>=17,"complete weapon spec fields "+id)
			labels_fit(arsenal.detail,id)
	check(guns==30,"all 30 weapons")
	var cars=0
	menu.show_tab("vehicles");await frames(3)
	for kind in Vehicles.data().classes:
		vehicles.choose_class(kind);await frames(3)
		for id in vehicles.visible_models.duplicate():
			cars+=1;vehicles.show_equipment(id);await frames(2)
			check(vehicles.active_texture.texture!=null,"vehicle image "+id)
			check(vehicles.detail_labels.title.text==Vehicles.model(id).name,"vehicle name "+id)
			labels_fit(vehicles.detail,id)
	check(cars==75,"all 75 vehicles")
	# Existing fleet selection and Encounter Lab remain reachable from the new shell.
	menu.open_fleet_lab();await frames(5)
	check(menu.has_node("VehicleFleet"),"fleet and Encounter Lab reachable")
	if menu.has_node("VehicleFleet"):menu.get_node("VehicleFleet").queue_free();await frames(3)
	menu.show_tab("battle_setup");builder.open_fleet();await frames(5)
	check(menu.has_node("VehicleFleet"),"embedded setup fleet modal uses full menu surface")
	if menu.has_node("VehicleFleet"):
		check(menu.get_rect().encloses(menu.get_node("VehicleFleet").get_rect()),"fleet modal fits full menu")
		menu.get_node("VehicleFleet").queue_free();await frames(3)
	check(builder.config==setup,"catalogs do not change setup")
	for dimensions in [Vector2i(1152,860),Vector2i(1280,720),Vector2i(390,844)]:
		root.size=dimensions;DisplayServer.window_set_size(dimensions);await frames(8)
		for id in ["factions","arsenal","vehicles","battle_setup"]:
			await tab(id)
			check(Rect2(Vector2.ZERO,Vector2(dimensions)).encloses(menu.tabs[id].get_global_rect()),"navigation on screen "+id+str(dimensions))
		check(Rect2(Vector2.ZERO,Vector2(dimensions)).encloses(builder.start_button.get_global_rect()),"launch button in bounds "+str(dimensions))
		if dimensions.x==1280:await shot("setup_720p")
	root.size=Vector2i(1440,1000);DisplayServer.window_set_size(root.size);await frames(8)
	# Verify launch/return integration once without simulating the battle.
	await click(builder.start_button);await frames(12)
	check(scene.runtime!=null and scene.battle!=null and not scene.ui.visible,"configured battle launch still works")
	scene.return_to_setup();await frames(5)
	check(scene.runtime==null and scene.ui.visible and builder.config==setup,"return retains complete setup")
	var f=FileAccess.open(OUT+("smoke.json" if fast else "record.json"),FileAccess.WRITE)
	f.store_string(JSON.stringify({"checks":checks,"errors":errors,"preview_end_seconds":preview_end_seconds,"factions":23,"paired_unit_images":115,"weapons":guns,"vehicles":cars,"battle_launched_after_preview_only":true},"\t"));f.close()
	print("GLOSSARY_VALIDATION ",checks," checks; ",errors.size()," failures")
	quit(0 if errors.is_empty() else 1)
