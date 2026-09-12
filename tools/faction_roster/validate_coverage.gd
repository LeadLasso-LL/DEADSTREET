extends SceneTree
const Anim=preload("res://battle/presentation/tactical_unit_animation_catalog.gd")
const Factions=preload("res://battle/identity/faction_unit_catalog.gd")
const Weapons=preload("res://battle/combat/battle_weapon_catalog.gd")
var errors: Array=[]
var validated: Array=[]
var animation_count=0
var frame_count=0
func _initialize() -> void:call_deferred("run")
func save_report(pending: int) -> void:
	FileAccess.open("res://tools/faction_roster/coverage_validation.json",FileAccess.WRITE).store_string(JSON.stringify({"errors":errors,"validated":validated,"pairings":validated.size(),"animations":animation_count,"frames":frame_count,"pending":pending},"  "))
func check_variant(variant: String) -> void:
	var frames=Anim.frames_for(variant)
	if frames==null:errors.append("missing frames "+variant);return
	for clip: String in Anim.manifest().clips:
		var spec: Dictionary=Anim.manifest().clips[clip]
		for direction: String in Anim.manifest().directions:
			var name=Anim.animation_name(clip,direction)
			if not frames.has_animation(name):errors.append("missing "+variant+"/"+name);continue
			animation_count+=1
			if frames.get_frame_count(name)!=int(spec.count):errors.append("frame count "+variant+"/"+name)
			if not is_equal_approx(frames.get_animation_speed(name),float(spec.fps)):errors.append("fps "+variant+"/"+name)
			if frames.get_animation_loop(name)!=bool(spec.loop):errors.append("loop "+variant+"/"+name)
			for i in range(frames.get_frame_count(name)):
				frame_count+=1
				var tex=frames.get_frame_texture(name,i) as AtlasTexture
				if tex==null or tex.atlas==null:errors.append("null texture "+variant+"/"+name);continue
				if not Rect2(Vector2.ZERO,tex.atlas.get_size()).encloses(tex.region):errors.append("outside atlas "+variant+"/"+name)
	frames=null
	Anim._frames_cache.clear();Anim._texture_cache.clear();Anim._variant_lru.clear()
func run() -> void:
	var pending: Array=Anim.faction_manifest().models.keys()
	if pending.size()!=690:errors.append("expected 690 pairings")
	var started=Time.get_ticks_msec()
	while not pending.is_empty() and Time.get_ticks_msec()-started<14400000:
		var progressed=false
		for key: String in pending.duplicate():
			var variant: String=Anim.faction_manifest().models[key]
			if variant.begins_with("faction_") and not FileAccess.file_exists("res://assets/art/units/factions/validation/"+variant+".json"):continue
			var parts=key.split(":")
			var model=Weapons.get_model(parts[1])
			if model==null or Anim.variant_for(parts[0],model.weapon_type_id,parts[1])!=variant:errors.append("binding "+key)
			check_variant(variant)
			validated.append(key);pending.erase(key);progressed=true
			if validated.size()%20==0:
				print("ROSTER_COVERAGE_PROGRESS ",validated.size(),"/690 errors=",errors.size());save_report(pending.size())
			await process_frame
		if not progressed:await create_timer(3.0).timeout
	if not pending.is_empty():errors.append("unfinished build "+str(pending.size()))
	save_report(pending.size())
	print("ROSTER_COVERAGE pairings=",validated.size()," animations=",animation_count," frames=",frame_count," errors=",errors)
	quit(0 if errors.is_empty() else 1)
