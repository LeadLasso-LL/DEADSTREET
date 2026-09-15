extends SceneTree
func _initialize():
 var base="res://assets/art/weapons/arsenal/"
 var data: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/data/weapon_models.json"))
 for id: String in data.models:
  var im=Image.new()
  if im.load_svg_from_string(FileAccess.get_file_as_string(base+"source/"+id+".svg"),1.)!=OK:push_error(id);quit(1);return
  var used=im.get_used_rect()
  var padded=used.grow(6).intersection(Rect2i(Vector2i.ZERO,im.get_size()))
  im=im.get_region(padded)
  im.save_png(base+"icons/"+id+".png")
 print("ICONS_COMPLETE 30")
 quit()
