extends Control
const Armor=preload("res://campaign/equipment/armor_catalog.gd")
const Service=preload("res://campaign/equipment/armor_service.gd")
const Card=preload("res://gameplay/tactical_unit_card.gd")
const Markers=preload("res://gameplay/unit_armor_markers.gd")
signal armor_selected(armor_id: String)
var state: GameState
var faction_id: String
var sandbox:=false
var soldier_select: OptionButton
var status: Label
var balance: Label
var stock_labels: Dictionary={}
var buy_buttons: Dictionary={}
var equip_buttons: Dictionary={}
var font: SystemFont
var frame: Panel
func configure(p_state: GameState, p_faction: String, p_sandbox: bool) -> void:
 state=p_state;faction_id=p_faction;sandbox=p_sandbox
func _ready() -> void:
 font=SystemFont.new();font.font_names=PackedStringArray(["Arial"])
 size=Vector2(1152,860);mouse_filter=Control.MOUSE_FILTER_STOP
 var dim=ColorRect.new();add_child(dim);dim.size=size;dim.color=Color(0.02,0.04,0.06,.96)
 frame=Panel.new();add_child(frame);frame.position=Vector2(25,65);frame.size=Vector2(1102,735)
 frame.add_theme_stylebox_override("panel",Card.style(Color("#172127"),Color("#657381")))
 label_at(Vector2(50,88),Vector2(820,35),"ARMOR  /  EQUIPMENT",26)
 add_button(Vector2(992,86),Vector2(105,34),"CLOSE",queue_free)
 balance=label_at(Vector2(50,132),Vector2(1000,25),"",14)
 for i in range(3):
  var id: String=Armor.IDS[i];var item: Dictionary=Armor.ITEMS[id];var x:=50+i*353
  var tile=Panel.new();add_child(tile);tile.position=Vector2(x,181);tile.size=Vector2(338,420)
  tile.add_theme_stylebox_override("panel",Card.style(Color("#222e37"),Color("#4c5d6d")))
  label_at(Vector2(x+16,194),Vector2(295,30),item.name,21)
  var markers=Markers.new();add_child(markers);markers.position=Vector2(x+18,230);markers.tier=i+1
  label_at(Vector2(x+62,226),Vector2(220,22),"TIER %d  ·  HP +%d%%"%[i+1,roundi(item.bonus*100)],14)
  var icon=TextureRect.new();add_child(icon);icon.position=Vector2(x+69,255);icon.size=Vector2(200,234);icon.texture=Armor.texture(id)
  icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;icon.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;icon.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;icon.mouse_filter=Control.MOUSE_FILTER_IGNORE
  var description=label_at(Vector2(x+17,497),Vector2(303,48),item.description,13);description.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
  stock_labels[id]=label_at(Vector2(x+17,554),Vector2(303,25),"",14)
  buy_buttons[id]=add_button(Vector2(x,615),Vector2(162,35),"ALL UNLOCKED" if sandbox else "BUY  $%d"%item.price,func():purchase(id))
  buy_buttons[id].disabled=sandbox
  equip_buttons[id]=add_button(Vector2(x+172,615),Vector2(166,35),"PREVIEW" if sandbox else "EQUIP",func():equip(id))
 soldier_select=OptionButton.new();add_child(soldier_select);soldier_select.position=Vector2(50,674);soldier_select.size=Vector2(710,35);soldier_select.fit_to_longest_item=false;soldier_select.clip_text=true
 soldier_select.visible=not sandbox
 if not sandbox and state!=null:
  for soldier in state.soldiers.values():
   if soldier.faction_id!=faction_id:continue
   soldier_select.add_item("%s / UNIT %02d / TIER %d"%[soldier.weapon_type_id.to_upper(),soldier_select.item_count+1,soldier.unit_tier])
   soldier_select.set_item_metadata(soldier_select.item_count-1,soldier.id)
 soldier_select.item_selected.connect(func(_i):refresh())
 add_button(Vector2(787,674),Vector2(307,35),"NO ARMOR" if sandbox else "UNEQUIP TO INVENTORY",func():equip(""))
 status=label_at(Vector2(50,729),Vector2(1045,47),"",13);status.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 refresh()
func label_at(at: Vector2,sz: Vector2,text: String,points: int) -> Label:
 return Card.label(self,at,sz,text,points,Color("#dbe0df"),font)
func add_button(at: Vector2,sz: Vector2,text: String,action: Callable) -> Button:
 var b=Button.new();add_child(b);b.position=at;b.size=sz;b.text=text;b.add_theme_font_size_override("font_size",13);b.pressed.connect(action);return b
func selected_soldier() -> String:
 return str(soldier_select.get_item_metadata(soldier_select.selected)) if soldier_select.selected>=0 else ""
func refresh() -> void:
 if sandbox:
  balance.text="All three armors are available. Choose armor for each unit in the battle loadout rows."
  for id: String in Armor.IDS:stock_labels[id].text="HP capacity  %d%%"%roundi(100.*(1.+Armor.bonus(id)))
  return
 var faction=state.get_faction(faction_id) if state!=null else null
 if not faction is MajorGang:return
 balance.text="AVAILABLE FUNDS  $%d   ·   Purchase a vest, then assign it to a unit."%roundi(faction.money)
 var soldier=state.get_soldier(selected_soldier())
 for id: String in Armor.IDS:
  var quantity:=int(faction.armor_inventory.get(id,0))
  stock_labels[id].text="%d available in inventory"%quantity
  buy_buttons[id].disabled=faction.money<float(Armor.ITEMS[id].price)
  equip_buttons[id].disabled=soldier==null or (quantity<1 and soldier.armor_id!=id) or state.is_soldier_in_active_traveling_force(selected_soldier())
 if soldier!=null:status.text="Equipped: "+Armor.label(soldier.armor_id)+"  ·  HP +%d%%"%roundi(100.*Armor.bonus(soldier.armor_id))
func purchase(id: String) -> void:
 if sandbox:return
 var result=Service.purchase(state,faction_id,id);refresh();status.text=result.message
func equip(id: String) -> void:
 if sandbox:armor_selected.emit(id);queue_free();return
 var result=Service.equip(state,faction_id,selected_soldier(),id);refresh();status.text=result.message
