from pathlib import Path
R=Path(__file__).parent
def edit(name,old,new):
 p=R/name;s=p.read_text();assert old in s,name;p.write_text(s.replace(old,new))
edit('src/build.py','near=group(up);arm(near,','if wounded:up.remove(far);up.append(far)\n near=group(up);arm(near,')
edit('src/directions.py',"if side or d=='SW':\n   # Far upper", "if (side or d=='SW') and not wounded:\n   # Far upper")
for name,old,new in [
 ('src/base_rig.py','knee=knee*(1-fall)', 'knee=(hp+(ank-hp)*.473+(knee-(hp+(ank-hp)*.473))*.18) if wounded and side==1 else knee;knee=knee*(1-fall)'),
 ('src/directional_base/lower_body.py','knee=knee*(1-fall)', 'knee=(hp+(ank-hp)*.473+(knee-(hp+(ank-hp)*.473))*.18) if wounded and side==1 else knee;knee=knee*(1-fall)'),
 ('src/directional_base/views.py','b3=b3*(1-fall)', 'b3=(a3+(ank-a3)*.473+(b3-(a3+(ank-a3)*.473))*.18) if wounded and side==1 else b3;b3=b3*(1-fall)')]:
 edit(name,old,new)
edit('src/gait.py','stance=.52 if sore else .68','stance=.40 if sore else .72')
edit('src/gait.py','reach=8 if sore else 10','reach=7 if sore else 11')
edit('src/gait.py','(3 if sore else 6)*math.sin(math.pi*t)','(1.2 if sore else 7)*math.sin(math.pi*t)')
print('Connected wounded arm layers and stiff injured knee')
