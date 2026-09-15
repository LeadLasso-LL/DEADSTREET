from pathlib import Path
import subprocess
r=Path(__file__).resolve().parents[2]
def git(*args,**kw):return subprocess.run(['git',*args],cwd=r,check=True,**kw)
assert not subprocess.check_output(['git','diff','--cached','--name-only'],cwd=r).strip(),'Preserve existing staged changes; stop for review'
note='\n\n### Harold battle effects and aftermath — 2026-09-10\n\nAdded modestly stronger hit spray, wounded trails and death pools; removed hit circles and floating combat-state labels. Exposed navigation to cover gains 18% speed without changing base or wounded tuning. All three requested victory endings now play before results: attackers enter the objective; defenders kneel beside fallen comrades; casualty-free defenders regroup, with wounded entering and healthy guarding outward. Original 72 BPM muffled 808 apartment instrumental and dry weapon revision 3 are reusable and reproducible. Heartbeat/start is preserved exactly. See docs/HAROLD_BATTLE_FINISH_2026-09-10.md and docs/references/battle_finish. Campaign consequences remain deferred.\n'
control='docs/DEAD_STREET_PROJECT_CONTROL.md';p=r/control
if note not in p.read_text(encoding='utf-8'):p.write_text(p.read_text(encoding='utf-8')+note,encoding='utf-8')
head=subprocess.check_output(['git','show','HEAD:'+control],cwd=r).decode()
blob=subprocess.check_output(['git','hash-object','-w','--stdin'],cwd=r,input=(head+note).encode()).decode().strip()
git('update-index','--cacheinfo','100644,'+blob+','+control)
ignore=r/'.gitignore';addition='\n# Local battle-finish capture and pose intermediates\ntools/battle_finish/results/\ntools/battle_finish/transfer/\ntools/battle_finish/pose_svg/\ntools/battle_finish/*.log\ntools/battle_finish/*.uid\n'
if addition not in ignore.read_text():ignore.write_text(ignore.read_text()+addition)
paths=['.gitignore','battle/runtime/battle_movement_service.gd','battle/presentation/tactical_unit_animation_catalog.gd','gameplay/tactical_blood_layer.gd','gameplay/tactical_battle_view.gd','gameplay/tactical_battle_outro.gd','gameplay/tactical_battle_presentation.gd','gameplay/tactical_battle_audio.gd','tools/battle_showcase/validate_presentation.gd','tools/unit_source_recovery/showcase_build.py','tools/battle_audio/build_audio.py','tools/battle_audio/refine_weapons.py','tools/battle_audio/build_apartment_trap.py','assets/art/units/pixel_v1/manifest.json','assets/audio/harold/SOURCE.json','assets/audio/harold/WEAPON_REVISION.json','assets/audio/harold/APARTMENT_TRAP.json','assets/audio/harold/apartment_beat.wav','docs/HAROLD_BATTLE_FINISH_2026-09-10.md']
paths += [f'assets/audio/harold/{kind}_{i}.wav' for kind in ['smg','rifle','pistol','shotgun'] for i in range(3)]
paths += [str(p.relative_to(r)) for p in (r/'assets/art/units/pixel_v1/check_comrade').glob('*.png')]
paths += [str(p.relative_to(r)) for p in (r/'docs/references/battle_finish').iterdir() if p.suffix not in ['.import','.uid']]
paths += ['tools/battle_finish/'+name for name in ['validate.gd','review.gd','record.ps1','encode_video.py','save_review.py','build_check_pose.py','render_check_pose.gd','finish_check_pose.py']]
git('add','--',*paths)
git('diff','--cached','--check');git('diff','--cached','--stat')
