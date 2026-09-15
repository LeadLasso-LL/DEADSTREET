from pathlib import Path
import subprocess,sys
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');o=r/'tools/whittaker_estate/width_scenery_20260914';base=Path(r'C:\Users\brand\AppData\Local\DeadStreetTools\godot_release_4.7.2')
(r/'tools/tactical_controls/estate_scenery_preview.gd').write_text("extends \"res://tools/tactical_controls/estate_record.gd\"\nfunc _initialize():\n out=\"C:/Users/brand/OneDrive/Documents/dead-street/tools/whittaker_estate/width_scenery_20260914\"\n super._initialize()\nfunc _process(delta):\n super._process(delta)\n if frames>=60:\n  active=false\n  print(\"SCENERY_PREVIEW_COMPLETE\")\n  quit()\n return false\n",encoding='utf-8')
commands=[([sys.executable,str(r/'tools/tactical_controls/run.py'),'pack'],'pack1'),([str(base/'godot.exe'),'--','--check=estate_bake'],'bake'),([sys.executable,str(r/'tools/tactical_controls/run.py'),'pack'],'pack2'),([str(base/'godot.exe'),'--fixed-fps','30','--','--check=hud_layout_review'],'hud'),([str(base/'godot.exe'),'--fixed-fps','30','--','--check=estate_scenery_preview'],'intro')]
for cmd,name in commands:
 print('START',name,flush=True)
 with (o/(name+'.log')).open('wb') as log:result=subprocess.run(cmd,cwd=r,stdout=log,stderr=subprocess.STDOUT,timeout=180)
 text=(o/(name+'.log')).read_text(encoding='utf-8',errors='replace');errors=[s for s in text.splitlines() if 'SCRIPT ERROR' in s or s.startswith('ERROR:') or 'HUD_FAIL' in s]
 print('DONE',name,result.returncode,errors,flush=True)
 if result.returncode or errors:print(text[-6000:],flush=True);raise SystemExit(1)
print('PRESENTATION_NATIVE_CHECKS_COMPLETE',flush=True)