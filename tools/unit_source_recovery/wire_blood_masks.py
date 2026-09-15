from pathlib import Path
R=Path(__file__).parents[2]
p=R/'assets/art/street_detail/unit_finish.gdshader';s=p.read_text()
s=s.replace('uniform bool blood_enabled = true;','uniform sampler2D clothing_mask : hint_default_black, filter_nearest, repeat_disable;\nuniform bool blood_enabled = true;')
old='float fabric=1.0-step(0.16,max(max(c.r,c.g),c.b)-min(min(c.r,c.g),c.b));'
assert old in s;s=s.replace(old,'float fabric=step(0.98,texture(clothing_mask,uv).r);');p.write_text(s)
p=R/'gameplay/tactical_actor_presenter.gd';s=p.read_text().replace('var _abdomen: Dictionary = {}','var _abdomen: Dictionary = {}\nvar _blood_masks: Dictionary = {}')
old='\t\t\tvar point: Array=_abdomen.get'
new='\t\t\tif not _blood_masks.has(stain_variant): _blood_masks[stain_variant]=load("res://assets/art/units/pixel_v1/blood_masks/"+stain_variant+".png")\n\t\t\tbody.material.set_shader_parameter("clothing_mask",_blood_masks[stain_variant])\n'+old
assert old in s;s=s.replace(old,new);p.write_text(s)
p=R/'tools/dusk_review/blood_preview.gd';s=p.read_text()
old='mat.set_shader_parameter("blood_enabled",i!=2);'
assert old in s;s=s.replace(old,'mat.set_shader_parameter("clothing_mask",load("res://assets/art/units/pixel_v1/blood_masks/"+spec[0]+".png"));'+old);p.write_text(s)
p=R/'docs/BLOOD_PRESENTATION.md';s=p.read_text();s+='\nClothing stains use per-frame clothing visibility masks drawn in the same layer order as the sprites. Foreground guns, hands, arms and outlines exclude blood; Blood Off still hides all effects. Rebuild masks with export_blood_masks.py then render_blood_masks.gd whenever anatomy, clothing or equipment changes.\n';p.write_text(s)
print('Stains restricted to visible clothing pixels')
