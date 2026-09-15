extends Control
const Glossary=preload("res://gameplay/sandbox_glossary_panel.gd")
const Builder=preload("res://gameplay/sandbox_force_builder.gd")
const Config=preload("res://gameplay/sandbox_force_config.gd")
const Card=preload("res://gameplay/tactical_unit_card.gd")
var owner_scene: Node
var pages={}
var tabs={}
var active_tab="battle_setup"
var builder: Control
var body: Control
var font: SystemFont
var background: ColorRect
var title_art: TextureRect
func _ready():
 size=Vector2(1504,860);mouse_filter=Control.MOUSE_FILTER_STOP
 font=SystemFont.new();font.font_names=PackedStringArray(["Arial"])
 background=ColorRect.new();add_child(background);background.color=Color("#121c20");background.mouse_filter=Control.MOUSE_FILTER_IGNORE
 title_art=TextureRect.new();title_art.name="DeadStreetWordmark";add_child(title_art)
 var atlas=AtlasTexture.new();atlas.atlas=ImageTexture.create_from_image(Image.load_from_file("res://assets/menu/opening/approved_title.png"));atlas.region=Rect2(86,120,1912,532)
 title_art.texture=atlas;title_art.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;title_art.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
 title_art.position=Vector2(24,0);title_art.size=Vector2(172,47);title_art.mouse_filter=Control.MOUSE_FILTER_IGNORE;title_art.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
 var ink=CanvasItemMaterial.new();ink.blend_mode=CanvasItemMaterial.BLEND_MODE_ADD;title_art.material=ink
 Card.label(self,Vector2(211,15),Vector2(230,24),"/  SANDBOX",15,Color("#bcc8bd"),font)
 var names=[["battle_setup","BATTLE SETUP"],["factions","FACTION GLOSSARY"],["arsenal","ARSENAL"],["vehicles","VEHICLES"],["tutorial","TUTORIAL"]]
 for row in names:
  var id: String=row[0]
  var button=Button.new();add_child(button);button.name="Tab_"+id;button.text=row[1]
  button.add_theme_font_override("font",font);button.add_theme_font_size_override("font_size",13)
  button.add_theme_stylebox_override("hover",Card.style(Color("#3c4940"),Color("#d2bf8d")))
  button.pressed.connect(show_tab.bind(id));tabs[id]=button
 body=Control.new();add_child(body);body.position=Vector2(0,96)
 builder=Builder.new();builder.name="BattleSetup";builder.embedded=true
 builder.config=Config.from_legacy(owner_scene.loadouts) if owner_scene.custom_loadouts.is_empty() else owner_scene.custom_loadouts.duplicate(true)
 builder.setup_changed.connect(func(config):owner_scene.custom_loadouts=config.duplicate(true))
 builder.launch_requested.connect(func(config):owner_scene.custom_loadouts=config.duplicate(true);owner_scene.start_battle(false,config))
 body.add_child(builder);pages.battle_setup=builder
 show_tab("battle_setup");arrange(size)
func arrange(area: Vector2):
 size=area;background.size=size;body.size=Vector2(size.x,size.y-96.)
 var tab_w=(size.x-88.)/5.;var i=0
 for id in tabs:
  tabs[id].position=Vector2(24+i*(tab_w+10.),49);tabs[id].size=Vector2(tab_w,36);i+=1
 builder.position=Vector2.ZERO;builder.scale=Vector2.ONE;builder.size=body.size
 for id in pages:
  if id!="battle_setup":pages[id].position=Vector2((size.x-1152.)*.5,0)
 for child in get_children():
  if child.name=="VehicleFleet":child.position=Vector2((size.x-1504.)*.5,0)
func show_tab(id: String):
 if id!="factions" and pages.has("factions"):pages.factions.faction_audio.stop()
 if id=="tutorial":owner_scene.open_tutorial();return
 if not pages.has(id):
  var page=Glossary.new();page.mode=id;page.name=id.capitalize()+"Glossary";page.fleet_requested.connect(open_fleet_lab);body.add_child(page);pages[id]=page
 active_tab=id
 for key in pages:pages[key].visible=key==id
 for key in tabs:tabs[key].add_theme_stylebox_override("normal",Card.style(Color("#3c443a") if key==id else Color("#233036"),Color("#d2bf8d") if key==id else Color("#4b5b54")))
 arrange(size)
func open_fleet_lab():
 if has_node("VehicleFleet"):return
 var fleet=preload("res://gameplay/vehicle_fleet_panel.gd").new();fleet.name="VehicleFleet"
 fleet.faction_id=builder.config.attacker.faction;fleet.required_units=builder.config.attacker.units.size()
 fleet.selected=builder.config.attacker.vehicles.duplicate()
 fleet.convoy_selected.connect(func(models):builder.config.attacker.vehicles=models.duplicate();builder.config.attacker.erase("vehicle_occupants");builder.changed())
 fleet.blockade_battle_requested.connect(owner_scene.start_blockade_battle)
 add_child(fleet);arrange(size)
