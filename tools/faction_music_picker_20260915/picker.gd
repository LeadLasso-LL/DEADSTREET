extends SceneTree
const Catalog=preload("res://gameplay/music_catalog.gd")
const OUT="res://tools/faction_music_picker_20260915/"
var factions={}
var tracks=[]
var choices={}
var rows={}
var current=""
var player: AudioStreamPlayer
var stage: Control
var status: Label
var now: Label
var save_path=OUT+"assignments.json"
var testing=false
var tan=Color("#d8c491")
func _initialize():call_deferred("build")
func text_at(value: String,at: Vector2,sz: Vector2,points=16)->Label:
	var n=Label.new();stage.add_child(n);n.text=value;n.position=at;n.size=sz
	n.add_theme_font_size_override("font_size",points);return n
func style(bg: Color,border: Color)->StyleBoxFlat:
	var s=StyleBoxFlat.new();s.bg_color=bg;s.border_color=border
	s.set_border_width_all(1);s.set_corner_radius_all(4);s.content_margin_left=9;s.content_margin_right=9
	return s
func button(value: String,at: Vector2,sz: Vector2,action: Callable)->Button:
	var b=Button.new();stage.add_child(b);b.text=value;b.position=at;b.size=sz;b.pressed.connect(action);return b
func build():
	testing="--assignment-check" in OS.get_cmdline_user_args()
	if testing:save_path=OUT+"test_assignments.json"
	root.title="Dead Street — Faction Music Assignments";root.size=Vector2i(1000,750)
	root.content_scale_size=Vector2i.ZERO;root.content_scale_mode=Window.CONTENT_SCALE_MODE_DISABLED
	root.set_flag(Window.FLAG_RESIZE_DISABLED,true)
	RenderingServer.set_default_clear_color(Color("#142023"))
	stage=Control.new();root.add_child(stage);stage.size=Vector2(1000,750)
	var theme=Theme.new();theme.default_font_size=16
	var font=SystemFont.new();font.font_names=PackedStringArray(["Arial"]);theme.default_font=font
	for type in ["Button","OptionButton"]:
		theme.set_stylebox("normal",type,style(Color("#263539"),Color("#465653")))
		theme.set_stylebox("hover",type,style(Color("#35443f"),tan))
		theme.set_stylebox("pressed",type,style(Color("#485444"),tan))
		theme.set_color("font_color",type,Color("#ede9dc"))
	stage.theme=theme
	factions=JSON.parse_string(FileAccess.get_file_as_string("res://assets/data/faction_units.json")).factions
	for track in Catalog.tracks():
		if track.has("battle_loop"):tracks.append(track)
	if FileAccess.file_exists(save_path):
		var saved=JSON.parse_string(FileAccess.get_file_as_string(save_path))
		if saved is Dictionary:choices=saved.get("faction_tracks",{})
	player=AudioStreamPlayer.new();root.add_child(player);player.volume_db=-8
	text_at("FACTION MUSIC",Vector2(24,13),Vector2(360,30),23).modulate=tan
	status=text_at("",Vector2(430,17),Vector2(545,26),15);status.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
	text_at("Choose a track to assign and hear it. Each preview loops. Your choices save automatically.",Vector2(24,49),Vector2(950,22),14)
	var i=0
	for id in factions:
		if id in ["trc","nbpd"]:continue
		var y=86+i*28
		var backdrop=ColorRect.new();stage.add_child(backdrop);backdrop.position=Vector2(18,y);backdrop.size=Vector2(964,27)
		backdrop.color=Color("#1d2c30") if i%2==0 else Color("#172428");backdrop.mouse_filter=Control.MOUSE_FILTER_IGNORE
		var emblem=TextureRect.new();stage.add_child(emblem);emblem.position=Vector2(25,y+1);emblem.size=Vector2(26,26)
		emblem.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;emblem.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		emblem.texture=ImageTexture.create_from_image(Image.load_from_file(str(factions[id].emblem)))
		text_at(str(factions[id].name),Vector2(61,y),Vector2(412,27),16)
		var pick=OptionButton.new();stage.add_child(pick);pick.position=Vector2(478,y);pick.size=Vector2(437,27)
		pick.add_theme_font_size_override("font_size",15);pick.get_popup().add_theme_font_size_override("font_size",16)
		pick.add_item("Choose snippet…")
		for track in tracks:pick.add_item(str(track.title)+" — "+str(track.artist))
		var selected=0
		for n in range(tracks.size()):
			if str(tracks[n].id)==str(choices.get(id,"")):selected=n+1
		pick.select(selected)
		pick.item_selected.connect(func(index):choose(id,index))
		var play=button("▶",Vector2(924,y),Vector2(49,27),func():audition(id));play.disabled=selected==0
		play.tooltip_text="Play or pause this faction's selected snippet"
		rows[id]={"pick":pick,"play":play,"emblem":emblem}
		i+=1
	now=text_at("Nothing playing",Vector2(24,688),Vector2(640,26),15);now.modulate=tan
	button("Save screenshot",Vector2(787,690),Vector2(189,34),save_screenshot)
	text_at("TRC & NBPD retain their existing sirens.",Vector2(24,721),Vector2(740,20),13)
	refresh()
	if testing:call_deferred("check")
func choose(id,index):
	if index==0:choices.erase(id)
	else:choices[id]=str(tracks[index-1].id)
	if current==id:player.stop();current=""
	save_choices();refresh()
	if index>0:audition(id)
func save_choices():
	var mapped={};var human=[]
	for id in rows:
		var tid=str(choices.get(id,""))
		if tid.is_empty():continue
		mapped[id]=tid;var track=Catalog.track(tid)
		human.append({"faction":factions[id].name,"faction_id":id,"track":track.title,"artist":track.artist,"track_id":tid})
	var f=FileAccess.open(save_path,FileAccess.WRITE)
	if f:f.store_string(JSON.stringify({"schema":1,"status":"owner_draft","faction_tracks":mapped,"assignments":human,"siren_factions":["trc","nbpd"]},"  "))
	else:now.text="Could not save choices — please take a screenshot."
func audition(id):
	if str(choices.get(id,"")).is_empty():return
	if current==id and player.playing:
		player.stream_paused=not player.stream_paused
	else:
		player.stop();player.stream=Catalog.battle_stream(str(choices[id]));player.stream_paused=false
		current=id;player.play()
	refresh()
func refresh():
	var count=0
	for id in rows:
		var assigned=not str(choices.get(id,"")).is_empty()
		if assigned:count+=1
		rows[id].play.disabled=not assigned
		rows[id].play.text="Ⅱ" if current==id and player.playing and not player.stream_paused else "▶"
	status.text=str(count)+" / "+str(rows.size())+" assigned"
	if now:
		if current.is_empty():now.text="Nothing playing"
		else:
			var t=Catalog.track(str(choices[current]))
			now.text=("Paused: " if player.stream_paused else "Playing: ")+str(t.title)+" — "+str(t.artist)+"  ·  "+str(factions[current].name)
func save_screenshot():
	await process_frame;await RenderingServer.frame_post_draw
	var target=OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP).path_join("Dead-Street-Faction-Music-Assignments.png")
	var result=root.get_texture().get_image().save_png(target)
	now.text="Screenshot saved to Desktop." if result==OK else "Use your screenshot shortcut to capture this screen."
func check():
	await process_frame;await process_frame
	var checks={"21_factions":rows.size()==21,"21_snippets":tracks.size()==21,"authorities_excluded":not rows.has("trc") and not rows.has("nbpd")}
	var visible=true;var emblems=true
	for id in rows:
		visible=visible and Rect2(Vector2.ZERO,Vector2(root.size)).encloses(rows[id].play.get_global_rect())
		emblems=emblems and rows[id].emblem.texture!=null and rows[id].pick.item_count==22
	checks["all_rows_fit"]=visible;checks["emblems_and_all_choices"]=emblems
	rows["mercer"].pick.select(1);rows["mercer"].pick.item_selected.emit(1)
	await create_timer(.25).timeout
	checks["selection_plays"]=player.playing and current=="mercer"
	checks["draft_saved"]=JSON.parse_string(FileAccess.get_file_as_string(save_path)).faction_tracks.mercer==tracks[0].id
	rows["mercer"].play.pressed.emit();checks["pause"]=player.stream_paused
	rows["mercer"].play.pressed.emit();checks["resume"]=not player.stream_paused
	rows["mercer"].pick.select(0);rows["mercer"].pick.item_selected.emit(0);checks["clear"]=not choices.has("mercer") and rows["mercer"].play.disabled
	await process_frame;await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+"picker-review.png")
	FileAccess.open(OUT+"validation.json",FileAccess.WRITE).store_string(JSON.stringify(checks,"  "))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
	print("PICKER_CHECKS ",checks);quit(0 if not checks.values().has(false) else 1)
