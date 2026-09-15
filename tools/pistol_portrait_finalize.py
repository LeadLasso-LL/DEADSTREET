from pathlib import Path
import json,hashlib,subprocess,sys
R=Path(__file__).resolve().parent.parent;O=R/'tools/pistol_portrait_20260914'
def git(*args,**kw):return subprocess.check_output(['git',*args],cwd=R,stderr=subprocess.DEVNULL,**kw)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
assert not git('diff','--cached','--name-only').strip()
check=json.loads((O/'native_card_checks.json').read_text());assert check=={'checks':556,'failures':[],'portraits':139},check
protected=json.loads((O/'protected_hashes.json').read_text());assert all(sha(R/p)==h for p,h in protected.items())
validation=json.loads((O/'validation.json').read_text());assert all(sha(R/x['portrait'])==x['candidate_sha256'] for x in validation['items'])
entry='\n\n## 20260914-pistol-portrait-03 - Installed and native-validated; scoped publication\n\nInstalled 138 reviewed regular pistol card PNGs. All 139 pistol catalog entries including unchanged Mercer dual specialist pass 556 native binding/path/texture/visible-pixel checks with zero failures. All 415 protected hashes remain identical. Initial native verification exposed 12 stale imported legacy portraits; refreshed only those caches through an isolated native editor project, then reran the exact catalog probe successfully. Transparent RGB padding is correctly ignored; visible pixels and alpha must match. One remote launch timed out before starting; saved reports/process inspection established no running task, and retry succeeded in 4.50s. No live loaders/gameplay/animation source modified. No new anatomy defects seen in the inspected 276 regular standing views and specialist pair. Static-card scope only; no full animation or broad regression claim. Source adapter, immutable before-art baseline, visual sheets and reproduction/finishing instructions saved in tools/pistol_portrait_20260914/README.md. Next: owner review of corrected cards; retain this card finishing step after future atlas rebuilds. Scoped commit/push proceeding under standing authorization. Other chats and inherited dirty work remain uncommitted and preserved.\n'
journal=R/'docs/DEAD_STREET_JOURNAL.md'
with journal.open('a',encoding='utf-8') as f:f.write(entry)
control='\n\n## 2026-09-14 — Pistol card anatomy pass (pistol-portrait-03)\n\nIMPLEMENTED / VALIDATED: all 138 regular pistol portraits across 23 factions repaired for visible SW far/right forearm continuity, with connected legacy Mercer/Orlov shoulders. SW/SE static views reviewed; unchanged dual specialist included in 139-entry native loading check (556 checks, zero failures). Preserve accepted battle and full animation assets. Owner visual acceptance pending. Evidence and required portrait finishing step: [pistol card README](../tools/pistol_portrait_20260914/README.md).\n'
standard='\n\n## Pistol card forearm continuity — 2026-09-14\n\nSW/SE pistol card portraits must retain a visible continuous elbow-to-hand forearm connection and shoulders joined into the garment/torso. Preserve existing joints, body proportions, grip anchors and mirror convention. The card-only finishing pass is documented in [the pistol portrait report](../tools/pistol_portrait_20260914/README.md). Full atlas rebuilds must retain/reapply that finishing pass before publishing card crops; an uncorrected atlas crop is not the accepted card baseline. This standing-image correction does not certify unreviewed animation stances.\n'
for path,section in [('docs/DEAD_STREET_PROJECT_CONTROL.md',control),('docs/UNIT_ART_STANDARD.md',standard)]:
 with (R/path).open('a',encoding='utf-8') as f:f.write(section)
def hive_edit(s):
 for marker,replacement in [
 ('**Active objective:**','**Active objective:** Pistol card anatomy pass implemented and validated: 138 regular portraits repaired, all SW/SE static views reviewed, unchanged dual specialist included in 139-entry native check. See journal pistol-portrait-03 and tools/pistol_portrait_20260914/README.md.'),
 ('**Immediate next task:**','**Immediate next task:** Owner reviews the repaired pistol cards. Preserve accepted battle/presentation and animation assets. Future atlas rebuilds must reapply the documented portrait finishing step. Native check passes 556 checks/zero failures; no render or repair task remains running.'),
 ('**Checkpoint / publication:**','**Checkpoint / publication:** Pistol portrait checkpoint prepared on build/arsenal-checkpoint-20260911 from verified 54b1597; scoped commit/push under standing authorization. Exact resulting SHA/remote verification will be saved in tools/pistol_portrait_20260914/checkpoint_receipt.json. The estate presentation remains the version-6 checkpoint.')]:
  a=s.index(marker);b=s.index('\n\n',a);s=s[:a]+replacement+s[b:]
 s=s.replace('Version-5 video 88.197s','Version-6 video 88.197s')
 return s
hive=R/'docs/DEAD_STREET_HIVE_MIND.md';hive.write_text(hive_edit(hive.read_text(encoding='utf-8')),encoding='utf-8')
def stage_text(path,text):
 h=git('hash-object','-w','--stdin',input=text.encode('utf-8')).decode().strip()
 git('update-index','--add','--cacheinfo','100644,'+h+','+path)
for path,section in [('docs/DEAD_STREET_PROJECT_CONTROL.md',control),('docs/UNIT_ART_STANDARD.md',standard)]:
 stage_text(path,git('show','HEAD:'+path).decode('utf-8')+section)
stage_text('docs/DEAD_STREET_HIVE_MIND.md',hive_edit(git('show','HEAD:docs/DEAD_STREET_HIVE_MIND.md').decode('utf-8')))
s=journal.read_text(encoding='utf-8');own=[]
for chunk in s.split('\n## '):
 if chunk.startswith('20260914-pistol-portrait-'):own.append('\n## '+chunk)
assert len(own)==3,len(own)
stage_text('docs/DEAD_STREET_JOURNAL.md',git('show','HEAD:docs/DEAD_STREET_JOURNAL.md').decode('utf-8')+'\n'+''.join(own))
names=['README.md','portrait_anatomy.py','worker.py','render.gd','build_portraits.py','install.py','refresh_imports.py','inventory.json','before_portraits.zip','validation.json','protected_hashes.json','native_card_checks.gd','native_card_checks.json','candidate_sample.png']
paths=[x['portrait'] for x in validation['items']]+['tools/pistol_portrait_20260914/'+name for name in names]+[p.relative_to(R).as_posix() for p in (O/'review').glob('*.png')]
git('add','--',*paths)
staged=git('diff','--cached','--name-only').decode().splitlines()
allowed=set(paths)|{'docs/DEAD_STREET_PROJECT_CONTROL.md','docs/UNIT_ART_STANDARD.md','docs/DEAD_STREET_HIVE_MIND.md','docs/DEAD_STREET_JOURNAL.md'}
assert set(staged)<=allowed
git('diff','--cached','--check')
print('STAGED',len(staged),'PORTRAITS',len(validation['items']),'PROTECTED',len(protected),'CHECKS',check['checks'])
print(git('diff','--cached','--stat').decode())
