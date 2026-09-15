"""Rebuild approved opening media on the PC from existing source art/recordings."""
from pathlib import Path
import importlib.util, subprocess, json, shutil, re, hashlib
repo=Path(r'C:\Users\brand\OneDrive\Documents\dead-street')
out=repo/'tools/menu_title_20260914/native'
assets=repo/'assets/menu/opening'
assets.mkdir(parents=True,exist_ok=True)
ff=str(Path(r'C:\Users\brand\AppData\Local\DeadStreetTools\python\Lib\site-packages\imageio_ffmpeg\binaries\ffmpeg-win-x86_64-v7.1.exe'))
original_run=subprocess.run;original_popen=subprocess.Popen
def mapped(args,*a,**kw):
    args=list(args)
    if args and args[0]=='ffmpeg':args[0]=ff
    return original_popen(args,*a,**kw)
subprocess.Popen=mapped
spec=importlib.util.spec_from_file_location('approved',repo/'tools/menu_title_20260914/revision3/compose_revision3.py')
c=importlib.util.module_from_spec(spec);spec.loader.exec_module(c)
c.ROOT=out/'media_work';c.ROOT.mkdir(exist_ok=True);(c.ROOT/'qa').mkdir(exist_ok=True)
c.ASSETS=repo/'tools/menu_title_20260914'
def count(path,expected):
    result=original_run([ff,'-v','error','-xerror','-i',str(path),'-map','0:v:0','-an','-vf','fps=30','-progress','pipe:1','-f','null','-'],capture_output=True,text=True)
    values=re.findall(r'^frame=(\d+)',result.stdout,re.M)
    assert result.returncode==0 and values and int(values[-1])==expected,(path,expected,values[-1:] if values else [],result.stderr[-2000:])
    return {'frames':int(values[-1])}
c.frames=count
original_render=c.run
def render(args,name,expected=None):
    if name=='action_montage.mkv':
        graph_path=c.ROOT/'action.ffgraph'
        graph=graph_path.read_text()
        for i in range(1,len(c.SHOTS)):
            graph=graph.replace(f'[x{i}];',f'[raw{i}];[raw{i}]fps=30,settb=AVTB[x{i}];')
        graph=graph.replace('fps=30,settb=AVTB,setpts=PTS-STARTPTS,format=yuv420p','setpts=PTS-STARTPTS,format=yuv420p,fps=30').replace('fps=30,settb=AVTB','fps=30')
        graph=graph.replace('setpts=N/(30*TB)[out]','tpad=stop_mode=clone:stop_duration=0.1333333333,setpts=N/(30*TB)[out]')
        graph_path.write_text(graph)
    return original_render(args,name,expected)
c.run=render
c.make_warning()
if not (c.ROOT/'title_motion.mkv').exists():c.make_title_motion()
if not (c.ROOT/'action_montage.mkv').exists():c.make_action([i for i in range(len(c.SHOTS)) if not (c.ROOT/f'action_{i:02d}.mkv').exists()])
parts=[(c.ASSETS/'startup_gloria.mkv' if (c.ASSETS/'startup_gloria.mkv').exists() else c.ROOT/'startup_gloria.mkv'),(c.ASSETS/'startup_godot.mkv' if (c.ASSETS/'startup_godot.mkv').exists() else c.ROOT/'startup_godot.mkv'),c.ROOT/'warning_slow.mkv',c.ROOT/'black_hold.mkv',c.ROOT/'title_motion.mkv']
(out/'startup_parts.txt').write_text(''.join("file '"+p.as_posix()+"'\n" for p in parts))
startup_args=[]
for path in parts:startup_args+=['-i',str(path)]
graph=';'.join(f'[{i}:v]fps=30,setpts=PTS-STARTPTS,format=yuv420p[v{i}]' for i in range(5))+';[v0][v1][v2][v3][v4]concat=n=5:v=1:a=0[v]'
jobs=[('startup.ogv',startup_args+['-filter_complex',graph,'-map','[v]','-frames:v','630']),('montage.ogv',['-i',str(c.ROOT/'action_montage.mkv'),'-vf','hue=s=0,eq=contrast=1.12:brightness=-0.008:gamma=0.99,colorchannelmixer=rr=0.64:gg=0.64:bb=0.64,vignette=angle=PI/5','-frames:v','720'])]
for name,args in jobs:
    if (assets/name).exists():
        count(assets/name,630 if name=='startup.ogv' else 720)
        print('NATIVE_MEDIA_REUSED',name,flush=True)
        continue
    result=original_run([ff,'-v','error','-xerror']+args+['-an','-c:v','libtheora','-q:v','8','-pix_fmt','yuv420p','-r','30','-threads','2','-y',str(assets/name)],capture_output=True)
    assert result.returncode==0,result.stderr
    count(assets/name,630 if name=='startup.ogv' else 720)
    print('NATIVE_MEDIA_READY',name,(assets/name).stat().st_size,flush=True)
for name in ['approved_title.png','camera_ui.png','B-22_Dead_Street.mp3']:
    shutil.copy2(c.ASSETS/name,assets/name)
report={p.name:{'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'bytes':p.stat().st_size} for p in assets.iterdir() if p.is_file() and not p.name.endswith('.import')}
(out/'media_receipt.json').write_text(json.dumps(report,indent=2))
print('NATIVE_MEDIA_COMPLETE',flush=True)
