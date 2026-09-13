extends SceneTree
const Cases=preload("res://tools/sandbox_setup/scenarios.gd")
const Config=preload("res://gameplay/sandbox_force_config.gd")
const Anim=preload("res://battle/presentation/tactical_unit_animation_catalog.gd")
var errors=[]
var checks=0
var output="res://tools/sandbox_setup/results/"
var scene
var records=[]
func _initialize():call_deferred("run")
func check(ok: bool,label: String):
 checks+=1
 if not ok:errors.append(label);printerr("FLEXIBLE_UI_FAIL ",label)
func capture(name: String):
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(output+name+".png")
func find_hud(node: Node):
 if node.get_script()!=null and node.get_script().resource_path=="res://gameplay/tactical_command_hud.gd":return node
 for child in node.get_children():
  var found=find_hud(child)
  if found!=null:return found
 return null
func wait_active():
 var started=Time.get_ticks_msec()
 while Time.get_ticks_msec()-started<50000:
  await process_frame
  if scene.battle!=null and scene.battle.battle_phase=="active":return true
 return false
func run():
 DirAccess.make_dir_recursive_absolute(output);root.size=Vector2i(1152,860);DisplayServer.window_set_size(root.size)
 scene=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(scene);await process_frame
 scene.open_force_builder();await process_frame;var panel=scene.surface.get_node("ForceBuilder")
 check(panel.config.attacker.units.size()==5 and panel.config.defender.units.size()==5,"default faction forces")
 var chooser=panel.faction_options.attacker;var idx=Config.Factions.all_ids().find("trc");chooser.select(idx);chooser.item_selected.emit(idx)
 check(panel.config.attacker.faction=="trc" and panel.config.attacker.units.size()==5,"faction change preserves roster")
 panel.duplicate_unit("attacker",3);panel.duplicate_unit("attacker",4)
 check(panel.config.attacker.units.size()==7,"duplicate units")
 var w=panel.row_widgets.attacker[4].weapon;w.select(4);w.item_selected.emit(4)
 panel.row_widgets.attacker[4].tier.select(2);panel.row_widgets.attacker[4].tier.item_selected.emit(2)
 panel.row_widgets.attacker[4].armor.select(3);panel.row_widgets.attacker[4].armor.item_selected.emit(3)
 check(panel.config.attacker.units[3].tier==1 and panel.config.attacker.units[4].tier==3,"duplicate equipment independent")
 check(panel.config.attacker.units[4].weapon==Config.Weapons.models_for_class("rifle")[4],"individual duplicate weapon")
 panel.remove_unit("defender",4);panel.remove_unit("defender",3)
 panel.config.attacker.vehicles=["bayou"];panel.changed();check(panel.start_button.disabled,"UI blocks insufficient seats")
 panel.auto_fit();check(not panel.start_button.disabled and panel.config.attacker.vehicles.size()==2,"auto-fit actual attacker count")
 panel.open_fleet();await process_frame;var fleet=panel.get_node("VehicleFleet")
 check(fleet.required_units==7,"fleet receives force size");fleet.queue_free();await process_frame
 panel.config.defender.units=[];panel.refresh_side("defender");check(panel.start_button.disabled,"UI blocks empty enemy")
 panel.add_unit("defender","rifle");panel.duplicate_unit("defender",0);panel.add_unit("defender","sniper")
 check(not panel.start_button.disabled,"uneven composition ready")
 await capture("flexible_setup")
 var chosen=panel.config.duplicate(true);panel.start_button.pressed.emit()
 var active=await wait_active();check(active,"7v3 reaches active battle")
 if active:
  var battle=scene.battle;var view=scene.runtime.get_node("TacticalBattleView")
  check(battle.participants.size()==10,"7v3 exact ten participants")
  check(view.battle_presentation.last_path_errors.is_empty(),"7v3 arrival paths")
  for p in battle.participants.values():check(p.identity.gang_archetype_id==chosen[p.side_id].faction,"selected faction outfit "+p.participant_id)
  await create_timer(4.).timeout;await capture("uneven_battle")
  var hud=find_hud(scene.runtime);check(hud!=null,"HUD exists")
  if hud!=null:
   check(hud.roster_pages==2,"seven units have two HUD pages")
   hud.page_next.pressed.emit();await process_frame;check(hud.page_index==1 and hud.cards[0].root.visible and not hud.cards[2].root.visible,"last HUD page complete")
   var selected_id=hud.cards[0].id;var p=battle.get_participant(selected_id)
   if p.is_alive and not p.is_wounded:hud.cards[0].root.pressed.emit();check(view._selected_participant_id()==selected_id,"page card selects correct unit")
   await capture("hud_second_page")
  records.append({"scenario":"7v3","participants":battle.participants.size(),"shots":battle.combat_feedback_events.size()})
 scene.return_to_setup();await process_frame
 check(scene.custom_loadouts==chosen and panel.config==chosen,"return keeps exact roster and gear")
 # Exercise a full heavy transport and the 24-unit HUD/results surfaces.
 panel.queue_free();await process_frame
 scene.custom_loadouts=Cases.make(12,12,["lastlight"]);scene.open_force_builder();await process_frame;panel=scene.surface.get_node("ForceBuilder")
 check(panel.add_buttons.attacker.disabled and panel.add_buttons.defender.disabled,"12-unit limits visible")
 var before=panel.config.duplicate(true);panel.add_unit("attacker","rifle");check(before==panel.config,"add cannot exceed map cap")
 panel.launch();active=await wait_active();check(active,"12v12 heavy transport reaches active battle")
 if active:
  var b=scene.battle;var view=scene.runtime.get_node("TacticalBattleView");var director=view.battle_presentation
  check(b.participants.size()==24 and b.vehicles.size()==1,"24 units and selected heavy")
  check(director.last_path_errors.is_empty(),"12v12 arrival paths")
  var paths={}
  for p in b.participants.values():
   var key=Anim.variant_for(p.identity.gang_archetype_id,p.weapon_type,p.weapon_model_id);paths[key]=true
   check(view.actor_presenter._unit_nodes.has(p.participant_id),"actor present "+p.participant_id)
  await create_timer(4.).timeout
  var hud=find_hud(scene.runtime)
  check(hud!=null and hud.roster_pages==3,"twelve units have three HUD pages")
  if hud!=null:hud.page_next.pressed.emit();hud.page_next.pressed.emit();await process_frame
  await capture("large_battle")
  records.append({"scenario":"12v12","participants":b.participants.size(),"variants":paths.size(),"shots":b.combat_feedback_events.size()})
  # Controlled terminal-state fixture checks all casualty cards and return flow.
  # This is test-only; ordinary battles retain their normal elimination rules.
  for p in b.participants.values():
   if p.side_id==b.defender_side_id:p.is_alive=false;p.vitality=0.
  var result=load("res://battle/core/battle_victory_service.gd").resolve_if_terminal(b);check(result.resolved,"terminal fixture resolves")
  var until=Time.get_ticks_msec()+30000
  while Time.get_ticks_msec()<until and not director.results_visible():await process_frame
  check(director.results_visible(),"results reached")
  if director.results_visible():
   check(director.result_cards.size()==24 and director.result_snapshot.attacker.size()==12 and director.result_snapshot.defender.size()==12,"results include every unit")
   await create_timer(1.5).timeout;await capture("large_results")
   for column in range(2):
    var result_panel=director.result_root.get_child(column)
    for child in result_panel.get_children():
     if child is ScrollContainer:child.scroll_vertical=999
   await capture("large_results_bottom")
   director.continue_button.pressed.emit();await process_frame;await process_frame
   check(scene.battle==null and scene.ui.visible,"continue returns to retained builder")
   check(panel.config==before,"results do not mutate setup")
 var report={"checks":checks,"errors":errors,"battles":records,"terminal_results_fixture":true}
 FileAccess.open(output+"review.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
 print("FLEXIBLE_NATIVE ",report);quit(0 if errors.is_empty() else 1)
