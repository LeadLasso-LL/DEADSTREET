extends RefCounted
static var textures={}
static func for_side(battle,side: String) -> Dictionary:
 for p in battle.participants.values():
  if p.side_id!=side:continue
  var archetype=p.identity.gang_archetype_id
  var id="orlov_bratva" if archetype=="russian_organized_crime" else ("mercer_saints" if archetype=="local_street_gang" else "")
  var title="ORLOV BRATVA" if id=="orlov_bratva" else ("MERCER SAINTS" if id=="mercer_saints" else side.to_upper())
  if not id.is_empty() and not textures.has(id):textures[id]=load("res://assets/art/factions/"+id+".png")
  return {"id":id,"name":title,"emblem":textures.get(id),"side":side}
 return {"id":"","name":side.to_upper(),"emblem":null,"side":side}
