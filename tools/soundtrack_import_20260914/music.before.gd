extends Node
## Persistent menu player. Current catalogue contains the one owner-supplied track.
const TRACK="res://assets/menu/opening/B-22_Dead_Street.mp3"
var player: AudioStreamPlayer
var layer: CanvasLayer
var surface: Control
var dock: Button
var panel: PanelContainer
var toast: PanelContainer
var label: Label
var toggle: Button
var enabled_check: CheckBox
var volume: HSlider
var sandbox
var in_sandbox=false
var entry_clock=0.0
var signature_started=false
var track_finished=false
var play_count=0
var user_paused=false
var track_enabled=true
var last_clock=0.0
var output_latency=0.0
var settings_path="user://dead_street_music.cfg"

func _ready():
	player=AudioStreamPlayer.new(); add_child(player); player.volume_db=-4.0
	var stream=AudioStreamMP3.new(); stream.data=FileAccess.get_file_as_bytes(TRACK); player.stream=stream
	player.finished.connect(finished)
	output_latency=AudioServer.get_output_latency()
	var cfg=ConfigFile.new()
	if cfg.load(settings_path)==OK: track_enabled=bool(cfg.get_value("playlist","dead_street",true))
	layer=CanvasLayer.new(); layer.layer=90; add_child(layer); layer.hide()
	surface=Control.new(); layer.add_child(surface); surface.mouse_filter=Control.MOUSE_FILTER_IGNORE
	dock=Button.new(); surface.add_child(dock); dock.text="▥  Music   ⌄"; dock.size=Vector2(123,36)
	dock.pressed.connect(toggle_panel)
	panel=PanelContainer.new(); surface.add_child(panel); panel.custom_minimum_size=Vector2(282,245); panel.hide()
	style(panel)
	var margin=MarginContainer.new(); panel.add_child(margin)
	for side in ["left","top","right","bottom"]: margin.add_theme_constant_override("margin_"+side,14)
	var box=VBoxContainer.new(); margin.add_child(box); box.add_theme_constant_override("separation",9)
	var head=HBoxContainer.new(); box.add_child(head)
	var heading=Label.new(); heading.text="Music"; heading.add_theme_font_size_override("font_size",20); heading.size_flags_horizontal=Control.SIZE_EXPAND_FILL; head.add_child(heading)
	var close=Button.new(); close.text="×"; close.pressed.connect(func():panel.hide()); head.add_child(close)
	var now=Label.new(); now.text="NOW PLAYING"; now.add_theme_font_size_override("font_size",10); now.modulate=Color("#b4babc"); box.add_child(now)
	label=Label.new(); label.text="Dead Street\nB-22"; label.add_theme_font_size_override("font_size",16); box.add_child(label)
	var order=Label.new(); order.text="SHUFFLE ORDER"; order.add_theme_font_size_override("font_size",10); order.modulate=Color("#b4babc"); box.add_child(order)
	enabled_check=CheckBox.new(); enabled_check.text="Dead Street — B-22"; enabled_check.button_pressed=track_enabled; box.add_child(enabled_check)
	enabled_check.toggled.connect(func(on):track_enabled=on; save_settings())
	var actions=HBoxContainer.new(); box.add_child(actions)
	toggle=Button.new(); toggle.name="PlayPause"; toggle.custom_minimum_size=Vector2(38,32); toggle.pressed.connect(pause_music); actions.add_child(toggle); update_transport_button()
	var skip=Button.new(); skip.name="NextTrack"; skip.custom_minimum_size=Vector2(38,32); skip.icon=transport_icon("next"); skip.disabled=true; skip.tooltip_text="No other tracks in this playlist yet."; actions.add_child(skip)
	volume=HSlider.new(); volume.min_value=0; volume.max_value=1; volume.step=0.01; volume.value=db_to_linear(-4.0); volume.size_flags_horizontal=Control.SIZE_EXPAND_FILL; actions.add_child(volume)
	volume.value_changed.connect(func(value):player.volume_db=linear_to_db(maxf(value,0.0001)))
	toast=PanelContainer.new(); surface.add_child(toast); toast.size=Vector2(282,93); style(toast)
	var text=Label.new(); text.text="NOW PLAYING\nDead Street\nB-22"; text.position=Vector2(14,10); text.add_theme_font_size_override("font_size",16)
	var tm=MarginContainer.new(); tm.add_theme_constant_override("margin_left",14); tm.add_theme_constant_override("margin_top",10); tm.add_theme_constant_override("margin_right",14); tm.add_theme_constant_override("margin_bottom",10); toast.add_child(tm); tm.add_child(text)

func style(control: Control):
	var bg=StyleBoxFlat.new(); bg.bg_color=Color("#0b1317"); bg.border_color=Color("#939d9f"); bg.set_border_width_all(1)
	control.add_theme_stylebox_override("panel",bg)

func start_signature():
	if signature_started:return
	signature_started=true; player.play(); play_count+=1; last_clock=0

func clock() -> float:
	if not signature_started:return 0.0
	if player.stream_paused:return last_clock
	var t=player.get_playback_position()+AudioServer.get_time_since_last_mix()-output_latency
	last_clock=maxf(last_clock,maxf(0.0,t)); return last_clock

func show_on_entry():
	in_sandbox=true; entry_clock=Time.get_ticks_msec()/1000.0; layer.show(); toast.show(); dock.hide()

func _process(_delta: float):
	if not in_sandbox:return
	var menu_visible=is_instance_valid(sandbox) and sandbox.ui.visible
	layer.visible=menu_visible
	player.stream_paused=user_paused or not menu_visible
	var viewport=get_viewport().get_visible_rect().size; surface.size=viewport
	var factor=minf(1.0,minf(viewport.x/1280.0,viewport.y/720.0)); surface.scale=Vector2.ONE*factor
	var area=viewport/factor; var elapsed=Time.get_ticks_msec()/1000.0-entry_clock
	dock.position=area-Vector2(151,51); panel.position=area-Vector2(310,315)
	toast.position=area-Vector2(310,140)
	if elapsed>=3.0:
		var q=clampf((elapsed-3.0)/0.75,0.0,1.0)
		toast.position=toast.position.lerp(dock.position,q); toast.scale=Vector2.ONE.lerp(Vector2(0.436,0.387),q); toast.modulate.a=1-q
		if q>=1:toast.hide();dock.show()

func toggle_panel(): panel.visible=not panel.visible
func pause_music():
	user_paused=not user_paused; update_transport_button()
	if not user_paused and track_finished:player.play(); play_count+=1; last_clock=0.0; track_finished=false
func finished():
	# With one track, wait for a deliberate replay instead of immediately repeating it.
	track_finished=true; user_paused=true; update_transport_button()
func save_settings():
	var cfg=ConfigFile.new(); cfg.set_value("playlist","dead_street",track_enabled); cfg.save(settings_path)
func _unhandled_key_input(event: InputEvent):
	if not in_sandbox or not layer.visible:return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode==KEY_M:
		toggle_panel();get_viewport().set_input_as_handled()

func transport_icon(symbol: String) -> Texture2D:
	var shapes={
		"pause":'<rect x="5" y="4" width="5" height="16"/><rect x="14" y="4" width="5" height="16"/>',
		"play":'<path d="M6 4 L20 12 L6 20 Z"/>',
		"next":'<path d="M3 4 L16 12 L3 20 Z"/><rect x="17" y="4" width="4" height="16"/>'}
	var image=Image.new()
	image.load_svg_from_string('<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="#dce2df">'+shapes[symbol]+'</svg>')
	return ImageTexture.create_from_image(image)

func update_transport_button():
	toggle.icon=transport_icon("play" if user_paused else "pause")
	toggle.tooltip_text="Play music" if user_paused else "Pause music"

func _input(event: InputEvent):
	if not in_sandbox or not layer.visible or not panel.visible:return
	var outside_press=false
	if event is InputEventMouseButton:
		outside_press=event.pressed and event.button_index in [MOUSE_BUTTON_LEFT,MOUSE_BUTTON_RIGHT]
	elif event is InputEventScreenTouch:outside_press=event.pressed
	if not outside_press:return
	if panel.get_global_rect().has_point(event.position) or (dock.is_visible_in_tree() and dock.get_global_rect().has_point(event.position)):return
	panel.hide()
	get_viewport().set_input_as_handled()
