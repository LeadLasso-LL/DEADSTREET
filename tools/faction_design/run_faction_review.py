"""One-command review build, with targeted outfit revisions and full final checks."""
from pathlib import Path
import argparse, importlib, json, subprocess, sys, time

HERE=Path(__file__).parent
ROOT=HERE.parents[1]
sys.path.insert(0,str(HERE))


def main():
    p=argparse.ArgumentParser()
    p.add_argument('faction',choices=['eastex','whittaker','calle_ocho','ventresca','ravicci','zangyaku','bitian','stateline','sierra_roja'])
    p.add_argument('--godot',required=True)
    p.add_argument('--full',action='store_true')
    p.add_argument('--roles',nargs='+',choices=['pistol','smg','shotgun','rifle','sniper'])
    p.add_argument('--output-name',default='')
    args=p.parse_args()
    import review_eastex as review
    profile=importlib.import_module(args.faction+'_outfits')
    name=args.output_name or args.faction
    if not name.replace('_','').isalnum():raise ValueError('Invalid output directory')
    out=HERE/name
    frames=out/'frames';frames.mkdir(parents=True,exist_ok=True)
    (frames/'.gdignore').touch()
    review.style=profile;review.OUT=out;review.FRAMES=frames
    review.KIND=getattr(profile,'KIND',0)
    review.TITLE=getattr(profile,'TITLE',"EASTEX 44'S")
    review.PREFIX=args.faction
    review.DESCRIPTIONS=getattr(profile,'DESCRIPTIONS',review.DESCRIPTIONS)
    timings={};started=time.perf_counter()
    def stage(name,fn):
        t=time.perf_counter();fn();timings[name]=round(time.perf_counter()-t,3)
    stage('source_and_geometry',lambda:review.generate(args.full,args.roles))
    base='res://tools/faction_design/'+name+'/'
    stage('render_and_bounds',lambda:subprocess.run([args.godot,'--headless','--path',str(ROOT),
          '--script','res://tools/faction_design/render_eastex.gd','--',base],cwd=ROOT,check=True))
    stage('palette_and_review_sheets',review.board)
    if args.full:stage('motion_and_armory_sheets',review.audit)
    render=json.loads((out/'render_validation.json').read_text())
    geometry=json.loads((out/'geometry_validation.json').read_text())
    assert not render['failures'] and render['frames']==geometry['frames']
    assert geometry['body_matches_accepted_geometry']
    full=args.full and (not args.roles or set(args.roles)==set(review.ROLES))
    if full:assert render['frames']==1080
    report={'faction':args.faction,'full_review':full,'roles':args.roles or review.ROLES,
            'frames':render['frames'],'failures':[], 'timings_seconds':timings,
            'total_seconds':round(time.perf_counter()-started,3),
            'visual_acceptance':'Requires visual review; automated checks do not assert acceptance.'}
    (out/'pipeline_report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print('FACTION_REVIEW_COMPLETE',json.dumps(report),flush=True)


if __name__=='__main__':main()
