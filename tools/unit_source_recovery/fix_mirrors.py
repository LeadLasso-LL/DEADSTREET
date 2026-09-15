from pathlib import Path
R=Path(__file__).parent
p=R/'src/directions.py';s=p.read_text()
needle="def make(k,q,d,w,settle=0,aim=0,kick=0,flash=False,crouch=0,fall=0,lean=0,reload=0):"
s=s.replace(needle,needle+"""
 # User-approved handedness swap: these views are true reflections.
 if d in ['SW','W']:
  root=make(k,q,'SE' if d=='SW' else 'E',w,settle,aim,kick,flash,crouch,fall,lean,reload)
  reflected=E.Element(N+'g',{'transform':'translate(128 0) scale(-1 1)'})
  for child in list(root):root.remove(child);reflected.append(child)
  root.append(reflected)
  return root""")
p.write_text(s)
p=R/'src/build.py';s=p.read_text()
needle=" gun=group(up,transform=f'translate({origin[0]} {origin[1]}) rotate({angle})')"
s=s.replace(needle,""" # Bring the distal support forearm over the shirt edge into the palm.
 support_end=origin+rot@grips[1]
 support_elbow=np.array([56+2*aim,48-6*aim],float)
 sleeve_start=support_elbow*.55+support_end*.45
 B.limb(up,sleeve_start,support_end,2.8,2.3,skin if kind==0 else cloth)
 list(up)[-1].set('fill',hi if kind==0 else shine)
"""+needle)
p.write_text(s)
print('Mirrors and SE wrist join updated')
