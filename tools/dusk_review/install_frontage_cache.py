import json
from pathlib import Path
data=json.loads(Path('tools/dusk_review/cache_patch.json').read_text())
p=Path('gameplay/harold_street_art.gd')
s=p.read_text()
s=s.replace('var gang_font: SystemFont\n','var bake_source := false\nvar frontage_texture: Texture2D\nvar frontage_bounds: Rect2\n')
s=s.replace('\tgang_font=SystemFont.new()\n\tgang_font.font_names=PackedStringArray(["Old English Text MT"])\n','')
s=s.replace('if not prop.is_empty() and prop[0]=="east_apartments":','if not bake_source and not prop.is_empty() and prop[0]=="east_apartments":')
s=s.replace('\tif prop.is_empty():\n','\tif prop.is_empty() and not bake_source:\n',1)
s=s.replace('func ground() -> void:',data['setup']+'\nfunc ground() -> void:',1)
s=s.replace('func _draw() -> void:\n','func _draw() -> void:\n'+data['draw'],1)
p.write_text(s)
print('Static scenery cache hook installed')
