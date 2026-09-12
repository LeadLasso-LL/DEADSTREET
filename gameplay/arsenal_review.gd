extends Node
const Weapons=preload("res://battle/combat/battle_weapon_catalog.gd")
const Anim=preload("res://battle/presentation/tactical_unit_animation_catalog.gd")
const Fixture=preload("res://gameplay/arsenal_battle_fixture.gd")
const Runtime=preload("res://battle/runtime/battle_runtime_service.gd")
const Card=preload("res://gameplay/tactical_unit_card.gd")
const Factions=preload("res://battle/identity/faction_unit_catalog.gd")
const Tiers=preload("res://battle/combat/battle_unit_tier_catalog.gd")
const Stars=preload("res://gameplay/unit_tier_stars.gd")
const CLASSES=["pistol","smg","shotgun","rifle","sniper"]
var ui: CanvasLayer
var surface: Control
var grid: GridContainer
var name_label: Label
var stats: Label
var note: Label
var sprite: AnimatedSprite2D
var icon: TextureRect
var sound: AudioStreamPlayer
var direction="sw"
var clip="idle"
var faction="orlov"
var unit_tier=1
var tier_stars: Control
var unit_tier_select: OptionButton
var animation_select: OptionButton
var faction_select: OptionButton
var selected="glock_17"
var mercer_specialist=false
var loadouts={"attacker":{"faction":"orlov","unit_tiers":{}},"defender":{"faction":"mercer","unit_tiers":{}}}
var loadout_options={}
var side_options={}
var font: SystemFont
var runtime: Node
var battle
var ready_started=false
var battle_clock=0.
var seed_value=4101
func _ready():
 font=SystemFont.new();font.font_names=PackedStringArray(["Arial"])
 sound=AudioStreamPlayer.new();add_child(sound);sound.volume_db=-10
 ui=CanvasLayer.new();ui.layer=80;add_child(ui)
 surface=Control.new();ui.add_child(surface);surface.size=Vector2(1152,860)
 var bg=ColorRect.new();surface.add_child(bg);bg.size=surface.size;bg.color=Color("#121c20")
 text(Vector2(28,20),Vector2(850,36),"DEAD STREET  /  BATTLE SANDBOX",26)
 note=text(Vector2(28,58),Vector2(1100,25),"23 factions · 115 outfits · 30 weapons · All factions, weapons and unit tiers unlocked",13)
 for i in range(CLASSES.size()):button(surface,Vector2(28+i*221,95),Vector2(209,35),CLASSES[i].to_upper(),show_class.bind(CLASSES[i]))
 grid=GridContainer.new();surface.add_child(grid);grid.position=Vector2(28,148);grid.columns=2;grid.add_theme_constant_override("h_separation",12);grid.add_theme_constant_override("v_separation",12)
 name_label=text(Vector2(658,146),Vector2(470,30),"",22)
 stats=text(Vector2(658,180),Vector2(230,245),"",14);stats.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 sprite=AnimatedSprite2D.new();surface.add_child(sprite);sprite.position=Vector2(996,320);sprite.scale=Vector2(2.7,2.7);sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 icon=TextureRect.new();surface.add_child(icon);icon.position=Vector2(658,451);icon.size=Vector2(230,47);icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;icon.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;icon.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 var dir=OptionButton.new();surface.add_child(dir);dir.position=Vector2(658,506);dir.size=Vector2(92,32)
 for id in ["sw","s","se","e","ne","n","nw","w"]:dir.add_item(id.to_upper());dir.set_item_metadata(dir.item_count-1,id)
 dir.item_selected.connect(func(i):direction=str(dir.get_item_metadata(i));refresh())
 animation_select=OptionButton.new();surface.add_child(animation_select);animation_select.position=Vector2(762,506);animation_select.size=Vector2(167,32)
 for id in Anim.bound_clip_ids():
  if id in ["fire_left","cover_fire_left"]:continue
  animation_select.add_item(id.replace("_"," ").capitalize());animation_select.set_item_metadata(animation_select.item_count-1,id)
  if id=="idle":animation_select.select(animation_select.item_count-1)
 animation_select.item_selected.connect(func(i):clip=str(animation_select.get_item_metadata(i));refresh())
 button(surface,Vector2(942,506),Vector2(158,32),"PLAY REPORT",play_report)
 faction_select=faction_option(Vector2(28,506),Vector2(280,32),faction)
 faction_select.item_selected.connect(func(i):faction=str(faction_select.get_item_metadata(i));refresh())
 var tier_option=OptionButton.new();surface.add_child(tier_option);tier_option.position=Vector2(320,506);tier_option.size=Vector2(210,32)
 unit_tier_select=tier_option
 for rank in range(1,4):tier_option.add_item("Unit %d - %s"%[rank,Tiers.label_for(rank)])
 tier_option.item_selected.connect(func(i):unit_tier=i+1;refresh())
 tier_stars=Stars.new();surface.add_child(tier_stars);tier_stars.position=Vector2(550,516)
 var special=CheckButton.new();surface.add_child(special);special.position=Vector2(28,548);special.text="Mercer dual-pistol specialist (defender pistol slot)";special.add_theme_font_size_override("font_size",12)
 special.toggled.connect(func(on):
  mercer_specialist=on
  loadouts["defender"]["specialist"]="mercer_dual_glock" if on else ""
  loadout_options["defenderpistol"].disabled=on
  side_options["defender"].disabled=on
  if on:
   faction="mercer"
   loadouts["defender"]["faction"]="mercer"
   side_options["defender"].select(Factions.all_ids().find("mercer"))
   loadouts["defender"]["pistol"]="glock_17"
   var option=loadout_options["defenderpistol"]
   for i in range(option.item_count):
    if option.get_item_metadata(i)=="glock_17":option.select(i)
   faction_select.select(Factions.all_ids().find("mercer"))
   show_class("pistol");choose("glock_17")
  refresh())
 text(Vector2(28,590),Vector2(1080,20),"BATTLE LOADOUTS  /  Any weapon within its class. Stars represent unit training, independently of weapon tier.",12)
 for side_index in range(2):
  var side: String="attacker" if side_index==0 else "defender"
  var row_y: int=648+side_index*79
  text(Vector2(28,row_y-24),Vector2(180,20),side.to_upper(),12)
  var team=faction_option(Vector2(28,row_y),Vector2(190,31),str(loadouts[side]["faction"]))
  side_options[side]=team
  team.item_selected.connect(func(i):loadouts[side]["faction"]=str(team.get_item_metadata(i)))
  for c in range(CLASSES.size()):
   var kind: String=CLASSES[c]
   var x: int=232+c*178
   text(Vector2(x,row_y-24),Vector2(164,20),kind.to_upper()+" / UNIT TIER",10)
   var select=OptionButton.new();surface.add_child(select);select.position=Vector2(x,row_y);select.size=Vector2(123,31);select.add_theme_font_size_override("font_size",10);select.fit_to_longest_item=false;select.clip_text=true;select.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS
   for id in Weapons.models_for_class(kind):
    var d=Weapons.get_model(id);select.add_item(d.display_name);select.set_item_metadata(select.item_count-1,id)
    select.set_item_tooltip(select.item_count-1,"Weapon tier %d - %s"%[d.tier,d.display_name])
    if id==Weapons.default_model(kind):select.select(select.item_count-1)
   loadouts[side][kind]=str(select.get_item_metadata(select.selected));loadout_options[side+kind]=select
   select.item_selected.connect(func(i):loadouts[side][kind]=str(select.get_item_metadata(i)))
   var rank=OptionButton.new();rank.name=side+"_"+kind+"_tier";surface.add_child(rank);rank.position=Vector2(x+128,row_y);rank.size=Vector2(42,31)
   for tier in range(1,4):rank.add_item(str(tier));rank.set_item_tooltip(tier-1,Tiers.label_for(tier))
   rank.item_selected.connect(func(i):loadouts[side]["unit_tiers"][kind]=i+1)
   loadouts[side]["unit_tiers"][kind]=1
 button(surface,Vector2(826,797),Vector2(284,39),"TEST 5v5 - ALL FIVE CLASSES",start_battle.bind(false))
 text(Vector2(28,800),Vector2(775,42),"Esc returns to the sandbox. Unit-tier bonuses are initial balance values for testing.\nGuide weapon pairings are suggestions; they do not limit these loadouts.",12)
 show_class("pistol")
func text(at: Vector2,sz: Vector2,value: String,points: int) -> Label:
 return Card.label(surface,at,sz,value,points,Color("#d5ddcf"),font)
func button(parent: Node,at: Vector2,sz: Vector2,value: String,action: Callable) -> Button:
 var b=Button.new();parent.add_child(b);b.position=at;b.custom_minimum_size=sz;b.text=value;b.add_theme_font_override("font",font);b.add_theme_font_size_override("font_size",13)
 b.add_theme_stylebox_override("normal",Card.style(Color("#243136"),Color("#4e605d")));b.add_theme_stylebox_override("hover",Card.style(Color("#3d4945"),Color("#a1ac91")));b.pressed.connect(action);return b
func show_class(kind: String):
 for c in grid.get_children():grid.remove_child(c);c.queue_free()
 var ids=Weapons.models_for_class(kind)
 for id in ids:
  var d=Weapons.get_model(id);var b=button(grid,Vector2.ZERO,Vector2(292,106),"",choose.bind(id));b.set_meta("model",id)
  Card.label(b,Vector2(12,10),Vector2(268,20),"T%d  %s"%[d.tier,d.display_name],12,Color("#e0e1d3"),font)
  Card.label(b,Vector2(220,57),Vector2(64,36),"MOVE\n%+.0f%%"%((d.movement_multiplier-1.)*100.),10,Color("#adbdab"),font)
  var thumbnail=TextureRect.new();b.add_child(thumbnail);thumbnail.position=Vector2(7,32);thumbnail.size=Vector2(208,64);thumbnail.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;thumbnail.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED;thumbnail.mouse_filter=Control.MOUSE_FILTER_IGNORE;thumbnail.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
  var path="res://assets/art/weapons/arsenal/icons/"+id+".png";thumbnail.texture=load(path) if ResourceLoader.exists(path) else null
 choose(ids[0])
func choose(id: String):selected=id;refresh()
func refresh():
 for b in grid.get_children():b.add_theme_stylebox_override("normal",Card.style(Color("#39443c") if b.get_meta("model")==selected else Color("#243136"),Color("#b4b18c") if b.get_meta("model")==selected else Color("#4e605d")))
 var d=Weapons.get_model(selected)
 var special=mercer_specialist and faction=="mercer" and selected=="glock_17"
 if special:d=preload("res://battle/combat/battle_specialist_catalog.gd").profile(d)
 d=Tiers.profile(d,unit_tier)
 tier_stars.tier=unit_tier
 unit_tier_select.select(unit_tier-1)
 faction_select.select(Factions.all_ids().find(faction))
 name_label.text=d.display_name+"  /  WEAPON T"+str(d.tier)
 name_label.add_theme_font_size_override("font_size",18 if name_label.text.length()>34 else 22)
 stats.text="%s CLASS\n\nRange: %.1f\nShot pace: %.2f / sec\nSolid trauma: %.2f\nCritical trauma: %.2f\nInitial aim: %.2f sec\nMovement: %+.0f%%\n\nRange and trauma use game units."%[d.weapon_type_id.to_upper(),d.max_range,d.shots_per_second,d.solid_trauma,d.critical_trauma,d.acquire_seconds,(d.movement_multiplier-1.)*100.]
 stats.text += "\nUnit %d - %s"%[unit_tier,Tiers.label_for(unit_tier)]
 stats.text += "\nMagazine: %d • Reload: %.1fs"%[d.magazine_capacity,d.reload_seconds]
 var variant=Anim.variant_for(faction,d.weapon_type_id,selected,"mercer_dual_glock" if special else "");sprite.sprite_frames=Anim.frames_for(variant)
 if sprite.sprite_frames!=null:
  var animation=Anim.animation_name(clip,direction)
  if not sprite.sprite_frames.has_animation(animation):animation=Anim.animation_name("idle",direction)
  sprite.stop();sprite.speed_scale=float(sprite.sprite_frames.get_frame_count(animation))/(d.reload_seconds*Anim.clip_fps("reload")) if clip=="reload" else 1.;sprite.play(animation)
 var path="res://assets/art/weapons/arsenal/icons/"+selected+".png";icon.texture=load(path) if ResourceLoader.exists(path) else null
func play_report():
 var path="res://assets/audio/weapons/"+selected+"_0.wav"
 if ResourceLoader.exists(path):sound.stream=load(path);sound.play()
func start_battle(snipers: bool):
 if runtime!=null:return
 runtime=load("res://gameplay/gameplay_runtime.tscn").instantiate();add_child(runtime)
 await get_tree().process_frame
 var result=Fixture.setup(runtime,loadouts,snipers,seed_value,true);seed_value+=1
 if not result.has("battle"):
  note.text="Test could not start: "+str(result);runtime.queue_free();runtime=null;return
 battle=result.battle;ready_started=false;battle_clock=0.;ui.visible=false
func _process(delta: float):
 if surface!=null:
  var viewport=get_viewport().get_visible_rect().size;var scale_factor=minf(viewport.x/1152.,viewport.y/860.);surface.scale=Vector2.ONE*scale_factor;surface.position=(viewport-Vector2(1152,860)*scale_factor)*.5
 if battle==null:return
 if not ready_started:
  var director=runtime.get_node("TacticalBattleView").battle_presentation
  if director.stage=="ready" and director.ready_clock>.7:
   var begin=Fixture.begin_review(runtime, battle);ready_started=begin!=null and begin.success
   if ready_started:
    for force_id in battle.get_sorted_tactical_force_ids():
     if battle.get_tactical_force(force_id).side_id==battle.attacker_side_id:preload("res://battle/core/battle_force_command_service.gd").set_command(battle,force_id,"push")
  return
 if battle.battle_phase=="active":
  battle_clock+=delta
  Runtime.advance(battle,minf(delta,.1))
func _input(event: InputEvent):
 if event is InputEventKey and event.pressed and event.keycode==KEY_ESCAPE and runtime!=null:
  runtime.queue_free();runtime=null;battle=null;ui.visible=true;get_viewport().set_input_as_handled()

func faction_option(at: Vector2,sz: Vector2,chosen: String) -> OptionButton:
 var option=OptionButton.new();surface.add_child(option);option.position=at;option.size=sz;option.fit_to_longest_item=false;option.clip_text=true;option.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS;option.add_theme_font_size_override("font_size",11)
 for id in Factions.all_ids():
  option.add_item(Factions.display_name(id));option.set_item_metadata(option.item_count-1,id)
  option.set_item_tooltip(option.item_count-1,Factions.display_name(id))
  if id==chosen:option.select(option.item_count-1)
 return option
