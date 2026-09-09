extends Node2D
# Presentation only: bounded, deterministic marks. No combat or pathing changes.
var enabled := true
var battle_id := 0
var seen_sequence := -1
var marks: Array = []
var hits: Array = []
var walkers: Dictionary = {}
var dead: Dictionary = {}
var clock := 0.0
func sync(battle) -> void:
	if battle == null:
		marks.clear(); hits.clear(); walkers.clear(); dead.clear(); battle_id=0
		queue_redraw(); return
	if battle_id != battle.get_instance_id():
		marks.clear(); hits.clear(); walkers.clear(); dead.clear()
		seen_sequence=-1; battle_id=battle.get_instance_id()
	clock=battle.elapsed_time_seconds
	visible=enabled
	if not enabled:
		marks.clear(); hits.clear(); walkers.clear()
		for event in battle.combat_feedback_events: seen_sequence=maxi(seen_sequence,event.sequence_id)
		return
	for event in battle.combat_feedback_events:
		if event.sequence_id<=seen_sequence: continue
		seen_sequence=event.sequence_id
		if event.trauma_applied<=0.0 or clock-event.elapsed_time_seconds>.25: continue
		var target=battle.get_participant(event.target_participant_id)
		if target==null: continue
		var pos=Vector2(target.battle_position.x*8,target.battle_position.y*6)
		hits.append({"p":pos+Vector2(2,-15),"t":clock,"seed":event.sequence_id})
	for id in battle.participants:
		var unit=battle.participants[id]
		if not unit.has_battle_position: continue
		var pos=Vector2(unit.battle_position.x*8,unit.battle_position.y*6)
		if not unit.is_alive:
			if not dead.has(id):
				dead[id]=true
				marks.append({"p":pos,"size":3.1,"seed":int(id.hash())})
		elif unit.is_wounded:
			if not walkers.has(id): walkers[id]={"p":pos,"t":clock}
			var last: Dictionary=walkers[id]
			if pos.distance_to(last.p)>13.0 and clock-float(last.t)>.8:
				marks.append({"p":pos+Vector2(sin(clock*3.0)*1.2,0),"size":.65,"seed":int(clock*10)})
				walkers[id]={"p":pos,"t":clock}
	while marks.size()>240: marks.pop_front()
	hits=hits.filter(func(h): return clock-float(h.t)<.18)
	queue_redraw()
func _draw() -> void:
	if not enabled: return
	for mark in marks:
		var pos: Vector2=mark.p
		var size: float=mark.size
		for i in range(6 if size>1.0 else 2):
			var offset=Vector2(sin(float(mark.seed+i)*2.7),cos(float(mark.seed+i)*1.9))*size*1.5
			draw_rect(Rect2((pos+offset).round(),Vector2(size, maxf(.6,size*.55))),Color("#66272b"))
	for hit in hits:
		var age: float=(clock-float(hit.t))/.18
		for i in range(5):
			var offset=Vector2(cos(float(i)*2.1),sin(float(i)*2.1))*(1.0+age*3.5)
			draw_rect(Rect2((Vector2(hit.p)+offset).round(),Vector2(.8,.8)),Color(.58,.12,.14,1.0-age))
