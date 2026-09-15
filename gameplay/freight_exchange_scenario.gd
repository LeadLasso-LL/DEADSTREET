extends RefCounted
const Config=preload("res://gameplay/sandbox_force_config.gd")
static func config(count: int=10) -> Dictionary:
 var setup={"map_id":"freight_exchange","attacker":{"faction":"ashford_crane","vehicles":["obsidian","nocturne","eidolon"],"units":[]},"defender":{"faction":"mcallister","units":[]}}
 var classes=["rifle","smg","shotgun","rifle","sniper","smg","rifle","shotgun","pistol","rifle"]
 for side in ["attacker","defender"]:
  for i in range(count):
   var u=Config.unit(classes[i%classes.size()]);u.tier=2
   setup[side].units.append(u)
 return setup
