extends SceneTree
const OUT="C:/Users/brand/OneDrive/Documents/dead-street/tools/menu_title_20260914/native/"
var scene
var checks=0
var errors=[]
var record=false
var report={}
func _initialize():call_deferred("run")
func check(ok: bool,label: String):
	checks+=1
	if not ok:errors.append(label);printerr("OPENING_FAIL ",label)
func frames(n: int):
	for i in range(n):await process_frame
func click(point: Vector2):
	var motion=InputEventMouseMotion.new();motion.position=point;motion.global_position=point;root.push_input(motion,true)
	for pressed in [true,false]:
		var e=InputEventMouseButton.new();e.position=point;e.global_position=point;e.button_index=MOUSE_BUTTON_LEFT;e.pressed=pressed;root.push_input(e,true);await process_frame
func wait_to(t: float):
	while scene.elapsed<t:await process_frame
func shot(name: String):
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+name+".png")
func run():
	record="--record" in OS.get_cmdline_user_args()
	root.size=Vector2i(1280,720);DisplayServer.window_set_size(root.size)
	scene=load("res://gameplay/sandbox_opening.tscn").instantiate();root.add_child(scene)
	await frames(15)
	check(scene.phase=="gate","starts on Enter gate")
	check(scene.enter_button.visible and not scene.open_button.visible,"only Enter is available")
	check(not scene.music.player.playing and not scene.startup.is_playing(),"gate is silent and does not advance video")
	check(scene.sandbox.runtime==null and not scene.sandbox.ui.visible,"existing sandbox concealed with no battle")
	check(scene.sandbox.surface.has_node("TutorialButton"),"Tutorial entry preserved")
	await shot("gate")
	await create_timer(2.0).timeout
	check(scene.elapsed==0 and scene.activation_count==0,"indefinite wait does not run cues")
	check(scene.enter_button.get_rect()==scene.open_button.get_rect(),"Enter matches Open Sandbox position and dimensions")
	await click(scene.enter_button.get_global_rect().get_center());await frames(3)
	check(scene.activation_count==1 and scene.phase=="credits","real Enter click starts credits")
	check(scene.music.play_count==1 and scene.music.player.playing,"signature starts once")
	scene.begin();scene.open_sandbox()
	check(scene.activation_count==1 and scene.phase=="credits","duplicate Enter and early sandbox entry ignored")
	await wait_to(8.2);await shot("caution_hold")
	await wait_to(11.9);await shot("black_hold")
	await RenderingServer.frame_post_draw
	var black_image=root.get_texture().get_image();black_image.convert(Image.FORMAT_RGB8)
	var maximum=0
	for value in black_image.get_data():maximum=maxi(maximum,value)
	check(maximum<=4,"native blackout has no white sliver")
	await wait_to(20.85)
	check(scene.phase=="credits" and not scene.open_button.visible,"no early title phase or button")
	await wait_to(21.2);await shot("title_reveal")
	check(scene.phase=="title" and scene.title.visible,"title appears at audio cue")
	check(scene.title.size==Vector2(1056,384),"title matches approved dimensions without clipping")
	check(scene.revealed_at>=21 and scene.revealed_at<21.12,"title transition follows the 21-second audio cue")
	await wait_to(21.7);await shot("first_firefight")
	await wait_to(26.85);check(not scene.open_button.visible,"button hidden before 27")
	await wait_to(27.1)
	check(scene.open_button.visible and not scene.open_button.disabled,"button enabled at 27")
	check(scene.enabled_at>=27 and scene.enabled_at<27.12,"button uses music clock")
	if record:await wait_to(45.0)
	var player_id=scene.music.player.get_instance_id();var before=scene.music.player.get_playback_position()
	await click(scene.open_button.get_global_rect().get_center());await frames(5)
	check(scene.phase=="sandbox" and scene.sandbox.ui.visible,"real button opens real sandbox")
	check(scene.music.player.get_instance_id()==player_id and scene.music.play_count==1,"same audio player survives entry")
	check(scene.music.player.get_playback_position()>=before,"music does not restart")
	check(scene.music.layer.visible and scene.music.toast.visible,"now-playing shown on entry")
	await shot("sandbox_entry");await create_timer(4.1).timeout
	check(scene.music.dock.visible and not scene.music.toast.visible,"now-playing docks into Music")
	await click(scene.music.dock.get_global_rect().get_center());await frames(4)
	check(scene.music.panel.visible,"Music opens functional panel")
	await shot("music_panel")
	var enabled_before=scene.music.track_enabled
	scene.music.enabled_check.button_pressed=not enabled_before;await frames(2)
	check(scene.music.track_enabled==(not enabled_before),"playlist exclusion responds")
	scene.music.enabled_check.button_pressed=enabled_before
	var resume_position=scene.music.player.get_playback_position();var resume_count=scene.music.play_count
	scene.music.pause_music();await frames(2);check(scene.music.player.stream_paused,"pause control works")
	scene.music.pause_music();await frames(2);check(not scene.music.player.stream_paused,"resume control works")
	check(scene.music.play_count==resume_count and scene.music.player.get_playback_position()>=resume_position,"resume preserves position without replay")
	scene.music.panel.hide()
	var tutorial_button=scene.sandbox.find_child("Tab_tutorial",true,false)
	if tutorial_button==null:tutorial_button=scene.sandbox.surface.get_node("TutorialButton")
	await click(tutorial_button.get_global_rect().get_center());await frames(10)
	check(scene.sandbox.get_node_or_null("SandboxTutorial")!=null,"Tutorial still opens after intro")
	report={"status":"PASS" if errors.is_empty() else "FAIL","checks":checks,"errors":errors,"title_at":scene.revealed_at,"button_at":scene.enabled_at,"sandbox_at":scene.menu_opened_at,"audio_play_count":scene.music.play_count,"native_black_max_pixel":maximum,"viewport":[1280,720],"mode":"record" if record else "smoke","runtime_and_menu_real":true}
	FileAccess.open(OUT+("record.json" if record else "smoke.json"),FileAccess.WRITE).store_string(JSON.stringify(report,"  "))
	print("OPENING_VALIDATION ",JSON.stringify(report));quit(0 if errors.is_empty() else 1)
