extends RefCounted
## Menu-only circular seal masking. Canonical source images and battle rendering remain intact.
const Anim = preload("res://battle/presentation/tactical_unit_animation_catalog.gd")
const Factions = preload("res://battle/identity/faction_unit_catalog.gd")
const MASK = preload("res://gameplay/sandbox_emblem.gdshader")
static var masks: Dictionary = {}
static var materials: Dictionary = {}
static func apply(picture: TextureRect, faction_id: String):
 var id=Factions.canonical_id(faction_id)
 picture.texture=Anim._load_texture(Factions.emblem_path(id))
 if masks.is_empty():masks=JSON.parse_string(FileAccess.get_file_as_string("res://assets/data/sandbox_emblem_masks.json"))
 if not masks.has(id):return
 if not materials.has(id):
  var row=masks[id];var mat=ShaderMaterial.new();mat.shader=MASK
  mat.set_shader_parameter("center",Vector2(row.center[0],row.center[1]))
  mat.set_shader_parameter("source_size",Vector2(row.size[0],row.size[1]))
  mat.set_shader_parameter("radius",float(row.radius));materials[id]=mat
 picture.material=materials[id]
