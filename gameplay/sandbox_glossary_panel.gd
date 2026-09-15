extends Control
const FactionPreview = preload("res://gameplay/faction_audio_preview.gd")
const MenuEmblem = preload("res://gameplay/sandbox_emblem.gd")
const Factions = preload("res://battle/identity/faction_unit_catalog.gd")
const Weapons = preload("res://battle/combat/battle_weapon_catalog.gd")
const Vehicles = preload("res://campaign/vehicles/vehicle_model_catalog.gd")
const Anim = preload("res://battle/presentation/tactical_unit_animation_catalog.gd")
const Card = preload("res://gameplay/tactical_unit_card.gd")
const CLASSES = ["pistol","smg","shotgun","rifle","sniper"]
const INK = Color("#dedfd1")
const MUTED = Color("#9daea8")
const TAN = Color("#d2bf8d")
signal fleet_requested
var mode = "factions"
var selected_id = "mercer"
var selected_class = "pistol"
var data: Dictionary = {}
var font: SystemFont
var search: LineEdit
var list: VBoxContainer
var list_scroll: ScrollContainer
var detail: Control
var detail_scroll: ScrollContainer
var tiles: GridContainer
var class_buttons = {}
var item_buttons = {}
var unit_images = {}
var visible_models: Array = []
var detail_labels = {}
var active_texture: TextureRect
var selected_faction_rows: Dictionary = {}
var leader_image: TextureRect
var faction_audio: Node
var audio_button: Button

func _ready():
	size = Vector2(1152,764)
	mouse_filter = Control.MOUSE_FILTER_STOP
	font = SystemFont.new(); font.font_names = PackedStringArray(["Arial"])
	if mode == "factions":
		var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://assets/data/faction_glossary.json"))
		if parsed is Dictionary: data = parsed.get("factions",{})
		faction_audio=FactionPreview.new();add_child(faction_audio)
		faction_audio.playback_changed.connect(update_audio_button)
		visibility_changed.connect(func():
			if not is_visible_in_tree():faction_audio.stop())
		tree_exiting.connect(faction_audio.stop)
		build_factions()
	else: build_equipment()

func label(parent: Node, at: Vector2, dimensions: Vector2, text: String, points: int = 14, color: Color = INK) -> Label:
	var result = Card.label(parent,at,dimensions,text,points,color,font)
	result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return result

func panel(parent: Node, at: Vector2, dimensions: Vector2) -> Panel:
	var result = Panel.new(); parent.add_child(result)
	result.position = at; result.size = dimensions
	result.add_theme_stylebox_override("panel",Card.style(Color("#1b282c"),Color("#3c4d4b")))
	return result

func picture(parent: Node, at: Vector2, dimensions: Vector2, texture: Texture2D) -> TextureRect:
	var result = TextureRect.new(); parent.add_child(result)
	result.position = at; result.size = dimensions; result.texture = texture
	result.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	result.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	result.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return result

func button(parent: Node, text: String, at: Vector2, dimensions: Vector2, action: Callable) -> Button:
	var result = Button.new(); parent.add_child(result)
	result.position = at; result.custom_minimum_size = dimensions; result.size = dimensions
	result.text = text; result.add_theme_font_override("font",font)
	result.add_theme_font_size_override("font_size",12)
	result.add_theme_stylebox_override("normal",Card.style(Color("#243237"),Color("#425451")))
	result.add_theme_stylebox_override("hover",Card.style(Color("#35423d"),TAN))
	result.add_theme_stylebox_override("focus",Card.style(Color(0,0,0,0),TAN))
	result.pressed.connect(action)
	return result

func clear(parent: Node):
	for child in parent.get_children(): parent.remove_child(child); child.queue_free()

func build_factions():
	label(self,Vector2(24,8),Vector2(760,30),"FACTION GLOSSARY",19,TAN)
	search = LineEdit.new(); add_child(search)
	search.position = Vector2(24,48); search.size = Vector2(248,34)
	search.placeholder_text = "Search factions or leaders"
	search.add_theme_font_size_override("font_size",12)
	search.text_changed.connect(func(_value):refresh_faction_list())
	list_scroll = ScrollContainer.new(); add_child(list_scroll)
	list_scroll.position = Vector2(24,96); list_scroll.size = Vector2(248,642)
	list_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	list = VBoxContainer.new(); list_scroll.add_child(list)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL; list.add_theme_constant_override("separation",6)
	detail = Control.new(); add_child(detail); detail.position = Vector2(296,8); detail.size = Vector2(832,730)
	refresh_faction_list(); show_faction(selected_id)

func leader_for(id: String) -> String:
	return str(data.get(id,{}).get("leader_display",Factions.profile(id).get("leader","Undisclosed")))

func refresh_faction_list():
	clear(list); item_buttons.clear()
	for id in Factions.all_ids():
		var needle = search.text.strip_edges().to_lower()
		var haystack = (Factions.display_name(id)+" "+leader_for(id)).to_lower()
		if not needle.is_empty() and needle not in haystack and needle.replace(" ","") not in haystack.replace(" ",""): continue
		var b = button(list,"",Vector2.ZERO,Vector2(230,58),show_faction.bind(id))
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		MenuEmblem.apply(picture(b,Vector2(8,9),Vector2(38,38),null),id)
		label(b,Vector2(55,6),Vector2(172,48),Factions.display_name(id),12)
		b.tooltip_text = Factions.display_name(id)
		item_buttons[id] = b
	if item_buttons.is_empty(): label(list,Vector2.ZERO,Vector2(232,48),"No matching factions.",13,MUTED)
	mark_faction()

func mark_faction():
	for id in item_buttons:
		item_buttons[id].add_theme_stylebox_override("normal",Card.style(Color("#39443b") if id==selected_id else Color("#243237"),TAN if id==selected_id else Color("#425451")))

func toggle_faction_audio():
	if faction_audio.current_faction==selected_id:faction_audio.stop()
	else:faction_audio.play_faction(selected_id)

func update_audio_button():
	if not is_instance_valid(audio_button):return
	var playing=faction_audio.current_faction==selected_id
	audio_button.icon=faction_audio.icon(playing)
	audio_button.tooltip_text="Stop faction audio" if playing else "Play faction audio"
	audio_button.set_meta("playing",playing)

func show_faction(id: String):
	faction_audio.stop()
	selected_id = id; clear(detail); unit_images.clear(); detail_labels.clear(); leader_image=null; mark_faction()
	var row: Dictionary = data.get(id,{})
	selected_faction_rows = row
	MenuEmblem.apply(picture(detail,Vector2(0,0),Vector2(96,96),null),id)
	detail_labels.title = label(detail,Vector2(114,0),Vector2(498,65),Factions.display_name(id),25)
	detail_labels.leader = label(detail,Vector2(114,71),Vector2(498,35),"LEADER  /  "+leader_for(id),15,TAN)
	var photo_path = str(row.get("leader_photo",""))
	if not photo_path.is_empty():
		leader_image=picture(detail,Vector2(630,0),Vector2(202,252),Anim._load_texture(photo_path))
		leader_image.texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR
		leader_image.set_meta("faction",id)
		leader_image.tooltip_text=leader_for(id)
	else:
		var pending=panel(detail,Vector2(630,0),Vector2(202,252))
		label(pending,Vector2(18,98),Vector2(166,66),"LEADERSHIP\nUNDISCLOSED",13,MUTED)
	var story = panel(detail,Vector2(0,116),Vector2(612,158))
	label(story,Vector2(18,14),Vector2(576,23),str(row.get("kind","Organization")).to_upper(),12,TAN)
	detail_labels.description = label(story,Vector2(18,45),Vector2(576,102),str(row.get("description","")),16)
	label(detail,Vector2(630,260),Vector2(150,27),"Faction Audio",13,TAN)
	audio_button=button(detail,"",Vector2(794,257),Vector2(34,32),toggle_faction_audio)
	audio_button.name="FactionAudioToggle";audio_button.icon_alignment=HORIZONTAL_ALIGNMENT_CENTER
	audio_button.disabled=not faction_audio.available(id)
	update_audio_button()
	if audio_button.disabled:audio_button.tooltip_text="Faction audio unavailable"
	label(detail,Vector2(0,296),Vector2(800,28),"REGULAR UNITS",16,TAN)
	for i in range(CLASSES.size()):
		var role: String = CLASSES[i]
		var model_id: String = row.get("weapons",{}).get(role,Weapons.default_model(role))
		var weapon = Weapons.get_model(model_id)
		var tile = panel(detail,Vector2(i*168,336),Vector2(160,345))
		label(tile,Vector2(12,14),Vector2(136,25),role.to_upper(),14,TAN)
		var variant = Anim.variant_for(id,role,model_id)
		var texture = Anim._load_texture(Anim.atlas_path(variant,"portraits"))
		var unit_image = picture(tile,Vector2(8,48),Vector2(144,167),texture)
		unit_image.set_meta("faction",id); unit_image.set_meta("weapon",model_id); unit_image.set_meta("variant",variant)
		unit_images[role] = unit_image
		label(tile,Vector2(12,235),Vector2(136,52),weapon.display_name,14)
		label(tile,Vector2(12,302),Vector2(136,25),"WEAPON TIER %d"%weapon.tier,11,MUTED)

func build_equipment():
	if mode=="vehicles": selected_class="two_wheelers"
	label(self,Vector2(24,8),Vector2(950,29),"ARSENAL" if mode=="arsenal" else "VEHICLES",19,TAN)
	if mode=="vehicles": button(self,"FLEET & ENCOUNTER LAB",Vector2(862,4),Vector2(266,32),func():fleet_requested.emit())
	var classes: Array = CLASSES if mode=="arsenal" else Vehicles.data().classes.keys()
	for i in range(classes.size()):
		var id: String = classes[i]
		var width = 212 if mode=="arsenal" else 266
		var title = id.to_upper() if mode=="arsenal" else Vehicles.class_name_for(id).to_upper()
		class_buttons[id] = button(self,title,Vector2(24+i*(width+9),48),Vector2(width,34),choose_class.bind(id))
	var scroll = ScrollContainer.new(); add_child(scroll)
	scroll.position = Vector2(24,98); scroll.size = Vector2(512,640)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	list_scroll = scroll
	tiles = GridContainer.new(); scroll.add_child(tiles)
	tiles.columns = 2; tiles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tiles.add_theme_constant_override("h_separation",10); tiles.add_theme_constant_override("v_separation",10)
	detail_scroll = ScrollContainer.new(); add_child(detail_scroll)
	detail_scroll.position = Vector2(558,98); detail_scroll.size = Vector2(570,640)
	detail_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	detail = Control.new(); detail_scroll.add_child(detail)
	detail.custom_minimum_size = Vector2(550,640); detail.size = detail.custom_minimum_size
	choose_class(selected_class)

func choose_class(id: String):
	selected_class = id; clear(tiles); item_buttons.clear(); visible_models.clear()
	list_scroll.scroll_vertical = 0
	for key in class_buttons:
		class_buttons[key].add_theme_stylebox_override("normal",Card.style(Color("#39443b") if key==id else Color("#243237"),TAN if key==id else Color("#425451")))
	var ids: Array = Weapons.models_for_class(id) if mode=="arsenal" else Vehicles.all_ids().filter(func(key):return Vehicles.model(key).vehicle_class==id)
	if mode=="vehicles":
		ids.sort_custom(func(a,b):
			var left=int(Vehicles.model(a).price)
			var right=int(Vehicles.model(b).price)
			return str(Vehicles.model(a).name).naturalnocasecmp_to(str(Vehicles.model(b).name))<0 if left==right else left<right)
	for model_id in ids:
		visible_models.append(model_id)
		var model = Weapons.get_model(model_id) if mode=="arsenal" else Vehicles.model(model_id)
		var b = button(tiles,"",Vector2.ZERO,Vector2(245,169),show_equipment.bind(model_id))
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var title = model.display_name if mode=="arsenal" else model.name
		label(b,Vector2(12,10),Vector2(219,40),title,14)
		picture(b,Vector2(12,53),Vector2(219,76),equipment_texture(model_id))
		var footer = "TIER %d  /  $%s"%[model.tier,money(Weapons.purchase_price(model_id))] if mode=="arsenal" else "%d SEATS  /  $%s"%[model.unit_capacity,money(model.price)]
		label(b,Vector2(12,141),Vector2(219,20),footer,11,TAN)
		item_buttons[model_id]=b
	if not ids.is_empty(): show_equipment(ids[0])

func money(value) -> String:
	var source = str(int(value)); var result = ""
	for i in range(source.length()):
		if i>0 and (source.length()-i)%3==0: result+=","
		result+=source[i]
	return result

func equipment_texture(id: String) -> Texture2D:
	return Anim._load_texture("res://assets/art/weapons/arsenal/icons/"+id+".png") if mode=="arsenal" else Vehicles.icon(id)

func stat(label_text: String, value: String, y: float, hint: String = ""):
	var left = label(detail,Vector2(18,y),Vector2(300,24),label_text,14,MUTED)
	var right = label(detail,Vector2(326,y),Vector2(204,24),value,14)
	left.tooltip_text=hint; right.tooltip_text=hint
	left.mouse_filter=Control.MOUSE_FILTER_PASS; right.mouse_filter=Control.MOUSE_FILTER_PASS
	detail_labels[label_text]=right

func show_equipment(id: String):
	selected_id=id; clear(detail); detail_labels.clear(); detail_scroll.scroll_vertical=0
	for key in item_buttons:
		item_buttons[key].add_theme_stylebox_override("normal",Card.style(Color("#39443b") if key==id else Color("#243237"),TAN if key==id else Color("#425451")))
	var m = Weapons.get_model(id) if mode=="arsenal" else Vehicles.model(id)
	panel(detail,Vector2.ZERO,Vector2(550,252))
	detail_labels.title=label(detail,Vector2(18,14),Vector2(514,62),m.display_name if mode=="arsenal" else m.name,25)
	active_texture=picture(detail,Vector2(24,81),Vector2(502,123),equipment_texture(id))
	label(detail,Vector2(18,218),Vector2(514,25),("%s  /  WEAPON TIER %d"%[m.weapon_type_id.to_upper(),m.tier]) if mode=="arsenal" else Vehicles.class_name_for(m.vehicle_class).to_upper(),13,TAN)
	if mode=="arsenal":
		var rows=[
			["Price","$"+money(Weapons.purchase_price(id)),"Purchase price per firearm. Unit recruitment and training are separate."],
			["Range","%.1f"%m.max_range,"Maximum firing distance in battlefield units."],
			["Fire rate","%.2f shots / sec"%m.shots_per_second,"Shot pace while firing. Aiming, movement and reloads can slow it."],
			["Movement","%+.0f%%"%((m.movement_multiplier-1.)*100.),"Change to the unit's normal movement speed while carrying this weapon."],
			["Standard hit damage","%.2f"%m.solid_trauma,"Health damage from a solid hit."],
			["Critical hit damage","%.2f"%m.critical_trauma,"Health damage from a critical hit."],
			["Graze damage","%.2f"%m.graze_trauma,"Health damage from a grazing hit."],
			["Initial aim","%.2f sec"%m.acquire_seconds,"Time to acquire an initial shot."],
			["Aim recovery","%.2f sec"%m.reacquire_seconds,"Time to reacquire a shot after losing settled aim."],
			["Shots before reload",str(m.magazine_capacity),"Shots per magazine before the next reload."],
			["Reload cycle","%.1f sec"%m.reload_seconds,"The reload duration used by this weapon's class."],
			["Recoil per shot","%.3f"%m.recoil_per_shot,"How much each shot unsettles aim."],
			["Recoil recovery","%.3f"%m.recoil_recovery,"How quickly accumulated recoil settles."],
			["Base solid hit chance","%.0f%%"%(m.solid_probability*100.),"Chance before battle conditions and unit bonuses."],
			["Base critical hit chance","%.0f%%"%(m.critical_probability*100.),"Chance before battle conditions and unit bonuses."],
			["Base graze chance","%.0f%%"%(m.graze_probability*100.),"Chance before battle conditions and unit bonuses."],
			["Base miss chance","%.0f%%"%(m.miss_probability*100.),"Chance before battle conditions and unit bonuses."]]
		for i in range(rows.size()): stat(rows[i][0],rows[i][1],275+i*30,rows[i][2])
		label(detail,Vector2(18,275+rows.size()*30+15),Vector2(514,53),"Weapon stats before unit-tier bonuses. Range uses battlefield units; damage is health lost on that hit.",12,MUTED)
		detail.custom_minimum_size.y=275+rows.size()*30+83
	else:
		label(detail,Vector2(18,270),Vector2(514,72),m.description,14)
		stat("Seats, including driver",str(int(m.unit_capacity)),354)
		stat("Road movement","%.1f / turn"%m.movement_per_turn,386)
		stat("Price","$"+money(m.price),418)
		stat("Upkeep","$%s / turn"%money(m.upkeep_per_turn),450)
		stat("Resource capacity",str(int(m.resource_capacity)),482)
		stat("Protective cover","Yes" if m.cover else "No",514)
		stat("Doors",str(int(m.doors)),546)
		stat("Length / width / height","%.1f / %.1f / %.1f m"%[m.length,m.width,m.height],578)
		var y=621.0
		if m.get("service_role","")=="bank_cash":
			stat("Cash capacity","$"+money(m.cash_capacity),y); y+=38
		elif m.get("service_role","")=="prisoner_transfer":
			label(detail,Vector2(18,y),Vector2(514,42),"CUSTODY TRANSPORT  /  3 guards + 8 prisoners",13,TAN);y+=50
		if not str(m.get("ability_name","")).is_empty():
			label(detail,Vector2(18,y),Vector2(514,28),str(m.ability_name).to_upper(),15,TAN);y+=36
			label(detail,Vector2(18,y),Vector2(514,60),str(m.ability_summary),14);y+=68
			label(detail,Vector2(18,y),Vector2(514,112),str(m.ability_limits),13,MUTED);y+=120
		label(detail,Vector2(18,y),Vector2(514,54),"Convoys travel at their slowest vehicle's pace. Vehicle abilities can be tried in the Encounter Lab." if m.get("ability_status","")=="encounter_lab" else "Convoys travel at their slowest vehicle's pace. Seats include the driver.",12,MUTED)
		detail.custom_minimum_size.y=maxf(660,y+68)
