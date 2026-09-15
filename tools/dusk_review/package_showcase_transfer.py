from pathlib import Path
import base64,hashlib,json,shutil
r=Path(__file__).resolve().parents[1]/'battle_showcase'
p=r/'results/Dead_Street_Harold_4v4.mp4';b=p.read_bytes();t=r/'transfer';t.mkdir(exist_ok=True)
parts=[]
for i,start in enumerate(range(0,len(b),65536)):
 data=b[start:start+65536];name=f'part_{i:03}.txt';(t/name).write_text(base64.b64encode(data).decode())
 parts.append(dict(name=name,bytes=len(data),sha256=hashlib.sha256(data).hexdigest()))
info=dict(filename=p.name,bytes=len(b),sha256=hashlib.sha256(b).hexdigest(),parts=parts)
(t/'manifest.json').write_text(json.dumps(info));print(json.dumps({k:v for k,v in info.items() if k!='parts'}));print('parts',len(parts))
desktop=Path.home()/'Desktop';shutil.copy2(p,desktop/p.name)
print('DESKTOP_COPY',str(desktop/p.name))
