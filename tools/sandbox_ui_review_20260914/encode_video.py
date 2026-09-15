from pathlib import Path
import base64, hashlib, json, re, subprocess, time
import imageio_ffmpeg

out=Path(__file__).resolve().parent
ffmpeg=imageio_ffmpeg.get_ffmpeg_exe()
for _ in range(120):
    if (out/'record.json').exists() and 'UI_CAPTURE_COMPLETE' in (out/'record_worker.log').read_text(errors='replace'):break
    time.sleep(1)
else:raise RuntimeError('Native recording did not complete')
report=json.loads((out/'record.json').read_text())
assert report['checks']>200 and not report['errors'] and report['no_combat']
duration=report['frames']/30
source=out/'sandbox_ui_raw.avi'
target=out/'Dead_Street_Bridge_5v5_Sandbox_UI_Review.mp4'
common=[ffmpeg,'-hide_banner','-y','-i',str(source)]
video=['-map','0:v:0','-map','0:a?','-c:v','libx264','-preset','medium','-tune','animation','-pix_fmt','yuv420p','-r','30','-c:a','aac','-b:a','32k','-ac','2','-movflags','+faststart','-metadata','title=Dead Street - Bridge 5v5 Sandbox UI Review']
result=subprocess.run(common+video+['-crf','20',str(target)],capture_output=True,timeout=360)
(out/'encode.log').write_bytes(result.stderr)
assert result.returncode==0,result.stderr[-5000:]
if target.stat().st_size>7_850_000:
    bitrate=int((7_650_000*8/duration-32_000)*0.97)
    for passnum in (1,2):
        args=common+['-c:v','libx264','-preset','medium','-tune','animation','-pix_fmt','yuv420p','-r','30','-b:v',str(bitrate),'-pass',str(passnum),'-passlogfile',str(out/'ui_encode_pass')]
        args+=['-an','-f','null','NUL'] if passnum==1 else ['-c:a','aac','-b:a','32k','-ac','2','-movflags','+faststart',str(target)]
        result=subprocess.run(args,capture_output=True,timeout=360)
        assert result.returncode==0,result.stderr[-5000:]
assert target.stat().st_size<8_000_000
decode=subprocess.run([ffmpeg,'-hide_banner','-v','error','-i',str(target),'-map','0:v:0','-f','null','-','-progress','pipe:1'],capture_output=True,timeout=180)
assert decode.returncode==0 and not decode.stderr,decode.stderr[-5000:]
decoded_frames=int(re.findall(rb'frame=(\d+)',decode.stdout)[-1])
assert abs(decoded_frames-report['frames'])<=5,(decoded_frames,report['frames'])
inspection=[('video_opening',3.0),('video_map_menu',next(e['seconds'] for e in report['events'] if 'choose the map' in e['chapter'])+3.1),('video_weapon_menu',next(e['seconds'] for e in report['events'] if e['chapter']=='Attacker / Pistol')+1.1),('video_defender_loadout',next(e['seconds'] for e in report['events'] if e['chapter']=='Defender / Rifle')+5.0),('video_convoy',next(e['seconds'] for e in report['events'] if 'Seat validation' in e['chapter'])+1.0),('video_final',duration-2.0)]
for name,seconds in inspection:
    subprocess.run([ffmpeg,'-v','error','-y','-ss',str(seconds),'-i',str(target),'-frames:v','1',str(out/(name+'.png'))],check=True,timeout=30)
data=target.read_bytes()
transfer=out/'transfer';transfer.mkdir(exist_ok=True)
chunk_size=512*1024
chunks=[]
for i,offset in enumerate(range(0,len(data),chunk_size)):
    part=data[offset:offset+chunk_size]
    name=f'{i:03}.b64'
    (transfer/name).write_text(base64.b64encode(part).decode(),encoding='ascii')
    chunks.append({'name':name,'bytes':len(part),'sha256':hashlib.sha256(part).hexdigest()})
delivery={'filename':target.name,'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest(),'fps':30,'width':1152,'height':860,'frames':decoded_frames,'duration_seconds':decoded_frames/30,'video_codec':'H.264','pixel_format':'yuv420p','audio_codec':'AAC','faststart':True,'full_decode_passed':True,'ui_checks':report['checks'],'ui_errors':report['errors'],'no_combat':True,'chunks':chunks}
(out/'delivery.json').write_text(json.dumps(delivery,indent=2))
print(json.dumps(delivery),flush=True)
