extends SceneTree
const Formation=preload("res://campaign/vehicles/convoy_formation_catalog.gd")
const Rules=preload("res://gameplay/sandbox_convoy_rules.gd")
const Factions=preload("res://battle/identity/faction_unit_catalog.gd")
const Config=preload("res://gameplay/sandbox_force_config.gd")
const Maps=preload("res://gameplay/sandbox_map_catalog.gd")
var errors=[]
var checks=0
var runs=[]
func _initialize():call_deferred("run")
func expect(ok: bool,label: String):
 checks+=1
 if not ok:errors.append(label);push_error(label)
func run():
 for faction in Factions.all_ids():
  var limit=4 if faction in ["stateline","blacktop","zangyaku","bitian","nbpd","trc"] else 2
  expect(Formation.two_wheelers_per_slot(faction)==limit,"Faction limit "+faction)
  var mixed=["ironhorse","bayou"]
  for i in range(limit-1):mixed.append("ironhorse")
  mixed.append("shuttle")
  var groups=Formation.slots(mixed,faction)
  expect(groups.size()==3 and groups[0].indices.size()==limit,"Nonconsecutive grouping "+faction)
  expect(Rules.check(mixed,16,faction).valid,"Mixed 16-seat convoy "+faction)
  var full=[]
  for i in range(limit*3):full.append("ironhorse")
  expect(Rules.check(full,limit*3,faction).valid,"Three full bike slots "+faction)
  expect(not Rules.addition(full,"ironhorse",16,faction).valid,"Fourth slot blocked "+faction)
  full.remove_at(0)
  expect(Rules.addition(full,"ironhorse",limit*3,faction).valid,"Removal restores availability "+faction)
  var pedal=[]
  for i in range(limit):pedal.append("yardbird")
  expect(Formation.slots(pedal,faction).size()==1,"Two-Wheelers category consistent "+faction)
  expect(not Rules.check(mixed,17,faction).valid,"16-unit cap "+faction)
  expect(not Rules.addition(["ironhorse"],"ironhorse",1,faction).valid,"No spare driver "+faction)
 var scene=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(scene)
 for i in range(5):await process_frame
 scene.set_process(false)
 for variant in ["mercer","stateline","zangyaku","trc","twelve_bikes"]:
  for map in Maps.IDS:
   var faction="stateline" if variant=="twelve_bikes" else variant
   var c=Maps.preset(map);c.attacker.faction=faction;c.attacker.units=[];c.attacker.erase("vehicle_occupants")
   for i in range(16):c.attacker.units.append(Config.unit(Config.CLASSES[i%5]))
   c.attacker.vehicles=[]
   if variant=="twelve_bikes":
    for i in range(12):c.attacker.vehicles.append("ironhorse")
   else:
    c.attacker.vehicles=["ironhorse","bayou"]
    for i in range(Formation.two_wheelers_per_slot(faction)-1):c.attacker.vehicles.append("ironhorse")
    c.attacker.vehicles.append("shuttle")
   await scene.start_battle(false,c)
   var tag=variant+" / "+map
   expect(scene.battle!=null,"Launch "+tag+" "+scene.note.text)
   if scene.battle!=null:
    for i in range(12):await process_frame
    var b=scene.battle;var view=scene.runtime.get_node("TacticalBattleView");var people=[];var vehicles=[]
    for v in b.vehicles.values():
     if v.side_id==b.attacker_side_id:
      vehicles.append(v.battle_vehicle_id);people.append_array(v.get_meta("convoy_occupants",[]))
      expect(v.has_battle_position,"Placed vehicle "+tag+" "+v.battle_vehicle_id)
    var unique={}
    for id in people:unique[id]=true
    expect(vehicles.size()==c.attacker.vehicles.size(),"Every selected vehicle arrives "+tag)
    expect(people.size()==16 and unique.size()==16,"Every passenger exactly once "+tag)
    expect(view.battle_presentation.last_path_errors.is_empty(),"Dismount paths "+tag)
    runs.append({"variant":variant,"map":map,"vehicles":vehicles.size(),"passengers":people.size(),"path_errors":view.battle_presentation.last_path_errors})
   scene.return_to_setup();await process_frame
 var c=Maps.preset("river_bridge");c.defender.faction="bitian";c.defender.vehicles=[];c.defender.units=[]
 for i in range(12):c.defender.vehicles.append("ironhorse")
 for i in range(16):c.defender.units.append(Config.unit(Config.CLASSES[i%5]))
 await scene.start_battle(false,c)
 expect(scene.battle!=null,"Defending twelve-bike blockade "+scene.note.text)
 var result={"checks":checks,"errors":errors,"runs":runs}
 FileAccess.open("res://tools/bike_slots_20260915/check.json",FileAccess.WRITE).store_string(JSON.stringify(result,"\t"))
 print("BIKE_LIMIT_CHECK ",JSON.stringify(result));quit(0 if errors.is_empty() else 1)
