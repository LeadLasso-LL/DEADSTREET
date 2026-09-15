extends SceneTree
const Outro=preload("res://gameplay/tactical_battle_outro.gd")
const Baseline=preload("res://tools/freight_loot_20260915/baseline_outro.gd")
const C=preload("res://battle/geometry/freight_exchange_catalog.gd")
var failures=[]
func check(ok,label_value):
 if not ok:failures.append(label_value)
func _initialize():call_deferred("run")
func run():
 var scene=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(scene)
 await process_frame
 await scene.start_battle(false,preload("res://gameplay/freight_exchange_scenario.gd").config())
 scene.set_process(false)
 if scene.battle==null:push_error("Fixture failed");quit(1);return
 var b=scene.battle;var view=scene.runtime.get_node("TacticalBattleView")
 # Isolated presentation fixture only: no production outcome or combat changes.
 b.tactical_result=BattleVictoryResult.new()
 b.tactical_result.resolved=true;b.tactical_result.winning_side_id=b.attacker_side_id
 view._sync_actor_presenter()
 var before=Baseline.new();before.build(b,C.ENTRANCE)
 var after=Outro.new();after.build(b,C.ENTRANCE,view)
 check(after.duration==before.duration,"Attacker ending duration changed")
 check(after.errors.is_empty(),"Attacker routes blocked")
 var goals=[];var moving=0;var walking=0;var data=[]
 for id in after.routes:
  var route=after.routes[id];var goal=route.points[-1]
  check(route.action=="loot" and route.length>0.,"Stationary attacker "+id)
  for taken in goals:check(goal.distance_to(taken)>=2.4,"Overlapping loot goals")
  goals.append(goal)
  data.append({"id":id,"distance":route.length,"goal":str(goal),"travel":route.travel})
 after.apply(view,5.)
 for id in after.routes:
  var node=view.actor_presenter._unit_nodes[id];var route=after.routes[id]
  if node.position.distance_to(route.snapshot.position)>1.:moving+=1
  if "walk" in str(node.get_node("body").animation):walking+=1
  check(node.visible and node.modulate.a==1.,"Attacker faded")
 check(moving==after.routes.size(),"Some attackers failed to move")
 b.tactical_result.winning_side_id=b.defender_side_id
 var old_defender=Baseline.new();old_defender.build(b,C.ENTRANCE)
 var new_defender=Outro.new();new_defender.build(b,C.ENTRANCE)
 check(old_defender.duration==new_defender.duration and old_defender.routes==new_defender.routes,"Defender outro changed")
 var report={"failures":failures,"duration":after.duration,"baseline_duration":before.duration,"moving":moving,"walking_at_5s":walking,"routes":data,"defender_unchanged":old_defender.routes==new_defender.routes}
 FileAccess.open("res://tools/freight_loot_20260915/validation.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
 print("FREIGHT_LOOT ",JSON.stringify(report))
 quit(0 if failures.is_empty() else 1)
