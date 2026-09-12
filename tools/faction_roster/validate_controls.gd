extends SceneTree
const Factions=preload("res://battle/identity/faction_unit_catalog.gd")
const Weapons=preload("res://battle/combat/battle_weapon_catalog.gd")
var errors: Array=[]
var selections=0
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var scene=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(scene)
	await process_frame
	for side: String in ["attacker","defender"]:
		var team: OptionButton=scene.side_options[side]
		for i in range(team.item_count):
			team.select(i);team.item_selected.emit(i);selections+=1
			await process_frame
			if scene.loadouts[side].faction!=str(team.get_item_metadata(i)):errors.append("faction selection "+side)
			if team.size.x>190.1:errors.append("long faction name overlaps loadout "+str(team.get_item_metadata(i)))
		for role: String in Factions.CLASSES:
			var weapon: OptionButton=scene.loadout_options[side+role]
			for i in range(weapon.item_count):
				weapon.select(i);weapon.item_selected.emit(i);selections+=1
				await process_frame
				if scene.loadouts[side][role]!=str(weapon.get_item_metadata(i)):errors.append("weapon selection "+side+role)
				if weapon.size.x>123.1:errors.append("long weapon name overlaps tier "+str(weapon.get_item_metadata(i)))
			var tier: OptionButton=scene.surface.get_node(side+"_"+role+"_tier")
			for i in range(3):
				tier.select(i);tier.item_selected.emit(i);selections+=1
				if scene.loadouts[side].unit_tiers[role]!=i+1:errors.append("tier selection "+side+role)
	print("ROSTER_CONTROLS selections=",selections," errors=",errors)
	quit(0 if errors.is_empty() else 1)
