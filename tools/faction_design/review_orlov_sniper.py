"""Build a complete single-class Orlov sniper review with existing validators."""
from pathlib import Path
import sys,json,subprocess,time
sys.path.insert(0,str(Path(__file__).parent))
import review_eastex as review
import orlov_sniper_outfits as style
from PIL import Image,ImageDraw
import numpy as np
def main():
 import argparse
 p=argparse.ArgumentParser();p.add_argument('--godot',required=True);args=p.parse_args()
 started=time.perf_counter()
 out=Path(__file__).parent/'orlov_sniper';frames=out/'frames';frames.mkdir(parents=True,exist_ok=True);(frames/'.gdignore').touch()
 review.style=style;review.OUT=out;review.FRAMES=frames;review.KIND=1
 review.TITLE=style.TITLE;review.PREFIX='orlov_sniper';review.ROLES=['sniper']
 review.generate(True,['sniper'])
 subprocess.run([args.godot,'--headless','--path',str(review.ROOT),'--script','res://tools/faction_design/render_eastex.gd','--','res://tools/faction_design/orlov_sniper/'],check=True,cwd=review.ROOT)
 colors=[v for c in style.SPECS.values() for v in c.values() if isinstance(v,str) and v.startswith('#')]+style.EXTRA_PALETTE
 review.showcase_finish.PAL=np.vstack([review.showcase_finish.PAL,np.array([tuple(bytes.fromhex(v.lstrip('#'))) for v in colors])])
 jobs=json.loads((out/'jobs.json').read_text())
 for key in jobs:review.showcase_finish.finish(frames/(key+'.png'))
 im=Image.new('RGB',(800,480),'#151c20')
 review.header(im,style.TITLE,'Ushanka / black zip jacket / dark green pants and gloves')
 d=ImageDraw.Draw(im)
 for col,clip in enumerate(['idle','aim']):
  x=20+390*col;d.rounded_rectangle((x,110,x+370,455),4,fill='#2a3335',outline='#465054')
  d.text((x+14,124),'STANDING' if clip=='idle' else 'AIMING',font=review.font(14,True),fill='#acb9bd')
  actor=review.sprite('sniper','SE',clip).crop((8,20,120,124)).resize((280,260),Image.Resampling.NEAREST)
  im.paste(actor,(x+45,175),actor)
 im.save(out/'orlov_sniper_outfit_review.png')
 for clip in ['idle','aim']:
  im=Image.new('RGB',(1664,328),'#151c20');review.header(im,style.TITLE+' / '+clip.upper(),'Eight facings / same fixed scale')
  d=ImageDraw.Draw(im)
  for i,direction in enumerate(review.DIRECTIONS):
   x=i*208;d.rectangle((x+8,110,x+201,318),fill='#2a3335')
   actor=review.sprite('sniper',direction,clip).crop((8,20,120,124)).resize((168,156),Image.Resampling.NEAREST)
   im.paste(actor,(x+20,150),actor);d.text((x+16,120),direction,font=review.font(12),fill='#acb9bd')
  im.save(out/('orlov_sniper_'+clip+'_directions.png'))
 review.audit()
 for f,height in [('orlov_sniper_motion_samples.png',328),('orlov_sniper_armory_fit.png',370)]:
  p=out/f;im=Image.open(p).convert('RGB').crop((0,0,1456 if 'motion' in f else 1536,height))
  # Correct the generic five-class armory heading for this six-rifle review.
  if 'armory' in f:
   ImageDraw.Draw(im).rectangle((0,0,im.width,96),fill='#151c20')
   review.header(im,style.TITLE+' / RIFLE FIT','All six sniper rifles / fixed aiming scale')
  im.save(p)
 seq=[];dur=[]
 for clip,count in [('walk',24),('fire',3),('reload',40),('cover_popout',8),('cover_tuck',9),('wounded_walk',24)]:
  for i in range(count):
   im=Image.new('RGB',(640,410),'#151c20');review.header(im,style.TITLE,clip.replace('_',' ').upper())
   review.paste(im,review.sprite('sniper','SE',clip,i),190,125,2);seq.append(im);dur.append(100 if clip=='fire' else 55)
  dur[-1]+=250
 seq[0].save(out/'orlov_sniper_motion_review.gif',save_all=True,append_images=seq[1:],duration=dur,loop=0,disposal=2)
 geo=json.loads((out/'geometry_validation.json').read_text());render=json.loads((out/'render_validation.json').read_text())
 assert geo['frames']==render['frames']==216 and geo['body_matches_accepted_geometry'] and not render['failures']
 report={'roles':['sniper'],'full_class_review':True,'frames':216,'failures':[],'motion_frames':len(seq),'total_seconds':round(time.perf_counter()-started,3),'runtime_binding':False}
 (out/'pipeline_report.json').write_text(json.dumps(report,indent=2)+'\n')
 print('ORLOV_SNIPER_REVIEW_COMPLETE',json.dumps(report),flush=True)
if __name__=='__main__':main()
