from pathlib import Path
import re,sys,json
sys.stdout.reconfigure(encoding='utf-8',errors='backslashreplace')
r=Path(__file__).resolve().parents[2]
cache=r/'.godot/global_script_class_cache.cfg'
text=cache.read_text(encoding='utf-8')
rows=[]
for block in re.findall(r'\{.*?\}',text,re.S):
 if 'res://tools/' in block:rows.append(re.search(r'"path": "([^"]+)"',block).group(1))
print('TOOL_CLASS_PATHS',json.dumps(rows,indent=2))
print('ACTIVE_CLASSES',len(re.findall(r'"class":',text)))
