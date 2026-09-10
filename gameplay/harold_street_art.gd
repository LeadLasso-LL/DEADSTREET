extends "res://gameplay/dusk_street_art.gd"
# Reusable brick frontage, stoop, parking and cutaway vocabulary.
const H = preload("res://battle/geometry/harold_street_catalog.gd")
var apartment_font: SystemFont
var shop_font: SystemFont
var bake_source := false
var frontage_texture: Texture2D
var frontage_bounds: Rect2
static var sedan_source_image: Image
var door_colors: Dictionary = {}
const BRICK = [Color("#514039"),Color("#654b3f"),Color("#473e38")]
func _ready() -> void:
	super._ready()
	apartment_font=SystemFont.new()
	apartment_font.font_names=PackedStringArray(["Arial","Liberation Sans"])
	apartment_font.font_weight=700
	shop_font=SystemFont.new()
	shop_font.font_names=PackedStringArray(["Arial","Liberation Sans"])
	shop_font.font_weight=700

	if not prop.is_empty() and prop[2]=="car":
		var colors=[Color("#777367"),Color("#75443e"),Color("#536258"),Color("#989786"),Color("#424d5e"),Color("#514e46")]
		var paint=colors[absi(str(prop[0]).hash())%colors.size()]
		if prop[0]=="arrival_car":paint=colors[2]
		if prop[0]=="arrival_car":prepare_door_colors(paint)
		material.set_shader_parameter("paint",Vector3(paint.r,paint.g,paint.b))
	if not bake_source and not prop.is_empty() and prop[0]=="east_apartments":
		var mark=preload("res://gameplay/weathered_graffiti.gd").new()
		var bounds: Rect2=prop[1]
		mark.position=p(bounds.position)+Vector2(43,bounds.size.y*6-7)
		add_child(mark)
	if prop.is_empty() and not bake_source:
		var im=Image.create(128,128,false,Image.FORMAT_RGBA8)
		for y in range(128):
			for x in range(128):
				var f=maxf(0.,1.-Vector2(x-64,y-64).length()/64.)
				im.set_pixel(x,y,Color(1,1,1,f*f*.65))
		var tex=ImageTexture.create_from_image(im)
		for spot in H.STREET_LIGHTS+[[Vector2(9,16),.6],[Vector2(25,16),.45]]:
			var light=PointLight2D.new()
			light.texture=tex;light.position=Vector2(spot[0].x*8,spot[0].y*6)
			light.color=Color("#ffd4a0");light.energy=spot[1];light.texture_scale=1.0
			add_child(light)

	if not bake_source:
		var key="ground" if prop.is_empty() else str(prop[0])
		var cache_path="res://assets/art/harold_frontage/"+key+".png"
		if ResourceLoader.exists(cache_path):
			frontage_texture=load(cache_path)
			frontage_bounds=cache_bounds(key,Rect2() if prop.is_empty() else prop[1])

static func cache_bounds(key: String,bounds: Rect2=Rect2()) -> Rect2:
	if key=="ground":return Rect2(-320,-280,1152,568)
	if "_bin_" in key:return Rect2(bounds.position.x*8-3,bounds.end.y*6-18,bounds.size.x*8+7,24)
	# Alley return and ironwork extend beyond the front elevation, including its top.
	var extra=72 if key=="harold_apartments" else 0
	var side=24 if key=="harold_apartments" else 0
	return Rect2(bounds.position.x*8-2,bounds.end.y*6-264-extra,bounds.size.x*8+4+side,270+extra)

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
	for spot in [Vector2(3.8,16.7),Vector2(16,16.6),Vector2(32.4,16.3),Vector2(39.5,19.2),Vector2(57,16.4),Vector2(4,40.4),Vector2(42,40.4),Vector2(10.9,37.8),Vector2(40.6,37.8)]:
		var t=p(spot)
		draw_circle(t+Vector2(2,1),5,Color(.03,.055,.045,.5))
		trash(t)
	for i in range(28):
		var t=p(Vector2(rng.randf_range(32.8,39.2),rng.randf_range(12,21)))
		rect(Rect2(t,Vector2(1.7,.8)),Color("#8c8973"))
	for row in H.props():
		if row[2]=="trash_can_fallen":spilled_rubbish(p(row[1].position),Vector2(row[1].size.x*8,row[1].size.y*6))
	stairs(Vector2(23,15),4.1,4.5)
	stairs(Vector2(49.6,15),3.6,3.9)
	# Ground shadows connect solid props to their footprints.
	for row in H.props():
		if row[2] in ["building","boundary","trash_can","trash_can_fallen"]:continue
		var b: Rect2=row[1];var q=p(b.position)
		street_prop_shadow(q,Vector2(b.size.x*8,b.size.y*6))
func stairs(start: Vector2,w: float,depth: float) -> void:
	var q=p(start);var width=w*8
	var run=depth*6/5.
	# Broad horizontal treads, vertical risers and worn nosings share one landing.
	for n in range(5):
		var y=q.y-1+n*run
		var tread=Rect2(q.x+.35,y,width-.7,run-1.65)
		rect(tread,Color("#74776a").darkened(n*.026))
		grain(tread,22,Color(.1,.13,.11,.16),Color(.75,.75,.65,.13))
		# Damp/dust-dark corners leave the walked-on centre lighter.
		rect(Rect2(tread.position,Vector2(2.2,tread.size.y)),Color(.12,.16,.13,.19))
		rect(Rect2(tread.position+Vector2(width-3.6,0),Vector2(2.5,tread.size.y)),Color(.1,.14,.12,.24))
		var edge=y+run-1.65
		rect(Rect2(q.x+.3,edge,width-.6,1.65),Color("#454d45"))
		line(Vector2(q.x+1,edge),Vector2(q.x+width-1,edge),Color("#999a87"),.62)
		line(Vector2(q.x+1,edge+1.45),Vector2(q.x+width-1,edge+1.45),Color("#303b35"),.45)
		for chip in range(4):
			var cx=q.x+rng.randf_range(2,width-2)
			line(Vector2(cx,edge),Vector2(cx+rng.randf_range(.4,1.3),edge+.25),Color("#5c6459"),.5)
		if n in [1,4]:
			var crack=Vector2(q.x+width*(.28 if n==1 else .74),y+.3)
			line(crack,crack+Vector2(1,1),Color("#464f47"),.35)
			line(crack+Vector2(1,1),crack+Vector2(.7,2.1),Color("#464f47"),.35)
func object_art() -> void:
	var r: Rect2=prop[1];var q=p(r.position);var sz=Vector2(r.size.x*8,r.size.y*6)
	match str(prop[2]):
		"building":
			if str(prop[0]).begins_with("south"):cutaway(q,sz)
			else: facade(q,sz,str(prop[0]))
		"boundary": pass
		"stoop_wall": stoop_wall(q,sz)
		"car": street_car(q,sz)
		"trash_can": trash_can(q,sz)
		"trash_can_fallen": fallen_can(q,sz)
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
	# A recessed opening: masonry shadow, inner jamb, glazing, sash and projecting sill.
	rect(Rect2(q+Vector2(-1.6,-2.1),Vector2(18.2,27.7)),Color(.035,.055,.055,.65))
	rect(Rect2(q+Vector2(-1,-1.4),Vector2(16.6,25)),Color("#544f43"))
	rect(Rect2(q,Vector2(14.7,23)),Color("#121e23"))
	rect(Rect2(q+Vector2(.6,.6),Vector2(1.1,21)),Color("#333b35"))
	rect(Rect2(q+Vector2(13.2,.7),Vector2(.8,21.5)),Color("#77715d"))
	var glass=Rect2(q+Vector2(1.8,1.2),Vector2(11.1,20.7))
	for row in range(21):
		var t=float(row)/21.
		var c=Color("#696047").lerp(Color("#b29a65"),t) if lit else Color("#111f27").lerp(Color("#304246"),t*.6)
		rect(Rect2(glass.position+Vector2(0,row),Vector2(glass.size.x,1)),c)
	if lit:
		# Uneven hanging curtains with shaded folds and a dark room beyond.
		for side in [0,1]:
			var cx=q.x+2 if side==0 else q.x+10
			var points=PackedVector2Array([Vector2(cx,q.y+1),Vector2(cx+2.8,q.y+1),Vector2(cx+2.2,q.y+19.3),Vector2(cx+.7,q.y+20),Vector2(cx-.3,q.y+18.5)])
			draw_colored_polygon(points,Color("#8e805c") if side==0 else Color("#9a895f"))
			line(Vector2(cx+.8,q.y+2),Vector2(cx+.5,q.y+18),Color("#b1a078"),.45)
			line(Vector2(cx+1.7,q.y+2),Vector2(cx+1.4,q.y+18.5),Color("#695f49"),.5)
		if style%3==1:rect(Rect2(q+Vector2(5.3,15.6),Vector2(3.8,5)),Color("#4b4c3c"))
	else:
		if style%3==0:
			rect(Rect2(q+Vector2(1.8,1.2),Vector2(11.1,6.2)),Color("#454b42"))
			for by in range(2,7):line(q+Vector2(2,by),q+Vector2(12.5,by),Color("#626455"),.28)
		draw_colored_polygon(PackedVector2Array([q+Vector2(2,9),q+Vector2(12.6,12.6),q+Vector2(12.6,14.2),q+Vector2(2,10.2)]),Color(.35,.48,.48,.16))
		line(q+Vector2(3,9.5),q+Vector2(3,19),Color(.55,.61,.57,.16),.4)
	# Narrow, worn timber sash: directional highlights, never a uniform bright outline.
	rect(Rect2(q+Vector2(1.4,10.5),Vector2(11.7,1.1)),Color("#756e59"))
	line(q+Vector2(1.5,11.7),q+Vector2(13.3,11.7),Color("#152626"),.65)
	line(q+Vector2(7.2,1),q+Vector2(7.2,21.8),Color("#4d5146"),.6)
	line(q+Vector2(7.7,1),q+Vector2(7.7,21.8),Color("#7d7760"),.35)
	rect(Rect2(q+Vector2(-1.8,-3),Vector2(18.1,1.5)),Color("#776b57"))
	grain(Rect2(q+Vector2(-1.8,-3),Vector2(18.1,1.5)),10,Color(.1,.13,.1,.25),Color(.7,.66,.53,.13))
	rect(Rect2(q+Vector2(-1.6,23),Vector2(18,1.7)),Color("#8b7e64"))
	line(q+Vector2(-1.8,22.9),q+Vector2(16.2,22.9),Color("#a4987b"),.5)
	rect(Rect2(q+Vector2(-1,24.7),Vector2(17.7,1.4)),Color("#534e40"))
	line(q+Vector2(.5,26.7),q+Vector2(16.7,26.7),Color(.04,.065,.06,.5),1)
	for i in range(6):
		var sx=rng.randf_range(0,15)
		line(q+Vector2(sx,23.3),q+Vector2(sx+.7,23.6),Color("#605e4d"),.4)
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
		apartment_entry(door_x,base,seed_id==1)
		for x in [q.x+(5 if seed_id==1 else 10),q.x+sz.x-28]:
			window(Vector2(x,base-32),seed_id==1,seed_id)
	# Torn notices and paint tags gather at reachable street level.
	for n in range(3):
		var notice=Vector2(q.x+sz.x-14-n*4,base-15+n)
		rect(Rect2(notice,Vector2(3,5)),Color("#a39b7e"))
		line(notice+Vector2(0,2),notice+Vector2(2,2),Color("#575b4c"),.5)
	# Fire escape belongs on the alley return, never across the street facade.
	if seed_id==1: alley_fire_escape(Vector2(q.x+sz.x,base))
func label(q: Vector2,words: String,width: float,size: int,c: Color) -> void:
	draw_string(ThemeDB.fallback_font,q,words,HORIZONTAL_ALIGNMENT_CENTER,width,size,c)
func shopfront(x: float,y: float,w: float) -> void:
	rect(Rect2(x+3.6,y-47,w-7.2,44.4),Color("#1a2728"))
	rect(Rect2(x+5,y-45.5,w-10,42),Color("#3f493d"))
	# A shallow, weathered enamel fascia bolted to a real frame.
	var board=Rect2(x+10,y-48.5,w-20,9.3)
	rect(Rect2(board.position+Vector2(1,1.7),board.size),Color(.035,.05,.045,.7))
	rect(board,Color("#62664e"))
	rect(Rect2(board.position+Vector2(.7,.6),board.size-Vector2(1.4,1.2)),Color("#304a3e"))
	line(board.position,board.position+Vector2(board.size.x,0),Color("#898871"),.65)
	line(board.position+Vector2(0,board.size.y),board.end,Color("#182b28"),1)
	painted_text(Vector2(x+w*.18,y-42.5),H.STORE.to_upper(),w*.64,4.4,shop_font,Color("#c7ba8c"))
	grain(board,80,Color(.045,.08,.06,.18),Color(.77,.75,.6,.085))
	for bx in [board.position.x+1.5,board.end.x-1.5]:
		rect(Rect2(bx,board.position.y+1.6,.6,.6),Color("#a4a184"))
		line(Vector2(bx,board.position.y+3),Vector2(bx-.3,board.position.y+5.4),Color(.29,.2,.13,.45),.5)
	var dx=x+w*.67
	for a in [[x+8,dx-x-13],[dx+20,x+w-dx-26]]:
		var wx: float=a[0];var ww: float=a[1]
		rect(Rect2(wx-.9,y-35.2,ww+1.8,27.8),Color("#1b2928"))
		rect(Rect2(wx,y-34,ww,25),Color("#68705b"))
		var glass=Rect2(wx+1.2,y-32.8,ww-2.4,22.7)
		rect(glass,Color("#424e3d"))
		for shelf in range(3):
			var sy=y-29.5+shelf*6.8
			rect(Rect2(wx+1.2,sy-2,ww-2.4,2),Color(.045,.09,.07,.3))
			for n in range(int((ww-3)/3.5)):
				var px=wx+2+n*3.5
				var height=rng.randf_range(2.4,4.6)
				var color=[Color("#8b7955"),Color("#707d61"),Color("#9d8f68"),Color("#775446"),Color("#526966")][rng.randi_range(0,4)]
				rect(Rect2(px,sy+3.7-height,rng.randf_range(1.5,2.6),height),color)
				if n%3==0:rect(Rect2(px+.2,sy+2.1,1.3,.6),Color("#b0a37d"))
			rect(Rect2(wx+1,sy+3.8,ww-2,.8),Color("#857a5a"))
			rect(Rect2(wx+1,sy+4.6,ww-2,.8),Color("#1b302b"))
		draw_colored_polygon(PackedVector2Array([Vector2(wx+1.3,y-29),Vector2(wx+ww-1.3,y-21),Vector2(wx+ww-1.3,y-18),Vector2(wx+1.3,y-26)]),Color(.41,.52,.49,.15))
		rect(Rect2(wx+1.2,y-13,ww-2.4,3.8),Color(.08,.13,.1,.32))
		for bx in range(1,int(ww),9):
			line(Vector2(wx+bx,y-33),Vector2(wx+bx,y-9),Color("#1b302a"),.65)
			line(Vector2(wx+bx+.5,y-33),Vector2(wx+bx+.5,y-9),Color("#73745a"),.3)
		line(Vector2(wx,y-34),Vector2(wx+ww,y-34),Color("#989174"),.5)
		rect(Rect2(wx-.7,y-8.8,ww+1.4,1.1),Color("#88806a"))
		rect(Rect2(wx,y-7.7,ww+1.4,1.4),Color("#24342e"))
		grain(Rect2(wx,y-34,ww,26),45,Color(.05,.1,.09,.16),Color(.8,.77,.62,.09))
	# Recessed aluminum shop door with glass reflections, kickplate and a small hanging OPEN sign.
	rect(Rect2(dx-.8,y-35,17.6,32.7),Color("#142627"))
	rect(Rect2(dx,y-34,16,30.5),Color("#797a63"))
	rect(Rect2(dx+1.3,y-32.7,13.2,28),Color("#293e35"))
	rect(Rect2(dx+2,y-31.7,11.7,20),Color("#45564a"))
	draw_colored_polygon(PackedVector2Array([Vector2(dx+2,y-29),Vector2(dx+13.7,y-24),Vector2(dx+13.7,y-22),Vector2(dx+2,y-27)]),Color(.5,.6,.53,.2))
	rect(Rect2(dx+3.2,y-25.7,7.7,3.4),Color("#273b33"))
	painted_text(Vector2(dx+3.8,y-23.2),"OPEN",6.5,1.7,shop_font,Color("#be9562"))
	line(Vector2(dx+11.8,y-19),Vector2(dx+11.8,y-15.8),Color("#c1b99a"),.8)
	line(Vector2(dx+12.3,y-19),Vector2(dx+12.3,y-15.8),Color("#182d29"),.4)
	rect(Rect2(dx+1.8,y-9.7,12.4,4.6),Color("#536259"))
	grain(Rect2(dx+1.8,y-9.7,12.4,4.6),20,Color(.05,.1,.08,.35),Color(.7,.71,.6,.18))
	painted_text(Vector2(x+10,y-4.2),"GROCERIES   /   COLD DRINKS",w*.5,1.8,shop_font,Color("#938e70"))
	line(Vector2(x+4,y-2.8),Vector2(x+w-4,y-2.8),Color("#77765f"),.75)
func stoop_wall(q: Vector2,sz: Vector2) -> void:
	# A constant-height solid wall from facade to final tread; never a stepped railing.
	var h=24.
	var top=Rect2(q-Vector2(0,h),sz)
	var face=Rect2(q+Vector2(0,sz.y-h),Vector2(sz.x,h))
	bricks(face,Color("#605348"))
	# Recessed side arris and the darker toe anchor the end face to the pavement.
	rect(Rect2(face.position+Vector2(sz.x-1.15,0),Vector2(1.15,h)),Color("#343e37"))
	rect(Rect2(q+Vector2(0,sz.y-2.4),Vector2(sz.x,2.4)),Color("#394238"))
	grain(face,55,Color(.065,.09,.065,.24),Color(.67,.6,.47,.12))
	rect(top,Color("#898776"))
	# Long coping stones follow the same horizontal plane along the whole run.
	for joint in range(0,int(sz.y),7):
		line(top.position+Vector2(0,joint),top.position+Vector2(sz.x,joint),Color("#555e52"),.45)
		line(top.position+Vector2(.5,joint+.7),top.position+Vector2(sz.x-.6,joint+.7),Color("#a3a08a"),.3)
	grain(top,65,Color(.12,.17,.12,.22),Color(.83,.81,.68,.12))
	line(top.position+Vector2(.25,0),top.position+Vector2(.25,sz.y),Color("#b1ac93"),.65)
	line(top.position+Vector2(sz.x-.35,0),top.end-Vector2(.35,0),Color("#454f43"),.8)
	rect(Rect2(face.position-Vector2(.3,.5),Vector2(sz.x+.6,1.7)),Color("#8d8a74"))
	line(face.position+Vector2(.1,-.45),face.position+Vector2(sz.x-.1,-.45),Color("#b2aa8e"),.65)
	line(face.position+Vector2(.2,1.4),face.position+Vector2(sz.x,1.4),Color("#333e35"),.65)
	for i in range(8):
		var t=face.position+Vector2(rng.randf_range(.5,sz.x-1.5),rng.randf_range(2,h-3))
		line(t,t+Vector2(.3,rng.randf_range(.5,2.4)),Color(.075,.12,.085,.32),.5)
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

	if frontage_texture!=null:
		if prop.is_empty():rect(Rect2(-1000,-1000,2500,2000),Color("#161c23"))
		draw_texture_rect(frontage_texture,Rect2(frontage_bounds.position-position,frontage_bounds.size),false)
		return
	if not prop.is_empty() and prop[2]=="lamp":
		# Full streetlight pole; the fixture and its base keep their previous footprint.
		draw_set_transform(Vector2.ZERO,0,Vector2(1.15,2.1))
		asset("lamp_0",Vector2(2,0),10)
		draw_set_transform(Vector2.ZERO)
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

func grain(r: Rect2,count: int,dark: Color,light: Color) -> void:
	for i in range(count):
		var t=r.position+Vector2(rng.randf_range(0,r.size.x-.5),rng.randf_range(0,r.size.y-.35))
		rect(Rect2(t,Vector2(rng.randf_range(.25,.8),.3)),dark if i%3 else light)

func apartment_entry(door_x: float,base: float,primary: bool) -> void:
	var t=Vector2(door_x-12,base-45)
	rect(Rect2(t+Vector2(.8,.5),Vector2(24.7,39.5)),Color(.025,.04,.04,.8))
	rect(Rect2(t,Vector2(23.5,38)),Color("#685e4b"))
	rect(Rect2(t+Vector2(1.1,1),Vector2(21,36.5)),Color("#182929"))
	rect(Rect2(t+Vector2(2,1.7),Vector2(1.5,34.5)),Color("#3e4337"))
	rect(Rect2(t+Vector2(21,1.7),Vector2(1,34.5)),Color("#867a5f"))
	var door=Rect2(t+Vector2(4,3),Vector2(15.4,34))
	rect(door,Color("#354338"))
	line(door.position,door.position+Vector2(0,33),Color("#646854"),.55)
	line(door.position+Vector2(15,0),door.end-Vector2(.4,0),Color("#0f2525"),.75)
	# Glazed upper door has a dark transom and warm, shaded hall behind it.
	rect(Rect2(t+Vector2(5.2,4.5),Vector2(12.8,1.8)),Color("#15292b"))
	for i in range(14):
		rect(Rect2(t+Vector2(5.3,7+i),Vector2(12.5,1)),Color("#5c634b").lerp(Color("#ae9867"),float(i)/18.))
	rect(Rect2(t+Vector2(10.9,7),Vector2(.8,14.2)),Color("#334236"))
	line(t+Vector2(5.2,21.5),t+Vector2(18,21.5),Color("#8a8164"),.55)
	rect(Rect2(t+Vector2(5.2,22),Vector2(12.8,1)),Color("#1e322e"))
	draw_colored_polygon(PackedVector2Array([t+Vector2(5.4,8),t+Vector2(10.8,10),t+Vector2(10.8,11.3),t+Vector2(5.4,9.2)]),Color(.61,.66,.52,.17))
	# Lower raised panels and a worn kickplate give the door thickness.
	for px in [5.5,12.]:
		rect(Rect2(t+Vector2(px,25),Vector2(5,7.6)),Color("#1c332c"))
		rect(Rect2(t+Vector2(px+.6,25.5),Vector2(3.9,6.5)),Color("#3c4c3c"))
		line(t+Vector2(px+.6,25.5),t+Vector2(px+4.5,25.5),Color("#62705a"),.35)
	rect(Rect2(t+Vector2(5.2,34),Vector2(12.8,1.4)),Color("#747662"))
	rect(Rect2(t+Vector2(16,23.6),Vector2(1.5,3.8)),Color("#27352c"))
	line(t+Vector2(16.4,24),t+Vector2(16.4,26.7),Color("#b3a77d"),.65)
	grain(door,40,Color(.035,.09,.06,.22),Color(.65,.66,.5,.12))
	var lintel=Rect2(door_x-14,base-48,28,2.8)
	rect(lintel,Color("#82725a"))
	grain(lintel,30,Color(.17,.14,.1,.22),Color(.74,.67,.53,.13))
	line(Vector2(door_x-14,base-48),Vector2(door_x+14,base-48),Color("#a09173"),.5)
	line(Vector2(door_x-13.5,base-44.8),Vector2(door_x+14.5,base-44.8),Color("#192b29"),1)
	if primary:
		# Keep the inset green/brass plaque; stack the name so its letters survive battle zoom.
		var plaque=Rect2(door_x-40,base-40,26,15)
		rect(Rect2(plaque.position+Vector2(.6,.8),plaque.size),Color(.045,.045,.035,.65))
		rect(plaque,Color("#8b7e62"))
		rect(Rect2(plaque.position+Vector2(.6,.6),plaque.size-Vector2(1.2,1.2)),Color("#303e34"))
		line(plaque.position+Vector2(.8,.6),plaque.position+Vector2(25.2,.6),Color("#aea082"),.35)
		painted_text(plaque.position+Vector2(1.5,5),"HAROLD",23,4.2,apartment_font,Color("#e3d2a5"))
		painted_text(plaque.position+Vector2(1.5,9.4),"Apartments",23,3.7,apartment_font,Color("#e3d2a5"))
		line(plaque.position+Vector2(3,10.5),plaque.position+Vector2(23,10.5),Color("#827b60"),.3)
		painted_text(plaque.position+Vector2(1.4,13.5),"1455 Mercer Ave.",23.2,2.25,shop_font,Color("#c8bfa1"))
		for px in [plaque.position.x+.9,plaque.end.x-1.2]:
			rect(Rect2(px,plaque.position.y+1,.35,.35),Color("#c2b28e"))
		for lx in [door_x-17.5,door_x+16.5]:
			rect(Rect2(lx,base-52,2.6,5.8),Color("#222e28"))
			rect(Rect2(lx+.5,base-51.4,1.5,4.1),Color("#c8a66d"))
			line(Vector2(lx+.3,base-49),Vector2(lx+2,base-49),Color("#65573e"),.4)
			rect(Rect2(lx-.3,base-52.6,3.1,1),Color("#4b4e3e"))
	var landing_width=32.8 if primary else 28.8
	var landing=Rect2(door_x-landing_width/2,base-8,landing_width,7)
	rect(landing,Color("#727667"))
	grain(landing,65,Color(.09,.14,.1,.22),Color(.72,.73,.6,.13))
	line(landing.position+Vector2(0,6.6),landing.end,Color("#959582"),.6)
	line(landing.position+Vector2(4,0),landing.position+Vector2(4,6),Color("#4f5a4d"),.4)

func pallets(q: Vector2,sz: Vector2) -> void:
	# Rough timber shipping crate on runners: lid, shaded end grain and a recessed front.
	var h=12.
	var top=q-Vector2(0,h)
	var side=2.6
	var fw=sz.x-side
	rect(Rect2(q+Vector2(.8,sz.y-.5),Vector2(sz.x,2.5)),Color("#26322b"))
	for px in [2.,sz.x-5]:
		rect(Rect2(q+Vector2(px,sz.y-.2),Vector2(2.7,2)),Color("#413f2e"))
	draw_colored_polygon(PackedVector2Array([top+Vector2(.3,0),top+Vector2(fw,-.3),top+Vector2(sz.x,sz.y-.4),top+Vector2(fw,sz.y),top+Vector2(0,sz.y-.3)]),Color("#817557"))
	var face=Rect2(top+Vector2(0,sz.y),Vector2(fw,h-1))
	rect(face,Color("#635b43"))
	draw_colored_polygon(PackedVector2Array([top+Vector2(fw,0),top+Vector2(sz.x,-.2),q+sz-Vector2(0,1),q+Vector2(fw,sz.y-1)]),Color("#3d4536"))
	for board in range(4):
		var px=face.position.x+board*fw/4.
		var tone=[Color("#6b644a"),Color("#7b6f50"),Color("#625f47"),Color("#74694c")][board]
		rect(Rect2(px+.3,face.position.y+.3,fw/4.-.5,h-1.6),tone)
		for i in range(6):
			var t=Vector2(px+rng.randf_range(.5,fw/4.-.5),face.position.y+rng.randf_range(.8,8))
			line(t,t+Vector2(.15,rng.randf_range(.6,2.6)),Color(.18,.23,.15,.34),.35)
		line(Vector2(px+.3,top.y+.4),Vector2(px+.3,top.y+sz.y-.5),Color("#494f3c"),.45)
	for by in [1.2,h-3.1]:
		rect(Rect2(face.position+Vector2(.1,by),Vector2(fw-.2,1.7)),Color("#8b7c59"))
		line(face.position+Vector2(.2,by+1.7),face.position+Vector2(fw,by+1.7),Color("#3d4633"),.5)
		for px in [1.5,fw-2]:
			rect(Rect2(face.position+Vector2(px,by+.6),Vector2(.5,.5)),Color("#2d382b"))
	# A dark steel binding follows both visible planes; scuffs and splits break the edges.
	rect(Rect2(top+Vector2(fw*.7,.3),Vector2(1.1,sz.y-.2)),Color("#404c40"))
	rect(Rect2(face.position+Vector2(fw*.7,0),Vector2(1.1,h-1)),Color("#354237"))
	grain(Rect2(top+Vector2(.5,.5),Vector2(fw-1,sz.y-1)),60,Color(.14,.19,.12,.28),Color(.78,.72,.52,.16))
	grain(face,70,Color(.13,.2,.12,.25),Color(.77,.7,.51,.13))
	line(face.position+Vector2(fw*.37,3),face.position+Vector2(fw*.34,6.6),Color("#424c35"),.45)
	rect(Rect2(face.position+Vector2(2.4,3.2),Vector2(3.5,3)),Color("#a29977"))
	for i in range(3):line(face.position+Vector2(2.8,4+i*.55),face.position+Vector2(5.2,4+i*.55),Color("#60644a"),.3)

func cabinet(q: Vector2,sz: Vector2) -> void:
	var t=q-Vector2(0,12)
	rect(Rect2(t,sz+Vector2(0,12)),Color("#25362f"))
	rect(Rect2(t+Vector2(.6,.7),Vector2(sz.x-2.2,sz.y+10.5)),Color("#536156"))
	rect(Rect2(t+Vector2(sz.x-1.7,.5),Vector2(1.7,sz.y+11.5)),Color("#35493f"))
	rect(Rect2(t+Vector2(.5,0),Vector2(sz.x-1,1.3)),Color("#8c9178"))
	line(t+Vector2(1,2),t+Vector2(sz.x-2,2),Color("#1c342c"),.6)
	for by in range(5,13,2):
		line(t+Vector2(2,by),t+Vector2(sz.x-3,by),Color("#233d33"),.6)
		line(t+Vector2(2,by+.6),t+Vector2(sz.x-3,by+.6),Color("#77826c"),.3)
	line(t+Vector2(sz.x*.52,3),t+Vector2(sz.x*.52,sz.y+9),Color("#273e33"),.7)
	rect(Rect2(t+Vector2(2.5,14.7),Vector2(3,3.6)),Color("#958966"))
	line(t+Vector2(4,15.3),t+Vector2(3.4,16.6),Color("#304135"),.45)
	line(t+Vector2(3.4,16.6),t+Vector2(4.4,16.4),Color("#304135"),.45)
	line(t+Vector2(4.4,16.4),t+Vector2(3.8,17.6),Color("#304135"),.45)
	line(t+Vector2(sz.x-3.4,16),t+Vector2(sz.x-3.4,18.3),Color("#a0a48a"),.6)
	rect(Rect2(q+Vector2(.5,sz.y-2),Vector2(sz.x-1,2)),Color("#2d4035"))
	grain(Rect2(t+Vector2(1,2),Vector2(sz.x-3,sz.y+8)),55,Color(.07,.14,.09,.24),Color(.69,.73,.58,.12))

func alley_point(base: Vector2,depth: float,outward: float,height: float) -> Vector2:
	# Foreshortened return plane: receding masonry and all ironwork share this basis.
	return base+Vector2(depth*.18+outward,-depth-height)

func alley_fire_escape(base: Vector2) -> void:
	var iron=Color("#192727")
	var edge=Color("#768175")
	# Narrow shaded return, attached to the building corner. The playable mouth stays open.
	draw_colored_polygon(PackedVector2Array([alley_point(base,0,0,0),alley_point(base,68,0,0),alley_point(base,68,0,260),alley_point(base,0,0,260)]),Color("#342f2a"))
	for h in range(0,260,3):
		for d in range(0,68,8):
			var start=float(d)+ (3. if (h/3)%2 else 0.)
			var end=minf(start+7.1,68.)
			if start>=68:continue
			var c=Color("#494033").lightened(rng.randf_range(-.09,.035))
			draw_colored_polygon(PackedVector2Array([alley_point(base,start,0,h),alley_point(base,end,0,h),alley_point(base,end,0,h+2.5),alley_point(base,start,0,h+2.5)]),c)
	line(base,alley_point(base,0,0,260),Color("#776550"),.55)
	line(alley_point(base,68,0,0),alley_point(base,68,0,260),Color("#1d2a27"),.8)
	# Side windows open directly onto each landing. Keep their recessed plane distinct.
	for level in range(5):
		var h=62.+level*39.
		var a=alley_point(base,9,.15,h+1)
		var b=alley_point(base,31,.15,h+1)
		draw_colored_polygon(PackedVector2Array([a,b,b-Vector2(0,23),a-Vector2(0,23)]),Color("#111e21"))
		line(a,b,Color("#887d61"),1.2)
		line(a-Vector2(0,22),b-Vector2(0,22),Color("#6c624d"),.8)
		line(a-Vector2(0,11),b-Vector2(0,11),Color("#5d6455"),.7)
		line(a,b+Vector2(0,0),Color("#948a6e"),.35)
	# Draw from the upper/back structure toward the nearest landing.
	for level in range(4,-1,-1):
		var h=62.+level*39.
		# Cantilever brackets connect outer beams back to masonry below each floor.
		for d in [7.,42.]:
			line(alley_point(base,d,0,h-9),alley_point(base,d,12,h),iron,1.5)
			line(alley_point(base,d,0,h),alley_point(base,d,12,h),edge,.65)
		var a=alley_point(base,6,1,h)
		var b=alley_point(base,44,1,h)
		var c=alley_point(base,44,12,h)
		var e=alley_point(base,6,12,h)
		draw_colored_polygon(PackedVector2Array([a,b,c,e]),Color("#293934"))
		# Open grating with a deep front rim; tread/rail highlights are thin worn steel.
		for d in range(7,44,3):
			line(alley_point(base,d,1,h),alley_point(base,d,12,h),Color("#101f22"),1.3)
			line(alley_point(base,d,1,h+.35),alley_point(base,d,12,h+.35),Color("#58675c"),.35)
		line(a,e,iron,2)
		line(e,c,iron,1.7)
		line(a-Vector2(0,.6),e-Vector2(0,.6),edge,.55)
		# The long flight rises away along the alley, with two stringers and real cross-treads.
		if level<4:
			for out in [2.,10.5]:
				line(alley_point(base,9,out,h),alley_point(base,40,out,h+39),iron,1.7)
				line(alley_point(base,9,out,h+9),alley_point(base,40,out,h+48),edge,.65)
			for n in range(11):
				var d=9.+float(n)*3.1
				var step_h=h+float(n)*3.9
				line(alley_point(base,d,2,step_h),alley_point(base,d,10.5,step_h),iron,1.6)
				line(alley_point(base,d,2,step_h+.5),alley_point(base,d,10.5,step_h+.5),edge,.55)
				if n%2==0:
					line(alley_point(base,d,10.5,step_h),alley_point(base,d,10.5,step_h+9),Color("#59695c"),.65)
		# Outer balusters and end rail follow the same deck, never float beside it.
		for d in range(6,45,6):
			line(alley_point(base,d,12,h),alley_point(base,d,12,h+9),iron,.95)
		line(alley_point(base,6,12,h+9),alley_point(base,44,12,h+9),edge,.65)
		for out in [1.,6.,12.]:
			line(alley_point(base,6,out,h),alley_point(base,6,out,h+9),iron,.95)
		line(alley_point(base,6,1,h+9),alley_point(base,6,12,h+9),edge,.7)
		# Small anchor plates and restrained rust sit at structural connections.
		for d in [7.,42.]:
			var bolt=alley_point(base,d,0,h)
			line(bolt+Vector2(0,2),bolt-Vector2(0,3),Color("#293731"),1)
			rect(Rect2(bolt-Vector2(.2,1),Vector2(.4,.5)),Color("#ac9973"))
			line(alley_point(base,d,12,h),alley_point(base,d+2,12,h),Color("#756044"),.5)
	# Retracted drop ladder ends above head height and above the dumpster, not on the path.
	for out in [3.,9.]:
		line(alley_point(base,6,out,62),alley_point(base,6,out,32),iron,1.2)
		line(alley_point(base,6,out+.3,61),alley_point(base,6,out+.3,32),edge,.35)
	for h in range(34,62,3):
		line(alley_point(base,6,3,h),alley_point(base,6,9,h),edge,.65)

func metal_oval(center: Vector2,radii: Vector2,c: Color) -> void:
	var points=PackedVector2Array()
	for n in range(28):
		var angle=TAU*float(n)/28.
		points.append(center+Vector2(cos(angle)*radii.x,sin(angle)*radii.y))
	draw_colored_polygon(points,c)

func trash_can(q: Vector2,sz: Vector2) -> void:
	# Tapered, dented galvanized body with a rolled lid, ribs and separate loop handles.
	rng.seed=absi(str(prop[0]).hash())
	var base=q+Vector2(sz.x*.5,sz.y-.6)
	var rx=sz.x*.47
	var h=14.
	var top=base-Vector2(0,h-1.6)
	metal_oval(base+Vector2(.35,.45),Vector2(rx+.7,1.3),Color(.025,.04,.035,.42))
	var shell=PackedVector2Array([top+Vector2(-rx,.2),top+Vector2(rx,.2),base+Vector2(rx*.9,-1.1),base+Vector2(rx*.65,.3),base+Vector2(-rx*.64,.3),base+Vector2(-rx*.9,-.8)])
	draw_colored_polygon(shell,Color("#35463f"))
	var tones=[Color("#6f7c69"),Color("#87907a"),Color("#73816c"),Color("#616f5f"),Color("#4d6154"),Color("#394e44"),Color("#2b4038")]
	for n in range(7):
		var left=-rx+float(n)*rx*2/7.
		var right=left+rx*2/7.+.12
		draw_colored_polygon(PackedVector2Array([top+Vector2(left,.3),top+Vector2(right,.3),base+Vector2(right*.88,-.8),base+Vector2(left*.88,-.8)]),tones[n])
	for n in range(1,7):
		var x=-rx+float(n)*rx*2/7.
		var dent=-.3 if n in [2,5] else .1
		var points=PackedVector2Array([top+Vector2(x,2),base+Vector2(x*.94+dent,-6),base+Vector2(x*.88,-1.8)])
		draw_polyline(points,Color("#425745"),.4)
		line(top+Vector2(x-.28,2),base+Vector2(x*.88-.28,-1.8),Color("#839178"),.24)
	metal_oval(base-Vector2(0,.35),Vector2(rx*.91,.9),Color("#415a46"))
	line(base+Vector2(-rx*.7,.15),base+Vector2(rx*.6,.25),Color("#697d63"),.35)
	# The lid overhangs the body, with an elliptical crown and shaded rolled rim.
	metal_oval(top+Vector2(0,.3),Vector2(rx+.6,1.8),Color("#253a34"))
	metal_oval(top-Vector2(0,.5),Vector2(rx+.65,1.65),Color("#9b9e83"))
	metal_oval(top-Vector2(0,.65),Vector2(rx-.2,1.05),Color("#737f69"))
	line(top+Vector2(-rx*.55,-1.1),top+Vector2(rx*.4,-1.1),Color("#b2b397"),.45)
	for side in [-1.,1.]:
		var t=top+Vector2(side*(rx+.05),3.1)
		draw_polyline(PackedVector2Array([t,t+Vector2(side*1.0,.3),t+Vector2(side*1.05,2),t+Vector2(0,2.2)]),Color("#223e32"),1)
		line(t+Vector2(side*.5,.2),t+Vector2(side*.7,1.7),Color("#9aa089"),.4)
	# Small arched lid handle casts a shadow onto the crown.
	line(top+Vector2(-1.4,-.7),top+Vector2(1.5,-.7),Color("#263e33"),.8)
	draw_polyline(PackedVector2Array([top+Vector2(-1.2,-.8),top+Vector2(-.8,-1.9),top+Vector2(.8,-1.9),top+Vector2(1.2,-.8)]),Color("#afb199"),.55)
	for i in range(7):
		var t=base+Vector2(rng.randf_range(-rx*.72,rx*.72),rng.randf_range(-10.5,-2))
		line(t,t+Vector2(.45,.6),Color("#354b3b") if i%3 else Color("#92957a"),.3)
	line(base+Vector2(-1,-3.8),base+Vector2(1.7,-4.1),Color("#53644e"),.6)

func fallen_can(q: Vector2,sz: Vector2) -> void:
	# Lying cylinder: closed base at left, deep open mouth at right, lengthwise ribs.
	var left=q+Vector2(2,sz.y-3.6)
	var right=q+Vector2(sz.x-2,sz.y-3.1)
	metal_oval(q+Vector2(sz.x*.5,sz.y+.5),Vector2(sz.x*.58,2.3),Color(.025,.04,.035,.62))
	draw_colored_polygon(PackedVector2Array([left+Vector2(0,-3.8),right+Vector2(0,-4.2),right+Vector2(0,4),left+Vector2(0,3.4)]),Color("#5f7361"))
	metal_oval(left,Vector2(2,3.7),Color("#526650"))
	for band in range(6):
		var y=-3.+float(band)*1.15
		line(left+Vector2(.5,y),right+Vector2(-.7,y+.1),[Color("#87947b"),Color("#9aa188"),Color("#788971"),Color("#576e58"),Color("#3d5744"),Color("#304b3c")][band],1)
		line(left+Vector2(.5,y+.6),right+Vector2(-.7,y+.65),Color("#354d3d"),.35)
	metal_oval(right,Vector2(2.2,4.3),Color("#a1a58b"))
	metal_oval(right+Vector2(.15,0),Vector2(1.6,3.5),Color("#182b27"))
	metal_oval(right+Vector2(-.15,.3),Vector2(.8,2.6),Color("#263e32"))
	line(left+Vector2(-.6,-2.8),left+Vector2(-.9,2.2),Color("#99a488"),.45)
	var handle=left.lerp(right,.3)+Vector2(0,-3.8)
	draw_polyline(PackedVector2Array([handle,handle+Vector2(.2,-1.1),handle+Vector2(2.5,-1.2),handle+Vector2(2.7,0)]),Color("#94a18a"),.6)

func spilled_rubbish(q: Vector2,sz: Vector2) -> void:
	# Detached lid and crumpled litter sit on the pavement, outside the cover body.
	rng.seed=int(q.x*71+q.y*19)
	var mouth=q+Vector2(sz.x,sz.y-1)
	metal_oval(mouth+Vector2(4.5,3.7),Vector2(4.2,1.65),Color(.025,.04,.035,.5))
	metal_oval(mouth+Vector2(4.1,3.1),Vector2(4.1,1.6),Color("#556854"))
	metal_oval(mouth+Vector2(4.1,2.8),Vector2(3.7,1.15),Color("#8b967a"))
	line(mouth+Vector2(3,2.6),mouth+Vector2(5,2.6),Color("#3b5340"),.7)
	for i in range(10):
		var t=mouth+Vector2(rng.randf_range(0,10),rng.randf_range(-3.7,3))
		var w=rng.randf_range(.9,2.5)
		var paper=PackedVector2Array([t,t+Vector2(w,-.35),t+Vector2(w+.5,.85),t+Vector2(.4,1.2)])
		draw_colored_polygon(paper,Color("#a69f7f") if i%3 else Color("#705843"))
		line(t+Vector2(.5,.2),t+Vector2(w*.7,.7),Color("#c0b697") if i%3 else Color("#9a7657"),.35)
	var bottle=mouth+Vector2(2,-3)
	line(bottle,bottle+Vector2(2,1.4),Color("#365941"),1.2)
	line(bottle+Vector2(2,1.4),bottle+Vector2(2.7,1.8),Color("#7b8d62"),.65)
	metal_oval(mouth+Vector2(7,-1),Vector2(1.2,.65),Color("#899581"))

func street_car(q: Vector2,sz: Vector2) -> void:
	var end=Vector2(q.x+sz.x/2,q.y+sz.y+1)
	var arrival=prop[0]=="arrival_car"
	var facing=-1. if str(prop[0]).begins_with("north") or arrival else 1.
	# Parked bodies receive this same footprint shadow in the ground bake.
	if arrival:street_prop_shadow(q,sz)
	draw_set_transform(end,0,Vector2(facing,1.10))
	var height=sz.x*float(textures["burgundy_sedan"].get_height())/float(textures["burgundy_sedan"].get_width())
	if arrival:arrival_door(sz.x,height,false)
	asset("burgundy_sedan",Vector2.ZERO,sz.x,Color.WHITE)
	if arrival:
		# A small recessed doorway stays within the front passenger compartment.
		var hinge=Vector2(sz.x*.205,-height*.17)
		var opening=PackedVector2Array([hinge+Vector2(0,-height*.245),hinge+Vector2(-sz.x*.16,-height*.19),hinge+Vector2(-sz.x*.16,-.25),hinge])
		draw_colored_polygon(opening,door_colors["edge"])
		line(hinge+Vector2(-sz.x*.16,-.25),hinge,door_colors["paint_dark"],.45)
		arrival_door(sz.x,height,true)
	draw_set_transform(Vector2.ZERO)

func street_prop_shadow(q: Vector2,sz: Vector2) -> void:
	# One footprint/contact treatment for authored parked props and live arriving cars.
	draw_colored_polygon(PackedVector2Array([q,q+Vector2(sz.x,0),q+sz+Vector2(3,4),q+Vector2(2,sz.y+4)]),Color(.015,.022,.026,.6))

func prepare_door_colors(paint: Color) -> void:
	# Sample the actual sedan, then apply the exact paint transform used by its shader.
	if sedan_source_image==null:sedan_source_image=textures["burgundy_sedan"].get_image()
	var points={"paint":Vector2i(50,16),"paint_dark":Vector2i(82,49),"paint_light":Vector2i(50,4),"edge":Vector2i(43,46),"glass":Vector2i(51,39),"glass_light":Vector2i(92,18)}
	for key in points:
		var c=sedan_source_image.get_pixelv(points[key])
		if c.r>c.g*1.25 and c.r>c.b*1.15:
			var value=maxf(c.r,maxf(c.g,c.b))*1.7
			c=Color(paint.r*value,paint.g*value,paint.b*value,c.a)
		door_colors[key]=c

func arrival_door(width: float,height: float,near_side: bool) -> void:
	# Front door length and outward opening are projected from one hinged leaf.
	# Short side panels and raked glazing match the elevated view of the sedan.
	var hinge=Vector2(width*.205,-height*(.17 if near_side else .715))
	var angle=deg_to_rad(36. if near_side else 48.)
	var sign_y=1. if near_side else -1.
	var leaf=Vector2(-cos(angle),sign_y*.75*sin(angle))*width*.175
	var tip=hinge+leaf
	var panel_h=height*.10
	var glass_h=height*.15
	var belt_hinge=hinge-Vector2(0,panel_h)
	var belt_tip=tip-Vector2(0,panel_h)
	var top_hinge=belt_hinge+Vector2(-width*.025,-glass_h*.80)
	var top_tip=belt_tip+Vector2(width*.008,-glass_h)
	var outline=PackedVector2Array([hinge,tip+Vector2(.25,-.2),belt_tip,top_tip,top_hinge,belt_hinge])
	# A dark edge and a narrow return face give the open leaf actual thickness.
	var back=PackedVector2Array()
	for point in outline:back.append(point+Vector2(.25,.18))
	draw_colored_polygon(back,door_colors["edge"])
	draw_colored_polygon(outline,door_colors["paint_dark"])
	var panel=PackedVector2Array([hinge+Vector2(-.2,-.25),tip+Vector2(.1,-.35),belt_tip+Vector2(.12,.2),belt_hinge+Vector2(-.18,.2)])
	draw_colored_polygon(panel,door_colors["paint"])
	line(hinge+Vector2(-.15,-.3),tip+Vector2(.15,-.35),door_colors["paint_dark"],.5)
	# Raked A-pillar, thin painted window frame and the same dark glass as the car.
	var glass=PackedVector2Array([belt_hinge+Vector2(-.3,-.2),belt_tip+Vector2(.2,-.2),top_tip+Vector2(.12,.35),top_hinge+Vector2(-.05,.3)])
	draw_colored_polygon(glass,door_colors["glass"])
	line(top_hinge,top_tip,door_colors["paint_light"],.35)
	line(belt_hinge,belt_tip,door_colors["paint_light"],.35)
	line(belt_tip,top_tip,door_colors["paint_dark"],.4)
	line(top_hinge,belt_hinge,door_colors["paint_light"],.35)
	line(top_hinge.lerp(belt_hinge,.45),top_tip.lerp(belt_tip,.45),door_colors["glass_light"],.3)
	# Recessed trim and handle are restrained, using body swatches instead of a separate green.
	var handle=hinge.lerp(tip,.72)-Vector2(0,panel_h*.55)
	line(handle,handle+leaf.normalized()*.75,door_colors["edge"],.45)
	line(handle-Vector2(0,.2),handle+leaf.normalized()*.65-Vector2(0,.2),door_colors["paint_light"],.25)
