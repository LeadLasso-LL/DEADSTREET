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
   r(Rect2(-1600,-1100,5000,2800),Color("#56684a"));draw_texture(ground_plate,Vector2(-1200,-900))
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
  "hedge":hedge(q,sz)
  "sandbags":sandbags(q,sz)
  "table":table(q,sz)
  "crates":crates(q,sz)
  "tree":tree(p(box.get_center()),1.0)
  "traffic":
   var texture=Models.sprite(prop[3],prop[4],float(prop[5]))
   if texture!=null:draw_texture_rect(texture,Rect2(Vector2(-64,-66)*Models.TACTICAL_SCALE,Vector2(128,96)*Models.TACTICAL_SCALE),false,Color("#c1c0a9"))
func ground():
 r(Rect2(-1600,-1100,5000,2800),Color("#56684a"))
 var foreground_rng=rng.state
 surroundings()
 rng.state=foreground_rng
 # Lawn stripes are subtle; bare patches, edged beds and gravel keep it grounded.
 var lawn=Rect2(-220,-35,1900,780);r(lawn,Color("#56684a"))
 for x in range(-220,1680,45):r(Rect2(x,-35,22,780),Color(.75,.77,.51,.045))
 grain(lawn,14000)
 for i in range(45):
  var q=Vector2(rng.randf_range(180,1370),rng.randf_range(20,620));oval(q,Vector2(rng.randf_range(4,17),rng.randf_range(2,8)),Color(.25,.28,.18,.15))
 # Public road: right-hand traffic northbound in the east lane. TRC turns right.
 r(Rect2(9,-1100,130,2800),Color("#303532"));grain(Rect2(12,-1100,123,2800),4000)
 for x in [18.,132.]:l(Vector2(x,-1100),Vector2(x,1700),Color("#c8c0a2"),1.)
 for y in range(-1090,1700,26):r(Rect2(71,y,2,15),Color("#b6a970"));r(Rect2(76,y,2,15),Color("#b6a970"))
 r(Rect2(140,-1100,8,2800),Color("#716b54"));grain(Rect2(140,-1100,8,2800),550)
 # Drive with a real circular turnaround and four narrow connector paths.
 var drive=Rect2(143,336,655,108)
 # The outside border starts at x139, exactly on the public road edge.
 r(Rect2(139,332,663,116),Color("#8d8971"));r(drive,Color("#767461"));grain(drive,2800)
 var center=C.FOUNTAIN*Vector2(8,6)
 oval(center,Vector2(208,145),Color("#aba48a"));oval(center,Vector2(201,139),Color("#7f7d69"))
 for n in range(28):
  var a=n*TAU/28.;var point=center+Vector2(cos(a)*197,sin(a)*135)
  l(point,point+Vector2(cos(a)*5,sin(a)*4),Color("#c9c0a0"),1.)
 oval(center,Vector2(69,50),Color("#b2a68a"));oval(center,Vector2(62,44),Color("#49553c"))
 for i in range(1000):
  var at=Vector2(rng.randf_range(center.x-207,center.x+207),rng.randf_range(center.y-144,center.y+144))
  var distance=((at-center)/Vector2(211,147)).length()
  if distance<1.0 and distance>.46:r(Rect2(at,Vector2(1,1)),Color(.77,.74,.60,.1))
 r(Rect2(384,530,626,32),Color("#77745a"));grain(Rect2(384,530,626,32),1800)
 r(Rect2(419,151,476,16),Color("#aaa182"));grain(Rect2(419,151,476,16),800)
 # A separate paved forecourt bridges the ring and the recessed portico.
 # The ring ends at x=130; steps begin at x=136, beyond the vehicle carriageway.
 var court=Rect2(1032,312,80,138)
 r(court.grow(3),Color("#d0c5a8"));r(court,Color("#b0a68c"))
 for x in range(1032,1113,16):l(Vector2(x,312),Vector2(x,450),Color("#99917b"),.7)
 for y in range(312,451,14):l(Vector2(1032,y),Vector2(1112,y),Color("#99917b"),.7)
 # Tapered approach joins paving flush with the outer curb, not into the lane.
 poly([Vector2(1018,350),Vector2(1034,350),Vector2(1034,417),Vector2(1018,417)],Color("#b0a68c"))
 # Parked vehicles now belong to inset gravel bays, not unrelated rectangles.
 for area in [Rect2(673,244,121,51),Rect2(851,250,126,50),Rect2(976,340,42,100),Rect2(905,134,125,67),Rect2(484,531,288,73),Rect2(779,516,227,57)]:
  r(area.grow(3),Color("#9a947b"));r(area,Color("#7f8068"));grain(area,900)
 # Low clipped hedges and border beds turn the lawn into a managed estate.
 for area in [Rect2(515,71,395,17),Rect2(532,216,294,12),Rect2(736,481,250,14),Rect2(445,110,46,152),Rect2(1078,96,42,63),Rect2(1076,569,45,35)]:
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
  if row[2]=="hedge":
   var bed: Rect2=Rect2(row[1].position*Vector2(8,6),row[1].size*Vector2(8,6)).grow(5)
   r(bed,Color("#786e51"));grain(bed,150,true)
  if row[2]=="tree":
   var at=row[1].get_center()*Vector2(8,6)
   oval(at+Vector2(24,9),Vector2(31,12),Color(.10,.16,.09,.23))
 for spec in [[45.,8.],[47.,104.],[20.,15.],[173.,6.],[171.,102.]]:
  distant_tree(Vector2(spec[0]*8,spec[1]*6),1.2)
 # Garage access apron continues through the lower gate to the outside track.
 var apron=Rect2(80*8,96*6,20*8,16*6)
 r(apron.grow(3),Color("#979078"));r(apron,Color("#78755e"));grain(apron,950)
 var track=Rect2(18*8,109*6,85*8,4*6)
 r(track,Color("#77735b"));grain(track,850)
 for x in [80.,100.]:
  var at=Vector2(x*8,102.6*6)
  oval(at+Vector2(0,20),Vector2(4,3),Color(.1,.13,.08,.18))
 # Short compressed turf marks follow the assault vehicles' final approach.
 for pair in [[Vector2(23,63),Vector2(39,49)],[Vector2(23,89),Vector2(41,78)],[Vector2(22,111),Vector2(30,103)]]:
  for offset in [-1.2,1.2]:
   var side=(pair[1]-pair[0]).normalized().orthogonal()*offset
   l((pair[0]+side)*Vector2(8,6),(pair[1]+side)*Vector2(8,6),Color(.25,.27,.16,.22),2.)
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
func surroundings():
 # Decorative noncombat context, baked with an independent random sequence.
 var hinterland=Rect2(-1600,-1100,5000,1065)
 r(hinterland,Color("#526044"));grain(hinterland,36000)
 for field in [Rect2(-1150,-830,1030,650),Rect2(190,-910,920,460),Rect2(1170,-840,1530,640)]:
  r(field,Color("#626b49"));grain(field,9000)
  for y in range(int(field.position.y)+8,int(field.end.y),16):
   l(Vector2(field.position.x,y),Vector2(field.end.x,y),Color(.31,.36,.23,.24),3.)
 # Access lane and drainage shoulders connect neighboring rural lots.
 for lane in [Rect2(-1400,-376,1409,28),Rect2(139,-376,2800,28)]:
  r(lane.grow(4),Color("#77765c"));r(lane,Color("#686b55"));grain(lane,2200)
  l(lane.position+Vector2(0,5),Vector2(lane.end.x,lane.position.y+5),Color("#83816a"),1.)
 for plot in [Rect2(-1040,-625,265,210),Rect2(-570,-605,250,195),Rect2(235,-655,320,232),Rect2(735,-610,265,194),Rect2(1300,-665,310,244),Rect2(1890,-620,280,206)]:
  r(plot.grow(3),Color("#66694e"));r(plot,Color("#72735a"));grain(plot,1100)
  var shed=Rect2(plot.position+Vector2(28,24),Vector2(plot.size.x*.59,64))
  shadow(shed.position,shed.size,16.)
  r(shed,Color("#85816c"))
  r(Rect2(shed.position+Vector2(0,42),Vector2(shed.size.x,28)),Color("#676a59"))
  poly([shed.position+Vector2(-4,38),shed.position+Vector2(13,-10),shed.position+Vector2(shed.size.x-13,-10),shed.position+Vector2(shed.size.x+4,38)],Color("#4c5a50"))
  l(shed.position+Vector2(13,-10),shed.position+Vector2(shed.size.x-13,-10),Color("#7a8370"),2.)
  for x in range(14,int(shed.size.x)-8,13):
   l(shed.position+Vector2(x,1),shed.position+Vector2(x-7,34),Color("#606e5e"),1.)
  for x in [12.,shed.size.x-32.]:
   r(Rect2(shed.position+Vector2(x,46),Vector2(18,13)),Color("#39493e"))
   l(shed.position+Vector2(x,61),shed.position+Vector2(x+20,61),Color("#a09a80"),2.)
  var path=Rect2(plot.get_center().x-8,plot.end.y,16,-348-plot.end.y)
  r(path,Color("#77765c"));grain(path,150)
  for x in range(int(plot.position.x),int(plot.end.x),22):
   r(Rect2(x,plot.end.y-12,2,13),Color("#555d44"))
  l(Vector2(plot.position.x,plot.end.y-8),Vector2(plot.end.x,plot.end.y-8),Color("#7a7b5c"),1.)
 # Layered wooded breaks keep surrounding buildings behind the estate.
 for row in [-810.,-270.,-170.,-55.]:
  for x in range(-1380,2920,42):
   if x>-30 and x<184:continue
   var at=Vector2(x+rng.randf_range(-13,13),row+rng.randf_range(-23,20))
   oval(at+Vector2(11,4),Vector2(29,10),Color(.12,.18,.11,.19))
   distant_tree(at,rng.randf_range(.7,1.3))
 for x in range(-1230,2790,190):
  if x>0 and x<180:continue
  var at=Vector2(x,-331)
  l(at+Vector2(3,0),at+Vector2(3,-64),Color("#424d3b"),3.)
  l(at+Vector2(-9,-58),at+Vector2(14,-58),Color("#787862"),2.)
  if x<2600:
   for i in range(12):
    var t=float(i)/12.;var u=float(i+1)/12.
    l(at+Vector2(t*190,-59+sin(t*PI)*8),at+Vector2(u*190,-59+sin(u*PI)*8),Color("#49513e"),.7)
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
func hedge(q: Vector2,sz: Vector2):
 shadow(q,sz,7.)
 r(Rect2(q-Vector2(0,9),sz+Vector2(0,9)),Color("#30472e"))
 for i in range(int(sz.x*sz.y/6)):
  var at=q+Vector2(rng.randf()*sz.x,rng.randf()*sz.y)-Vector2(0,9)
  oval(at,Vector2(3.5,2.5),Color("#607b43").lightened(rng.randf_range(-.13,.15)))
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
