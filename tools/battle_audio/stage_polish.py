from pathlib import Path
import subprocess
r=Path(__file__).resolve().parents[2]
def git(*args,**kw):return subprocess.run(['git',*args],cwd=r,check=True,**kw)
note='\n\n### Harold battle polish — 2026-09-10\n\nArrival choices, four open door cover spots, compact context panel, stalled aggressive-cover recovery, and revised weapon-only audio are implemented. See docs/HAROLD_BATTLE_POLISH_2026-09-10.md and docs/references/battle_polish for evidence and limitations. Original heartbeat/ambience assets are preserved. Second map requires discussion; broader campaign work, including individual tactical aftermath persistence, remains deferred.\n'
control='docs/DEAD_STREET_PROJECT_CONTROL.md';p=r/control
if note not in p.read_text(encoding='utf-8'):p.write_text(p.read_text(encoding='utf-8')+note,encoding='utf-8')
head=subprocess.check_output(['git','show','HEAD:'+control],cwd=r).decode()
blob=subprocess.check_output(['git','hash-object','-w','--stdin'],cwd=r,input=(head+note).encode()).decode().strip()
git('update-index','--cacheinfo','100644,'+blob+','+control)
ignore=r/'.gitignore';addition='\n# Local Harold polish captures and working transfers\ntools/battle_polish/results/\ntools/battle_polish/transfer/\ntools/battle_polish/*.log\ntools/battle_polish/*.uid\n'
if addition not in ignore.read_text():ignore.write_text(ignore.read_text()+addition)
paths=['.gitignore','battle/core/battle_state.gd','battle/combat/battle_combat_behavior_service.gd','battle/vehicles/battle_arrival_service.gd','gameplay/tactical_battle_view.gd','gameplay/tactical_deployment_controller.gd','gameplay/tactical_battle_presentation.gd','gameplay/tactical_battle_audio.gd','gameplay/harold_street_art.gd','tools/battle_showcase/scenario.gd','tools/battle_audio/refine_weapons.py','assets/audio/harold/WEAPON_REVISION.json','docs/HAROLD_BATTLE_POLISH_2026-09-10.md','docs/references/battle_polish']
paths += [f'assets/audio/harold/{kind}_{i}.wav' for kind in ['smg','rifle','pistol','shotgun'] for i in range(3)]
paths += ['tools/battle_polish/'+name for name in ['sweep.gd','variants.gd','validate.gd','handoff.gd','review.gd','record.ps1','encode_video.py','save_review.py']]
git('add','--',*paths)
git('diff','--cached','--check');git('diff','--cached','--stat')
