"""Transfer a revised recording using verified copies from the previous local cut."""
from pathlib import Path
import hashlib,json,base64,zlib,time

def digest(b):return hashlib.sha256(b).hexdigest()
def make(old,new):
 operations=[];target=0;offset=0;size=4096;literal_bytes=0;copied=0
 while offset+32<=len(old) and target<len(new):
  found=new.find(old[offset:offset+32],target,min(len(new),target+262144))
  if found<0:offset+=size;continue
  n=32;limit=min(len(old)-offset,len(new)-found)
  while n+size<=limit and old[offset+n:offset+n+size]==new[found+n:found+n+size]:n+=size
  while n<limit and old[offset+n]==new[found+n]:n+=1
  if found>target:
   chunk=new[target:found];operations.append({'data':base64.b64encode(chunk).decode()});literal_bytes+=len(chunk)
  operations.append({'copy':[offset,n]});copied+=n;target=found+n;offset=((offset+n+size-1)//size)*size
 if target<len(new):
  chunk=new[target:];operations.append({'data':base64.b64encode(chunk).decode()});literal_bytes+=len(chunk)
 result={'base_sha256':digest(old),'sha256':digest(new),'bytes':len(new),'operations':operations}
 rebuilt=b''.join(old[x['copy'][0]:sum(x['copy'])]if 'copy'in x else base64.b64decode(x['data'])for x in operations)
 assert rebuilt==new
 return result,{'copied_bytes':copied,'literal_bytes':literal_bytes,'operations':len(operations)}
if __name__=='__main__':
 import argparse
 ap=argparse.ArgumentParser();ap.add_argument('old');ap.add_argument('new');ap.add_argument('out');a=ap.parse_args();start=time.monotonic()
 patch,stats=make(Path(a.old).read_bytes(),Path(a.new).read_bytes());out=Path(a.out);out.mkdir(exist_ok=True)
 payload=base64.b64encode(zlib.compress(json.dumps(patch,separators=(',',':')).encode(),9)).decode()
 # Bound each tool response; four concurrent reads stay below the remote service limit.
 chunks=[payload[i:i+650000]for i in range(0,len(payload),650000)]
 for i,part in enumerate(chunks):(out/f'delta_{i:03}.txt').write_text(part,encoding='utf-8')
 manifest={k:v for k,v in patch.items()if k!='operations'};manifest.update(stats);manifest.update({'parts':len(chunks),'transfer_characters':len(payload),'build_seconds':time.monotonic()-start})
 (out/'manifest.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8');print('DELTA_READY',json.dumps(manifest),flush=True)
