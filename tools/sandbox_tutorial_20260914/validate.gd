extends SceneTree
const OUT = "C:/Users/brand/OneDrive/Documents/dead-street/tools/sandbox_tutorial_20260914/"
var checks = 0
var errors: Array = []
var frames = 0
var scene
var panel
var fast = false
var preview_end_seconds = 0.0
func _initialize(): call_deferred("run")
func check(ok: bool, label: String):
	checks += 1
	if not ok: errors.append(label); printerr("TUTORIAL_FAIL ",label)
func wait_frames(count: int):
	for i in range(count): await process_frame; frames += 1
func pause(seconds: float): await wait_frames(3 if fast else int(seconds*30))
func click(point: Vector2):
	await move(point)
	for down in [true,false]:
		var event = InputEventMouseButton.new()
		event.position = point; event.global_position = point
		event.button_index = MOUSE_BUTTON_LEFT; event.pressed = down
		Input.parse_input_event(event)
		await process_frame
func move(point: Vector2):
	var event = InputEventMouseMotion.new()
	event.position = point; event.global_position = point
	Input.parse_input_event(event)
	await wait_frames(3)
func key(code: Key):
	var event = InputEventKey.new(); event.keycode = code; event.pressed = true
	Input.parse_input_event(event); await wait_frames(3)
func shot(name: String):
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+name+".png")
func region_index(id: String) -> int:
	for i in range(panel.regions.size()):
		if panel.regions[i].id==id: return i
	return -1
func exposed_point(index: int) -> Vector2:
	var rect: Rect2 = panel.region_rect(index)
	for y in [.5,.1,.9,.3,.7]:
		for x in [.5,.1,.9,.3,.7]:
			var point = rect.position+rect.size*Vector2(x,y)
			if panel.hit_test(point)==index: return point
	return Vector2.INF
func inspect(id: String, seconds: float = 3.0):
	var index = region_index(id)
	check(index>=0,"region exists "+id)
	if index<0: return
	var point = exposed_point(index)
	check(point.is_finite(),"region reachable "+id)
	if not point.is_finite(): return
	await move(panel.canvas.position+point)
	check(panel.active_index==index and panel.tip.visible,"hover chooses "+id)
	check(panel.tip_text.text==panel.regions[index].text,"correct help "+id)
	check(Rect2(Vector2.ZERO,panel.surface.size).encloses(panel.tip.get_rect()),"tooltip inside window "+id)
	await pause(seconds)
func run():
	fast = "--fast" in OS.get_cmdline_user_args()
	root.size=Vector2i(1440,1000); DisplayServer.window_set_size(root.size)
	scene=load("res://gameplay/arsenal_review.tscn").instantiate(); root.add_child(scene)
	await wait_frames(10)
	var button=scene.surface.get_node("TutorialButton")
	check(scene.runtime==null,"menu has no battle")
	await pause(1)
	await click(button.get_global_rect().get_center())
	panel=scene.get_node_or_null("SandboxTutorial")
	check(panel!=null,"Tutorial button opens panel")
	if panel==null: quit(1);return
	await wait_frames(10)
	check(panel.texture!=null and panel.regions.size()>100,"real image and hotspots loaded")
	check(scene.runtime==null,"tutorial creates no battle")
	scene.open_tutorial()
	check(scene.get_children().filter(func(n):return n.name=="SandboxTutorial").size()==1,"one tutorial instance")
	await shot("tutorial_overview")
	await pause(1.5)
	var groups=[]
	for row in panel.regions:
		if row.id.begins_with("group_"): groups.append(row.text)
	check(groups.size()==6 and groups.all(func(text):return text==groups[0]),"identical group help")
	var unreachable=[]
	for i in range(panel.regions.size()):
		if not exposed_point(i).is_finite():unreachable.append(panel.regions[i].id)
	check(unreachable.is_empty(),"all regions reachable: "+str(unreachable))
	await inspect("group_",3.)
	await inspect("push",6.)
	await shot("tutorial_push")
	await inspect("cover_cover_north_car_2",5.)
	await shot("tutorial_cover")
	await inspect("health_sandbox_attacker_unit_04",3.)
	await inspect("playback_0",3.)
	await inspect("unit_sandbox_defender_unit_01",4.)
	await inspect("fall_back",5.)
	await inspect("map",4.)
	preview_end_seconds = Engine.get_process_frames()/30.0
	# Real wheel input keeps the hovered image point anchored and enlarges targets.
	var old_size=panel.image_rect().size
	var wheel=InputEventMouseButton.new();wheel.position=panel.canvas.position+panel.canvas.size*.5
	wheel.global_position=wheel.position;wheel.button_index=MOUSE_BUTTON_WHEEL_UP;wheel.pressed=true
	Input.parse_input_event(wheel);await wait_frames(1)
	wheel = wheel.duplicate();wheel.pressed=false
	Input.parse_input_event(wheel);await wait_frames(3)
	check(panel.zoom>1. and panel.image_rect().size.x>old_size.x,"wheel zoom")
	await click(panel.reset_button.get_global_rect().get_center())
	check(is_equal_approx(panel.zoom,1.),"Fit Image resets zoom")
	await click(panel.show_button.get_global_rect().get_center())
	check(panel.show_button.button_pressed,"show hotspots switch")
	await pause(2.)
	await click(panel.show_button.get_global_rect().get_center())
	panel.canvas.grab_focus()
	await key(KEY_RIGHT)
	check(panel.active_index>=0 and panel.tip.visible,"keyboard help browsing")
	for dimensions in [Vector2i(1152,860),Vector2i(1280,720),Vector2i(390,844)]:
		root.size=dimensions;DisplayServer.window_set_size(dimensions);await wait_frames(8)
		await inspect("push",.1)
		check(panel.surface.get_rect().encloses(panel.close_button.get_rect()),"close in bounds "+str(dimensions))
		if dimensions.x==390:await shot("tutorial_narrow")
	root.size=Vector2i(1440,1000);DisplayServer.window_set_size(root.size);await wait_frames(8)
	await key(KEY_ESCAPE)
	check(not scene.has_node("SandboxTutorial"),"Escape closes tutorial")
	check(scene.runtime==null and scene.ui.visible,"menu restored without a battle")
	await click(button.get_global_rect().get_center());await wait_frames(5)
	panel=scene.get_node("SandboxTutorial")
	check(panel.active_index==-1 and is_equal_approx(panel.zoom,1.),"reopen starts clean")
	await click(panel.close_button.get_global_rect().get_center());await wait_frames(3)
	check(not scene.has_node("SandboxTutorial"),"Close button closes tutorial")
	var f=FileAccess.open(OUT+("smoke.json" if fast else "record.json"),FileAccess.WRITE)
	f.store_string(JSON.stringify({"preview_end_seconds":preview_end_seconds,"checks":checks,"errors":errors,"frames":frames,"no_battle_created":scene.runtime==null},"\t"));f.close()
	print("TUTORIAL_VALIDATION ",checks," checks; ",errors.size()," failures")
	quit(0 if errors.is_empty() else 1)
