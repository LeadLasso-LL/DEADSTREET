extends Control
# Screen-space tactical roster and whole-force controls. Simulation owns all state.
const Factions = preload("res://battle/identity/faction_unit_catalog.gd")
const Query = preload("res://gameplay/tactical_unit_hud_query.gd")
const Commands = preload("res://battle/core/battle_force_command_service.gd")
const Catalog = preload("res://battle/core/battle_force_command_catalog.gd")
const Anim = preload("res://battle/presentation/tactical_unit_animation_catalog.gd")
const Card=preload("res://gameplay/tactical_unit_card.gd")
const HEIGHT = 180.0
const ROLES = ["smg", "rifle", "pistol", "shotgun", "sniper"]
const NAMES = {"smg":"IMI UZI", "rifle":"AK-47", "pistol":"GLOCK 17", "shotgun":"REMINGTON 870"}
const LABELS = {"push":"PUSH", "hold":"HOLD", "focus_left":"FOCUS LEFT", "focus_right":"FOCUS RIGHT", "fall_back":"FALL BACK"}
const TIPS = {"push":"Increase forward pressure and willingness to advance.", "hold":"Maintain local ground and avoid unnecessary chasing.", "focus_left":"Bias the force toward its left flank.", "focus_right":"Bias the force toward its right flank.", "fall_back":"Retreat toward the deployment side while remaining engaged."}
var strength_label: Label
var strength_fill: ColorRect
var strength_value=.5
var strength_battle_id=0
var view: Node
var surface: Control
var cards: Dictionary = {}
var buttons: Dictionary = {}
var textures: Dictionary = {}
var faction_label: Label
var command_label: Label
var battle_label: Label
var font: SystemFont
var normal_style: StyleBoxFlat
var page_index=0
var last_selected=""
var roster_pages=1
var page_label: Label
var page_back: Button
var page_next: Button
var active_style: StyleBoxFlat

func setup(p_view: Node) -> void:
 view=p_view
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 mouse_filter=Control.MOUSE_FILTER_IGNORE
 font=SystemFont.new();font.font_names=PackedStringArray(["Arial"]);font.font_weight=600
 normal_style=style(Color("#20282b"),Color("#475153"))
 active_style=style(Color("#41443b"),Color("#b9ad83"))
 surface=Control.new();add_child(surface);surface.mouse_filter=Control.MOUSE_FILTER_STOP
 var bg=Panel.new();surface.add_child(bg);bg.position=Vector2(12,0);bg.size=Vector2(1128,HEIGHT-8);bg.add_theme_stylebox_override("panel",style(Color("#11191d"),Color("#444e50")))
 bg.mouse_filter=Control.MOUSE_FILTER_IGNORE
 faction_label=label(surface,Vector2(28,10),Vector2(306,18),"OPERATIVES",12,Color("#c4cbbf"))
 strength_label=label(surface,Vector2(350,5),Vector2(276,12),"RELATIVE STRENGTH  /  EVEN",9,Color("#bfc8ba"))
 var strength_bg=ColorRect.new();surface.add_child(strength_bg);strength_bg.position=Vector2(350,22);strength_bg.size=Vector2(272,6);strength_bg.color=Color("#a15e68");strength_bg.mouse_filter=Control.MOUSE_FILTER_IGNORE
 strength_fill=ColorRect.new();strength_bg.add_child(strength_fill);strength_fill.size=Vector2(136,6);strength_fill.color=Color("#83b899");strength_fill.mouse_filter=Control.MOUSE_FILTER_IGNORE
 var midpoint=ColorRect.new();strength_bg.add_child(midpoint);midpoint.position=Vector2(135,0);midpoint.size=Vector2(2,6);midpoint.color=Color("#e0dfc9");midpoint.mouse_filter=Control.MOUSE_FILTER_IGNORE
 battle_label=label(surface,Vector2(660,10),Vector2(452,18),"COMMAND CENTER",12,Color("#c4cbbf"))
 for i in range(5):
  cards[i]=Card.build(surface,Vector2(28+i*151,34),font)
  cards[i].root.pressed.connect(select_card.bind(i))
 page_label=label(surface,Vector2(255,159),Vector2(150,18),"",10,Color("#b9c2b1"));page_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 page_back=Button.new();surface.add_child(page_back);page_back.position=Vector2(211,158);page_back.size=Vector2(38,20);page_back.text="‹";page_back.pressed.connect(func():set_roster_page(page_index-1))
 page_next=Button.new();surface.add_child(page_next);page_next.position=Vector2(411,158);page_next.size=Vector2(38,20);page_next.text="›";page_next.pressed.connect(func():set_roster_page(page_index+1))
 for control in [page_back,page_next]:
  control.add_theme_font_size_override("font_size",11)
  var small=style(Color("#243136"),Color("#60706a"));small.content_margin_top=0.;small.content_margin_bottom=0.;small.content_margin_left=2.;small.content_margin_right=2.
  control.add_theme_stylebox_override("normal",small);control.add_theme_stylebox_override("hover",small);control.add_theme_stylebox_override("pressed",small);control.add_theme_stylebox_override("disabled",small)
 var command_ids=["push","hold","fall_back","focus_left","focus_right"]
 for i in range(command_ids.size()):
  var id: String=command_ids[i]
  var b=Button.new();surface.add_child(b);b.text=LABELS[id];b.tooltip_text=TIPS[id];b.focus_mode=Control.FOCUS_NONE
  b.position=Vector2(660+(i%3)*150,35+(i/3)*39);b.size=Vector2(142,31)
  if i>=3:b.position=Vector2(660+(i-3)*225,74);b.size=Vector2(217,31)
  b.add_theme_font_override("font",font);b.add_theme_font_size_override("font_size",12)
  b.add_theme_color_override("font_color",Color("#d4d8cc"));b.add_theme_color_override("font_disabled_color",Color("#74807d"))
  b.add_theme_stylebox_override("normal",normal_style);b.add_theme_stylebox_override("hover",active_style);b.add_theme_stylebox_override("pressed",active_style);b.add_theme_stylebox_override("disabled",normal_style)
  b.pressed.connect(issue_command.bind(id));buttons[id]=b
 command_label=label(surface,Vector2(660,119),Vector2(442,16),"CURRENT ORDER  /  HOLD",11,Color("#b4ae94"))
 var ids=CheckButton.new();surface.add_child(ids);ids.position=Vector2(654,137);ids.size=Vector2(150,24);ids.text="UNIT EMBLEMS";ids.button_pressed=true;ids.focus_mode=Control.FOCUS_NONE
 ids.add_theme_font_override("font",font);ids.add_theme_font_size_override("font_size",9)
 ids.toggled.connect(func(value):view.battle_presentation.identifiers_enabled=value)
 var sound=CheckButton.new();surface.add_child(sound);sound.position=Vector2(840,137);sound.size=Vector2(125,24);sound.text="AUDIO";sound.button_pressed=true;sound.focus_mode=Control.FOCUS_NONE
 sound.add_theme_font_override("font",font);sound.add_theme_font_size_override("font_size",9)
 sound.toggled.connect(func(value):view.battle_presentation.audio_enabled=value)

func style(fill: Color,border: Color) -> StyleBoxFlat:
 var s=StyleBoxFlat.new();s.bg_color=fill;s.border_color=border;s.set_border_width_all(1);s.set_corner_radius_all(2);return s

func label(parent: Node,at: Vector2,sz: Vector2,text: String,points: int,color: Color) -> Label:
 var l=Label.new();parent.add_child(l);l.position=at;l.size=sz;l.text=text;l.add_theme_font_override("font",font);l.add_theme_font_size_override("font_size",points);l.add_theme_color_override("font_color",color);l.mouse_filter=Control.MOUSE_FILTER_IGNORE;return l

func _process(_delta: float) -> void:
 if view==null or not is_instance_valid(view):return
 var battle=view._battle_state()
 visible=view.visible and view._is_dusk_street() and battle!=null and battle.battle_phase in ["active","resolved"]
 if visible and view.battle_presentation!=null:visible=not view.battle_presentation.results_visible()
 if not visible:return
 var viewport_size=get_viewport_rect().size
 var factor=viewport_size.x/1152.0
 surface.scale=Vector2.ONE*factor;surface.position=Vector2(0,viewport_size.y-HEIGHT*factor);surface.size=Vector2(1152,HEIGHT)
 if strength_battle_id!=battle.get_instance_id():strength_battle_id=battle.get_instance_id();strength_value=.5;page_index=0;last_selected=""
 if not battle.strength_snapshot.is_empty():
  var share=float(battle.strength_snapshot.shares.get(Query.player_side_id(battle),.5))
  strength_value=move_toward(strength_value,share,maxf(0.,_delta)*.5)
  strength_fill.size.x=272*strength_value
  strength_label.text="RELATIVE STRENGTH  /  "+("ADVANTAGE" if share>.55 else ("DISADVANTAGE" if share<.45 else "EVEN"))
 var selected: String=view._selected_participant_id()
 var units: Array=Query.friendly_cards(battle,selected)
 units.sort_custom(func(a,b):return a.participant_id<b.participant_id if a.weapon_type==b.weapon_type else ROLES.find(a.weapon_type)<ROLES.find(b.weapon_type))
 roster_pages=maxi(1,ceili(float(units.size())/5.));page_index=clampi(page_index,0,roster_pages-1)
 if selected!=last_selected:
  last_selected=selected
  for index in range(units.size()):
   if units[index].participant_id==selected:page_index=index/5;break
 page_back.visible=roster_pages>1;page_next.visible=roster_pages>1;page_label.visible=roster_pages>1
 page_back.disabled=page_index==0;page_next.disabled=page_index==roster_pages-1
 page_label.text="UNITS %d–%d / %d"%[page_index*5+1,mini((page_index+1)*5,units.size()),units.size()]
 var alive=0
 for unit in units:
  if unit.is_alive:alive+=1
 for i in range(5):
  var unit_index=page_index*5+i
  var widgets: Dictionary=cards[i];widgets.root.visible=unit_index<units.size()
  var compact: bool=units.size()>4
  widgets.root.position.x=28+i*(120 if compact else 151)
  widgets.root.scale=Vector2(.81 if compact else 1.,1.)
  if unit_index>=units.size():continue
  var c: Dictionary=units[unit_index];var p=battle.get_participant(c.participant_id)
  widgets.id=c.participant_id
  Card.update(widgets,p,selected)
  widgets.root.tooltip_text="OPERATIVE %02d\n"%(unit_index+1)+widgets.root.tooltip_text
 var faction="ATTACKERS"
 if not units.is_empty():
  var p=battle.get_participant(units[0].participant_id)
  if p.has_identity():
   var profile=Factions.profile(p.identity.gang_archetype_id)
   faction=str(profile.get("hud_name",profile.get("name",p.identity.gang_archetype_id))).to_upper()
 faction_label.text=faction+"  /  %d OPERATIVES"%alive
 var title_size=12
 while title_size>8 and font.get_string_size(faction_label.text,HORIZONTAL_ALIGNMENT_LEFT,-1,title_size).x>306:title_size-=1
 faction_label.add_theme_font_size_override("font_size",title_size)
 var order=current_order(battle)
 command_label.text="CURRENT ORDER  /  "+LABELS.get(order,"MIXED")
 for id in buttons:
  buttons[id].disabled=battle.battle_phase!="active"
  buttons[id].add_theme_stylebox_override("normal",active_style if id==order else normal_style)

func current_order(battle) -> String:
 var found=""
 for id in battle.get_sorted_tactical_force_ids():
  var force=battle.get_tactical_force(id)
  if force.side_id!=Query.player_side_id(battle):continue
  if found.is_empty():found=force.command_id
  elif found!=force.command_id:return "mixed"
 return found

func issue_command(id: String) -> void:
 var battle=view._battle_state()
 if battle==null or battle.battle_phase!="active" or not Catalog.is_valid_command(id):return
 for force_id in battle.get_sorted_tactical_force_ids():
  var force=battle.get_tactical_force(force_id)
  if force.side_id==Query.player_side_id(battle):Commands.set_command(battle,force_id,id)

func set_roster_page(index: int) -> void:
 # Refresh card IDs with the page change, before another input can select one.
 _process(0.)
 page_index=clampi(index,0,roster_pages-1)
 _process(0.)

func select_card(index: int) -> void:
 if view.orders_controller!=null:view.orders_controller.select_participant(str(cards[index].id))
