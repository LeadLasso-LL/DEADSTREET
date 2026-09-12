extends SceneTree
const Anim=preload("res://battle/presentation/tactical_unit_animation_catalog.gd")
const Presenter=preload("res://gameplay/tactical_actor_presenter.gd")
const Identity=preload("res://battle/identity/tactical_identity_factory.gd")
const Participant=preload("res://battle/core/battle_participant.gd")
const State=preload("res://battle/core/battle_state.gd")
const Geometry=preload("res://battle/geometry/battlefield_geometry.gd")
const Weapons=preload("res://battle/combat/battle_weapon_catalog.gd")
var errors: Array=[]
func _initialize() -> void:call_deferred("run")
func run() -> void:
	var container=Node2D.new();root.add_child(container)
	var presenter=Presenter.new();presenter.bind_unit_root(container)
	var b=State.new();b.battlefield_geometry=Geometry.new()
	var ids: Array=[];var original: Dictionary={}
	# Thirteen simultaneously living variants exceed the twelve-entry browsing cache.
	for faction in ["mercer","orlov","eastex"]:
		for model in Weapons.models_for_class("pistol"):
			if ids.size()>=13:break
			var id: String=faction+model
			var p=Participant.new(id,"","player_gang","attacker","pistol")
			p.identity=Identity.make(id,faction,"pistol");p.weapon_model_id=model
			b.participants[id]=p;ids.append(id)
			if not presenter._ensure_unit_node(b,p):errors.append("spawn "+id);continue
			original[id]=presenter._unit_nodes[id].get_node("body").sprite_frames.get_instance_id()
	for id: String in ids:
		if not presenter._ensure_unit_node(b,b.participants[id]):errors.append("retained "+id);continue
		if presenter._unit_nodes[id].get_node("body").sprite_frames.get_instance_id()!=original.get(id):errors.append("cache eviction rebuilt active frames "+id)
	if Anim.frames_cache_size()>Anim.MAX_CACHED_VARIANTS:errors.append("unbounded browsing cache")
	print("ROSTER_CACHE actors=",ids.size()," cached=",Anim.frames_cache_size()," errors=",errors)
	presenter._clear_all();container.queue_free()
	quit(0 if errors.is_empty() else 1)
