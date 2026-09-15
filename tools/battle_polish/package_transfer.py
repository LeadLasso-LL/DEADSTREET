from pathlib import Path
import base64,hashlib,json
r=Path(__file__).parent/'results';out=Path(__file__).parent/'transfer';out.mkdir(exist_ok=True)
p=r/'Dead_Street_Harold_Battle_Polish.mp4';data=p.read_bytes();parts=[]
for i,start in enumerate(range(0,len(data),524288)):
 b=data[start:start+524288];name=f'part_{i:03}.txt';(out/name).write_text(base64.b64encode(b).decode());parts.append({'name':name,'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest()})
(out/'manifest.json').write_text(json.dumps({'filename':p.name,'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest(),'parts':parts}))
print('Packaged',len(data),'bytes',len(parts),'parts')
