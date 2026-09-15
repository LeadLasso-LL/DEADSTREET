extends RefCounted
## Reusable seven-a-side authored setup. Training/equipment are fixed before battle.
static func config(count=7) -> Dictionary:
 var setup={"map_id":"doble_ocho","attacker":{"faction":"sierra_roja","vehicles":["mesa","outlander"],"vehicle_occupants":[{"units":4,"bed":0},{"units":count-4,"bed":0}],"units":[]},"defender":{"faction":"calle_ocho","units":[]}}
 var Config=preload("res://gameplay/sandbox_force_config.gd")
 var classes=["rifle","smg","shotgun","rifle","pistol","smg","sniper"]
 for side in ["attacker","defender"]:
  for i in range(count):
   var u=Config.unit(classes[i]);u.tier=2
   setup[side].units.append(u)
 return setup
