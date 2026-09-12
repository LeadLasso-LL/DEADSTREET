@tool
extends EditorExportPlugin

# The runtime atlases use explicit PNG loading and skip redundant editor imports.
# Add their original bytes to the pack, including lazy-loaded wound/anchor files.
const MANIFEST := "res://assets/art/units/factions/manifest.json"
const ROOT := "res://assets/art/units/factions/"
const IMAGE_FOLDERS: Array[String] = ["units", "death_back", "check_comrade", "blood_masks", "portraits"]

func _get_name() -> String:
	return "DeadStreetFactionRoster"

static func catalog_paths(data: Dictionary) -> PackedStringArray:
	var paths := PackedStringArray([MANIFEST, "res://assets/data/faction_units.json"])
	for armor_id: String in ["patrol_vest", "field_carrier", "reinforced_carrier"]:
		paths.append("res://assets/art/equipment/armor/"+armor_id+".png")
	paths.append("res://assets/data/vehicle_models.json")
	var fleet_path="res://assets/art/vehicles/fleet/manifest.json"
	if FileAccess.file_exists(fleet_path):
		paths.append(fleet_path)
		var fleet: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(fleet_path))
		for model_id in fleet.get("models",{}):
			paths.append("res://assets/art/vehicles/fleet/icons/"+str(model_id)+".png")
			for frame in fleet.models[model_id].frames:
				paths.append("res://assets/art/vehicles/fleet/sprites/"+str(frame))
	var factions: Dictionary = {}
	for pairing: String in data.get("models", {}):
		factions[pairing.get_slice(":", 0)] = true
	for faction: String in factions:
		paths.append("res://assets/art/factions/roster/"+faction+".png")
	for variant: String in data.get("variants", {}):
		for folder: String in IMAGE_FOLDERS:
			paths.append(ROOT+folder+"/"+variant+".png")
		paths.append(ROOT+"anchors/"+variant+".json")
	return paths

func _export_begin(_features: PackedStringArray, _is_debug: bool, _path: String, _flags: int) -> void:
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(MANIFEST))
	if not data is Dictionary or not bool(data.get("complete", false)):
		get_export_platform().add_message(EditorExportPlatform.EXPORT_MESSAGE_ERROR, "Faction roster", "Complete the faction animation build before exporting.")
		return
	var paths := catalog_paths(data)
	for resource_path: String in paths:
		if not FileAccess.file_exists(resource_path):
			get_export_platform().add_message(EditorExportPlatform.EXPORT_MESSAGE_ERROR, "Faction roster", "Missing animation asset: "+resource_path)
			return
	for resource_path: String in paths:
		add_file(resource_path, FileAccess.get_file_as_bytes(resource_path), false)
