class_name MajorGang
extends Faction

var money: float = 0.0
var resources: ResourceStore = ResourceStore.new()
var controller_type: String = ""


func _init(p_id: String = "", p_display_name: String = "", p_controller_type: String = "") -> void:
	super(p_id, p_display_name, "major_gang")
	controller_type = p_controller_type


func to_dict() -> Dictionary:
	var data := super.to_dict()
	data["money"] = money
	data["resources"] = resources.to_dict()
	data["controller_type"] = controller_type
	return data


func from_dict(data: Dictionary) -> void:
	super.from_dict(data)
	faction_type = "major_gang"
	money = float(data.get("money", 0.0))
	var resource_data: Variant = data.get("resources", {})
	resources.from_dict(resource_data if resource_data is Dictionary else {})
	controller_type = str(data.get("controller_type", ""))
