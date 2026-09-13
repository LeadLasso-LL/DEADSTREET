from pathlib import Path
import argparse
import subprocess
import sys
from prepare_oracles import prepare, ROOT, OUTPUT

parser = argparse.ArgumentParser()
parser.add_argument("--godot", required=True)
parser.add_argument("--native", action="store_true")
parser.add_argument("--side", type=int, default=12)
parser.add_argument("--duration", type=float, default=30.0)
parser.add_argument("--bulwarks", action="store_true")
parser.add_argument("--uncapped", action="store_true")
parser.add_argument("--label", default="native_rerun")
args = parser.parse_args()
prepare()
scripts = ["native.gd"] if args.native else ["focused.gd", "replay.gd", "visual_checks.gd"]
for script in scripts:
    command = [args.godot, "--path", str(ROOT)]
    if not args.native:
        command.append("--headless")
    command += ["--script", "res://tools/bridge_perf/headroom/" + script]
    if args.native:
        command += ["--", "--side=" + str(args.side), "--duration=" + str(args.duration),
                    "--label=" + args.label]
        if args.bulwarks:
            command.append("--bulwarks")
        if args.uncapped:
            command.append("--uncapped")
    result = subprocess.run(command, cwd=ROOT, capture_output=True, timeout=240)
    output = (result.stdout + result.stderr).decode("utf-8", errors="replace")
    log = OUTPUT / (Path(script).stem + "_rerun.log")
    log.write_text(output, encoding="utf-8")
    errors = [line for line in output.splitlines()
              if "SCRIPT ERROR" in line or line.startswith("ERROR:")
              or "REPLAY_FAIL" in line]
    print(script, "exit", result.returncode, "script/engine errors", len(errors))
    if result.returncode or errors:
        print("\n".join(errors[:20]))
        raise SystemExit(1)
print("All requested runs completed without script/engine errors.")
