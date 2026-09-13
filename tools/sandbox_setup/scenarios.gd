extends RefCounted
const Config=preload("res://gameplay/sandbox_force_config.gd")
static func make(attacker_count: int,defender_count: int,vehicles: Array=[]) -> Dictionary:
 var config=Config.from_legacy({"attacker":{"faction":"trc"},"defender":{"faction":"nbpd"}})
 for side in ["attacker","defender"]:
  config[side].units=[]
  for i in range(attacker_count if side=="attacker" else defender_count):
   var row=Config.unit(Config.CLASSES[i%5]);row.tier=i%3+1;row.armor=["","patrol_vest","field_carrier","reinforced_carrier"][i%4]
   row.weapon=Config.Weapons.models_for_class(row["class"])[i%6]
   config[side].units.append(row)
 config.attacker.vehicles=vehicles.duplicate() if not vehicles.is_empty() else Config.auto_convoy(attacker_count)
 return config
