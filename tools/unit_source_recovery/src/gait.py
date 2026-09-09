"""Shared jogging contact and recovery, in character-local world units."""
import math
def smooth(t):
 t=max(0.0,min(1.0,t));return t*t*(3-2*t)
def height(q,base):
 # Compression after contact; extension and flight before the next landing.
 return base-2.8*math.cos(4*math.pi*(q-.18))
def foot(p):
 if p<.36:
  t=p/.36
  along=16-34*t
  roll=smooth((p-.26)/.10)
  return along,0.0,6*(1-smooth(t/.25))-28*roll,8*roll
 t=(p-.36)/.64
 # Heel folds up behind the seat, then knee travels forward and foot unfolds.
 along=(1-t)**3*(-18)+3*(1-t)**2*t*(-29)+3*(1-t)*t*t*22+t**3*16
 lift=27*math.sin(math.pi*(t**.72))**1.4
 pitch=-28*(1-t)-15*math.sin(math.pi*t)+6*t
 return along,lift,pitch,0.0
