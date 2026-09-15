import pathlib,subprocess
p=pathlib.Path(r'C:\Users\brand\OneDrive\Documents\dead-street'); out=p/'tools/cover_interactions_20260915/validation'
stop="Get-CimInstance Win32_Process -Filter 'ProcessId=3352' | Where-Object { $_.CommandLine -like '*cover_interactions_20260915/validation/other_maps.gd*' } | ForEach-Object { Stop-Process -Id $_.ProcessId }"
subprocess.run(['powershell','-NoProfile','-Command',stop],check=True)
legacy=(out.parent/'before/tactical_participant_visual.gd').read_text(); assert legacy.startswith('class_name TacticalParticipantVisual\n'); (out/'legacy_visual.gd').write_text(legacy.removeprefix('class_name TacticalParticipantVisual\n'))
f=out/'other_maps.gd';t=f.read_text().replace('res://tools/cover_interactions_20260915/before/tactical_participant_visual.gd','res://tools/cover_interactions_20260915/validation/legacy_visual.gd'); f.write_text(t)
godot=r'C:\Users\brand\OneDrive\Documents\Godot\Godot_v4.7.2-stable_win64.exe'
with (out/'other_maps_final_stdout.log').open('w',encoding='utf-8') as log:
 child=subprocess.Popen([godot,'--path',str(p),'--log-file',str(out/'other_maps_final.log'),'--script','res://tools/cover_interactions_20260915/validation/other_maps.gd'],cwd=p,stdout=log,stderr=subprocess.STDOUT);print('PID',child.pid,flush=True);print('EXIT',child.wait(timeout=180),flush=True)