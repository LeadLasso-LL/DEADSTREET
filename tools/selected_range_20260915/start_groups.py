from pathlib import Path
import subprocess,json,hashlib
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street'); o=r/'tools/selected_range_groups_20260915';o.mkdir(exist_ok=True)
p=r/'gameplay/tactical_orders_controller.gd'
assert not subprocess.check_output(['git','-C',str(r),'diff','HEAD','--',str(p)],text=True),'Selection controller has existing edits'
paths=['gameplay/tactical_orders_controller.gd','gameplay/tactical_selection_range.gd','gameplay/tactical_selection_range.gdshader']
for n in paths:
    src=r/n; (o/('before_'+src.name+'.txt')).write_bytes(src.read_bytes())
(o/'baseline_hashes.json').write_text(json.dumps({n:hashlib.sha256((r/n).read_bytes()).hexdigest() for n in paths},indent=2))
message="\n\n## 20260915-selected-range-05 — Class-group extension authorized and started\n\nBrandon approved: \"yeah go ahead and do individuals and class groups\". Keep accepted individual rendering; same-weapon-class selected groups get faint soft outlines only, with maximum-opacity compositing so overlapping rings do not accumulate brightness. Mixed groups and Select All suppress ranges. Each outline uses its unit's actual equipped maximum range. Implementation choice: mark Select All selection explicitly in the controller (including homogeneous squads); manually assembled homogeneous groups also qualify, and a single selected unit keeps individual presentation. No command, combat, HUD, audio or camera changes intended. Preserve current uncommitted indicator work and all concurrent portrait/music work. Fresh branch build/arsenal-checkpoint-20260911, HEADd262e8f, index empty; own indicator/view hashes unchanged from validation. Scope extends to narrow selection-display metadata in tactical_orders_controller.gd, new group shader, range node and tools/selected_range_groups_20260915/. Next: implement, check actual native class-button behavior/overlap pixels and preserve the accepted individual image. Existing Git publication blocker is separate and not retried.\n"
for n in ['DEAD_STREET_JOURNAL.md','DEAD_STREET_HIVE_MIND.md']:
    p=r/'docs'/n; before=p.read_bytes(); t=before.decode('utf-8')
    if message.strip() not in t:
        assert p.read_bytes()==before
        p.write_text(t+message,encoding='utf-8',newline='\n')
print('Verified controller clean, preserved baseline, recorded scope and authorization.')
