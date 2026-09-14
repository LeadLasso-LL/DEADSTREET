extends Node2D
## Retained native art. Baked ground and depth-sorted physical props share C.
const C=preload("res://battle/geometry/whittaker_estate_catalog.gd")
const Models=preload("res://campaign/vehicles/vehicle_model_catalog.gd")
const GROUND_PATH="res://assets/art/whittaker_estate/ground.png"
const Architecture=preload("res://gameplay/estate_architecture.gd")
const INK=Color("#222923")
static var ground_plate: Texture2D
static var prop_plates={}
var prop_plate: Texture2D
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
 if not bake_mode and not prop.is_empty() and prop[2] not in ["fountain","traffic","fountain_body","column"]:
  var path="res://assets/art/whittaker_estate/props/"+str(prop[0])+".png"
  if not prop_plates.has(path) and FileAccess.file_exists(path):
   var im=Image.new()
   if im.load_png_from_buffer(FileAccess.get_file_as_bytes(path))==OK:prop_plates[path]=ImageTexture.create_from_image(im)
  prop_plate=prop_plates.get(path)
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
   r(Rect2(-1600,-1100,5000,2800),Color("#56684a"));draw_texture(ground_plate,Vector2(-512,-384))
  else:ground()
  return
 var box: Rect2=prop[1];var q=p(box.position);var sz=box.size*Vector2(8,6)
 if prop_plate!=null and not bake_mode:
  draw_texture(prop_plate,Vector2(-prop_plate.get_width()*.5,48.-prop_plate.get_height()));return
 if prop[2] in ["house","wing","gatehouse","garage","step_wall","column"]:
  Architecture.new(self).render(prop);return
 match prop[2]:
  "fence":fence(q,sz)
  "pier":pier(q,sz)
  "fountain":
   draw_set_transform(p(C.FOUNTAIN),0,Vector2(.8,.8));fountain(Vector2.ZERO);draw_set_transform(Vector2.ZERO)
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
 r(Rect2(-1600,-1100,5000,2800),Color("#56684a"))
 # Quiet city silhouette through the treeline, not a second visual focal point.
 r(Rect2(-650,-310,2700,240),Color("#728078"))
 for x in range(-600,2000,38):
  var h=rng.randf_range(18,74);var y=-130+rng.randf_range(-5,5)
  r(Rect2(x,y-h,rng.randf_range(25,38),h),Color("#829184").darkened(rng.randf_range(.0,.1)))
  if x%3==0:l(Vector2(x+14,y-h),Vector2(x+14,y-h-12),Color("#6b7567"),2.)
  for wy in range(7,int(h)-4,10):
   for wx in range(5,25,8):r(Rect2(x+wx,y-h+wy,2,2),Color("#828775"))
 for i in range(90):
  var q=Vector2(-520+i*28.,-65+rng.randf_range(-20,25))
  distant_tree(q,rng.randf_range(.7,1.35))
 # Lawn stripes are subtle; bare patches, edged beds and gravel keep it grounded.
 var lawn=Rect2(-220,-35,1900,780);r(lawn,Color("#56684a"))
 for x in range(-220,1680,45):r(Rect2(x,-35,22,780),Color(.75,.77,.51,.045))
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
 oval(center,Vector2(218,153),Color("#aba48a"));oval(center,Vector2(211,147),Color("#7f7d69"))
 for n in range(28):
  var a=n*TAU/28.;var point=center+Vector2(cos(a)*205,sin(a)*142)
  l(point,point+Vector2(cos(a)*5,sin(a)*4),Color("#c9c0a0"),1.)
 oval(center,Vector2(69,50),Color("#b2a68a"));oval(center,Vector2(62,44),Color("#49553c"))
 for i in range(1000):
  var at=Vector2(rng.randf_range(center.x-207,center.x+207),rng.randf_range(center.y-144,center.y+144))
  var distance=((at-center)/Vector2(211,147)).length()
  if distance<1.0 and distance>.46:r(Rect2(at,Vector2(1,1)),Color(.77,.74,.60,.1))
 r(Rect2(384,530,626,32),Color("#77745a"));grain(Rect2(384,530,626,32),1800)
 r(Rect2(419,151,476,16),Color("#aaa182"));grain(Rect2(419,151,476,16),800)
 # The court meets the west-facing steps; service paths do not run under walls.
 poly([Vector2(998,331),Vector2(1113,331),Vector2(1113,376),Vector2(1010,407)],Color("#b8af91"))
 for x in range(1004,1110,12):l(Vector2(x,334),Vector2(x,375),Color("#938e76"),.7)
 # Parked vehicles now belong to inset gravel bays, not unrelated rectangles.
 for area in [Rect2(884,248,133,66),Rect2(905,134,125,67),Rect2(484,531,288,73),Rect2(844,527,131,67)]:
  r(area.grow(3),Color("#9a947b"));r(area,Color("#7f8068"));grain(area,900)
 # Low clipped hedges and border beds turn the lawn into a managed estate.
 for area in [Rect2(515,71,395,17),Rect2(532,216,294,12),Rect2(736,481,250,14)]:
  r(area.grow(4),Color("#756e50"));r(area,Color("#394e31"))
  for i in range(int(area.size.x/3)):
   var at=area.position+Vector2(rng.randf()*area.size.x,rng.randf()*area.size.y)
   oval(at,Vector2(4,3),Color("#617a46").lightened(rng.randf_range(-.1,.1)))
 # Subtle garden walks with individual paving joints and uneven edging.
 for area in [Rect2(534,95,17,108),Rect2(897,87,15,95)]:
  r(area.grow(2),Color("#6f7655"));r(area,Color("#a6a083"))
  for y in range(int(area.position.y)+7,int(area.end.y),9):l(Vector2(area.position.x,y),Vector2(area.end.x,y),Color("#888e72"),.8)
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
