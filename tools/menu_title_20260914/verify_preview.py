from pathlib import Path
import subprocess,json,hashlib
import numpy as np
from PIL import Image,ImageDraw
import compose_opening as c
r=Path(__file__).resolve().parent;v=r/'Dead_Street_Opening_Preview.mp4'
def frame(p,t):
 data=subprocess.check_output(['ffmpeg','-v','error','-ss',str(t),'-i',str(p),'-frames:v','1','-vf','scale=640:360','-pix_fmt','rgb24','-f','rawvideo','-'])
 return np.frombuffer(data,np.uint8).reshape(360,640,3)
meta=json.loads(subprocess.check_output(['ffprobe','-v','error','-count_frames','-show_streams','-show_format','-of','json',str(v)]))
video=next(s for s in meta['streams'] if s['codec_type']=='video')
assert int(video['nb_read_frames'])==1440 and abs(float(meta['format']['duration'])-48)<.04
subprocess.run(['ffmpeg','-v','error','-xerror','-i',str(v),'-f','null','-'],check=True)
offset=0;comparisons=[];ims=[]
for i,s in enumerate(c.SHOTS):
 t=offset+s[2]/c.FPS/2;offset+=s[2]/c.FPS
 if t>=23.7:break
 a=frame(v,t+12);b=frame(r/'montage_final.mkv',t)
 # Below the title, above the button: detect missing/frozen/wrong scene.
 aa=a[215:277,60:600].mean(axis=2).flatten();bb=b[215:277,60:600].mean(axis=2).flatten()
 correlation=float(np.corrcoef(aa,bb)[0,1]);color_error=int(np.ptp(a.astype('int16'),axis=2).max())
 assert correlation>.82,(i,'wrong or frozen montage',correlation)
 assert color_error<=3,(i,'not monochrome',color_error)
 comparisons.append({'shot':i,'time':t+12,'sector':s[5],'background_correlation':correlation,'max_rgb_difference':color_error})
 im=Image.fromarray(a);ImageDraw.Draw(im).text((8,8),f'{t+12:.1f}s / {s[5]}',fill='white',stroke_width=2,stroke_fill='black');ims.append(im)
sheet=Image.new('RGB',(1920,1440))
for i,im in enumerate(ims):sheet.paste(im,((i%3)*640,(i//3)*360))
sheet.save(r/'qa'/'final_contact.jpg')
for t in [1,5,9,11.3,11.5,11.8,12,17,25,37,40,44]:
 subprocess.run(['ffmpeg','-v','error','-ss',str(t),'-i',str(v),'-frames:v','1','-y',str(r/'qa'/f'final_{t}.png')],check=True)
audio=np.frombuffer(subprocess.check_output(['ffmpeg','-v','error','-i',str(v),'-vn','-f','f32le','-']),dtype='<f4')
assert np.isfinite(audio).all() and .01<float(abs(audio).max())<1
report={'duration_seconds':float(meta['format']['duration']),'frames':int(video['nb_read_frames']),'width':video['width'],'height':video['height'],'fps':video['r_frame_rate'],'video_codec':video['codec_name'],'pixel_format':video['pix_fmt'],'audio_title':'Dead Street','audio_artist':'B-22','audio_peak':float(abs(audio).max()),'full_decode':'PASS','all_four_shots_used_before_sandbox_entry_present':'PASS','monochrome':'PASS','scene_checks':comparisons,'bytes':v.stat().st_size,'sha256':hashlib.sha256(v.read_bytes()).hexdigest(),'title_original_sha256':hashlib.sha256(c.TITLE.read_bytes()).hexdigest(),'scope':'48-second edited opening and Music handoff preview; designed overlay on real sandbox UI still, no live sandbox integration'}
# Compare decoded audio to the original at both key handoffs: no restart/offset.
def mono(p):
 return np.frombuffer(subprocess.check_output(['ffmpeg','-v','error','-i',str(p),'-vn','-ac','1','-ar','16000','-f','f32le','-']),dtype='<f4')
original=mono(r/'B-22_Dead_Street.mp3'); final_audio=mono(v); audio_checks=[]
for st,en in [(10,14),(34,39),(40,45)]:
 a=original[st*16000:en*16000];b=final_audio[st*16000:en*16000]
 corr=float(np.corrcoef(a,b)[0,1]);assert corr>.99,(st,en,corr)
 audio_checks.append({'start':st,'end':en,'source_audio_correlation':corr})
# Exact frame boundaries rather than rounded seek times.
def exact(n):
 data=subprocess.check_output(['ffmpeg','-v','error','-i',str(v),'-vf',f'select=eq(n\\,{n})','-frames:v','1','-pix_fmt','rgb24','-f','rawvideo','-'])
 a=np.frombuffer(data,np.uint8).reshape(720,1280,3)
 Image.fromarray(a).save(r/'qa'/f'timeline_frame_{n:04d}.png');return a
black=exact(345);assert float(black.mean())<1.5,('not full black at 11.5',black.mean())
before=exact(509);after=exact(510)
# Thin top border and title lettering are entirely absent before the button cue.
roi=(slice(575,577),slice(490,790))
button_change=float(after[roi].mean()-before[roi].mean());assert button_change>30,button_change
settled=exact(360);assert settled[130:300,250:1030].mean()>12
report.update({'audio_continuity':'PASS','audio_continuity_checks':audio_checks,'black_frame_345_mean':float(black.mean()),'button_first_frame':510,'button_border_brightness_increase':button_change,'main_settled_frame':360,'timeline':__import__('startup_sequence').TIMELINE})
(r/'verification.json').write_text(json.dumps(report,indent=2));print(json.dumps(report),flush=True)
