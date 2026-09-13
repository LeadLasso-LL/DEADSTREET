extends RefCounted
## Sandbox-only force limits. Campaign recruitment and force limits are independent.
const Weapons=preload("res://battle/combat/battle_weapon_catalog.gd")
const Factions=preload("res://battle/identity/faction_unit_catalog.gd")
const Armor=preload("res://campaign/equipment/armor_catalog.gd")
const Models=preload("res://campaign/vehicles/vehicle_model_catalog.gd")
const CLASSES=["pistol","smg","shotgun","rifle","sniper"]
const MAX_UNITS=12

static func unit(kind: String="rifle") -> Dictionary:
 return {"class":kind,"weapon":Weapons.default_model(kind),"tier":1,"armor":"","specialist":""}

static func from_legacy(source: Dictionary) -> Dictionary:
 var result={"map_id":"harold"}
 for side in ["attacker","defender"]:
  var old: Dictionary=source.get(side,{})
  var team={"faction":old.get("faction","orlov" if side=="attacker" else "mercer"),"units":[]}
  for kind in CLASSES:
   var row=unit(kind)
   row.weapon=old.get(kind,row.weapon);row.tier=old.get("unit_tiers",{}).get(kind,1);row.armor=old.get("armor",{}).get(kind,"")
   if kind=="pistol":row.specialist=old.get("specialist","")
   team.units.append(row)
  if side=="attacker":team.vehicles=old.get("vehicles",["bayou","bayou"]).duplicate()
  result[side]=team
 return result

static func balanced() -> Array:
 var rows=[]
 for kind in CLASSES:rows.append(unit(kind))
 return rows

static func auto_convoy(count: int) -> Array:
 var models=[]
 for i in range(ceili(float(count)/4.)):models.append("bayou")
 return models

static func validate(config: Dictionary) -> Dictionary:
 var counts={}
 if config.get("map_id","harold") not in ["harold","river_bridge"]:return {"valid":false,"error":"Choose an available battlefield."}
 for side in ["attacker","defender"]:
  if not config.get(side) is Dictionary:return {"valid":false,"error":"Choose both forces."}
  var team: Dictionary=config[side]
  if not team.get("faction") is String or not Factions.all_ids().has(team.faction):return {"valid":false,"error":"Choose a valid "+side+" faction."}
  if not team.get("units") is Array:return {"valid":false,"error":"Choose the "+side+" units."}
  counts[side]=team.units.size()
  if counts[side]<1 or counts[side]>MAX_UNITS:return {"valid":false,"error":"Each side needs 1–%d units for this sandbox map."%MAX_UNITS}
  for i in range(team.units.size()):
   var row=team.units[i];var label="%s unit %d: "%[side.capitalize(),i+1]
   if not row is Dictionary:return {"valid":false,"error":label+"invalid unit."}
   if not row.get("class") is String or not CLASSES.has(row["class"]):return {"valid":false,"error":label+"choose a weapon class."}
   if not row.get("weapon") is String or not Weapons.models_for_class(row["class"]).has(row.weapon):return {"valid":false,"error":label+"weapon must match its class."}
   if not (row.get("tier") is int or row.get("tier") is float) or not is_finite(float(row.tier)) or float(row.tier)!=float(int(row.tier)) or int(row.tier)<1 or int(row.tier)>3:return {"valid":false,"error":label+"choose unit tier 1, 2, or 3."}
   if not row.get("armor") is String or not Armor.valid(row.armor):return {"valid":false,"error":label+"choose valid armor."}
   var special=row.get("specialist","")
   if special!="" and (special!="mercer_dual_glock" or team.faction!="mercer" or row["class"]!="pistol" or row.weapon!="glock_17"):return {"valid":false,"error":label+"Mercer dual-pistol requires Mercer Saints and Glock 17."}
 if not config.attacker.get("vehicles") is Array:return {"valid":false,"error":"Choose an attacking convoy."}
 for model in config.attacker.vehicles:
  if not model is String or not Models.has_model(model):return {"valid":false,"error":"Choose a valid convoy vehicle."}
 var convoy=Models.convoy(config.attacker.vehicles,counts.attacker)
 if not convoy.valid:return {"valid":false,"error":convoy.get("error","Choose transport for every attacker.")}
 if config.get("map_id","harold")=="river_bridge":
  var defender=config.defender.get("vehicles",[])
  if not defender is Array:return {"valid":false,"error":"Choose defending vehicles."}
  for id in defender:
   if not id is String or not Models.has_model(id):return {"valid":false,"error":"Choose valid defending vehicles."}
  var defense=Models.convoy(defender,counts.defender)
  if not defense.valid:return {"valid":false,"error":"Defenders: "+defense.error}
 return {"valid":true,"counts":counts,"convoy":convoy,"error":""}
