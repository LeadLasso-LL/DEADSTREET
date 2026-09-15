extends RefCounted
const Formation=preload("res://campaign/vehicles/convoy_formation_catalog.gd")
# Shared sandbox manifest: assigned before placement, so door routes and arrival
# riders refer to the same real participants instead of decorative extras.
static func apply(b,team: Dictionary) -> Dictionary:
 var units=[];var vehicles=[]
 for p in b.participants.values():
  if p.side_id==b.attacker_side_id:units.append(p)
 for v in b.vehicles.values():
  if v.side_id==b.attacker_side_id:vehicles.append(v)
 units.sort_custom(func(a,z):return a.participant_id<z.participant_id)
 vehicles.sort_custom(func(a,z):return a.battle_vehicle_id<z.battle_vehicle_id)
 var manifest=Formation.manifest(team.vehicles,units.size(),team.get("vehicle_occupants",[]))
 if not manifest.valid:return {"error":manifest.error}
 if vehicles.size()!=team.vehicles.size():return {"error":"Convoy vehicle count mismatch."}
 var groups=Formation.slots(team.vehicles,team.faction)
 for slot in range(groups.size()):
  var members=groups[slot].indices
  for member in range(members.size()):
   var v=vehicles[members[member]]
   v.set_meta("convoy_slot",slot);v.set_meta("convoy_member",member);v.set_meta("convoy_group_size",members.size())
 var cursor=0
 for i in range(vehicles.size()):
  var v=vehicles[i];var row=manifest.rows[i];var ids=[]
  for seat in range(row.units):
   var p=units[cursor];cursor+=1;p.transport_vehicle_id=v.battle_vehicle_id
   p.set_meta("transport_seat",seat)
   p.set_meta("transport_bed",seat>=row.units-row.bed)
   ids.append(p.participant_id)
  v.set_meta("convoy_occupants",ids)
 return {"valid":true,"slots":groups.size(),"manifest":manifest.rows}
