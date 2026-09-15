from pathlib import Path
R=Path(__file__).parents[2]
p=R/'world/roads/road_segment.gd';s=p.read_text();s=s.replace('var id: String = ""','var id: String = ""\nvar street_name: String = ""').replace('"id": id,','"id": id,\n\t\t"street_name": street_name,').replace('id = str(data.get("id", ""))','id = str(data.get("id", ""))\n\tstreet_name = str(data.get("street_name", ""))');p.write_text(s)
p=R/'battle/geometry/harold_street_catalog.gd';s=p.read_text().replace('const NEIGHBORHOOD = "Mercer Heights"','const Location = preload("res://world/harold_location.gd")\nconst NEIGHBORHOOD = Location.NEIGHBORHOOD').replace('const STREET = "Harold Ave."','const STREET = Location.STREET').replace('const OBJECTIVE = "Harold Apartments"','const OBJECTIVE = Location.OBJECTIVE').replace('const STORE = "Mercer Mini-Mart"','const STORE = Location.STORE');p.write_text(s)
p=R/'gameplay/starter_world_service.gd';s=p.read_text()
s=s.replace('const KEEP_MAP_POSITION', 'const HaroldLocation = preload("res://world/harold_location.gd")\nconst KEEP_MAP_POSITION',1)
s=s.replace('"Player Gang"','"Russian Mafia"').replace('"Rival Gang"','"Local Street Gang"').replace('"Starter Hood"','HaroldLocation.NEIGHBORHOOD').replace('"Rival HQ"','HaroldLocation.OBJECTIVE')
for a,b in [('Vector2(32,42)','Vector2(44,30)'),('Vector2(35,42)','Vector2(47,30)'),('Vector2(38,42)','Vector2(50,30)'),('Vector2(35,16.5)','Vector2(21,20)'),('Vector2(27,16.5)','Vector2(25,20)'),('Vector2(41,20)','Vector2(14,20)')]:s=s.replace(a,b)
a='graph.add_segment(RoadSegment.new(SEGMENT_ID, NODE_KEEP_ID, NODE_HQ_ID, SEGMENT_DISTANCE))'
assert a in s;s=s.replace(a,'var street_segment = RoadSegment.new(SEGMENT_ID, NODE_KEEP_ID, NODE_HQ_ID, SEGMENT_DISTANCE)\n\tstreet_segment.street_name = HaroldLocation.STREET\n\tgraph.add_segment(street_segment)')
p.write_text(s)
print('Campaign/tactical names share location source; road name persists in saves')
