from pathlib import Path
import subprocess,json,hashlib
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');o=r/'tools/whittaker_estate'
scope=["gameplay/tactical_actor_presenter.gd","gameplay/tactical_orders_controller.gd","gameplay/tactical_battle_view.gd","gameplay/tactical_battle_outro.gd","gameplay/tactical_faction_voices.gd","gameplay/tactical_camera_safety.gd","gameplay/tactical_battle_presentation.gd","gameplay/estate_architecture.gd","gameplay/estate_battle_setup.gd","gameplay/whittaker_estate_art.gd","gameplay/tactical_convoy_audio.gd","battle/geometry/whittaker_estate_catalog.gd","battle/presentation/tactical_participant_visual.gd","tools/tactical_controls/estate_geometry.gd","tools/tactical_controls/estate_audit.gd","tools/tactical_controls/estate_preview.gd","tools/tactical_controls/estate_record.gd","tools/tactical_controls/run.py","tools/whittaker_estate/record_worker.py","tools/whittaker_estate/encode.py","tools/whittaker_estate/README.md","docs/DEAD_STREET_HIVE_MIND.md","docs/DEAD_STREET_PROJECT_CONTROL.md","docs/DEAD_STREET_JOURNAL.md"]
scope += [str(p.relative_to(r)).replace('\\','/') for root in [r/'assets/art/whittaker_estate',r/'assets/audio/factions'] for p in root.rglob('*') if p.is_file() and p.suffix in ['.png','.ogg','.json']]
scope += ['tools/whittaker_estate/'+name for name in ['geometry.json','native.json','record.json','record_source_hashes.json','delivery.json','estate_overview.png','estate_house_detail.png','intro_full.png','arrival.png','combat_12.png','combat_30.png','aftermath.png','results.png']]
scope += ['tools/whittaker_estate/resume_20260914/'+name for name in ['record.json','line_checks.log','line_native.log','native_final.log']]
assert all((r/p).is_file() for p in scope)
assert not subprocess.check_output(['git','diff','--cached','--name-only'],cwd=r,text=True).strip()
subprocess.run(['git','diff','--check','--',*scope],cwd=r,check=True)
changed=subprocess.check_output(['git','status','--short','--untracked-files=all','--',*scope],cwd=r,text=True)
print('SCOPED_STATUS\n'+changed)
print('SCOPED_DIFF_STAT\n'+subprocess.check_output(['git','diff','--stat','--',*scope],cwd=r,text=True))
print('EXCLUDED_TRACKED\n'+subprocess.check_output(['git','status','--short','--untracked-files=no','--','battle/core/battle_victory_service.gd','tools/character_factory','tools/dusk_review','tools/unit_source_recovery'],cwd=r,text=True))
(o/'resume_20260914/checkpoint_scope.json').write_text(json.dumps(scope,indent=2),encoding='utf-8')
(o/'resume_20260914/checkpoint_scope.txt').write_bytes(b'\0'.join(p.encode() for p in scope)+b'\0')
print('REVIEW_MANIFEST_WRITTEN; no staging, commit or push performed')
