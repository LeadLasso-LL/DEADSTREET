extends SceneTree
const Catalog = preload("res://battle/presentation/tactical_unit_animation_catalog.gd")
const Presenter = preload("res://gameplay/tactical_actor_presenter.gd")
const State = preload("res://battle/core/battle_state.gd")
const Person = preload("res://battle/core/battle_participant.gd")
const Identity = preload("res://battle/identity/tactical_identity_factory.gd")
const Geometry = preload("res://battle/geometry/battlefield_geometry.gd")
const Weapons = preload("res://battle/combat/battle_weapon_catalog.gd")
var failures: Array[String] = []

func check(ok: bool, label: String) -> void:
	if not ok: failures.append(label)

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	var state = State.new()
	state.battlefield_geometry = Geometry.new()
	state.battle_phase = "active"
	var parent := Node2D.new()
	root.add_child(parent)
	var presenter = Presenter.new()
	presenter.bind_root(parent, 8.0)
	presenter.bind_unit_root(parent)
	for gang in ["local_street_gang","russian_organized_crime","italian_mob"]:
		for weapon in ["rifle","smg","pistol"]:
			var id: String = gang + "_" + weapon
			var p = Person.new(id,"","", "attacker",weapon)
			p.identity = Identity.make(id,gang,weapon)
			p.has_battle_position = true
			state.participants[id] = p
	presenter.sync_dynamic(state)
	check(presenter.unit_spawn_count == 9,"nine equipped outfits")
	check(Catalog.frames_cache_size() == 9,"shared variant cache")
	for p in state.participants.values():
		var id: String = p.participant_id
		var node = parent.get_node("unit_" + id)
		var body = node.get_node("body")
		for direction in Catalog.DIRECTION_IDS_8:
			check(body.sprite_frames.has_animation("walk_"+direction),id+" direction "+direction)
		p.weapon_state.is_reloading = true
		p.weapon_state.reload_remaining_seconds = Weapons.get_definition(p.weapon_type).reload_seconds * 0.5
		state.elapsed_time_seconds += 0.1
		presenter.sync_dynamic(state)
		check(presenter.unit_clip_id(id) == "reload",id+" reload")
		check(body.frame == 19,id+" reload midpoint")
		p.velocity = Vector2(3.0,0.0)
		p.battle_position += Vector2(0.4,0.0)
		state.elapsed_time_seconds += 0.1
		presenter.sync_dynamic(state)
		check(presenter.unit_clip_id(id) == "walk",id+" moving reload avoids sliding")
		p.velocity = Vector2.ZERO
		p.weapon_state.is_reloading = false
		p.is_alive = false
		state.elapsed_time_seconds += 0.1
		presenter.sync_dynamic(state)
		state.elapsed_time_seconds += 2.0
		presenter.sync_dynamic(state)
		check(presenter.unit_clip_id(id) == "death" and body.frame == 23,id+" death held")
	check(presenter.unit_spawn_count == 9,"nodes retained")
	var result := {"pass":failures.is_empty(),"failures":failures,"variants":9,"directions_per_variant":8}
	print("PIXEL_CONTRACT ",JSON.stringify(result))
	FileAccess.open("res://tools/pixel_integration/results/contract.json",FileAccess.WRITE).store_string(JSON.stringify(result,"  "))
	presenter._clear_all()
	parent.free()
	quit(0 if failures.is_empty() else 1)
