extends SceneTree
const OUT="res://tools/menu_polish_20260915/"
const Factions=preload("res://battle/identity/faction_unit_catalog.gd")
const Emblem=preload("res://gameplay/sandbox_emblem.gd")
const Catalog=preload("res://gameplay/music_catalog.gd")
var checks=0
var errors=[]
func _initialize():call_deferred("run")
func check(ok: bool, message: String):
 checks+=1
 if not ok:errors.append(message);printerr("POLISH_FAIL ",message)
func frames(n):
 for i in range(n):await process_frame
func click(control):
 var point=control.get_global_rect().get_center()
 var motion=InputEventMouseMotion.new();motion.position=point;motion.global_position=point;root.push_input(motion,true)
 for down in [true,false]:
  var event=InputEventMouseButton.new();event.position=point;event.global_position=point;event.button_index=MOUSE_BUTTON_LEFT;event.pressed=down;root.push_input(event,true);await process_frame
 await frames(3)
func shot(name):
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(OUT+name+".png")
func emblems_in(node,expected: int):
 var count=0
 for child in node.find_children("*","TextureRect",true,false):
  if child.material is ShaderMaterial and child.material.shader==Emblem.MASK:count+=1
 check(count==expected,"menu emblem binding count "+str(count)+" expected "+str(expected))
func run():
 root.size=Vector2i(1280,900);DisplayServer.window_set_size(root.size)
 var scene=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(scene);await frames(12)
 var menu=scene.menu_panels
 emblems_in(menu.builder,2);await shot("battle_setup")
 for side in ["attacker","defender"]:
  var option=menu.builder.faction_options[side]
  for i in range(option.item_count):
   option.select(i);option.item_selected.emit(i);await frames(1)
   emblems_in(menu.builder,2)
 menu.show_tab("factions");await frames(5)
 var faction=menu.pages.factions
 for id in Factions.all_ids():
  faction.show_faction(id);await frames(2)
  emblems_in(faction,24)
  if id in ["mercer","orlov","nbpd"]:await shot("faction_"+id)
 # Actual GPU pixels: all 23 circular emblems keep their inner colors and lose white corners.
 var overlay=CanvasLayer.new();overlay.layer=95;root.add_child(overlay)
 var bg=ColorRect.new();bg.color=Color("#121c20");bg.size=Vector2(root.size);overlay.add_child(bg)
 var pictures=[];var n=0
 var logical=root.get_visible_rect().size
 var step_x=(logical.x-40)/6.0;var step_y=(logical.y-40)/4.0
 for id in Factions.all_ids():
  var pic=TextureRect.new();bg.add_child(pic);pic.position=Vector2(20+(n%6)*step_x,20+(n/6)*step_y);pic.size=Vector2(132,132);pic.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;pic.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;Emblem.apply(pic,id);pictures.append(pic)
  var name=Label.new();bg.add_child(name);name.position=pic.position+Vector2(0,136);name.text=Factions.display_name(id);name.size=Vector2(step_x-6,32);name.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;name.add_theme_font_size_override("font_size",10);n+=1
 await frames(6);await shot("emblems_after")
 var screen=root.get_texture().get_image()
 for pic in pictures:pic.material=null
 await frames(3);await RenderingServer.frame_post_draw
 var unmasked=root.get_texture().get_image()
 var pixel_scale=Vector2(screen.get_size())/logical
 for pic in pictures:
  var pos=Vector2i(pic.position*pixel_scale);var extent=Vector2i(pic.size*pixel_scale)
  var reference=screen.get_pixel(pos.x+extent.x+8,pos.y+10)
  for corner in [Vector2i(3,3),Vector2i(extent.x-3,3),Vector2i(3,extent.y-3),extent-Vector2i(3,3)]:
   var value=screen.get_pixelv(pos+corner);check(abs(value.r-reference.r)+abs(value.g-reference.g)+abs(value.b-reference.b)<0.015,"no white canvas corner "+str(pos)+str(corner))
  var unchanged=true
  for y in range(int(extent.y*.3),int(extent.y*.7)):
   for x in range(int(extent.x*.3),int(extent.x*.7)):
    if screen.get_pixelv(pos+Vector2i(x,y))!=unmasked.get_pixelv(pos+Vector2i(x,y)):unchanged=false
  check(unchanged,"inner emblem colors preserved exactly "+str(pos))
 overlay.queue_free();await frames(3)
 menu.show_tab("arsenal");await frames(4);var arsenal=menu.pages.arsenal
 arsenal.choose_class("rifle");arsenal.show_equipment("ak47");await frames(3);await shot("ak47")
 arsenal.choose_class("sniper");await frames(3)
 for id in ["rem700","sks","svd","ssg69","awm","psg1"]:
  arsenal.show_equipment(id);await frames(2);check(arsenal.selected_id==id,"sniper detail selects "+id);await shot("sniper_"+id)
 var music=load("res://gameplay/sandbox_menu_music.gd").new();music.settings_path="user://menu_polish_native_test.cfg";root.add_child(music);music.sandbox=scene;music.player.volume_db=-42
 for track in music.tracks:music.enabled_tracks[str(track.id)]=true
 music.refill_queue();music.refresh_tracks();music.start_signature();music.show_on_entry();await frames(5)
 check(music.player.playing and music.play_count==1,"signature starts once")
 check(music.dock.visible and music.toast.visible,"small toast keeps music dock available")
 check(music.toast.size.x<=164 and music.toast.size.y<=60,"compact popup actual size "+str(music.toast.size))
 check(not music.toast.get_global_rect().intersects(music.dock.get_global_rect()),"popup starts above dock")
 await shot("music_popup")
 await click(music.dock);check(music.panel.visible,"dock opens menu during toast")
 check(not music.toast.get_global_rect().intersects(music.panel.get_global_rect()),"popup stays above open menu")
 var original_enabled=music.enabled_tracks.duplicate();var vol=music.player.volume_db
 for round in range(8):
  var old=music.current_id;var count=music.play_count
  await click(music.shuffle)
  check(music.current_id!=old,"shuffle immediately changes song "+str(round))
  check(music.player.playing and not music.player.stream_paused and music.play_count==count+1,"shuffle starts new first song "+str(round))
  var order=[music.current_id];order.append_array(music.queue)
  var distinct={}
  for id in order:distinct[id]=true
  check(order.size()==music.tracks.size() and distinct.size()==music.tracks.size(),"complete permutation without duplicate "+str(round))
  check(music.label.text.begins_with(str(music.info(music.current_id).title)),"now playing matches new starting song "+str(round))
 check(music.enabled_tracks==original_enabled and music.player.volume_db==vol,"shuffle preserves selections and volume")
 await shot("music_shuffle_menu")
 await click(music.toggle);check(music.user_paused,"pause works")
 await click(music.shuffle);check(not music.user_paused and music.player.playing and not music.player.stream_paused,"shuffle deliberately resumes immediately")
 var excluded=music.current_id;music.set_track_enabled(excluded,false);await frames(3);await click(music.shuffle)
 check(music.current_id!=excluded and excluded not in music.queue,"shuffle respects unchecked track")
 var expected=music.queue[0];music.player.seek(music.player.stream.get_length()-0.12);await create_timer(.7).timeout
 check(music.current_id==expected,"natural finish follows freshly shuffled queue")
 expected=music.queue[0];await click(music.skip);check(music.current_id==expected,"Next follows freshly shuffled queue")
 for track in music.tracks:music.enabled_tracks[str(track.id)]=false
 music.refill_queue();music.refresh_tracks();await frames(3)
 check(music.shuffle.disabled,"empty playlist disables shuffle")
 var count=music.play_count;music.reshuffle_tracks();check(music.play_count==count,"empty reshuffle does not play excluded music")
 music.enabled_tracks[music.current_id]=true;music.refill_queue();music.refresh_tracks();await frames(3);count=music.play_count
 await click(music.shuffle);check(music.play_count==count+1 and music.queue.is_empty(),"one enabled song restarts explicitly without queue duplication")
 for track in music.tracks:music.enabled_tracks[str(track.id)]=true
 music.refill_queue();music.refresh_tracks();await frames(3)
 for dimensions in [Vector2i(1152,860),Vector2i(1280,720),Vector2i(1440,1000)]:
  root.size=dimensions;DisplayServer.window_set_size(dimensions);music.show_track_toast();music.panel.show();await frames(6)
  check(Rect2(Vector2.ZERO,Vector2(root.size)).encloses(music.panel.get_global_rect()),"music menu fits "+str(dimensions))
  check(not music.toast.get_global_rect().intersects(music.panel.get_global_rect()),"compact toast clears controls "+str(dimensions))
  check(music.panel.get_global_rect().encloses(music.shuffle.get_global_rect()),"shuffle button within menu "+str(dimensions))
 count=music.play_count;scene.ui.hide();await frames(3);music.reshuffle_tracks();check(music.play_count==count and music.player.stream_paused,"hidden sandbox cannot shuffle and music stays paused")
 scene.ui.show();await frames(3);check(not music.player.stream_paused,"return resumes menu audio")
 DirAccess.remove_absolute(ProjectSettings.globalize_path(music.settings_path))
 FileAccess.open(OUT+"native_validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"errors":errors,"emblems":23,"gun_icons":7,"shuffle_rounds":8,"tracks":music.tracks.size(),"popup_size":str(music.toast.size)},"  "))
 print("MENU_POLISH_NATIVE ",checks," checks; ",errors.size()," failures")
 quit(0 if errors.is_empty() else 1)
