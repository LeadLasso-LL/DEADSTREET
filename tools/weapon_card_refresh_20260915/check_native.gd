extends SceneTree
const Anim=preload("res://battle/presentation/tactical_unit_animation_catalog.gd")
const Weapons=preload("res://battle/combat/battle_weapon_catalog.gd")
const Factions=preload("res://battle/identity/faction_unit_catalog.gd")
const Glossary=preload("res://gameplay/sandbox_glossary_panel.gd")
const O="res://tools/weapon_card_refresh_20260915/"
var checks=0
var failures=[]
func verify(value: bool,label: String):
 checks+=1
 if not value:failures.append(label)
func same_pixels(a: Image,b: Image)->bool:
 if a.is_compressed():a.decompress()
 if b.is_compressed():b.decompress()
 if a.get_size()!=b.get_size():return false
 a.convert(Image.FORMAT_RGBA8);b.convert(Image.FORMAT_RGBA8)
 var x=a.get_data();var y=b.get_data()
 for i in range(0,x.size(),4):
  if x[i+3]!=y[i+3]:return false
  if x[i+3]>0 and (x[i]!=y[i] or x[i+1]!=y[i+1] or x[i+2]!=y[i+2]):return false
 return true
func source_image(path: String,imported: bool=false)->Image:
 var im=Image.new()
 im.load_png_from_buffer(FileAccess.get_file_as_bytes(path))
 if imported:im.fix_alpha_edges()
 return im
func _initialize():call_deferred("run")
func run():
 var rows=JSON.parse_string(FileAccess.get_file_as_string(O+"inventory.json"))
 var found={}
 for row in rows:
  var model=Weapons.get_model(row.model)
  var variant=Anim.variant_for(row.faction,model.weapon_type_id,row.model,"mercer_dual_glock" if row.group=="specialist" else "")
  verify(variant==row.variant,"current binding "+row.variant)
  var path=Anim.atlas_path(variant,"portraits")
  verify(path=="res://"+row.portrait,"current path "+variant)
  var texture=Anim._load_texture(path)
  verify(texture!=null,"load "+variant)
  if texture!=null:verify(same_pixels(texture.get_image(),source_image(path)),"visible current pixels "+variant)
  if row.group!="specialist":found[row.faction+":"+row.model]=true
 verify(Factions.all_ids().size()==23,"canonical faction count")
 var model_rows=JSON.parse_string(FileAccess.get_file_as_string("res://assets/data/weapon_models.json")).models
 for faction in Factions.all_ids():
  for model in model_rows:verify(found.has(faction+":"+model),"complete coverage "+faction+":"+model)
 for id in ["rem870","moss500","spas12","benelli_m2","benelli_m4","saiga12","mini14","aug"]:
  var path="res://assets/art/weapons/arsenal/icons/"+id+".png"
  verify(same_pixels(Anim._load_texture(path).get_image(),source_image(path,true)),"current Arsenal trigger icon "+id)
 RenderingServer.set_default_clear_color(Color("#152226"))
 root.size=Vector2i(1152,764)
 var panel=Glossary.new();root.add_child(panel)
 await process_frame
 for faction in Factions.all_ids():
  panel.show_faction(faction)
  await process_frame
  for role in panel.unit_images:
   var picture=panel.unit_images[role]
   var expected=Anim.atlas_path(str(picture.get_meta("variant")),"portraits")
   verify(same_pixels(picture.texture.get_image(),source_image(expected)),"actual glossary "+faction+":"+role)
  if faction in ["mercer","orlov"]:
   await RenderingServer.frame_post_draw
   root.get_texture().get_image().save_png(O+"review/native_"+faction+".png")
 panel.queue_free()
 await process_frame
 var result={"checks":checks,"failures":failures,"portraits":rows.size(),"canonical_regular_combinations":found.size(),"runtime":"Godot 4.7.2; actual current catalogue bindings, textures and glossary cards; no combat benchmark needed for static artwork."}
 FileAccess.open(O+"native_validation.json",FileAccess.WRITE).store_string(JSON.stringify(result,"  "))
 print("NATIVE_WEAPON_CARDS ",checks," FAILURES ",failures)
 quit(0 if failures.is_empty() else 1)
