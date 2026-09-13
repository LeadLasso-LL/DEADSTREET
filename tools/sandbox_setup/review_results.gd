extends SceneTree
const Cases=preload("res://tools/sandbox_setup/scenarios.gd")
const Fixture=preload("res://gameplay/arsenal_battle_fixture.gd")
const Identity=preload("res://gameplay/battle_faction_identity.gd")
class HeadlessView extends Node:
 var _dusk_zoom=1.3
 var _dusk_pan=Vector2.ZERO
 var deployment_controller
 func _frame_camera():pass
 func _is_dusk_street():return false
func _initialize():call_deferred("run")
func run():
 root.size=Vector2i(1152,860);DisplayServer.window_set_size(root.size)
 var runtime=load("res://gameplay/gameplay_runtime.gd").new()
 runtime.game_state=load("res://gameplay/starter_world_service.gd").create();runtime.game_flow_controller=load("res://core/game_flow_controller.gd").create(runtime.game_state).controller
 var stub=HeadlessView.new();stub.name="TacticalBattleView";runtime.add_child(stub)
 var result=Fixture.setup(runtime,Cases.make(12,12),false,719,true)
 if not result.has("battle"):printerr(result);quit(1);return
 var director=load("res://gameplay/tactical_battle_presentation.gd").new();root.add_child(director);director.set_process(false)
 director.surface=Control.new();director.add_child(director.surface);director.font=SystemFont.new();director.font.font_names=PackedStringArray(["Arial"]);director.font.font_weight=600
 director.battle=result.battle;director.attacker=Identity.for_side(result.battle,"attacker");director.defender=Identity.for_side(result.battle,"defender")
 director.build_results();director.result_root.position=Vector2(56,118);director.result_root.modulate.a=1.
 var errors=[]
 for i in range(2):
  var panel=director.result_root.get_child(i)
  for child in panel.get_children():
   if child is Label and child.position.y==23:
    if director.font.get_string_size(child.text,HORIZONTAL_ALIGNMENT_LEFT,-1,child.get_theme_font_size("font_size")).x>382:errors.append("title overflow "+child.text)
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://tools/sandbox_setup/results/results_titles.png")
 FileAccess.open("res://tools/sandbox_setup/results/titles.json",FileAccess.WRITE).store_string(JSON.stringify({"errors":errors,"cards":director.result_cards.size()},"  "))
 print("RESULTS_TITLES ",errors);runtime.free();quit(0 if errors.is_empty() else 1)
