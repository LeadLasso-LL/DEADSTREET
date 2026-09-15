from pathlib import Path
import hashlib,json,subprocess,sys
sys.stdout.reconfigure(encoding='utf-8',errors='backslashreplace')
r=Path(__file__).resolve().parents[2]
out=Path(__file__).parent
hashes=json.loads((out/'baseline_hashes.json').read_text())
for name,digest in hashes.items():
    assert hashlib.sha256((r/name).read_bytes()).hexdigest()==digest,name+' changed since inspection'
changes={}
def load(name):
    changes[name]=(r/name).read_text(encoding='utf-8-sig')
def replace(name,old,new):
    assert changes[name].count(old)==1,(name,old)
    changes[name]=changes[name].replace(old,new)
c='battle/geometry/harold_street_catalog.gd'
load(c)
replace(c,'const SIZE = Vector2(64,46)','''# The same scale controls parked traffic art and its physical cover footprint.
const VehicleModels = preload("res://campaign/vehicles/vehicle_model_catalog.gd")
const ROAD = Rect2(0,23,64,20)
const SOUTH_SHIFT = ROAD.size.y-12.0
const SIZE = Vector2(64,46+SOUTH_SHIFT)
const PARKED_WIDTH = 2.1*VehicleModels.TACTICAL_SCALE
const ARRIVAL_BAND = Vector2(ROAD.position.y+1.0,ROAD.size.y-1.2)''')
replace(c,'const DEFENDER_ZONE = Rect2(1,15,29,19)','const DEFENDER_ZONE = Rect2(1,15,29,19+SOUTH_SHIFT)')
replace(c,'const ARRIVAL_CENTER = Vector2(49,28)','const ARRIVAL_CENTER = Vector2(49,ROAD.position.y+ROAD.size.y*.5)')
replace(c,'Vector2(17,35.6),.8],[Vector2(45,35.6)','Vector2(17,35.6+SOUTH_SHIFT),.8],[Vector2(45,35.6+SOUTH_SHIFT)')
replace(c,'# Authored positions for the following deployment milestone; not selectable yet.','# All arrival choices share the widened street center and legal road band.')
for x in [39,49,57]:
    replace(c,f'Vector2({x},28)',f'Vector2({x},ROAD.position.y+ROAD.size.y*.5)')
for old,new in [('Rect2(0,41,21,5)','Rect2(0,41+SOUTH_SHIFT,21,5)'),('Rect2(21,41,22,5)','Rect2(21,41+SOUTH_SHIFT,22,5)'),('Rect2(43,41,21,5)','Rect2(43,41+SOUTH_SHIFT,21,5)'),('Rect2(9.5,35.7,1.15,1.05)','Rect2(9.5,35.7+SOUTH_SHIFT,1.15,1.05)'),('Rect2(12,36.5,1.65,.95)','Rect2(12,36.5+SOUTH_SHIFT,1.65,.95)'),('Rect2(38.9,36,1.15,1.05)','Rect2(38.9,36+SOUTH_SHIFT,1.15,1.05)'),('[2.,10.,19.,27.,43.,54.]','[1.,11.6,22.2,32.8,43.4,54.]'),('[3.,13.,23.,34.,44.,55.]','[1.8,12.1,22.4,32.7,43.,53.3]'),('Rect2(x,23.7,5.0+(i%3)*.15,2.1)','Rect2(x,ROAD.position.y+.7,(5.0+(i%3)*.15)*VehicleModels.TACTICAL_SCALE,PARKED_WIDTH)'),('Rect2(x,32.3,5.0+(i%3)*.15,2.1)','Rect2(x,ROAD.end.y-.6-PARKED_WIDTH,(5.0+(i%3)*.15)*VehicleModels.TACTICAL_SCALE,PARKED_WIDTH)'),('Surface.KIND_ASPHALT,Rect2(0,23,64,12)','Surface.KIND_ASPHALT,ROAD'),('Rect2(0,35,64,6)','Rect2(0,ROAD.end.y,64,6)'),('Rect2(41,24,20,10.8)','Rect2(31,ARRIVAL_BAND.x,33,ARRIVAL_BAND.y)')]:
    replace(c,old,new)
a='gameplay/harold_street_art.gd'
load(a)
for old,new in [('Rect2(-320,-280,1152,568)','Rect2(-320,-280,1152,280+(H.SIZE.y+2)*6)'),('Rect2(-40,0,144,46)','Rect2(-40,0,144,H.SIZE.y)'),('Rect2(-40,23,144,12)','Rect2(-40,H.ROAD.position.y,144,H.ROAD.size.y)'),('Rect2(-40,35,144,6)','Rect2(-40,H.ROAD.end.y,144,6)'),('for y in [23,35]:','for y in [H.ROAD.position.y,H.ROAD.end.y]:'),('for y in [173,175]:','for y in [H.ROAD.get_center().y*6-1,H.ROAD.get_center().y*6+1]:'),('range(7500)','range(roundi(7500*H.ROAD.size.y/12.))'),('rng.randf_range(140,209)','rng.randf_range(H.ROAD.position.y*6+2,H.ROAD.end.y*6-1)'),('rng.randf_range(141,208)','rng.randf_range(H.ROAD.position.y*6+3,H.ROAD.end.y*6-2)'),('Vector2(120,187),Vector2(367,165)','Vector2(120,H.ROAD.get_center().y*6+13),Vector2(367,H.ROAD.get_center().y*6-9)'),('Vector2(4,40.4),Vector2(42,40.4),Vector2(10.9,37.8),Vector2(40.6,37.8)','Vector2(4,40.4+H.SOUTH_SHIFT),Vector2(42,40.4+H.SOUTH_SHIFT),Vector2(10.9,37.8+H.SOUTH_SHIFT),Vector2(40.6,37.8+H.SOUTH_SHIFT)')]:
    replace(a,old,new)
v='battle/vehicles/battle_arrival_service.gd'
load(v)
replace(v,'var rect=Rect2(left,24,right-left,10.8)','var rect=Rect2(left,Catalog.ARRIVAL_BAND.x,right-left,Catalog.ARRIVAL_BAND.y)')
b='tools/dusk_review/bake_harold_frontage.gd'
load(b)
replace(b,'var jobs=[["ground",[],Rect2(-320,-280,1152,568)]]','var jobs=[["ground",[],Art.cache_bounds("ground")]]')
replace(b,'\tfor row in Catalog.props():','\tfor row in ([] if "--ground-only" in OS.get_cmdline_user_args() else Catalog.props()):')
for name,text in changes.items():
    (r/name).write_text(text,encoding='utf-8',newline='\n')
    print('UPDATED',name,hashlib.sha256((r/name).read_bytes()).hexdigest())
(out/'source_delta.patch').write_bytes(subprocess.check_output(['git','diff','--',*changes],cwd=r))
note='\n\n## 20260915-harold-scale-02 - Geometry and art source installed\nAll12 parked vehicles now use shared1.6x length/width; collision and cover derive from the same rectangles. North/south rows respaced to avoid overlap. Road23..43, lower sidewalk43..49, map64x54; lower props/lamps/litter moved8 units. Arrival choices and deployment band follow the enlarged road. Apartment frontage and unit/camera/HUD code unchanged. Ground baker now uses runtime cache bounds and supports --ground-only so unrelated facades remain untouched. Next: rebake/import, native geometry/disembark/20-second combat comparison and screenshot inspection. Source diffs/baselines in tools/harold_scale_20260915/.\n'
for name in ['docs/DEAD_STREET_HIVE_MIND.md','docs/DEAD_STREET_JOURNAL.md']:
    with (r/name).open('a',encoding='utf-8') as f:f.write(note)
