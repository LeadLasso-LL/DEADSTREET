extends "res://tools/dusk_review/queue_showcase.gd"
func start()->void:
	await super.start()
	var b=runtime.get_current_session().battle_state
	for id in ["player_soldier_shotgun","rival_soldier_shotgun"]:
		var p=b.get_participant(id)
		p.weapon_type="shotgun"
		p.weapon_state=load("res://battle/combat/battle_weapon_catalog.gd").create_initial_state("shotgun")
	print("SHOTGUN_FIXTURE actual loadouts set to shotgun")
