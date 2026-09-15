from pathlib import Path
R=Path(__file__).parents[2]
p=R/'gameplay/harold_street_art.gd';s=p.read_text()
s=s.replace('super._ready()','''super._ready()
	if not prop.is_empty() and prop[2]=="car":
		var colors=[Color("#777367"),Color("#75443e"),Color("#536258"),Color("#989786"),Color("#424d5e"),Color("#514e46")]
		var paint=colors[absi(str(prop[0]).hash())%colors.size()]
		if prop[0]=="arrival_car":paint=Color("#333b3e")
		material.set_shader_parameter("paint",Vector3(paint.r,paint.g,paint.b))''',1)
s=s.replace('rng.randf_range(-.08,.02)','rng.randf_range(-.022,.014)')
s=s.replace('var y=base-67-floor_id*39','var y=base-84-floor_id*39')
s=s.replace('label(Vector2(q.x+6,base-53),H.OBJECTIVE,sz.x-12,7,Color("#d7c4a0"))','''rect(Rect2(q.x+20,base-57,sz.x-40,9),Color("#373e35"))
			label(Vector2(q.x+21,base-50),H.OBJECTIVE,sz.x-42,6,Color("#d7c4a0"))''')
s=s.replace('# Alley continues beyond the playable mouth, between actual building footprints.','''# Facades continue off both map edges with the road.
	for x in [-272.,512.]:
		bricks(Rect2(x,-280,272,370),Color("#493e36"))
		for row in range(8):
			for col in range(8):
				window(Vector2(x+12+col*32,10-row*39),(row+col)%5==0,col)
	# Alley continues beyond the playable mouth, between actual building footprints.''')
# More contextual detail, not evenly distributed scenery.
s=s.replace('# Apartment fire escape: small landings and rails, without covering the entrance.','''# Torn notices and paint tags gather at reachable street level.
	for n in range(3):
		var notice=Vector2(q.x+sz.x-14-n*4,base-15+n)
		rect(Rect2(notice,Vector2(3,5)),Color("#a39b7e"))
		line(notice+Vector2(0,2),notice+Vector2(2,2),Color("#575b4c"),.5)
	if seed_id==2:
		label(Vector2(q.x+22,base-5),"MERCER",35,7,Color("#9c967c"))
	# Apartment fire escape: small landings and rails, without covering the entrance.''')
p.write_text(s)
p=R/'battle/session/campaign_battle_session_service.gd';s=p.read_text()
s=s.replace('\t# Caller chooses the deployment protocol.', '\t# Apply scenario identities after authored geometry is known.\n\tpreload("res://battle/identity/tactical_identity_factory.gd").apply_debug_hq_identities(battle_state)\n\n\t# Caller chooses the deployment protocol.')
p.write_text(s)
# Review assertions cover real identity/zone contracts, not just rendering.
p=R/'tools/dusk_review/harold_review.gd';s=p.read_text()
needle='\t# Validate real navigation with the arrival vehicle already placed.'
s=s.replace(needle,'''	for unit in battle.participants.values():
		var expected="russian_organized_crime" if unit.side_id==battle.attacker_side_id else "local_street_gang"
		if unit.identity.gang_archetype_id!=expected:
			fail("faction identity");return
		if unit.side_id==battle.defender_side_id and not preload("res://battle/geometry/harold_street_catalog.gd").DEFENDER_ZONE.has_point(unit.battle_position):
			fail("defender zone");return
	# Validate real navigation with the arrival vehicle already placed.''')
p.write_text(s)
print('Car paint, sidewalk variation, signs and late-bound identities corrected')
