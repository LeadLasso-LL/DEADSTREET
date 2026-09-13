extends Control
const Config=preload("res://gameplay/sandbox_force_config.gd")
const Anim=preload("res://battle/presentation/tactical_unit_animation_catalog.gd")
const Weapons=preload("res://battle/combat/battle_weapon_catalog.gd")
const Factions=preload("res://battle/identity/faction_unit_catalog.gd")
const Armor=preload("res://campaign/equipment/armor_catalog.gd")
const Card=preload("res://gameplay/tactical_unit_card.gd")
const FleetPanel=preload("res://gameplay/vehicle_fleet_panel.gd")
signal launch_requested(config: Dictionary)
signal setup_changed(config: Dictionary)
var config: Dictionary={}
var lists={}
var counters={}
var add_buttons={}
var add_classes={}
var faction_options={}
var row_widgets={}
var start_button: Button
var status: Label
var convoy_label: Label
var font: SystemFont
var error_override=""
var map_option: OptionButton
var map_description: Label
var defender_controls=[]

func _ready():
 size=Vector2(1152,860);mouse_filter=Control.MOUSE_FILTER_STOP
 if config.is_empty():config=Config.from_legacy({})
 font=SystemFont.new();font.font_names=PackedStringArray(["Arial"])
 var bg=ColorRect.new();add_child(bg);bg.size=size;bg.color=Color("#121c20")
 label_at(self,Vector2(28,20),Vector2(920,36),"DEAD STREET / BATTLE SETUP",26)
 map_option=option(self,Vector2(28,62),Vector2(310,33))
 map_option.add_item("Harold Avenue");map_option.add_item("River Suspension Bridge")
 map_option.select(1 if config.get("map_id","harold")=="river_bridge" else 0)
 map_option.item_selected.connect(func(i):choose_map("river_bridge" if i==1 else "harold"))
 map_description=label_at(self,Vector2(356,66),Vector2(768,28),"1–12 units per side / All factions and equipment unlocked",12)
 button_at(self,Vector2(992,20),Vector2(132,36),"ARSENAL",queue_free)
 for side_index in range(2):build_side("attacker" if side_index==0 else "defender",28+side_index*564)
 convoy_label=label_at(self,Vector2(28,720),Vector2(720,65),"",13)
 convoy_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 button_at(self,Vector2(768,718),Vector2(190,36),"ATTACKING VEHICLES",open_fleet)
 button_at(self,Vector2(972,718),Vector2(152,36),"AUTO-FIT SEATS",auto_fit)
 defender_controls.append(button_at(self,Vector2(768,758),Vector2(190,33),"DEFENDING VEHICLES",func():open_fleet("defender")))
 defender_controls.append(button_at(self,Vector2(972,758),Vector2(152,33),"AUTO-FIT DEFENDERS",func():auto_fit("defender")))
 status=label_at(self,Vector2(28,807),Vector2(744,55),"",13);status.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 start_button=button_at(self,Vector2(808,808),Vector2(316,36),"START BATTLE",launch)
 refresh_status()

func label_at(parent,at,sz,value,points=13):return Card.label(parent,at,sz,value,points,Color("#d5ddcf"),font)
func button_at(parent,at,sz,value,action):
 var b=Button.new();parent.add_child(b);b.position=at;b.size=sz;b.text=value;b.add_theme_font_size_override("font_size",12)
 b.add_theme_stylebox_override("normal",Card.style(Color("#26363b"),Color("#506663")));b.add_theme_stylebox_override("hover",Card.style(Color("#3c4945"),Color("#b6ac85")));b.pressed.connect(action);return b
func option(parent,at,sz):
 var o=OptionButton.new();parent.add_child(o);o.position=at;o.size=sz;o.fit_to_longest_item=false;o.clip_text=true;o.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS;o.add_theme_font_size_override("font_size",12);return o
func build_side(side: String,x: int):
 var panel=Panel.new();add_child(panel);panel.position=Vector2(x,108);panel.size=Vector2(532,590);panel.add_theme_stylebox_override("panel",Card.style(Color("#1b292f"),Color("#4c605c")))
 counters[side]=label_at(panel,Vector2(14,12),Vector2(280,25),side.to_upper(),18)
 button_at(panel,Vector2(302,12),Vector2(136,30),"BALANCED FIVE",func():set_balanced(side))
 button_at(panel,Vector2(446,12),Vector2(72,30),"CLEAR",func():config[side].units.clear();refresh_side(side))
 var badge=TextureRect.new();panel.add_child(badge);badge.name="FactionEmblem";badge.position=Vector2(14,51);badge.size=Vector2(36,36);badge.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;badge.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;badge.texture=Anim._load_texture(Factions.emblem_path(config[side].faction))
 var faction=option(panel,Vector2(60,52),Vector2(458,34));faction_options[side]=faction
 for id in Factions.all_ids():
  faction.add_item(Factions.display_name(id));faction.set_item_metadata(faction.item_count-1,id);faction.set_item_tooltip(faction.item_count-1,Factions.display_name(id))
  if id==config[side].faction:faction.select(faction.item_count-1)
 faction.item_selected.connect(func(i):
  config[side].faction=str(faction.get_item_metadata(i));badge.texture=Anim._load_texture(Factions.emblem_path(config[side].faction))
  if config[side].faction!="mercer":
   for row in config[side].units:row.specialist=""
  refresh_side(side))
 var scroll=ScrollContainer.new();panel.add_child(scroll);scroll.position=Vector2(14,101);scroll.size=Vector2(504,431);scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
 var list=VBoxContainer.new();scroll.add_child(list);list.size_flags_horizontal=Control.SIZE_EXPAND_FILL;list.add_theme_constant_override("separation",8);lists[side]=list
 var classes=option(panel,Vector2(14,546),Vector2(242,31));add_classes[side]=classes
 for kind in Config.CLASSES:classes.add_item(kind.capitalize());classes.set_item_metadata(classes.item_count-1,kind)
 classes.select(3)
 add_buttons[side]=button_at(panel,Vector2(270,546),Vector2(248,31),"+ ADD UNIT",func():add_unit(side,str(classes.get_item_metadata(classes.selected))))
 refresh_side(side)

func refresh_side(side: String):
 var list=lists[side]
 for child in list.get_children():list.remove_child(child);child.queue_free()
 row_widgets[side]=[]
 for i in range(config[side].units.size()):build_row(side,i,list)
 counters[side].text=side.to_upper()+"  /  %d UNITS"%config[side].units.size()
 add_buttons[side].disabled=config[side].units.size()>=Config.MAX_UNITS
 changed()

func build_row(side: String,index: int,parent):
 var row: Dictionary=config[side].units[index]
 var shell=PanelContainer.new();parent.add_child(shell);shell.custom_minimum_size=Vector2(480,96);shell.add_theme_stylebox_override("panel",Card.style(Color("#25343a"),Color("#3b5055")))
 var host=Control.new();shell.add_child(host)
 label_at(host,Vector2(8,9),Vector2(26,22),"%02d"%(index+1),12)
 var kind=option(host,Vector2(35,5),Vector2(113,31))
 for id in Config.CLASSES:kind.add_item(id.capitalize());kind.set_item_metadata(kind.item_count-1,id)
 kind.select(Config.CLASSES.find(row["class"]));kind.item_selected.connect(func(i):
  row["class"]=str(kind.get_item_metadata(i));row.weapon=Weapons.default_model(row["class"]);row.specialist="";refresh_side(side))
 var weapon=option(host,Vector2(155,5),Vector2(233,31))
 for id in Weapons.models_for_class(row["class"]):
  weapon.add_item(Weapons.get_model(id).display_name);weapon.set_item_metadata(weapon.item_count-1,id)
  weapon.set_item_tooltip(weapon.item_count-1,Weapons.get_model(id).display_name)
  if id==row.weapon:weapon.select(weapon.item_count-1)
 weapon.item_selected.connect(func(i):row.weapon=str(weapon.get_item_metadata(i));row.specialist="";refresh_side(side))
 var duplicate=button_at(host,Vector2(395,5),Vector2(34,31),"+",func():duplicate_unit(side,index));duplicate.tooltip_text="Duplicate this unit and its equipment";duplicate.disabled=config[side].units.size()>=Config.MAX_UNITS
 var remove=button_at(host,Vector2(436,5),Vector2(34,31),"×",func():remove_unit(side,index));remove.tooltip_text="Remove this unit"
 var portrait=TextureRect.new();host.add_child(portrait);portrait.position=Vector2(8,37);portrait.size=Vector2(57,54);portrait.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;portrait.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;portrait.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;portrait.mouse_filter=Control.MOUSE_FILTER_IGNORE
 var variant=Anim.variant_for(config[side].faction,row["class"],row.weapon,row.get("specialist",""))
 portrait.texture=Anim._load_texture(Anim.atlas_path(variant,"portraits"))
 label_at(host,Vector2(72,39),Vector2(110,17),"UNIT TIER",9)
 host.tooltip_text=Factions.display_name(config[side].faction)+" / "+row["class"].capitalize()+ (" / Dual pistols" if not row.get("specialist","").is_empty() else "")
 var tier=option(host,Vector2(72,57),Vector2(110,29))
 for rank in range(1,4):
  tier.add_item("Tier %d"%rank);tier.set_item_tooltip(rank-1,["Regular","Experienced","Veteran"][rank-1])
 tier.select(int(row.tier)-1);tier.item_selected.connect(func(i):row.tier=i+1;changed())
 label_at(host,Vector2(190,39),Vector2(280,17),"ARMOR / HP BONUS",9)
 var armor=option(host,Vector2(190,57),Vector2(280,29));armor.add_item("No armor");armor.set_item_metadata(0,"")
 for id in Armor.IDS:
  armor.add_item("%s  +%d%% HP"%[Armor.label(id),roundi(Armor.bonus(id)*100.)]);armor.set_item_metadata(armor.item_count-1,id)
  if id==row.armor:armor.select(armor.item_count-1)
 armor.item_selected.connect(func(i):row.armor=str(armor.get_item_metadata(i));changed())
 row_widgets[side].append({"class":kind,"weapon":weapon,"tier":tier,"armor":armor,"duplicate":duplicate,"remove":remove,"root":shell})

func add_unit(side: String,kind: String):
 if config[side].units.size()>=Config.MAX_UNITS:return
 config[side].units.append(Config.unit(kind));refresh_side(side)
func duplicate_unit(side: String,index: int):
 if config[side].units.size()>=Config.MAX_UNITS:return
 config[side].units.insert(index+1,config[side].units[index].duplicate(true));refresh_side(side)
func remove_unit(side: String,index: int):
 config[side].units.remove_at(index);refresh_side(side)
func set_balanced(side: String):
 config[side].units=Config.balanced();refresh_side(side)
func auto_fit(side: String="attacker"):
 config[side].vehicles=Config.auto_convoy(config[side].units.size());changed()
func changed():
 error_override="";refresh_status();setup_changed.emit(config.duplicate(true))
func refresh_status():
 if status==null:return
 var check=Config.validate(config)
 start_button.disabled=not check.valid
 start_button.text="START %d vs %d"%[config.attacker.units.size(),config.defender.units.size()]
 var summary=Config.Models.convoy(config.attacker.vehicles)
 for control in defender_controls:control.visible=config.get("map_id","harold")=="river_bridge"
 convoy_label.text="ATTACKING CONVOY  /  %d vehicles  /  %d seats for %d units\nDefenders begin on foot at Harold Apartments."%[config.attacker.vehicles.size(),summary.get("units",0),config.attacker.units.size()]
 if config.get("map_id","harold")=="river_bridge":
  var defense=Config.Models.convoy(config.defender.get("vehicles",[]))
  convoy_label.text="WEST APPROACH  /  %d vehicles  /  %d seats for %d attackers\nEAST BLOCKADE  /  %d vehicles  /  %d seats for %d defenders"%[config.attacker.vehicles.size(),summary.get("units",0),config.attacker.units.size(),config.defender.get("vehicles",[]).size(),defense.get("units",0),config.defender.units.size()]
 status.text=error_override if not error_override.is_empty() else ("Ready. Each convoy uses its own units as drivers.\nEsc returns here after a battle; your setup is retained." if check.valid else check.error)
 status.add_theme_color_override("font_color",Color("#d68c87") if not error_override.is_empty() or not check.valid else Color("#acb9a8"))
func show_error(message: String):error_override=message;refresh_status()
func launch():
 if Config.validate(config).valid:launch_requested.emit(config.duplicate(true))
func open_fleet(side: String="attacker"):
 if has_node("VehicleFleet"):return
 var fleet=FleetPanel.new();fleet.name="VehicleFleet";fleet.required_units=config[side].units.size();fleet.faction_id=config[side].faction;fleet.selected=config[side].get("vehicles",[]).duplicate();fleet.allow_encounter_lab=false
 fleet.convoy_selected.connect(func(models):config[side].vehicles=models.duplicate();changed())
 add_child(fleet)

func choose_map(id: String):
 config.map_id=id
 if id=="river_bridge" and not config.defender.has("vehicles"):
  config.defender.vehicles=Config.auto_convoy(config.defender.units.size())
 changed()
