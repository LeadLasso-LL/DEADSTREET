from pathlib import Path
import subprocess,json,hashlib,sys
r=Path(__file__).resolve().parents[2]; out=Path(__file__).parent
def git(*args,**kw):
    return subprocess.check_output(['git','-C',str(r),*args],text=True,**kw).strip()
branch='build/arsenal-checkpoint-20260911'
assert git('branch','--show-current')==branch
assert git('remote','get-url','origin')=='https://github.com/LeadLasso-LL/DEADSTREET.git'
assert not git('diff','--cached','--name-only'),'Shared index is occupied'
head=git('rev-parse','HEAD')
assert git('ls-remote','origin','refs/heads/'+branch).split()[0]==head,'Remote moved'
report=json.loads((out/'native_validation.json').read_text())
assert report['checks']==234 and not report['errors']
hashes=json.loads((out/'final_source_hashes.json').read_text())
for p,h in hashes.items(): assert hashlib.sha256((r/p).read_bytes()).hexdigest()==h,p+' changed since validation'
owned=list(hashes)
names=['README.md','check_native.gd','run_native.py','native_validation.json','native.log','final_source_hashes.json','range_feature.patch','install_receipt.json','doc_deltas.json']
owned += [str((out/n).relative_to(r)).replace('\\','/') for n in names]
owned += [str(p.relative_to(r)).replace('\\','/') for p in out.glob('*.png')]
for p in ['gameplay/tactical_selection_range.gd.uid','gameplay/tactical_selection_range.gdshader.uid']:
    if (r/p).exists(): owned.append(p)
updates=json.loads((out/'doc_deltas.json').read_text(encoding='utf-8'))
doc_blobs={}
for item in updates:
    text=git('show',head+':'+item['path'])+'\n'
    for old,new in item['replacements']:
        assert text.count(old)==1 or new in text,'Committed coordination changed'
        text=text.replace(old,new,1)
    if item['append'].strip() not in text: text+=item['append']
    doc_blobs[item['path']]=git('hash-object','-w','--stdin',input=text)
assert git('rev-parse','HEAD')==head and not git('diff','--cached','--name-only')
git('add','--',*owned)
for p,blob in doc_blobs.items(): git('update-index','--add','--cacheinfo','100644',blob,p)
expected=set(owned)|set(doc_blobs)
actual=set(git('diff','--cached','--name-only').splitlines())
assert actual==expected,{'unexpected':list(actual-expected),'missing':list(expected-actual)}
assert git('rev-parse','HEAD')==head
git('diff','--cached','--check')
git('commit','-m','Add soft selected-unit weapon-range ground indicator')
commit=git('rev-parse','HEAD')
receipt={'status':'committed','commit':commit,'previous_head':head,'branch':branch,'scope':sorted(actual),'checks':234}
(out/'publication_receipt.json').write_text(json.dumps(receipt,indent=2))
git('push','origin','HEAD:refs/heads/'+branch)
assert git('ls-remote','origin','refs/heads/'+branch).split()[0]==commit
receipt['status']='pushed_verified'
(out/'publication_receipt.json').write_text(json.dumps(receipt,indent=2))
print(json.dumps(receipt,indent=2))
