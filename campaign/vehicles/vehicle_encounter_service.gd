class_name VehicleEncounterService
extends RefCounted
## Stateful encounter rules used by the sandbox lab. World event generation is separate.
const Models=preload("res://campaign/vehicles/vehicle_model_catalog.gd")
var data: Dictionary={"version":1,"turn":0,"journeys":{},"claims":{},"resources":{},"cash":{},"accounts":{},"locations":{},"prisons":{},"heat":{},"battle_uses":{},"driveby_uses":{},"roads":[]}
func to_dict() -> Dictionary:return data.duplicate(true)
func from_dict(saved: Dictionary) -> bool:
	if int(saved.get("version",0))!=1:return false
	for key in ["journeys","claims","resources","cash","accounts","locations","prisons","heat","battle_uses"]:
		if not saved.get(key) is Dictionary:return false
	if int(saved.get("turn",-1))<0:return false
	if not saved.get("driveby_uses",{}) is Dictionary or not saved.get("roads",[]) is Array:return false
	data=saved.duplicate(true);data.turn=int(data.turn);data["driveby_uses"]=data.get("driveby_uses",{});data["roads"]=data.get("roads",[]);return true
func result(ok: bool,message: String,extra: Dictionary={}) -> Dictionary:
	var r={"success":ok,"message":message};r.merge(extra,true);return r
func start_journey(id: String,owner: String,vehicles: Array) -> Dictionary:
	if id.is_empty() or owner.is_empty() or vehicles.is_empty() or data.journeys.has(id):return result(false,"Journey must be new and have an owner and vehicles.")
	var seen_units={};var seen_vehicles={}
	for v in vehicles:
		if not v is Dictionary:return result(false,"Invalid vehicle manifest.")
		var key=str(v.get("id",""));var m=Models.model(str(v.get("model","")));var units=v.get("occupants",[])
		if key.is_empty() or seen_vehicles.has(key) or m.is_empty() or not units is Array or units.is_empty() or units.size()>int(m.unit_capacity):return result(false,"Every vehicle needs a unique ID and valid crew seats.")
		for j in data.journeys.values():
			if not j.get("closed",false) and j.vehicles.has(key):return result(false,"Vehicle already has an active journey.")
		for u in units:
			if str(u).is_empty() or seen_units.has(str(u)):return result(false,"An occupant cannot be assigned twice.")
			seen_units[str(u)]=true
		seen_vehicles[key]={"model":m.id,"occupants":units.duplicate(),"jammer":false,"ended_turn":-1,"road_node":str(v.get("road_node","")),"movement_left":float(m.movement_per_turn)}
	data.journeys[id]={"owner":owner,"vehicles":seen_vehicles,"used":{},"closed":false}
	return result(true,"Journey manifest registered.")
func vehicle(journey: String,id: String,ability: String="") -> Dictionary:
	var j=data.journeys.get(journey,{})
	if j.is_empty() or j.get("closed",false):return {}
	var v=j.vehicles.get(id,{})
	if v.is_empty() or (not ability.is_empty() and Models.model(v.model).get("ability_id","")!=ability):return {}
	return v
func can_move(journey: String,id: String) -> bool:
	var v=vehicle(journey,id);return not v.is_empty() and int(v.ended_turn)!=int(data.turn) and float(v.get("movement_left",Models.model(v.model).movement_per_turn))>0.
func once(journey: String,key: String) -> bool:
	if data.journeys[journey].used.has(key):return false
	data.journeys[journey].used[key]=true;return true
func scout(journey: String,id: String,from: String,target: String,roads: Array,encounters: Dictionary) -> Dictionary:
	if vehicle(journey,id,"forward_eye").is_empty() or not can_move(journey,id):return result(false,"An available Wraith Zero is required.")
	var linked=false
	for e in roads:
		if e.get("kind","")=="road" and e.get("from")==from and e.get("to")==target:linked=true
	if not linked:return result(false,"Scout one directly connected road location.")
	var info=encounters.get(target,{})
	return result(true,"Forward Eye revealed the next road location.",{"location":target,"blockade":info.get("blockade","none"),"units":int(info.get("units",0)),"vehicles":int(info.get("vehicles",0))})
func set_jammer(journey: String,id: String,enabled: bool) -> Dictionary:
	var v=vehicle(journey,id,"ghost_channel")
	if v.is_empty():return result(false,"Eidolon GT is required.")
	v.jammer=enabled;return result(true,"Ghost Channel active." if enabled else "Ghost Channel inactive.")
func stop(journey: String,id: String,kind: String) -> Dictionary:
	var v=vehicle(journey,id)
	if v.is_empty():return result(false,"Unknown active vehicle.")
	var ability=Models.model(v.model).get("ability_id","");var scoped={"vehicle":id,"occupants":v.occupants.duplicate(),"heat_added":0}
	if kind=="routine_police" and ability=="ghost_channel" and v.jammer:return result(true,"Routine police stop avoided; other convoy vehicles remain exposed.",scoped)
	if kind=="mobile_interception" and ability=="breakaway" and can_move(journey,id) and once(journey,"breakaway"):
		v.ended_turn=data.turn;return result(true,"Breakaway succeeded. This vehicle has no movement left this turn.",scoped)
	if kind=="light_blockade" and ability=="breach_charge" and can_move(journey,id) and once(journey,"breach_charge"):
		var owner=data.journeys[journey].owner;data.heat[owner]=float(data.heat.get(owner,0))+25.;scoped.heat_added=25
		return result(true,"Light blockade breached; 25 heat added.",scoped)
	return result(false,"Vehicle is stopped. Resolve the encounter normally.",scoped)
func flank(journey: String,id: String,entry: String,entries: Dictionary) -> Dictionary:
	var v=vehicle(journey,id,"flanking_arrival");var e=entries.get(entry,{})
	if v.is_empty() or not e.get("road_connected",false) or not e.get("legal",false) or e.get("occupied",true):return result(false,"Asterion requires a free, legal, road-connected entrance.")
	return result(true,"Alternate arrival reserved for Asterion occupants.",{"entry":entry,"occupants":v.occupants.duplicate()})
func cross_country(journey: String,ids: Array,edge: Dictionary) -> Dictionary:
	if not edge.get("designated",false) or edge.get("kind","") not in ["dirt","wilderness"] or ids.is_empty():return result(false,"Only designated dirt and wilderness connections qualify.")
	var occupants=[]
	for id in ids:
		var v=vehicle(journey,str(id),"cross_country")
		if v.is_empty() or not can_move(journey,str(id)):return result(false,"Split off vehicles that cannot use this connection.")
		occupants.append_array(v.occupants)
	return result(true,"Cross-country connection available to this group.",{"occupants":occupants})
func recover(journey: String,id: String,battle_id: String,unit: Dictionary,in_zone: bool,secure: bool) -> Dictionary:
	var v=vehicle(journey,id,"life_support")
	if v.is_empty() or battle_id.is_empty() or not v.occupants.has(unit.get("id")) or not in_zone or not secure or unit.get("status","")!="critical" or float(unit.get("hp",0))<=0:return result(false,"Recovery needs a living critical occupant in a secure extraction zone.")
	var use_key=str(data.journeys[journey].owner)+":"+battle_id
	if data.battle_uses.has(use_key):return result(false,"Life Support already used in this battle.")
	data.battle_uses[use_key]=true
	unit.status="wounded";unit.available=false;unit.evacuated=true
	return result(true,"Occupant evacuated alive; recovery is required before service.",{"unit":unit.duplicate(true)})
func dispatch_resources(id: String,journey: String,vehicle_id: String,origin: String,manifest: Dictionary) -> Dictionary:
	var v=vehicle(journey,vehicle_id,"bonded_cargo");var source=data.locations.get(origin,{})
	if id.is_empty() or data.resources.has(id) or v.is_empty() or source.get("owner","")!=data.journeys[journey].owner or manifest.is_empty():return result(false,"A new bonded shipment needs Palisade and an owned departure location.")
	for shipment in data.resources.values():
		if shipment.get("vehicle")==vehicle_id and shipment.status=="in_transit":return result(false,"Vehicle already carries a shipment.")
	var total=0.
	for key in manifest:
		var amount=float(manifest[key]);total+=amount
		if str(key).is_empty() or not is_finite(amount) or amount<=0 or float(source.get("stock",{}).get(key,0))<amount:return result(false,"Manifest exceeds available source stock.")
	if total>float(Models.model(v.model).resource_capacity):return result(false,"Manifest exceeds cargo capacity.")
	for key in manifest:source.stock[key]=float(source.stock[key])-float(manifest[key])
	data.resources[id]={"origin":origin,"owner":source.owner,"vehicle":vehicle_id,"cargo":manifest.duplicate(true),"status":"in_transit"}
	return result(true,"Bonded cargo debited from origin and sealed.")
func lose_bonded(id: String) -> Dictionary:
	var s=data.resources.get(id,{})
	if s.is_empty() or s.status!="in_transit":return result(false,"Shipment is not available for loss resolution.")
	s.status="claim_pending";data.claims[id]={"due":int(data.turn)+2,"paid":false}
	return result(true,"Cargo denied to captor. Replacement due in two turns.",{"enemy_loot":{},"vehicle_captured":true})
func deliver_resources(id: String,destination: String) -> Dictionary:
	var s=data.resources.get(id,{});var target=data.locations.get(destination,{})
	if s.is_empty() or s.status!="in_transit" or target.get("owner","")!=s.owner:return result(false,"Shipment must be in transit and destination owned.")
	for key in s.cargo:target.stock[key]=float(target.stock.get(key,0))+float(s.cargo[key])
	s.status="delivered";return result(true,"Sealed cargo delivered once.")
func advance_turn() -> Array:
	data.turn=int(data.turn)+1;var paid=[]
	for j in data.journeys.values():
		if j.get("closed",false):continue
		for v in j.vehicles.values():v.movement_left=float(Models.model(v.model).movement_per_turn)
	for id in data.claims:
		var claim=data.claims[id];var shipment=data.resources[id];var target=data.locations.get(shipment.origin,{})
		if claim.paid or int(claim.due)>int(data.turn) or target.get("owner","")!=shipment.owner:continue
		for key in shipment.cargo:target.stock[key]=float(target.stock.get(key,0))+float(shipment.cargo[key])
		claim.paid=true;shipment.status="replaced";paid.append(id)
	return paid
func dispatch_cash(id: String,model_id: String,source: String,destination: String,amount: float) -> Dictionary:
	var m=Models.model(model_id)
	if id.is_empty() or data.cash.has(id) or m.get("service_role","")!="bank_cash" or not is_finite(amount) or amount<=0 or amount>float(m.get("cash_capacity",0)):return result(false,"Invalid cash truck or cash capacity.")
	if source==destination or not data.accounts.has(source) or not data.accounts.has(destination) or float(data.accounts[source])<amount:return result(false,"Shipment needs funded source and existing destination accounts.")
	data.accounts[source]=float(data.accounts[source])-amount
	data.cash[id]={"source":source,"destination":destination,"amount":amount,"model":model_id,"status":"in_transit"}
	return result(true,"Cash removed from source and loaded into the independent truck.")
func settle_cash(id: String,captor: String="",battle_won: bool=false) -> Dictionary:
	var s=data.cash.get(id,{})
	if s.is_empty() or s.status!="in_transit":return result(false,"Shipment already resolved or missing.")
	if not captor.is_empty() and (not battle_won or not data.accounts.has(captor)):return result(false,"A victorious interceptor and existing account are required.")
	var target=s.destination if captor.is_empty() else captor
	data.accounts[target]=float(data.accounts[target])+float(s.amount);s.status="delivered" if captor.is_empty() else "stolen"
	return result(true,"Cash credited once to "+target+".",{"amount":s.amount,"recipient":target})
func dispatch_prisoners(id: String,prisoners: Array,guards: int=3) -> Dictionary:
	if id.is_empty() or data.prisons.has(id) or guards<1 or guards>3 or prisoners.is_empty() or prisoners.size()>8:return result(false,"Custodian accepts 1-3 guards and 1-8 prisoners.")
	var seen={}
	for p in prisoners:
		if not p is Dictionary or str(p.get("id","")).is_empty() or seen.has(p.id) or str(p.get("allegiance","")).is_empty():return result(false,"Prisoners need unique IDs and existing allegiances.")
		seen[p.id]=true
	data.prisons[id]={"prisoners":prisoners.duplicate(true),"guards":guards,"status":"in_transit"}
	return result(true,"Prisoner manifest registered separately from guard seats.")
func rescue_prisoners(id: String,rescuer: String,battle_won: bool) -> Dictionary:
	var s=data.prisons.get(id,{})
	if s.is_empty() or s.status!="in_transit" or rescuer.is_empty() or not battle_won:return result(false,"A successful interception is required.")
	var freed=[]
	for p in s.prisoners:
		if not p.get("alive",true):continue
		var unit=p.duplicate(true);unit.status="freed";unit.returns_to=unit.allegiance;freed.append(unit)
	s.status="rescued";return result(true,"Surviving prisoners freed; original allegiances retained.",{"freed":freed,"auto_recruited":0})

func travel_road(journey: String,id: String,destination: String) -> Dictionary:
	var v=vehicle(journey,id)
	if v.is_empty() or not can_move(journey,id):return result(false,"Vehicle has no movement available.")
	var source=str(v.get("road_node",""));var cost=-1.
	for edge in data.roads:
		if edge.get("kind","")=="road" and edge.get("from","")==source and edge.get("to","")==destination:
			cost=float(edge.get("distance",-1));break
	var remaining=float(v.get("movement_left",Models.model(v.model).movement_per_turn))
	if source.is_empty() or destination==source or not is_finite(cost) or cost<=0. or cost>remaining:return result(false,"A connected road within the remaining movement budget is required.")
	v.road_node=destination;v.movement_left=maxf(0.,remaining-cost)
	return result(true,"Road movement completed.",{"road_node":destination,"distance_spent":cost,"movement_remaining":v.movement_left})
func drive_by(journey: String,id: String,target_id: String) -> Dictionary:
	var v=vehicle(journey,id,"drive_by");var target=data.locations.get(target_id,{})
	if v.is_empty() or int(v.ended_turn)==int(data.turn):return result(false,"An available drive-by vehicle is required.")
	var m=Models.model(v.model);var owner=str(data.journeys[journey].owner)
	if v.occupants.size()<int(m.drive_by_min_crew):return result(false,"Drive-By requires a driver and at least one passenger unit.")
	if target.is_empty() or target.get("kind","") not in ["business","building"] or target.get("status","")!="operational":return result(false,"Target must be an intact business or building.")
	if str(target.get("owner","")).is_empty() or target.owner==owner:return result(false,"Friendly and unowned locations are not valid raid targets.")
	if target.get("defenders",-1)!=0:return result(false,"Defenders present or defense state unknown. Resolve a normal battle.")
	if str(v.get("road_node","")).is_empty() or target.get("road_node","")!=v.road_node:return result(false,"Reach the target's connected roadside location first.")
	var use_key=id+":"+str(int(data.turn))
	if data.driveby_uses.has(use_key):return result(false,"This vehicle has already performed its drive-by this turn.")
	var remaining=float(v.get("movement_left",m.movement_per_turn))
	if not is_finite(remaining) or remaining<0.:return result(false,"Invalid movement budget.")
	data.driveby_uses[use_key]=target_id;target.status="destroyed";target.hp=0;target.income_active=false;target.production_active=false
	data.heat[owner]=float(data.heat.get(owner,0))+float(m.drive_by_heat)
	return result(true,"Undefended target destroyed. Remaining movement retained.",{"target":target_id,"movement_remaining":remaining,"heat_added":int(m.drive_by_heat),"loot":{},"territory_captured":false,"turn_ended":false})
