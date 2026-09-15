from pathlib import Path
import base64,hashlib,json,shutil
r=Path(__file__).resolve().parents[2]
p=r/'tools/battle_showcase/results/Dead_Street_Harold_Audio_Cinematics.mp4'
data=p.read_bytes();dest=r/'tools/battle_showcase/transfer_audio';dest.mkdir(exist_ok=True)
parts=[]
for i,offset in enumerate(range(0,len(data),524288)):
 b=data[offset:offset+524288];name='part_%03d.txt'%i;(dest/name).write_text(base64.b64encode(b).decode(),encoding='ascii');parts.append({'name':name,'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest()})
manifest={'filename':p.name,'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest(),'parts':parts}
(dest/'manifest.json').write_text(json.dumps(manifest));print(json.dumps(manifest))
