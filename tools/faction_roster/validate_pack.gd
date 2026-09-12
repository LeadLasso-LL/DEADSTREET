extends SceneTree
const Anim=preload("res://battle/presentation/tactical_unit_animation_catalog.gd")
const Exporter=preload("res://addons/faction_roster_export/roster_export.gd")
func _initialize() -> void:
	var source=Anim.atlas_path("faction_eastex_glock_17","portraits")
	var packed="res://__roster_pack_probe__/portrait.png"
	var packpath="user://roster_pack_probe.pck"
	var pack=PCKPacker.new()
	assert(pack.pck_start(packpath)==OK)
	assert(pack.add_file(packed,source)==OK)
	assert(pack.flush()==OK)
	assert(ProjectSettings.load_resource_pack(packpath))
	var texture=Anim._load_texture(packed)
	assert(texture!=null and texture.get_size()==Vector2(90,80))
	var paths=Exporter.catalog_paths(Anim.faction_manifest())
	assert(paths.size()==3841)
	var distinct={}
	for path in paths:distinct[path]=true
	assert(distinct.size()==paths.size())
	print("ROSTER_PACK raw PNG loaded from PCK; export file count=",paths.size())
	quit()
