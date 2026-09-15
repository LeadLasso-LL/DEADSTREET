from pathlib import Path
import subprocess,shutil
r=Path(__file__).resolve().parents[2]
def git(*args,**kw):return subprocess.run(['git',*args],cwd=r,check=True,**kw)
assert not git('diff','--cached','--name-only',capture_output=True,text=True).stdout.strip(), 'Preserve existing staged changes'
ref=r/'docs/references/battle_showcase';ref.mkdir(parents=True,exist_ok=True)
shutil.copy2(r/'tools/unit_source_recovery/showcase_lineup.png',ref/'outfit_lineup.png')
for name in ['validation.json','atlas_checks.json','selection.json','seed_2005.json','video_integrity.json']:
 shutil.copy2(r/'tools/battle_showcase/results'/name,ref/name)
shutil.copy2(r/'tools/battle_showcase/results/video_middle.png',ref/'battle_hud.png')
paths=['docs/BATTLE_SHOWCASE_2026-09-10.md',str(ref.relative_to(r)),'gameplay/tactical_command_hud.gd','gameplay/tactical_command_hud.gd.uid','gameplay/tactical_battle_view.gd','gameplay/tactical_actor_presenter.gd','battle/presentation/tactical_unit_animation_catalog.gd','tools/unit_source_recovery/.gitignore']
paths += ['tools/unit_source_recovery/src/'+p for p in ['outfits.py','build.py','directions.py','base_rig.py','directional_base/lower_body.py','directional_base/views.py']]
paths += ['tools/unit_source_recovery/'+p for p in ['showcase_build.py','showcase_render.gd','showcase_finish.py','showcase_install.py','showcase_portraits.py','showcase_contact_sheets.py']]
paths += ['tools/battle_showcase/'+p for p in ['.gitignore','scenario.gd','review.gd','validate.gd','check_atlases.py','record.ps1','encode_video.py']]
base='assets/art/units/pixel_v1/'
paths += [base+'manifest.json',base+'death_back',base+'portraits']
for k in range(2):
 for w in ['uzi_smg','ak_rifle','pistol','pump_shotgun']:
  paths += [base+f'{k}_{w}.png',base+f'blood_masks/{k}_{w}.png']
git('add','--',*paths)
# Add only this pointer to the control document's index blob; retain its earlier working edits.
p='docs/DEAD_STREET_PROJECT_CONTROL.md';old=git('show','HEAD:'+p,capture_output=True).stdout
note=b'\n## Latest implementation: Harold 4v4 recording (2026-09-10)\n\nSee [BATTLE_SHOWCASE_2026-09-10.md](BATTLE_SHOWCASE_2026-09-10.md) for the faction wardrobe specification, live four-card HUD, recovered whole-force controls, backward deaths, validation and reproducible recording setup. The prior approved Harold map baseline remains in force; new character/HUD visuals are ready for product-owner review.\n\n'
def add_note(b):i=b.index(b'\n')+1;return b[:i]+note+b[i:]
working=r/p;working.write_bytes(add_note(working.read_bytes()))
blob=git('hash-object','-w','--stdin',input=add_note(old),capture_output=True).stdout.decode().strip()
git('update-index','--cacheinfo','100644',blob,p)
git('diff','--cached','--check')
git('diff','--cached','--stat')
