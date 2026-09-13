extends RefCounted
## Stored checkpoint duties. No automatic victories, loot, or world event generation.
const Models=preload("res://campaign/vehicles/vehicle_model_catalog.gd")
static func active_post(s,journey: String,id: String,ability: String="") -> Dictionary:
 var v=s.vehicle(journey,id,ability)
 if v.is_empty() or v.occupants.size()<2 or not str(v.get("encounter","")).is_empty():return {}
 var post=s.data.blockades.get(v.get("post",""),{})
 if post.get("status","")!="active" or post.get("owner","")!=s.data.journeys[journey].owner or post.get("road_node","")!=v.get("road_node",""):return {}
 return post
static func station(s,journey: String,id: String,blockade: String) -> Dictionary:
 var v=s.vehicle(journey,id);var post=s.data.blockades.get(blockade,{})
 if v.is_empty() or Models.model(v.model).get("ability_id","") not in ["lockdown","pursuit_net"]:return s.result(false,"A Roadwarden or Bloodhound is required.")
 if not s.can_move(journey,id) or not str(v.get("post","")).is_empty() or v.occupants.size()<2 or float(v.movement_left)<1.:return s.result(false,"Stationing needs two crew and one movement point.")
 if post.get("status","")!="active" or post.get("strength","") not in ["light","fortified"] or str(post.get("road_node","")).is_empty() or post.get("owner","")!=s.data.journeys[journey].owner or post.road_node!=v.get("road_node",""):return s.result(false,"Reach an active owned blockade before deploying.")
 v.post=blockade;v.movement_left-=1.
 return s.result(true,"Vehicle stationed. One movement point spent.",{"post":blockade,"strength":strength(s,blockade)})
static func withdraw(s,journey: String,id: String) -> Dictionary:
 var v=s.vehicle(journey,id)
 if v.is_empty() or str(v.get("post","")).is_empty() or not str(v.get("encounter","")).is_empty():return s.result(false,"No available stationed vehicle.")
 v.post="";v.ended_turn=int(s.data.turn)
 return s.result(true,"Post withdrawn. Support removed; movement resumes next turn.")
static func strength(s,blockade: String) -> String:
 var p=s.data.blockades.get(blockade,{})
 if p.get("status","")!="active":return "inactive"
 if p.get("strength","")=="fortified":return "fortified"
 for j in s.data.journeys:
  for id in s.data.journeys[j].vehicles:
   var v=s.vehicle(j,id,"lockdown")
   if not v.is_empty() and v.get("post","")==blockade and not active_post(s,j,id,"lockdown").is_empty():return "fortified"
 return "light"
static func cover_count(s,blockade: String) -> int:
 for j in s.data.journeys:
  for id in s.data.journeys[j].vehicles:
   var v=s.vehicle(j,id,"lockdown")
   if not v.is_empty() and v.get("post","")==blockade and not active_post(s,j,id,"lockdown").is_empty():return 2
 return 0
static func road_cost(s,source: String,target: String) -> float:
 for e in s.data.roads:
  if e.get("kind","")=="road" and e.get("from","")==source and e.get("to","")==target:
   var cost=float(e.get("distance",-1.))
   if is_finite(cost) and cost>0.:return cost
 return -1.
static func stop_at(s,journey: String,id: String,blockade: String) -> Dictionary:
 var v=s.vehicle(journey,id);var p=s.data.blockades.get(blockade,{})
 if v.is_empty() or p.get("status","")!="active" or p.get("owner","")==s.data.journeys[journey].owner or v.get("road_node","")!=p.get("road_node",""):return s.result(false,"An active enemy blockade at this road node is required.")
 var power=strength(s,blockade);var stopped=s.stop(journey,id,"fortified_blockade" if power=="fortified" else "light_blockade")
 stopped["battle_required"]=not stopped.success;stopped["blockade_strength"]=power;stopped["cover_barriers"]=cover_count(s,blockade)
 return stopped
static func pursue(s,journey: String,id: String,target_journey: String) -> Dictionary:
 var post=active_post(s,journey,id,"pursuit_net");var v=s.vehicle(journey,id,"pursuit_net");var target=s.data.journeys.get(target_journey,{})
 if post.is_empty() or target.is_empty() or target.get("closed",false) or target.owner==s.data.journeys[journey].owner or target.vehicles.is_empty():return s.result(false,"A stationed Bloodhound and an active hostile convoy are required.")
 var key=id+":"+str(int(s.data.turn))
 if s.data.pursuit_uses.has(key) or int(v.ended_turn)==int(s.data.turn):return s.result(false,"Pursuit Net is already spent this turn.")
 var node="";var crew=[];var models=[]
 for target_id in target.vehicles:
  var tv=s.vehicle(target_journey,target_id)
  if tv.is_empty() or tv.occupants.is_empty() or not str(tv.get("encounter","")).is_empty() or not str(tv.get("post","")).is_empty():return s.result(false,"Convoy is unavailable or already in battle.")
  if node.is_empty():node=str(tv.get("road_node",""))
  if node.is_empty() or tv.get("road_node","")!=node:return s.result(false,"Target convoy must be together at one road node.")
  crew.append_array(tv.occupants);models.append(tv.model)
 var cost=road_cost(s,v.road_node,node)
 if node==v.road_node or cost<=0. or cost>float(v.movement_left):return s.result(false,"The target must be one connected road away within remaining movement.")
 var encounter="pursuit_"+id+"_"+str(int(s.data.turn));var origin=str(v.post)
 s.data.pursuit_uses[key]=true;v.movement_left-=cost;v.road_node=node;v.post="";v.encounter=encounter;v.ended_turn=int(s.data.turn)
 for tv in target.vehicles.values():tv.encounter=encounter;tv.ended_turn=int(s.data.turn)
 s.data.blockade_encounters[encounter]={"status":"pending","kind":"pursuit","road_node":node,"origin_post":origin,"attacker_owner":s.data.journeys[journey].owner,"defender_owner":target.owner,"attacker_journey":journey,"attacker_vehicle":id,"attacker_crew":v.occupants.duplicate(),"defender_journey":target_journey,"defender_crew":crew,"defender_models":models,"winner":"","loot":{}}
 return s.result(true,"Pursuit battle required. Bloodhound left its post and paid road movement.",{"battle_required":true,"encounter_id":encounter,"movement_remaining":v.movement_left,"automatic_victory":false})
static func finish_pursuit(s,encounter: String,winner: String,survivors: Dictionary) -> Dictionary:
 var e=s.data.blockade_encounters.get(encounter,{})
 if e.get("status","")!="pending" or winner not in [e.get("attacker_owner",""),e.get("defender_owner","")]:return s.result(false,"Pending encounter and valid winner required.")
 var manifests={};var ids={}
 for j in [e.attacker_journey,e.defender_journey]:
  for id in s.data.journeys[j].vehicles:
   var v=s.data.journeys[j].vehicles[id]
   if v.get("encounter","")==encounter:manifests[id]=v
 if survivors.size()!=manifests.size():return s.result(false,"Battle result must include every involved vehicle.")
 for id in manifests:
  if not survivors.get(id) is Array:return s.result(false,"Missing survivor manifest.")
  for u in survivors[id]:
   if ids.has(u) or not manifests[id].occupants.has(u):return s.result(false,"Invalid or duplicate survivor.")
   ids[u]=true
 for id in manifests:
  var v=manifests[id];v.occupants=survivors[id].duplicate();v.encounter="";v.ended_turn=int(s.data.turn);v.available=not v.occupants.is_empty()
 e.status="resolved";e.winner=winner
 return s.result(true,"Battle resolved. Survivors retained; movement stays ended. No automatic cargo award.")
