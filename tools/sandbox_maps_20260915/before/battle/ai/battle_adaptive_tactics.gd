extends RefCounted
# Reactive force intent. Explicit commands and individual player orders always win.
const Strength=preload("res://battle/ai/battle_relative_strength.gd")
const CONFIRM_SECONDS=2.5
const MIN_POSTURE_SECONDS=5.
static func advance(b,delta: float):
 if delta<=0. or b.battle_phase!="active":return
 if not Strength.refresh(b):return
 var snapshot=b.strength_snapshot;var now=b.elapsed_time_seconds
 for id in b.get_sorted_tactical_force_ids():
  var force=b.get_tactical_force(id)
  # Matches the existing gameplay player-side contract: attackers are player controlled.
  if force.side_id==b.attacker_side_id or force.has_explicit_command:continue
  var share=float(snapshot.shares.get(force.side_id,.5));var hp=float(snapshot.health.get(force.side_id,0.))
  var m=b.strength_memory.get(id,{"candidate":"hold","since":now,"changed":-100.,"health":hp,"loss":-100.,"posture":"hold"})
  if hp<float(m.health)-.001:m.loss=now
  m.health=hp
  var desired="hold"
  if share>=.60 and now-float(m.loss)>=1.5:desired="push"
  elif share<=.34:desired="fall_back"
  elif str(m.posture)=="push" and share>=.53:desired="push"
  elif str(m.posture)=="fall_back" and share<=.42:desired="fall_back"
  if desired!=str(m.candidate):m.candidate=desired;m.since=now
  if desired!=str(m.posture) and now-float(m.since)>=CONFIRM_SECONDS and now-float(m.changed)>=MIN_POSTURE_SECONDS:
   m.posture=desired;m.changed=now;force.command_id=desired
   b.strength_events.append({"time":now,"force":id,"side":force.side_id,"order":desired,"share":share,"reason":"sustained_advantage" if desired=="push" else ("outmatched" if desired=="fall_back" else "advantage_lost")})
   if b.strength_events.size()>128:b.strength_events.pop_front()
  b.strength_memory[id]=m
  for p in b.participants.values():
   if p.tactical_force_id!=id or not p.is_alive or p.is_wounded or not p.player_tactical_intent.is_empty():continue
   if str(m.posture)!="hold" and (str(m.posture)=="fall_back" or may_advance(b,p)):
    p.set_defend_position(false);p.clear_defend_position_anchor()
static func autonomous_force(b,p) -> bool:
 var f=b.get_tactical_force(p.tactical_force_id)
 return f!=null and f.side_id!=b.attacker_side_id and not f.has_explicit_command and b.strength_memory.has(f.tactical_force_id)
static func may_advance(b,p) -> bool:
 if b.strength_snapshot.is_empty():return true
 var s=b.strength_snapshot
 var local_share=float(s.local.get(p.participant_id,.5))
 var hostiles=0
 for side in s.living:
  if side!=p.side_id:hostiles+=int(s.living[side])
 return local_share>=.48 and (int(s.support.get(p.participant_id,0))>0 or hostiles<=1)
static func permits_counterattack(b,p) -> bool:
 if not autonomous_force(b,p) or p.is_wounded:return false
 var f=b.get_tactical_force(p.tactical_force_id)
 return f.command_id=="push" and may_advance(b,p)
