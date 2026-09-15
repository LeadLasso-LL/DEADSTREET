from pathlib import Path
import hashlib,subprocess,json,sys
sys.stdout.reconfigure(encoding='utf-8',errors='backslashreplace')
out=Path(__file__).parent;r=out.parents[1]
planner='battle/ai/battle_vehicle_deployment_planner.gd'
context='battle/vehicles/battle_vehicle_placement_context.gd'
catalog='battle/geometry/harold_street_catalog.gd'
arrival='battle/vehicles/battle_arrival_service.gd'
names=[planner,context,catalog,arrival]
assert not subprocess.check_output(['git','status','--porcelain','--',planner,context],cwd=r,text=True).strip()
source={name:(r/name).read_bytes() for name in names}
for name,raw in source.items():
    p=out/'door_clearance_baseline'/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(raw)
(out/'door_clearance_baseline/.gdignore').write_text('# Historical source snapshot.\n')
data={name:raw.decode('utf-8-sig').replace('\r\n','\n') for name,raw in source.items()}
def edit(name,old,new,count=1):
    assert data[name].count(old)==count,(name,old)
    data[name]=data[name].replace(old,new)
edit(context,'var arrival_heading: Vector2 = Vector2.ZERO','var arrival_heading: Vector2 = Vector2.ZERO\n# Optional authored body padding; default preserves existing map placement.\nvar parking_clearance: float = 0.6')
edit(planner,'if not _candidate_is_free(occupied, position, pose_facing, profile):','if not _candidate_is_free(occupied, position, pose_facing, profile, context.parking_clearance if context != null else 0.6):')
old='static func _candidate_is_free(\n\toccupied: Array[Dictionary],\n\tposition: Vector2,\n\tfacing: Vector2,\n\tprofile: BattleVehiclePhysicalProfile\n) -> bool:'
new=old.replace('profile: BattleVehiclePhysicalProfile\n','profile: BattleVehiclePhysicalProfile,\n\tclearance: float = 0.6\n')
edit(planner,old,new)
edit(planner,'cleared_corners(ghost,0.6)','cleared_corners(ghost,clearance)')
edit(planner,'cleared_corners(other_ghost,0.6)','cleared_corners(other_ghost,clearance)')
edit(catalog,'const SOUTH_SHIFT = ROAD.size.y-12.0','const SOUTH_SHIFT = ROAD.size.y-12.0\nconst VEHICLE_CLEARANCE = 0.95*VehicleModels.TACTICAL_SCALE')
edit(catalog,'d.attacker_vehicle_placement_context=VehicleContext.new(true,ARRIVAL_CENTER,true,Vector2.LEFT)','d.attacker_vehicle_placement_context=VehicleContext.new(true,ARRIVAL_CENTER,true,Vector2.LEFT)\n\td.attacker_vehicle_placement_context.parking_clearance=VEHICLE_CLEARANCE')
edit(arrival,'for v in vehicles:convoy_length+=Body.profile_for_vehicle(v).length+1.3','for v in vehicles:convoy_length+=Body.profile_for_vehicle(v).length+2.0*Catalog.VEHICLE_CLEARANCE')
edit(arrival,'var context=preload("res://battle/vehicles/battle_vehicle_placement_context.gd").new(vehicles.size()==1,c,true,Vector2.LEFT)','var context=preload("res://battle/vehicles/battle_vehicle_placement_context.gd").new(vehicles.size()==1,c,true,Vector2.LEFT)\n context.parking_clearance=Catalog.VEHICLE_CLEARANCE')
note='\n\n## 20260915-harold-scale-06 - Mixed-convoy door clearance corrected\nA faction-appropriate Taiga/Bayou/Outlander screenshot fixture exposed a real invalid_vehicle_pose: old planner padding0.6 per body let adjacent open door proxies enter neighboring vehicle bodies by about0.1 world units. Native diagnostic records exact colliding body/door IDs in mixed_convoy_debug.log. Shared placement context now accepts authored parking_clearance with unchanged default0.6; planner forwards it. Only Harold sets1.52 per body, sufficient for both current-scale door leaves, and allocates matching convoy length. Bridge/estate behavior retains default. New planner/context files were clean before this narrow edit; exact before copies and hashes retained. No visual-only suppression of doors or relaxed collision validation. Next: rerun native heavy convoy, actual Orlov mixed convoy, default-context map smokes, final screenshot and records.\n'
for name in ['docs/DEAD_STREET_HIVE_MIND.md','docs/DEAD_STREET_JOURNAL.md']:
    with (r/name).open('a',encoding='utf-8') as f:f.write(note)
for name,text in data.items():
    assert (r/name).read_bytes()==source[name]
    (r/name).write_text(text,encoding='utf-8',newline='\n')
print('CLEARANCE_INSTALLED',json.dumps({name:hashlib.sha256((r/name).read_bytes()).hexdigest() for name in names}))
