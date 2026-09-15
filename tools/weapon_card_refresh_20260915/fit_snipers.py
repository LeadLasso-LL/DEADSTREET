from pathlib import Path
import subprocess
O=Path(__file__).resolve().parent
p=O/'build_cards.py';s=p.read_text(encoding='utf-8')
needle="    for i,node in enumerate(art[row['model']]):g.insert(i,copy.deepcopy(node))"
assert s.count(needle)==1
s=s.replace(needle,"""    definition=json.loads((R/f"assets/art/weapons/arsenal/source/{row['model']}.json").read_text())
    sniper=row['model'] in ['rem700','sks','svd','ssg69','awm','psg1']
    gx,gy=definition['right_grip']
    wrapper=E.Element(N+'g',{'transform':f'translate({gx} {gy}) scale(0.9) translate({-gx} {-gy})'}) if sniper else E.Element(N+'g')
    for node in art[row['model']]:wrapper.append(copy.deepcopy(node))
    g.insert(0,wrapper)""")
p.write_text(s,encoding='utf-8',newline='\n')
exec(compile(s,str(p),'exec'))
subprocess.run([__import__('sys').executable,str(O/'edges.py')],check=True)
