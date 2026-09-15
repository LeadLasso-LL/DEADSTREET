import json, subprocess, hashlib
from pathlib import Path
import imageio_ffmpeg
root=Path(__file__).resolve().parent
manifest=json.loads((root/'manifest.json').read_text(encoding='utf-8-sig'))
audio=root/manifest['file']
cmd=[imageio_ffmpeg.get_ffmpeg_exe(),'-hide_banner','-nostdin','-xerror','-err_detect','explode','-i',str(audio),'-map','0:a:0','-f','s16le','-ac','2','-ar','44100','pipe:1']
r=subprocess.run(cmd,capture_output=True,timeout=60)
(root/'decode.log').write_bytes(r.stderr)
decoded_seconds=len(r.stdout)/(44100*2*2)
source_seconds=manifest['duration_ms']/1000
checks={'full_decode':r.returncode==0,'duration_matches':abs(decoded_seconds-source_seconds)<0.15,'bytes_match':audio.stat().st_size==manifest['bytes'],'sha256_matches':hashlib.sha256(audio.read_bytes()).hexdigest()==manifest['sha256']}
report={'checks':checks,'all_pass':all(checks.values()),'decoded_seconds':decoded_seconds,'source_seconds':source_seconds,'pcm_bytes':len(r.stdout),'sample_rate':44100,'channels':2,'decode_exit_code':r.returncode,'settings_changed':False,'playlist_installed':False,'independent_listening_verdict':False}
(root/'validation.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
manifest['verified_decode']=report['all_pass']
manifest['decoded_seconds']=decoded_seconds
(root/'manifest.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
print(json.dumps(report))
if not report['all_pass']: raise SystemExit(1)
