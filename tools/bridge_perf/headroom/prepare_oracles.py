from pathlib import Path
import re
import subprocess

BASELINE = "613bbabb4d7d642bdaeb008e4ad272530ff53fd5"
ROOT = Path(__file__).resolve().parents[3]
OUTPUT = Path(__file__).resolve().parent

def prepare():
    paths = subprocess.check_output(
        ["git", "ls-tree", "-r", "--name-only", BASELINE, "battle"], cwd=ROOT,
        text=True, encoding="utf-8").splitlines()
    paths = [p for p in paths if p.endswith("_service.gd") or Path(p).name in
             ("battle_relative_strength.gd", "battle_adaptive_tactics.gd", "battle_unit_tier_catalog.gd")]
    mapping = {p: "tools/bridge_perf/headroom/oracle/" + p for p in paths}
    for path, destination in mapping.items():
        source = subprocess.check_output(["git", "show", BASELINE + ":" + path],
                                         cwd=ROOT, text=True, encoding="utf-8")
        source = re.sub(r"(?m)^class_name .*\n", "", source)
        for original, replacement in mapping.items():
            source = source.replace("res://" + original, "res://" + replacement)
        target = ROOT / destination
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(source, encoding="utf-8")
    source = subprocess.check_output(
        ["git", "show", BASELINE + ":gameplay/tactical_actor_presenter.gd"],
        cwd=ROOT, text=True, encoding="utf-8")
    (OUTPUT / "oracle_actor.gd").write_text(
        re.sub(r"(?m)^class_name .*\n", "", source), encoding="utf-8")

if __name__ == "__main__":
    prepare()
