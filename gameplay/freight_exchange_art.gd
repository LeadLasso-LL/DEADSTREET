extends "res://gameplay/doble_ocho_art.gd"
## Retained pixel scenery. Every solid is drawn from the authored physical footprint.
const Freight=preload("res://battle/geometry/freight_exchange_catalog.gd")
const FREIGHT_PLATE="res://assets/art/freight_exchange/ground.png"
const FREIGHT_ORIGIN=Vector2(-1408,-896)
static var freight_plate: Texture2D
func _ready():
 texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 font=SystemFont.new();font.font_names=PackedStringArray(["Arial"]);font.font_weight=700
 set_process(not prop.is_empty() and prop[2] in ["boxcar","timber_car","dispatch","shed"])
 if prop.is_empty() and not bake_mode and freight_plate==null and FileAccess.file_exists(FREIGHT_PLATE):
  var im=Image.new()
  if im.load_png_from_buffer(FileAccess.get_file_as_bytes(FREIGHT_PLATE))==OK:freight_plate=ImageTexture.create_from_image(im)
func _process(delta):
 # Fade only the local solid that hides a living actor; collision is unchanged.
 var target_alpha=1.
 if view!=null and is_instance_valid(view):
  var b=view._battle_state()
  if b!=null:
   var box: Rect2=prop[1];var h=40. if prop[2] in ["dispatch","shed"] else 26.
   var screen_box=Rect2(box.position*Vector2(8,6)-Vector2(0,h),box.size*Vector2(8,6)+Vector2(0,h))
   for unit in b.participants.values():
    if not unit.has_battle_position or not unit.is_alive:continue
    var foot=unit.battle_position*Vector2(8,6)
    if foot.y>=position.y:continue
    var torso=Rect2(foot-Vector2(8,24),Vector2(16,23))
    if screen_box.intersection(torso).get_area()>torso.get_area()*.45:target_alpha=.35;break
 self_modulate.a=target_alpha if target_alpha<self_modulate.a else move_toward(self_modulate.a,target_alpha,delta*4.)
func _draw():
 rng.seed=915523 if prop.is_empty() else absi(str(prop[0]).hash())
 if prop.is_empty():
  if not bake_mode and freight_plate!=null:draw_texture(freight_plate,FREIGHT_ORIGIN)
  else:freight_ground()
  return
 var box: Rect2=prop[1];var q=p(box.position);var sz=box.size*Vector2(8,6)
 match prop[2]:
  "boxcar":railcar(q,sz,str(prop[3]),false)
  "timber_car":railcar(q,sz,str(prop[3]),true)
  "dispatch","shed":dispatch(q,sz,str(prop[3]),prop[2]=="dispatch")
  "platform":loading_platform(q,sz,str(prop[3]))
  "crates":cargo(q,sz)
  "reel":cable_reel(q,sz)
  "barrier":concrete_stop(q,sz)
func freight_ground():
 var plate=Rect2(FREIGHT_ORIGIN,Vector2(4096,2304))
 r(plate,Color("#373d39"));grain(plate,40000,true)
 # Freight district extends beyond every camera edge, with a public access road.
 for box in [Rect2(-173,-105,63,280),Rect2(-104,-105,57,280),Rect2(179,-105,156,280)]:ground_rect(box,Color("#454a42"),6000)
 for spec in [[-163,-84,43,29],[-100,-45,45,32],[-96,17,38,30],[-167,52,46,37],[-94,102,34,31],[191,-68,48,37],[251,-23,54,33],[193,35,46,34],[259,76,60,37],[185,110,56,36]]:
  backdrop_shop(Rect2(spec[0],spec[1],spec[2],spec[3]),"",int(spec[0])%2==0)
 ground_rect(Rect2(-44,-149,32,382),Color("#292f30"),12000)
 for x in [-41.,-15.]:ground_line(Vector2(x,-149),Vector2(x,233),Color("#a69e85"),1.1)
 for y in range(-140,235,7):
  ground_line(Vector2(-29,y),Vector2(-29,y+4),Color("#ae975e"),1.2)
  ground_line(Vector2(-28,y),Vector2(-28,y+4),Color("#ae975e"),1.2)
 ground_rect(Rect2(-12,-90,188,243),Color("#5a5c50"),18000)
 # North sheds are separate businesses behind the exchange, not copied map props.
 backdrop_shop(Rect2(22,-57,43,28),"CALDER COLD STORAGE",true)
 backdrop_shop(Rect2(80,-53,57,27),"NORTH BAY FREIGHT",false)
 backdrop_shop(Rect2(28,91,35,24),"RAIL MAINTENANCE",true)
 backdrop_shop(Rect2(110,97,43,28),"PARKER LOGISTICS",false)
 # West receiving lane connects to the public road at the south entrance.
 ground_rect(Rect2(2,-90,22,243),Color("#2d3333"),8200)
 ground_rect(Rect2(-44,62,220,12),Color("#303636"),5000)
 ground_rect(Rect2(24,0,140,62),Color("#66685c"),16000)
 for x in range(25,165,8):ground_line(Vector2(x,1),Vector2(x,61),Color(.15,.20,.18,.22),.7)
 for y in range(2,63,7):ground_line(Vector2(24,y),Vector2(164,y),Color(.15,.20,.18,.22),.7)
 for i in range(55):
  var at=Vector2(rng.randf_range(25,163),rng.randf_range(1,61))
  for j in range(3):
   var end=at+Vector2(rng.randf_range(.4,1.3),rng.randf_range(-.4,.4));ground_line(at,end,Color(.12,.15,.14,.35),.8);at=end
 # Track ballast / ties / two polished steel rails. Rails never block crossings.
 for y in Freight.TRACKS:
  ground_rect(Rect2(24,y-4,152,8),Color("#414944"),6000)
  for x in range(24,177,2):
   ground_rect(Rect2(x,y-3.2,1.0,6.4),Color("#454238"))
   ground_line(Vector2(x+.1,y-3),Vector2(x+.1,y+3),Color("#82745a"),1.)
  for sy in [y-1.95,y+1.95]:
   ground_line(Vector2(24,sy+.28),Vector2(176,sy+.28),Color("#222c2b"),3.)
   ground_line(Vector2(24,sy),Vector2(176,sy),Color("#a8aaa0"),1.5)
   ground_line(Vector2(24,sy-.2),Vector2(176,sy-.2),Color("#d0caba"),.55)
  # End-of-line stops remain outside the combat perimeter.
  for sy in [y-2,y+2]:
   ground_rect(Rect2(169,sy-1,1.4,2),Color("#35433d"));ground_line(Vector2(169,sy),Vector2(171.5,y),Color("#9b8151"),2.)
  ground_line(Vector2(170,y-3),Vector2(170,y+3),Color("#bca36c"),3.)
 # Flush timber infill only at each rail bed; the connecting concrete is the yard.
 # Broken edges, ballast and old tyre scuffs replace clean painted rectangles.
 for cross in Freight.CROSSINGS:
  for y in Freight.TRACKS:
   var left=cross.position.x;var right=cross.end.x
   for yy in range(int(y)-4,int(y)+5):
    var inset=rng.randf_range(-.32,.30)
    var box=Rect2(left+inset,yy+.06,right-left-inset+rng.randf_range(-.30,.18),.83)
    ground_rect(box,Color("#666858") if yy%2 else Color("#797866"),12)
    ground_line(Vector2(box.position.x+.2,yy+.2),Vector2(box.end.x-.2,yy+.2),Color("#979079"),.65)
    for x in [left+.7,right-.7]:ground_rect(Rect2(x,yy+.42,.10,.10),Color("#343d37"))
   for sy in [y-1.95,y+1.95]:
    ground_line(Vector2(left-.35,sy+.23),Vector2(right+.35,sy+.23),Color("#252e2c"),3.)
    ground_line(Vector2(left-.35,sy),Vector2(right+.35,sy),Color("#a4ada6"),1.2)
   for edge in [left,right]:
    for j in range(32):
     var at=Vector2(edge+rng.randf_range(-.6,.35),y+rng.randf_range(-4.6,4.6))
     ground_rect(Rect2(at,Vector2(rng.randf_range(.08,.23),rng.randf_range(.1,.24))),Color("#454e45"))
  for x in [cross.position.x+cross.size.x*.3,cross.position.x+cross.size.x*.7]:
   for y in range(18,56):
    if rng.randf()<.22:continue
    ground_line(Vector2(x+rng.randf_range(-.12,.12),y),Vector2(x,y+.6),Color(.18,.22,.20,.14),2.)
 # Shallow irregular puddles collect beside rails and apron joints.
 for spec in [[34.,35.,6.,1.5],[78.,40.,3.,1.7],[113.,32.,3.,1.2],[53.,21.,8.,.7],[89.,53.,10.,1.1],[146.,57.,7.,1.8],[27.,70.,5.,.9],[120.,70.,11.,.6],[153.,19.8,5.,.5]]:
  var center=Vector2(spec[0],spec[1])*Vector2(8,6);var extent=Vector2(spec[2],spec[3])*Vector2(8,6);var outline=[]
  for n in range(16):
   var angle=float(n)*TAU/16.;outline.append(center+Vector2(cos(angle),sin(angle))*extent*rng.randf_range(.72,1.))
  poly(outline,Color("#3c5054"))
  for n in range(9):
   var shift=Vector2(rng.randf_range(-extent.x*.6,extent.x*.6),rng.randf_range(-extent.y*.6,extent.y*.6))
   l(center+shift,center+shift+Vector2(rng.randf_range(3,12),0),Color(.60,.69,.66,.22),.7)
 # Low loading platforms, forklift aprons and worn lane markings.
 for area in [Rect2(50,10,55,9),Rect2(55,55,52,8),Rect2(126,18,35,4)]:
  ground_rect(area,Color("#727466"),700)
 for x in range(28,164,12):ground_line(Vector2(x,72),Vector2(x+6,72),Color("#a29970"),1.)
 for y in range(-80,152,12):ground_line(Vector2(22,y),Vector2(22,y+6),Color("#b1a173"),1.)
 # Receiving road has no painted arrival bays. Loose wear and wet tracks remain.
 for y in [18.,41.,66.]:
  for j in range(10):
   var at=Vector2(rng.randf_range(7,22),y+rng.randf_range(-3,3))
   ground_line(at,at+Vector2(rng.randf_range(.2,1.),rng.randf_range(.6,1.5)),Color(.07,.10,.10,.10),1.1)
 # Perimeter fencing is outside playable bounds, visibly interrupted at access roads.
 for box in [Rect2(25,-2,139,.5),Rect2(166,0,.5,61),Rect2(25,78,139,.5)]:yard_fence(box.position*Vector2(8,6),box.size*Vector2(8,6))
 for at in [Vector2(25,-2),Vector2(110,-2),Vector2(165,16),Vector2(165,58),Vector2(27,78),Vector2(108,78),Vector2(70,12),Vector2(96,57)]:lamp(at*Vector2(8,6))
 # Small weeds gather at unused edges and cracks, not evenly over the concrete.
 for i in range(500):
  var at=Vector2(rng.randf_range(24,169),[-4.,79.][i%2]+rng.randf_range(-1.5,1.5))*Vector2(8,6)
  l(at,at+Vector2(rng.randf_range(-2,2),-rng.randf_range(1,4)),Color("#687350"),.9)
func railcar(q: Vector2,sz: Vector2,title: String,timber: bool):
 var h=26.;var color=[Color("#825548"),Color("#56675b"),Color("#777363")][absi(title.hash())%3]
 shadow(q,sz,9.)
 # Two bogies, axles, steel underframe, and couplers lie within the physical body.
 for x in [sz.x*.18,sz.x*.82]:
  for dx in [-6.,6.]:
   oval(q+Vector2(x+dx,sz.y-3),Vector2(5.3,5.1),Color("#1f2927"));oval(q+Vector2(x+dx,sz.y-3),Vector2(2.6,2.5),Color("#68716a"));oval(q+Vector2(x+dx,sz.y-3),Vector2(1.1,1.2),Color("#2d3b35"))
  r(Rect2(q+Vector2(x-12,sz.y-10),Vector2(24,5)),Color("#384840"))
 r(Rect2(q+Vector2(1,sz.y-12),Vector2(sz.x-2,6)),Color("#38443d"))
 for x in [1.,sz.x-5.]:r(Rect2(q+Vector2(x,sz.y*.52-4),Vector2(4,5)),Color("#566055"))
 var top=q-Vector2(0,h);var front=q+Vector2(0,sz.y-h-7)
 if timber:
  r(Rect2(top+Vector2(0,20),sz),Color("#565c48"))
  for y in range(4,int(sz.y)+8,6):
   r(Rect2(top+Vector2(5,y),Vector2(sz.x-10,5)),Color("#aa8b5a"));l(top+Vector2(5,y),top+Vector2(sz.x-5,y),Color("#d4b279"),1.)
   for i in range(7):
    var x=rng.randf_range(6,sz.x-7);l(top+Vector2(x,y+2),top+Vector2(minf(x+14,sz.x-5),y+2),Color("#786a47"),.7)
  for x in [12.,sz.x*.35,sz.x*.65,sz.x-13.]:l(top+Vector2(x,2),top+Vector2(x,sz.y+7),Color("#3f4d46"),3.)
 else:
  r(Rect2(top,sz+Vector2(0,h-9)),Color("#303d37"))
  r(Rect2(top+Vector2(1,1),sz-Vector2(2,0)),color.lightened(.20))
  r(Rect2(front,Vector2(sz.x,h-1)),color)
  for x in range(5,int(sz.x)-3,9):
   l(top+Vector2(x,2),top+Vector2(x,sz.y-1),color.lightened(.32),1.)
   l(front+Vector2(x,1),front+Vector2(x,h-3),color.darkened(.30),1.4)
  # Recessed sliding door and runners, rather than a featureless colored slab.
  var door=Rect2(front+Vector2(sz.x*.39,2),Vector2(sz.x*.24,h-5))
  r(door.grow(1),Color("#303d37"));r(door,color.darkened(.14))
  for x in range(3,int(door.size.x)-1,5):l(door.position+Vector2(x,1),door.position+Vector2(x,door.size.y-1),color.lightened(.08),1.)
  l(door.position-Vector2(3,2),door.position+Vector2(door.size.x+3,-2),Color("#bbb294"),1.2)
  r(Rect2(door.position+Vector2(door.size.x-6,7),Vector2(2,7)),Color("#b1b2a0"))
  label(front+Vector2(10,13),title,6,Color("#d1c5a0"))
  label(front+Vector2(sz.x-38,17),"LOAD  60T",4,Color("#c1b794"))
  for x in [3.,sz.x-5.]:
   l(front+Vector2(x,1),front+Vector2(x,h-3),Color("#b0a187"),1.)
   for y in [5.,10.,15.,20.]:l(front+Vector2(x-2,y),front+Vector2(x+2,y),Color("#aa9b81"),.8)
  grain(Rect2(front,Vector2(sz.x,h-2)),220,true)
  for i in range(20):
   var at=front+Vector2(rng.randf_range(2,sz.x-3),rng.randf_range(1,h-4))
   r(Rect2(at,Vector2(rng.randf_range(1,3),1)),Color("#b98a62"))
 l(q+Vector2(2,sz.y-7),q+Vector2(sz.x-2,sz.y-7),Color("#8c8c73"),1.)
func loading_platform(q: Vector2,sz: Vector2,title: String):
 shadow(q,sz,4.)
 r(Rect2(q,sz),Color("#52594f"));r(Rect2(q-Vector2(0,6),sz),Color("#a3a58e"))
 grain(Rect2(q-Vector2(0,6),sz),180,true)
 for x in range(3,int(sz.x)-4,14):
  l(q+Vector2(x,sz.y-5),q+Vector2(x+6,sz.y-5),Color("#c1ac68"),3.)
  l(q+Vector2(x+6,sz.y-5),q+Vector2(x+11,sz.y-5),Color("#3e4a41"),3.)
 for x in range(20,int(sz.x)-12,48):
  r(Rect2(q+Vector2(x,sz.y-3),Vector2(8,3)),Color("#283a31"))
 label(q+Vector2(6,sz.y-10),"LOADING  "+title,6,Color("#4a584b"))
func dispatch(q: Vector2,sz: Vector2,title: String,main: bool):
 var h=37. if main else 27.;var front=q+Vector2(0,sz.y-h)
 shadow(q,sz,12.)
 r(Rect2(q-Vector2(0,h),sz+Vector2(0,h)),Color("#48544b"))
 r(Rect2(front,Vector2(sz.x,h)),Color("#817c62"))
 for y in range(5,int(h),6):
  l(front+Vector2(1,y),front+Vector2(sz.x-1,y),Color("#625f4c"),.7)
  for x in range(4 if y%12 else 10,int(sz.x),14):l(front+Vector2(x,y-5),front+Vector2(x,y),Color("#67634d"),.7)
 # Sheet-metal pitched roof with eaves, seams and weathered vent.
 var top=q-Vector2(0,h)
 r(Rect2(top-Vector2(3,3),sz+Vector2(6,4)),Color("#4b5c53"))
 for x in range(2,int(sz.x)+2,7):l(top+Vector2(x,0),top+Vector2(x,sz.y-2),Color("#7c8872"),.8)
 l(top-Vector2(3,3),top+Vector2(sz.x+3,-3),Color("#a7ac91"),1.)
 l(top+Vector2(-3,sz.y),top+Vector2(sz.x+3,sz.y),Color("#293c33"),3.)
 var door=front+Vector2(sz.x*.44,12)
 r(Rect2(door-Vector2(2,2),Vector2(23,h-9)),Color("#b7ac89"));r(Rect2(door,Vector2(19,h-11)),Color("#283b33"))
 l(door,door+Vector2(0,h-11),Color("#4c594a"),2.);r(Rect2(door+Vector2(15,h-21),Vector2(2,2)),Color("#cbb984"))
 for x in [14.,sz.x-43.]:
  r(Rect2(front+Vector2(x,13),Vector2(25,15)),Color("#a6a18b"));r(Rect2(front+Vector2(x+2,15),Vector2(21,10)),Color("#344d47"))
  l(front+Vector2(x+3,16),front+Vector2(x+19,16),Color("#839c8f"),1.);l(front+Vector2(x+12,15),front+Vector2(x+12,25),Color("#889581"),1.)
 r(Rect2(front+Vector2(4,0),Vector2(sz.x-8,11)),Color("#233b34"))
 var sign_size=9 if main else 7
 while sign_size>5 and font.get_string_size(title,HORIZONTAL_ALIGNMENT_LEFT,-1,sign_size).x>sz.x-16:sign_size-=1
 label(front+Vector2(8,9),title,sign_size,Color("#e1cea0"))
func cargo(q: Vector2,sz: Vector2):
 shadow(q,sz,5.);r(Rect2(q-Vector2(0,11),sz+Vector2(0,11)),Color("#5b513a"));r(Rect2(q-Vector2(0,11),sz),Color("#ac9468"));r(Rect2(q+Vector2(0,sz.y-11),Vector2(sz.x,11)),Color("#8b744e"))
 for y in range(-9,int(sz.y)-11,4):l(q+Vector2(2,y),q+Vector2(sz.x-2,y),Color("#c6aa79"),.9)
 for x in [4.,sz.x-6.]:l(q+Vector2(x,-10),q+Vector2(x,sz.y-1),Color("#3c4d44"),2.)
 l(q+Vector2(6,sz.y-2),q+Vector2(sz.x-7,sz.y-10),Color("#b99a69"),2.)
func cable_reel(q: Vector2,sz: Vector2):
 shadow(q,sz,4.)
 var center=q+sz*.5;var half=sz*.48
 oval(center+Vector2(0,2),half,Color("#665637"));r(Rect2(center-Vector2(half.x*.67,9),Vector2(half.x*1.34,11)),Color("#34443d"))
 for x in range(-6,7,2):l(center+Vector2(x,-8),center+Vector2(x,1),Color("#637368"),1.)
 oval(center-Vector2(0,10),half,Color("#b39864"));oval(center-Vector2(0,10),half*.18,Color("#34473c"))
 for x in [-5.,5.]:l(center+Vector2(x,-10-half.y*.75),center+Vector2(x,-10+half.y*.75),Color("#807047"),.8)
func concrete_stop(q: Vector2,sz: Vector2):
 shadow(q,sz,3.);r(Rect2(q,sz),Color("#626b5e"))
 poly([q+Vector2(0,sz.y),q+Vector2(3,-7),q+Vector2(sz.x-3,-7),q+sz],Color("#9eaa96"))
 l(q+Vector2(3,-7),q+Vector2(sz.x-3,-7),Color("#c2c8ae"),1.3)
 for x in range(7,int(sz.x)-6,10):r(Rect2(q+Vector2(x,0),Vector2(4,3)),Color("#beaa65"))
 grain(Rect2(q,sz),40,true)
