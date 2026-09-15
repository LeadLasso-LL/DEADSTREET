extends RefCounted
## Display names and recommended sandbox compositions; internal geometry IDs stay stable.
const Config=preload("res://gameplay/sandbox_force_config.gd")
const IDS=["harold","river_bridge","whittaker_estate","doble_ocho","freight_exchange"]
const RIVER_NAME="Calder River"
const DATA={
 "freight_exchange":{"name":"Eastex Freight Exchange","place":"Eastex","hint":"Rainy night / Rail crossings / 10 per side","count":10,"classes":["rifle","smg","shotgun","rifle","sniper","smg","rifle","shotgun","pistol","rifle"]},
 "harold":{"name":"Harold Ave.","place":"Mercer Heights","hint":"Tight street fighting / 4–5 per side","count":5,"classes":["pistol","smg","shotgun","rifle","sniper"]},
 "river_bridge":{"name":"Calder Memorial Bridge","place":"Calder River","hint":"Traffic blockade / 8–10 per side","count":8,"classes":["rifle","smg","shotgun","rifle","pistol","smg","rifle","sniper"]},
 "whittaker_estate":{"name":"Whittaker Estate","place":"City Outskirts","hint":"Estate assault / 12 per side","count":12,"classes":["rifle","smg","shotgun","rifle","pistol","smg","rifle","shotgun","rifle","smg","pistol","sniper"]},
 "doble_ocho":{"name":"Doble Ocho Auto Yard","place":"South Side","hint":"Two-gate garage raid / 6–7 per side","count":7,"classes":["rifle","smg","shotgun","rifle","pistol","smg","sniper"]}
}
static var textures={}
static func info(id: String) -> Dictionary:return DATA.get(id,DATA.harold)
static func texture(id: String) -> Texture2D:
 if not textures.has(id):
  var path="res://assets/menu/maps/"+id+".png"
  textures[id]=ImageTexture.create_from_image(Image.load_from_file(path)) if FileAccess.file_exists(path) else null
 return textures[id]
static func preset(id: String,current: Dictionary={}) -> Dictionary:
 var result=Config.from_legacy({}) if current.is_empty() else current.duplicate(true)
 result.map_id=id
 for side in ["attacker","defender"]:
  result[side].units=[]
  for kind in info(id).classes:result[side].units.append(Config.unit(kind))
  result[side].erase("vehicle_occupants")
  if side=="attacker" or id=="river_bridge":result[side].vehicles=Config.auto_convoy(info(id).count,result[side].faction)
  elif result[side].has("vehicles"):result[side].erase("vehicles")
 if id=="doble_ocho":
  var yard=preload("res://gameplay/doble_ocho_scenario.gd").config()
  for side in ["attacker","defender"]:
   var faction=result[side].faction
   result[side]=yard[side].duplicate(true);result[side].faction=faction
 return result
