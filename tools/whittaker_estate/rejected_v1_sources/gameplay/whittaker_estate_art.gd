extends Node2D
## Retained native art. Baked ground and depth-sorted physical props share C.
const C=preload("res://battle/geometry/whittaker_estate_catalog.gd")
const Models=preload("res://campaign/vehicles/vehicle_model_catalog.gd")
const GROUND_PATH="res://assets/art/whittaker_estate/ground.png"
const INK=Color("#222923")
static var ground_plate: Texture2D
var prop: Array=[]
var view
var bake_mode=false
var rng=RandomNumberGenerator.new()
var font: SystemFont
var timer=0.
func _ready():
 texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 font=SystemFont.new();font.font_names=PackedStringArray(["Georgia"]);font.font_weight=600
 if prop.is_empty() and not bake_mode and ground_plate==null and FileAccess.file_exists(GROUND_PATH):
  var im=Image.new()
  if im.load_png_from_buffer(FileAccess.get_file_as_bytes(GROUND_PATH))==OK:ground_plate=ImageTexture.create_from_image(im)
 set_process(not prop.is_empty() and prop[2]=="fountain")
func _process(delta):
 timer+=delta
 if int(timer*8)!=int((timer-delta)*8):queue_redraw()
func p(at: Vector2) -> Vector2:return at*Vector2(8,6)-position
func r(box: Rect2,color: Color):draw_rect(box,color)
func l(a: Vector2,b: Vector2,c: Color,w=1.):draw_line(a,b,c,w,false)
func poly(points: Array,c: Color):draw_colored_polygon(PackedVector2Array(points),c)
func oval(q: Vector2,sz: Vector2,c: Color):
 var pts=PackedVector2Array()
 for n in range(48):pts.append(q+Vector2(cos(n*TAU/48.),sin(n*TAU/48.))*sz)
 draw_colored_polygon(pts,c)
func grain(box: Rect2,n: int,dark=false):
 for i in range(n):
  var at=box.position+Vector2(rng.randf()*box.size.x,rng.randf()*box.size.y)
  r(Rect2(at,Vector2(1,1)),Color(.08,.10,.07,rng.randf_range(.02,.13)) if dark else Color(.79,.77,.59,rng.randf_range(.025,.13)))
func _draw():
 rng.seed=14371 if prop.is_empty() else absi(str(prop[0]).hash())
 if prop.is_empty():
  if not bake_mode and ground_plate!=null:
   r(Rect2(-1600,-1100,5000,2800),Color("#485541"));draw_texture(ground_plate,Vector2(-512,-384))
  else:ground()
  return
 var box: Rect2=prop[1];var q=p(box.position);var sz=box.size*Vector2(8,6)
 match prop[2]:
  "house":house(q,sz)
  "gatehouse":hut(q,sz,false)
  "garage":hut(q,sz,true)
  "fence":fence(q,sz)
  "pier":pier(q,sz)
  "fountain":fountain(p(C.FOUNTAIN))
  "fountain_body":pass
  "planter":planter(q,sz)
  "sandbags":sandbags(q,sz)
  "table":table(q,sz)
  "crates":crates(q,sz)
  "tree":tree(p(box.get_center()),1.0)
  "traffic":
   var texture=Models.sprite(prop[3],prop[4],float(prop[5]))
   if texture!=null:draw_texture_rect(texture,Rect2(Vector2(-64,-66)*Models.TACTICAL_SCALE,Vector2(128,96)*Models.TACTICAL_SCALE),false,Color("#c1c0a9"))
func ground():
 r(Rect2(-1600,-1100,5000,2800),Color("#485541"))
 # Quiet city silhouette through the treeline, not a second visual focal point.
 r(Rect2(-650,-310,2700,240),Color("#535d56"))
 for x in range(-600,2000,38):
  var h=rng.randf_range(18,74);var y=-130+rng.randf_range(-5,5)
  r(Rect2(x,y-h,rng.randf_range(25,38),h),Color("#626c60").darkened(rng.randf_range(.0,.1)))
  if x%3==0:l(Vector2(x+14,y-h),Vector2(x+14,y-h-12),Color("#6b7567"),2.)
  for wy in range(7,int(h)-4,10):
   for wx in range(5,25,8):r(Rect2(x+wx,y-h+wy,2,2),Color("#828775"))
 for i in range(90):
  var q=Vector2(-520+i*28.,-65+rng.randf_range(-20,25))
  distant_tree(q,rng.randf_range(.7,1.35))
 # Lawn stripes are subtle; bare patches, edged beds and gravel keep it grounded.
 var lawn=Rect2(-220,-35,1900,780);r(lawn,Color("#485541"))
 for x in range(-220,1680,45):r(Rect2(x,-35,22,780),Color(.60,.64,.43,.028))
 grain(lawn,14000)
 for i in range(45):
  var q=Vector2(rng.randf_range(180,1370),rng.randf_range(20,620));oval(q,Vector2(rng.randf_range(4,17),rng.randf_range(2,8)),Color(.25,.28,.18,.15))
 # Public road: right-hand traffic northbound in the east lane. TRC turns right.
 r(Rect2(9,-600,130,1900),Color("#303532"));grain(Rect2(12,-220,123,1150),4000)
 for x in [18.,132.]:l(Vector2(x,-500),Vector2(x,1200),Color("#c8c0a2"),1.)
 for y in range(-480,1200,26):r(Rect2(71,y,2,15),Color("#b6a970"));r(Rect2(76,y,2,15),Color("#b6a970"))
 r(Rect2(140,-120,8,920),Color("#716b54"));grain(Rect2(140,-120,8,920),550)
 # Drive with a real circular turnaround and four narrow connector paths.
 var drive=Rect2(135,336,663,108);r(drive.grow(4),Color("#8d8971"));r(drive,Color("#767461"));grain(drive,2800)
 var center=C.FOUNTAIN*Vector2(8,6)
 oval(center,Vector2(214,150),Color("#aba48a"));oval(center,Vector2(208,145),Color("#7f7d69"))
 for n in range(28):
  var a=n*TAU/28.;var point=center+Vector2(cos(a)*205,sin(a)*142)
  l(point,point+Vector2(cos(a)*5,sin(a)*4),Color("#c9c0a0"),1.)
 oval(center,Vector2(87,64),Color("#b2a68a"));oval(center,Vector2(79,58),Color("#49553c"))
 for i in range(1000):
  var at=Vector2(rng.randf_range(center.x-207,center.x+207),rng.randf_range(center.y-144,center.y+144))
  var distance=((at-center)/Vector2(208,145)).length()
  if distance<1.0 and distance>.46:r(Rect2(at,Vector2(1,1)),Color(.77,.74,.60,.1))
 r(Rect2(384,530,626,32),Color("#77745a"));grain(Rect2(384,530,626,32),1800)
 r(Rect2(418,141,550,26),Color("#99927a"));grain(Rect2(418,141,550,26),1000)
 # Curved walk from the court to the mansion steps.
 r(Rect2(1010,377,219,35),Color("#ada78f"))
 for x in range(1010,1220,12):l(Vector2(x,378),Vector2(x,411),Color("#8b8873"),.7)
 for y in [382.,394.,407.]:l(Vector2(1010,y),Vector2(1228,y),Color("#bdb69d"),1.)
 # Gravel parking bay, service apron and worn wheel tracks.
 for area in [Rect2(889,234,167,79),Rect2(1080,427,280,79),Rect2(792,521,152,66)]:
  r(area,Color("#6f705c"));grain(area,1300)
 for y in [359.,414.]:l(Vector2(160,y),Vector2(706,y),Color(.22,.24,.18,.14),5.)
 # Beds and low flowers around the upper garden rather than empty lawn.
 for area in [Rect2(535,193,130,18),Rect2(741,174,107,18),Rect2(923,111,63,22)]:
  r(area.grow(2),Color("#6b6248"));r(area,Color("#3e4932"))
  for i in range(55):
   var q=area.position+Vector2(rng.randf()*area.size.x,rng.randf()*area.size.y)
   oval(q,Vector2(2,1),Color("#8c8d65") if i%3 else Color("#bbab7d"))
 # Patio, clipped shrubs and tree shadows follow their physical anchors.
 for row in C.props():
  if row[2]=="tree":
   var at=row[1].get_center()*Vector2(8,6)
   oval(at+Vector2(24,9),Vector2(31,12),Color(.10,.16,.09,.23))
 for spec in [[45.,8.],[47.,104.],[20.,15.],[173.,6.],[171.,102.]]:
  distant_tree(Vector2(spec[0]*8,spec[1]*6),1.2)
 # Main gate leaves are open inward, preserving the vehicle/infantry entrance.
 for y in [53.,73.]:
  var at=Vector2(400,y*6);var end=at+Vector2(40,-16 if y<60 else 16)
  l(at-Vector2(0,15),end-Vector2(0,15),Color("#232e28"),2.)
  l(at-Vector2(0,3),end-Vector2(0,3),Color("#343e30"),2.)
  for n in range(9):
   var q=at.lerp(end,float(n)/8.);l(q,q-Vector2(0,20),Color("#24332b"),1.)
 # Estate plaque belongs to the wall and stays a quiet real-scale detail.
 r(Rect2(378,290,18,12),Color("#303d30"));draw_rect(Rect2(378,290,18,12),Color("#a7965d"),false,.8)
 draw_string(font,Vector2(380,298),"W",HORIZONTAL_ALIGNMENT_CENTER,14,8,Color("#d3c79a"))
 for at in [Vector2(405,304),Vector2(405,450),Vector2(850,313),Vector2(982,448)]:
  l(at,at-Vector2(0,24),Color("#303b2f"),2.);r(Rect2(at-Vector2(3,29),Vector2(6,7)),Color("#a69865"));r(Rect2(at-Vector2(2,28),Vector2(4,4)),Color("#d3bf7e"))
func distant_tree(q: Vector2,scale_value: float):
 var c=Color("#394b39")
 r(Rect2(q-Vector2(2,30)*scale_value,Vector2(4,34)*scale_value),Color("#3e4332"))
 for spec in [[-12.,-27.,20.,17.],[12.,-29.,19.,20.],[0.,-48.,22.,24.]]:
  oval(q+Vector2(spec[0],spec[1])*scale_value,Vector2(spec[2],spec[3])*scale_value,c.lightened(rng.randf_range(0.,.07)))
func shadow(q: Vector2,sz: Vector2,reach=12.):
 poly([q+Vector2(0,sz.y),q+sz,q+sz+Vector2(reach,reach*.4),q+Vector2(reach,sz.y+reach*.4)],Color(.10,.13,.08,.30))
func window(q: Vector2,w: float,h: float):
 r(Rect2(q-Vector2(2,2),Vector2(w+4,h+4)),Color("#7f8474"))
 r(Rect2(q,Vector2(w,h)),Color("#23382f"));r(Rect2(q+Vector2(2,2),Vector2(w-4,h-4)),Color("#4a5b4d"))
 poly([q+Vector2(3,2),q+Vector2(w-2,2),q+Vector2(3,h*.6)],Color("#637163"))
 l(q+Vector2(w*.5,0),q+Vector2(w*.5,h),Color("#d8d6be"),2.);l(q+Vector2(0,h*.5),q+Vector2(w,h*.5),Color("#dad7bf"),1.)
 r(Rect2(q+Vector2(-3,h+1),Vector2(w+6,3)),Color("#e0ddc4"))
 for dx in [-10.,w+3.]:
  r(Rect2(q+Vector2(dx,-1),Vector2(7,h+2)),Color("#35483a"))
  for y in range(3,int(h),4):l(q+Vector2(dx+1,y),q+Vector2(dx+6,y),Color("#56624c"),1.)
func house(q: Vector2,sz: Vector2):
 var face=q+Vector2(0,sz.y-129.)
 shadow(q,sz,22.)
 # Raised limestone foundation and distinct front/side planes.
 r(Rect2(q+Vector2(0,sz.y-12),Vector2(sz.x,16)),Color("#706f5a"))
 r(Rect2(face,Vector2(sz.x,123)),Color("#d3d0b9"));r(Rect2(face+Vector2(2,2),Vector2(sz.x-4,112)),Color("#dfdcc6"))
 poly([q+Vector2(sz.x,0),q+sz,q+sz+Vector2(15,-10),q+Vector2(sz.x+15,-10)],Color("#8b9581"))
 for y in range(5,116,6):l(face+Vector2(2,y),face+Vector2(sz.x-2,y),Color("#c3c2ac"),.65)
 grain(Rect2(face,Vector2(sz.x,120)),1500,true)
 # Deep eaves and hip roof; shingles break up the broad roof planes.
 poly([q+Vector2(-9,-83),q+Vector2(sz.x-28,-89),face+Vector2(sz.x+9,-8),face+Vector2(-9,-8)],Color("#323d38"))
 poly([q+Vector2(22,-106),q+Vector2(sz.x-60,-109),face+Vector2(sz.x-34,-29),face+Vector2(15,-29)],Color("#526055"))
 poly([q+Vector2(sz.x-60,-109),q+Vector2(sz.x-28,-89),face+Vector2(sz.x+9,-8),face+Vector2(sz.x-34,-29)],Color("#39473f"))
 var top=q.y-100.;var bottom=face.y-26
 for y in range(int(top),int(bottom),8):
  var progress=(y-top)/maxf(bottom-top,1.);var left=q.x+22-progress*8;var right=q.x+sz.x-60+progress*24
  l(Vector2(left,y),Vector2(right,y),Color("#424f45"),1.)
  for x in range(int(left)+5,int(right)-4,17):l(Vector2(x,y),Vector2(x+1,y+5),Color("#637063"),.6)
 r(Rect2(face+Vector2(-9,-9),Vector2(sz.x+19,8)),Color("#a6ad97"));r(Rect2(face+Vector2(-9,-9),Vector2(sz.x+19,2)),Color("#ece6cf"))
 # Chimneys, flashing and masonry caps.
 for dx in [28.,sz.x-66.]:
  var at=q+Vector2(dx,-90)
  r(Rect2(at,Vector2(18,35)),Color("#a9a68b"));r(Rect2(at-Vector2(3,3),Vector2(24,6)),Color("#d5d0b5"))
  for y in range(5,31,6):l(at+Vector2(1,y),at+Vector2(17,y),Color("#8a8d75"),1.)
 # Two stories of inset windows with shutters. Central entrance is recessed.
 for dx in [23.,70.,sz.x-96.,sz.x-49.]:
  window(face+Vector2(dx,13),23,35);window(face+Vector2(dx,72),23,33)
 var center=face+Vector2(sz.x*.5,0)
 r(Rect2(center+Vector2(-20,69),Vector2(40,52)),Color("#8c917c"));r(Rect2(center+Vector2(-17,72),Vector2(34,47)),Color("#2f3d30"))
 for dx in [-14.,3.]:
  r(Rect2(center+Vector2(dx,76),Vector2(11,17)),Color("#596c56"));r(Rect2(center+Vector2(dx,98),Vector2(11,16)),Color("#41533d"))
 r(Rect2(center+Vector2(-2,96),Vector2(4,2)),Color("#c8b277"))
 window(center+Vector2(-13,11),26,36)
 # Broad portico, tall round columns, balustrade and central pediment.
 var front=face.y+129
 for dx in [-63.,-39.,39.,63.]:
  var x=center.x+dx
  r(Rect2(x-5,face.y+5,10,121),Color("#9ca38b"));r(Rect2(x-4,face.y+6,7,119),Color("#e6e2cc"));r(Rect2(x-3,face.y+7,2,118),Color("#f0ead4"))
  r(Rect2(x-7,face.y+2,14,5),Color("#d7d7bd"));r(Rect2(x-7,front-6,14,7),Color("#cbcbb0"))
 r(Rect2(center+Vector2(-77,-6),Vector2(154,11)),Color("#dedcc4"))
 poly([center+Vector2(-82,-7),center+Vector2(82,-7),center+Vector2(0,-45)],Color("#eee8d1"))
 poly([center+Vector2(-66,-12),center+Vector2(66,-12),center+Vector2(0,-36)],Color("#a5ad96"))
 l(center+Vector2(-83,-8),center+Vector2(0,-47),Color("#f4edd8"),3.);l(center+Vector2(0,-47),center+Vector2(83,-8),Color("#c5ccb1"),3.)
 r(Rect2(center+Vector2(-71,58),Vector2(142,5)),Color("#a6af96"))
 for dx in range(-66,70,8):l(center+Vector2(dx,48),center+Vector2(dx,59),Color("#ece7ce"),2.)
 l(center+Vector2(-72,47),center+Vector2(72,47),Color("#e7e2c8"),3.)
 for i in range(5):
  r(Rect2(center+Vector2(-53-i*2,129+i*3),Vector2(106+i*4,3)),Color("#9b9f88"));l(center+Vector2(-53-i*2,129+i*3),center+Vector2(53+i*2,129+i*3),Color("#d2ceb5"),1.)
 for dx in [-103.,103.]:planter(Vector2(center.x+dx-9,front-4),Vector2(18,12))
func hut(q: Vector2,sz: Vector2,garage: bool):
 var h=40. if not garage else 61.;shadow(q,sz,14.)
 var front=q+Vector2(0,sz.y-h)
 r(Rect2(front,Vector2(sz.x,h)),Color("#c3c5ac"));r(Rect2(front+Vector2(2,2),Vector2(sz.x-4,h-5)),Color("#d3d0b7"))
 for y in range(5,int(h)-3,5):l(front+Vector2(1,y),front+Vector2(sz.x-1,y),Color("#afb49a"),1.)
 poly([q+Vector2(-5,-h),q+Vector2(sz.x-8,-h-6),front+Vector2(sz.x+5,-5),front+Vector2(-5,-5)],Color("#3d4d3e"))
 for y in range(int(q.y-h)+6,int(front.y)-5,7):l(Vector2(q.x+3,y),Vector2(q.x+sz.x-8,y),Color("#58624c"),1.)
 l(front+Vector2(-5,-4),front+Vector2(sz.x+5,-4),Color("#e0d9bc"),2.)
 if garage:
  for dx in [10.,sz.x*.52]:
   var w=sz.x*.4;r(Rect2(front+Vector2(dx,10),Vector2(w,h-12)),Color("#435240"))
   for y in range(15,int(h)-5,7):l(front+Vector2(dx+2,y),front+Vector2(dx+w-2,y),Color("#7a836b"),1.)
   r(Rect2(front+Vector2(dx+w*.5,h-15),Vector2(7,2)),Color("#b9b69a"))
 else:
  window(front+Vector2(10,8),20,22)
  r(Rect2(front+Vector2(sz.x-26,5),Vector2(18,h-7)),Color("#41503c"));r(Rect2(front+Vector2(sz.x-23,8),Vector2(12,15)),Color("#849079"))
  l(front+Vector2(sz.x-12,25),front+Vector2(sz.x-9,25),Color("#d5c78f"),1.)
  r(Rect2(front+Vector2(9,-15),Vector2(45,9)),Color("#354a35"));draw_string(font,front+Vector2(11,-8),"SECURITY",HORIZONTAL_ALIGNMENT_CENTER,41,5,Color("#d9d0a7"))
 grain(Rect2(front,Vector2(sz.x,h)),int(sz.x*2),true)
func fence(q: Vector2,sz: Vector2):
 var vertical=sz.y>sz.x;var end=q+Vector2(0,sz.y) if vertical else q+Vector2(sz.x,0)
 l(q+Vector2(2,2),end+Vector2(2,2),Color("#252f26"),4.)
 l(q,end,Color("#929780"),4.);l(q-Vector2(0,3),end-Vector2(0,3),Color("#c0bca1"),2.)
 for lift in [8.,19.]:l(q-Vector2(0,lift),end-Vector2(0,lift),Color("#293c2d"),1.5)
 var count=int(q.distance_to(end)/5.)
 for n in range(count+1):
  var at=q.lerp(end,float(n)/maxf(count,1.));l(at-Vector2(0,3),at-Vector2(0,24),Color("#2b3d2e"),1.2)
  poly([at+Vector2(-2,-22),at+Vector2(2,-22),at+Vector2(0,-26)],Color("#637155"))
func pier(q: Vector2,sz: Vector2):
 shadow(q,sz,6.);r(Rect2(q-Vector2(0,23),sz+Vector2(0,23)),Color("#89927b"));r(Rect2(q+Vector2(1,-22),sz+Vector2(-3,20)),Color("#c1c0a5"))
 for y in range(-19,int(sz.y)-1,5):l(q+Vector2(1,y),q+Vector2(sz.x-2,y),Color("#a0a68c"),1.)
 r(Rect2(q+Vector2(-2,-26),Vector2(sz.x+4,5)),Color("#d2ccb0"));oval(q+Vector2(sz.x*.5,-30),Vector2(4,5),Color("#d6d0b3"))
func planter(q: Vector2,sz: Vector2):
 shadow(q,sz,5.);r(Rect2(q-Vector2(0,8),sz+Vector2(0,8)),Color("#72775d"));r(Rect2(q+Vector2(1,-8),sz-Vector2(2,0)),Color("#c0b596"));r(Rect2(q+Vector2(2,-6),sz-Vector2(4,2)),Color("#3e4a31"))
 for i in range(int(sz.x*.5)):
  var at=q+Vector2(rng.randf_range(2,sz.x-2),rng.randf_range(-9,sz.y-4));oval(at,Vector2(3,2),Color("#626e46").lightened(rng.randf_range(0.,.14)))
 grain(Rect2(q+Vector2(0,sz.y-7),Vector2(sz.x,7)),int(sz.x),true)
func sandbags(q: Vector2,sz: Vector2):
 shadow(q,sz,5.)
 for layer in range(3):
  for y in range(0,int(sz.y),7):
   for x in range(-3 if layer%2 else 0,int(sz.x)-3,12):
    var at=q+Vector2(x+6,y-layer*4.);oval(at+Vector2(1,2),Vector2(7,4),Color("#50553d"));oval(at,Vector2(6,3.5),Color("#97946c").darkened(layer*.04));l(at+Vector2(-3,-1),at+Vector2(3,-1),Color("#b7af84"),1.)
func table(q: Vector2,sz: Vector2):
 shadow(q,sz,6.);poly([q,q+Vector2(sz.x,0),q+sz-Vector2(2,14),q+Vector2(2,sz.y-14)],Color("#7b6543"))
 for x in range(3,int(sz.x)-1,7):l(q+Vector2(x,0),q+Vector2(x,sz.y-14),Color("#a68b5e"),1.)
 for x in [3.,sz.x-4.]:l(q+Vector2(x,0),q+Vector2(x+4,sz.y+1),Color("#514d32"),3.)
func crates(q: Vector2,sz: Vector2):
 shadow(q,sz,6.)
 for ox in [0.,sz.x*.45]:
  var at=q+Vector2(ox,-12);var w=sz.x*.52;r(Rect2(at,Vector2(w,sz.y+10)),Color("#65583c"));r(Rect2(at+Vector2(1,1),Vector2(w-2,sz.y+7)),Color("#8e7750"))
  for y in range(4,int(sz.y)+5,5):l(at+Vector2(1,y),at+Vector2(w-1,y),Color("#b09363"),1.)
  l(at+Vector2(2,2),at+Vector2(w-3,sz.y+7),Color("#665a3a"),2.)
func tree(q: Vector2,s: float):
 r(Rect2(q-Vector2(3,35)*s,Vector2(6,36)*s),Color("#554e34"));l(q-Vector2(1,3),q-Vector2(2,38),Color("#827351"),1.)
 l(q-Vector2(0,22),q-Vector2(15,40),Color("#65583a"),3.)
 for i in range(35):
  var a=rng.randf()*TAU;var reach=rng.randf()*23
  var at=q+Vector2(cos(a)*reach,sin(a)*reach*.63)-Vector2(0,43)
  oval(at,Vector2(rng.randf_range(7,15),rng.randf_range(5,11)),Color("#3e5132").lightened(rng.randf_range(0.,.15)))
func fountain(q: Vector2):
 oval(q+Vector2(6,7),Vector2(62,41),Color(.08,.14,.10,.32))
 oval(q,Vector2(58,40),Color("#737c69"));oval(q-Vector2(0,5),Vector2(58,38),Color("#c7c2a7"));oval(q-Vector2(0,6),Vector2(48,30),Color("#6f897b"))
 oval(q-Vector2(0,8),Vector2(45,27),Color("#839c8c"))
 for i in range(9):
  var a=i*TAU/9.+timer*.08;var at=q+Vector2(cos(a)*31,sin(a)*19)-Vector2(0,8)
  l(at,at+Vector2(8,0),Color(.75,.82,.69,.25),1.)
 r(Rect2(q-Vector2(5,47),Vector2(10,40)),Color("#959d87"));r(Rect2(q-Vector2(4,47),Vector2(5,39)),Color("#e0d8b8"))
 oval(q-Vector2(0,33),Vector2(23,10),Color("#717f6c"));oval(q-Vector2(0,38),Vector2(26,10),Color("#d8cfad"));oval(q-Vector2(0,40),Vector2(21,7),Color("#8caa99"))
 oval(q-Vector2(0,54),Vector2(9,5),Color("#c8c9aa"));oval(q-Vector2(0,57),Vector2(10,4),Color("#e5dcc0"))
 for dx in [-18.,-9.,9.,18.]:
  var alpha=.38+sin(timer*5+dx)*.1
  l(q+Vector2(dx,-37),q+Vector2(dx*1.3,-11+sin(timer*3+dx)*2),Color(.79,.86,.77,alpha),1.)
  r(Rect2(q+Vector2(dx*1.3,-10),Vector2(3,1)),Color(.81,.88,.76,.4))
 l(q-Vector2(0,57),q-Vector2(0,66+sin(timer*2)*2),Color(.8,.86,.76,.65),1.2)
