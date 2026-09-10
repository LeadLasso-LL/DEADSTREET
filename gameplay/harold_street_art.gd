extends "res://gameplay/dusk_street_art.gd"
# Reusable brick frontage, stoop, parking and cutaway vocabulary.
const H = preload("res://battle/geometry/harold_street_catalog.gd")
var apartment_font: SystemFont
var shop_font: SystemFont
var gang_font: SystemFont
const BRICK = [Color("#514039"),Color("#654b3f"),Color("#473e38")]
func _ready() -> void:
	super._ready()
	apartment_font=SystemFont.new()
	apartment_font.font_names=PackedStringArray(["Georgia","Times New Roman"])
	shop_font=SystemFont.new()
	shop_font.font_names=PackedStringArray(["Arial","Liberation Sans"])
	shop_font.font_weight=700
	gang_font=SystemFont.new()
	gang_font.font_names=PackedStringArray(["Old English Text MT"])

	if not prop.is_empty() and prop[2]=="car":
		var colors=[Color("#777367"),Color("#75443e"),Color("#536258"),Color("#989786"),Color("#424d5e"),Color("#514e46")]
		var paint=colors[absi(str(prop[0]).hash())%colors.size()]
		if prop[0]=="arrival_car":paint=Color("#333b3e")
		material.set_shader_parameter("paint",Vector3(paint.r,paint.g,paint.b))
	if prop.is_empty():
		var im=Image.create(128,128,false,Image.FORMAT_RGBA8)
		for y in range(128):
			for x in range(128):
				var f=maxf(0.,1.-Vector2(x-64,y-64).length()/64.)
				im.set_pixel(x,y,Color(1,1,1,f*f*.65))
		var tex=ImageTexture.create_from_image(im)
		for spot in [[Vector2(6,23),1.1],[Vector2(29,23),1.0],[Vector2(54,23),1.1],[Vector2(17,35),.8],[Vector2(45,35),.8],[Vector2(9,16),.6],[Vector2(25,16),.45]]:
			var light=PointLight2D.new()
			light.texture=tex;light.position=Vector2(spot[0].x*8,spot[0].y*6)
			light.color=Color("#ffd4a0");light.energy=spot[1];light.texture_scale=1.0
			add_child(light)
func ground() -> void:
	rng.seed=991
	rect(Rect2(-1000,-1000,2500,2000),Color("#161c23"))
	box(Rect2(-40,0,144,46),Color("#30332f"))
	box(Rect2(-40,23,144,12),Color("#252b30"))
	for band in [Rect2(-40,15,144,8),Rect2(-40,35,144,6)]:
		box(band,Color("#484841"))
		for x in range(-40,104,2):
			for y in range(int(band.position.y),int(band.end.y),2):
				var q=p(Vector2(x,y))
				rect(Rect2(q+Vector2(.4,.4),Vector2(15.2,11.2)),Color("#515047").lightened(rng.randf_range(-.022,.014)))
				if rng.randf()<.25:line(q+Vector2(2,1),q+Vector2(7,8),Color("#303630"),.45)
	for y in [23,35]:
		var q=p(Vector2(-40,y))
		rect(Rect2(q,Vector2(1152,1.5)),Color("#8a8370"))
		rect(Rect2(q+Vector2(0,1.5),Vector2(1152,1.2)),Color("#171f23"))
	for x in range(-320,830,27):
		for y in [173,175]:rect(Rect2(x,y,13,.65),Color("#897044"))
	# Dry asphalt: aggregate and cracks; no wet reflections.
	for i in range(7500):
		var q=Vector2(rng.randf_range(-70,580),rng.randf_range(140,209))
		rect(Rect2(q,Vector2(.45,.35)),Color(.55,.55,.5,rng.randf_range(.035,.13)))
	for i in range(50):
		var q=Vector2(rng.randf_range(0,512),rng.randf_range(141,208))
		line(q,q+Vector2(3,1),Color("#151d21"),.5);line(q+Vector2(3,1),q+Vector2(5,-1),Color("#151d21"),.4)
	# Small, irregular accumulations by bins and deliveries; no dotted curb border.
	for cluster in [Vector2(29,107),Vector2(127,105),Vector2(274,108),Vector2(310,119),Vector2(456,106)]:
		for i in range(10):
			var q=cluster+Vector2(rng.randfn(0,5),rng.randfn(0,2.5))
			var c=[Color("#999078"),Color("#686e5e"),Color("#655342")][i%3]
			draw_colored_polygon(PackedVector2Array([q,q+Vector2(1.6,-.4),q+Vector2(2,.5),q+Vector2(.4,1)]),c)
	for x in [7,19,41,60]:
		var q=p(Vector2(x,23.2));rect(Rect2(q,Vector2(9,2.2)),INK)
		for n in range(9):line(q+Vector2(n,0),q+Vector2(n,2),Color("#686c61"),.45)
	for q in [Vector2(120,187),Vector2(367,165)]:
		draw_circle(q,3.4,Color("#151e22"));draw_circle(q,2.8,Color("#525a52"))
		for n in range(-2,3):line(q+Vector2(-2,n*.7),q+Vector2(2,n*.7),Color("#27342f"),.45)
	# Facades continue off both map edges with the road.
	for x in [-272.,512.]:
		bricks(Rect2(x,-280,272,370),Color("#493e36"))
		for row in range(8):
			for col in range(8):
				window(Vector2(x+12+col*32,10-row*39),(row+col)%5==0,col)
	# Alley continues beyond the playable mouth, between actual building footprints.
	box(Rect2(33,0,6,15),Color("#252e2c"))
	for y in range(1,15):
		line(p(Vector2(33,y)),p(Vector2(39,y)),Color("#353a31"),.35)
	box(Rect2(33,0,6,8),Color(0.025,.04,.055,.5))
	for x in [33.4,38.6]:line(p(Vector2(x,8)),p(Vector2(x,8.5)),Color("#7d7c66"),.65)
	# Uncollected rubbish belongs at service walls and beside the alley.
	for spot in [Vector2(3.8,16.7),Vector2(16,16.6),Vector2(32.4,16.3),Vector2(39.5,19.2),Vector2(57,16.4),Vector2(4,40.4),Vector2(42,40.4)]:
		var t=p(spot)
		draw_circle(t+Vector2(2,1),5,Color(.03,.055,.045,.5))
		trash(t)
	for i in range(28):
		var t=p(Vector2(rng.randf_range(32.8,39.2),rng.randf_range(12,21)))
		rect(Rect2(t,Vector2(1.7,.8)),Color("#8c8973"))
	stairs(Vector2(23,15),4.1,4.5)
	stairs(Vector2(49.6,15),3.6,3.9)
	# Ground shadows connect solid props to their footprints.
	for row in H.props():
		if row[2] in ["building","boundary"]:continue
		var b: Rect2=row[1];var q=p(b.position)
		draw_colored_polygon(PackedVector2Array([q,q+Vector2(b.size.x*8,0),q+Vector2(b.size.x*8+3,b.size.y*6+4),q+Vector2(2,b.size.y*6+4)]),Color(.015,.022,.026,.6))
func stairs(start: Vector2,w: float,depth: float) -> void:
	var q=p(start);var width=w*8
	var step_depth=(depth*6-3)/5.
	for n in range(5):
		var y=q.y+3+n*step_depth
		var inset=(4-n)*.35
		rect(Rect2(q.x+inset,y,width-inset*2,step_depth-1.2),Color("#777b73").darkened(n*.018))
		rect(Rect2(q.x+inset,y+step_depth-1.2,width-inset*2,1.2),Color("#4f574f"))
		line(Vector2(q.x+inset+.5,y+step_depth-1.3),Vector2(q.x+width-inset-.5,y+step_depth-1.3),Color("#96998b"),.65)
		if n==3:line(Vector2(q.x+4,y+.8),Vector2(q.x+6,y+1.3),Color("#5c665b"),.4)
func object_art() -> void:
	var r: Rect2=prop[1];var q=p(r.position);var sz=Vector2(r.size.x*8,r.size.y*6)
	match str(prop[2]):
		"building":
			if str(prop[0]).begins_with("south"):cutaway(q,sz)
			else: facade(q,sz,str(prop[0]))
		"boundary": pass
		"stoop_wall": stoop_wall(q,sz)
		"car":
			var end=Vector2(q.x+sz.x/2,q.y+sz.y+1)
			# Source sedan nose points right; north curb faces west, south east.
			if str(prop[0]).begins_with("north") or prop[0]=="arrival_car":
				draw_set_transform(Vector2(end.x*2,0),0,Vector2(-1,1))
			asset("burgundy_sedan",end,sz.x,Color("#afb7b6"))
			draw_set_transform(Vector2.ZERO)
		"dumpster":
			asset("dumpster_0",q+Vector2(sz.x/2,sz.y),sz.x,Color("#879486"))
			trash(q+Vector2(sz.x+3,sz.y-1))
		"utility": cabinet(q,sz)
		"crate": pallets(q,sz)
func bricks(r: Rect2,base: Color) -> void:
	rect(r,base)
	for y in range(0,int(r.size.y),3):
		for x in range(-6,int(r.size.x),7):
			var xx=maxf(0,x+(3.5 if (y/3)%2 else 0))
			var width=minf(6.3,r.size.x-xx)
			if width>0:rect(Rect2(r.position+Vector2(xx,y),Vector2(width,2.5)),base.lightened(rng.randf_range(-.1,.06)))
func window(q: Vector2,lit: bool,style: int) -> void:
	rect(Rect2(q-Vector2(2,2),Vector2(18,26)),Color("#282c2a"))
	rect(Rect2(q-Vector2(1,1),Vector2(16,24)),Color("#827866"))
	rect(Rect2(q,Vector2(14,22)),Color("#302f29") if lit else Color("#19262b"))
	if lit:
		rect(Rect2(q+Vector2(1,1),Vector2(12,20)),[Color("#bba06e"),Color("#8d8866"),Color("#d2ab73")][style%3])
		rect(Rect2(q+Vector2(2,1),Vector2(3,20)),Color("#8d7856"))
		rect(Rect2(q+Vector2(10,1),Vector2(3,20)),Color("#9a8059"))
	else:
		line(q+Vector2(2,2),q+Vector2(11,4),Color("#3f5253"),.8)
		if style%3==0:rect(Rect2(q+Vector2(1,2),Vector2(12,7)),Color("#484b43"))
	line(q+Vector2(7,0),q+Vector2(7,22),Color("#5b594e"),.8)
	line(q+Vector2(0,11),q+Vector2(14,11),Color("#716751"),1)
	rect(Rect2(q+Vector2(-2,23),Vector2(19,2)),Color("#8c8068"))
	rect(Rect2(q+Vector2(-1,25),Vector2(18,2)),Color("#252d29"))
func facade(q: Vector2,sz: Vector2,id: String) -> void:
	var seed_id=0 if id=="mercer_market" else 1 if id=="harold_apartments" else 2
	rng.seed=420+seed_id
	var base=q.y+sz.y
	var height=260.0
	bricks(Rect2(q.x,base-height,sz.x,height),BRICK[seed_id])
	# Masonry piers and cornice bands provide depth at each floor.
	for x in [q.x,q.x+sz.x-5]:
		rect(Rect2(x,base-height,5,height),BRICK[seed_id].darkened(.2))
		line(Vector2(x+1,base-height),Vector2(x+1,base),Color("#7d6851"),.55)
	for floor_id in range(6):
		var y=base-84-floor_id*39
		rect(Rect2(q.x,y+30,sz.x,2),Color("#81705a"))
		rect(Rect2(q.x,y+32,sz.x,2),Color("#242e2b"))
		for col in range(int((sz.x-12)/27)):
			window(Vector2(q.x+10+col*27,y),rng.randf()<.33,col+floor_id)
	# Drains, cabling and stains belong to the facade.
	line(Vector2(q.x+sz.x-7,base-height),Vector2(q.x+sz.x-7,base-4),Color("#242d2a"),1.8)
	line(Vector2(q.x+sz.x-6.5,base-height),Vector2(q.x+sz.x-6.5,base-4),Color("#6c6958"),.5)
	for i in range(80):
		var t=Vector2(rng.randf_range(q.x+3,q.x+sz.x-3),rng.randf_range(base-45,base-3))
		line(t,t+Vector2(0,rng.randf_range(2,9)),Color(.08,.12,.1,.2),rng.randf_range(.4,1.5))
	if seed_id==0: shopfront(q.x,base,sz.x)
	else:
		var door_x=25.*8-position.x if seed_id==1 else 51.4*8-position.x
		rect(Rect2(door_x-12,base-45,24,39),Color("#1a2424"))
		rect(Rect2(door_x-10,base-43,20,35),Color("#75674e"))
		rect(Rect2(door_x-8,base-40,16,32),Color("#2f3830"))
		rect(Rect2(door_x-6,base-37,12,15),Color("#b9a270"))
		line(Vector2(door_x,base-38),Vector2(door_x,base-9),Color("#111d20"),1)
		rect(Rect2(door_x+4,base-20,1,3),Color("#c4ab75"))
		rect(Rect2(door_x-15,base-48,30,4),Color("#8a795c"))
		line(Vector2(door_x-15,base-44),Vector2(door_x+15,base-44),Color("#212c27"),1)
		if seed_id==1:
			# Small individual metal letters mounted directly on the masonry.
			painted_text(Vector2(door_x-43,base-51),"Harold Apartments",86,9,apartment_font,Color("#c9b48c"),true)
			for x in [door_x-18,door_x+17]:
				rect(Rect2(x,base-37,2,5),Color("#dfbb78"))
				rect(Rect2(x-.5,base-38,3,1),INK)
		# A continuous stone landing reaches the bottom of the door.
		var landing_width=32.8 if seed_id==1 else 28.8
		rect(Rect2(door_x-landing_width/2,base-8,landing_width,11),Color("#777b73"))
		line(Vector2(door_x-landing_width/2,base-8),Vector2(door_x-landing_width/2,base+3),Color("#96998b"),.7)
		for x in [q.x+10,q.x+sz.x-28]:
			window(Vector2(x,base-32),seed_id==1,seed_id)
		label(Vector2(q.x+5,base-3),"MH",15,8,Color("#a59d82"))
	# Torn notices and paint tags gather at reachable street level.
	for n in range(3):
		var notice=Vector2(q.x+sz.x-14-n*4,base-15+n)
		rect(Rect2(notice,Vector2(3,5)),Color("#a39b7e"))
		line(notice+Vector2(0,2),notice+Vector2(2,2),Color("#575b4c"),.5)
	if seed_id==2:
		painted_text(Vector2(q.x+43,base-7),"M",30,33,gang_font,Color("#a13c35"))
		for drip in [Vector2(52,-9),Vector2(62,-8)]:
			line(Vector2(q.x,base)+drip,Vector2(q.x,base)+drip+Vector2(.3,3),Color("#82352e"),.65)
	# Apartment fire escape: small landings and rails, without covering the entrance.
	if seed_id==1:
		var x=q.x+sz.x-27
		for level in range(4):
			var y=base-73-level*39
			line(Vector2(x,y),Vector2(x+20,y),Color("#121f22"),2)
			line(Vector2(x,y-8),Vector2(x+20,y-8),Color("#88816a"),.65)
			for bar in range(6):line(Vector2(x+bar*4,y-8),Vector2(x+bar*4,y),Color("#26332f"),.8)
			# Retracted lowest ladder clears the apartment name board.
			line(Vector2(x+3,y),Vector2(x+7,y+8) if level==0 else Vector2(x+17,y+30),Color("#111e22"),1.4)
			for n in range(2 if level==0 else 8):line(Vector2(x+3+n*1.7,y+n*3.6),Vector2(x+7+n*1.7,y+n*3.6),Color("#7b7764"),.65)
func label(q: Vector2,words: String,width: float,size: int,c: Color) -> void:
	draw_string(ThemeDB.fallback_font,q,words,HORIZONTAL_ALIGNMENT_CENTER,width,size,c)
func shopfront(x: float,y: float,w: float) -> void:
	rect(Rect2(x+4,y-47,w-8,44),Color("#353b32"))
	rect(Rect2(x+4,y-50,w-8,13),Color("#c2b48f"))
	line(Vector2(x+5,y-47),Vector2(x+w-5,y-47),Color("#9e9f7b"),.7)
	painted_text(Vector2(x+7,y-40),H.STORE,w-14,11,shop_font,Color("#453a2f"))
	var dx=x+w*.67
	for a in [[x+8,dx-x-13],[dx+20,x+w-dx-26]]:
		var wx: float=a[0];var ww: float=a[1]
		rect(Rect2(wx,y-34,ww,25),Color("#b3a372"))
		rect(Rect2(wx+1,y-33,ww-2,23),Color("#555f44"))
		for shelf in range(3):
			for n in range(int(ww/4)):
				rect(Rect2(wx+2+n*4,y-30+shelf*7,2.5,4),[Color("#a88f60"),Color("#718476"),Color("#ae9c7b")][(n+shelf)%3])
			line(Vector2(wx+1,y-25+shelf*7),Vector2(wx+ww-1,y-25+shelf*7),Color("#292f29"),.8)
		for bx in range(0,int(ww),8):line(Vector2(wx+bx,y-34),Vector2(wx+bx,y-9),Color("#313b30"),.6)
	rect(Rect2(dx,y-34,16,31),Color("#a29777"))
	rect(Rect2(dx+2,y-32,12,27),Color("#31473d"))
	label(Vector2(dx+1,y-22),"OPEN",14,4,Color("#e4af72"))
	rect(Rect2(dx+11,y-17,1,4),Color("#c2b48c"))
	label(Vector2(x+7,y-4),"GROCERIES  •  COLD DRINKS",w*.6,4,Color("#a69d82"))
	# Worn roll-up shutter housing and threshold.
	rect(Rect2(x+5,y-36,w-10,2),Color("#777665"))
	line(Vector2(x+4,y-2),Vector2(x+w-4,y-2),Color("#8a846d"),1.3)
func stoop_wall(q: Vector2,sz: Vector2) -> void:
	# Each shallow masonry section has its own depth anchor.
	var h=3.0
	bricks(Rect2(q-Vector2(0,h),sz+Vector2(0,h)),Color("#5b5045"))
	rect(Rect2(q-Vector2(.4,h+.5),Vector2(sz.x+.8,1.2)),Color("#969080"))
func cutaway(q: Vector2,sz: Vector2) -> void:
	# Fixed-camera foreground convention: low wall caps and dark building mass.
	rect(Rect2(q,sz),Color("#172124"))
	bricks(Rect2(q-Vector2(0,3),Vector2(sz.x,5)),Color("#605044"))
	rect(Rect2(q-Vector2(0,4),Vector2(sz.x,2)),Color("#95866c"))
	for x in [0.,sz.x-3]:
		bricks(Rect2(q+Vector2(x,0),Vector2(3,sz.y)),Color("#4a423a"))
	# Dark footprint remains visually solid; not an invitation into an interior.
func trash(q: Vector2) -> void:
	for i in range(3):
		var t=q+Vector2(i*3.7,-(i%2)*1.1)
		var w=3.5+(i%2)*.6
		draw_set_transform(t,0,Vector2(1,.42))
		draw_circle(Vector2(0,1),w+1,Color(0.025,.035,.03,.45))
		draw_set_transform(Vector2.ZERO)
		draw_colored_polygon(PackedVector2Array([t+Vector2(-w,0),t+Vector2(-w-.4,-2),t+Vector2(-w+.3,-4),t+Vector2(-1.1,-5.6),t+Vector2(.4,-6),t+Vector2(w,-4.4),t+Vector2(w+.5,-1.7),t+Vector2(w-.7,.5),t+Vector2(-1,.7)]),Color("#182324"))
		draw_colored_polygon(PackedVector2Array([t+Vector2(-w+.7,-1),t+Vector2(-w+1,-3.8),t+Vector2(-1,-5),t+Vector2(-1.8,-2)]),Color("#354341"))
		line(t+Vector2(.2,-5.5),t+Vector2(1.5,-2),Color("#45524d"),.5)
		line(t+Vector2(2,-1),t+Vector2(w-.3,-2.4),Color("#2e3d3a"),.55)
		draw_colored_polygon(PackedVector2Array([t+Vector2(-.8,-5.4),t+Vector2(-1.4,-7),t+Vector2(.1,-6.6),t+Vector2(1.3,-7.2),t+Vector2(1,-5.6)]),Color("#384640"))
		line(t+Vector2(-1,-5.6),t+Vector2(1,-5.7),Color("#60645a"),.5)
func _draw() -> void:
	if not prop.is_empty() and prop[2]=="lamp":
		# Full streetlight pole; the fixture and its base keep their previous footprint.
		draw_set_transform(Vector2.ZERO,0,Vector2(1.15,2.1))
		asset("lamp_0",Vector2(2,0),10)
		draw_set_transform(Vector2.ZERO)
	elif not prop.is_empty() and prop[2]=="street_sign":
		line(Vector2(0,0),Vector2(0,-29),Color("#a0a397"),1.1)
		rect(Rect2(-22,-29,44,8),Color("#1e5844"))
		draw_rect(Rect2(-22,-29,44,8),Color("#b7c4ad"),false,.65)
		label(Vector2(-21,-23),H.STREET,42,6,Color("#edf0d7"))
	else:super._draw()

func painted_text(q: Vector2,words: String,width: float,height: float,font: Font,c: Color,raised: bool=false) -> void:
	var font_size=48
	var natural=font.get_string_size(words,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size)
	var scale_factor=minf(width/maxf(1,natural.x),height/36.)
	var pos=q+Vector2((width-natural.x*scale_factor)/2.,0)
	draw_set_transform(pos,0,Vector2.ONE*scale_factor)
	if raised:draw_string(font,Vector2(1.8,1.8),words,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,Color("#252d29"))
	draw_string(font,Vector2.ZERO,words,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,c)
	draw_set_transform(Vector2.ZERO)
