from pathlib import Path
import shutil
R=Path(__file__).parent
for rel in ['src/base_rig.py','src/directional_base/lower_body.py','src/directional_base/views.py','render.py']:
 p=R/rel;backup=p.with_suffix('.before_motion')
 if not backup.exists():shutil.copy2(p,backup)
 s=backup.read_text()
 if rel=='src/base_rig.py':
  s='import gait\n'+s
  start=s.index('  if p<.42:');end=s.index('  if stop is not None:',start)
  s=s[:start]+'  along,lift,pitch,_=gait.foot(p)\n'+s[end:]
  s=s.replace('h=51-2.4*math.cos(2*math.pi*(beat-.12))','h=gait.height(q,51)')
  s=s.replace('RIGHT*lateral+F*along','RIGHT*(lateral*1.12)+F*(along*1.12)')
 elif rel.endswith('lower_body.py'):
  s='import gait\n'+s
  start=s.index('  elif p<.48:');end=s.index('  along=along*',start)
  s=s[:start]+'  else:along,lift,pitch,toe_pivot=gait.foot(p)\n'+s[end:]
  s=s.replace('h=58.5-1.1*math.cos(2*math.pi*(phase-.13))','h=gait.height(q,54)')
  s=s.replace('x*1.2,y*1.18','x*1.34,y*1.24')
 elif rel.endswith('views.py'):
  s='import gait\n'+s
  start=s.index('  elif p<.48:');end=s.index('  along=along*',start)
  s=s[:start]+'  else:along,lift,pitch,_=gait.foot(p)\n'+s[end:]
  s=s.replace('52.5-(0 if still else 1.1*math.cos(4*math.pi*(q-.065)))','52.5 if still else gait.height(q,52.5)')
  s=s.replace('51.5-(0 if still else 1.8*math.cos(4*math.pi*(q-.065)))','51.5 if still else gait.height(q,51.5)')
  s=s.replace('   if front:lng*=.8','   lat*=1.12;lng*=1.12\n   if front:lng*=.8')
 p.write_text(s)
p=R/'render.py';s=p.read_text()
old="elif clip=='death':st.update(crouch=.9*smooth(t/.5),fall=smooth((t-.3)/.6),lean=-7*math.sin(math.pi*min(t/.3,1)),aim=.2)"
new="""elif clip=='death':
  drop=max(0,min(1,(t-.10)/.45));fall=drop*drop
  settle_t=max(0,(t-.55)/.45)
  bounce=math.sin(min(1,settle_t)*math.pi*2)*math.exp(-settle_t*5) if t>.55 else 0
  buckle=.22*math.sin(math.pi*min(1,t/.32))*(1-fall)
  st.update(crouch=.9*fall+buckle-.06*max(0,bounce),fall=fall-.025*max(0,bounce),lean=-10*math.sin(math.pi*min(1,t/.28))*(1-fall),aim=.2,q=1.15)"""
assert old in s;s=s.replace(old,new);p.write_text(s)
p=R/'src/directions.py';s=p.read_text()
if not s.startswith('import gait'):s='import gait\n'+s
s=s.replace('51-2.4*math.cos(2*math.pi*((q*2)%1-.12))','gait.height(q,51)')
p.write_text(s)
print('Motion source patched')
