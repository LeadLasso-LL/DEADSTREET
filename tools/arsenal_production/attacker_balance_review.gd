extends SceneTree

const Fixture = preload("res://gameplay/arsenal_battle_fixture.gd")
const Weapons = preload("res://battle/combat/battle_weapon_catalog.gd")
const Runtime = preload("res://battle/runtime/battle_runtime_service.gd")
const Orders = preload("res://battle/core/battle_force_command_service.gd")
const Victory = preload("res://battle/core/battle_victory_service.gd")

var reports: Array = []
var errors: Array = []
var output_name: String = "attacker_balance_candidate.json"

func _initialize():
	call_deferred("run")

func run():
	var pairs: Array = [0, 1, 2, 3, 4, 5]
	var observe_seconds: float = 240.0
	var equal_loadouts: bool = false
	var snipers: bool = false
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--pairs="):
			pairs = []
			for value in arg.trim_prefix("--pairs=").split(","): pairs.append(int(value))
		if arg.begins_with("--out="): output_name = arg.trim_prefix("--out=").get_file()
		if arg.begins_with("--observe="): observe_seconds = maxf(120.0, float(arg.trim_prefix("--observe=")))
		if arg == "--equal": equal_loadouts = true
		if arg == "--snipers": snipers = true
	for index in pairs:
		var runtime = load("res://gameplay/gameplay_runtime.tscn").instantiate()
		root.add_child(runtime)
		await process_frame
		var loadouts = {"attacker": {}, "defender": {}}
		for kind in ["pistol", "smg", "rifle", "shotgun", "sniper"]:
			var ids = Weapons.models_for_class(kind)
			loadouts.attacker[kind] = ids[index]
			loadouts.defender[kind] = ids[index if equal_loadouts else (index + 1) % 6]
		var result = Fixture.setup(runtime, loadouts, snipers, 4200 + index)
		if not result.has("battle"):
			errors.append(result)
			runtime.queue_free()
			await process_frame
			continue
		var b = result.battle
		runtime.skip_battle_cinematics = true
		var begun = Fixture.begin_review(runtime, b)
		if begun == null or not begun.success:
			errors.append("begin failed")
			runtime.queue_free()
			await process_frame
			continue
		# Elapsed time alone must not create a winner, draw, or resolved phase.
		var previous_time = b.elapsed_time_seconds
		for time_value in [120.0, 3600.0, 86400.0]:
			b.elapsed_time_seconds = time_value
			var terminal = Victory.resolve_if_terminal(b)
			if terminal.resolved or b.battle_phase != "active" or not b.get_winning_side_id().is_empty():
				errors.append("elapsed time incorrectly resolved battle")
		b.elapsed_time_seconds = previous_time
		for id in b.get_sorted_tactical_force_ids():
			if b.get_tactical_force(id).side_id == b.attacker_side_id: Orders.set_command(b, id, "push")
		var seen = {}
		var shots = {"attacker": 0, "defender": 0}
		var start = Time.get_ticks_msec()
		# Observation budget limits this diagnostic, never the battle outcome.
		for tick in range(int(observe_seconds / 0.05)):
			if b.battle_phase != "active": break
			var advanced = Runtime.advance(b, 0.05)
			if not advanced.success:
				errors.append(advanced.error_code)
				break
			for e in b.combat_feedback_events:
				if seen.has(e.sequence_id): continue
				seen[e.sequence_id] = true
				var p = b.get_participant(e.source_participant_id)
				shots[p.side_id] += 1
		var alive = {"attacker": 0, "defender": 0}
		var survivors = []
		for p in b.participants.values():
			if p.is_alive:
				alive[p.side_id] += 1
				survivors.append({"id": p.participant_id, "model": p.weapon_model_id, "position": str(p.battle_position), "target": p.target_participant_id, "move": p.combat_move_mode, "wounded": p.is_wounded})
		var report = {"pair": index, "seed": 4200 + index, "equal_loadouts": equal_loadouts, "snipers": snipers, "phase": b.battle_phase, "winner": b.get_winning_side_id(), "observation_cutoff": b.battle_phase == "active", "elapsed": b.elapsed_time_seconds, "alive": alive, "shots": shots, "survivors": survivors, "wall_ms": Time.get_ticks_msec() - start}
		reports.append(report)
		print("ATTACKER_REVIEW ", JSON.stringify(report))
		_save()
		runtime.queue_free()
		await process_frame
		await process_frame
	_save()
	print("ATTACKER_REVIEW_COMPLETE ", reports.size(), " errors=", errors)
	quit(0 if errors.is_empty() else 1)

func _save():
	FileAccess.open("res://tools/arsenal_production/" + output_name, FileAccess.WRITE).store_string(JSON.stringify({"errors": errors, "battles": reports}, "  "))
