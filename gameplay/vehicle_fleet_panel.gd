extends Control
const Formation=preload("res://campaign/vehicles/convoy_formation_catalog.gd")
const Models=preload("res://campaign/vehicles/vehicle_model_catalog.gd")
const Factions=preload("res://battle/identity/faction_unit_catalog.gd")
const Card=preload("res://gameplay/tactical_unit_card.gd")
const Rules=preload("res://gameplay/sandbox_convoy_rules.gd")
signal convoy_selected(models: Array)
signal blockade_battle_requested(context: Dictionary)
var faction_id="mercer"
var selected: Array=["bayou","bayou"]
var selected_class="passenger_cars"
var required_units=5
var allow_encounter_lab=true
var grid: GridContainer
var convoy_row: Control
var status: Label
var apply_button: Button
var preferred: CheckBox
var font: SystemFont
var class_buttons={}
var model_buttons={}
var seat_bar: Control
var slot_label: Label
var background: ColorRect
var crew_label: Label
var packing_hint: Label
func _ready():
 size=Vector2(1504,860);mouse_filter=Control.MOUSE_FILTER_STOP
 font=SystemFont.new();font.font_names=PackedStringArray(["Arial"])
 background=ColorRect.new();add_child(background);background.size=size;background.color=Color("#111b20")
 label_at(Vector2(24,15),Vector2(860,34),"BUILD YOUR CONVOY",25)
 crew_label=label_at(Vector2(24,53),Vector2(930,23),Factions.display_name(faction_id)+"  /  %d units  /  3 vehicle slots"%required_units,14)
 if allow_encounter_lab:button_at(Vector2(1152,18),Vector2(178,35),"ENCOUNTER LAB",open_encounter_lab)
 button_at(Vector2(1352,18),Vector2(128,35),"CLOSE",queue_free)
 var i=0
 for id in Models.data().classes:
  var key: String=id
  var tab=button_at(Vector2(24+i*367,91),Vector2(356,34),Models.class_name_for(id),func():selected_class=key;refresh_models())
  tab.toggle_mode=true;class_buttons[id]=tab;i+=1
 if not class_buttons.has(selected_class):selected_class=Models.data().classes.keys()[1]
 preferred=CheckBox.new();add_child(preferred);preferred.position=Vector2(24,132);preferred.text="Faction suggestions";preferred.add_theme_font_size_override("font_size",12);preferred.toggled.connect(func(_x):refresh_models())
 packing_hint=label_at(Vector2(252,135),Vector2(665,24),"",13);packing_hint.name="TwoWheelerRule";packing_hint.add_theme_color_override("font_color",Color("#d2bf8d"))
 label_at(Vector2(920,135),Vector2(560,24),"Click a vehicle to add it",13).horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
 var scroll=ScrollContainer.new();add_child(scroll);scroll.position=Vector2(24,167);scroll.size=Vector2(1456,412);scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
 grid=GridContainer.new();scroll.add_child(grid);grid.columns=4;grid.size_flags_horizontal=Control.SIZE_EXPAND_FILL;grid.add_theme_constant_override("h_separation",12);grid.add_theme_constant_override("v_separation",12)
 label_at(Vector2(24,600),Vector2(500,31),"YOUR CONVOY",21)
 slot_label=label_at(Vector2(430,604),Vector2(200,25),"",13)
 status=label_at(Vector2(865,600),Vector2(615,30),"",16);status.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
 seat_bar=SeatMeter.new();add_child(seat_bar);seat_bar.position=Vector2(866,634);seat_bar.size=Vector2(614,7);seat_bar.max_value=required_units
 convoy_row=preload("res://gameplay/sandbox_convoy_slots.gd").new();add_child(convoy_row);convoy_row.position=Vector2(24,652);convoy_row.size=Vector2(1456,137)
 convoy_row.remove_vehicle.connect(func(index):selected.remove_at(index);refresh_convoy())
 convoy_row.edit_requested.connect(func():
  scroll.scroll_vertical=0
  for id in model_buttons:
   if not model_buttons[id].button.disabled:model_buttons[id].button.grab_focus();break)
 button_at(Vector2(24,808),Vector2(154,35),"CLEAR",func():selected=[];refresh_convoy())
 button_at(Vector2(190,808),Vector2(190,35),"AUTO-FIT",func():selected=Rules.auto_fit(required_units,faction_id);refresh_convoy())
 apply_button=button_at(Vector2(582,805),Vector2(340,42),"USE THIS CONVOY",func():
  if Rules.check(selected,required_units,faction_id).valid:convoy_selected.emit(selected.duplicate());queue_free())
 apply_button.add_theme_stylebox_override("normal",Card.style(Color("#414b3b"),Color("#d2bf8d")))
 refresh_models();refresh_convoy()
func label_at(at: Vector2,sz: Vector2,value: String,points=13) -> Label:
 return Card.label(self,at,sz,value,points,Color("#d9dfd5"),font)
func button_at(at: Vector2,sz: Vector2,value: String,action: Callable) -> Button:
 var b=Button.new();add_child(b);b.position=at;b.size=sz;b.text=value;b.add_theme_font_size_override("font_size",13);b.pressed.connect(action);return b
func refresh_models():
 refresh_packing_hint()
 for id in class_buttons:class_buttons[id].set_pressed_no_signal(id==selected_class)
 for child in grid.get_children():grid.remove_child(child);child.queue_free()
 model_buttons={}
 for id in Models.all_ids():
  var m=Models.model(id)
  if m.vehicle_class!=selected_class:continue
  if preferred.button_pressed and not Models.preferences(faction_id).has(id):continue
  var key: String=id
  var tile=Button.new();grid.add_child(tile);tile.custom_minimum_size=Vector2(348,187);tile.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND;tile.tooltip_text=m.description
  tile.add_theme_stylebox_override("normal",Card.style(Color("#22323a"),Color("#526961")));tile.add_theme_stylebox_override("hover",Card.style(Color("#3c4940"),Color("#d2bf8d")));tile.add_theme_stylebox_override("disabled",Card.style(Color("#172126"),Color("#303d42")))
  tile.pressed.connect(func():try_add(key))
  var title=Card.label(tile,Vector2(12,7),Vector2(300,25),m.name,16,Color("#e7e4d4"),font);title.mouse_filter=Control.MOUSE_FILTER_IGNORE
  var picture=TextureRect.new();tile.add_child(picture);picture.position=Vector2(16,35);picture.size=Vector2(316,104);picture.texture=Models.icon(id);picture.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;picture.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;picture.mouse_filter=Control.MOUSE_FILTER_IGNORE
  var detail=Card.label(tile,Vector2(12,151),Vector2(304,23),"%d seats  ·  %s"%[int(m.unit_capacity),"Up to %d / slot"%Formation.two_wheelers_per_slot(faction_id) if Formation.two_wheeler(id) else "1 slot"],14,Color("#c4d5c7"),font);detail.mouse_filter=Control.MOUSE_FILTER_IGNORE
  var mark=Card.label(tile,Vector2(272,3),Vector2(60,26),"+",22,Color("#d2bf8d"),font);mark.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT;mark.mouse_filter=Control.MOUSE_FILTER_IGNORE
  var blocked=Label.new();tile.add_child(blocked);blocked.position=Vector2(22,70);blocked.size=Vector2(304,32);blocked.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;blocked.add_theme_font_size_override("font_size",15);blocked.add_theme_color_override("font_color",Color("#f0b2a8"));blocked.add_theme_stylebox_override("normal",Card.style(Color(.07,.09,.10,.92),Color("#68514e")));blocked.mouse_filter=Control.MOUSE_FILTER_IGNORE
  model_buttons[id]={"button":tile,"image":picture,"blocked":blocked,"mark":mark}
 refresh_availability()
func refresh_availability():
 for id in model_buttons:
  var legal=Rules.addition(selected,id,required_units,faction_id);var c=model_buttons[id]
  c.button.disabled=not legal.valid;c.image.modulate=Color.WHITE if legal.valid else Color(.40,.40,.40,.50);c.blocked.visible=not legal.valid;c.blocked.text=legal.badge;c.mark.visible=legal.valid
  c.button.tooltip_text=Models.model(id).description if legal.valid else legal.error
func try_add(id: String):
 if not Rules.addition(selected,id,required_units,faction_id).valid:return
 selected.append(id);refresh_convoy()
func refresh_packing_hint():
 if packing_hint==null:return
 var limit=Formation.two_wheelers_per_slot(faction_id)
 packing_hint.visible=selected_class=="two_wheelers"
 packing_hint.text="Up to %d two-wheelers share one convoy slot%s."%[limit," for this faction" if limit==4 else ""]
func refresh_convoy():
 refresh_packing_hint()
 crew_label.text=Factions.display_name(faction_id)+"  /  %d units  /  3 vehicle slots"%required_units
 seat_bar.max_value=required_units
 convoy_row.configure(selected,faction_id)
 var summary=Models.convoy(selected);var legal=Rules.check(selected,required_units,faction_id);var seats=int(summary.get("units",0))
 apply_button.disabled=not legal.valid
 slot_label.text="%d / 3 slots"%Formation.slots(selected,faction_id).size()
 status.text="%d / %d seats  %s"%[seats,required_units,"— READY" if legal.valid else "— "+str(legal.error)]
 status.add_theme_color_override("font_color",Color("#b9d4b9") if legal.valid else Color("#e0b49b"));seat_bar.value=mini(seats,required_units)
 refresh_availability()
func open_encounter_lab():
 if has_node("EncounterLab"):return
 var lab=load("res://gameplay/vehicle_encounter_lab.gd").new();lab.name="EncounterLab";lab.battle_requested.connect(func(context):blockade_battle_requested.emit(context));add_child(lab)

class SeatMeter extends Control:
 var max_value=1.
 var value=0.:
  set(v):value=v;queue_redraw()
 func _draw():
  draw_rect(Rect2(Vector2.ZERO,size),Color("#101b20"))
  draw_rect(Rect2(Vector2.ZERO,Vector2(size.x*clampf(value/maxf(max_value,1.),0.,1.),size.y)),Color("#91ad8e"))
