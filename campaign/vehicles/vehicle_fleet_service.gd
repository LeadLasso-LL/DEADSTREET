class_name VehicleFleetService
extends RefCounted
const Models=preload("res://campaign/vehicles/vehicle_model_catalog.gd")
const VehicleData=preload("res://campaign/vehicles/vehicle.gd")
static func create(id: String,faction: String,model_id: String) -> Vehicle:
	if id.is_empty() or not Models.has_model(model_id):return null
	var m=Models.model(model_id)
	return VehicleData.new(id,faction,model_id,"",int(m.unit_capacity),float(m.movement_per_turn),float(m.upkeep_per_turn))
static func purchase(state: GameState,faction_id: String,stronghold_id: String,model_id: String) -> Dictionary:
	if state==null or not Models.has_model(model_id):return {"success":false,"error":"Unknown vehicle"}
	var faction=state.get_faction(faction_id)
	var home=state.get_map_location(stronghold_id)
	if not faction is MajorGang or not home is Stronghold or home.owner_faction_id!=faction_id:return {"success":false,"error":"A faction-owned stronghold is required"}
	var m=Models.model(model_id)
	if m.get("service_only",false):return {"success":false,"error":"Independent service vehicle; available for sandbox encounters only."}
	if faction.money<float(m.price):return {"success":false,"error":"Insufficient funds"}
	var suffix=state.vehicles.size();var id="fleet_%s_%d"%[model_id,suffix]
	while state.has_vehicle(id):suffix+=1;id="fleet_%s_%d"%[model_id,suffix]
	var vehicle=create(id,faction_id,model_id)
	state.add_vehicle(vehicle)
	if not state.has_vehicle(id):return {"success":false,"error":"Could not register vehicle"}
	if not state.assign_vehicle_to_stronghold(id,stronghold_id):
		state.vehicles.erase(id)
		return {"success":false,"error":"Could not park vehicle"}
	faction.money-=float(m.price)
	return {"success":true,"vehicle_id":id}
static func load_resource(vehicle: Vehicle,source: ResourceStore,resource_id: String,amount: float) -> bool:
	if vehicle==null or source==null or resource_id.is_empty() or not is_finite(amount) or amount<=0.:return false
	if vehicle.resource_capacity<=0 or vehicle.cargo_amount()+amount>vehicle.resource_capacity:return false
	if source.get_amount(resource_id)<amount:return false
	if not source.remove(resource_id,amount):return false
	vehicle.cargo.add(resource_id,amount)
	return true
static func unload_resource(vehicle: Vehicle,destination: ResourceStore,resource_id: String,amount: float) -> bool:
	if vehicle==null or destination==null or resource_id.is_empty() or not is_finite(amount) or amount<=0.:return false
	if not vehicle.cargo.remove(resource_id,amount):return false
	destination.add(resource_id,amount)
	return true
