extends SceneTree
const Anim=preload("res://battle/presentation/tactical_unit_animation_catalog.gd")
var scene
var errors=[]
var fps=[]
var captured=false
var seen={}
func _initialize():call_deferred("run")
func capture(name: String):
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://tools/arsenal_production/"+name+".png")
func run():
 root.size=Vector2i(1440,900)
 scene=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(scene)
 await process_frame
 scene.show_class("sniper");scene.choose("awm")
 await capture("arsenal_review")
 scene.loadouts={"attacker":{"pistol":"five_seven","smg":"vector","shotgun":"benelli_m4","sniper":"awm"},"defender":{"pistol":"desert_eagle","smg":"p90","shotgun":"saiga12","sniper":"psg1"}}
 await scene.start_battle(true)
 if scene.battle==null:push_error("Rendered test failed to start");quit(1);return
 var start=Time.get_ticks_msec()
 var finished=false
 while Time.get_ticks_msec()-start<130000:
  await process_frame
  var b=scene.battle
  for event in b.combat_feedback_events:
   if not seen.has(event.sequence_id):
    seen[event.sequence_id]=event.source_participant_id
  if b.battle_phase=="active" and b.elapsed_time_seconds>5.:
   fps.append(Engine.get_frames_per_second())
   if not captured and b.elapsed_time_seconds>12.:
    await capture("arsenal_battle");captured=true
  var presentation=scene.runtime.get_node("TacticalBattleView").battle_presentation
  if presentation.results_visible() and presentation.result_root.modulate.a>.99:
   await capture("arsenal_results");finished=true;break
 var b=scene.battle
 if not captured:errors.append("No live battle capture")
 if not finished:errors.append("Result presentation did not complete")
 if seen.is_empty():errors.append("No rendered combat shots")
 var models={}
 for p in b.participants.values():
  var variant=Anim.variant_for(p.identity.gang_archetype_id,p.weapon_type,p.weapon_model_id)
  models[p.participant_id]={"model":p.weapon_model_id,"variant":variant}
  if not variant.begins_with("arsenal_"):errors.append("Expected custom model "+p.weapon_model_id)
 fps.sort()
 var report={"errors":errors,"resolved":finished,"shots":seen.size(),"combat_seconds":b.elapsed_time_seconds,"winner":b.get_winning_side_id(),"models":models,"fps_median":fps[fps.size()/2] if not fps.is_empty() else 0,"fps_low":fps[0] if not fps.is_empty() else 0}
 FileAccess.open("res://tools/arsenal_production/graphics_validation.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
 print("ARSENAL_GRAPHICS ",JSON.stringify(report));quit(0 if errors.is_empty() else 1)
