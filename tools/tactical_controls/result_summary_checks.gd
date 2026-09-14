extends RefCounted
const Summary=preload("res://gameplay/battle_result_summary.gd")
const Result=preload("res://battle/core/battle_victory_result.gd")
class Fixture extends RefCounted:
 var participants={}
 var tactical_result
static func run() -> Dictionary:
 var b=Fixture.new();var errors=[];var checks=0
 b.participants={"a":{"side_id":"attacker","is_alive":true,"is_wounded":false},"w":{"side_id":"attacker","is_alive":true,"is_wounded":true},"d":{"side_id":"attacker","is_alive":false,"is_wounded":false},"e":{"side_id":"defender","is_alive":false,"is_wounded":false}}
 b.tactical_result=Result.resolved_victory("attacker",["defender"],["attacker"],true)
 var a=Summary.for_side(b,"attacker");var d=Summary.for_side(b,"defender")
 for valid in [a.remaining==2,a.text=="2 Units Remaining",not a.retreated,d.remaining==0,d.text=="0 Units Remaining",not d.retreated]:
  checks+=1
  if not valid:errors.append("Elimination/survivor summary failed")
 b.participants.e.is_alive=true
 d=Summary.for_side(b,"defender");checks+=1
 if d.text!="1 Unit Remaining" or d.retreated:errors.append("Living loser was incorrectly called a retreat")
 b.tactical_result=Result.resolved_victory("attacker",["defender"],["attacker","defender"],true,["defender","attacker","defender"])
 b.tactical_result=Result.from_stored(b.tactical_result)
 d=Summary.for_side(b,"defender");checks+=1
 if d.text!="1 Unit Remaining · Retreated from battle" or not d.retreated:errors.append("Stored retreat summary failed")
 checks+=1
 if b.tactical_result.retreated_side_ids.size()!=1 or Summary.for_side(b,"attacker").retreated:errors.append("Winner/duplicate retreat metadata failed")
 return {"checks":checks,"errors":errors}
