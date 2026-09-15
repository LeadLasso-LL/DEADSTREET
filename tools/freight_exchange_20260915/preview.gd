extends SceneTree
const C=preload("res://battle/geometry/freight_exchange_catalog.gd")
const Art=preload("res://gameplay/freight_exchange_art.gd")
func _initialize():call_deferred("run")
func settle(n=6):
 for i in range(n):await process_frame
func run():
 var bake="--bake" in OS.get_cmdline_user_args()
 var vp=SubViewport.new();vp.size=Vector2i(4096,2304) if bake else Vector2i(1600,950);vp.render_target_update_mode=SubViewport.UPDATE_ALWAYS;root.add_child(vp)
 vp.canvas_transform=Transform2D(0,Vector2(1408,896)) if bake else Transform2D(0,Vector2(1.1,1.1),0,Vector2(78,215))
 var ground=Art.new();ground.bake_mode=bake;vp.add_child(ground)
 if not bake:
  var layer=Node2D.new();layer.y_sort_enabled=true;vp.add_child(layer)
  for row in C.props():
   var p=Art.new();p.prop=row;var b: Rect2=row[1];p.position=Vector2(b.get_center().x*8,b.end.y*6);layer.add_child(p)
 if not bake:
  var weather=preload("res://gameplay/freight_exchange_weather.gd").new();weather.sound_enabled=false;vp.add_child(weather)
 await settle();await RenderingServer.frame_post_draw
 var path="res://assets/art/freight_exchange/ground.png" if bake else "res://tools/freight_exchange_20260915/map_overview.png"
 DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
 var result=vp.get_texture().get_image().save_png(path)
 if not bake:
  var im=vp.get_texture().get_image().get_region(Rect2i(65,110,1480,725));im.resize(896,439,Image.INTERPOLATE_LANCZOS)
  DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://assets/menu/maps"));im.save_png("res://assets/menu/maps/freight_exchange.png")
 print("FREIGHT_IMAGE ",path," ",result);quit(result)
