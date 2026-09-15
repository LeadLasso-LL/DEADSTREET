from pathlib import Path
import json
r=Path(r"C:\Users\brand\OneDrive\Documents\dead-street")
event=json.loads((r/"tools/bike_slots_20260915/checkpoint3.json").read_text())
for name in ["DEAD_STREET_HIVE_MIND.md","DEAD_STREET_JOURNAL.md","DEAD_STREET_PROJECT_CONTROL.md"]:
 p=r/"docs"/name
 if "## 20260915-bike-slots-03" not in p.read_text(encoding="utf-8"):
  with p.open("a",encoding="utf-8",newline="\n") as f:f.write("\n\n"+event+"\n")
 assert "## 20260915-bike-slots-03" in p.read_text(encoding="utf-8")
print("Checkpoint03 saved and verified in Hive, Journal and Project Control")
