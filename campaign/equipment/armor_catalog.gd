class_name ArmorCatalog
extends RefCounted

# Fictional equipment models. Game tiers are not ballistic certification levels.
const BASE_MAX_HP := 1.5
const IDS := ["patrol_vest", "field_carrier", "reinforced_carrier"]
const ITEMS := {
 "patrol_vest": {"tier":1, "name":"Patrol Vest", "bonus":0.15, "price":300,
  "description":"Flexible torso vest with a smooth front and adjustable waist straps."},
 "field_carrier": {"tier":2, "name":"Field Carrier", "bonus":0.30, "price":750,
  "description":"Compact plate carrier with a front plate pocket and webbing cummerbund."},
 "reinforced_carrier": {"tier":3, "name":"Reinforced Carrier", "bonus":0.50, "price":1500,
  "description":"Reinforced torso carrier with padded straps and a close-fitting cummerbund."}
}
static func valid(id: String) -> bool:
 return id.is_empty() or ITEMS.has(id)
static func tier(id: String) -> int:
 return int(ITEMS.get(id,{}).get("tier",0))
static func bonus(id: String) -> float:
 return float(ITEMS.get(id,{}).get("bonus",0.0))
static func max_hp(id: String) -> float:
 return BASE_MAX_HP*(1.0+bonus(id))
static func label(id: String) -> String:
 return str(ITEMS.get(id,{}).get("name","No armor"))
static func texture(id: String) -> Texture2D:
 if not ITEMS.has(id):return null
 var path: String="res://assets/art/equipment/armor/"+id+".png"
 if not FileAccess.file_exists(path):return null
 var image := Image.new()
 if image.load_png_from_buffer(FileAccess.get_file_as_bytes(path))!=OK:return null
 return ImageTexture.create_from_image(image)
