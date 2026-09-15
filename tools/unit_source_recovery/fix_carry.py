from pathlib import Path
R=Path(__file__).parent
p=R/'src/directions.py';s=p.read_text()
s=s.replace(" a=math.radians(theta);rot="," if side or d=='SW':origin+=np.array([7.,5.])*(1-aim)*(1-fall)\n a=math.radians(theta);rot=")
s=s.replace(" en[1]+=2.0;ef[1]+=2.0"," if d=='SW':en=np.array([-6.+s*.4,-10.]);ef=np.array([10.+s*.4,-12.])\n en[1]+=2.0;ef[1]+=2.0")
s=s.replace("  g.remove(far);g.append(far)","  if side or d=='SW':\n   # Far upper arm remains behind torso; only its forearm crosses in front.\n   lower_body.limb(g,ef,wr_far,3.15,2.15,skin if k==0 else cloth)\n  else:\n   g.remove(far);g.append(far)")
p.write_text(s)
p=R/'src/directional_base/lower_body.py';s=p.read_text().replace('x*1.34,y*1.24','x*1.34,y*1.60');p.write_text(s)
print('Carry layering and shoe height fixed')
