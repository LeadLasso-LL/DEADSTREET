from pathlib import Path
R=Path(__file__).parents[2]
p=R/'gameplay/harold_street_art.gd';s=p.read_text()
s=s.replace('for i in range(170):','for i in range(230):')
s=s.replace('stairs(Vector2(23,15),4.1,4.5)','''# Uncollected rubbish belongs at service walls and beside the alley.
	for spot in [Vector2(3.8,16.7),Vector2(16,16.6),Vector2(32.4,16.3),Vector2(39.5,19.2),Vector2(57,16.4),Vector2(4,40.4),Vector2(42,40.4)]:
		var t=p(spot)
		draw_circle(t+Vector2(2,1),5,Color(.03,.055,.045,.5))
		trash(t)
	for i in range(28):
		var t=p(Vector2(rng.randf_range(32.8,39.2),rng.randf_range(12,21)))
		rect(Rect2(t,Vector2(1.7,.8)),Color("#8c8973"))
	stairs(Vector2(23,15),4.1,4.5)''')
s=s.replace('for i in range(50):\n\t\tvar t=Vector2','for i in range(80):\n\t\tvar t=Vector2')
p.write_text(s)
p=R/'battle/geometry/harold_street_catalog.gd';s=p.read_text()
s=s.replace('Rect2(x,23.7,5.8,2.3)','Rect2(x,23.7,5.0+(i%3)*.15,2.1)').replace('Rect2(x,32.1,5.8,2.3)','Rect2(x,32.3,5.0+(i%3)*.15,2.1)')
p.write_text(s)
# One explicit generic road-name save/load check, plus location audits.
p=R/'tools/dusk_review/harold_review.gd';s=p.read_text()
needle='\tvar battle = session.battle_state'
s=s.replace(needle,needle+'''
	var segment=preload("res://world/roads/road_segment.gd").new("street_test","a","b",12)
	segment.street_name=preload("res://world/harold_location.gd").STREET
	var restored=preload("res://world/roads/road_segment.gd").new()
	restored.from_dict(segment.to_dict())
	if restored.street_name!=segment.street_name:fail("street name serialization");return''',1)
p.write_text(s)
print('Final street wear and consistent parked car scale installed')
