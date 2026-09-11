extends SceneTree
func _initialize():
 var base="res://tools/faction_design/"
 var data: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(base+"animation_jobs.json"))
 var dest="res://assets/art/units/mercer/"
 var atlases: Dictionary={}
 var clipped: Array=[]
 DirAccess.make_dir_recursive_absolute(base+"samples")
 for job: Array in data.jobs:
  var im=Image.new()
  if im.load_svg_from_string(FileAccess.get_file_as_string(base+"animation_svg/"+str(job[0])+".svg"),2.)!=OK:push_error(str(job[0]));quit(1);return
  im.resize(128,128,Image.INTERPOLATE_LANCZOS)
  var bounds=im.get_used_rect()
  if bounds.position.x<=0 or bounds.end.x>=128 or bounds.position.y<=0 or bounds.end.y>=128:clipped.append(job[0])
  if data.sample:im.save_png(base+"samples/"+job[0]+".png");continue
  if not atlases.has(job[1]):atlases[job[1]]=Image.create(4096,(int(data.rows) if job[1]=="units" else 1)*8*128,false,Image.FORMAT_RGBA8)
  atlases[job[1]].blit_rect(im,Rect2i(0,0,128,128),Vector2i(job[2],job[3]))
 for key: String in atlases:atlases[key].save_png(dest+key+"/"+data.variant+".png")
 var log={"variant":data.variant,"frames":data.jobs.size(),"touching_frame_border":clipped}
 var file=FileAccess.open(base+"animation_render_check.json",FileAccess.WRITE);file.store_string(JSON.stringify(log));file.close()
 print("RENDERED ",data.variant," frames=",data.jobs.size()," borders=",clipped.size())
 quit(1 if not clipped.is_empty() else 0)
