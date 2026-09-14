extends SceneTree
const Anim=preload("res://battle/presentation/tactical_unit_animation_catalog.gd")
func _initialize():
 var rows=JSON.parse_string(FileAccess.get_file_as_string("res://tools/pistol_portrait_20260914/inventory.json"))
 var checks=0
 var failures=[]
 for row in rows:
  var specialist="mercer_dual_glock" if row.group=="mercer" else ""
  var faction="mercer" if row.group=="mercer" else str(row.faction)
  var model="glock_17" if row.group=="mercer" else str(row.model)
  var variant=Anim.variant_for(faction,"pistol",model,specialist)
  if variant!=row.variant:failures.append(str(row.variant)+": binding");continue
  checks+=1
  var path=Anim.atlas_path(variant,"portraits")
  if path!="res://"+str(row.portrait):failures.append(variant+": path");continue
  checks+=1
  var texture=Anim._load_texture(path)
  if texture==null:failures.append(variant+": missing texture");continue
  checks+=1
  var actual=texture.get_image()
  var expected=Image.new()
  expected.load_png_from_buffer(FileAccess.get_file_as_bytes(path))
  actual.convert(Image.FORMAT_RGBA8)
  expected.convert(Image.FORMAT_RGBA8)
  var mismatch=0
  for y in expected.get_height():
   for x in expected.get_width():
    var a=actual.get_pixel(x,y)
    var b=expected.get_pixel(x,y)
    if a.a!=b.a or (b.a>0 and a!=b):mismatch+=1
  if mismatch>0:failures.append(variant+": "+str(mismatch)+" visible pixel mismatches");continue
  checks+=1
 var result={"portraits":rows.size(),"checks":checks,"failures":failures}
 FileAccess.open("res://tools/pistol_portrait_20260914/native_card_checks.json",FileAccess.WRITE).store_string(JSON.stringify(result,"  "))
 print("PISTOL_CARD_CHECKS ",JSON.stringify(result))
 quit(0 if failures.is_empty() else 1)
