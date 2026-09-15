from pathlib import Path
import subprocess,sys
r=Path(r'C:\Users\brand\OneDrive\Documents\dead-street');p=r/'gameplay/tactical_command_hud.gd';s=p.read_text(encoding='utf-8')
s=s.replace('var right_header: Control','var header_fields: Array[Control] = []').replace('\tright_header = Control.new()\n\tsurface.add_child(right_header)\n\tright_header.mouse_filter = Control.MOUSE_FILTER_IGNORE\n','').replace('right_header.add_child','surface.add_child').replace('label(right_header,','label(surface,')
s=s.replace('\tstrength_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE','\tstrength_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE\n\theader_fields.assign([faction_emblem, faction_label, divider, strength_label, strength_bg])\n\tfor field in header_fields:\n\t\tfield.set_meta("header_base_x", field.position.x)')
s=s.replace('\tright_header.position.x = layout_width - DESIGN_SIZE.x','\tfor field in header_fields:\n\t\tfield.position.x = float(field.get_meta("header_base_x")) + layout_width - DESIGN_SIZE.x');p.write_text(s,encoding='utf-8')
p=r/'tools/tactical_controls/hud_layout_review.gd';s=p.read_text(encoding='utf-8').replace('hud.right_header.position','hud.faction_emblem.position');p.write_text(s,encoding='utf-8')
subprocess.run([sys.executable,str(r/'tools/tactical_controls/run.py'),'pack'],cwd=r,check=True)
with (r/'tools/whittaker_estate/width_scenery_20260914/hud.log').open('wb') as log:q=subprocess.run([r'C:\Users\brand\AppData\Local\DeadStreetTools\godot_release_4.7.2\godot.exe','--fixed-fps','30','--','--check=hud_layout_review'],cwd=r,stdout=log,stderr=subprocess.STDOUT,timeout=180)
print('HUD_RENDER_CHECK',q.returncode,flush=True)