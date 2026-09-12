extends Control
const Scenarios=preload("res://gameplay/vehicle_encounter_scenarios.gd")
const Models=preload("res://campaign/vehicles/vehicle_model_catalog.gd")
const Card=preload("res://gameplay/tactical_unit_card.gd")
var scenarios=Scenarios.new()
var picker: OptionButton
var brief: Label
var outcome: Label
var state_label: Label
var icon: TextureRect
var font: SystemFont
var saved: Dictionary={}
func _ready():
 size=Vector2(1152,860);mouse_filter=Control.MOUSE_FILTER_STOP
 font=SystemFont.new();font.font_names=PackedStringArray(["Arial"])
 var bg=ColorRect.new();add_child(bg);bg.size=size;bg.color=Color("#111b20")
 label_at(Vector2(28,20),Vector2(900,38),"VEHICLE ENCOUNTER LAB",25)
 button_at(Vector2(1000,20),Vector2(120,36),"CLOSE",queue_free)
 label_at(Vector2(28,65),Vector2(1090,50),"Controlled encounters for testing. Campaign event generation is not connected yet.",15)
 picker=OptionButton.new();add_child(picker);picker.position=Vector2(28,125);picker.size=Vector2(560,42)
 for id in Scenarios.IDS:picker.add_item(Models.model(id).name)
 picker.item_selected.connect(func(_i):refresh())
 brief=label_at(Vector2(28,190),Vector2(610,145),"",18);brief.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 icon=TextureRect.new();add_child(icon);icon.position=Vector2(665,145);icon.size=Vector2(440,220);icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;icon.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;icon.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 button_at(Vector2(28,350),Vector2(220,42),"RUN / RESOLVE",func():execute(false))
 button_at(Vector2(263,350),Vector2(260,42),"COUNTER-TEST / INTERCEPT",func():execute(true))
 button_at(Vector2(538,350),Vector2(170,42),"ADVANCE TURN",func():
  var paid=scenarios.service.advance_turn();outcome.text="Turn advanced. Cargo claims paid: %d"%paid.size();refresh())
 outcome=label_at(Vector2(28,413),Vector2(1090,88),"Choose a vehicle and run its encounter.",18);outcome.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 state_label=label_at(Vector2(28,520),Vector2(1090,240),"",17)
 button_at(Vector2(28,795),Vector2(170,38),"RESET ALL",func():scenarios.reset();outcome.text="Fresh test state.";refresh())
 button_at(Vector2(214,795),Vector2(170,38),"SAVE SNAPSHOT",func():
  saved=scenarios.service.to_dict();var f=FileAccess.open("user://vehicle_encounter_lab.json",FileAccess.WRITE)
  if f:f.store_string(JSON.stringify(saved));outcome.text="Test snapshot saved."
  else:outcome.text="Could not write the test snapshot.")
 button_at(Vector2(400,795),Vector2(170,38),"LOAD SNAPSHOT",load_snapshot)
 scenarios.reset();refresh()
func label_at(at: Vector2,sz: Vector2,text: String,points: int) -> Label:return Card.label(self,at,sz,text,points,Color("#d9dfd5"),font)
func button_at(at: Vector2,sz: Vector2,text: String,action: Callable) -> Button:
 var b=Button.new();add_child(b);b.position=at;b.size=sz;b.text=text;b.pressed.connect(action);return b
func execute(counter: bool):
 var result=scenarios.run(picker.selected,counter)
 outcome.text=("SUCCESS · " if result.success else "STOPPED · ")+result.message
 if result.has("blockade"):outcome.text+="\nRoad ahead: %s blockade · %d units · %d vehicles"%[result.blockade,result.units,result.vehicles]
 if result.has("movement_remaining"):outcome.text+="\n%.1f road units remaining. Turn %d."%[float(result.movement_remaining),scenarios.service.data.turn]
 if result.has("freed"):outcome.text+="\n%d survivors return to their original factions. No automatic recruitment."%result.freed.size()
 refresh()
func refresh():
 var id=Scenarios.IDS[picker.selected];brief.text=Scenarios.BRIEFS[picker.selected];icon.texture=Models.icon(id);state_label.text=scenarios.state_text(picker.selected)
func load_snapshot():
 var raw=JSON.parse_string(FileAccess.get_file_as_string("user://vehicle_encounter_lab.json")) if FileAccess.file_exists("user://vehicle_encounter_lab.json") else null
 outcome.text="Snapshot restored." if raw is Dictionary and scenarios.service.from_dict(raw) else "No valid saved snapshot."
 refresh()
