"""Original failing civil-warning rotor. No recordings, voices or engine changes."""
from pathlib import Path
import hashlib,json,wave
import numpy as np

SR=44100
def synthesize():
    t=np.arange(12*SR)/SR
    # A rising/falling electrical rotor above the engine's low rumble.
    knots=[0,.2,1.6,3.1,4.1,5.9,6.7,7.1,8.7,9.2,10.4,11.6,12]
    pitch=[300,320,635,700,460,320,270,360,650,535,370,240,220]
    f=np.interp(t,knots,pitch)
    f*=1+.011*np.sin(2*np.pi*4.7*t)+.004*np.sin(2*np.pi*17.3*t)
    phase=2*np.pi*np.cumsum(f)/SR
    x=np.zeros_like(t)
    for h,gain in [(1,1),(2,.52),(3,.32),(4,.16),(5,.08)]:
        x+=gain*np.sin(h*phase)
    x+=.32*np.sin(phase*1.009+.5*np.sin(2*np.pi*.23*t))
    envelope=np.interp(t,[0,.15,.6,5.0,6.15,6.7,7.0,7.4,10.0,11.65,12],[0,0,1,.92,.1,0,0,.88,.82,0,0])
    # Short power failures interrupt the sweep; rounded edges avoid digital clicks.
    for start,duration,depth in [(2.35,.12,.88),(2.61,.08,.73),(4.36,.23,.85),(8.22,.13,.88),(8.49,.27,.96),(10.25,.12,.7)]:
        phase_drop=np.clip((t-start)/duration,0,1)
        notch=np.sin(np.pi*phase_drop)**2
        envelope*=1-depth*notch
    rotor=.83+.17*np.sin(2*np.pi*(12*t+.16*np.sin(2*np.pi*.31*t)))
    x=np.tanh(x*1.1)*envelope*rotor
    echo=np.zeros_like(x)
    for delay,gain in [(.065,.08),(.13,.035)]:
        n=round(delay*SR);echo[n:]+=x[:-n]*gain
    x+=echo;x-=np.mean(x)
    x*=.72/max(np.max(np.abs(x)),1e-12)
    return x

def save(folder):
    folder=Path(folder);folder.mkdir(parents=True,exist_ok=True)
    x=synthesize();p=folder/'trc_siren.wav'
    with wave.open(str(p),'wb') as w:
        w.setparams((1,2,SR,0,'NONE','not compressed'));w.writeframes((x*32767).astype('<i2').tobytes())
    report={'file':p.name,'seconds':12,'sample_rate':SR,'peak':float(np.max(np.abs(x))),'rms':float(np.sqrt(np.mean(x*x))),'sha256':hashlib.sha256(p.read_bytes()).hexdigest(),'source':'Original procedural synthesis; broken warning siren, no external samples or vocals','engine_changed':False}
    (folder/'trc_siren_manifest.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report),flush=True)

if __name__=='__main__':
    import sys
    save(sys.argv[1] if len(sys.argv)>1 else Path(__file__).resolve().parents[2]/'assets/audio/convoy')
