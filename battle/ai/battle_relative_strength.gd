extends RefCounted
# Observational fighting capability, not win probability. Never consumes combat RNG.
const Weapons=preload("res://battle/combat/battle_weapon_catalog.gd")
const Vitality=preload("res://battle/combat/battle_combat_consequence_service.gd")
const INTERVAL=.5
static func unit_power(p) -> float:
 if p==null or not p.is_alive or not p.has_battle_position:return 0.
 var w=Weapons.for_participant(p)
 if w==null:return 0.
 var trauma=w.graze_probability*w.graze_trauma+w.solid_probability*w.solid_trauma+w.critical_probability*w.critical_trauma
 var firing_time=float(w.magazine_capacity)/maxf(w.shots_per_second,.01)
 var sustained=float(w.magazine_capacity)*trauma/maxf(firing_time+w.reload_seconds,.01)
 var health=clampf(p.vitality/Vitality.BASELINE_VITALITY,0.,1.)
 var readiness=.82 if p.weapon_state!=null and (p.weapon_state.is_reloading or p.weapon_state.ammo_in_magazine==0) else 1.
 var protection=1.12 if p.has_occupied_cover_slot() else 1.
 return sqrt(maxf(.01,sustained))*(.8+.2*clampf(w.max_range/40.,0.,1.5))*sqrt(health)*(.5 if p.is_wounded else 1.)*readiness*protection
static func evaluate(b) -> Dictionary:
 var sides={};var units={};var living={};var health={}
 var ids=b.participants.keys();ids.sort()
 for id in ids:
  var p=b.get_participant(id);var power=unit_power(p);units[id]=power
  sides[p.side_id]=float(sides.get(p.side_id,0.))+power
  living[p.side_id]=int(living.get(p.side_id,0))+(1 if p.is_alive else 0)
  health[p.side_id]=float(health.get(p.side_id,0.))+(maxf(0.,p.vitality) if p.is_alive else 0.)
 var total=0.
 for power in sides.values():total+=float(power)
 var shares={}
 for side in sides:shares[side]=float(sides[side])/total if total>0.00001 else .5
 var local={};var support={}
 for id in ids:
  var p=b.get_participant(id);var allied=0.;var hostile=0.;var nearby=0
  for other_id in ids:
   var q=b.get_participant(other_id)
   if not q.is_alive or not q.has_battle_position:continue
   var distance=p.battle_position.distance_to(q.battle_position)
   var weight=clampf(1.-distance/32.,0.,1.)
   if q.side_id==p.side_id:
    allied+=float(units[other_id])*weight
    if other_id!=id and distance<=18.:nearby+=1
   else:hostile+=float(units[other_id])*weight
  local[id]=allied/(allied+hostile) if allied+hostile>.00001 else .5
  support[id]=nearby
 return {"sides":sides,"shares":shares,"units":units,"local":local,"support":support,"living":living,"health":health,"time":b.elapsed_time_seconds}
static func refresh(b,force: bool=false) -> bool:
 if not force and not b.strength_snapshot.is_empty() and b.elapsed_time_seconds<float(b.strength_snapshot.time)+INTERVAL:return false
 b.strength_snapshot=evaluate(b);return true
