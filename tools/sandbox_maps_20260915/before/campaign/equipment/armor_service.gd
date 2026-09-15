class_name ArmorService
extends RefCounted
const Armor = preload("res://campaign/equipment/armor_catalog.gd")

# Inventory counts are unequipped items. A soldier owns at most one equipped vest.
static func purchase(state: GameState, faction_id: String, armor_id: String) -> Dictionary:
 if state==null or not Armor.ITEMS.has(armor_id):return fail("Unknown armor.")
 var faction=state.get_faction(faction_id)
 if not faction is MajorGang:return fail("This faction has no purchasing inventory.")
 var price: float=float(Armor.ITEMS[armor_id].price)
 if faction.money<price:return fail("Insufficient funds.")
 faction.money-=price
 faction.armor_inventory[armor_id]=int(faction.armor_inventory.get(armor_id,0))+1
 return {"success":true,"message":"Purchased "+Armor.label(armor_id)+"."}

static func equip(state: GameState, faction_id: String, soldier_id: String, armor_id: String) -> Dictionary:
 if state==null or not Armor.valid(armor_id):return fail("Unknown armor.")
 var faction=state.get_faction(faction_id)
 var soldier=state.get_soldier(soldier_id)
 if not faction is MajorGang or soldier==null or soldier.faction_id!=faction_id:return fail("Select one of your units.")
 if state.is_soldier_in_active_traveling_force(soldier_id):return fail("Return this unit from deployment before changing armor.")
 if soldier.armor_id==armor_id:return {"success":true,"message":"Already equipped."}
 if not armor_id.is_empty() and int(faction.armor_inventory.get(armor_id,0))<1:return fail("Purchase this armor first.")
 var previous: String=soldier.armor_id
 if not armor_id.is_empty():faction.armor_inventory[armor_id]=int(faction.armor_inventory.get(armor_id,0))-1
 if not previous.is_empty():faction.armor_inventory[previous]=int(faction.armor_inventory.get(previous,0))+1
 soldier.armor_id=armor_id
 return {"success":true,"message":"Equipped "+Armor.label(armor_id)+"." if not armor_id.is_empty() else "Armor returned to inventory."}

static func fail(message: String) -> Dictionary:
 return {"success":false,"message":message}
