extends SceneTree
const Cases=preload("res://tools/sandbox_setup/scenarios.gd")
const Director=preload("res://tools/tactical_controls/estate_director.gd")
var errors=[]
var checks=0
var samples=[]
var out="C:/Users/brand/OneDrive/Documents/dead-street/tools/tactical_controls/hud_fixed_20260914"
func _initialize():call_deferred("run")
func check(ok,label):
 checks+=1
 if not ok:errors.append(label);printerr("HUD_FAIL ",label)
func run():
 DirAccess.make_dir_recursive_absolute(out)
 for map_id in ["river_bridge","whittaker_estate"]:
  root.size=Vector2i(1440,1000);DisplayServer.window_set_size(root.size)
  var scene=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(scene)
  await process_frame
  var config=Director.config() if map_id=="whittaker_estate" else Cases.make(12,12,["aegis","vigil","aegis"])
  config.map_id=map_id
  if map_id=="river_bridge":config.defender.vehicles=["bulwark","interceptor","bulwark"]
  await scene.start_battle(false,config)
  scene.set_process(false)
  var b=scene.battle
  check(b!=null,map_id+" creates battle")
  if b==null:continue
  var view=scene.runtime.get_node("TacticalBattleView")
  view.battle_presentation.skip_to_ready()
  await process_frame
  var begun=preload("res://gameplay/arsenal_battle_fixture.gd").begin_review(scene.runtime,b)
  check(begun!=null and begun.success,map_id+" starts")
  b.tactical_paused=true
  var hud=view.get_node("CommandHudLayer").get_child(0)
  var voices=0
  for n in view.get_children():
   if n.get_script()!=null and "tactical_faction_voices" in n.get_script().resource_path:voices+=1
  check(voices==0,map_id+" has no faction vocal player")
  for size in [Vector2i(1440,1000),Vector2i(1920,1080),Vector2i(1280,720)]:
   root.size=size;DisplayServer.window_set_size(size)
   await process_frame;await process_frame;await RenderingServer.frame_post_draw
   var rect=hud.surface.get_global_rect()
   var viewport_size=hud.get_viewport_rect().size
   var expected=226.*minf(viewport_size.x/1152.,viewport_size.y/800.)
   check(absf(rect.size.y-expected)<.1,map_id+" fixed bridge height "+str(size))
   check(rect.size.y/viewport_size.y<=.283,map_id+" bounded screen share")
   check(hud.cards.size()==(16 if map_id=="whittaker_estate" else 12),map_id+" complete roster")
   for id in hud.cards:
    var card=hud.cards[id]
    check(rect.encloses(card.get_global_rect()),map_id+" card enclosed "+id)
    for field in [card.weapon_symbol,card.portrait,card.weapon_model,card.status,card.number,card.command_status,card.health]:
     if not field.visible:continue
     check(Rect2(Vector2.ZERO,card.size).grow(.1).encloses(Rect2(field.position,field.size)),map_id+" card field enclosed "+str(field.name))
    check(not card.get_global_rect().intersects(Rect2(hud.surface.global_position+hud.command_row.position*hud.surface.scale,Vector2(1152,29)*hud.surface.scale)),map_id+" no card-command overlap")
   var debug_fields=[]
   for field in [hud.cards.values()[0].weapon_model,hud.cards.values()[0].status,hud.cards.values()[0].number,hud.cards.values()[0].command_status]:
    debug_fields.append({"name":str(field.name),"text":field.text,"pos":str(field.position),"size":str(field.size),"minimum":str(field.get_minimum_size())})
   print("HUD_FIELDS ",map_id," ",JSON.stringify(debug_fields))
   var label=map_id+"_"+str(size.x)+"x"+str(size.y)
   root.get_texture().get_image().save_png(out+"/"+label+".png")
   samples.append({"map":map_id,"viewport":[size.x,size.y],"hud_height":rect.size.y,"hud_fraction":rect.size.y/viewport_size.y,"cards":hud.cards.size(),"card_height":hud.cards.values()[0].size.y,"voices":voices})
  # Force representative card states in this paused review-only scene.
  var ids=hud.cards.keys()
  var wounded=b.get_participant(ids[0]);wounded.is_wounded=true
  var dead=b.get_participant(ids[1]);dead.is_alive=false
  view.orders_controller.select_participant(ids[2])
  await process_frame;await process_frame;await RenderingServer.frame_post_draw
  check(hud.cards[ids[0]].status.text=="WOUNDED",map_id+" wounded text")
  check(hud.cards[ids[1]].status.text=="ELIMINATED",map_id+" eliminated text")
  check(view.orders_controller.is_selected(ids[2]),map_id+" card selection")
  root.get_texture().get_image().save_png(out+"/"+map_id+"_states.png")
  scene.queue_free();await process_frame;await process_frame
 var report={"checks":checks,"errors":errors,"samples":samples,"faction_vocals_enabled":false}
 FileAccess.open(out+"/hud_layout.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
 print("HUD_LAYOUT ",JSON.stringify(report));quit(0 if errors.is_empty() else 1)
