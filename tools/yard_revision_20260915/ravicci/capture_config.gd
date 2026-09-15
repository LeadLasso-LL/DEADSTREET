extends RefCounted
## Owner-directed video cast. The reusable Sierra Roja sandbox preset is unchanged.
static func config(count=7) -> Dictionary:
 var setup=preload("res://gameplay/doble_ocho_scenario.gd").config(count)
 setup.attacker.faction="ravicci"
 setup.attacker.vehicles=["monarch","obsidian"]
 # Experienced Ravicci assault crew versus the tier-two local defenders.
 for row in setup.attacker.units:row.tier=3
 return setup
