extends Node
func _ready():
 var icon=Image.load_from_file("res://assets/branding/sandbox_icon.png")
 if icon!=null:DisplayServer.set_icon(icon)
 for arg in OS.get_cmdline_user_args():
  if arg=="--benchmark":
   var tree=get_tree()
   tree.set_script(load("res://tools/playtest_release_20260915/bench.gd"))
   tree.call_deferred("_initialize");queue_free();return
 get_tree().change_scene_to_file("res://gameplay/sandbox_opening.tscn")
