extends SceneTree
func _initialize():
 var base="res://tools/unit_source_recovery/"
 var jobs=JSON.parse_string(FileAccess.get_file_as_string(base+"mask_jobs.json"))
 var atlases={}
 DirAccess.make_dir_recursive_absolute("res://assets/art/units/pixel_v1/blood_masks")
 for job in jobs:
  if not atlases.has(job[1]): atlases[job[1]]=Image.create(4096,6144,false,Image.FORMAT_RGBA8)
  var image=Image.new()
  if image.load_svg_from_string(FileAccess.get_file_as_string(base+"mask_svg/"+job[0]+".svg"),2.0)!=OK: quit(1);return
  image.resize(128,128,Image.INTERPOLATE_LANCZOS)
  atlases[job[1]].blit_rect(image,Rect2i(0,0,128,128),Vector2i(job[2],job[3]))
 for variant in atlases:
  atlases[variant].convert(Image.FORMAT_L8)
  atlases[variant].save_png("res://assets/art/units/pixel_v1/blood_masks/"+variant+".png")
  print("MASK_RENDERED ",variant)
 quit()
