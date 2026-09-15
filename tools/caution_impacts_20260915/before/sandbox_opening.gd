extends Node
## The opening owns its audio across the transition into the existing sandbox.
const Music = preload("res://gameplay/sandbox_menu_music.gd")
const BASE = "res://assets/menu/opening/"
var layer: CanvasLayer
var stage: Control
var black: ColorRect
var startup: VideoStreamPlayer
var montage: VideoStreamPlayer
var title: TextureRect
var camera: TextureRect
var enter_button: TextureButton
var open_button: TextureButton
var music
var sandbox
var phase = "gate"
var elapsed = 0.0
var activation_count = 0
var revealed_at = -1.0
var enabled_at = -1.0
var menu_opened_at = -1.0

func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)
	music = Music.new(); music.name = "MenuMusic"; add_child(music)
	layer = CanvasLayer.new(); layer.layer = 100; add_child(layer)
	black = ColorRect.new(); black.color = Color.BLACK; layer.add_child(black)
	stage = Control.new(); stage.size = Vector2(1280,720); layer.add_child(stage)
	stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	montage = video("montage.ogv",true); montage.hide()
	startup = video("startup.ogv",false); startup.hide()
	title = picture("approved_title.png",Vector2(112,79),Vector2(1056,384)); title.hide()
	var shader = Shader.new()
	shader.code = "shader_type canvas_item; render_mode unshaded; void fragment(){ vec4 s=texture(TEXTURE,UV); float a=dot(s.rgb,vec3(0.299,0.587,0.114)); COLOR=vec4(vec3(1.0),a); }"
	var mat = ShaderMaterial.new(); mat.shader=shader; title.material=mat
	camera=picture("camera_ui.png",Vector2.ZERO,Vector2(1280,720)); camera.hide()
	enter_button=action_button("enter_button.png",begin); enter_button.name="Enter"
	open_button=action_button("open_button.png",open_sandbox); open_button.name="OpenSandbox"
	open_button.hide(); open_button.disabled=true
	# Build the existing menu while the silent gate covers it; no battle is launched.
	sandbox=load("res://gameplay/arsenal_review.tscn").instantiate(); sandbox.name="BattleSandbox"; add_child(sandbox)
	sandbox.ui.hide(); sandbox.process_mode=Node.PROCESS_MODE_DISABLED
	music.sandbox=sandbox
	layout()
	print("OPENING_GATE_READY")

func texture(path: String) -> Texture2D:
	return ImageTexture.create_from_image(Image.load_from_file(BASE+path))

func picture(path: String,at: Vector2,sz: Vector2) -> TextureRect:
	var p=TextureRect.new(); p.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	p.stretch_mode=TextureRect.STRETCH_SCALE; p.texture=texture(path); p.position=at; p.size=sz
	p.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	p.mouse_filter=Control.MOUSE_FILTER_IGNORE; stage.add_child(p); return p

func video(path: String,repeat: bool) -> VideoStreamPlayer:
	var p=VideoStreamPlayer.new(); var stream=VideoStreamTheora.new(); stream.file=BASE+path
	p.stream=stream; p.expand=true; p.size=Vector2(1280,720); p.loop=repeat
	p.volume=0.0; p.mouse_filter=Control.MOUSE_FILTER_IGNORE; stage.add_child(p); return p

func action_button(path: String,action: Callable) -> TextureButton:
	var b=TextureButton.new(); b.texture_normal=texture(path); b.position=Vector2(489,575); b.size=Vector2(303,55)
	b.ignore_texture_size=true; b.stretch_mode=TextureButton.STRETCH_SCALE; b.focus_mode=Control.FOCUS_ALL
	b.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND; stage.add_child(b); b.pressed.connect(action)
	b.mouse_entered.connect(func(): b.modulate=Color(1.2,1.2,1.2))
	b.mouse_exited.connect(func(): b.modulate=Color.WHITE)
	b.focus_entered.connect(func(): b.modulate=Color(1.2,1.2,1.2))
	b.focus_exited.connect(func(): b.modulate=Color.WHITE)
	return b

func layout():
	var viewport=get_viewport().get_visible_rect().size
	black.size=viewport
	var factor=minf(viewport.x/1280.0,viewport.y/720.0)
	stage.scale=Vector2.ONE*factor; stage.position=(viewport-Vector2(1280,720)*factor)*0.5

func begin():
	if phase!="gate": return
	activation_count+=1; enter_button.disabled=true; enter_button.hide()
	phase="credits"; elapsed=0.0
	music.start_signature(); startup.show(); startup.play()
	print("OPENING_ACTIVATED")

func _process(delta: float):
	layout()
	if phase=="gate" or phase=="sandbox": return
	elapsed=maxf(elapsed,music.clock())
	if phase=="title" and not music.player.playing:elapsed+=delta
	if phase=="credits":
		# Follow the audible music clock; small corrections avoid long video drift.
		startup.speed_scale=clampf(1.0+(elapsed-startup.stream_position)*0.3,0.94,1.06)
		if elapsed>=21.0:
			phase="title"; revealed_at=elapsed
			startup.hide(); startup.stop(); title.show(); camera.show(); montage.show(); montage.play()
			print("OPENING_TITLE ",elapsed)
	if phase=="title":
		var t=elapsed-21.0
		title.position.y=79+round(2.2*sin(TAU*t/1.35)+0.55*sin(TAU*t/0.43))
		montage.modulate.a=clampf(t/0.6,0.0,1.0); camera.modulate.a=montage.modulate.a
		if elapsed>=27.0 and not open_button.visible:
			open_button.show(); open_button.disabled=false; enabled_at=elapsed
			print("OPENING_SANDBOX_ENABLED ",elapsed)

func open_sandbox():
	if phase!="title" or elapsed<27.0: return
	phase="sandbox"; menu_opened_at=music.clock(); open_button.disabled=true
	montage.stop(); startup.stop(); layer.hide()
	sandbox.process_mode=Node.PROCESS_MODE_INHERIT; sandbox.ui.show()
	music.show_on_entry()
	print("OPENING_SANDBOX_ENTERED ",menu_opened_at)

func _unhandled_key_input(event: InputEvent):
	if event is InputEventKey and event.pressed and not event.echo and event.keycode==KEY_ENTER:
		if phase=="gate": begin(); get_viewport().set_input_as_handled()
		elif phase=="title" and elapsed>=27.0: open_sandbox(); get_viewport().set_input_as_handled()
