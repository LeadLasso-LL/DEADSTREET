extends Node2D
const Catalog = preload("res://battle/geometry/dusk_street_catalog.gd")
const ASSETS = "res://assets/art/street_detail/"
var prop: Array = []
var rng = RandomNumberGenerator.new()
var textures: Dictionary = {}
const INK = Color("#171d20")
func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	for key in ["auto_shop","corner_store","burgundy_sedan","dumpster_0","barrier_0","lamp_0","tires_0","yard_fence"]:
		textures[key] = load(ASSETS+key+".png")
	if not prop.is_empty() and prop[2] == "car":
		var mat := ShaderMaterial.new()
		mat.shader = load("res://assets/art/street_detail/car_paint.gdshader")
		var paint = Color("#596c71")
		if prop[0] == "threshold_sedan": paint = Color("#854744")
		if prop[0] == "arrival_car": paint = Color("#3b4546")
		if prop[0] == "west_sedan": paint = Color("#65715c")
		mat.set_shader_parameter("paint",Vector3(paint.r,paint.g,paint.b))
		material = mat
func p(v: Vector2) -> Vector2:
	return Vector2(v.x*8,v.y*6)-position
func rect(r: Rect2,c: Color) -> void:
	draw_rect(r,c)
func box(r: Rect2,c: Color) -> void:
	rect(Rect2(p(r.position),Vector2(r.size.x*8,r.size.y*6)),c)
func line(a: Vector2,b: Vector2,c: Color,w: float=0.35) -> void:
	draw_line(a,b,c,w,false)
func asset(key: String, bottom: Vector2, width: float, tint: Color=Color.WHITE) -> void:
	var tex: Texture2D = textures.get(key)
	if tex == null: return
	var size = tex.get_size()*width/tex.get_width()
	draw_texture_rect(tex,Rect2(bottom-Vector2(width/2,size.y),size),false,tint)
func _draw() -> void:
	rng.seed=922
	if prop.is_empty(): ground()
	elif prop[2]=="lamp":
		asset("lamp_0",Vector2(2,0),10)
	else: object_art()
func ground() -> void:
	rect(Rect2(-200,-180,1000,800),Color("#20292a"))
	box(Rect2(0,0,64,46),Color("#363b38"))
	box(Rect2(0,23,64,12),Color("#282e31"))
	# Large pavement slabs with narrow seams, patched corners and a curb face.
	for band in [Rect2(0,15,64,8),Rect2(0,35,64,6)]:
		box(band,Color("#55564c"))
		for x in range(0,64,2):
			for y in range(int(band.position.y),int(band.end.y),2):
				var q=p(Vector2(x,y))
				rect(Rect2(q+Vector2(.25,.25),Vector2(15.5,11.5)),Color("#55584f").lightened(rng.randf_range(-.035,.035)))
				line(q,q+Vector2(16,0),Color("#767567"),.3)
	for y in [23,35]:
		var q=p(Vector2(0,y))
		rect(Rect2(q-Vector2(0,1.2),Vector2(512,1.2)),Color("#8c8974"))
		rect(Rect2(q,Vector2(512,1.5)),Color("#202628"))
	for x in range(0,512,24):
		rect(Rect2(x,173,11,.55),Color("#9a8659"))
		rect(Rect2(x,175,11,.45),Color("#746647"))
	# Fine pixel aggregate retains detail when inspected close up.
	for i in range(15000):
		var q=Vector2(rng.randf_range(0,512),rng.randf_range(40,276))
		var c=Color(0.57,0.55,0.43,rng.randf_range(.04,.15))
		rect(Rect2(q,Vector2(.3,.3)),c)
	for q in [Vector2(100,182),Vector2(352,151),Vector2(222,195),Vector2(39,162)]:
		var poly=PackedVector2Array([q,q+Vector2(25,-2),q+Vector2(29,9),q+Vector2(3,11)])
		draw_colored_polygon(poly,Color("#252c2d"))
		for n in range(4):line(poly[n],poly[(n+1)%4],Color("#4c514b"),.4)
	for x in [50,193,330,489]:
		var q=Vector2(x,135)
		rect(Rect2(q,Vector2(9,2)),INK)
		for n in range(10):line(q+Vector2(n*.85,0),q+Vector2(n*.85,2),Color("#727867"),.25)
	for q in [Vector2(186,187),Vector2(399,161)]:
		draw_circle(q,4,Color("#1b2426"))
		draw_circle(q-Vector2(0,.35),3.4,Color("#60675a"))
		for n in range(-2,3):line(q+Vector2(-2.4,n*.8),q+Vector2(2.4,n*.8),Color("#343f3c"),.3)
	# Short wear and cracks at the curb; no large confetti-like rectangles.
	for i in range(45):
		var q=Vector2(rng.randf_range(0,510),[139,211][i%2]+rng.randf_range(-1,2))
		line(q,q+Vector2(2,1),Color("#202729"),.4)
		line(q+Vector2(2,1),q+Vector2(3,-.5),Color("#202729"),.35)
	# Restrained reflected shop / lamp light, with broad stepped falloff.
	for pair in [[Vector2(11,23),Color(.9,.65,.27,.018)],[Vector2(38,23),Color(.9,.57,.26,.018)],[Vector2(55,16),Color(.37,.67,.67,.015)]]:
		var q=p(pair[0])
		for n in range(18):
			draw_circle(q,float(23-n),pair[1])
	for row in Catalog.props():
		var r: Rect2=row[1]
		var q=p(r.position)
		var sz=Vector2(r.size.x*8,r.size.y*6)
		var depth=9.0 if row[2]=="building" else 3.0
		draw_colored_polygon(PackedVector2Array([q,q+Vector2(sz.x,0),q+sz+Vector2(depth*.4,depth),q+Vector2(depth*.4,sz.y+depth)]),Color(0.035,.06,.07,.4))
	# Service-yard markings and fence suggest a functioning block beyond the fight.
	for x in range(12,95,20):line(Vector2(x,258),Vector2(x+8,274),Color("#777251"),.5)
	asset("yard_fence",Vector2(55,275),85,Color("#aab3b0"))
func object_art() -> void:
	var r: Rect2=prop[1]
	var q=p(r.position)
	var sz=Vector2(r.size.x*8,r.size.y*6)
	var end=Vector2(q.x+sz.x/2,q.y+sz.y)
	match str(prop[2]):
		"building":
			if str(prop[0]).begins_with("south"):
				rear_building(q,sz)
			else:
				var key="auto_shop" if prop[0]=="pawn" else "corner_store"
				asset(key,end,sz.x,Color("#c1c6c5"))
				if prop[0]=="club":
					var sc=sz.x/316.0
					var sign=Vector2(q.x+8*sc,end.y-71*sc)
					rect(Rect2(sign,Vector2(sz.x-16*sc,21*sc)),Color("#46363a"))
					draw_string(ThemeDB.fallback_font,sign+Vector2(2,11*sc),"THE SOCIAL CLUB",HORIZONTAL_ALIGNMENT_CENTER,sz.x-20*sc,7,Color("#c6b69a"))
		"car":
			var tint=Color("#b3bec6") if prop[0]=="east_sedan" else Color("#c8c0b7")
			asset("burgundy_sedan",end+Vector2(0,1),sz.x,tint)
		"van": van(q,sz)
		"dumpster": asset("dumpster_0",end,sz.x,Color("#b8c4ba"))
		"wall": planter(q,sz)
		"utility": cabinet(q,sz)
		"crate": pallets(q,sz)
func rear_building(q: Vector2,sz: Vector2) -> void:
	# North-facing storefront is on the far side. Only rear masonry and roof here.
	# Low foreground cutaway keeps the adjacent sidewalk readable.
	var h=10.0
	rect(Rect2(q-Vector2(0,h),sz+Vector2(0,h)),Color("#272e2e"))
	rect(Rect2(q-Vector2(-1,h-1),sz-Vector2(2,2)),Color("#414844"))
	for y in range(0,int(sz.y)-2,4):line(q+Vector2(1,y-h),q+Vector2(sz.x-1,y-h),Color("#52574d"),.3)
	rect(Rect2(q+Vector2(0,sz.y-h),Vector2(sz.x,h)),Color("#4a4841"))
	for y in range(0,int(h),2):
		line(q+Vector2(0,sz.y-h+y),q+Vector2(sz.x,sz.y-h+y),Color("#303936"),.3)
		for x in range(y%4,int(sz.x),5):line(q+Vector2(x,sz.y-h+y),q+Vector2(x,sz.y-h+y+2),Color("#6a6150"),.3)
	line(q-Vector2(0,h),q+Vector2(sz.x,-h),Color("#8a8370"),.6)
	for x in [sz.x*.25,sz.x*.7]:
		rect(Rect2(q+Vector2(x,sz.y-7),Vector2(8,5)),INK)
		for n in range(5):line(q+Vector2(x+n*1.6,sz.y-7),q+Vector2(x+n*1.6,sz.y-2),Color("#777b6e"),.4)
func cabinet(q: Vector2,sz: Vector2) -> void:
	var top=q-Vector2(0,12)
	rect(Rect2(top,sz+Vector2(0,12)),INK)
	rect(Rect2(top+Vector2(1,1),sz+Vector2(-2,10)),Color("#565f58"))
	line(top+Vector2(1,2),top+Vector2(sz.x-1,2),Color("#929587"),.5)
	for y in range(5,13,2):line(top+Vector2(2,y),top+Vector2(sz.x-2,y),Color("#293632"),.5)
	rect(Rect2(top+Vector2(3,15),Vector2(3,4)),Color("#b6a578"))
	line(top+Vector2(sz.x-3,15),top+Vector2(sz.x-3,20),INK,.6)
	# Separate steel doors, plinth and electrical warning identify street cabinets.
	line(top+Vector2(sz.x*.5,3),top+Vector2(sz.x*.5,sz.y+10),INK,.8)
	rect(Rect2(top+Vector2(1,sz.y+9),Vector2(sz.x-2,3)),Color("#303a38"))
	line(top+Vector2(sz.x*.5-2,16),top+Vector2(sz.x*.5-2,20),Color("#bac0ae"),.8)
	var warning=top+Vector2(3.8,16)
	line(warning,warning+Vector2(-.7,1.2),INK,.55)
	line(warning+Vector2(-.7,1.2),warning+Vector2(.5,1.2),INK,.55)
	line(warning+Vector2(.5,1.2),warning+Vector2(-.3,2.5),INK,.55)
	for y in [sz.y+4,sz.y+6]:
		line(top+Vector2(2,y),top+Vector2(sz.x*.5-2,y),INK,.65)
func pallets(q: Vector2,sz: Vector2) -> void:
	# Full shipping crates on a pallet; slatted faces and diagonal braces.
	var h=12.0
	var t=q-Vector2(0,h)
	rect(Rect2(q+Vector2(1,sz.y-1),Vector2(sz.x-2,2)),Color("#34332a"))
	for x in [2.0,sz.x-5]:rect(Rect2(q+Vector2(x,sz.y),Vector2(3,2)),INK)
	rect(Rect2(t,sz+Vector2(0,h-1)),Color("#695841"))
	rect(Rect2(t+Vector2(1,1),sz-Vector2(2,2)),Color("#9b8660"))
	var face=t+Vector2(0,sz.y)
	rect(Rect2(face,Vector2(sz.x,h-1)),Color("#7b674b"))
	for x in range(1,int(sz.x),4):
		line(face+Vector2(x,0),face+Vector2(x,h-1),Color("#413c30"),.5)
		line(t+Vector2(x,1),t+Vector2(x,sz.y-1),Color("#534e39"),.4)
	for y in [1.0,h-3]:
		rect(Rect2(face+Vector2(0,y),Vector2(sz.x,1.7)),Color("#ab9166"))
	line(face+Vector2(2,h-2),face+Vector2(sz.x-2,1),Color("#b59b73"),1.6)
	for x in [1.5,sz.x-2]:
		for y in [2.0,h-2]:rect(Rect2(face+Vector2(x,y),Vector2(.5,.5)),INK)
	rect(Rect2(face+Vector2(sz.x*.65,3),Vector2(4,4)),Color("#bfb18c"))
	line(face+Vector2(sz.x*.65+1,4),face+Vector2(sz.x*.65+3,4),INK,.3)
func planter(q: Vector2,sz: Vector2) -> void:
	var h=7.0
	var top=q-Vector2(0,h)
	rect(Rect2(top,sz+Vector2(0,h)),Color("#332f2a"))
	rect(Rect2(q+Vector2(0,sz.y-h),Vector2(sz.x,h)),Color("#725a49"))
	for y in range(0,7,2):
		line(q+Vector2(0,sz.y-h+y),q+Vector2(sz.x,sz.y-h+y),Color("#3b3830"),.4)
		for x in range(y%4,int(sz.x),6):line(q+Vector2(x,sz.y-h+y),q+Vector2(x,sz.y-h+y+2),Color("#a18768"),.4)
	rect(Rect2(top-Vector2(.5,.5),Vector2(sz.x+1,1.5)),Color("#aaa08b"))
	rect(Rect2(top+Vector2(1,1),sz-Vector2(2,1)),Color("#353a2b"))
	for x in range(2,int(sz.x)-1,3):
		rect(Rect2(top+Vector2(x,-1-(x%3)),Vector2(3,4)),Color("#495644"))
		rect(Rect2(top+Vector2(x+1,-2),Vector2(1,2)),Color("#758068"))
func van(q: Vector2,sz: Vector2) -> void:
	var t=q-Vector2(0,7)
	for x in [5.0,sz.x-9]:
		draw_circle(q+Vector2(x,sz.y-1),3.2,INK)
		draw_circle(q+Vector2(x,sz.y-1),1.7,Color("#939b97"))
		draw_circle(q+Vector2(x,sz.y-1),.8,Color("#465457"))
	# Box body and a lower separate cab with sloped windshield.
	rect(Rect2(t+Vector2(12,-6),Vector2(sz.x-13,sz.y+8)),Color("#637675"))
	rect(Rect2(t+Vector2(13,-5),Vector2(sz.x-15,sz.y-3)),Color("#9aa7a0"))
	rect(Rect2(t+Vector2(13,sz.y-7),Vector2(sz.x-15,8)),Color("#798d87"))
	line(t+Vector2(13,sz.y-7),t+Vector2(sz.x-2,sz.y-7),Color("#c2c7b4"),.6)
	draw_colored_polygon(PackedVector2Array([t+Vector2(0,6),t+Vector2(4,1),t+Vector2(12,1),t+Vector2(12,sz.y+2),t+Vector2(0,sz.y+2)]),Color("#89998e"))
	draw_colored_polygon(PackedVector2Array([t+Vector2(2,6),t+Vector2(5,2),t+Vector2(11,2),t+Vector2(11,sz.y-5),t+Vector2(2,sz.y-5)]),Color("#233b42"))
	line(t+Vector2(5,3),t+Vector2(10,3),Color("#829fa3"),.6)
	line(t+Vector2(12,sz.y-6),t+Vector2(12,sz.y+2),Color("#344847"),.5)
	rect(Rect2(t+Vector2(8,sz.y-3),Vector2(2,.6)),Color("#d0c9b3"))
	rect(Rect2(t+Vector2(13,sz.y+1),Vector2(sz.x-14,2)),Color("#364d4c"))
	# Rolling cargo shutter with frame, rails and latch.
	rect(Rect2(t+Vector2(21,sz.y-7),Vector2(sz.x-25,8)),Color("#556c69"))
	for y in range(1,7):line(t+Vector2(22,sz.y-7+y),t+Vector2(sz.x-5,sz.y-7+y),Color("#9baca1"),.35)
	rect(Rect2(t+Vector2(25,sz.y-1),Vector2(3,.6)),Color("#d0cab2"))
	rect(Rect2(t+Vector2(0,sz.y-4),Vector2(1,2)),Color("#e5d7a7"))
	line(t+Vector2(0,sz.y+1),t+Vector2(3,sz.y+1),Color("#b4bbaa"),1)
