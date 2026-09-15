from pathlib import Path
R=Path(__file__).parent
def edit(name,old,new):
 p=R/name;s=p.read_text();assert old in s,name;p.write_text(s.replace(old,new))
edit('src/build.py','def make(kind,q,','def outline_arm(parent,start):\n for el in list(parent)[start:]:\n  if el.get("stroke") not in [None,"none"] and el.get("fill")!="none":\n   el.set("stroke","#090f12");el.set("stroke-width","1.25")\ndef make(kind,q,')
edit('src/build.py','def arm(parent,a,b,c):\n  a,b,c=', 'def arm(parent,a,b,c):\n  outline_start=len(parent)\n  a,b,c=')
edit('src/build.py',"far=group(up);arm(far,"," outline_arm(parent,outline_start)\n far=group(up);arm(far,")
edit('src/build.py','B.limb(up,sleeve_start,support_end,','outline_start=len(up)\n B.limb(up,sleeve_start,support_end,')
edit('src/build.py',"gun=group(up,transform=", "outline_arm(up,outline_start)\n gun=group(up,transform=")
edit('src/build.py',"skin,'#382b25',.6)","skin,'#090f12',.95)")
edit('src/directions.py','def arm(parent,a,b,c):\n  fill=', 'def arm(parent,a,b,c):\n  outline_start=len(parent)\n  fill=')
edit('src/directions.py',' def gun(parent):','  build.outline_arm(parent,outline_start)\n def gun(parent):')
edit('src/directions.py',"skin,'#382b25',.5)","skin,'#090f12',.95)")
edit('src/directions.py','   lower_body.limb(g,ef,wr_far,','   outline_start=len(g)\n   lower_body.limb(g,ef,wr_far,')
edit('src/directions.py','  else:\n   g.remove(far);g.append(far)','   build.outline_arm(g,outline_start)\n  else:\n   g.remove(far);g.append(far)')
print('Internal arm and hand contours strengthened')
