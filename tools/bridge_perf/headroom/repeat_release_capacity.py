from pathlib import Path
import os,sys,json,subprocess,re,time,ctypes,shutil
sys.stdout.reconfigure(encoding="utf-8")
r=Path(__file__).resolve().parents[3];out=Path(__file__).resolve().parent
if len(sys.argv)!=2:raise SystemExit("Usage: python repeat_release_capacity.py RELEASE_RUNTIME_FOLDER")
base=Path(sys.argv[1]);exe=base/"godot.exe"
v=json.loads((out/"release_results.json").read_text(encoding="utf-8"))
print("COMPLETED_CHECKS",json.dumps(v.get("checks",{})),flush=True)
assert len(v.get("checks",{}))==3,"Wait for original validation to finish before repeat"
class Power(ctypes.Structure):
 _fields_=[("ACLineStatus",ctypes.c_byte),("BatteryFlag",ctypes.c_byte),("BatteryLifePercent",ctypes.c_byte),("SystemStatusFlag",ctypes.c_byte),("BatteryLifeTime",ctypes.c_uint32),("BatteryFullLifeTime",ctypes.c_uint32)]
def normalized(raw):return b"\n".join(x.rstrip(b" \t\r") for x in re.sub(rb"\r+\n",b"\n",raw).split(b"\n")).rstrip(b"\n")+b"\n"
def snapshot(label):
 p=Power();ctypes.windll.kernel32.GetSystemPowerStatus(ctypes.byref(p))
 info={"ac_line":p.ACLineStatus,"battery_percent":p.BatteryLifePercent}
 q=shutil.which("nvidia-smi")
 if q:
  result=subprocess.run([q,"--query-gpu=name,pstate,temperature.gpu,utilization.gpu,clocks.current.graphics,clocks.current.memory,power.draw","--format=csv"],capture_output=True,timeout=10)
  info["gpu"]=normalized(result.stdout+result.stderr).decode("utf-8",errors="replace")
 script="Get-CimInstance Win32_Process | Where-Object { $_.Name -like '*godot*' } | Select-Object Name,ProcessId,CommandLine | ConvertTo-Json -Compress; (Get-Counter '\\Process(*)\\% Processor Time' -SampleInterval 1 -MaxSamples 1).CounterSamples | Where-Object { $_.InstanceName -notin @('_total','idle') } | Sort-Object CookedValue -Descending | Select-Object -First 8 InstanceName,CookedValue | ConvertTo-Json -Compress"
 p=subprocess.run(["powershell","-NoProfile","-Command",script],capture_output=True,timeout=20)
 info["processes_cpu"]=normalized(p.stdout+p.stderr).decode("utf-8",errors="replace")
 print("TELEMETRY",label,json.dumps(info),flush=True);return info
telemetry={"before":snapshot("before")}
for uncapped in [True,False]:
 label="release_32_repeat_"+("uncapped" if uncapped else "normal");path=base/"results"/(label+".json");path.unlink(missing_ok=True)
 cmd=[str(exe),"--","--check=native","--side=16","--duration=30","--label="+label]
 if uncapped:cmd.append("--uncapped")
 print("RUN_BEGIN",label,flush=True);p=subprocess.run(cmd,cwd=r,capture_output=True,timeout=180)
 raw=normalized(p.stdout+p.stderr);(out/(label+".log")).write_bytes(raw);txt=raw.decode("utf-8",errors="replace")
 bad=[x for x in txt.splitlines() if "SCRIPT ERROR" in x or x.startswith("ERROR:")]
 if p.returncode or bad or not path.exists():print(txt[-7000:],flush=True);raise SystemExit("Repeat failed")
 result=json.loads(path.read_text(encoding="utf-8"));(out/path.name).write_bytes((json.dumps(result,indent=2)+"\n").encode("utf-8"))
 assert result["units"]==32 and result["rendered"]==32 and result["damage"]>0 and result["build"]["debug"] is False
 print("REPEAT_RESULT",label,json.dumps(result),flush=True)
 v["native"][label]=result;telemetry[label]=snapshot(label)
 v["telemetry_file"]="release_repeat_telemetry.json";v["repeat_reason"]="Original later 32-unit uncapped sample and paused/setup measurements deteriorated sharply; repeat tests check stability."
 (out/"release_results.json").write_bytes((json.dumps(v,indent=2)+"\n").encode("utf-8"))
 (out/"release_repeat_telemetry.json").write_bytes((json.dumps(telemetry,indent=2)+"\n").encode("utf-8"))
print("RELEASE_REPEAT_COMPLETE",flush=True)
