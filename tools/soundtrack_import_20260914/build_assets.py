from pathlib import Path
import hashlib, json, subprocess, wave
import numpy as np
import imageio_ffmpeg
ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'tools/soundtrack_import_20260914'
source = ROOT / 'tools/soundcloud_ob_test_20260914/OB_Bond.mp3'
if not source.exists(): source = ROOT / 'assets/audio/music/OB_Bond.mp3'
expected = 'b2e7a8f318a5c64083ad1ff3b9723b42f987638ba12c633b165e0b930f783634'
assert hashlib.sha256(source.read_bytes()).hexdigest() == expected
rate, start, duration, blend = 44100, 21.0, 30.0, 0.080
raw = subprocess.check_output([imageio_ffmpeg.get_ffmpeg_exe(), '-v', 'error', '-xerror', '-i', str(source), '-f', 'f32le', '-ar', str(rate), '-ac', '2', 'pipe:1'])
pcm = np.frombuffer(raw, dtype='<f4').reshape(-1, 2)
a, n, k = round(start*rate), round(duration*rate), round(blend*rate)
clip = pcm[a:a+n].copy()
assert len(clip) == n
# Match the tail into the waveform immediately before the exact requested start.
# A smooth 80ms blend retains the 30s period and never inserts silence or shifts the start.
w = (0.5-0.5*np.cos(np.linspace(0,np.pi,k)))[:,None]
original_tail = clip[-k:].copy()
clip[-k:] = original_tail*(1-w) + pcm[a-k:a]*w
source_peak=float(np.max(np.abs(clip)))
gain=min(1.0, (10**(-1/20))/max(source_peak,1e-9))
clip *= gain
asset_dir = ROOT / 'assets/audio/music'
asset_dir.mkdir(parents=True, exist_ok=True)
menu = asset_dir / 'OB_Bond.mp3'
assert not menu.exists() or menu.read_bytes() == source.read_bytes()
menu.write_bytes(source.read_bytes())
battle = asset_dir / 'OB_Bond_battle_21_51.wav'
encoded = np.rint(np.clip(clip,-1,1)*32767).astype('<i2')
with wave.open(str(battle),'wb') as f:
    f.setnchannels(2); f.setsampwidth(2); f.setframerate(rate); f.writeframes(encoded.tobytes())
original_seam = float(np.max(np.abs(pcm[a]-original_tail[-1])))
seam = float(np.max(np.abs(clip[0]-clip[-1])))
local_step = float(np.max(np.abs(pcm[a]-pcm[a-1])))*gain
report = {'source_sha256':expected,'menu_sha256':hashlib.sha256(menu.read_bytes()).hexdigest(),'source_start_seconds':start,'source_end_seconds':start+duration,'duration_seconds':duration,'frames':n,'sample_rate':rate,'channels':2,'seam_blend_seconds':blend,'seam_blend_preroll_seconds':[start-blend,start],'raw_boundary_step':original_seam,'processed_boundary_step':seam,'normal_source_step_at_start':local_step,'decoded_source_peak':source_peak,'battle_gain_db':float(20*np.log10(gain)),'pcm_peak':float(np.max(np.abs(clip))),'battle_sha256':hashlib.sha256(battle.read_bytes()).hexdigest(),'unchanged_before_final_blend':bool(np.allclose(clip[:-k],pcm[a:a+n-k]*gain,atol=1e-7)),'loop_period_exact':len(clip)==n,'no_compression_on_menu':menu.read_bytes()==source.read_bytes(),'listening_approval':False}
assert report['unchanged_before_final_blend'] and report['loop_period_exact'] and report['no_compression_on_menu'] and abs(seam-local_step)<1e-7
# Decode the complete WAV once more and verify its exact frame count.
r = subprocess.run([imageio_ffmpeg.get_ffmpeg_exe(),'-v','error','-xerror','-i',str(battle),'-f','s16le','pipe:1'],capture_output=True,check=True)
assert len(r.stdout)==n*4
report['full_wav_decode']=True
(OUT/'audio_validation.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
original = ROOT/'assets/menu/opening/B-22_Dead_Street.mp3'
catalog = {'schema_version':1,'signature_track':'dead_street','tracks':[
 {'id':'dead_street','title':'Dead Street','artist':'B-22','menu_file':'res://assets/menu/opening/B-22_Dead_Street.mp3','source_title':'Track 22','source_artist':'brandon','source_url':'https://soundcloud.com/brandonharb-1/track-22/s-eO7fL','menu_sha256':hashlib.sha256(original.read_bytes()).hexdigest(),'default_enabled':True},
 {'id':'bond_ob','title':'Bond','artist':'OB','menu_file':'res://assets/audio/music/OB_Bond.mp3','source_title':'Bond','source_artist':'OB','source_url':'https://soundcloud.com/colinobriennn/bond','source_track_id':408242721,'menu_sha256':expected,'default_enabled':True,'battle_loop':{'file':'res://assets/audio/music/OB_Bond_battle_21_51.wav','source_start_seconds':21.0,'duration_seconds':30.0,'seam_blend_seconds':blend,'seam_preroll_seconds':blend,'sample_rate':rate,'channels':2,'frames':n,'sha256':report['battle_sha256']}}
 ],'faction_tracks':{}}
target=ROOT/'assets/data/music_catalog.json'
assert not target.exists() or json.loads(target.read_text(encoding='utf-8'))==catalog, 'Preserve newer catalogue'
target.write_text(json.dumps(catalog,indent=2)+'\n',encoding='utf-8')
print(json.dumps(report),flush=True)
