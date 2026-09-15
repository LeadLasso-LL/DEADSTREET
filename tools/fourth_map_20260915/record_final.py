from pathlib import Path
import shutil,sys,subprocess
r=Path("C:\\Users\\brand\\OneDrive\\Documents\\dead-street");o=r/'tools/fourth_map_20260915';archive=o/'first_export';archive.mkdir(exist_ok=True)
for name in ['record.json','delivery.json','capture.log','capture_godot.log','capture_source_hashes.json','DEAD_STREET_Doble_Ocho_Battle.mp4','combat_14.png']:
 p=o/name;assert p.exists();assert not (archive/name).exists();shutil.copy2(p,archive/name)
for name in ['record_worker.py','encode.py']:
 p=o/name;s=p.read_text(encoding='utf-8');assert 'yard_raw_v1.avi' in s;p.write_text(s.replace('yard_raw_v1.avi','yard_raw_v2.avi'),encoding='utf-8')
print('First export retained; faster occlusion reveal in final capture',flush=True)
subprocess.run([sys.executable,str(o/'record_worker.py')],check=True)
