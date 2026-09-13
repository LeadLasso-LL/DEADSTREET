extends SceneTree
const Nav=preload("res://battle/navigation/battle_navigation_service.gd")
const C=preload("res://battle/geometry/river_bridge_catalog.gd")
var errors=[]
var checks=0
func check(ok: bool,label: String):
 checks+=1
 if not ok:errors.append(label);printerr("CONNECTIVITY_FAIL ",label)
func _initialize():
 var b=load("res://battle/core/battle_state.gd").new()
 var g=load("res://battle/geometry/battlefield_geometry.gd").new();b.battlefield_geometry=g
 g.width=20.;g.height=20.;g.attacker_deployment_rect=Rect2(1,1,6,18);g.defender_deployment_rect=Rect2(13,1,6,18)
 g.obstacles["wall"]=C.Base.Obstacle.new("wall",Rect2(9,0,2,20),true,true,"wall")
 check(g.is_valid(),"closed room fixture valid")
 for pair in [[Vector2(3,5),Vector2(16,5)],[Vector2(3,5),Vector2(3,17)],[Vector2(16,5),Vector2(16,17)]]:
  check(Nav.is_reachable(b,pair[0],pair[1])==Nav.find_path(b,pair[0],pair[1]).success,"disconnected components match routes")
 check(not Nav.is_reachable(b,Vector2(3,5),Vector2(16,5)),"solid wall unreachable")
 g.obstacles.clear();g.obstacles["upper"]=C.Base.Obstacle.new("upper",Rect2(9,0,2,8),true,true,"wall");g.obstacles["lower"]=C.Base.Obstacle.new("lower",Rect2(9,12,2,8),true,true,"wall");g.content_revision+=1
 check(Nav.is_reachable(b,Vector2(3,5),Vector2(16,5)) and Nav.find_path(b,Vector2(3,5),Vector2(16,5)).success,"opening invalidates cached disconnection")
 var cover=C.Base.Cover.new("edge_cover","upper");g.cover_objects["edge_cover"]=cover
 var slot=C.Base.Slot.new("edge_slot","edge_cover",Vector2(9,8),Vector2.DOWN);g.cover_slots["edge_slot"]=slot;cover.slot_ids.append("edge_slot")
 check(not g.is_valid(),"inclusive obstacle edge blocks cover")
 slot.position=Vector2(9,8.01)
 check(g.is_valid(),"point beyond edge remains legal")
 DirAccess.make_dir_recursive_absolute("res://tools/bridge_map/results")
 FileAccess.open("res://tools/bridge_map/results/connectivity.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"errors":errors},"  "))
 print("BRIDGE_CONNECTIVITY ",checks," ",errors);quit(0 if errors.is_empty() else 1)
