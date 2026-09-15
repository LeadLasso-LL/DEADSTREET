from pathlib import Path
import subprocess,json,difflib,hashlib
r=Path("C:\\Users\\brand\\OneDrive\\Documents\\dead-street");o=r/'tools/fourth_map_20260915'
def git(*args):return subprocess.run(['git',*args],cwd=r,capture_output=True,check=True).stdout.decode('utf-8')
print('HEAD',git('rev-parse','HEAD').strip());print('INDEX',git('diff','--cached','--name-only').strip());print('BRANCH',git('branch','--show-current').strip())
report=[]
for before in (o/'before').rglob('*.gd'):
 rel=before.relative_to(o/'before').as_posix();old=before.read_text(encoding='utf-8');new=(r/rel).read_text(encoding='utf-8');head=git('show','HEAD:'+rel);current=head;conflicts=[]
 a=old.splitlines(keepends=True);b=new.splitlines(keepends=True)
 for tag,i,j,k,l in reversed(difflib.SequenceMatcher(a=a,b=b,autojunk=False).get_opcodes()):
  if tag=='equal':continue
  left=''.join(a[max(0,i-2):i]);right=''.join(a[j:j+2]);needle=left+''.join(a[i:j])+right;replacement=left+''.join(b[k:l])+right
  if current.count(needle)!=1:conflicts.append({'lines':[i+1,j],'old':''.join(a[i:j]),'new':''.join(b[k:l])});continue
  current=current.replace(needle,replacement,1)
 report.append({'path':rel,'conflicts':conflicts,'owned_changes':old!=new,'unrelated_changes_in_file':head!=old})
print(json.dumps(report,indent=2));(o/'checkpoint_scope_review.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
