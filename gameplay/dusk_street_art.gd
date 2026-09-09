extends Node2D
const Catalog = preload("res://battle/geometry/dusk_street_catalog.gd")
var prop: Array = []
var rng = RandomNumberGenerator.new()
const GROUND = Color("#292b35")
const INK = Color("#131923")
func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
func p(v: Vector2) -> Vector2:
	return Vector2(v.x*8,v.y*6)-position
func box(r: Rect2, color: Color) -> void:
	draw_rect(Rect2(p(r.position),Vector2(r.size.x*8,r.size.y*6)),color)
func rect(r: Rect2, color: Color) -> void:
	draw_rect(r,color)
func _draw() -> void:
	rng.seed = 832
	if prop.is_empty(): ground()
	elif prop[2] == "lamp": lamp()
	else: object_art()
func ground() -> void:
	rect(Rect2(-180,-140,880,640),Color("#171e2b"))
	box(Rect2(0,0,64,46),GROUND)
	box(Rect2(0,15,64,8),Color("#49474b"))
	box(Rect2(0,35,64,6),Color("#444247"))
	box(Rect2(0,23,64,12),Color("#262a32"))
	box(Rect2(16,0,6,23),Color("#303139"))
	box(Rect2(40,0,8,23),Color("#303139"))
	# Deterministic pixel clusters, sparse wear rather than full-screen noise.
	for i in range(3500):
		var x = rng.randi_range(0,511)
		var y = rng.randi_range(0,275)
		var c = Color("#363942") if i%3 else Color("#23252e")
		if y>=90 and y<138 or y>=210 and y<246:
			c = Color("#555055") if i%3 else Color("#3d3c44")
		rect(Rect2(x,y,rng.randi_range(1,3),1),c)
	for y in [136,209]:
		rect(Rect2(0,y,512,2),Color("#79706a"))
		rect(Rect2(0,y+2,512,2),INK)
	for x in range(0,512,12):
		for y in [93,107,121,215,229]:
			rect(Rect2(x,y,1,12),Color("#36363e"))
	for x in range(0,512,27):
		rect(Rect2(x,171,13,1),Color("#8c7951"))
		rect(Rect2(x,176,13,1),Color("#796b4b"))
	for x in [34,451]:
		for y in range(144,200,10):
			rect(Rect2(x,y,17,4),Color("#8a8174"))
	# Patched asphalt, drain grates, paper and oil.
	for xy in [Vector2(123,192),Vector2(339,150),Vector2(193,231),Vector2(76,152)]:
		rect(Rect2(xy,Vector2(31,9)),Color("#20252d"))
		for n in range(5): rect(Rect2(xy+Vector2(n*6,1),Vector2(3,1)),Color("#45444b"))
	for x in [63,211,366,486]:
		rect(Rect2(x,132,12,4),INK)
		for n in range(5): rect(Rect2(x+n*2,132,1,3),Color("#67605d"))
	for i in range(32):
		var xy = Vector2(rng.randi_range(8,501),rng.randi_range(91,242))
		rect(Rect2(xy,Vector2(2,1)),Color("#a4997f"))
	for xy in [Vector2(109,199),Vector2(354,202),Vector2(191,115)]:
		for i in range(5):
			rect(Rect2(xy+Vector2(i*3,i%2),Vector2(17-i*2,1)),Color("#555563"))
	# Stepped pools of sodium light, restrained cyan from the laundry.
	for row in [[Vector2(11,23),Color(0.85,0.54,0.24,0.07)],[Vector2(38,23),Color(0.95,0.51,0.19,0.07)],[Vector2(55,17),Color(0.3,0.65,0.7,0.06)]]:
		var xy = p(row[0])
		for n in range(8):
			rect(Rect2(xy-Vector2(27-n*3,15-n),Vector2(54-n*6,32-n*2)),row[1])
	# Soft contact shadows under the authored objects.
	for row in Catalog.props():
		var r: Rect2 = row[1]
		box(Rect2(r.position+Vector2(0.6,0.8),r.size+Vector2(0.6,0.2)),Color(0.04,0.05,0.08,0.4))
func object_art() -> void:
	var r: Rect2 = prop[1]
	var xy = p(r.position)
	var sz = Vector2(r.size.x*8,r.size.y*6)
	if prop[2] == "building":
		building(xy,sz,str(prop[3]))
	elif prop[2] == "car" or prop[2] == "van":
		car(xy,sz)
		if prop[2] == "van":
			rect(Rect2(xy+Vector2(12,-12),Vector2(sz.x-14,sz.y+4)),Color("#777572"))
			rect(Rect2(xy+Vector2(14,-11),Vector2(sz.x-18,sz.y-2)),Color("#8a8580"))
			rect(Rect2(xy+Vector2(14,sz.y-10),Vector2(sz.x-18,4)),Color("#565961"))
			rect(Rect2(xy+Vector2(20,sz.y-8),Vector2(9,1)),Color("#9a8c76"))
	else:
		cover_prop(xy,sz,str(prop[2]))
func building(xy: Vector2, sz: Vector2, title: String) -> void:
	var height = 32.0
	var roof = Rect2(xy-Vector2(0,height),sz)
	rect(Rect2(xy,sz),INK)
	rect(Rect2(xy+Vector2(0,sz.y-height),Vector2(sz.x,height)),Color("#4c4143"))
	rect(roof,Color("#373b45"))
	rect(Rect2(roof.position+Vector2(2,2),roof.size-Vector2(4,4)),Color("#44434b"))
	# Tar seams, parapet caps and roof ventilation.
	for y in range(5,int(sz.y)-3,9):
		rect(Rect2(roof.position+Vector2(3,y),Vector2(sz.x-6,1)),Color("#353842"))
	for i in range(35):
		var q = roof.position+Vector2(rng.randi_range(4,int(sz.x)-5),rng.randi_range(4,int(sz.y)-5))
		rect(Rect2(q,Vector2(2,1)),Color("#555057"))
	rect(Rect2(roof.position,Vector2(sz.x,2)),Color("#777077"))
	rect(Rect2(roof.position+Vector2(0,sz.y-2),Vector2(sz.x,3)),Color("#272a33"))
	rect(Rect2(roof.position+Vector2(0,sz.y),Vector2(sz.x,2)),Color("#817574"))
	for x in [sz.x*0.2,sz.x*0.7]:
		var ac = roof.position+Vector2(x,9)
		rect(Rect2(ac+Vector2(2,3),Vector2(13,10)),INK)
		rect(Rect2(ac,Vector2(13,9)),Color("#69676b"))
		for n in range(4): rect(Rect2(ac+Vector2(2,1+n*2),Vector2(9,1)),Color("#3a404b"))
	var fy = xy.y+sz.y-height+3
	for yy in range(int(fy),int(xy.y+sz.y)-1,4):
		rect(Rect2(xy.x+2,yy,sz.x-4,1),Color("#382f38"))
		for xx in range(int(xy.x)+3+(yy%8),int(xy.x+sz.x)-2,10):
			rect(Rect2(xx,yy,1,4),Color("#675257"))
	# Recessed entry and readable windows at human scale.
	var door = Vector2(xy.x+sz.x*0.55,xy.y+sz.y-23)
	rect(Rect2(door-Vector2(2,2),Vector2(13,26)),Color("#706165"))
	rect(Rect2(door,Vector2(9,23)),INK)
	rect(Rect2(door+Vector2(2,2),Vector2(5,9)),Color("#756451"))
	rect(Rect2(door+Vector2(7,11),Vector2(1,2)),Color("#cbaf78"))
	for x in [5.0,sz.x-22.0]:
		var win=Vector2(xy.x+x,xy.y+sz.y-15)
		rect(Rect2(win-Vector2.ONE,Vector2(16,12)),INK)
		rect(Rect2(win,Vector2(14,10)),Color("#a48d61"))
		rect(Rect2(win+Vector2(6,0),Vector2(2,10)),Color("#3e3840"))
		rect(Rect2(win+Vector2(0,5),Vector2(14,1)),Color("#514348"))
		for n in range(3): rect(Rect2(win+Vector2(n*5,0),Vector2(1,10)),Color("#47434a"))
	var sign=Vector2(xy.x+3,fy-3)
	rect(Rect2(sign,Vector2(sz.x-6,9)),Color("#28202c"))
	rect(Rect2(sign,Vector2(sz.x-6,1)),Color("#98635b"))
	draw_string(ThemeDB.fallback_font,sign+Vector2(3,7),title,HORIZONTAL_ALIGNMENT_LEFT,sz.x-12,7,Color("#d1b398"))
	rect(Rect2(xy+Vector2(sz.x*0.54-4,sz.y),Vector2(20,2)),Color("#777071"))
	# Downpipe and peeling notices.
	rect(Rect2(xy+Vector2(sz.x-3,sz.y-height),Vector2(2,height)),Color("#1e2833"))
	rect(Rect2(xy+Vector2(25,sz.y-9),Vector2(4,6)),Color("#999080"))
	# Worn awnings above the shop windows; separate colors identify frontages.
	var fabric = Color("#654b50") if title != "LAUNDROMAT" else Color("#456569")
	for ax in [5.0,sz.x-22.0]:
		rect(Rect2(xy+Vector2(ax-1,sz.y-18),Vector2(17,4)),fabric)
		for n in range(4):
			rect(Rect2(xy+Vector2(ax+n*4,sz.y-18),Vector2(2,3)),fabric.lightened(.12))
		rect(Rect2(xy+Vector2(ax-1,sz.y-14),Vector2(17,1)),INK)
	# Small tags and torn flyers, away from the unit silhouettes.
	var tag = xy+Vector2(33,sz.y-7)
	for n in range(5):
		rect(Rect2(tag+Vector2(n*2,-n%3),Vector2(1,4)),Color("#8b7880"))
	rect(Rect2(tag+Vector2(-1,3),Vector2(13,1)),Color("#8b7880"))
func car(xy: Vector2, sz: Vector2) -> void:
	var top = xy-Vector2(0,6)
	var paint = Color("#535563")
	if str(prop[0]) == "threshold_sedan": paint = Color("#66504b")
	if str(prop[0]) == "east_sedan": paint = Color("#3e5657")
	# Stepped corners, separate roof, glazing and a low visible sill.
	rect(Rect2(xy+Vector2(2,sz.y-2),Vector2(sz.x-4,3)),INK)
	for x in [5.0,sz.x-11]:
		rect(Rect2(xy+Vector2(x,sz.y-4),Vector2(6,6)),INK)
		rect(Rect2(xy+Vector2(x+1,sz.y-3),Vector2(4,4)),Color("#727077"))
		rect(Rect2(xy+Vector2(x+2,sz.y-2),Vector2(2,2)),Color("#282c34"))
	rect(Rect2(top+Vector2(3,0),Vector2(sz.x-6,sz.y+2)),paint)
	rect(Rect2(top+Vector2(1,2),Vector2(sz.x-2,sz.y-2)),paint)
	rect(Rect2(top+Vector2(0,4),Vector2(sz.x,sz.y-6)),paint)
	rect(Rect2(top+Vector2(3,1),Vector2(sz.x-6,1)),paint.lightened(.25))
	rect(Rect2(top+Vector2(3,sz.y-1),Vector2(sz.x-6,3)),paint.darkened(.25))
	var cx = floor(sz.x*.3)
	var cw = floor(sz.x*.4)
	rect(Rect2(top+Vector2(cx-2,2),Vector2(cw+4,sz.y-3)),INK)
	rect(Rect2(top+Vector2(cx,1),Vector2(cw,sz.y-5)),Color("#7c7575"))
	rect(Rect2(top+Vector2(cx-2,3),Vector2(3,sz.y-6)),Color("#63777e"))
	rect(Rect2(top+Vector2(cx+cw,3),Vector2(3,sz.y-6)),Color("#455e6b"))
	rect(Rect2(top+Vector2(cx,sz.y-4),Vector2(cw,4)),Color("#243743"))
	rect(Rect2(top+Vector2(cx+cw*.5,sz.y-4),Vector2(1,4)),paint.lightened(.15))
	rect(Rect2(top+Vector2(cx-3,sz.y-3),Vector2(3,2)),paint.lightened(.2))
	rect(Rect2(top+Vector2(cx+cw*.5,sz.y+1),Vector2(3,1)),Color("#aaa2a0"))
	rect(Rect2(top+Vector2(cx+cw*.5-2,sz.y),Vector2(1,4)),INK)
	for y in [3.0,sz.y-5]:
		rect(Rect2(top+Vector2(0,y),Vector2(2,2)),Color("#d5bc88"))
		rect(Rect2(top+Vector2(sz.x-2,y),Vector2(2,2)),Color("#9d4645"))
	rect(Rect2(top+Vector2(0,6),Vector2(1,sz.y-11)),Color("#a3a0a0"))
	rect(Rect2(top+Vector2(sz.x-1,6),Vector2(1,sz.y-11)),Color("#a3a0a0"))
	rect(Rect2(top+Vector2(5,sz.y-2),Vector2(4,1)),paint.lightened(.35))
func cover_prop(xy: Vector2, sz: Vector2, kind: String) -> void:
	var h=6.0
	var base=Color("#77706a")
	if kind=="dumpster": base=Color("#455a51");h=9
	if kind=="crate": base=Color("#796554");h=6
	if kind=="utility": base=Color("#60636a");h=17
	rect(Rect2(xy-Vector2(0,h),sz+Vector2(0,h)),INK)
	rect(Rect2(xy+Vector2(1,sz.y-h),Vector2(sz.x-2,h)),base.darkened(0.22))
	rect(Rect2(xy-Vector2(-1,h-1),sz-Vector2(2,2)),base)
	rect(Rect2(xy-Vector2(0,h),Vector2(sz.x,1)),base.lightened(0.25))
	if kind=="wall":
		for x in range(0,int(sz.x),9): rect(Rect2(xy+Vector2(x,sz.y-5),Vector2(1,5)),INK)
	elif kind=="dumpster":
		for x in range(3,int(sz.x)-2,6): rect(Rect2(xy+Vector2(x,sz.y-7),Vector2(1,5)),base.lightened(.12))
		rect(Rect2(xy+Vector2(4,sz.y-4),Vector2(6,2)),Color("#a29879"))
	elif kind=="crate":
		for y in range(1,int(sz.y)+5,3):rect(Rect2(xy+Vector2(0,y-6),Vector2(sz.x,1)),base.darkened(.35))
	else:
		for y in range(4,11,2):rect(Rect2(xy+Vector2(3,sz.y-y),Vector2(sz.x-6,1)),INK)

func lamp() -> void:
	# Small sprite-like fixture. Light pool lives on the ground beneath it.
	rect(Rect2(-2,-1,5,2),Color("#101823"))
	rect(Rect2(0,-28,2,28),Color("#242b35"))
	rect(Rect2(0,-28,1,25),Color("#77706a"))
	rect(Rect2(1,-29,8,2),Color("#333c48"))
	rect(Rect2(6,-28,5,2),Color("#b89a68"))
	rect(Rect2(7,-27,3,1),Color("#ead1a0"))
