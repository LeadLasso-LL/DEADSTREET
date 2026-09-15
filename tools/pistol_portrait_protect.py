from pathlib import Path
import subprocess,json,hashlib
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');o=r/'tools/pistol_portrait_20260914'
def git(*args):return subprocess.check_output(['git',*args],cwd=r,text=True,encoding='utf-8')
assert not git('diff','--cached','--name-only').strip()
dirty=git('diff','--name-only').splitlines()
rows=json.loads((o/'inventory.json').read_text())
paths={x['atlas'] for x in rows}|set(dirty)-{'docs/DEAD_STREET_HIVE_MIND.md','docs/DEAD_STREET_JOURNAL.md'}
paths|={p.relative_to(r).as_posix() for folder in ['battle','gameplay','tools/unit_source_recovery/src','tools/faction_design','tools/arsenal_production'] for p in (r/folder).rglob('*') if p.is_file() and p.suffix in ['.gd','.py']}
paths|={x['portrait'] for x in rows if x['group']=='mercer'}
hashes={s:hashlib.sha256((r/s).read_bytes()).hexdigest() for s in sorted(paths)}
(o/'protected_hashes.json').write_text(json.dumps(hashes,indent=2)+'\n')
with (r/'docs/DEAD_STREET_JOURNAL.md').open('a',encoding='utf-8') as f:f.write('\n\n## 20260914-pistol-portrait-02 - Full roster anatomy repair visually checked\n\nInspected 138 regular portraits (23 factions, six pistol models each) in SW and SE, plus intact Mercer dual-pistol specialist. Shared torso layering hid the proximal far/right forearm in SW; the portrait-only generator now redraws the original elbow-to-hand segment at its original radius. Legacy Mercer/Orlov shoulder caps now use connected garment joins without changing shoulder/elbow/wrist positions. All other outfit adapters remain unchanged. All 276 generated regular views visually checked on six fixed-scale sheets, with native-size portraits and a six-outfit before/after comparison. No new visible anatomy fault found. Original source renders match all 138 installed portraits pixel-for-pixel; candidate deltas total 10,987 pixels confined to arms. Body/lower geometry and weapon/hand group are identical. World animation and dual specialist remain untouched. Two prototype setup failures (missing worker import path, then unregistered SVG namespace) were corrected before any asset installation. Next: install exact reviewed candidates, native card texture checks, protected-source verification, then scoped commit/push. Candidate evidence: tools/pistol_portrait_20260914/.\n')
print('PROTECTED',len(hashes),'HEAD',git('rev-parse','HEAD').strip(),'DIRTY',len(dirty))
print((r/'AGENTS.md').read_text(encoding='utf-8'))
