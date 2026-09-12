"""Rebuild only revised rifles; preserve every accepted outfit and all other guns."""
from pathlib import Path
import concurrent.futures,json,subprocess,sys,time
ROOT=Path(__file__).resolve().parents[2]
sys.path[:0]=[str(ROOT/'tools/arsenal_production'),str(ROOT/'tools/faction_roster')]
import build_roster as roster
MODELS=['g36c','m4a1']
def command(args):subprocess.run(args,cwd=ROOT,check=True)
def main():
    import produce_art as legacy
    began=time.time()
    # The original 0/1/2 variants are still used by Mercer, Orlov and legacy entry points.
    for mid in MODELS:
        for kind in range(3):
            v=f'{kind}_{mid}'
            previous=json.loads((legacy.H/f'completed_{v}.json').read_text())
            command([sys.executable,str(legacy.H/'build_art.py'),mid,str(kind)])
            command([str(roster.GODOT),'--headless','--path',str(ROOT),'--script','res://tools/arsenal_production/render_art.gd'])
            record=json.loads((legacy.H/'render_check.json').read_text())
            assert record['frames']==1840,record
            # Existing rig feet touch borders in a few walk frames; forbid NEW clipped frames.
            assert set(record['touching_frame_border'])<=set(previous['touching_frame_border']),record
            for folder in ['units','death_back','check_comrade']:legacy.finish(legacy.D/folder/f'{v}.png')
            im=legacy.Image.open(legacy.D/'units'/f'{v}.png')
            im.crop((24*128,3*6*128,25*128,3*6*128+128)).crop((18,12,108,92)).save(legacy.D/'portraits'/f'{v}.png')
            (legacy.H/f'completed_{v}.json').write_text(json.dumps(record))
            for p in (legacy.H/'render_svg').glob('*.svg'):p.unlink()
            print('LEGACY_COMPLETE',v,flush=True)
    command([str(roster.GODOT),'--headless','--path',str(ROOT),'--script','res://tools/arsenal_production/render_icons.gd'])
    tasks=[(p,m) for p in roster.PROFILES if p!='orlov_sniper' for m in MODELS]
    def run(task):
        p,m=task
        log=roster.WORK/f'{p}_{m}_refinement.log';log.parent.mkdir(parents=True,exist_ok=True)
        with log.open('w') as f:
            result=subprocess.run([sys.executable,str(ROOT/'tools/faction_roster/build_roster.py'),'--worker',p,'--model',m],stdout=f,stderr=subprocess.STDOUT)
        if result.returncode:raise RuntimeError(str(log))
        print('FACTION_COMPLETE',p,m,flush=True)
    with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:list(pool.map(run,tasks))
    print('RIFLE_REFINEMENT_COMPLETE',len(tasks)+6,'sets',round(time.time()-began),'seconds',flush=True)
if __name__=='__main__':main()
