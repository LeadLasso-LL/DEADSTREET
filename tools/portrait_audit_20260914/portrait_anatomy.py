"""Standing-card source adapter: continuous shoulder roots and whole support forearms.
No joint, torso, head, leg, weapon, or animation-atlas changes.
"""
from contextlib import contextmanager
import inspect
import build, outfits
_SOURCE=inspect.getsource(build.make)
assert _SOURCE.count('sleeve_start=support_elbow*.55+support_end*.45')==1
_SOURCE=_SOURCE.replace('sleeve_start=support_elbow*.55+support_end*.45','sleeve_start=support_elbow')
_SOURCE=_SOURCE.replace('outfits.forearm(up,sleeve_start,support_end,costume,skin,hi,2.8)','outfits.forearm(up,sleeve_start,support_end,costume,skin,hi,3.1)')
# Bare tank-top arms use the same open shoulder-root contour as clothed arms.
needle="  p(parent,f'M{xy(a+[.2,-1])}"
assert _SOURCE.count(needle)==1
_SOURCE=_SOURCE.replace(needle,"  list(parent)[-1].set('stroke','none')\n  p(parent,f'M{xy(outer)} Q{xy(a+v*6+n*3.7)} {xy(left)}','none','#090f12',.9)\n"+needle)
_NAMESPACE=dict(build.__dict__)
exec(compile(_SOURCE,__file__,'exec'),_NAMESPACE)
_CORRECTED=_NAMESPACE['make']
@contextmanager
def corrected(legacy=False):
 old_make,old_arm=build.make,outfits.arm
 if legacy:
  import eastex_outfits
  def joined(parent,a,b,h,c,skin,hi):
   return eastex_outfits.arm(parent,a,b,h,dict(c,new_unit=True,eastex=True),skin,hi)
  outfits.arm=joined
 build.make=_CORRECTED
 try:yield
 finally:build.make,outfits.arm=old_make,old_arm
