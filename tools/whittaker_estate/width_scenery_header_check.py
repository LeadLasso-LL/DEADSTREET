from pathlib import Path
import subprocess,sys
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');p=r/'tools/tactical_controls/hud_layout_review.gd';s=p.read_text(encoding='utf-8')
s=s.replace('   var rect=hud.surface.get_global_rect()','   for settle in range(4):await process_frame\n   await RenderingServer.frame_post_draw\n   var rect=hud.surface.get_global_rect()')
s=s.replace('   var debug_fields=[]','   for header in [hud.faction_emblem,hud.faction_label,hud.strength_label,hud.strength_fill.get_parent()]:\n    check(rect.encloses(header.get_global_rect()),map_id+" header enclosed "+str(header.name))\n   print("HUD_HEADER ",map_id," ",size," ",hud.right_header.position," ",hud.faction_label.get_global_rect()," visible ",hud.faction_label.is_visible_in_tree()," text ",hud.faction_label.text)\n   var debug_fields=[]')
s=s.replace('"hud_width":rect.size.x','"logical_viewport":str(viewport_size),"hud_width":rect.size.x')
p.write_text(s,encoding='utf-8')
subprocess.run([sys.executable,str(r/'tools/tactical_controls/run.py'),'pack'],cwd=r,check=True)
with (r/'tools/whittaker_estate/width_scenery_20260914/hud.log').open('wb') as log:q=subprocess.run([r'C:\Users\brand\AppData\Local\DeadStreetTools\godot_release_4.7.2\godot.exe','--fixed-fps','30','--','--check=hud_layout_review'],cwd=r,stdout=log,stderr=subprocess.STDOUT,timeout=180)
print('HUD_RECHECK',q.returncode,flush=True)