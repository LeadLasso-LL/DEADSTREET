from pathlib import Path
import subprocess,json,hashlib,shutil,base64
import imageio_ffmpeg
r=Path(__file__).resolve().parents[2];o=Path(__file__).resolve().parent;a=r/'assets/menu/opening';ff=imageio_ffmpeg.get_ffmpeg_exe()
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
before=o/'before';before.mkdir(exist_ok=True)
for p in [a/'startup.ogv',r/'gameplay/sandbox_opening.gd']:
 target=before/p.name
 if not target.exists():shutil.copy2(p,target)
assert sha(r/'gameplay/sandbox_opening.gd')=='ad343c57220d54ff281e95c3ad976c853b12e3719c72dfe6421f96724f503289','Opening changed since takeover; inspect before install'
sign=base64.b64decode((o/'clean_sign.b64').read_text(),validate=True)
assert hashlib.sha256(sign).hexdigest()==json.loads((o/'payload.json').read_text())['sign_sha256']
(a/'caution_clean.png').write_bytes(sign)
parts=[('-loop','1','-framerate','30','-i',str(r/'tools/menu_title_20260914/credit_gloria.png')),('-loop','1','-framerate','30','-i',str(r/'tools/menu_title_20260914/credit_godot.png'))]
args=list(parts[0])+list(parts[1])+['-f','lavfi','-i','color=black:s=1280x720:r=30:d=7.5','-ss','13','-i',str(before/'startup.ogv')]
graph='[0:v]trim=duration=2.5,setpts=PTS-STARTPTS,fade=t=out:st=2:d=0.5,setsar=1,format=yuv420p[v0];[1:v]trim=duration=3,setpts=PTS-STARTPTS,fade=t=in:st=0:d=0.5,fade=t=out:st=2.5:d=0.5,setsar=1,format=yuv420p[v1];[2:v]setpts=PTS-STARTPTS,setsar=1,format=yuv420p[v2];[3:v]setpts=PTS-STARTPTS,fps=30,tpad=stop_mode=clone:stop_duration=0.1,trim=duration=8,setsar=1,format=yuv420p[v3];[v0][v1][v2][v3]concat=n=4:v=1:a=0[out]'
candidate=o/'startup_candidate.ogv'
with (o/'media.log').open('wb') as log:
 subprocess.run([ff,'-nostdin','-y','-v','warning','-filter_complex_threads','2']+args+['-filter_complex',graph,'-map','[out]','-frames:v','630','-an','-c:v','libtheora','-q:v','10','-r','30','-pix_fmt','yuv420p','-threads','2',str(candidate)],stdout=log,stderr=subprocess.STDOUT,check=True)
decode=subprocess.run([ff,'-v','error','-xerror','-i',str(candidate),'-vf','fps=30','-progress','pipe:1','-f','null','NUL'],capture_output=True,text=True,check=True)
assert 'frame=630' in decode.stdout,decode.stdout
source=(r/'gameplay/sandbox_opening.gd').read_text(encoding='utf-8')
edits=[('const Music = preload("res://gameplay/sandbox_menu_music.gd")','const Music = preload("res://gameplay/sandbox_menu_music.gd")\nconst Caution = preload("res://gameplay/sandbox_caution.gd")'),('var montage: VideoStreamPlayer','var montage: VideoStreamPlayer\nvar caution'),('startup = video("startup.ogv",false); startup.hide()','startup = video("startup.ogv",false); startup.hide()\n\tcaution=Caution.new(); stage.add_child(caution)'),('elapsed=maxf(elapsed,music.clock())','elapsed=maxf(elapsed,music.clock())\n\tcaution.advance(elapsed,music.volume_value)')]
for old,new in edits:
 assert source.count(old)==1,old
 source=source.replace(old,new)
shutil.copy2(candidate,a/'startup.ogv');(r/'gameplay/sandbox_opening.gd').write_text(source,encoding='utf-8',newline='\n')
report={'status':'INSTALLED','startup_frames':630,'sign_sha256':sha(a/'caution_clean.png'),'startup_sha256':sha(a/'startup.ogv'),'opening_sha256':sha(r/'gameplay/sandbox_opening.gd'),'hit_times':[7.2,7.533333,7.933333,8.233333,8.566667],'credits':[2.5,3.0],'caution':[5.5,11.5],'zoom':[9.25,11.5],'black_hold':[11.5,13.0],'title':21,'button':27}
(o/'installation.json').write_text(json.dumps(report,indent=2));print(json.dumps(report),flush=True)
