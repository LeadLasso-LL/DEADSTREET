extends SceneTree
const Armor=preload("res://campaign/equipment/armor_catalog.gd")
const Service=preload("res://campaign/equipment/armor_service.gd")
const Starter=preload("res://gameplay/starter_world_service.gd")
const ArmorView=preload("res://gameplay/armor_selection_panel.gd")
const Fixture=preload("res://gameplay/arsenal_battle_fixture.gd")
const Card=preload("res://gameplay/tactical_unit_card.gd")
const Participant=preload("res://battle/core/battle_participant.gd")
const Identity=preload("res://battle/identity/tactical_identity_factory.gd")
var errors: Array=[]
var checks:=0
var output="res://tools/armor_equipment/review/"
func _initialize():call_deferred("run")
func check(ok: bool,message: String):
 checks+=1
 if not ok:errors.append(message)
func screenshot(name: String):
 if DisplayServer.get_name()=="headless":return
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(output+name+".png")
func run():
 DirAccess.make_dir_recursive_absolute(output)
 root.size=Vector2i(1152,860)
 var scene=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(scene)
 await process_frame
 for side: String in ["attacker","defender"]:
  for role: String in scene.CLASSES:
   var option: OptionButton=scene.armor_options[side+role]
   check(option.item_count==4,"all armors unlocked")
   for i in range(4):
    option.select(i);option.item_selected.emit(i)
    check(scene.loadouts[side].armor[role]==str(option.get_item_metadata(i)),"armor callback "+side+role)
   check(option.size.x<=170.1,"armor selector overlaps next column")
 scene.show_class("rifle");scene.choose("m4a1")
 scene.preview_armor="reinforced_carrier";scene.unit_tier=3;scene.refresh()
 await screenshot("sandbox")
 scene.open_armor_catalog();await process_frame
 var panel=scene.surface.get_node("ArmorCatalog")
 for id: String in Armor.IDS:check(panel.stock_labels.has(id) and panel.buy_buttons[id].disabled,"sandbox catalogue")
 await screenshot("armor_catalog")
 panel.equip("field_carrier");await process_frame
 check(scene.preview_armor=="field_carrier" and scene.armor_markers.tier==2,"preview selection")
 scene.ui.visible=false
 # Exercise campaign store actions via the actual UI, then save/load that world.
 var state=Starter.create();var gang=state.get_faction(Starter.PLAYER_FACTION_ID);gang.money=5000
 var layer=CanvasLayer.new();root.add_child(layer)
 var store=ArmorView.new();store.configure(state,Starter.PLAYER_FACTION_ID,false);layer.add_child(store)
 await process_frame
 store.buy_buttons.patrol_vest.pressed.emit();store.equip_buttons.patrol_vest.pressed.emit()
 var id=store.selected_soldier()
 check(state.get_soldier(id).armor_id=="patrol_vest" and gang.money==4700,"purchase/equip UI")
 await screenshot("campaign_store")
 store.queue_free();await process_frame
 var board=Control.new();layer.add_child(board);board.size=Vector2(1152,860)
 var bg=ColorRect.new();board.add_child(bg);bg.size=board.size;bg.color=Color("#172127")
 var font=SystemFont.new();font.font_names=PackedStringArray(["Arial"])
 Card.label(board,Vector2(50,60),Vector2(1000,60),"EQUIPMENT / TRAINING + ARMOR",28,Color("#dbe0df"),font)
 Card.label(board,Vector2(50,122),Vector2(1000,55),"Gold stars: unit training     Silver-ringed blue circles: equipped armor",17,Color("#aebac4"),font)
 for i in range(4):
  var p=Participant.new("hud","hud","trc","attacker","rifle")
  p.identity=Identity.make("hud","trc","rifle");p.weapon_model_id="m4a1";p.unit_tier=3;p.armor_id="" if i==0 else Armor.IDS[i-1];p.vitality=p.max_vitality
  var w=Card.build(board,Vector2(80+i*267,240),font);Card.update(w,p);w.root.scale=Vector2(1.5,1.5)
  check(w.armor.tier==i and w.stars.tier==3,"HUD markers independent")
  check(is_equal_approx(w.health.size.x,123.),"armored full bar")
  Card.label(board,Vector2(80+i*267,450),Vector2(240,80),Armor.label(p.armor_id)+"\nHP capacity: %d%%"%roundi(100.*(1.+Armor.bonus(p.armor_id))),17,Color("#c6d1d7"),font)
 await screenshot("hud_markers")
 board.queue_free();await process_frame
 var gun_board=Control.new();layer.add_child(gun_board);gun_board.size=Vector2(1152,860)
 var gun_bg=ColorRect.new();gun_board.add_child(gun_bg);gun_bg.size=gun_board.size;gun_bg.color=Color("#233036")
 Card.label(gun_board,Vector2(50,50),Vector2(1050,60),"RIFLE REFINEMENTS / EXISTING TRC RIG",27,Color("#e0e4dd"),font)
 var anim=preload("res://battle/presentation/tactical_unit_animation_catalog.gd")
 var poses=["idle_sw","idle_s","idle_e","aim_sw","aim_nw"]
 for row in range(2):
  var model: String="g36c" if row==0 else "m4a1"
  Card.label(gun_board,Vector2(50,135+row*335),Vector2(1000,40),model.to_upper(),22,Color("#c7d3dc"),font)
  for column in range(poses.size()):
   var actor=AnimatedSprite2D.new();gun_board.add_child(actor);actor.position=Vector2(135+column*223,320+row*335);actor.scale=Vector2.ONE*1.8;actor.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
   actor.sprite_frames=anim.frames_for(anim.variant_for("trc","rifle",model));actor.animation=poses[column];actor.frame=0
   Card.label(gun_board,Vector2(60+column*223,185+row*335),Vector2(170,30),poses[column].replace("_"," ").to_upper(),13,Color("#adbbc3"),font)
 await screenshot("rifle_refinement")
 layer.queue_free();await process_frame
 # Build a real 5v5 battle with armor selected in every slot.
 var runtime=load("res://gameplay/gameplay_runtime.tscn").instantiate();root.add_child(runtime)
 await process_frame
 var result=Fixture.setup(runtime,scene.loadouts,false,71203,true)
 check(result.has("battle"),"armored battle setup")
 if result.has("battle"):
  var b=result.battle
  check(b.participants.size()==10,"ten armored participants")
  for p in b.participants.values():
   check(p.armor_id=="reinforced_carrier" and is_equal_approx(p.vitality,2.25),"armor transferred at setup")
   var soldier=runtime.game_state.get_soldier(p.campaign_soldier_id)
   check(soldier.armor_id==p.armor_id,"campaign/battle equipment matches")
  var deployed=runtime.game_state.get_soldier(Starter.SOLDIER_ID)
  var locked=Service.equip(runtime.game_state,Starter.PLAYER_FACTION_ID,deployed.id,"")
  check(not locked.success,"deployed equipment cannot change")
 print("ARMOR_UI checks=",checks," errors=",errors)
 runtime.queue_free();scene.queue_free();await process_frame
 quit(0 if errors.is_empty() else 1)
