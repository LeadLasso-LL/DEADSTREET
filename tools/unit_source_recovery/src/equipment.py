"""Reusable weapon art and attachment anchors, independent of faction."""
import json,copy
from pathlib import Path
import xml.etree.ElementTree as E
ROOT=Path(__file__).parent/'weapons'
DEFAULTS=['uzi_smg','ak_rifle','pistol']
DEFINITIONS=json.loads((ROOT/'equipment.json').read_text())
ART={key:E.parse(ROOT/value['art']).getroot() for key,value in DEFINITIONS.items()}
def draw(parent,weapon_id,reload=0):
 import xml.etree.ElementTree as E
 ns='{http://www.w3.org/2000/svg}'
 for child in ART[weapon_id]:
  child=copy.deepcopy(child)
  if 0<reload<1:
   body=list(child)[0];d=body.get('d')
   if weapon_id=='ak_rifle':d=d.replace('L22 6 22 7 Q22.8 12 26.2 16 L22.8 17 Q19 13 18 8 L13 8','L22 6 L18 8 L13 8')
   elif weapon_id=='uzi_smg':d=d.replace('18 7 17 19 13 19 12 7','18 7 17.6 11 12.4 11 12 7')
   body.set('d',d)
  # Weapon-local contours remain separate from the unit silhouette.
  body=list(child)[0]
  body.set('stroke','#090f12');body.set('stroke-width','1.35')
  if weapon_id=='uzi_smg':
   body.set('fill','#555c63')
   E.SubElement(child,ns+'path',{'d':'M12.5 7 L17.5 7 17 19 13 19Z M30 1 L37 1 37 4 30 4Z M0 1 L8 1 8 5 0 5Z','fill':'#111819','stroke':'#090f12','stroke-width':'.75'})
   E.SubElement(child,ns+'path',{'d':'M9 1 L27 1 M20 4 L25 4','fill':'none','stroke':'#959fa5','stroke-width':'1.0'})
  elif weapon_id=='pistol':
   E.SubElement(child,ns+'path',{'d':'M1 0 L12 0','fill':'none','stroke':'#899399','stroke-width':'.85'})
  if weapon_id=='uzi_smg' and 0<reload<1:
   for part in child:
    if part.get('d','').startswith('M12.5 7'):part.set('d',part.get('d').replace('17 19 13 19','17.5 11 12.5 11'))
  parent.append(child)
 if weapon_id!='pump_shotgun' and 0<reload<1 and not .4<reload<.55:
  y=mag_offset(reload)
  shape={'ak_rifle':'M18 7 L22 7 Q22.8 12 26.2 16 L22.8 17 Q19 13 18 7Z','uzi_smg':'M12.4 11 L17.6 11 17 19 13 19Z','pistol':'M1.5 10 L4.8 11 4.2 15 1.3 14Z'}[weapon_id]
  E.SubElement(parent,ns+'path',{'d':shape,'transform':f'translate(0 {y})','fill':'#202527','stroke':'#111819','stroke-width':'.6'})

def mag_offset(t):
 if t<.18:return 0
 if t<.4:return 11*(t-.18)/.22
 if t<.55:return 11
 if t<.8:return 11*(1-(t-.55)/.25)
 return 0

def support_target(t,normal,origin,mat,w,belt):
 import numpy as np
 if w=='pump_shotgun' or not 0<t<1:return normal
 grip={'ak_rifle':[22,16],'uzi_smg':[15,18],'pistol':[3,13]}[w]
 target=origin+mat@np.array([grip[0],grip[1]+mag_offset(t)])
 def mix(a,b,u):u=max(0,min(1,u));u=u*u*(3-2*u);return a*(1-u)+b*u
 if t<.18:return mix(normal,target,t/.18)
 if t<.4:return target
 if t<.475:return mix(target,np.array(belt), (t-.4)/.075)
 if t<.55:return mix(np.array(belt),target,(t-.475)/.075)
 if t<.8:return target
 return mix(target,normal,(t-.8)/.2)
