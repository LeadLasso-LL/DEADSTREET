extends RefCounted
const Factions=preload("res://battle/identity/faction_unit_catalog.gd")
const Anim=preload("res://battle/presentation/tactical_unit_animation_catalog.gd")
static var textures={}
static func for_side(battle,side: String) -> Dictionary:
 for p in battle.participants.values():
  if p.side_id!=side or p.identity==null:continue
  var id: String=Factions.canonical_id(p.identity.gang_archetype_id)
  var title: String=Factions.display_name(id).to_upper() if not id.is_empty() else side.to_upper()
  if not id.is_empty() and not textures.has(id):textures[id]=Anim._load_texture(Factions.emblem_path(id))
  return {"id":id,"name":title,"short_name":str(Factions.profile(id).get("hud_name",title)),"emblem":textures.get(id),"side":side}
 return {"id":"","name":side.to_upper(),"emblem":null,"side":side}

static var _emblem_material: ShaderMaterial
static func style_emblem(item: CanvasItem) -> void:
 if _emblem_material==null:
  _emblem_material=ShaderMaterial.new()
  _emblem_material.shader=preload("res://assets/art/factions/emblem_round.gdshader")
 item.material=_emblem_material
