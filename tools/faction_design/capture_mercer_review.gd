extends SceneTree
func _initialize():call_deferred("run")
func run():
 root.size=Vector2i(1152,720)
 var menu=Node.new();menu.set_script(load("res://gameplay/arsenal_review.gd"));root.add_child(menu)
 await process_frame
 for child in menu.surface.get_children():
  if child is CheckButton and child.text=="Mercer dual-pistol specialist":child.button_pressed=true
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://tools/faction_design/mercer_arsenal_review.png")
 menu.faction="local_street_gang";menu.show_class("sniper");menu.choose("rem700")
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://tools/faction_design/mercer_sniper_arsenal.png")
 await menu.start_battle(true)
 if menu.battle==null:push_error("Mercer menu battle failed");quit(1);return
 await create_timer(15.).timeout
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://tools/faction_design/mercer_battle_review.png")
 print("MERCER_UI_CAPTURE_COMPLETE phase=",menu.battle.battle_phase," seconds=",menu.battle.elapsed_time_seconds)
 quit()
