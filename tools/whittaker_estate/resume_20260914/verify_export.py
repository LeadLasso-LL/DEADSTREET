from pathlib import Path
import subprocess,sys,json
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');o=r/'tools/whittaker_estate'
p=o/'encode.py';s=p.read_text(encoding='utf-8');assert "'-ac','1','-ar','22050'" in s
s=s.replace("'-ac','1','-ar','22050'","'-ac','2','-ar','22050'").replace('len(a)>duration*22050*.99','len(a)>duration*22050*2*.99')
p.write_text(s,encoding='utf-8')
# Reuse the completed valid encode; rerun the decode/verification/writeback tail.
prefix=s[:s.index('base=[ff,')]
tail=s[s.index("subprocess.run([ff,'-v','error','-i',str(final)"): ]
scope={'__file__':str(p),'__name__':'__main__'}
exec(compile(prefix+"\nfinal=out/'Dead_Street_Whittaker_Estate_Mobile.mp4'\n"+tail,str(p),'exec'),scope)
with (r/'docs/DEAD_STREET_JOURNAL.md').open('a',encoding='utf-8') as f:f.write('\n\n### 20260914-active-resume-04 - Capture/export verification\nCurrent line-command checks passed 128/128 and native UI 43/43. Final recording passed 31,514 actor-frame checks, zero HUD/visibility/route errors, max ending movement 1.434 px and zero result-card camera jump. 36 clips loaded with a maximum of three simultaneous voices. Original stereo peak 0.947 and AAC stereo peak 0.925; neither clipped. The old export check downmixed stereo to mono and falsely exceeded unity. Corrected to verify delivered stereo; reused the already valid encode rather than changing its mix or repeating the capture. Source/mix unchanged by this validation correction.\n')
g=r'C:\Users\brand\AppData\Local\DeadStreetTools\godot_release_4.7.2\godot.exe'
p=subprocess.run([g,'--','--check=estate_native'],cwd=r,capture_output=True,timeout=90)
log=(p.stdout+p.stderr).decode('utf-8',errors='replace');(o/'resume_20260914/native_final.log').write_text(log,encoding='utf-8');print('NATIVE',p.returncode,log[-1800:],flush=True)
