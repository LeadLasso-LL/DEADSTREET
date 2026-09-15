extends Panel
const Card=preload("res://gameplay/tactical_unit_card.gd")
const Models=preload("res://campaign/vehicles/vehicle_model_catalog.gd")
const Rules=preload("res://gameplay/sandbox_convoy_rules.gd")
signal edit_requested
signal remove_vehicle(index: int)
var side="attacker"
var title: Label
var seats: Label
var edit: Button
var slots: Control
var font: SystemFont
func _ready():
 font=SystemFont.new();font.font_names=PackedStringArray(["Arial"])
 add_theme_stylebox_override("panel",Card.style(Color("#19282e"),Color("#687768")))
 title=Card.label(self,Vector2(14,8),Vector2(390,25),"02  /  ATTACKING CONVOY" if side=="attacker" else "DEFENDING BLOCKADE",16,Color("#d2bf8d"),font)
 seats=Card.label(self,Vector2.ZERO,Vector2(230,25),"",13,Color("#becfc1"),font)
 edit=Button.new();add_child(edit);edit.text="EDIT CONVOY";edit.add_theme_font_size_override("font_size",12);edit.pressed.connect(func():edit_requested.emit())
 slots=preload("res://gameplay/sandbox_convoy_slots.gd").new();add_child(slots);slots.remove_vehicle.connect(func(index):remove_vehicle.emit(index));slots.edit_requested.connect(func():edit_requested.emit())
 resized.connect(arrange);arrange()
func arrange():
 if slots==null:return
 edit.position=Vector2(size.x-156,7);edit.size=Vector2(142,27)
 seats.position=Vector2(size.x-345,10);seats.size=Vector2(180,22);seats.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
 title.size.x=size.x-370
 title.add_theme_font_size_override("font_size",13 if size.x<900 else 16)
 slots.position=Vector2(14,43);slots.size=Vector2(size.x-28,size.y-55)
func configure(team: Dictionary):
 slots.configure(team.get("vehicles",[]),team.faction)
 var check=Rules.check(team.get("vehicles",[]),team.units.size(),team.faction)
 seats.text="%d / %d seats"%[Models.convoy(team.get("vehicles",[])).get("units",0),team.units.size()]
 seats.add_theme_color_override("font_color",Color("#b9d4b9") if check.valid else Color("#edab9d"))
 edit.text="EDIT CONVOY" if check.valid else "COMPLETE CONVOY"
