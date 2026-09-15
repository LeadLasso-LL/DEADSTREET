extends SceneTree
const Config=preload("res://gameplay/sandbox_force_config.gd")
const Maps=preload("res://gameplay/sandbox_map_catalog.gd")
const Rules=preload("res://gameplay/sandbox_convoy_rules.gd")
const Formation=preload("res://campaign/vehicles/convoy_formation_catalog.gd")
var errors=[]
var checks=0
var report=[]
func _initialize():call_deferred("run")
func expect(value: bool,detail: String):
 checks+=1
 if not value:errors.append(detail);push_error(detail)
func run():
 for id in Maps.IDS:expect(Config.max_units(id)==16,id+" cap16")
 for faction in ["stateline","blacktop","nbpd","trc"]:
  expect(Formation.slots(["ironhorse","bayou","ironhorse","ironhorse","bayou"],faction).size()==3,faction+" bike packing")
  expect(Formation.slots(["ironhorse","ironhorse","ironhorse","ironhorse","ironhorse","ironhorse","ironhorse","ironhorse","ironhorse"],faction).size()==3,faction+" nine motorcycles")
 expect(Formation.slots(["ironhorse","ironhorse","ironhorse"],"orlov").size()==3,"Non-bike faction uses individual slots")
 expect(not Rules.addition(["roadwarden","roadwarden","roadwarden"],"roadwarden",16,"trc").valid,"Fourth Roadwarden blocked")
 expect(not Rules.addition(["bayou","bayou"],"bayou",16,"orlov").valid,"Insufficient last-slot seats blocked")
 expect(Rules.addition(["bayou","bayou"],"shuttle",16,"orlov").valid,"Last-slot transport allowed")
 expect(not Rules.addition(["bayou"],"bayou",1,"orlov").valid,"Driver limit")
 for count in range(1,17):expect(Rules.check(Rules.auto_fit(count),count,"orlov").valid,"Auto-fit "+str(count))
 var scene=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(scene)
 await process_frame;scene.set_process(false)
 var builder=scene.menu_panels.builder
 for dims in [Vector2(1504,860),Vector2(1728,972),Vector2(2064,860)]:
  scene.menu_panels.arrange(dims)
  await process_frame
  expect(builder.side_panels.attacker.get_rect().end.x<builder.map_selector.position.x,"Left panel clears map")
  expect(builder.map_selector.get_rect().end.x<builder.side_panels.defender.position.x,"Map clears right panel")
  expect(builder.convoy_strips.attacker.position.y>builder.side_panels.attacker.get_rect().end.y,"Convoy below force setup")
  expect(builder.badges.attacker.size==Vector2(80,80),"Large emblem")
 for id in Maps.IDS:
  builder.choose_map(id)
  expect(builder.config.attacker.units.size()==Maps.info(id).count,id+" preset count")
  expect(builder.config.attacker.faction=="orlov" and builder.config.defender.faction=="mercer",id+" factions retained")
  expect(Config.validate(builder.config).valid,id+" preset valid")
  var keep=builder.config.duplicate(true);builder.choose_map(id);expect(builder.config==keep,"Same map preserves edits")
  for count in [Maps.info(id).count,16]:
   var setup=Maps.preset(id)
   if count==16:
    for side in ["attacker","defender"]:
     setup[side].units=[]
     for i in range(16):setup[side].units.append(Config.unit(Config.CLASSES[i%5]))
     setup[side].erase("vehicle_occupants")
     if side=="attacker" or id=="river_bridge":setup[side].vehicles=Rules.auto_fit(16,setup[side].faction)
   await scene.start_battle(false,setup)
   expect(scene.battle!=null,"Launch "+id+" "+str(count))
   if scene.battle!=null:
    for i in range(12):await process_frame
    var b=scene.battle;var view=scene.runtime.get_node("TacticalBattleView")
    expect(b.participants.size()==count*2,id+" actual participant count")
    var covered=0
    for p in b.participants.values():
     expect(p.has_battle_position,id+" deployed "+p.participant_id)
     if p.has_occupied_cover_slot():covered+=1
    report.append({"map":id,"units":count,"covered":covered,"arrival_errors":view.battle_presentation.last_path_errors})
    expect(view.battle_presentation.last_path_errors.is_empty(),id+" arrival paths")
   scene.return_to_setup();await process_frame
 # Actual button states, removals and guarded signal path.
 var fleet=preload("res://gameplay/vehicle_fleet_panel.gd").new();fleet.required_units=16;fleet.faction_id="trc";fleet.selected=["roadwarden","roadwarden","roadwarden"];root.add_child(fleet)
 await process_frame;fleet.selected_class="heavy_transports";fleet.refresh_models()
 for id in fleet.model_buttons:expect(fleet.model_buttons[id].button.disabled,"All fourth vehicles disabled")
 fleet.try_add("roadwarden");expect(fleet.selected.size()==3,"Guarded illegal add")
 fleet.selected.remove_at(2);fleet.refresh_convoy();expect(not fleet.model_buttons.roadwarden.button.disabled,"Removal re-enables valid add")
 expect(fleet.convoy_row.cells.size()==3,"Exactly three visible slots")
 var file=FileAccess.open("res://tools/sandbox_maps_20260915/check.json",FileAccess.WRITE);file.store_string(JSON.stringify({"checks":checks,"errors":errors,"launches":report},"\t"))
 print("SANDBOX_MAP_CHECK ",JSON.stringify({"checks":checks,"errors":errors,"launches":report}));quit(0 if errors.is_empty() else 1)
