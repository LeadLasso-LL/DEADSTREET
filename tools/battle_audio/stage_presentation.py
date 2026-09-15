from pathlib import Path
import subprocess,shutil
r=Path(__file__).resolve().parents[2]
def git(*args,**kw):return subprocess.run(['git',*args],cwd=r,check=True,**kw)
result=r/'tools/battle_showcase/results';ref=r/'docs/references/audio_cinematics';ref.mkdir(parents=True,exist_ok=True)
for name in ['video_opening.png','video_combat.png','video_results.png','presentation_checks.json','audio_mix_validation.json','video_integrity.json','selection.json','seed_2002.json']:
 shutil.copy2(result/name,ref/name)
rel='docs/DEAD_STREET_PROJECT_CONTROL.md';p=r/rel
note='''\n\n## Harold audio and cinematics checkpoint — 2026-09-10\n\nImplemented arrival/result presentation and original audio on top of the accepted map and 4v4 HUD/outfits. See `docs/AUDIO_CINEMATICS_2026-09-10.md` for the presentation contract, original emblem provenance, sound design, validation and recording reproduction. Use the approved Mercer Saints M and Orlov Bratva eagle consistently in context, unit markers and results.\n\nThe 62.4-second `Dead_Street_Harold_Audio_Cinematics.mp4` contains covered deployment, arrival, live combat audio and terminal results. 121 new presentation checks pass. The existing medium arrival slot remains in use; the separately planned close/medium/far selector is still a future deployment milestone.\n'''.encode()
base=subprocess.check_output(['git','show','HEAD:'+rel],cwd=r)
working=p.read_bytes()
if note not in working:p.write_bytes(working+note)
if note not in base:base+=note
blob=git('hash-object','-w','--stdin',input=base,stdout=subprocess.PIPE).stdout.decode().strip()
git('update-index','--cacheinfo','100644,'+blob+','+rel)
paths=['docs/AUDIO_CINEMATICS_2026-09-10.md','docs/references/audio_cinematics','assets/art/factions','assets/audio/harold',
'gameplay/gameplay_runtime.gd','gameplay/harold_street_art.gd','gameplay/tactical_battle_view.gd','gameplay/tactical_command_hud.gd',
'gameplay/battle_faction_identity.gd','gameplay/tactical_battle_audio.gd','gameplay/tactical_battle_presentation.gd','gameplay/tactical_unit_card.gd',
'gameplay/battle_faction_identity.gd.uid','gameplay/tactical_battle_audio.gd.uid','gameplay/tactical_battle_presentation.gd.uid','gameplay/tactical_unit_card.gd.uid',
'tools/battle_audio/.gitignore','tools/battle_audio/build_audio.py','tools/battle_showcase/.gitignore','tools/battle_showcase/review.gd','tools/battle_showcase/scenario.gd','tools/battle_showcase/record.ps1','tools/battle_showcase/encode_video.py','tools/battle_showcase/validate_presentation.gd']
git('add','--',*[p for p in paths if (r/p).exists()])
git('diff','--cached','--check')
git('diff','--cached','--stat')
