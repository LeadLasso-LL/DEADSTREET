from pathlib import Path
import subprocess
r=Path(__file__).resolve().parents[2]
def git(*a,**kw):return subprocess.run(['git',*a],cwd=r,check=True,**kw)
rel='docs/DEAD_STREET_PROJECT_CONTROL.md';p=r/rel
note='\n\n## Relative strength and reactive AI — 2026-09-10\n\nAdded the live bottom-HUD strength meter and strength-aware AI force intent. See `docs/RELATIVE_STRENGTH_AI_2026-09-10.md` for authority rules, provisional thresholds, the unscripted counterattack evidence and deferred visual feedback. 853 checks passed. The approved audio/cinematics video remains the earlier staged showcase; the new AI review has no timed defender orders.\n'.encode()
base=subprocess.check_output(['git','show','HEAD:'+rel],cwd=r);working=p.read_bytes()
if note not in working:p.write_bytes(working+note)
if note not in base:base+=note
blob=git('hash-object','-w','--stdin',input=base,stdout=subprocess.PIPE).stdout.decode().strip()
git('update-index','--cacheinfo','100644,'+blob+','+rel)
paths=['battle/ai/battle_relative_strength.gd','battle/ai/battle_adaptive_tactics.gd','battle/ai/battle_relative_strength.gd.uid','battle/ai/battle_adaptive_tactics.gd.uid','battle/core/battle_state.gd','battle/core/battle_tactical_force.gd','battle/core/battle_force_command_service.gd','battle/runtime/battle_runtime_service.gd','battle/combat/battle_combat_behavior_service.gd','gameplay/tactical_command_hud.gd','tools/strength_review/.gitignore','tools/strength_review/validate.gd','tools/strength_review/review.gd','docs/RELATIVE_STRENGTH_AI_2026-09-10.md','docs/references/relative_strength']
git('add','--',*[p for p in paths if (r/p).exists()])
git('diff','--cached','--check')
git('diff','--cached','--stat')
