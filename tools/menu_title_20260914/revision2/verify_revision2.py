"""Frame, source-action and uninterrupted-audio checks for the revised review."""
from pathlib import Path
import subprocess,json,hashlib
import numpy as np
from PIL import Image,ImageDraw
import compose_revision2 as c
r=c.ROOT;v=r/'Dead_Street_Opening_Preview.mp4'
meta=c.frames(v,1710);assert abs(float(meta['format']['duration'])-57)<.02
video=next(s for s in meta['streams'] if s['codec_type']=='video')
assert (video['width'],video['height'],video['r_frame_rate'])==(1280,720,'30/1')

nums=[345,360,389,390,420,480,540,600,629,630,631,648,660,680,720,809,810,850,915,1050,1230,1380,1455,1560]
vf='select='+ '+'.join(f'eq(n\\,{n})' for n in nums)
data=subprocess.check_output(['ffmpeg','-v','error','-xerror','-i',str(v),'-an','-vf',vf,'-fps_mode','passthrough','-pix_fmt','rgb24','-f','rawvideo','-'])
arr=np.frombuffer(data,np.uint8).reshape(len(nums),720,1280,3);samples=dict(zip(nums,arr))
for n in [345,360,389]:assert samples[n].max()<=2,('black hold failed',n,samples[n].max())
title=np.array(Image.open(c.ASSETS/'approved_title.png').convert('L').resize((1056,384),Image.Resampling.NEAREST))
mask=title>60
completed=samples[630][79:463,112:1168].mean(2)
title_corr=float(np.corrcoef(completed.ravel(),title.ravel())[0,1]);assert title_corr>.997,title_corr
title_error=float(abs(completed-title).mean())
before=samples[629][79:463,112:1168].mean(2)
before_error=float(abs(before-title).mean())
# Compression error over the entire title can exceed the tiny finishing change.
# Check only the original pixels that actually finish between frames 629 and 630.
pair_data=subprocess.check_output(['ffmpeg','-v','error','-i',str(r/'title_motion.mkv'),'-vf','select=between(n\\,239\\,240)','-fps_mode','passthrough','-pix_fmt','gray','-f','rawvideo','-'])
pair=np.frombuffer(pair_data,np.uint8).reshape(2,720,1280).astype('int16')
finishing=(pair[1]-pair[0])>2
finishing_gain=float((samples[630].mean(2)-samples[629].mean(2))[finishing].mean())
assert finishing.sum()>100 and finishing_gain>.5,('final pieces did not complete at 21',finishing.sum(),finishing_gain)
# No background before 21; begins its fade from black at 21, visible by 21.6.
for n in [390,420,480,540,600,629,630]:assert samples[n][475:560,120:1150].max()<=3,('early background',n)
assert samples[648][475:560,120:1150].mean()>8
roi=(slice(575,577),slice(490,790));button_delta=float(samples[810][roi].mean()-samples[809][roi].mean())
button=np.array(Image.open(c.ASSETS/'button_ui.png').convert('RGBA'))
button_ink=(button[:,:,3]>250)&(button[:,:,:3].mean(2)>210)
button_ink_before=float(samples[809][button_ink].mean());button_ink_after=float(samples[810][button_ink].mean())
assert button_ink_before<185 and button_ink_after>210 and button_ink_after-button_ink_before>60,('button cue',button_ink_before,button_ink_after)
# Recover tiny actual image translations from bright title pixels while footage moves.
hover=[]
for n in [630,648,660,680,720]:
 actual=samples[n].mean(2);scores=[]
 for off in range(-4,5):
  patch=actual[79+off:463+off,112:1168]
  scores.append(float(np.mean(abs(patch[title>210]-title[title>210]))))
 hover.append({'frame':n,'offset':int(np.argmin(scores))-4})
assert len(set(x['offset'] for x in hover))>=3,('hover not moving',hover)
assert max(abs(x['offset']) for x in hover)<=3,hover
# All actual montage scenes must survive export in order, including the first firefight.
checks=[];offset=0
def sample(path,t,graded=False):
 grade="hue=s=0,eq=contrast=1.12:brightness=-0.008:gamma=0.99,colorchannelmixer=rr=0.64:gg=0.64:bb=0.64,vignette=angle=PI/5," if graded else ""
 b=subprocess.check_output(['ffmpeg','-v','error','-ss',str(t),'-i',str(path),'-frames:v','1','-vf',grade+'scale=640:360','-pix_fmt','rgb24','-f','rawvideo','-'])
 return np.frombuffer(b,np.uint8).reshape(360,640,3)
for i,s in enumerate(c.SHOTS):
 t=offset+s[2]/60;offset+=s[2]/30
 a=sample(v,21+t);b=sample(r/'action_montage.mkv',t,graded=True)
 aa=a[235:275,70:600].mean(2).ravel();bb=b[235:275,70:600].mean(2).ravel()
 corr=float(np.corrcoef(aa,bb)[0,1]);assert corr>.80,(i,corr)
 assert np.ptp(a.astype('int16'),axis=2).max()<=3
 checks.append({'shot':i,'time':21+t,'label':s[4],'correlation':corr})
# Measure opening shot's movement and brief bright changes in the actual crop.
raw=subprocess.check_output(['ffmpeg','-v','error','-i',str(r/'action_00.mkv'),'-vf','scale=640:360','-pix_fmt','rgb24','-f','rawvideo','-'])
shot=np.frombuffer(raw,np.uint8).reshape(-1,360,640,3).astype('int16');delta=shot[1:]-shot[:-1]
flash=((delta[:,:,:,0]>60)&(delta[:,:,:,1]>45)).sum((1,2))
assert int(flash.max())>20,('first scene lacks visible fire/action changes',flash.max())
def audio(path):
 return np.frombuffer(subprocess.check_output(['ffmpeg','-v','error','-xerror','-i',str(path),'-vn','-ac','1','-ar','16000','-f','f32le','-']),dtype='<f4')
audio_out=audio(v);original=audio(c.ASSETS/'B-22_Dead_Street.mp3');audio_checks=[]
assert np.isfinite(audio_out).all() and float(abs(audio_out).max())<1
for a,b in [(10,15),(19,23),(43,49),(50,54)]:
 corr=float(np.corrcoef(original[a*16000:b*16000],audio_out[a*16000:b*16000])[0,1]);assert corr>.99,(a,b,corr)
 audio_checks.append({'from':a,'to':b,'correlation':corr})
selected=[420,480,540,630,648,720,810,850,915,1380,1455,1560];sheet=Image.new('RGB',(1440,1080))
for i,n in enumerate(selected):
 im=Image.fromarray(samples[n]).resize((480,270));ImageDraw.Draw(im).text((8,8),f'{n/30:.2f}s',fill='white',stroke_width=2,stroke_fill='black');sheet.paste(im,((i%3)*480,(i//3)*270))
sheet.save(r/'qa/final_contact.jpg')
for n in [629,630,648,809,810,1380,1455,1560]:Image.fromarray(samples[n]).save(r/'qa'/f'final_{n:04d}.png')
report={'status':'PASS','frames':1710,'duration':57,'width':1280,'height':720,'fps':30,'full_video_audio_decode':'PASS',
 'black_hold_checked_frames':[345,360,389],'title_complete_frame':630,'title_correlation':title_corr,
 'finishing_pixel_count':int(finishing.sum()),'finishing_pixel_brightness_gain_at_21':finishing_gain,'title_before_completion_error':before_error,'title_completed_error':title_error,'background_starts_at':21,'button_first_frame':810,'button_border_delta':button_delta,'button_ink_before':button_ink_before,'button_ink_after':button_ink_after,
 'hover_offsets':hover,'scene_checks':checks,'first_scene':'Bridge crossfire; source 34.5s','first_scene_max_bright_change_pixels':int(flash.max()),
 'audio_continuity':audio_checks,'audio_peak_mono':float(abs(audio_out).max()),'music_scale':.88,
 'source_title_sha256':hashlib.sha256((c.ASSETS/'approved_title.png').read_bytes()).hexdigest(),
 'sha256':hashlib.sha256(v.read_bytes()).hexdigest(),'bytes':v.stat().st_size,'scope':'57-second edited design preview; no native controller integration'}
(r/'verification.json').write_text(json.dumps(report,indent=2));print(json.dumps(report),flush=True)
