class_name VehicleModelCatalog
extends RefCounted
const PATH="res://assets/data/vehicle_models.json"
const ART="res://assets/art/vehicles/fleet/"
const DIRECTIONS=["e","se","s","sw","w","nw","n","ne"]
static var _data: Dictionary={}
static var _textures: Dictionary={}
static func data() -> Dictionary:
	if _data.is_empty():
		var parsed: Variant=JSON.parse_string(FileAccess.get_file_as_string(PATH))
		if parsed is Dictionary:_data=parsed
	return _data
static func all_ids() -> Array:
	return data().get("models",{}).keys()
static func has_model(id: String) -> bool:
	return data().get("models",{}).has(id)
static func model(id: String) -> Dictionary:
	# Preserve old campaign saves without rewriting their explicit travel/capacity stats.
	var key="bayou" if id=="car" else id
	return data().get("models",{}).get(key,{})
static func preferences(faction_id: String) -> Array:
	return data().get("faction_preferences",{}).get(faction_id,[])
static func class_name_for(id: String) -> String:
	return str(data().get("classes",{}).get(id,{}).get("name",id))
static func texture(path: String) -> Texture2D:
	if _textures.has(path):return _textures[path]
	if not FileAccess.file_exists(path):return null
	var im=Image.new()
	if im.load_png_from_buffer(FileAccess.get_file_as_bytes(path))!=OK:return null
	var result=ImageTexture.create_from_image(im);_textures[path]=result
	return result
static func icon(id: String) -> Texture2D:
	var m=model(id)
	return null if m.is_empty() else texture(ART+"icons/"+str(m.id)+".png")
static func direction_for(facing: Vector2) -> String:
	return DIRECTIONS[posmod(roundi(facing.angle()/(PI/4.)),8)]
static func sprite(id: String,facing: Vector2,door_open: float=0.) -> Texture2D:
	var m=model(id)
	if m.is_empty():return null
	var phase=0 if int(m.doors)==0 else clampi(roundi(door_open*2.),0,2)
	return texture(ART+"sprites/%s_%s_%d.png"%[m.id,direction_for(facing),phase])
static func convoy(models: Array,required_units: int=0) -> Dictionary:
	if required_units>0 and models.size()>required_units:return {"valid":false,"error":"Each vehicle needs a unit to drive it."}
	var seats=0;var cargo=0;var cost=0;var upkeep=0.;var movement=INF
	for id in models:
		var m=model(str(id))
		if m.is_empty():return {"valid":false,"error":"Unknown vehicle: "+str(id)}
		seats+=int(m.unit_capacity);cargo+=int(m.resource_capacity);cost+=int(m.price)
		upkeep+=float(m.upkeep_per_turn);movement=minf(movement,float(m.movement_per_turn))
	return {"valid":not models.is_empty() and seats>=required_units,"units":seats,"cargo":cargo,"price":cost,"upkeep":upkeep,"movement":0. if models.is_empty() else movement,"error":"Choose enough seats for %d units."%required_units if seats<required_units else ""}
