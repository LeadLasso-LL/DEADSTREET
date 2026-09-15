from pathlib import Path
import subprocess
r=Path('C:/Users/brand/OneDrive/Documents/dead-street')
p=r/'tools/tactical_controls/estate_director.gd';s=p.read_text();assert 'estate_flank_count"]=3' in s;s=s.replace('estate_flank_count"]=3','estate_flank_count"]=4').replace('three-person flank','four-person flank');p.write_text(s)
p=r/'battle/geometry/whittaker_estate_catalog.gd';s=p.read_text();assert '[119.,88.,"rancher"' in s;s=s.replace('[119.,88.,"rancher"','[116.,74.,"rancher"');p.write_text(s)
p=r/'tools/tactical_controls/estate_assault_checks.gd';s=p.read_text().replace('flankers.size()==3,"exactly three flankers"','flankers.size()==4,"all four Vigil passengers flank"').replace('dir.flank_paths.size()==3,"three planned flank paths"','dir.flank_paths.size()==4,"four planned flank paths"');p.write_text(s)
d=r/'tools/tactical_controls/hud_fixed_20260914'
for name,args in [('pack',[str(r/'tools/tactical_controls/run.py'),'pack']),('assault',['--headless','--','--check=estate_assault_checks']),('probe',['--headless','--','--check=estate_probe'])]:
 exe=str(Path('C:/Users/brand/AppData/Local/DeadStreetTools/python/python.exe')) if name=='pack' else 'C:/Users/brand/AppData/Local/DeadStreetTools/godot_release_4.7.2/godot.exe'
 result=subprocess.run([exe]+args,cwd=r,capture_output=True,timeout=180);log=(result.stdout+result.stderr).decode(errors='replace');(d/(name+'_four.log')).write_text(log);print(name,result.returncode,log[-9000:] if name=='probe' or result.returncode else log[-300:],flush=True)
 assert result.returncode==0
