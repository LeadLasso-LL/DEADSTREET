class_name FactionUnitCatalog
extends RefCounted

# Presentation roster, not campaign eligibility or an equipment whitelist.
const CLASSES: Array[String] = ["pistol", "smg", "shotgun", "rifle", "sniper"]
const ALIASES := {"local_street_gang": "mercer", "mercer_saints": "mercer", "russian_organized_crime": "orlov", "orlov_bratva": "orlov"}
static var _rows: Dictionary = {}

static func rows() -> Dictionary:
	if _rows.is_empty():
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://assets/data/faction_units.json"))
		if parsed is Dictionary:
			_rows = parsed.get("factions", {})
	return _rows

static func canonical_id(id: String) -> String:
	var resolved: String = str(ALIASES.get(id, id))
	return resolved if rows().has(resolved) else ""

static func all_ids() -> Array[String]:
	var result: Array[String] = []
	result.assign(rows().keys())
	return result

static func profile(id: String) -> Dictionary:
	return rows().get(canonical_id(id), {})

static func display_name(id: String) -> String:
	return str(profile(id).get("name", id))

static func emblem_path(id: String) -> String:
	return str(profile(id).get("emblem", ""))
