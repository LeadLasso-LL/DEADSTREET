"""Authored game balance. Values are fictional tactical units, not firearm specifications."""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
# id, name, class, tier, movement, range, cadence, solid trauma, critical trauma,
# miss, graze, critical chance, acquire, recoil per shot, recoil recovery/sec
ROWS=[
('glock_17','Glock 17','pistol',1,1.24,24,2.5,.28,.70,.30,.30,.05,.22,.025,.18),
('m1911','Colt M1911A1','pistol',1,1.18,23,1.8,.37,.85,.31,.26,.06,.28,.05,.15),
('usp','HK USP','pistol',2,1.20,26,2.4,.34,.82,.24,.27,.07,.23,.025,.20),
('cz75','CZ 75 SP-01','pistol',2,1.16,26,2.7,.31,.78,.22,.27,.06,.29,.018,.23),
('desert_eagle','Desert Eagle','pistol',3,1.10,28,1.25,.65,1.50,.25,.22,.12,.38,.095,.14),
('five_seven','FN Five-seveN','pistol',3,1.25,30,2.8,.30,.86,.19,.27,.09,.18,.02,.25),
('uzi','IMI Uzi','smg',1,1.02,20,6,.16,.45,.42,.30,.02,.25,.024,.20),
('mac10','MAC-10','smg',1,1.13,17,8,.15,.40,.44,.29,.02,.20,.045,.18),
('mp5','HK MP5','smg',2,1.06,26,5.5,.19,.52,.30,.30,.04,.24,.021,.23),
('mp5k','HK MP5K','smg',2,1.18,19,6.5,.18,.48,.34,.30,.03,.17,.03,.22),
('vector','KRISS Vector','smg',3,1.04,23,9,.18,.54,.32,.29,.04,.20,.022,.27),
('p90','FN P90','smg',3,1.13,30,6.5,.17,.49,.25,.29,.05,.20,.018,.27),
('ak47','AK-47','rifle',1,.99,40,1.6,.42,.85,.25,.22,.08,.30,.065,.16),
('mini14','Ruger Mini-14','rifle',1,1.08,38,1.45,.37,.80,.22,.24,.08,.28,.04,.21),
('m4a1','M4A1','rifle',2,1.07,44,1.9,.43,.92,.21,.23,.09,.25,.04,.22),
('g36c','HK G36C','rifle',2,1.09,35,2.2,.40,.86,.23,.23,.08,.18,.038,.24),
('scar_h','FN SCAR-H','rifle',3,.94,49,1.6,.59,1.25,.20,.20,.12,.39,.085,.17),
('aug','Steyr AUG A3','rifle',3,1.01,46,2.05,.45,1.02,.17,.22,.10,.25,.033,.23),
('rem870','Remington 870','shotgun',1,1.02,12,1,.70,1.20,.36,.14,.15,.28,.08,.16),
('moss500','Mossberg 500 Cruiser','shotgun',1,1.16,9.5,1.05,.72,1.22,.39,.14,.14,.18,.09,.16),
('spas12','Franchi SPAS-12','shotgun',2,.89,14,1.35,.74,1.35,.33,.15,.16,.36,.085,.19),
('benelli_m2','Benelli M2 Tactical','shotgun',2,1.08,13,1.45,.68,1.25,.31,.16,.15,.23,.09,.21),
('benelli_m4','Benelli M4','shotgun',3,.98,15,1.55,.80,1.55,.28,.16,.18,.29,.06,.23),
('saiga12','Saiga-12','shotgun',3,.94,13.5,2.0,.75,1.40,.32,.17,.16,.30,.105,.19),
('rem700','Remington 700','sniper',1,.97,64,.42,.86,1.60,.15,.19,.25,1.35,.09,.17),
('sks','SKS with scope','sniper',1,.96,45,.85,.60,1.15,.24,.23,.16,.85,.065,.20),
('svd','Dragunov SVD','sniper',2,.93,64,.70,.86,1.65,.16,.19,.26,1.12,.075,.20),
('ssg69','Steyr SSG 69','sniper',2,.98,70,.43,1.03,1.85,.11,.16,.34,1.50,.09,.18),
('awm','Accuracy International AWM','sniper',3,.79,78,.38,1.30,2.10,.09,.14,.42,1.80,.12,.16),
('psg1','HK PSG1','sniper',3,.75,69,.70,.96,1.80,.11,.18,.31,1.45,.065,.22),
]
DEFAULTS={'pistol':'glock_17','smg':'uzi','rifle':'ak47','shotgun':'rem870','sniper':'rem700'}
ART={'pistol':'pistol','smg':'uzi_smg','rifle':'ak_rifle','shotgun':'pump_shotgun','sniper':'ak_rifle'}
RECOVERY={"desert_eagle":.09,"uzi":.11,"mp5":.10,"mp5k":.12,"vector":.19,"p90":.105,"ak47":.055,"m4a1":.06,"g36c":.055,"scar_h":.08,"aug":.062,"spas12":.085,"benelli_m2":.10,"benelli_m4":.082,"saiga12":.11,"sks":.032,"svd":.04,"psg1":.04}
MODELS={}
for r in ROWS:
 id,name,kind,tier,move,reach,rate,solid,critical,miss,graze,crit,aim,recoil,recover=r
 MODELS[id]=dict(id=id,name=name,weapon_class=kind,tier=tier,art_base=ART[kind],movement_multiplier=move,
  weight_burden=round((1.25-move)/.5,3),max_range=reach,shots_per_second=rate,solid_trauma=solid,
  critical_trauma=critical,graze_trauma=round(solid*.22,3),miss_probability=miss,graze_probability=graze,
  solid_probability=round(1-miss-graze-crit,4),critical_probability=crit,acquire_seconds=aim,
  recoil_per_shot=recoil,recoil_recovery=RECOVERY.get(id,recover),reacquire_seconds=round(aim*.75,3),
  balance_notes="Provisional game tuning; no per-model magazine capacity or reserve ammunition.")
data=dict(schema=1,status='provisional game balance',defaults=DEFAULTS,models=MODELS)
p=ROOT/'assets/data/weapon_models.json';p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(data,indent=2)+'\n')
print('Authored',len(MODELS),'weapon models')
