class_name MajorGang
extends Faction

const Armor := preload("res://campaign/equipment/armor_catalog.gd")
var armor_inventory: Dictionary = {}

var money: float = 0.0:
	set(value):
		money = maxf(value, 0.0)
var resources: ResourceStore = ResourceStore.new()
var controller_type: String = ""
var upkeep_shortfall: float = 0.0:
	set(value):
		upkeep_shortfall = maxf(value, 0.0)


func _init(p_id: String = "", p_display_name: String = "", p_controller_type: String = "") -> void:
	super(p_id, p_display_name, "major_gang")
	controller_type = p_controller_type


func to_dict() -> Dictionary:
	var data := super.to_dict()
	data["money"] = money
	data["armor_inventory"] = armor_inventory.duplicate()
	data["resources"] = resources.to_dict()
	data["controller_type"] = controller_type
	data["upkeep_shortfall"] = upkeep_shortfall
	return data


func from_dict(data: Dictionary) -> void:
	super.from_dict(data)
	faction_type = "major_gang"
	armor_inventory.clear()
	var stock: Variant = data.get("armor_inventory", {})
	if stock is Dictionary:
		for armor_id: String in Armor.IDS:
			if stock.has(armor_id):
				armor_inventory[armor_id] = maxi(0, int(stock.get(armor_id, 0)))
	money = float(data.get("money", 0.0))
	var resource_data: Variant = data.get("resources", {})
	resources.from_dict(resource_data if resource_data is Dictionary else {})
	controller_type = str(data.get("controller_type", ""))
	upkeep_shortfall = maxf(float(data.get("upkeep_shortfall", 0.0)), 0.0)
