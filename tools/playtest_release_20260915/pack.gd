extends SceneTree
func _initialize():
 ProjectSettings.set_setting("application/config/name","Dead Street Sandbox")
 ProjectSettings.set_setting("application/run/main_scene","res://tools/playtest_release_20260915/boot.tscn")
 ProjectSettings.set_setting("application/config/icon",null)
 ProjectSettings.set_setting("application/config/use_custom_user_dir",true)
 ProjectSettings.set_setting("application/config/custom_user_dir_name","DeadStreetSandbox")
 ProjectSettings.set_setting("display/window/size/viewport_width",1920)
 ProjectSettings.set_setting("display/window/size/viewport_height",1080)
 ProjectSettings.set_setting("display/window/size/window_width_override",1600)
 ProjectSettings.set_setting("display/window/size/window_height_override",900)
 if ProjectSettings.save_custom("C:/Users/brand/OneDrive/Documents/dead-street/tools/playtest_release_20260915/stage/project.binary")!=OK:quit(2);return
 var pack=PCKPacker.new()
 if pack.pck_start("C:/Users/brand/OneDrive/Documents/dead-street/tools/playtest_release_20260915/candidate/DeadStreetSandbox.pck")!=OK:quit(3);return
 if pack.add_file("res://project.binary","C:/Users/brand/OneDrive/Documents/dead-street/tools/playtest_release_20260915/stage/project.binary")!=OK:quit(4);return
 var rows=JSON.parse_string(FileAccess.get_file_as_string("C:/Users/brand/OneDrive/Documents/dead-street/tools/playtest_release_20260915/stage/manifest.json"))
 for row in rows:
  if pack.add_file("res://"+row.path,row.source)!=OK:printerr("PACK_FAILED ",row.path);quit(5);return
 if pack.flush()!=OK:quit(6);return
 FileAccess.open("C:/Users/brand/OneDrive/Documents/dead-street/tools/playtest_release_20260915/candidate/Godot_License.txt",FileAccess.WRITE).store_string(Engine.get_license_text())
 print("PACKAGE_READY ",rows.size())
 quit()
