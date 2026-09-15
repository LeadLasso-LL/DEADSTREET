extends SceneTree
func _initialize():
 var base="res://tools/unit_source_recovery/"
 var jobs=JSON.parse_string(FileAccess.get_file_as_string(base+"showcase_jobs.json"))
 var bounds={}
 for job in jobs.jobs:
  if not str(job[1]).ends_with("__death_back"):continue
  var text=FileAccess.get_file_as_string(base+"showcase_svg/"+job[0]+".svg")
  text=text.replace('width="128"','width="192"').replace('height="128"','height="192"').replace('viewBox="0 0 128 128"','viewBox="-32 -32 192 192"')
  var im=Image.new();im.load_svg_from_string(text,1.)
  var rect=im.get_used_rect();rect.position-=Vector2i(32,32)
  var d=str(job[0]).split("_")[-4]
  if not bounds.has(d):bounds[d]=rect
  else:bounds[d]=bounds[d].merge(rect)
 print("DEATH_BOUNDS ",bounds)
 quit()
