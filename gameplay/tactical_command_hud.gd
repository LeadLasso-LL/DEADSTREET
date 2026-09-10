extends Control
# Screen-space tactical roster and whole-force controls. Simulation owns all state.
const Query = preload("res://gameplay/tactical_unit_hud_query.gd")
const Commands = preload("res://battle/core/battle_force_command_service.gd")
const Catalog = preload("res://battle/core/battle_force_command_catalog.gd")
const Anim = preload("res://battle/presentation/tactical_unit_animation_catalog.gd")
const HEIGHT = 180.0
const ROLES = ["smg", "rifle", "pistol", "shotgun"]
const NAMES = {"smg":"IMI UZI", "rifle":"AK-47", "pistol":"GLOCK 17", "shotgun":"REMINGTON 870"}
const LABELS = {"push":"PUSH", "hold":"HOLD", "focus_left":"FOCUS LEFT", "focus_right":"FOCUS RIGHT", "fall_back":"FALL BACK"}
const TIPS = {"push":"Increase forward pressure and willingness to advance.", "hold":"Maintain local ground and avoid unnecessary chasing.", "focus_left":"Bias the force toward its left flank.", "focus_right":"Bias the force toward its right flank.", "fall_back":"Retreat toward the deployment side while remaining engaged."}
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
 faction_label=label(surface,Vector2(28,10),Vector2(570,18),"ORLOV BRATVA  /  OPERATIVES",12,Color("#c4cbbf"))
 battle_label=label(surface,Vector2(660,10),Vector2(452,18),"COMMAND CENTER",12,Color("#c4cbbf"))
 for i in range(4):
  var card=Button.new();surface.add_child(card);card.position=Vector2(28+i*151,34);card.size=Vector2(141,124);card.focus_mode=Control.FOCUS_NONE
  card.add_theme_stylebox_override("normal",style(Color("#252f32"),Color("#465254")))
  card.add_theme_stylebox_override("hover",active_style);card.add_theme_stylebox_override("pressed",active_style)
  card.add_theme_stylebox_override("disabled",style(Color("#231e21"),Color("#5c343b")))
  var status=label(card,Vector2(8,4),Vector2(125,12),"ACTIVE",9,Color("#83b889"));status.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
  var portrait=TextureRect.new();card.add_child(portrait);portrait.position=Vector2(9,19);portrait.size=Vector2(123,62)
  portrait.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;portrait.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;portrait.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;portrait.mouse_filter=Control.MOUSE_FILTER_IGNORE
  var role=label(card,Vector2(8,83),Vector2(125,15),"",12,Color("#e3e1d3"));role.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
  var gun=label(card,Vector2(5,100),Vector2(131,13),"",10,Color("#9caba9"));gun.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
  var bar_bg=ColorRect.new();card.add_child(bar_bg);bar_bg.position=Vector2(9,116);bar_bg.size=Vector2(123,4);bar_bg.color=Color("#11181c");bar_bg.mouse_filter=Control.MOUSE_FILTER_IGNORE
  var health=ColorRect.new();card.add_child(health);health.position=Vector2(9,116);health.size=Vector2(123,4);health.color=Color("#7da986");health.mouse_filter=Control.MOUSE_FILTER_IGNORE
  cards[i]={"root":card,"status":status,"portrait":portrait,"role":role,"gun":gun,"health":health,"id":""}
  card.pressed.connect(select_card.bind(i))
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
 label(surface,Vector2(660,142),Vector2(450,14),"WHOLE FORCE   /   SELECT AN OPERATIVE TO DIRECT INDIVIDUALLY",8,Color("#728582"))

func style(fill: Color,border: Color) -> StyleBoxFlat:
 var s=StyleBoxFlat.new();s.bg_color=fill;s.border_color=border;s.set_border_width_all(1);s.set_corner_radius_all(2);return s

func label(parent: Node,at: Vector2,sz: Vector2,text: String,points: int,color: Color) -> Label:
 var l=Label.new();parent.add_child(l);l.position=at;l.size=sz;l.text=text;l.add_theme_font_override("font",font);l.add_theme_font_size_override("font_size",points);l.add_theme_color_override("font_color",color);l.mouse_filter=Control.MOUSE_FILTER_IGNORE;return l

func _process(_delta: float) -> void:
 if view==null or not is_instance_valid(view):return
 var battle=view._battle_state()
 visible=view.visible and view._is_dusk_street() and battle!=null and battle.battle_phase in ["active","resolved"]
 if not visible:return
 var viewport_size=get_viewport_rect().size
 var factor=viewport_size.x/1152.0
 surface.scale=Vector2.ONE*factor;surface.position=Vector2(0,viewport_size.y-HEIGHT*factor);surface.size=Vector2(1152,HEIGHT)
 var selected: String=view._selected_participant_id()
 var units: Array=Query.friendly_cards(battle,selected)
 units.sort_custom(func(a,b):return ROLES.find(a.weapon_type)<ROLES.find(b.weapon_type))
 var alive=0
 for i in range(4):
  var widgets: Dictionary=cards[i];widgets.root.visible=i<units.size()
  if i>=units.size():continue
  var c: Dictionary=units[i];var p=battle.get_participant(c.participant_id)
  widgets.id=c.participant_id
  var state: String="DEAD" if not c.is_alive else ("WOUNDED" if c.is_wounded else "ACTIVE")
  var tint=Color("#d7656a") if state=="DEAD" else (Color("#ddbd72") if state=="WOUNDED" else Color("#83b889"))
  widgets.status.text=state;widgets.status.add_theme_color_override("font_color",tint)
  widgets.root.disabled=not c.can_select
  widgets.root.add_theme_stylebox_override("normal",active_style if c.is_selected else normal_style)
  widgets.role.text=c.weapon_type.to_upper()+" 1"
  widgets.gun.text=NAMES.get(c.weapon_type,c.weapon_type.to_upper())+"  /  T1"
  widgets.health.size=Vector2(123.0*float(c.vitality_ratio),4.0)
  widgets.health.color=Color("#c6a368") if state=="WOUNDED" else Color("#7da986")
  widgets.portrait.modulate=Color(.72,.22,.26) if state=="DEAD" else (Color(1.,.72,.72) if state=="WOUNDED" else Color.WHITE)
  var variant: String=Anim.variant_for(p.identity.gang_archetype_id,p.weapon_type)
  if not textures.has(variant):
   var path="res://assets/art/units/pixel_v1/portraits/"+variant+".png"
   textures[variant]=load(path) if ResourceLoader.exists(path) else null
  widgets.portrait.texture=textures[variant]
  if c.is_alive:alive+=1
 var faction="ORLOV BRATVA"
 if not units.is_empty():
  var p=battle.get_participant(units[0].participant_id)
  if p.identity.gang_archetype_id=="local_street_gang":faction="MERCER SAINTS"
 faction_label.text=faction+"  /  %d OPERATIVES"%alive
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

func select_card(index: int) -> void:
 if view.orders_controller!=null:view.orders_controller.select_participant(str(cards[index].id))
