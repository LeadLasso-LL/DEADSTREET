"""Run a Godot diagnostic and fail on script errors, including exit-code-zero errors."""
from pathlib import Path
import argparse, subprocess, sys
parser=argparse.ArgumentParser()
parser.add_argument("--godot", required=True)
parser.add_argument("--script", default="res://tools/bridge_perf/next_pass/validate_final.gd")
parser.add_argument("--native", action="store_true")
args, game_args=parser.parse_known_args()
root=Path(__file__).resolve().parents[2]
command=[args.godot,"--path",str(root)]
if not args.native: command.append("--headless")
command += ["--script",args.script]
if game_args: command += ["--",*game_args]
run=subprocess.run(command,capture_output=True,text=True,encoding="utf-8",errors="replace",timeout=180)
output=run.stdout+run.stderr
log=root/"tools/bridge_perf/next_pass"/(Path(args.script).stem+".checked.log")
log.write_text(output,encoding="utf-8")
errors=[line for line in output.splitlines() if "SCRIPT ERROR:" in line or line.startswith("ERROR:")]
print(output[-8000:])
print("Log:",log)
if run.returncode or errors:
    print("FAILED:",run.returncode,errors[:8])
    sys.exit(1)
print("PASS: process succeeded with no engine errors.")
