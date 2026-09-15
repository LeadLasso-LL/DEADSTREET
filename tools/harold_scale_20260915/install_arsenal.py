from pathlib import Path
import hashlib,json,re,sys
sys.stdout.reconfigure(encoding='utf-8',errors='backslashreplace')
out=Path(__file__).parent;r=out.parents[1]
names=['battle/geometry/harold_street_catalog.gd','gameplay/harold_street_art.gd','battle/vehicles/battle_arrival_service.gd']
data={name:(r/name).read_text(encoding='utf-8-sig') for name in names}
for name in names:
    p=out/'scaled_legacy_baseline'/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes((r/name).read_bytes())
(out/'scaled_legacy_baseline/.gdignore').write_text('# Historical source snapshot.\n')
note='\n\n## 20260915-harold-scale-04 - Owner adds Arsenal neighborhood vehicles\nOwner requested actual Arsenal vehicles, predominantly poor-neighborhood transport with one or two modest upgrades immediately outside Mercer Saints HQ. Selected worn Rattleback/Bayou, Workhorse pickup, Courier van and one practical Civicline; Cabrillo Lowline and Rancher Seven by the HQ, both canonical Mercer preferences. No premium/exotic vehicles. All parked art uses the existing fleet renderer, with model catalogue length/width at shared1.6x and closed doors. Same12 parked identities retained. Scale-only checks exposed an older Harold arrival limit: left boundary31 cannot fit the enlarged three-car convoy for Close/Medium. Extend that placement band toward world x1 as required by actual convoy length; retain existing option positions. Initial option-check fixture also needed its auto-committed side reopened; documented separately from real placement issue. Next: model-specific geometry/art, rebake ground, all choices/routes/cover and native screenshot.\n'
for name in ['docs/DEAD_STREET_HIVE_MIND.md','docs/DEAD_STREET_JOURNAL.md']:
    with (r/name).open('a',encoding='utf-8') as f:f.write(note)
c=names[0]
old='const PARKED_WIDTH = 2.1*VehicleModels.TACTICAL_SCALE'
assert old in data[c]
specs=[['north_car_0','rattleback',1.0],['north_car_1','bayou',8.8],['north_car_2','cabrillo',19.0],['north_car_3','rancher',29.6],['north_car_4','bayou',40.5],['north_car_5','courier',54.0],['south_car_0','bayou',1.8],['south_car_1','workhorse',12.1],['south_car_2','rattleback',22.4],['south_car_3','bayou',32.7],['south_car_4','civicline',43.0],['south_car_5','rattleback',53.3]]
data[c]=data[c].replace(old,'# Neighborhood transport; the two HQ cars are modest Mercer upgrades.\nconst PARKED_CARS = '+json.dumps(specs))
start=data[c].index('\tfor i in range(6):')
end=data[c].index('\treturn rows',start)
data[c]=data[c][:start]+'''\tfor spec in PARKED_CARS:
\t\tvar model = VehicleModels.model(spec[1])
\t\tvar size = Vector2(float(model.length),float(model.width))*VehicleModels.TACTICAL_SCALE
\t\tvar north = str(spec[0]).begins_with("north")
\t\tvar y = ROAD.position.y+.7 if north else ROAD.end.y-.6-size.y
\t\trows.append([spec[0],Rect2(Vector2(spec[2],y),size),"car","",spec[1]])
'''+data[c][end:]
a=names[1]
old='\tif not prop.is_empty() and prop[2]=="car":'
assert data[a].count(old)==1
data[a]=data[a].replace(old,'''\tif not prop.is_empty() and prop[2]=="car" and prop.size()>4:
\t\t# Use the canonical fleet sprite, palette, scale and ground-centre anchor.
\t\tmaterial=null
\t\tposition=prop[1].get_center()*Vector2(8,6)
\t\tvar parked=preload("res://gameplay/fleet_vehicle_art.gd").new()
\t\tparked.name="ParkedArsenalVehicle";parked.model_id=str(prop[4])
\t\tparked.facing=Vector2.LEFT if str(prop[0]).begins_with("north") else Vector2.RIGHT
\t\tadd_child(parked)
\telif not prop.is_empty() and prop[2]=="car":''')
old='func street_car(q: Vector2,sz: Vector2) -> void:'
assert old in data[a]
data[a]=data[a].replace(old,old+'\n\tif prop.size()>4:return # Canonical fleet child renders this parked vehicle.')
v=names[2]
old='var right=minf(64,c.x+12);var left=maxf(31,right-maxf(20.,convoy_length))'
assert old in data[v]
data[v]=data[v].replace(old,'# Long current-scale convoys need their full length even for Close/Medium.\n var right=minf(Catalog.SIZE.x,c.x+12);var left=maxf(1.,right-maxf(20.,convoy_length))')
for name,text in data.items():
    (r/name).write_text(text,encoding='utf-8',newline='\n')
    print('UPDATED',name,hashlib.sha256((r/name).read_bytes()).hexdigest())
(out/'parked_manifest.json').write_text(json.dumps(specs,indent=2))
