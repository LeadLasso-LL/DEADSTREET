import json
from pathlib import Path
data=json.loads(Path('tools/dusk_review/frontage_revision_payload.json').read_text())
p=Path('gameplay/harold_street_art.gd')
s=p.read_text()
for name,body in data['functions'].items():
    a=s.index('func '+name+'(')
    b=s.find('\nfunc ',a+1)
    s=s[:a]+body.rstrip()+'\n'+s[b+1:] if b>=0 else s[:a]+body
a=s.index('\t\trect(Rect2(door_x-12,base-45')
b=s.index('\t\tfor x in [q.x+10,q.x+sz.x-28]:',a)
s=s[:a]+'\t\tapartment_entry(door_x,base,seed_id==1)\n'+s[b:]
s=s.replace('\t\tlabel(Vector2(q.x+5,base-3),"MH",15,8,Color("#a59d82"))\n','')
a=s.index('\tif seed_id==2:\n\t\tpainted_text(')
b=s.index('\t# Apartment fire escape:',a)
s=s[:a]+s[b:]
needle='\tif prop.is_empty():\n'
ready='\tif not prop.is_empty() and prop[0]=="east_apartments":\n\t\tvar mark=preload("res://gameplay/weathered_graffiti.gd").new()\n\t\tvar bounds: Rect2=prop[1]\n\t\tmark.position=p(bounds.position)+Vector2(43,bounds.size.y*6-7)\n\t\tadd_child(mark)\n'
s=s.replace(needle,ready+needle,1)
s+=data['append']
p.write_text(s)
Path('gameplay/weathered_graffiti.gd').write_text(data['graffiti'])
print('Frontage art and material revision installed')
