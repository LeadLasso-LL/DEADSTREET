extends Control
const Glossary = preload("res://gameplay/sandbox_glossary_panel.gd")
const Builder = preload("res://gameplay/sandbox_force_builder.gd")
const Config = preload("res://gameplay/sandbox_force_config.gd")
const Card = preload("res://gameplay/tactical_unit_card.gd")
var owner_scene: Node
var pages = {}
var tabs = {}
var active_tab = "battle_setup"
var builder: Control
var body: Control
var font: SystemFont
func _ready():
	size=Vector2(1152,860);mouse_filter=Control.MOUSE_FILTER_STOP
	font=SystemFont.new();font.font_names=PackedStringArray(["Arial"])
	var background=ColorRect.new();add_child(background);background.size=size;background.color=Color("#121c20");background.mouse_filter=Control.MOUSE_FILTER_IGNORE
	Card.label(self,Vector2(24,12),Vector2(820,28),"DEAD STREET  /  SANDBOX",20,Color("#dfdfd0"),font)
	var names=[["battle_setup","BATTLE SETUP"],["factions","FACTION GLOSSARY"],["arsenal","ARSENAL"],["vehicles","VEHICLES"],["tutorial","TUTORIAL"]]
	for i in range(names.size()):
		var id: String=names[i][0]
		var button=Button.new();add_child(button);button.name="Tab_"+id;button.text=names[i][1]
		button.position=Vector2(24+i*221,49);button.size=Vector2(212,36)
		button.add_theme_font_override("font",font);button.add_theme_font_size_override("font_size",13)
		button.add_theme_stylebox_override("hover",Card.style(Color("#3c4940"),Color("#d2bf8d")))
		button.pressed.connect(show_tab.bind(id));tabs[id]=button
	body=Control.new();add_child(body);body.position=Vector2(0,96);body.size=Vector2(1152,764)
	builder=Builder.new();builder.name="BattleSetup";builder.embedded=true
	builder.config=Config.from_legacy(owner_scene.loadouts) if owner_scene.custom_loadouts.is_empty() else owner_scene.custom_loadouts.duplicate(true)
	builder.setup_changed.connect(func(config):owner_scene.custom_loadouts=config.duplicate(true))
	builder.launch_requested.connect(func(config):owner_scene.custom_loadouts=config.duplicate(true);owner_scene.start_battle(false,config))
	body.add_child(builder);builder.scale=Vector2.ONE*(764./816.);builder.position=Vector2((1152.-1152.*builder.scale.x)*.5,0)
	pages.battle_setup=builder
	show_tab("battle_setup")

func show_tab(id: String):
	if id=="tutorial":owner_scene.open_tutorial();return
	if not pages.has(id):
		var page=Glossary.new();page.mode=id;page.name=id.capitalize()+"Glossary";page.fleet_requested.connect(open_fleet_lab);body.add_child(page);pages[id]=page
	active_tab=id
	for key in pages:pages[key].visible=key==id
	for key in tabs:tabs[key].add_theme_stylebox_override("normal",Card.style(Color("#3c443a") if key==id else Color("#233036"),Color("#d2bf8d") if key==id else Color("#4b5b54")))

func open_fleet_lab():
	if has_node("VehicleFleet"):return
	var fleet=preload("res://gameplay/vehicle_fleet_panel.gd").new();fleet.name="VehicleFleet"
	fleet.faction_id=builder.config.attacker.faction;fleet.required_units=builder.config.attacker.units.size()
	fleet.selected=builder.config.attacker.vehicles.duplicate()
	fleet.convoy_selected.connect(func(models):builder.config.attacker.vehicles=models.duplicate();builder.config.attacker.erase("vehicle_occupants");builder.changed())
	fleet.blockade_battle_requested.connect(owner_scene.start_blockade_battle)
	add_child(fleet)
