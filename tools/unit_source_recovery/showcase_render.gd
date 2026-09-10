extends SceneTree
func _initialize():
 var base="res://tools/unit_source_recovery/"
 var data=JSON.parse_string(FileAccess.get_file_as_string(base+"showcase_jobs.json"))
 var out=base+"showcase_samples/" if data.sample else base+"showcase_atlases/"
 DirAccess.make_dir_recursive_absolute(out)
 var current=""
 var atlas: Image
 for job in data.jobs:
  if not data.sample and job[1]!=current:
   if atlas!=null:atlas.save_png(out+current+".png");print("RENDERED ",current)
   current=job[1];atlas=Image.create(4096,(1 if current.ends_with("__death_back") else int(data.rows))*8*128,false,Image.FORMAT_RGBA8)
  var im=Image.new()
  if im.load_svg_from_string(FileAccess.get_file_as_string(base+"showcase_svg/"+job[0]+".svg"),2.)!=OK:push_error(job[0]);quit(1);return
  im.resize(128,128,Image.INTERPOLATE_LANCZOS)
  if data.sample:im.save_png(out+job[0]+".png")
  else:atlas.blit_rect(im,Rect2i(0,0,128,128),Vector2i(job[2],job[3]))
 if atlas!=null:atlas.save_png(out+current+".png");print("RENDERED ",current)
 print("SHOWCASE_NATIVE_COMPLETE")
 quit()
