extends "res://tools/dusk_review/runtime_review.gd"
var trace: FileAccess
var sample_at := 0.0
var mode := "baseline"
var order_stage := 0
func start() -> void:
	if not OS.get_cmdline_user_args().is_empty(): mode = OS.get_cmdline_user_args()[0]
	trace = FileAccess.open("res://tools/dusk_review/results/decisions_"+mode+".jsonl",FileAccess.WRITE)
	await super.start()
func _process(delta: float) -> bool:
	if active and not comparing:
		var b = runtime.get_current_session().battle_state
		var ctl = runtime.tactical_orders_controller
		ctl.sync_from_authority()
		if mode == "orders" and elapsed >= .5 + order_stage*1.5 and order_stage < 3:
			issue_probe(b,ctl)
		if elapsed >= sample_at:
			sample_at = elapsed + .1
			for p in b.participants.values():
				var target = b.get_participant(p.target_participant_id)
				var dist = p.battle_position.distance_to(target.battle_position) if target != null else -1.0
				trace.store_line(JSON.stringify({"t":b.elapsed_time_seconds,"id":p.participant_id,"weapon":p.weapon_type,"alive":p.is_alive,"wounded":p.is_wounded,"pos":[p.battle_position.x,p.battle_position.y],"speed":p.velocity.length(),"cover":p.occupied_cover_slot_id,"reserved":p.reserved_cover_slot_id,"action":p.combat_move_mode,"target":p.target_participant_id,"distance":dist,"intent":p.player_tactical_intent,"posture":p.cover_posture_phase}))
			trace.flush()
	return super._process(delta)
func issue_probe(b,ctl) -> void:
	for p in b.participants.values():
		if not ctl.select_participant(p.participant_id): continue
		var result
		var before = Time.get_ticks_usec()
		if order_stage == 0: result = ctl.issue_move(Vector2(32,39))
		elif order_stage == 1: result = ctl.issue_cover("cover_threshold_sedan")
		else:
			for enemy in b.participants.values():
				if enemy.side_id != p.side_id and enemy.is_alive:
					result = ctl.issue_target(enemy.participant_id)
					break
		trace.store_line(JSON.stringify({"order":order_stage,"id":p.participant_id,"t":b.elapsed_time_seconds,"success":result.success if result != null else false,"error":result.error_code if result != null else "no_target","call_ms":(Time.get_ticks_usec()-before)/1000.0}))
		break
	order_stage += 1

