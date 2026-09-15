extends SceneTree
const Catalog=preload("res://gameplay/music_catalog.gd")
const Menu=preload("res://gameplay/sandbox_menu_music.gd")
const OUT="res://tools/menu_additions_20260915/"
func _initialize():call_deferred("run")
func run():
	var removed=["switch_b22","ripper_b22","dead_or_alive_b22","lurk_b22"]
	var settings="user://menu_additions_validation.cfg"
	var cfg=ConfigFile.new()
	for id in removed:cfg.set_value("playlist",id,true)
	cfg.set_value("player","volume",0.0);cfg.save(settings)
	var menu=Menu.new();menu.settings_path=settings;root.add_child(menu)
	await process_frame
	var ok=menu.tracks.size()==21 and menu.track_checks.size()==21 and Catalog.tracks().size()==25
	for id in removed:
		ok=ok and not menu.track_checks.has(id) and id not in menu.queue and not menu.enabled_tracks.has(id)
		ok=ok and Catalog.menu_stream(id)!=null and Catalog.battle_stream(id)!=null
	for id in ["mercy_b22","hitters_b22","creepin_b22"]:
		var stream=Catalog.menu_stream(id)
		ok=ok and menu.track_checks.has(id) and menu.enabled_tracks.get(id,false) and stream!=null and stream.get_length()>30 and Catalog.battle_stream(id)==null
		menu.queue.assign([id])
		ok=ok and menu.advance(false) and menu.current_id==id and menu.label.text.contains("B-22")
	menu.current_id="dead_street"
	for i in range(3):
		menu.refill_queue()
		for id in removed:ok=ok and id not in menu.queue
	ok=ok and menu.current_id=="dead_street"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(settings))
	FileAccess.open(OUT+"native_validation.json",FileAccess.WRITE).store_string(JSON.stringify({"passed":ok,"menu_tracks":menu.tracks.size(),"all_tracks":Catalog.tracks().size(),"old_enabled_preferences_ignored":true,"removed_menu_and_battle_streams_load":true},"  "))
	print("MENU_ADDITIONS ","PASS" if ok else "FAIL")
	quit(0 if ok else 1)
