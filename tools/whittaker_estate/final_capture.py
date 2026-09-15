from pathlib import Path
import sys,subprocess,ctypes,time
r=Path(__file__).resolve().parents[2];out=r/'tools/whittaker_estate'
# Only stop this pass's superseded capture, after checking its command line.
query=subprocess.run(['powershell','-NoProfile','-Command',"(Get-CimInstance Win32_Process -Filter 'ProcessId=15280').CommandLine"],capture_output=True,text=True)
if '--check=estate_record' in query.stdout:subprocess.run(['taskkill','/PID','15280','/F'],capture_output=True)
k=ctypes.windll.kernel32;k.OpenProcess.restype=ctypes.c_void_p
handle=k.OpenProcess(0x00100000,False,23300)
if handle:
 result=k.WaitForSingleObject(ctypes.c_void_p(handle),450000);k.CloseHandle(ctypes.c_void_p(handle))
 if result!=0:raise RuntimeError('Previous owned recording worker has not exited')
old=out/'superseded_arrival_v1';old.mkdir(exist_ok=True)
for name in ['estate_raw.avi','estate_raw.wav','record.json','record_worker.log','capture.log','Dead_Street_Whittaker_Estate_Mobile.mp4','delivery.json']:
 p=out/name
 if p.exists():p.rename(old/name)
subprocess.run([sys.executable,str(r/'tools/tactical_controls/run.py'),'pack'],cwd=r,check=True,timeout=90)
g=r'C:\Users\brand\AppData\Local\DeadStreetTools\godot_release_4.7.2\godot.exe'
subprocess.run([g,'--','--check=estate_bake'],cwd=r,check=True,timeout=90)
print('FINAL_CAPTURE_START',flush=True)
subprocess.run([sys.executable,'-X','utf8','-u',str(out/'record_worker.py')],cwd=r,check=True,timeout=900)
print('FINAL_CAPTURE_COMPLETE',flush=True)
