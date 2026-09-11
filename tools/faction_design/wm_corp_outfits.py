"""W&M Corporation combines intact family wardrobes by role."""
import mcallister_outfits as mc
import whittaker_outfits as wh
rig,outfits,directions,build=mc.rig,mc.outfits,mc.directions,mc.build
N,path,xy,BASE,np=mc.N,mc.path,mc.xy,mc.BASE,mc.np
KIND=1
TITLE='WHITTAKER-MCALLISTER CORP.'
PREFIX='wm_corp'
BLUE=('#a29475',)
ORIGINS={'pistol':mc,'smg':wh,'shotgun':wh,'rifle':mc,'sniper':wh}
SPECS={r:m.SPECS[r] for r,m in ORIGINS.items()}
DESCRIPTIONS={r:m.DESCRIPTIONS[r] for r,m in ORIGINS.items()}
NOTES={r:[('McAllister personnel' if m is mc else 'Whittaker personnel'),m.NOTES[r][1]] for r,m in ORIGINS.items()}
EXTRA_PALETTE=list(dict.fromkeys(mc.EXTRA_PALETTE+wh.EXTRA_PALETTE))
def make(role,model,direction,**state):
 family=ORIGINS[role]
 # Explicit dispatch prevents import order from selecting the other family's art.
 outfits.head=family.head
 outfits.torso=family.torso
 outfits.arm=family.arm
 outfits.forearm=family.forearm
 return family.make(role,model,direction,**state)
