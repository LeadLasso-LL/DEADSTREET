from pathlib import Path
import base64, hashlib, json, re, subprocess
import imageio_ffmpeg
out=Path(__file__).resolve().parent
report=json.loads((out/'record.json').read_text())
assert report['checks']>=70 and not report['errors'] and report['no_battle_created']
ffmpeg=imageio_ffmpeg.get_ffmpeg_exe()
target=out/'Dead_Street_Tutorial_Preview.mp4'
args=[ffmpeg,'-hide_banner','-y','-i',str(out/'tutorial_raw.avi'),'-t',str(report['preview_end_seconds']),'-an','-c:v','libx264','-preset','medium','-tune','animation','-crf','19','-pix_fmt','yuv420p','-r','30','-movflags','+faststart',str(target)]
result=subprocess.run(args,capture_output=True,timeout=240)
(out/'encode.log').write_bytes(result.stderr)
assert result.returncode==0,result.stderr[-4000:]
decode=subprocess.run([ffmpeg,'-v','error','-i',str(target),'-f','null','-','-progress','pipe:1'],capture_output=True,timeout=120)
assert decode.returncode==0 and not decode.stderr,decode.stderr[-4000:]
frames=int(re.findall(rb'frame=(\d+)',decode.stdout)[-1])
data=target.read_bytes();chunks=[]
transfer=out/'transfer';transfer.mkdir(exist_ok=True)
for i,offset in enumerate(range(0,len(data),512*1024)):
    part=data[offset:offset+512*1024];name=f'{i:03}.b64'
    (transfer/name).write_text(base64.b64encode(part).decode(),encoding='ascii')
    chunks.append(dict(name=name,bytes=len(part),sha256=hashlib.sha256(part).hexdigest()))
delivery=dict(filename=target.name,bytes=len(data),sha256=hashlib.sha256(data).hexdigest(),width=1440,height=1000,fps=30,frames=frames,duration_seconds=frames/30,codec='H.264',pixel_format='yuv420p',faststart=True,full_decode_passed=True,checks=report['checks'],errors=report['errors'],chunks=chunks)
(out/'delivery.json').write_text(json.dumps(delivery,indent=2))
print(json.dumps(delivery),flush=True)
