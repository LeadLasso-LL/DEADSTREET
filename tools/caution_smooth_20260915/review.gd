extends SceneTree
const OUT="C:/Users/brand/OneDrive/Documents/dead-street/tools/caution_smooth_20260915/"
var scene
var errors=[]
var checks=0
var started_frame=0
func _initialize():call_deferred("run")
func check(ok: bool, label: String):
	checks+=1
	if not ok: errors.append(label); printerr("INTRO_FAIL ",label)
func wait_to(t: float):
	while scene.elapsed<t: await process_frame
func shot(name: String):
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+name+".png")
func run():
	root.gui_disable_input=true
	scene=load("res://gameplay/sandbox_opening.tscn").instantiate();root.add_child(scene)
	# Capture-only review level; never change saved player settings.
	scene.music.volume_value=db_to_linear(-4.0);scene.music.player.volume_db=-4.0
	await process_frame;await shot("gate")
	var previous_focus_y=504.0
	var path_ok=true
	for i in range(343):
		var v=scene.caution.zoom_view_at(8.95+float(i)/120.0)
		var focus_y=360.0+(504.0-v.y)*v.z
		if focus_y>previous_focus_y+0.002: path_ok=false
		previous_focus_y=focus_y
	check(path_ok and absf(previous_focus_y-360.0)<0.01,"spray paint moves continuously to center with no reversal")
	check(scene.phase=="gate" and not scene.music.player.playing,"silent Enter gate")
	check(not scene.startup.is_playing() and not scene.caution.visible,"gate has no animation")
	await create_timer(1.0).timeout
	started_frame=Engine.get_frames_drawn()
	scene.enter_button.pressed.emit()
	check(scene.music.play_count==1 and scene.activation_count==1,"Enter starts signature once")
	scene.begin();scene.open_sandbox()
	check(scene.activation_count==1 and scene.phase=="credits","double activation and early entry blocked")
	await wait_to(6.3);await shot("clean_sign")
	check(scene.caution.visible and scene.caution.visible_hits==0,"clean sign before bullets")
	for i in range(5):
		await wait_to(scene.caution.HIT_TIMES[i]+0.10)
		check(scene.caution.visible_hits==i+1,"staggered visible hole %d"%(i+1))
		check(scene.caution.get_child_count()==0,"no intro sound players %d"%(i+1))
		check(absf(scene.caution.appeared_at[i]-scene.caution.HIT_TIMES[i])<0.06,"impact clock %d"%(i+1))
		await shot("hit_%d"%(i+1))
	await wait_to(9.0);await shot("shot_sign")
	for at in [9.4,9.9,10.4,10.9,11.4,11.75]:
		await wait_to(at);await shot("zoom_%.2f"%at)
	await wait_to(11.95);await shot("black_hold")
	var im=root.get_texture().get_image();im.convert(Image.FORMAT_RGB8)
	var maximum=0
	for value in im.get_data():maximum=maxi(maximum,value)
	check(maximum<=4,"full blackout without white sliver")
	await wait_to(20.85);check(scene.phase=="credits","title phase not early")
	await wait_to(21.2);await shot("title")
	check(scene.phase=="title" and scene.revealed_at>=21 and scene.revealed_at<21.12,"title21s")
	check(scene.title.size==Vector2(1056,384),"approved title size")
	await wait_to(26.85);check(not scene.open_button.visible,"Open Sandbox not early")
	await wait_to(27.2);check(scene.open_button.visible and scene.enabled_at<27.12,"Open Sandbox27s")
	await wait_to(29.0);await shot("open_sandbox_button")
	var player=scene.music.player.get_instance_id();var position=scene.music.player.get_playback_position()
	scene.open_button.pressed.emit();await process_frame
	check(scene.phase=="sandbox" and scene.sandbox.ui.visible,"actual sandbox opens")
	check(scene.music.player.get_instance_id()==player and scene.music.play_count==1,"same music player through entry")
	check(scene.music.player.get_playback_position()>=position,"music position preserved")
	check(scene.sandbox.runtime==null,"no unintended battle")
	await shot("sandbox_entry")
	await create_timer(4.5).timeout
	check(scene.music.dock.visible,"Music dock after entry")
	await shot("sandbox_final")
	var report={"intro_sound_players":scene.caution.get_child_count(),"zoom_start":8.95,"zoom_end":11.8,"status":"PASS" if errors.is_empty() else "FAIL","checks":checks,"errors":errors,"title_at":scene.revealed_at,"button_at":scene.enabled_at,"sandbox_at":scene.menu_opened_at,"hit_times":scene.caution.appeared_at,"black_max":maximum,"signature_play_count":scene.music.play_count,"start_frame":started_frame,"total_frames":Engine.get_frames_drawn(),"viewport":[root.size.x,root.size.y]}
	FileAccess.open(OUT+"native_review.json",FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
	print("INTRO_REVIEW ",JSON.stringify(report));quit(0 if errors.is_empty() else 1)
