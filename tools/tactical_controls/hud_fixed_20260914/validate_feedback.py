from pathlib import Path
import subprocess,sys
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');d=r/'tools/tactical_controls/hud_fixed_20260914';g=r'C:\Users\brand\AppData\Local\DeadStreetTools\godot_release_4.7.2\godot.exe'
p=r/'gameplay/tactical_compact_card.gd';s=p.read_text(encoding='utf-8');old='\trole.visible = not condensed';assert old in s;s=s.replace(old,'\tfor field in [role, weapon_model, status, number, command_status]:\n\t\tfield.size.y = 14.0 if field == role else 12.0\n'+old,1);p.write_text(s,encoding='utf-8')
p=r/'tools/tactical_controls/estate_assault_checks.gd';s=p.read_text();s=s.replace('    var obstacle=b.battlefield_geometry.get_obstacle(id)','    if id.begins_with(v.battle_vehicle_id+\'__door\'):continue # Hinged parts of this vehicle, not scenery.\n    var obstacle=b.battlefield_geometry.get_obstacle(id)',1);p.write_text(s)
def run(args,label,timeout=150):
 result=subprocess.run(args,cwd=r,capture_output=True,timeout=timeout);t=(result.stdout+result.stderr).decode('utf-8',errors='replace');(d/(label+'.log')).write_bytes(t.replace('\r','').encode());bad=result.returncode or any(k in t for k in ['SCRIPT ERROR','HUD_FAIL','ESTATE_FAIL','ASSAULT_FAIL','CONTROLS_FAIL','RECORD_ERROR']);print(label,'exit',result.returncode,'errors',bool(bad),t[-5000:] if bad else t[-600:],flush=True);assert not bad,label
run([sys.executable,str(r/'tools/tactical_controls/run.py'),'pack'],'pack_ui_fixed')
run([g,'--','--check=hud_layout_review'],'hud_layout_fixed')
run([g,'--headless','--','--check=estate_assault_checks'],'assault_fixed')
run([g,'--','--check=line_native'],'line_native_fixed')
run([g,'--','--check=estate_bake'],'bake_ground')
run([g,'--','--check=estate_bake_props'],'bake_props')
run([sys.executable,str(r/'tools/tactical_controls/run.py'),'pack'],'pack_baked')
run([g,'--fixed-fps','30','--disable-vsync','--','--check=estate_audit'],'estate_audit',240)
print('FEEDBACK_NATIVE_GATES_COMPLETE',flush=True)
