extends RefCounted
# Slot packing changes faction logistics only. Every vehicle keeps its own
# capacity, driver, cost and collision body; it never becomes a composite car.
const Models=preload("res://campaign/vehicles/vehicle_model_catalog.gd")
static func motorcycle(id: String) -> bool:
 var m=Models.model(id)
 return m.get("vehicle_class","")=="two_wheelers" and m.get("body","")!="bicycle"
static func two_wheeler(id: String) -> bool:
 return Models.model(id).get("vehicle_class","")=="two_wheelers"
static func two_wheelers_per_slot(faction_id: String) -> int:
 return 4 if faction_id in ["stateline","blacktop","zangyaku","bitian","nbpd","trc"] else 2
static func packs_motorcycles(faction_id: String) -> bool:
 return two_wheelers_per_slot(faction_id)>1
static func slots(models: Array,faction_id: String) -> Array:
 var result=[]
 for i in range(models.size()):
  var pack=two_wheeler(str(models[i]))
  var placed=false
  if pack:
   for group in result:
    if group.motorcycles and group.indices.size()<two_wheelers_per_slot(faction_id):
     group.indices.append(i);placed=true;break
  if not placed:result.append({"indices":[i],"motorcycles":pack})
 return result
static func bed_capacity(model_id: String) -> int:
 return 2 if Models.model(model_id).get("body","") in ["pickup","crew_pickup"] else 0
static func manifest(models: Array,count: int,chosen: Array=[]) -> Dictionary:
 if not Models.convoy(models,count).valid:return {"valid":false,"error":"Convoy needs a driver per vehicle and a seat for every unit."}
 var rows=[]
 if not chosen.is_empty():
  if chosen.size()!=models.size():return {"valid":false,"error":"Passenger assignments must match the convoy vehicles."}
  var total=0
  for i in range(chosen.size()):
   if not chosen[i] is Dictionary:return {"valid":false,"error":"Invalid passenger assignment."}
   var n=chosen[i].get("units",0);var bed=chosen[i].get("bed",0)
   if not (n is int or n is float) or not (bed is int or bed is float):return {"valid":false,"error":"Passenger counts must be whole numbers."}
   if not is_finite(float(n)) or not is_finite(float(bed)) or float(n)!=float(int(n)) or float(bed)!=float(int(bed)):return {"valid":false,"error":"Passenger counts must be whole numbers."}
   if n<1 or n>int(Models.model(models[i]).unit_capacity) or bed<0 or bed>bed_capacity(models[i]) or bed>=n:return {"valid":false,"error":"Invalid capacity, driver or pickup-bed assignment."}
   total+=int(n);rows.append({"units":int(n),"bed":int(bed)})
  if total!=count:return {"valid":false,"error":"Passenger assignments must account for every unit exactly once."}
 else:
  for _id in models:rows.append({"units":1,"bed":0})
  var remaining=count-models.size()
  # Fill enclosed transport before pillion seats; each bike still has a driver.
  var order=[]
  for i in range(models.size()):
   if not motorcycle(models[i]):order.append(i)
  for i in range(models.size()):
   if motorcycle(models[i]):order.append(i)
  for i in order:
   var added=mini(remaining,int(Models.model(models[i]).unit_capacity)-1)
   rows[i].units+=added;remaining-=added
  for i in range(models.size()):rows[i].bed=mini(bed_capacity(models[i]),maxi(0,rows[i].units-1))
 return {"valid":true,"rows":rows,"error":""}
