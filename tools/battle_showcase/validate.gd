extends SceneTree
const Scenario=preload("res://tools/battle_showcase/scenario.gd")
const Anim=preload("res://battle/presentation/tactical_unit_animation_catalog.gd")
const Query=preload("res://gameplay/tactical_unit_hud_query.gd")
var runtime
var checks=0
var problems: Array[String]=[]
func _initialize():call_deferred("start")
func verify(ok: bool,message: String):
 checks+=1
 if not ok:problems.append(message)
func start():
 runtime=load("res://gameplay/gameplay_runtime.tscn").instantiate();root.add_child(runtime)
 await process_frame
 var result=Scenario.setup(runtime,3107)
 if not result.has("battle"):push_error(str(result));quit(1);return
 var battle=result.battle
 var view=runtime.get_node("TacticalBattleView")
 var hud
 for child in view.get_children():
  if child is CanvasLayer and child.layer==30:hud=child.get_child(0)
 await process_frame
 verify(hud!=null and hud.visible,"HUD visible")
 verify(hud.cards.size()==4,"four friendly cards")
 for command in ["push","hold","focus_left","focus_right","fall_back"]:
  hud.issue_command(command)
  for id in battle.get_sorted_tactical_force_ids():
   var f=battle.get_tactical_force(id)
   verify(f.command_id==(command if f.side_id==battle.attacker_side_id else "hold"),"command isolation "+command)
 var p=battle.get_participant(str(hud.cards[0].id))
 p.vitality=.75;p.is_wounded=true
 await process_frame
 verify(hud.cards[0].status.text=="WOUNDED","live wounded label")
 verify(absf(hud.cards[0].health.size.x-61.5)<.01,"live half vitality bar")
 verify(hud.cards[0].portrait.modulate.g<.8,"wounded portrait tint")
 p.is_alive=false;p.vitality=0.
 await process_frame
 verify(hud.cards[0].status.text=="DEAD","live dead label")
 verify(hud.cards[0].health.size.x==0.,"dead bar empty")
 verify(hud.cards[0].portrait.modulate.g<.3,"deep red dead portrait")
 verify(hud.cards[0].root.disabled,"dead card cannot issue orders")
 p.is_alive=true;p.is_wounded=false;p.vitality=1.5
 await process_frame
 verify(hud.cards[0].status.text=="ACTIVE","active label")
 verify(hud.cards[0].health.size.x==123.,"full health bar")
 for unit in battle.participants.values():
  var variant=Anim.variant_for(unit.identity.gang_archetype_id,unit.weapon_type)
  var frames=Anim.frames_for(variant)
  verify(ResourceLoader.exists("res://assets/art/units/pixel_v1/portraits/"+variant+".png"),"portrait "+variant)
  for direction in Anim.IMPLEMENTED_DIRECTION_IDS:
   for clip in ["idle","walk","fire","reload","wounded_walk","death","death_back"]:
    var name=clip+"_"+direction
    verify(frames.has_animation(name),"bound clip "+variant+" "+name)
   verify(frames.get_frame_count("death_back_"+direction)==32,"backward frames "+variant+direction)
   verify(not frames.get_animation_loop("death_back_"+direction),"death holds "+variant+direction)
  verify(unit.identity.is_valid(),"identity "+variant)
 var nav=preload("res://battle/navigation/battle_navigation_service.gd")
 for id in battle.battlefield_geometry.get_sorted_cover_slot_ids():
  verify(nav.is_reachable(battle,Vector2(49,30),battle.battlefield_geometry.get_cover_slot(id).position),"reachable cover "+id)
 print("SHOWCASE_VALIDATION checks=",checks," problems=",problems)
 DirAccess.make_dir_recursive_absolute("res://tools/battle_showcase/results")
 FileAccess.open("res://tools/battle_showcase/results/validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"problems":problems},"  "))
 quit(0 if problems.is_empty() else 1)
