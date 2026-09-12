extends SceneTree
const Armor=preload("res://campaign/equipment/armor_catalog.gd")
func _initialize():
 for id: String in Armor.IDS:
  var base="res://assets/art/equipment/armor/"+id
  var im=Image.new()
  if im.load_svg_from_string(FileAccess.get_file_as_string(base+".svg"))!=OK:quit(1);return
  im.resize(192,224,Image.INTERPOLATE_LANCZOS)
  im.resize(576,672,Image.INTERPOLATE_NEAREST)
  if im.get_used_rect().size.x<100:quit(1);return
  im.save_png(base+".png")
 print("ARMOR_ART_COMPLETE 3 standalone transparent garments")
 quit()
