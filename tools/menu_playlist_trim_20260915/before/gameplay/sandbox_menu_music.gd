extends Node
## Persistent player: signature across entry, then an enabled-track shuffle bag.
const Catalog = preload("res://gameplay/music_catalog.gd")
var player: AudioStreamPlayer
var layer: CanvasLayer
var surface: Control
var dock: Button
var panel: PanelContainer
var toast: PanelContainer
var label: Label
var toast_label: Label
var toggle: Button
var skip: Button
var shuffle: Button
var volume: HSlider
var queue_box: VBoxContainer
var track_checks = {}
var tracks: Array = []
var enabled_tracks = {}
var queue: Array[String] = []
var current_id = "dead_street"
var sandbox
var in_sandbox = false
var entry_clock = 0.0
var signature_started = false
var track_finished = false
var play_count = 0
var user_paused = false
var preview_paused = false
var last_clock = 0.0
var output_latency = 0.0
var settings_path = "user://dead_street_music.cfg"
var volume_value = db_to_linear(-4.0)

func _ready():
	add_to_group("dead_street_menu_music")
	tracks = Catalog.tracks()
	current_id = str(Catalog.catalogue().get("signature_track", "dead_street"))
	var cfg = ConfigFile.new()
	cfg.load(settings_path)
	for track in tracks:
		var id = str(track.id)
		enabled_tracks[id] = bool(cfg.get_value("playlist", id, track.get("default_enabled", true)))
	volume_value = clampf(float(cfg.get_value("player", "volume", volume_value)), 0, 1)
	player = AudioStreamPlayer.new(); add_child(player)
	player.stream = Catalog.menu_stream(current_id)
	player.volume_db = linear_to_db(maxf(volume_value, 0.0001))
	player.finished.connect(finished)
	output_latency = AudioServer.get_output_latency()
	refill_queue()
	build_ui()
	refresh_tracks()

func build_ui():
	layer = CanvasLayer.new(); layer.layer = 90; add_child(layer); layer.hide()
	surface = Control.new(); layer.add_child(surface); surface.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dock = Button.new(); surface.add_child(dock); dock.text = "▥  Music   ⌄"; dock.size = Vector2(123,36)
	dock.pressed.connect(toggle_panel)
	panel = PanelContainer.new(); surface.add_child(panel); panel.custom_minimum_size = Vector2(282,300); panel.hide(); style(panel)
	var margin = MarginContainer.new(); panel.add_child(margin)
	for side in ["left","top","right","bottom"]: margin.add_theme_constant_override("margin_"+side,14)
	var box = VBoxContainer.new(); margin.add_child(box); box.add_theme_constant_override("separation",9)
	var head = HBoxContainer.new(); box.add_child(head)
	var heading = Label.new(); heading.text = "Music"; heading.add_theme_font_size_override("font_size",20); heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL; head.add_child(heading)
	var close = Button.new(); close.text = "×"; close.pressed.connect(func():panel.hide()); head.add_child(close)
	var now = Label.new(); now.text = "NOW PLAYING"; now.add_theme_font_size_override("font_size",10); now.modulate = Color("#b4babc"); box.add_child(now)
	label = Label.new(); label.custom_minimum_size.x = 254; label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; label.add_theme_font_size_override("font_size",16); box.add_child(label)
	var order = Label.new(); order.text = "SHUFFLE ORDER"; order.add_theme_font_size_override("font_size",10); order.modulate = Color("#b4babc"); box.add_child(order)
	var scroll = ScrollContainer.new(); scroll.custom_minimum_size = Vector2(254,100); scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED; scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO; box.add_child(scroll)
	queue_box = VBoxContainer.new(); queue_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL; scroll.add_child(queue_box)
	var hint = Label.new(); hint.text = "Check tracks to include them in shuffle."; hint.add_theme_font_size_override("font_size",10); hint.modulate = Color("#b4babc"); box.add_child(hint)
	var actions = HBoxContainer.new(); box.add_child(actions)
	toggle = Button.new(); toggle.name = "PlayPause"; toggle.custom_minimum_size = Vector2(38,32); toggle.pressed.connect(pause_music); actions.add_child(toggle)
	skip = Button.new(); skip.name = "NextTrack"; skip.custom_minimum_size = Vector2(38,32); skip.icon = transport_icon("next"); skip.pressed.connect(next_track); actions.add_child(skip)
	shuffle = Button.new(); shuffle.name = "ShuffleTracks"; shuffle.custom_minimum_size = Vector2(38,32); shuffle.icon = transport_icon("shuffle"); shuffle.pressed.connect(reshuffle_tracks); actions.add_child(shuffle)
	volume = HSlider.new(); volume.min_value = 0; volume.max_value = 1; volume.step = 0.01; volume.value = volume_value; volume.size_flags_horizontal = Control.SIZE_EXPAND_FILL; volume.tooltip_text = "Music volume"; actions.add_child(volume)
	volume.value_changed.connect(func(value):volume_value=value; player.volume_db=linear_to_db(maxf(value,0.0001)); save_settings())
	toast = PanelContainer.new(); surface.add_child(toast); toast.custom_minimum_size = Vector2(158,56); toast.hide(); style(toast); toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tm = MarginContainer.new(); tm.mouse_filter = Control.MOUSE_FILTER_IGNORE; toast.add_child(tm)
	for side in ["left","top","right","bottom"]: tm.add_theme_constant_override("margin_"+side,8)
	toast_label = Label.new(); toast_label.mouse_filter = Control.MOUSE_FILTER_IGNORE; toast_label.custom_minimum_size = Vector2(140,34); toast_label.autowrap_mode = TextServer.AUTOWRAP_OFF; toast_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS; toast_label.clip_text = true; toast_label.add_theme_font_size_override("font_size",12); tm.add_child(toast_label)

func info(id: String) -> Dictionary:
	for track in tracks:
		if str(track.id) == id: return track
	return {}

func refill_queue():
	queue.clear()
	for track in tracks:
		var id = str(track.id)
		if id != current_id and enabled_tracks.get(id, false): queue.append(id)
	queue.shuffle()

func set_track_enabled(id: String, on: bool):
	enabled_tracks[id] = on
	if not on: queue.erase(id)
	elif id != current_id and id not in queue: queue.append(id)
	save_settings()
	# Rebuild after the checkbox has finished dispatching its input.
	refresh_tracks.call_deferred()

func refresh_tracks():
	for child in queue_box.get_children():
		queue_box.remove_child(child); child.queue_free()
	track_checks.clear()
	var shown: Array[String] = [current_id]
	for id in queue:
		if id not in shown: shown.append(id)
	for track in tracks:
		if str(track.id) not in shown: shown.append(str(track.id))
	for id in shown:
		var track = info(id)
		var check = CheckBox.new(); check.name = "Track_"+id
		var prefix = "Now · " if id == current_id else (str(queue.find(id)+1)+" · " if id in queue else "— · ")
		check.text = prefix+str(track.get("title",id))+" — "+str(track.get("artist",""))
		check.clip_text = true; check.custom_minimum_size = Vector2(250,30)
		check.button_pressed = enabled_tracks.get(id,false)
		check.tooltip_text = str(track.get("title",id))+" — "+str(track.get("artist",""))+"\nInclude in shuffle. The current song finishes even if unchecked."
		if id != current_id and id not in queue and check.button_pressed: check.tooltip_text += "\nReturns in the next shuffle round."
		_bind_check(check,id)
		queue_box.add_child(check); track_checks[id] = check
	var current = info(current_id)
	label.text = str(current.get("title",""))+"\n"+str(current.get("artist",""))
	toast_label.text = label.text
	toast_label.tooltip_text = label.text
	update_transport_button()

func _bind_check(check: CheckBox, id: String):
	check.toggled.connect(func(on):set_track_enabled(id,on))

func style(control: Control):
	var bg = StyleBoxFlat.new(); bg.bg_color = Color("#0b1317"); bg.border_color = Color("#939d9f"); bg.set_border_width_all(1)
	control.add_theme_stylebox_override("panel",bg)

func start_signature():
	if signature_started: return
	signature_started = true; player.play(); play_count += 1; last_clock = 0

func clock() -> float:
	if not signature_started: return 0.0
	if player.stream_paused: return last_clock
	var t = player.get_playback_position()+AudioServer.get_time_since_last_mix()-output_latency
	last_clock = maxf(last_clock,maxf(0.0,t)); return last_clock

func show_on_entry():
	in_sandbox = true
	layer.show()
	show_track_toast()
	# A signature that ended while waiting at the title advances only after entry.
	if track_finished and not queue.is_empty(): advance(false)

func show_track_toast():
	entry_clock = Time.get_ticks_msec()/1000.0
	toast.scale = Vector2.ONE; toast.modulate.a = 1; toast.show(); dock.show()

func _process(_delta: float):
	if not in_sandbox: return
	var menu_visible = is_instance_valid(sandbox) and sandbox.ui.visible
	layer.visible = menu_visible
	player.stream_paused = user_paused or preview_paused or not menu_visible
	var viewport = get_viewport().get_visible_rect().size; surface.size = viewport
	var factor = maxf(0.1,minf(1.0,minf(viewport.x/1280.0,viewport.y/720.0))); surface.scale = Vector2.ONE*factor
	var area = viewport/factor
	dock.position = area-Vector2(151,51)
	panel.position = Vector2(maxf(12,area.x-panel.size.x-28),maxf(12,area.y-panel.size.y-70))
	toast.position = Vector2(area.x-toast.size.x-28,dock.position.y-toast.size.y-8)
	if panel.visible: toast.position = Vector2(panel.position.x+panel.size.x-toast.size.x,maxf(12,panel.position.y-toast.size.y-8))
	var elapsed = Time.get_ticks_msec()/1000.0-entry_clock
	if elapsed >= 3.0:
		var q = clampf((elapsed-3.0)/0.75,0.0,1.0)
		if not panel.visible:
			toast.position = toast.position.lerp(dock.position,q); toast.scale = Vector2.ONE.lerp(dock.size/toast.size,q)
		toast.modulate.a = 1-q
		if q >= 1: toast.hide(); dock.show()

func toggle_panel(): panel.visible = not panel.visible

func advance(preserve_pause: bool) -> bool:
	if queue.is_empty(): refill_queue()
	if queue.is_empty(): return false
	var id = queue.pop_front()
	var stream = Catalog.menu_stream(id)
	if stream == null:
		push_warning("Music file unavailable: "+id)
		return false
	var was_paused = user_paused
	current_id = id; player.stream = stream; player.play(); play_count += 1
	track_finished = false; user_paused = was_paused if preserve_pause else false
	player.stream_paused = user_paused or preview_paused or (in_sandbox and (not is_instance_valid(sandbox) or not sandbox.ui.visible))
	# Refill only at a round boundary; exclude the song just selected.
	if queue.is_empty(): refill_queue()
	refresh_tracks()
	if in_sandbox: show_track_toast()
	return true

func next_track():
	if in_sandbox and layer.visible: advance(true)

func reshuffle_tracks():
	if not in_sandbox or not layer.visible: return
	var fresh: Array[String] = []
	for track in tracks:
		var id = str(track.id)
		if enabled_tracks.get(id,false): fresh.append(id)
	if fresh.is_empty(): return
	fresh.shuffle()
	if fresh.size()>1 and fresh[0]==current_id:
		var alternate = randi_range(1,fresh.size()-1)
		fresh[0]=fresh[alternate]; fresh[alternate]=current_id
	queue.assign(fresh)
	# A deliberate new shuffle starts its first song immediately, including from pause.
	advance(false)

func pause_music():
	if track_finished:
		if not advance(false) and enabled_tracks.get(current_id,false):
			player.play(); play_count += 1; track_finished = false; user_paused = false
	else: user_paused = not user_paused
	player.stream_paused = user_paused or preview_paused
	update_transport_button()

func finished():
	track_finished = true
	if in_sandbox and advance(false): return
	# Before entry preserve the completed signature clock for the opening.
	user_paused = true
	update_transport_button()

func set_preview_paused(on: bool):
	preview_paused=on
	var hidden=in_sandbox and (not is_instance_valid(sandbox) or not sandbox.ui.visible)
	player.stream_paused=user_paused or preview_paused or hidden

func save_settings():
	var cfg = ConfigFile.new()
	for id in enabled_tracks: cfg.set_value("playlist",id,enabled_tracks[id])
	cfg.set_value("player","volume",volume_value)
	cfg.save(settings_path)

func _unhandled_key_input(event: InputEvent):
	if not in_sandbox or not layer.visible: return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_M:
			toggle_panel(); get_viewport().set_input_as_handled()
		elif event.keycode == KEY_MEDIANEXT:
			next_track(); get_viewport().set_input_as_handled()
		elif event.keycode == KEY_MEDIAPLAY or (panel.visible and event.keycode == KEY_SPACE):
			pause_music(); get_viewport().set_input_as_handled()
		elif event.keycode == KEY_ESCAPE and panel.visible:
			panel.hide(); get_viewport().set_input_as_handled()

func transport_icon(symbol: String) -> Texture2D:
	var shapes = {
		"pause":'<rect x="5" y="4" width="5" height="16"/><rect x="14" y="4" width="5" height="16"/>',
		"play":'<path d="M6 4 L20 12 L6 20 Z"/>',
		"next":'<path d="M3 4 L16 12 L3 20 Z"/><rect x="17" y="4" width="4" height="16"/>',
		"shuffle":'<g fill="none" stroke="#dce2df" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 6H6C10 6 14 18 18 18H21M17 14l4 4 -4 4M3 18H6C8 18 9 15 10.5 13M13.5 9C15 7 16 6 18 6H21M17 2l4 4 -4 4"/></g>'}
	var image = Image.new()
	image.load_svg_from_string('<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="#dce2df">'+shapes[symbol]+'</svg>')
	return ImageTexture.create_from_image(image)

func update_transport_button():
	toggle.icon = transport_icon("play" if user_paused else "pause")
	toggle.tooltip_text = "Play music" if user_paused else "Pause music"
	var enabled_count = 0
	for track in tracks:
		if enabled_tracks.get(str(track.id),false): enabled_count += 1
	shuffle.disabled = enabled_count==0
	shuffle.tooltip_text = "Shuffle enabled songs and play the new first song" if enabled_count>0 else "Check a track to enable Shuffle."
	skip.disabled = queue.is_empty()
	skip.tooltip_text = "Next track" if not skip.disabled else "Check another track to enable Next."

func _input(event: InputEvent):
	if not in_sandbox or not layer.visible or not panel.visible: return
	var outside_press = false
	if event is InputEventMouseButton: outside_press = event.pressed and event.button_index in [MOUSE_BUTTON_LEFT,MOUSE_BUTTON_RIGHT]
	elif event is InputEventScreenTouch: outside_press = event.pressed
	if not outside_press: return
	if panel.get_global_rect().has_point(event.position) or (dock.is_visible_in_tree() and dock.get_global_rect().has_point(event.position)): return
	panel.hide()
	get_viewport().set_input_as_handled()
