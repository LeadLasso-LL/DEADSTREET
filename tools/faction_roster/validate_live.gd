extends SceneTree
const Factions=preload("res://battle/identity/faction_unit_catalog.gd")
const Anim=preload("res://battle/presentation/tactical_unit_animation_catalog.gd")
const Fixture=preload("res://gameplay/arsenal_battle_fixture.gd")
const Victory=preload("res://battle/core/battle_victory_service.gd")
var scene
var errors: Array=[]
var seen: Dictionary={}
var captured=false
var suffix=""
func _initialize() -> void: call_deferred("run")
func capture(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://tools/faction_roster/"+name+suffix+".png")
func find_hud(node: Node) -> Node:
	var script=node.get_script()
	if script!=null and script.resource_path=="res://gameplay/tactical_command_hud.gd":return node
	for child in node.get_children():
		var found=find_hud(child)
		if found!=null:return found
	return null
func run() -> void:
	root.size=Vector2i(1440,1080)
	scene=load("res://gameplay/arsenal_review.tscn").instantiate();root.add_child(scene)
	await process_frame
	var authority_test="--authorities" in OS.get_cmdline_user_args()
	if authority_test:suffix="_authorities"
	scene.faction="trc" if authority_test else "orlov"
	scene.unit_tier=3;scene.show_class("sniper");scene.choose("svd")
	await capture("sandbox_controls")
	scene.loadouts={
		"attacker":{"faction":"orlov","pistol":"cz75","smg":"mp5k","shotgun":"saiga12","rifle":"ak47","sniper":"svd","unit_tiers":{"pistol":1,"smg":2,"shotgun":3,"rifle":2,"sniper":3}},
		"defender":{"faction":"mercer","pistol":"five_seven","smg":"p90","shotgun":"benelli_m4","rifle":"scar_h","sniper":"awm","unit_tiers":{"pistol":3,"smg":1,"shotgun":2,"rifle":3,"sniper":1}}
	}
	if authority_test:
		scene.loadouts.attacker.faction="trc"
		scene.loadouts.defender.faction="nbpd"
	await scene.start_battle(false)
	if scene.battle==null:
		push_error("ROSTER_LIVE_SETUP "+scene.note.text);quit(1);return
	var b=scene.battle
	if b.participants.size()!=10:errors.append("expected ten participants")
	var models: Dictionary={}
	for p in b.participants.values():
		var variant=Anim.variant_for(p.identity.gang_archetype_id,p.weapon_type,p.weapon_model_id)
		var frames=Anim.frames_for(variant)
		if frames==null:errors.append("missing runtime frames "+variant)
		else:
			for clip: String in Anim.manifest().clips:
				for direction: String in Anim.manifest().directions:
					var name=Anim.animation_name(clip,direction)
					if not frames.has_animation(name) or frames.get_frame_count(name)!=int(Anim.manifest().clips[clip].count):errors.append("missing clip "+variant+"/"+name)
		models[p.participant_id]={"faction":p.identity.gang_archetype_id,"class":p.weapon_type,"weapon":p.weapon_model_id,"tier":p.unit_tier,"variant":variant}
	var start: int=Time.get_ticks_msec()
	var phase_checked=false
	var finished=false
	while Time.get_ticks_msec()-start<180000:
		await process_frame
		if b.battle_phase=="active" and not phase_checked:
			var original: float=b.elapsed_time_seconds
			for elapsed in [120.0,3600.0,86400.0]:
				b.elapsed_time_seconds=elapsed
				if Victory.resolve_if_terminal(b).resolved:errors.append("time resolved a living battle")
			b.elapsed_time_seconds=original;phase_checked=true
		for event in b.combat_feedback_events:seen[event.sequence_id]=event.source_participant_id
		if not captured and b.battle_phase=="active" and b.elapsed_time_seconds>8.0:
			await capture("battle_tier_stars");captured=true
			var hud=find_hud(scene.runtime)
			var profile=Factions.profile(scene.loadouts.attacker.faction)
			var expected=str(profile.get("hud_name",profile.name)).to_upper()
			if hud==null or not hud.faction_label.text.begins_with(expected):errors.append("unit-card faction heading")
		var presentation=scene.runtime.get_node("TacticalBattleView").battle_presentation
		if presentation.results_visible() and presentation.result_root.modulate.a>.99:
			await capture("battle_results");finished=true;break
	if not captured:errors.append("no live battle capture")
	if seen.is_empty():errors.append("no combat feedback")
	var report={"errors":errors,"models":models,"shots":seen.size(),"resolved":finished,"winner":b.get_winning_side_id(),"elapsed":b.elapsed_time_seconds,"observation_cutoff":not finished}
	FileAccess.open("res://tools/faction_roster/live_validation"+suffix+".json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
	print("ROSTER_LIVE ",JSON.stringify(report))
	quit(0 if errors.is_empty() else 1)
