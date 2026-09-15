from pathlib import Path
R=Path(__file__).parent
p=R/'src/directions.py';s=p.read_text()
s=s.replace("if d=='SW':theta=30;length=.80","if d=='SW':theta=55;length=.80")
s=s.replace(" a=math.radians(theta);rot="," carry=1.5*math.sin(2*math.pi*(q-.12))*(1-settle)*(1-aim)*(1-fall)\n origin+=np.array([carry,.25*carry])\n a=math.radians(theta);rot=")
s=s.replace(" if d=='SW':en=np.array([-6.+s*.4,-10.]);ef=np.array([10.+s*.4,-12.])"," if d=='W':en=np.array([3.+s*.45,-12.]);ef=np.array([7.+s*.3,-16.])\n if d=='SW':en=np.array([-7.+s*.4,-6.]);ef=np.array([10.+s*.4,-16.])")
s=s.replace(" en[1]+=2.0;ef[1]+=2.0"," en[0]+=.45*carry;ef[0]+=.45*carry\n en[1]+=2.0;ef[1]+=2.0")
p.write_text(s)
p=R/'src/build.py';s=p.read_text()
s=s.replace(" origin+=np.array([4*aim-1.4*kick,-10*aim-.6*kick])"," origin+=np.array([4*aim-1.4*kick,-10*aim-.6*kick])\n carry=1.5*math.sin(2*math.pi*(q-.12))*(1-settle)*(1-aim)*(1-fall)\n origin+=np.array([carry,.25*carry])")
p.write_text(s)
print('Grip routing and carry motion updated')
