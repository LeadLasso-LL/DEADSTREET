extends SceneTree
const Art=preload("res://gameplay/whittaker_estate_art.gd")
const Catalog=preload("res://battle/geometry/whittaker_estate_catalog.gd")
func _initialize():call_deferred("run")
func run():
 var folder="C:/Users/brand/OneDrive/Documents/dead-street/assets/art/whittaker_estate/props"
 DirAccess.make_dir_recursive_absolute(folder)
 var vp=SubViewport.new();vp.transparent_bg=true;vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(vp)
 var count=0
 for row in Catalog.props():
  if row[2] in ["traffic","fountain","fountain_body","column"]:continue
  var box: Rect2=row[1]
  vp.size=Vector2i(ceili(box.size.x*8+400),ceili(box.size.y*6+300))
  var anchor=Vector2(box.get_center().x*8,box.end.y*6)
  vp.canvas_transform=Transform2D(0,Vector2(vp.size.x*.5,vp.size.y-48)-anchor)
  var art=Art.new();art.bake_mode=true;art.prop=row;art.position=anchor;vp.add_child(art)
  await process_frame;await process_frame;await RenderingServer.frame_post_draw
  var result=vp.get_texture().get_image().save_png(folder+"/"+str(row[0])+".png")
  if result!=OK:printerr("ESTATE_FAIL prop bake ",row[0]);quit(1);return
  count+=1;art.queue_free();await process_frame
 print("ESTATE_PROP_PLATES ",count);quit()
