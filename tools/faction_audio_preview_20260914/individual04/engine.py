from pathlib import Path
from dataclasses import dataclass, field
import json, math, hashlib, subprocess, sys
import numpy as np
from scipy.signal import butter, sosfilt
from scipy.io import wavfile
import tinysoundfont
import tempfile, shutil, os
ROOT=Path(__file__).resolve().parent
SR=44100
SF=ROOT.parent / "dependencies/GeneralUser-GS.sf2"
OUT=ROOT / "previews"
OUT.mkdir(exist_ok=True)

@dataclass
class Track:
    label: str
    program: int
    level: float = 1.0
    pan: float = 0.0
    hp: float = 45
    lp: float = 12000
    room: float = .1
    delay: float = 0
    drive: float = 0
    drum: bool = False
    notes: list = field(default_factory=list)
    def n(self, beat, pitch, length=.45, vel=85):
        self.notes.append([round(float(beat),5), int(pitch), round(float(length),5),int(vel)])
    def chord(self, beat, pitches, length=1.5, vel=70, strum=0):
        for i,p in enumerate(pitches): self.n(beat+i*strum,p,length,vel-(i%3)*3)

class Song:
    def __init__(self,number,id,name,vibe,bpm,meter=4,bars=8):
        self.number=number; self.id=id; self.name=name; self.vibe=vibe
        self.bpm=bpm; self.meter=meter; self.bars=bars; self.tracks=[]
        self.beat=60/bpm; self.duration=bars*meter*self.beat+1.8
    def track(self,*args,**kwargs):
        t=Track(*args,**kwargs); self.tracks.append(t); return t

def filt(x,f,kind): return sosfilt(butter(2,f,kind,fs=SR,output='sos'),x,axis=0)

def render_track(song,t):
    synth=tinysoundfont.Synth(gain=-8,samplerate=SR)
    sf=synth.sfload(str(SF))
    synth.program_select(0,sf,128 if t.drum else 0,t.program,is_drums=t.drum)
    synth.control_change(0,10,int(64+t.pan*48))
    events=[]; rng=np.random.default_rng(1700+song.number*13+len(t.label))
    for beat,pitch,dur,vel in t.notes:
        # Small timing/velocity differences retain each deliberately authored rhythm.
        start=max(0,int((beat*song.beat+rng.uniform(-.003,.003))*SR))
        end=start+max(128,int(dur*song.beat*SR))
        velocity=max(1,min(127,vel+int(rng.integers(-3,4))))
        events.extend([(start,1,pitch,velocity),(end,0,pitch,0)])
    events.sort()
    n=int(song.duration*SR); x=np.zeros((n,2),np.float32); pos=0
    for at,on,pitch,vel in events+[(n,0,0,0)]:
        at=min(n,at)
        if at>pos:
            x[pos:at]=np.frombuffer(synth.generate_simple(at-pos),np.float32).reshape(-1,2)
            pos=at
        if on: synth.noteon(0,pitch,vel)
        else: synth.noteoff(0,pitch)
        if pos>=n: break
    synth.sfunload(sf)
    if t.hp: x=filt(x,t.hp,'highpass')
    if t.drive:
        # Cabinet-filtered saturation, with bass kept on a separate clean track.
        x=np.tanh(x*t.drive)/max(1,t.drive*.35)
    if t.lp: x=filt(x,t.lp,'lowpass')
    dry=x.copy()
    if t.delay:
        for rep in range(1,4):
            d=int(SR*song.beat*.75*rep)
            x[d:]+=dry[:-d,::-1]*(t.delay**rep)
    if t.room:
        # Short, diffuse stereo room; no reverb cloud over the rhythm.
        wet=filt(dry,5200,'lowpass')
        for sec,g in [(.037,.26),(.053,.22),(.079,.19),(.113,.16),(.163,.12),(.229,.08),(.307,.055)]:
            d=int(SR*sec); x[d:]+=wet[:-d,::-1]*t.room*g
    return x*t.level

def render(s):
    total=np.zeros((int(s.duration*SR),2),np.float64)
    print(f'{s.number:02d} {s.name}: {len(s.tracks)} tracks, {s.duration:.1f}s',flush=True)
    for t in s.tracks: total+=render_track(s,t)
    if s.id=='ashford_crane':
        # A restrained whole-ensemble tape flutter, no abrupt pitch jumps.
        t=np.arange(len(total))/SR
        shift=.00055*np.sin(2*np.pi*.57*t)+.00014*np.sin(2*np.pi*4.1*t)
        at=np.clip(np.arange(len(total))+shift*SR,0,len(total)-1)
        total=np.column_stack([np.interp(at,np.arange(len(total)),total[:,ch]) for ch in range(2)])
    total=filt(total,28,'highpass')
    total-=total.mean(axis=0)
    # Gentle mix-bus rounding; final EBU normalization is done by FFmpeg below.
    scale=max(.01,np.quantile(np.abs(total),.998))
    total=np.tanh(total/(scale*1.6))*.76
    a=int(.025*SR); tail=int(1.55*SR)
    total[:a]*=np.linspace(0,1,a)[:,None]
    total[-tail:]*=np.linspace(1,0,tail)[:,None]**1.5
    base=f'{s.number:02d}_{s.id}_i4'
    stage=Path(tempfile.mkdtemp(prefix='dead_street_i4_'))
    raw=stage/(base+'_mix.wav')
    wavfile.write(raw,SR,(np.clip(total,-1,1)*32767).astype(np.int16))
    # Two-pass loudness keeps quiet previews and heavier previews comparable.
    pre=subprocess.run(['ffmpeg','-hide_banner','-i',str(raw),'-af','loudnorm=I=-18:TP=-2:LRA=9:print_format=json','-f','null','-'],capture_output=True,text=True,check=True)
    stats=json.loads(pre.stderr[pre.stderr.rfind('{'):])
    af='loudnorm=I=-18:TP=-2:LRA=9:measured_I={input_i}:measured_TP={input_tp}:measured_LRA={input_lra}:measured_thresh={input_thresh}:offset={target_offset}:linear=true'.format(**stats)
    master=stage/(base+'.wav'); mp3=stage/(base+'.mp3')
    subprocess.run(['ffmpeg','-v','error','-y','-i',str(raw),'-af',af,'-ar',str(SR),'-c:a','pcm_s16le',str(master)],check=True)
    subprocess.run(['ffmpeg','-v','error','-y','-i',str(master),'-c:a','libmp3lame','-b:a','192k','-metadata','title='+s.name+' — individual 04','-metadata','artist=DEAD STREET','-metadata','album=DEAD STREET — individual 04 — awaiting review','-metadata','track='+str(s.number),str(mp3)],check=True)
    raw.unlink()
    pcm=wavfile.read(master)[1].astype(np.float64)/32768
    assert np.all(np.isfinite(pcm)) and np.max(np.abs(pcm))<.98 and np.max(np.abs(pcm))>.04
    spec={'number':s.number,'id':s.id,'name':s.name,'vibe':s.vibe,'bpm':s.bpm,'meter':s.meter,'bars':s.bars,'duration':len(pcm)/SR,'status':'PREVIEW — NOT OWNER APPROVED','mp3':mp3.name,'wav':master.name,'peak':float(abs(pcm).max()),'rms':float(np.sqrt(np.mean(pcm**2))),'sha256':hashlib.sha256(mp3.read_bytes()).hexdigest(),'score':[{'label':t.label,'program':t.program,'notes':t.notes} for t in s.tracks]}
    # Publish only closed, validated files; incomplete encoder output stays private.
    for src in [master,mp3]:
        dst=OUT/src.name; pending=OUT/(src.name+'.pending')
        with pending.open('wb') as f:
            f.write(src.read_bytes()); f.flush(); os.fsync(f.fileno())
        os.replace(pending,dst)
    (OUT/(base+'.json')).write_text(json.dumps(spec,ensure_ascii=False,indent=2))
    shutil.rmtree(stage)
    print(f'  rendered {mp3.name}, peak {spec["peak"]:.3f}',flush=True)
    return spec
