extends SceneTree
class FakeBattle extends RefCounted:
	var participants={"unit":{"has_battle_position":true,"is_alive":true,"is_wounded":true,"battle_position":Vector2(10,10)}}
	var elapsed_time_seconds=0.0
	var combat_feedback_events=[]
	func get_participant(id): return participants.get(id)
func _initialize():
	var layer=load("res://gameplay/tactical_blood_layer.gd").new()
	root.add_child(layer)
	var b=FakeBattle.new()
	layer.sync(b)
	for i in range(10):
		b.elapsed_time_seconds+=1.0;layer.sync(b)
	assert(layer.marks.is_empty(),"standing must not pool")
	b.participants.unit.battle_position.x+=2
	b.elapsed_time_seconds+=1.0;layer.sync(b)
	assert(layer.marks.size()==1,"one spaced drop")
	b.combat_feedback_events=[{"sequence_id":1,"trauma_applied":0.0,"elapsed_time_seconds":11.0,"target_participant_id":"unit"}]
	layer.sync(b);assert(layer.hits.is_empty(),"miss must not bleed")
	b.combat_feedback_events.append({"sequence_id":2,"trauma_applied":1.0,"elapsed_time_seconds":11.0,"target_participant_id":"unit"})
	layer.sync(b);assert(layer.hits.size()==1,"damaging hit splashes once")
	layer.sync(b);assert(layer.hits.size()==1,"no duplicate hit")
	b.participants.unit.is_alive=false;layer.sync(b)
	assert(layer.marks.size()==2,"death mark once")
	layer.sync(b);assert(layer.marks.size()==2)
	layer.enabled=false;layer.sync(b)
	assert(not layer.visible and layer.marks.is_empty() and layer.hits.is_empty(),"blood off hides all marks")
	layer.enabled=true
	var next=FakeBattle.new();layer.sync(next)
	assert(layer.marks.is_empty() and layer.dead.is_empty(),"battle reset")
	for i in range(300):
		next.elapsed_time_seconds+=1.0;next.participants.unit.battle_position.x+=2;layer.sync(next)
	assert(layer.marks.size()<=240,"bounded trail")
	print("BLOOD_CHECKS_PASS");quit()
