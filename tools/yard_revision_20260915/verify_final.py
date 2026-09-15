from pathlib import Path
import json,hashlib,subprocess
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');o=r/'tools/yard_revision_20260915';base=json.loads((o/'baseline.json').read_text())
allowed={'battle/geometry/doble_ocho_catalog.gd','gameplay/doble_ocho_art.gd','gameplay/doble_ocho_setup.gd','gameplay/tactical_convoy_audio.gd'}
changed=[n for n,h in base['sources'].items() if hashlib.sha256((r/n).read_bytes()).hexdigest()!=h];unexpected=[n for n in changed if n.replace('\\','/') not in allowed]
capture=json.loads((o/'ravicci/capture_source_hashes.json').read_text());after_capture=[n for n,h in capture.items() if hashlib.sha256((r/n).read_bytes()).hexdigest()!=h]
def git(*a):return subprocess.run(['git',*a],cwd=r,capture_output=True,check=True).stdout.decode('utf-8').strip()
result={'head':git('rev-parse','HEAD'),'branch':git('branch','--show-current'),'index':git('diff','--cached','--name-only'),'production_baseline_count':len(base['sources']),'changed_by_revision':changed,'unexpected_changes':unexpected,'capture_source_count':len(capture),'changed_since_capture':after_capture}
(o/'preservation.json').write_text(json.dumps(result,indent=2));print(json.dumps(result,indent=2));assert not unexpected and not after_capture
