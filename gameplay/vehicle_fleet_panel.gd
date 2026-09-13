extends Control
const Models=preload("res://campaign/vehicles/vehicle_model_catalog.gd")
const Factions=preload("res://battle/identity/faction_unit_catalog.gd")
const Card=preload("res://gameplay/tactical_unit_card.gd")
signal convoy_selected(models: Array)
signal blockade_battle_requested(context: Dictionary)
var faction_id="mercer"
var selected: Array=["bayou","bayou"]
var selected_class="two_wheelers"
var required_units=5
var allow_encounter_lab=true
var grid: GridContainer
var convoy_row: HBoxContainer
var status: Label
var apply_button: Button
var preferred: CheckBox
var font: SystemFont
var class_buttons: Dictionary={}
func _ready():
	size=Vector2(1152,860);mouse_filter=Control.MOUSE_FILTER_STOP
	font=SystemFont.new();font.font_names=PackedStringArray(["Arial"])
	var bg=ColorRect.new();add_child(bg);bg.size=size;bg.color=Color("#111b20")
	label_at(Vector2(28,18),Vector2(890,38),"DEAD STREET / VEHICLE FLEET",26)
	if allow_encounter_lab:button_at(Vector2(810,18),Vector2(178,35),"ENCOUNTER LAB",open_encounter_lab)
	button_at(Vector2(1000,18),Vector2(120,35),"CLOSE",queue_free)
	label_at(Vector2(28,58),Vector2(1090,38),"%d models · All unlocked · Seats include the driver · Only Heavy Transports carry resources"%Models.all_ids().size(),13)
	var i=0
	for id in Models.data().classes:
		var tab=button_at(Vector2(28+i*273,102),Vector2(260,34),Models.class_name_for(id),func():selected_class=id;refresh_models())
		tab.toggle_mode=true;class_buttons[id]=tab
		i+=1
	preferred=CheckBox.new();add_child(preferred);preferred.position=Vector2(28,146)
	preferred.text="Suggested for "+Factions.display_name(faction_id);preferred.add_theme_font_size_override("font_size",13)
	preferred.toggled.connect(func(_x):refresh_models())
	var scroll=ScrollContainer.new();add_child(scroll);scroll.position=Vector2(28,183);scroll.size=Vector2(1096,420)
	scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
	grid=GridContainer.new();scroll.add_child(grid);grid.columns=3;grid.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation",12);grid.add_theme_constant_override("v_separation",12)
	label_at(Vector2(28,621),Vector2(1090,30),"ATTACKING CONVOY / %d units to transport"%required_units,17)
	var convoy_scroll=ScrollContainer.new();add_child(convoy_scroll);convoy_scroll.position=Vector2(28,658);convoy_scroll.size=Vector2(1096,52);convoy_scroll.vertical_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
	convoy_row=HBoxContainer.new();convoy_scroll.add_child(convoy_row);convoy_row.add_theme_constant_override("separation",8)
	status=label_at(Vector2(28,713),Vector2(1096,58),"",14);status.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	button_at(Vector2(28,795),Vector2(150,35),"CLEAR CONVOY",func():selected=[];refresh_convoy())
	apply_button=button_at(Vector2(850,795),Vector2(270,35),"USE THIS CONVOY",func():convoy_selected.emit(selected.duplicate());queue_free())
	refresh_models();refresh_convoy()
func label_at(at: Vector2,sz: Vector2,value: String,points: int) -> Label:
	return Card.label(self,at,sz,value,points,Color("#d9dfd5"),font)
func button_at(at: Vector2,sz: Vector2,value: String,action: Callable) -> Button:
	var b=Button.new();add_child(b);b.position=at;b.size=sz;b.text=value;b.add_theme_font_size_override("font_size",13);b.pressed.connect(action);return b
func refresh_models():
	for id in class_buttons:class_buttons[id].set_pressed_no_signal(id==selected_class)
	for child in grid.get_children():grid.remove_child(child);child.queue_free()
	for id in Models.all_ids():
		var m=Models.model(id)
		if m.vehicle_class!=selected_class:continue
		if preferred.button_pressed and not Models.preferences(faction_id).has(id):continue
		var tile=PanelContainer.new();grid.add_child(tile);tile.custom_minimum_size=Vector2(352,310)
		tile.add_theme_stylebox_override("panel",Card.style(Color("#26323a"),Color("#4c6068")))
		var holder=Control.new();tile.add_child(holder)
		Card.label(holder,Vector2(12,8),Vector2(328,25),m.name,18,Color("#e4dfc9"),font)
		var icon=TextureRect.new();holder.add_child(icon);icon.position=Vector2(25,40);icon.size=Vector2(300,110)
		icon.texture=Models.icon(id);icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;icon.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;icon.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
		Card.label(holder,Vector2(12,157),Vector2(328,23),"$%d · %d seats · %.1f road units/turn"%[m.price,m.unit_capacity,m.movement_per_turn],13,Color("#c6d5cb"),font)
		Card.label(holder,Vector2(12,183),Vector2(328,23),"Cargo %d · Upkeep $%d/turn"%[m.resource_capacity,m.upkeep_per_turn],12,Color("#a8bbc2"),font)
		var detail=str(m.get("ability_name",""))
		if m.get("service_role","")=="bank_cash":detail="Independent cash service · $%d capacity"%int(m.cash_capacity)
		if m.get("service_role","")=="prisoner_transfer":detail="Independent custody · 3 guards + 8 prisoners"
		var info=Card.label(holder,Vector2(12,209),Vector2(328,50),detail,12,Color("#e4c67f"),font)
		info.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		info.tooltip_text=str(m.get("ability_summary",""))+" "+str(m.get("ability_limits",""))
		var add=Button.new();holder.add_child(add);add.position=Vector2(12,268);add.size=Vector2(328,34);add.text="ADD TO CONVOY";add.tooltip_text=m.description
		add.pressed.connect(func():
			if selected.size()<required_units:selected.append(id);refresh_convoy())
func refresh_convoy():
	for child in convoy_row.get_children():convoy_row.remove_child(child);child.queue_free()
	for index in range(selected.size()):
		var b=Button.new();convoy_row.add_child(b);b.custom_minimum_size=Vector2(207,40);b.text=Models.model(selected[index]).name+" ×";b.add_theme_font_size_override("font_size",12)
		b.pressed.connect(func():selected.remove_at(index);refresh_convoy())
	var summary=Models.convoy(selected,required_units)
	apply_button.disabled=not summary.valid
	status.text="%d/%d seats · %.1f road units/turn · %d resource slots · Fleet value $%d · Upkeep $%d/turn"%[summary.get("units",0),required_units,summary.get("movement",0.),summary.get("cargo",0),summary.get("price",0),summary.get("upkeep",0)]
	status.text+="\nConvoys travel at their slowest vehicle's pace. "+("Ready for the sandbox." if summary.valid else summary.get("error","Choose a convoy."))

func open_encounter_lab():
	if has_node("EncounterLab"):return
	var lab=load("res://gameplay/vehicle_encounter_lab.gd").new();lab.name="EncounterLab";lab.battle_requested.connect(func(context):blockade_battle_requested.emit(context));add_child(lab)
