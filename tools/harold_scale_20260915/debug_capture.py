from pathlib import Path
import subprocess,sys
sys.stdout.reconfigure(encoding='utf-8',errors='backslashreplace')
out=Path(__file__).parent;r=out.parents[1];dbg=out/'debug';dbg.mkdir(exist_ok=True);(dbg/'.gdignore').write_text('# Isolated diagnostic source copies.\n')
s=(r/'gameplay/arsenal_battle_fixture.gd').read_text(encoding='utf-8-sig')
s=s.replace('if committed==null or not committed.success:return','if committed==null or not committed.success:dump_vehicles(b);return')
s+='\nstatic func dump_vehicles(b):\n var body=preload("res://battle/vehicles/battle_vehicle_body_service.gd")\n for v in b.vehicles.values():\n  print("POSE_AUDIT ",v.battle_vehicle_id," ",v.vehicle_type_id," ",v.battle_position," ",v.facing_direction," ",body.get_placement_error(b,v.battle_vehicle_id,v.battle_position,v.facing_direction))\n  for ob in b.battlefield_geometry.obstacles.values():\n   if body.pose_intersects_rect(v.battle_position,v.facing_direction,body.profile_for_vehicle(v),ob.bounds):print("HITS_OBSTACLE ",v.battle_vehicle_id," ",ob.obstacle_id," ",ob.bounds)\n'
(dbg/'fixture.gd').write_text(s,encoding='utf-8')
s=(r/'gameplay/arsenal_review.gd').read_text(encoding='utf-8-sig').replace('res://gameplay/arsenal_battle_fixture.gd','res://tools/harold_scale_20260915/debug/fixture.gd')
(dbg/'review.gd').write_text(s,encoding='utf-8')
s='extends SceneTree\nfunc _initialize():call_deferred("run")\nfunc run():\n var scene=load("res://gameplay/arsenal_review.tscn").instantiate()\n scene.set_script(load("res://tools/harold_scale_20260915/debug/review.gd"))\n root.add_child(scene)\n await process_frame\n var config=preload("res://tools/sandbox_setup/scenarios.gd").make(12,12,["taiga","bayou","outlander"])\n config.map_id="harold";config.attacker.faction="orlov";config.defender.faction="mercer"\n await scene.start_battle(false,config)\n quit()\n'
(dbg/'check.gd').write_text(s,encoding='utf-8')
engine=str(r.parent/'Godot/Godot_v4.7.2-stable_win64.exe')
p=subprocess.Popen([engine,'--path',str(r),'--script','res://tools/harold_scale_20260915/debug/check.gd','--log-file',str(out/'mixed_convoy_debug.log')]);print('PID',p.pid,flush=True);p.wait(timeout=90)
print((out/'mixed_convoy_debug.log').read_text(encoding='utf-8')[-4000:])