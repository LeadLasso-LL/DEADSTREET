extends SceneTree
# Full live runtime, with NO timed defender orders or edited health.
const Scenario=preload("res://tools/battle_showcase/scenario.gd")
const Runtime=preload("res://battle/runtime/battle_runtime_service.gd")
var runtime
var b
var t=0.
var active=false
var seen={}
var initial={}
var fast=false
var captured=false
func _initialize():
 fast="--fast" in OS.get_cmdline_user_args();call_deferred("start")
func start():
 runtime=load("res://gameplay/gameplay_runtime.tscn").instantiate();root.add_child(runtime);await process_frame
 var result=Scenario.setup(runtime,2002)
 if not result.has("battle"):push_error(str(result));quit(1);return
 b=result.battle
 for p in b.participants.values():initial[p.participant_id]=p.battle_position
 active=true
func _process(_dt):
 if not active:return false
 for i in range(12 if fast else 1):
  var previous=t;t+=1./30.
  # Only the PLAYER's opening cover advances are authored; defenders receive no script orders.
  for timing in [4.,14.,24.,34.,42.]:
   if previous<timing and t>=timing:
    var targets={"rifle":"cover_north_car_3","smg":"cover_south_car_3","pistol":"cover_north_bin_east","shotgun":"cover_south_bin_east"}
    for p in b.participants.values():
     if p.side_id!=b.attacker_side_id or not p.is_alive or p.is_wounded:continue
     if runtime.tactical_orders_controller.select_participant(p.participant_id):
      if timing<30:runtime.tactical_orders_controller.issue_cover(targets[p.weapon_type])
      else:runtime.tactical_orders_controller.issue_move(Vector2(30,25))
    runtime.tactical_orders_controller.clear_selection()
  Runtime.advance(b,1./30.)
  if not fast and t>=8. and not captured:captured=true;capture_hud()
  for e in b.combat_feedback_events:seen[e.sequence_id]=true
  if b.battle_phase=="resolved" or t>=55.:
   active=false;call_deferred("finish");return false
 return false
func finish():
 var movement={};var defenders=0
 for p in b.participants.values():
  if p.side_id==b.defender_side_id:movement[p.participant_id]=p.battle_position.distance_to(initial[p.participant_id]);defenders+=1 if p.is_alive else 0
 var report={"seconds":t,"phase":b.battle_phase,"shots":seen.size(),"ai_decisions":b.strength_events,"defender_displacement":movement,"defenders_alive":defenders}
 DirAccess.make_dir_recursive_absolute("res://tools/strength_review/results")
 FileAccess.open("res://tools/strength_review/results/review.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "));print("ADAPTIVE_REVIEW ",JSON.stringify(report))
 if not fast:
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("res://tools/strength_review/results/strength_hud.png")
 runtime.queue_free();await process_frame;await process_frame;quit()

func capture_hud():
 DirAccess.make_dir_recursive_absolute("res://tools/strength_review/results")
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("res://tools/strength_review/results/strength_hud_active.png")
