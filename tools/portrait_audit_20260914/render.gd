extends SceneTree
func _initialize():
 var args=OS.get_cmdline_user_args()
 var data=JSON.parse_string(FileAccess.get_file_as_string(args[0]))
 for job in data.jobs:
  var im=Image.new()
  if im.load_svg_from_string(job[1],2.0)!=OK:quit(1);return
  im.resize(128,128,Image.INTERPOLATE_LANCZOS)
  if im.save_png(args[1]+"/"+job[0]+".png")!=OK:quit(2);return
 print("PORTRAIT_RENDERED ",data.jobs.size())
 quit()
