extends SceneTree
func _initialize():
 var base="res://tools/unit_source_recovery/"
 var jobs=JSON.parse_string(FileAccess.get_file_as_string(base+"jobs.json"))
 var atlases={}
 DirAccess.make_dir_recursive_absolute(base+"review_atlases")
 for job in jobs:
  var variant=job[1]
  if not atlases.has(variant): atlases[variant]=Image.create(4096,6144,false,Image.FORMAT_RGBA8)
  var image=Image.new()
  var err=image.load_svg_from_string(FileAccess.get_file_as_string(base+"svg_export/"+job[0]+".svg"),2.0)
  if err!=OK: push_error(job[0]);quit(1);return
  image.resize(128,128,Image.INTERPOLATE_LANCZOS)
  atlases[variant].blit_rect(image,Rect2i(0,0,128,128),Vector2i(job[2],job[3]))
 for variant in atlases:
  atlases[variant].save_png(base+"review_atlases/"+variant+".png")
  print("RENDERED ",variant)
 quit()
