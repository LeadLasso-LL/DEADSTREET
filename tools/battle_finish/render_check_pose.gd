extends SceneTree
func _initialize():
 var base="res://tools/battle_finish/pose_svg/"
 var jobs=JSON.parse_string(FileAccess.get_file_as_string(base+"jobs.json"))
 var out="res://assets/art/units/pixel_v1/check_comrade/"
 DirAccess.make_dir_recursive_absolute(out)
 var current="";var atlas: Image
 for job in jobs:
  if job[1]!=current:
   if atlas!=null:atlas.save_png(out+current+".png")
   current=job[1];atlas=Image.create(1280,1024,false,Image.FORMAT_RGBA8)
  var im=Image.new()
  if im.load_svg_from_string(FileAccess.get_file_as_string(base+job[0]+".svg"),2.)!=OK:push_error(job[0]);quit(1);return
  im.resize(128,128,Image.INTERPOLATE_LANCZOS)
  atlas.blit_rect(im,Rect2i(0,0,128,128),Vector2i(job[2],job[3]))
 if atlas!=null:atlas.save_png(out+current+".png")
 print("CHECK_POSE_RENDERED");quit()
