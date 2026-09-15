extends SceneTree
const Maps=preload("res://gameplay/sandbox_map_catalog.gd")
const Config=preload("res://gameplay/sandbox_force_config.gd")
var reports=[]
var errors=[]
func _initialize():call_deferred("run")
func run():
 var scene=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(scene);await process_frame;scene.set_process(false)
 for faction in ["stateline","blacktop","nbpd","trc"]:
  for map in Maps.IDS:
   var c=Maps.preset(map);c.attacker.faction=faction
   var bike="ironhorse" if faction in ["stateline","blacktop"] else "marshal" if faction=="nbpd" else "outrider"
   c.attacker.vehicles=[bike,"bayou",bike,bike,"shuttle"];c.attacker.erase("vehicle_occupants")
   c.attacker.units=[]
   for i in range(16):c.attacker.units.append(Config.unit(Config.CLASSES[i%5]))
   await scene.start_battle(false,c)
   if scene.battle==null:errors.append({"faction":faction,"map":map,"error":scene.note.text})
   else:
    for i in range(12):await process_frame
    var b=scene.battle;var view=scene.runtime.get_node("TacticalBattleView");var people=0;var group_sizes=[]
    for v in b.vehicles.values():
     if v.side_id==b.attacker_side_id:
      people+=v.get_meta("convoy_occupants",[]).size();group_sizes.append(int(v.get_meta("convoy_group_size",1)))
    if people!=16:errors.append({"faction":faction,"map":map,"error":"Wrong manifest count"})
    if not view.battle_presentation.last_path_errors.is_empty():errors.append({"faction":faction,"map":map,"error":view.battle_presentation.last_path_errors})
    reports.append({"faction":faction,"map":map,"people":people,"group_sizes":group_sizes})
   scene.return_to_setup();await process_frame
 FileAccess.open("res://tools/sandbox_maps_20260915/groups.json",FileAccess.WRITE).store_string(JSON.stringify({"errors":errors,"runs":reports},"\t"))
 print("MIXED_GROUP_CHECK ",JSON.stringify({"errors":errors,"runs":reports}));quit(0 if errors.is_empty() else 1)
