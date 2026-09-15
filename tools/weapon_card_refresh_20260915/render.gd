extends SceneTree
const O="res://tools/weapon_card_refresh_20260915/"
func _initialize():
 var data=JSON.parse_string(FileAccess.get_file_as_string(O+"icon_jobs.json"))
 for job in data.jobs:
  var im=Image.new()
  if im.load_svg_from_string(job[1],1.)!=OK:quit(1);return
  var rect=im.get_used_rect().grow(6).intersection(Rect2i(Vector2i.ZERO,im.get_size()))
  im.get_region(rect).save_png(O+"renders/icon_"+job[0]+".png")
 data=JSON.parse_string(FileAccess.get_file_as_string(O+"card_jobs.json"))
 for job in data.jobs:
  var im=Image.new()
  if im.load_svg_from_string(job[1],2.)!=OK:quit(2);return
  im.resize(128,128,Image.INTERPOLATE_LANCZOS)
  if im.save_png(O+"renders/"+job[0]+".png")!=OK:quit(3);return
 print("CARD_RENDERED ",data.jobs.size())
 quit()
