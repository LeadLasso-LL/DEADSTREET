"""Shared jogging contact and recovery, in character-local world units."""
import math
def smooth(t):
 t=max(0.0,min(1.0,t));return t*t*(3-2*t)
def height(q,base):
 # Compression after contact; extension and flight before the next landing.
 return base+2.0-1.1*math.cos(4*math.pi*(q-.18))
def foot(p):
 if p<.36:
  t=p/.36
  along=12-26*t
  roll=smooth((p-.26)/.10)
  return along,0.0,3*(1-smooth(t/.25))-14*roll,5*roll
 t=(p-.36)/.64
 # Heel folds up behind the seat, then knee travels forward and foot unfolds.
 along=(1-t)**3*(-14)+3*(1-t)**2*t*(-20)+3*(1-t)*t*t*17+t**3*12
 lift=11*math.sin(math.pi*(t**.72))**1.4
 pitch=-14*(1-t)-8*math.sin(math.pi*t)+3*t
 return along,lift,pitch,0.0


def limping_foot(p):
 # Longer support on the sound leg; short, low recovery on the sore leg.
 sore=p>=.5
 u=(p*2)%1
 along,lift,pitch,pivot=foot(u*.5 if sore else .5+u*.5)
 return along*.62,lift*(.28 if sore else .48),pitch*.35,pivot*.3

def wounded_foot(p,side):
 sore=side==1;stance=.40 if sore else .72
 reach=7 if sore else 11
 if p<stance:
  t=p/stance;roll=smooth((t-.8)/.2)
  return reach-2*reach*t,0,-7*roll,3*roll
 t=(p-stance)/(1-stance)
 return -reach+2*reach*smooth(t),(1.2 if sore else 7)*math.sin(math.pi*t),-7*(1-t),0
