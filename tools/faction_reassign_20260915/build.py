from pathlib import Path
import hashlib,json,subprocess,wave
import numpy as np
import imageio_ffmpeg
OUT=Path(__file__).resolve().parent;ROOT=OUT.parents[1]
RATE=44100;N=30*RATE;K=round(.080*RATE)
assets=ROOT/"assets/audio/music"
validation=OUT/"validation";validation.mkdir(exist_ok=True)
sha=lambda b:hashlib.sha256(b).hexdigest()
def process(meta):
    source=assets/f"{meta['basename']}.mp3"
    original=source.read_bytes();assert sha(original)==meta['sha256']
    raw=subprocess.check_output([imageio_ffmpeg.get_ffmpeg_exe(),'-v','error','-xerror','-err_detect','explode','-i',str(source),'-f','f32le','-ar',str(RATE),'-ac','2','pipe:1'],timeout=60)
    pcm=np.frombuffer(raw,dtype='<f4').reshape(-1,2)
    decoded_seconds=len(pcm)/RATE
    start=meta['start_seconds'];a=round(start*RATE)
    assert a>=0 and a+N<=len(pcm),'Excerpt extends outside full decoded audio'
    clip=pcm[a:a+N].copy();raw_step=float(np.max(np.abs(clip[0]-clip[-1])))
    if a>=K:
        preroll=pcm[a-K:a];mode='source_preroll';expected_step=float(np.max(np.abs(pcm[a]-pcm[a-1])))
    elif a==0:
        # Odd reflection preserves the zero-second first sample and slope without negative indexing.
        preroll=2*clip[0]-clip[K:0:-1];mode='zero_start_odd_reflection';expected_step=float(np.max(np.abs(clip[1]-clip[0])))
    else:
        raise ValueError('Sub-80ms nonzero start needs explicit seam handling')
    w=(.5-.5*np.cos(np.linspace(0,np.pi,K)))[:,None]
    clip[-K:]=clip[-K:]*(1-w)+preroll*w
    source_peak=float(np.max(np.abs(clip)));gain=min(1.,10**(-1/20)/max(source_peak,1e-9))
    clip*=gain
    assert np.allclose(clip[:-K],pcm[a:a+N-K]*gain,atol=1e-7)
    processed_step=float(np.max(np.abs(clip[0]-clip[-1])))
    assert abs(processed_step-expected_step*gain)<2e-7
    encoded=np.rint(clip*32767).astype('<i2')
    assert encoded.shape==(N,2) and float(np.max(np.abs(clip)))<1
    menu=assets/f"{meta['basename']}.mp3";loop=assets/f"{meta['basename']}_battle_{start}_{start+30}.wav"
    assert not menu.exists() or menu.read_bytes()==original,'Do not overwrite a different menu asset'
    menu.write_bytes(original)
    with wave.open(str(loop)+'.part','wb') as f:
        f.setnchannels(2);f.setsampwidth(2);f.setframerate(RATE);f.writeframes(encoded.tobytes())
    Path(str(loop)+'.part').replace(loop)
    with wave.open(str(loop),'rb') as f:
        assert (f.getnframes(),f.getnchannels(),f.getsampwidth(),f.getframerate())==(N,2,2,RATE)
        assert f.readframes(N)==encoded.tobytes()
    decoded=subprocess.check_output([imageio_ffmpeg.get_ffmpeg_exe(),'-v','error','-xerror','-i',str(loop),'-f','s16le','pipe:1'],timeout=30)
    assert decoded==encoded.tobytes()
    result={**meta,'status':'validated','decoded_source_seconds':decoded_seconds,'frames':N,'duration_seconds':30.,'source_start_seconds':start,'source_end_seconds':start+30,'seam_mode':mode,'seam_blend_seconds':.08,'raw_boundary_step':raw_step,'processed_boundary_step':processed_step,'expected_normal_step':expected_step*gain,'battle_gain_db':float(20*np.log10(gain)),'pcm_peak':float(np.max(np.abs(clip))),'menu_sha256':sha(menu.read_bytes()),'battle_sha256':sha(loop.read_bytes()),'menu_file':'res://'+menu.relative_to(ROOT).as_posix(),'battle_file':'res://'+loop.relative_to(ROOT).as_posix(),'full_source_decode':True,'full_wav_decode':True,'period_exact':True,'start_preserved':True,'no_compression_on_menu':menu.read_bytes()==original,'independent_listening_approval':False}
    (validation/f"{meta['id']}.json").write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print('VALIDATED '+meta['id']+' '+str(start)+'-'+str(start+30)+'s',flush=True)
    return result

p=ROOT/'assets/data/music_catalog.json';before=p.read_bytes();catalog=json.loads(before)
assert before==(OUT/'catalog.before.json').read_bytes(),'Concurrent catalogue change'
rows=[('orlov','hitters_b22',17),('union_sur','creepin_b22',12),('calle_ocho','mercy_b22',0)]
results=[]
for faction,id,start in rows:
 t=next(t for t in catalog['tracks'] if t['id']==id)
 assert 'battle_loop' not in t,'Already installed; do not rerun'
 meta={'id':id,'faction':faction,'title':t['title'],'artist':t['artist'],'basename':Path(t['menu_file']).stem,'sha256':t['menu_sha256'],'start_seconds':start}
 result=process(meta);results.append(result)
 t['battle_loop']={'file':result['battle_file'],'source_start_seconds':start,'duration_seconds':30.,'seam_blend_seconds':.08,'seam_mode':result['seam_mode'],'seam_preroll_seconds':.08 if start else 0.,'sample_rate':RATE,'channels':2,'frames':N,'sha256':result['battle_sha256']}
 catalog['faction_tracks'][faction]=id
assert 'glock_b22' not in catalog['menu_excluded_tracks']
catalog['menu_excluded_tracks'].append('glock_b22')
assert p.read_bytes()==before,'Concurrent catalogue edit'
p.write_text(json.dumps(catalog,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
(OUT/'audio_validation.json').write_text(json.dumps({'passed':True,'tracks':results},indent=2),encoding='utf-8')
print('LOOPS AND ASSIGNMENTS INSTALLED; 20 MENU TRACKS',flush=True)
