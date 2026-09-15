"""Install the validated live-source sandbox entry; preserve unrelated work."""
from pathlib import Path
import hashlib,json,subprocess,datetime
repo=Path(r'C:\Users\brand\OneDrive\Documents\dead-street')
out=repo/'tools/menu_title_20260914/native'
report=json.loads((out/'smoke.json').read_text())
assert report['status']=='PASS' and report['checks']==29 and report['audio_play_count']==1,report
assert 'OPENING_VALIDATION' in (out/'direct_smoke.log').read_bytes().decode('utf-16',errors='replace')
(out/'direct_smoke.json').write_text(json.dumps(report,indent=2))
launcher=repo/'tools/arsenal_production/Open-Arsenal.ps1'
old=launcher.read_text(encoding='utf-8-sig')
assert "'res://gameplay/arsenal_review.tscn'" in old or "'res://gameplay/sandbox_opening.tscn'" in old
backup=out/'Open-Arsenal.before-enter.ps1'
if not backup.exists():backup.write_bytes(launcher.read_bytes())
launcher.write_text(old.replace("'res://gameplay/arsenal_review.tscn'","'res://gameplay/sandbox_opening.tscn'"),encoding='utf-8')
gui=Path(r'C:\Users\brand\OneDrive\Documents\Godot\Godot_v4.7.2-stable_win64.exe')
assert gui.exists()
cmd=repo/'Open Dead Street Sandbox.cmd'
cmd_text='@echo off\nstart "" "'+str(gui)+'" --path "%~dp0." "res://gameplay/sandbox_opening.tscn"\n'
assert not cmd.exists() or cmd.read_text()==cmd_text,'Existing unrelated launcher must be preserved'
cmd.write_text(cmd_text,encoding='ascii')
receipt={'status':'INSTALLED','time_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=repo,text=True).strip(),'launcher':str(launcher),'double_click_file':str(cmd),'gui':str(gui),'scene':'res://gameplay/sandbox_opening.tscn','validation':report,'publication':'not committed or pushed in this pass','files':{str(p.relative_to(repo)):hashlib.sha256(p.read_bytes()).hexdigest() for p in [launcher,cmd,repo/'gameplay/sandbox_opening.gd',repo/'gameplay/sandbox_menu_music.gd']}}
(out/'launch_receipt.json').write_text(json.dumps(receipt,indent=2))
print(json.dumps(receipt,indent=2))
