extends RefCounted
## One sandbox legality contract for buttons, auto-fit and final launch.
const Models=preload("res://campaign/vehicles/vehicle_model_catalog.gd")
const Formation=preload("res://campaign/vehicles/convoy_formation_catalog.gd")
const MAX_SLOTS=3
const MAX_UNITS=16
static func check(models: Array,count: int,faction: String,complete=true) -> Dictionary:
 if count<1 or count>MAX_UNITS:return {"valid":false,"error":"Choose 1–16 units.","badge":"UNIT LIMIT"}
 for id in models:
  if not id is String or not Models.has_model(id):return {"valid":false,"error":"Choose a valid vehicle.","badge":"UNAVAILABLE"}
 if models.size()>count:return {"valid":false,"error":"Each vehicle needs one of your units to drive it.","badge":"NEEDS DRIVER"}
 var groups=Formation.slots(models,faction)
 if groups.size()>MAX_SLOTS:return {"valid":false,"error":"Your convoy has three vehicle slots.","badge":"SLOTS FULL"}
 var seats=int(Models.convoy(models).get("units",0))
 if complete and (models.is_empty() or seats<count):return {"valid":false,"error":"Add seats for %d more units."%maxi(0,count-seats),"badge":"MORE SEATS"}
 if not complete:
  var possible=seats+(MAX_SLOTS-groups.size())*12
  if Formation.packs_motorcycles(faction):
   for group in groups:
    if group.motorcycles:possible+=(Formation.two_wheelers_per_slot(faction)-group.indices.size())*2
  if possible<count:return {"valid":false,"error":"This choice leaves too few seats within three slots.","badge":"TOO FEW SEATS"}
 return {"valid":true,"error":"","badge":"","seats":seats,"slots":groups.size()}
static func addition(models: Array,id: String,count: int,faction: String) -> Dictionary:
 var next=models.duplicate();next.append(id);return check(next,count,faction,false)
static func auto_fit(count: int,faction: String="") -> Array:
 if count<=12:
  var result=[]
  for i in range(ceili(count/4.)):result.append("bayou")
  return result
 # Two compact passenger shuttles carry sixteen without a fourth vehicle slot.
 if faction=="trc":return ["aegis","relay"]
 if faction=="nbpd":return ["shuttle","interceptor"]
 return ["shuttle","bayou"]
