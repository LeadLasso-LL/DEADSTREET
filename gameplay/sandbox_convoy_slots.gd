extends Control
const Models=preload("res://campaign/vehicles/vehicle_model_catalog.gd")
const Formation=preload("res://campaign/vehicles/convoy_formation_catalog.gd")
const Card=preload("res://gameplay/tactical_unit_card.gd")
signal remove_vehicle(index: int)
signal edit_requested
var models: Array=[]
var faction="mercer"
var removable=true
var font: SystemFont
var cells=[]
func _ready():
 font=SystemFont.new();font.font_names=PackedStringArray(["Arial"]);resized.connect(rebuild);rebuild()
func configure(value: Array,faction_id: String):models=value.duplicate();faction=faction_id;if_ready_rebuild()
func if_ready_rebuild():
 if is_node_ready():rebuild()
func rebuild():
 for c in get_children():remove_child(c);c.queue_free()
 cells=[]
 var groups=Formation.slots(models,faction)
 var w=(size.x-20.)/3.
 for i in range(3):
  var panel=Panel.new();add_child(panel);panel.name="Slot%d"%(i+1);panel.position=Vector2(i*(w+10),0);panel.size=Vector2(w,size.y)
  panel.add_theme_stylebox_override("panel",Card.style(Color("#223238") if i<groups.size() else Color("#152127"),Color("#698071") if i<groups.size() else Color("#45565b")))
  cells.append(panel)
  if i>=groups.size():
   var empty=Button.new();panel.add_child(empty);empty.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);empty.text="+  SLOT %d"%(i+1);empty.flat=true;empty.add_theme_font_size_override("font_size",14);empty.pressed.connect(func():edit_requested.emit());continue
  var indices: Array=groups[i].indices
  var member_w=w/indices.size()
  for j in range(indices.size()):
   var index=int(indices[j]);var m=Models.model(models[index]);var x=j*member_w
   var picture=TextureRect.new();panel.add_child(picture);picture.position=Vector2(x+8,12);picture.size=Vector2(member_w-16,maxf(32,size.y-54));picture.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;picture.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;picture.texture=Models.icon(models[index]);picture.mouse_filter=Control.MOUSE_FILTER_IGNORE
   var title=Card.label(panel,Vector2(x+5,size.y-41),Vector2(member_w-10,19),m.name,11,Color("#e4e4d6"),font);title.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS;title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;title.tooltip_text=m.name
   var seats=Card.label(panel,Vector2(x+5,size.y-23),Vector2(member_w-10,18),"%d seats"%int(m.unit_capacity),11,Color("#b6c6b8"),font);seats.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
   if removable:
    var remove=Button.new();panel.add_child(remove);remove.position=Vector2(x+member_w-27,3);remove.size=Vector2(24,24);remove.text="×";remove.tooltip_text="Remove "+m.name;remove.pressed.connect(func():remove_vehicle.emit(index))
