from pathlib import Path
import subprocess,sys,json
from PIL import Image,ImageDraw,ImageFont
import numpy as np
R=Path(__file__).resolve().parents[2];O=Path(__file__).parent
sys.path.insert(0,str(R/'tools/faction_roster'))
from build_roster import finish_exact
profiles=['mercer','orlov','calle_ocho','trc','whittaker','ventresca']
(O/'renders').mkdir(exist_ok=True)
for profile in profiles:
 subprocess.run([sys.executable,str(O/'worker.py'),profile,'--sample'],cwd=R,check=True)
 job=O/'jobs'/(profile+'.json')
 p=subprocess.run([r'C:\Users\brand\OneDrive\Documents\Godot\Godot_v4.7.2-stable_win64_console.exe','--headless','--path',str(R),'--script',str(O/'render.gd'),'--',str(job),str(O/'renders')],capture_output=True,text=True)
 assert p.returncode==0,p.stdout+p.stderr
 data=json.loads(job.read_text())
 for name,svg in data['jobs']:finish_exact(O/'renders'/(name+'.png'),np.array(data['palette'],dtype=np.int32))
im=Image.new('RGB',(1280,1680),'#263033');draw=ImageDraw.Draw(im);font=ImageFont.truetype('C:/Windows/Fonts/arial.ttf',18)
for i,profile in enumerate(profiles):
 data=json.loads((O/'jobs'/(profile+'.json')).read_text());v=data['rows'][0]['variant'];y=i*280
 draw.text((10,y+6),profile+'       SW before / after                           SE before / after',font=font,fill='#e9e3d6')
 for col,(direction,state) in enumerate([('SW','before'),('SW','after'),('SE','before'),('SE','after')]):
  actor=Image.open(O/'renders'/(v+'_'+direction+'_'+state+'.png')).convert('RGBA').crop((18,6,108,86)).resize((270,240),Image.Resampling.NEAREST)
  im.paste(actor,(col*320,y+30),actor)
im.save(O/'candidate_sample.png')
print('CANDIDATE_REVIEW_READY',flush=True)
