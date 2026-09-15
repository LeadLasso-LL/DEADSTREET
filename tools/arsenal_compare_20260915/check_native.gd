extends SceneTree
const OUT="res://tools/arsenal_compare_20260915/"
const Compare=preload("res://gameplay/equipment_comparison.gd")
const Weapons=preload("res://battle/combat/battle_weapon_catalog.gd")
const Vehicles=preload("res://campaign/vehicles/vehicle_model_catalog.gd")
var checks=0
var errors=[]
var ui_checks=0
func _initialize():call_deferred("run")
func frames(n):
	for i in range(n):await process_frame
func check(ok: bool,message: String):
	checks+=1
	if not ok:errors.append(message);printerr("COMPARE_FAIL ",message)
func hover(control):
	var point=control.get_global_rect().get_center()
	var motion=InputEventMouseMotion.new();motion.position=point;motion.global_position=point;root.push_input(motion,true)
	await frames(3)
func click(control):
	await hover(control)
	var point=control.get_global_rect().get_center()
	for down in [true,false]:
		var e=InputEventMouseButton.new();e.position=point;e.global_position=point;e.button_index=MOUSE_BUTTON_LEFT;e.pressed=down;root.push_input(e,true);await process_frame
	await frames(3)
func shot(name):
	await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(OUT+name+".png")
func test_values(base_id: String,ids: Array,vehicles: bool):
	var base_model=Vehicles.model(base_id) if vehicles else Weapons.get_model(base_id)
	for id in ids:
		var model=Vehicles.model(id) if vehicles else Weapons.get_model(id)
		var rows=Compare.compare(base_id,id,vehicles)
		check(rows.size()==(10 if vehicles else 17),"complete stat count "+id)
		for row in rows:
			var raw=float(Weapons.purchase_price(id)) if row.key=="price" and not vehicles else float(model.get(row.key))
			var base_raw=float(Weapons.purchase_price(base_id)) if row.key=="price" and not vehicles else float(base_model.get(row.key))
			if row.key=="movement_multiplier":raw=(raw-1)*100;base_raw=(base_raw-1)*100
			elif row.unit=="%":raw*=100;base_raw*=100
			check(is_equal_approx(raw,row.value) and is_equal_approx(base_raw,row.base_value) and is_equal_approx(raw-base_raw,row.delta),"canonical values and signed difference "+id+" "+row.key)
			check(row.delta_text=="—" if id==base_id else not row.delta_text.is_empty(),"delta rendered "+id+" "+row.key)
			if row.direction==0:check(row.benefit==0,"neutral tradeoff "+id+" "+row.key)
func check_cells(page):
	for key in page.comparison_cells:
		var row=page.comparison_cells[key]
		for cell in [row.base,row.other,row.delta]:
			check(cell.position.x+cell.size.x<=550.01,"cell fits detail width "+key)
			check(cell.get_line_count()*cell.get_line_height()<=29,"cell fits row height "+key+" "+cell.text)
func run():
	root.size=Vector2i(1440,1000);DisplayServer.window_set_size(root.size)
	var scene=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(scene);await frames(10)
	var menu=scene.menu_panels;var builder=menu.builder
	for side in ["attacker","defender"]:
		check(builder.add_classes[side].get_item_text(1)=="SMG","uppercase SMG add picker "+side)
		for row in builder.row_widgets[side]:check(row["class"].get_item_text(1)=="SMG","uppercase SMG existing-row picker "+side)
		builder.add_classes[side].select(1)
	await shot("smg_picker")
	await click(menu.tabs.arsenal);var guns=menu.pages.arsenal
	var pistol_ids=Weapons.models_for_class("pistol")
	await hover(guns.item_buttons[pistol_ids[1]])
	check(guns.comparison_base.is_empty() and guns.compared_id.is_empty(),"hover before click does not pin a gun")
	await click(guns.item_buttons[pistol_ids[0]])
	check(guns.comparison_base==pistol_ids[0],"actual click pins gun")
	await hover(guns.item_buttons[pistol_ids[1]])
	check(guns.compared_id==pistol_ids[1] and guns.selected_id==pistol_ids[0],"actual hover compares without changing selected gun")
	check(guns.comparison_cells.size()==17,"all gun comparison rows rendered")
	check_cells(guns);await shot("guns_same_class")
	await hover(guns.detail_scroll);guns.detail_scroll.scroll_vertical=9999;await frames(4)
	check(guns.compared_id==pistol_ids[1] and guns.detail_scroll.scroll_vertical>0,"comparison persists while scrolling details")
	await shot("guns_scrolled")
	await click(guns.class_buttons.smg)
	check(guns.comparison_base==pistol_ids[0] and guns.compared_id.is_empty(),"selected gun persists across class tabs")
	var smg_id=Weapons.models_for_class("smg")[1]
	await hover(guns.item_buttons[smg_id]);check(guns.compared_id==smg_id,"actual cross-class gun comparison")
	check_cells(guns);await shot("guns_cross_class")
	await click(guns.item_buttons[smg_id]);check(guns.comparison_base==smg_id and guns.compared_id.is_empty(),"click hovered gun replaces baseline")
	var all_guns=[]
	for kind in guns.CLASSES:all_guns.append_array(Weapons.models_for_class(kind))
	test_values(smg_id,all_guns,false)
	for row in Compare.compare(smg_id,smg_id):check(row.delta_text=="—" and row.benefit==0,"identical guns are neutral "+row.key)
	for row in Compare.SPECS:
		var spec={"precision":row[2],"unit":row[3],"key":row[1]}
		check(Compare.format_value(spec,-0.00000001,true)=="—","no negative zero "+str(row[1]))
	check(Compare.format_value({"precision":0,"unit":"money","key":"price"},-1250,true)=="−$1,250","signed comma-grouped price difference")
	check(Compare.format_value({"precision":0,"unit":"%","key":"solid_probability"},5,true)=="+5 pp","chance deltas use percentage points")
	await click(menu.tabs.vehicles);var fleet=menu.pages.vehicles
	var first=fleet.visible_models[0];var second=fleet.visible_models[1]
	await click(fleet.item_buttons[first]);await hover(fleet.item_buttons[second])
	check(fleet.comparison_base==first and fleet.compared_id==second,"actual vehicle click and hover")
	check(fleet.comparison_cells.size()==10,"all vehicle comparison rows rendered")
	check_cells(fleet);await shot("vehicles_same_class")
	var category=fleet.class_buttons.keys()[1]
	await click(fleet.class_buttons[category]);var candidate=fleet.visible_models[1]
	await hover(fleet.item_buttons[candidate])
	check(fleet.comparison_base==first and fleet.compared_id==candidate,"actual cross-category vehicle comparison")
	check_cells(fleet);await shot("vehicles_cross_class")
	test_values(first,Vehicles.all_ids(),true)
	for category_id in fleet.class_buttons:
		fleet.choose_class(category_id);await frames(2)
		var prior=-1
		for id in fleet.visible_models:
			var price=int(Vehicles.model(id).price);check(price>=prior,"ascending vehicle prices "+id);prior=price
	# Inspect every model through the real panel, including special service roles.
	var special_count=0
	for id in Vehicles.all_ids():
		fleet.hover_equipment(id)
		if Vehicles.model(id).get("service_role","")=="bank_cash":special_count+=1;await frames(2);fleet.detail_scroll.scroll_vertical=9999;await frames(2);await shot("vehicle_special_role")
	check(special_count>0,"bank cash capacity shown in special-role comparison")
	# Benefit directions use costs/timing and actual cover transitions correctly.
	for vehicle_mode in [false,true]:
		var ids=Vehicles.all_ids() if vehicle_mode else all_guns
		for row in Compare.compare(ids[0],ids[-1],vehicle_mode):
			if row.key in ["price","upkeep_per_turn","acquire_seconds","reload_seconds","recoil_per_shot","miss_probability"]:
				check(row.direction==-1,"lower-is-better direction "+row.key)
			if row.key in ["recoil_recovery","max_range","unit_capacity","cover"]:check(row.direction==1,"higher-is-better direction "+row.key)
	await click(menu.tabs.arsenal);await click(guns.class_buttons.pistol);await hover(guns.item_buttons[pistol_ids[0]])
	check(fleet.compared_id.is_empty() and fleet.comparison_base==first,"leaving vehicle page clears only hover")
	for dimensions in [Vector2i(1152,860),Vector2i(1280,720),Vector2i(1440,1000)]:
		root.size=dimensions;DisplayServer.window_set_size(dimensions);await frames(6)
		check(Rect2(Vector2.ZERO,root.get_visible_rect().size).encloses(guns.detail_scroll.get_global_rect()),"comparison visible at "+str(dimensions))
		check_cells(guns)
		if dimensions==Vector2i(1280,720):await shot("comparison_720p")
	await click(guns.class_buttons.smg);await hover(guns.item_buttons[smg_id]);check(guns.compared_id.is_empty(),"hovering selected tile restores single detail")
	FileAccess.open(OUT+"native_validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"errors":errors,"guns":all_guns.size(),"vehicles":Vehicles.all_ids().size(),"input_and_layout":true},"  "))
	print("EQUIPMENT_COMPARE_NATIVE ",checks," checks; ",errors.size()," failures")
	quit(0 if errors.is_empty() else 1)
