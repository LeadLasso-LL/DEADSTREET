from pathlib import Path
import subprocess,json,hashlib
r=Path('C:/Users/brand/OneDrive/Documents/dead-street');d=r/'tools/tactical_controls/hud_fixed_20260914';scope=json.loads((d/'feedback_scope.json').read_text())
p=r/'tools/tactical_controls/estate_audit.gd';before=p.read_bytes();after=before.rstrip()+b'\n';p.write_bytes(after)
receipt={'captured_sources':'tools/whittaker_estate/record_source_hashes.json','post_capture_changes':[{'path':str(p.relative_to(r)),'reason':'Removed one extra blank line at EOF from audit fixture; no runtime/capture behavior change','before_sha256':hashlib.sha256(before).hexdigest(),'after_sha256':hashlib.sha256(after).hexdigest()}],'video_version':3,'video_sha256':'4b3925d681c7c22d11e97571d903e332909718b3f146c2b448cfd8d92519bfbe','unrelated_work':'preserved'}
p=d/'feedback_validation.json';p.write_text(json.dumps(receipt,indent=2));scope.append(p.relative_to(r).as_posix());(d/'feedback_scope.json').write_text(json.dumps(scope,indent=2))
assert not subprocess.check_output(['git','diff','--cached','--name-only'],cwd=r,text=True).strip()
check=subprocess.run(['git','diff','--check','--']+scope,cwd=r,capture_output=True,text=True);print('DIFF_CHECK',check.returncode,check.stdout);assert check.returncode==0
add=subprocess.run(['git','add','-A','--']+scope,cwd=r,capture_output=True,text=True);assert add.returncode==0,add.stderr
staged=subprocess.check_output(['git','diff','--cached','--name-only'],cwd=r,text=True).splitlines();assert set(staged)<=set(scope)
check=subprocess.run(['git','diff','--cached','--check'],cwd=r,capture_output=True,text=True);print('STAGED_CHECK',check.returncode,check.stdout);assert check.returncode==0
print('SCOPED_PATHS',len(staged));print(subprocess.check_output(['git','diff','--cached','--stat'],cwd=r,text=True))
