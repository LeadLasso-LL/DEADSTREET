extends "res://gameplay/whittaker_estate_art.gd"
## Retained drawn scenery, sharing the map's physical footprints and fleet art.
const Yard=preload("res://battle/geometry/doble_ocho_catalog.gd")
const PLATE="res://assets/art/doble_ocho/ground.png"
const PLATE_ORIGIN=Vector2(-1536,-960)
static var yard_plate: Texture2D
func _ready():
 texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 font=SystemFont.new();font.font_names=PackedStringArray(["Arial"]);font.font_weight=700
 set_process(not prop.is_empty() and prop[2]=="container")
 if prop.is_empty() and not bake_mode and yard_plate==null and FileAccess.file_exists(PLATE):
  var im=Image.new()
  if im.load_png_from_buffer(FileAccess.get_file_as_bytes(PLATE))==OK:yard_plate=ImageTexture.create_from_image(im)
func _process(delta):
 # Locally fade this solid container only when it obscures an actual actor.
 # Collision, shot blocking and ground positions remain authoritative.
 var target_alpha=1.
 if view!=null and is_instance_valid(view):
  var b=view._battle_state()
  if b!=null:
   var box: Rect2=prop[1]
   var screen_box=Rect2(box.position*Vector2(8,6)-Vector2(0,30),box.size*Vector2(8,6)+Vector2(0,30))
   for unit in b.participants.values():
    if not unit.has_battle_position or not unit.is_alive:continue
    var foot=unit.battle_position*Vector2(8,6)
    if foot.y>=position.y:continue
    var torso=Rect2(foot-Vector2(8,24),Vector2(16,23))
    if screen_box.intersects(torso):target_alpha=.28;break
 self_modulate.a=target_alpha if target_alpha<self_modulate.a else move_toward(self_modulate.a,target_alpha,delta*4.)
func _draw():
 rng.seed=917433 if prop.is_empty() else absi(str(prop[0]).hash())
 if prop.is_empty():
  if not bake_mode and yard_plate!=null:draw_texture(yard_plate,PLATE_ORIGIN)
  else:yard_ground()
  return
 var box: Rect2=prop[1];var q=p(box.position);var sz=box.size*Vector2(8,6)
 match prop[2]:
  "garage","workshop":shop(q,sz,prop[2]=="garage",str(prop[3]))
  "fence","gate":yard_fence(q,sz)
  "container":container_box(q,sz)
  "tires":tire_stack(q,sz)
  "compressor":compressor(q,sz)
  "pallets":pallets(q,sz)
  "drums":drums(q,sz)
  "dumpster":dumpster(q,sz)
  "bollard":bollard(q,sz)
  "traffic":
   var texture=Models.sprite(prop[3],prop[4],0.)
   if texture!=null:draw_texture_rect(texture,Rect2(Vector2(-64,-66)*Models.TACTICAL_SCALE,Vector2(128,96)*Models.TACTICAL_SCALE),false,Color("#c2bbb0"))
func label(q: Vector2,value: String,size_value: int,color: Color,width=-1.):
 draw_string(font,q,value,HORIZONTAL_ALIGNMENT_LEFT,width,size_value,color)
func ground_rect(box: Rect2,color: Color,rough=0):
 var projected=Rect2(box.position*Vector2(8,6),box.size*Vector2(8,6))
 r(projected,color)
 if rough>0:grain(projected,rough)
func ground_line(a: Vector2,b: Vector2,color: Color,width=1.):l(a*Vector2(8,6),b*Vector2(8,6),color,width)
func backdrop_shop(box: Rect2,title: String,green: bool):
 var q=box.position*Vector2(8,6);var sz=box.size*Vector2(8,6)
 ground_rect(box.grow(1.3),Color("#514f40"),400)
 warehouse(q,sz,green)
 r(Rect2(q+Vector2(5,sz.y-25),Vector2(sz.x-10,7)),Color("#283c34"))
 label(q+Vector2(8,sz.y-19),title,6,Color("#b8aa82"))
 # Patched brick frontage, shutter seams and a pavement threshold.
 l(q+Vector2(0,sz.y+1),q+Vector2(sz.x,sz.y+1),Color("#95896c"),2.)
 for x in range(9,27,3):l(q+Vector2(x,sz.y-19),q+Vector2(x,sz.y-4),Color("#52614f"),.7)
func yard_ground():
 r(Rect2(PLATE_ORIGIN,Vector2(4096,2304)),Color("#353a32"));grain(Rect2(PLATE_ORIGIN,Vector2(4096,2304)),46000,true)
 # Distant roofs stay irregular and subdued; the visible block is individually authored below.
 for i in range(65):
  var q=Vector2(rng.randf_range(-1500,2450),rng.randf_range(-920,1200))
  if Rect2(-530,-340,1830,1060).has_point(q):continue
  var sz=Vector2(rng.randf_range(78,200),rng.randf_range(65,132))
  r(Rect2(q-Vector2(9,9),sz+Vector2(18,26)),Color("#41443a"));warehouse(q,sz,i%3==0)
 # Back service lane, connected shop plots and a narrow eastern utility passage.
 ground_rect(Rect2(20,-51,118,51),Color("#4c4d3e"),4700)
 ground_rect(Rect2(20,-11,130,9),Color("#393f35"),1700)
 ground_rect(Rect2(113,-11,8,62),Color("#454839"),1500)
 backdrop_shop(Rect2(27,-41,29,27),"FRONTERA MACHINE",false)
 backdrop_shop(Rect2(62,-47,34,32),"SOTO BODYWORK",true)
 backdrop_shop(Rect2(102,-38,29,24),"ACE REFRIGERATION",false)
 ground_rect(Rect2(30,-12,11,2),Color("#6d6954"),60)
 ground_rect(Rect2(81,-12,10,2),Color("#68694f"),60)
 # The far side of the access street belongs to a poor mixed commercial block.
 ground_rect(Rect2(-55,-49,48,97),Color("#575344"),4300)
 backdrop_shop(Rect2(-50,-43,39,28),"MERCER AUTO ELECTRIC",true)
 backdrop_shop(Rect2(-43,-8,32,24),"LA ESQUINA / ABARROTES",false)
 ground_rect(Rect2(-48,21,39,25),Color("#42473b"),2000)
 for x in [-45.,-34.,-23.]:
  ground_line(Vector2(x,25),Vector2(x,42),Color("#887c5f"),.8)
  ground_line(Vector2(x,42),Vector2(x+9,42),Color("#887c5f"),.8)
 # Opposite pavement has storefronts and a loading recess, not an identical warehouse row.
 ground_rect(Rect2(-58,73,204,66),Color("#504d3f"),6000)
 backdrop_shop(Rect2(-50,82,34,26),"PAWN / TOOLS",false)
 backdrop_shop(Rect2(-7,86,33,28),"MENDOZA UPHOLSTERY",true)
 backdrop_shop(Rect2(36,78,29,31),"USED PARTS",false)
 backdrop_shop(Rect2(76,87,44,29),"SOUTHSIDE SUPPLY",true)
 ground_rect(Rect2(76,75,44,10),Color("#3d4439"),1200)
 ground_line(Vector2(80,77),Vector2(115,77),Color("#8b8061"),1.)
 ground_line(Vector2(119,76),Vector2(119,84),Color("#8b8061"),1.)
 # Road dimensions match the authored navigation surfaces: 20-wide west / 17-wide south.
 ground_rect(Rect2(-192,51,512,17),Color("#252d2d"),17000)
 ground_rect(Rect2(0,-160,20,211),Color("#293030"),7300)
 # Continuous five/six-unit pedestrian sidewalks connect around the yard corner.
 for box in [Rect2(-192,45.7,192,5.3),Rect2(20,45.7,300,5.3),Rect2(-192,68,512,5),Rect2(-5,-160,5,211),Rect2(20,-160,6,205.7)]:
  ground_rect(box,Color("#969fa3"),1800)
 for x in range(-190,320,6):
  if x<0 or x>20:ground_line(Vector2(x,46),Vector2(x,50.8),Color("#535f64"),1.8)
  ground_line(Vector2(x,68.3),Vector2(x,72.8),Color("#535f64"),1.8)
 for y in range(-158,46,6):
  ground_line(Vector2(-4.8,y),Vector2(-.2,y),Color("#535f64"),1.8)
  if y<26 or y>40:ground_line(Vector2(20.2,y),Vector2(25.8,y),Color("#535f64"),1.8)
 for pair in [[Vector2(-192,50.8),Vector2(0,50.8)],[Vector2(20,50.8),Vector2(88,50.8)],[Vector2(102,50.8),Vector2(320,50.8)],[Vector2(-192,68.2),Vector2(320,68.2)],[Vector2(.1,-160),Vector2(.1,51)],[Vector2(20,-160),Vector2(20,26)],[Vector2(20,40),Vector2(20,50.8)]]:
  var a: Vector2=pair[0];var b: Vector2=pair[1]
  ground_line(a,b,Color("#b5bec0"),2.);ground_line(a+Vector2(0,.35),b+Vector2(0,.35),Color("#566268"),.8)
 for x in range(-190,320,6):
  if x>-1 and x<24:continue
  ground_line(Vector2(x,59.3),Vector2(x+3,59.3),Color("#9d8a56"),1.2)
  ground_line(Vector2(x,59.9),Vector2(x+3,59.9),Color("#9d8a56"),1.2)
 for y in range(-156,49,6):
  ground_line(Vector2(9.7,y),Vector2(9.7,y+3),Color("#9d8a56"),1.2)
  ground_line(Vector2(10.3,y),Vector2(10.3,y+3),Color("#9d8a56"),1.2)
 for at in [Vector2(21,51.2),Vector2(64,51.2),Vector2(107,51.2),Vector2(42,67.2)]:
  ground_rect(Rect2(at,Vector2(2.8,.6)),Color("#172822"))
  for x in range(1,7):ground_line(at+Vector2(x*.35,.1),at+Vector2(x*.35,.5),Color("#777c64"),.8)
 # The wider working yard has worn concrete joints, patches and oil, not stretched props.
 var yard=Rect2(26,5,86,40);ground_rect(yard,Color("#62614f"),19500)
 for y in range(6,45,4):ground_line(Vector2(26.4,y),Vector2(111.6,y),Color(.20,.24,.21,.20),.7)
 for x in range(27,112,4):ground_line(Vector2(x,5),Vector2(x,44.7),Color(.20,.24,.21,.20),.7)
 for i in range(46):
  var at=Vector2(rng.randf_range(211,891),rng.randf_range(117,268))
  for j in range(3):
   var end=at+Vector2(rng.randf_range(4,8),rng.randf_range(-3,3));l(at,end,Color(.13,.20,.18,.4),.65);at=end
 for box in [Rect2(27.3,40.9,7.2,4),Rect2(58,23,15,3.5),Rect2(77,36,10,5),Rect2(103,24,7,7)]:ground_rect(box,Color("#686753"),130)
 # Dumpster now sits on the interior waste pad, clear of both roads and sidewalks.
 # Aprons cross pedestrian paths at dropped curbs and stop flush at the road edges.
 ground_rect(Rect2(20,26,12.5,14),Color("#8a9497"),620)
 ground_rect(Rect2(88,42,14,9),Color("#8a9497"),700)
 ground_line(Vector2(20,26),Vector2(20,40),Color("#b0b8ba"),1.)
 ground_line(Vector2(88,50.8),Vector2(102,50.8),Color("#b0b8ba"),1.)
 for y in [27.,39.]:ground_line(Vector2(20.2,y),Vector2(25.7,y),Color("#b1a27c"),1.)
 for x in [89.,101.]:ground_line(Vector2(x,43),Vector2(x,50.6),Color("#b1a27c"),1.)
 label(Vector2(720,266),"KEEP CLEAR",7,Color("#b4a478"))
 for at in [Vector2(44,22),Vector2(69,29),Vector2(96,27),Vector2(43,39),Vector2(70,42),Vector2(104,38)]:
  oval(at*Vector2(8,6),Vector2(26,6),Color(.13,.20,.16,.22))
 for box in [Rect2(38,20,12,5),Rect2(63,25,12,6),Rect2(89,24,13,6)]:
  ground_line(box.position,box.position+Vector2(box.size.x,0),Color("#95896b"),1.)
  ground_line(box.position,box.position+Vector2(0,box.size.y),Color("#95896b"),1.)
 for i in range(110):
  var at=Vector2(rng.randf_range(215,887),rng.randf_range(119,267))
  if i%3==0:r(Rect2(at,Vector2(2,1)),Color("#b0a58a"))
  else:l(at,at+Vector2(2,-2),Color("#4d5035"),1.)
 for at in [Vector2(390,143),Vector2(609,220),Vector2(844,182)]:
  draw_arc(at,6,0,TAU,20,Color("#303c38"),1.5,false);l(at+Vector2(5,3),at+Vector2(15,7),Color("#303c38"),1.3)
 # Background fleet remains wholly outside combat bounds; it cannot imply false tactical cover.
 for spec in [[-36.,34.,"rattleback",Vector2.UP],[-17.,32.,"workhorse",Vector2.DOWN],[84.,-6.,"courier",Vector2.RIGHT],[93.,81.,"rattleback",Vector2.RIGHT]]:
  var texture=Models.sprite(spec[2],spec[3],0.)
  if texture!=null:draw_texture_rect(texture,Rect2(Vector2(spec[0]*8,spec[1]*6)+Vector2(-64,-66)*Models.TACTICAL_SCALE,Vector2(128,96)*Models.TACTICAL_SCALE),false,Color("#aaa58d"))
 # Backlot boundaries, refuse, weeds and service poles visually connect the blocks.
 for box in [Rect2(-51,20,1,26),Rect2(121,-10,.5,53),Rect2(27,-13,28,.4),Rect2(123,77,.5,39)]:yard_fence(box.position*Vector2(8,6),box.size*Vector2(8,6))
 for at in [Vector2(-48,41),Vector2(126,37),Vector2(117,-8)]:
  pallets(at*Vector2(8,6),Vector2(21,13));tire_stack((at+Vector2(3,1))*Vector2(8,6),Vector2(18,13))
 for i in range(90):
  var at=Vector2(rng.randf_range(-390,1030),rng.randf_range(-65,-10))
  oval(at,Vector2(3,1.2),Color("#596047"))
 for spec in [[219.,154.,46.,21.],[729.,138.,53.,24.],[819.,290.,30.,14.],[143.,290.,41.,17.]]:
  for k in range(12,0,-1):oval(Vector2(spec[0],spec[1]),Vector2(spec[2],spec[3])*float(k)/12.,Color(.95,.64,.24,.007))
 for at in [Vector2(187,103),Vector2(201,298),Vector2(853,297),Vector2(-33,434),Vector2(729,434)]:lamp(at)
 for x in range(-480,1260,210):
  var at=Vector2(x,-30)
  l(at,at-Vector2(0,57),Color("#443d30"),3.);l(at+Vector2(-11,-50),at+Vector2(12,-50),Color("#80735c"),2.)
  for j in range(16):
   var t=float(j)/16.;var u=float(j+1)/16.
   l(at+Vector2(t*210,-51+sin(t*PI)*10),at+Vector2(u*210,-51+sin(u*PI)*10),Color("#222c2a"),.8)

func warehouse(q: Vector2,sz: Vector2,green: bool):
 shadow(q,sz,12.)
 r(Rect2(q,sz),Color("#47493f"));r(Rect2(q,Vector2(sz.x,sz.y-23)),Color("#555949") if green else Color("#5c5648"))
 for x in range(4,int(sz.x)-3,7):l(q+Vector2(x,3),q+Vector2(x,sz.y-25),Color("#6e6a56"),.7)
 r(Rect2(q+Vector2(7,sz.y-21),Vector2(23,18)),Color("#28332f"))
 for x in range(38,int(sz.x)-17,26):r(Rect2(q+Vector2(x,sz.y-18),Vector2(17,9)),Color("#384a43"))
 r(Rect2(q+Vector2(sz.x*.58,10),Vector2(22,15)),Color("#333f3b"));r(Rect2(q+Vector2(sz.x*.58+2,8),Vector2(19,13)),Color("#727463"))
 for j in range(3):l(q+Vector2(sz.x*.58+5,11+j*3),q+Vector2(sz.x*.58+17,11+j*3),Color("#3c4b45"),1.)
func shop(q: Vector2,sz: Vector2,main: bool,title: String):
 var h=43. if main else 34.
 shadow(q,sz,12.)
 var front=q+Vector2(0,sz.y-h)
 r(Rect2(q-Vector2(0,h),sz+Vector2(0,h)),Color("#393e36"))
 r(Rect2(front,Vector2(sz.x,h)),Color("#8b8063") if main else Color("#747763"))
 r(Rect2(front+Vector2(0,h-12),Vector2(sz.x,12)),Color("#45574e"))
 for y in range(6,int(h)-2,7):
  l(front+Vector2(0,y),front+Vector2(sz.x,y),Color(.21,.24,.18,.23),.65)
  for x in range(6 if int(y/7)%2 else 0,int(sz.x),13):l(front+Vector2(x,y-6),front+Vector2(x,y),Color(.25,.25,.19,.24),.6)
 # Recessed garage shutters and open pedestrian doorway have actual jambs.
 var bays=3 if main else 2;var width=(sz.x-24)/float(bays)
 for i in range(bays):
  var at=front+Vector2(10+i*width,13);var bw=width-10
  r(Rect2(at-Vector2(2,2),Vector2(bw+4,h-11)),Color("#504e3d"))
  r(Rect2(at,Vector2(bw,h-13)),Color("#303e39"))
  r(Rect2(at+Vector2(2,1),Vector2(bw-4,h-15)),Color("#637064") if i!=1 or not main else Color("#242f2b"))
  if i!=1 or not main:
   for y in range(3,int(h)-14,3):l(at+Vector2(3,y),at+Vector2(bw-3,y),Color("#3f4e46"),.8)
   r(Rect2(at+Vector2(bw*.5-3,h-21),Vector2(6,2)),Color("#b5ad88"))
  else:
   r(Rect2(at+Vector2(2,1),Vector2(bw-4,6)),Color("#566354"))
   r(Rect2(at+Vector2(5,10),Vector2(14,h-24)),Color("#354a3b"))
   r(Rect2(at+Vector2(8,11),Vector2(8,5)),Color("#7b825c"))
   r(Rect2(at+Vector2(bw-22,13),Vector2(15,3)),Color("#9a855c"))
  l(at+Vector2(-2,h-12),at+Vector2(bw+2,h-12),Color("#afa486"),2.)
  r(Rect2(at+Vector2(bw*.5-4,-4),Vector2(8,2)),Color("#e8c176"))
 # Corrugated roof, metal ridge, patched sheets, vents and connected pipework.
 var roof=Rect2(q-Vector2(3,h+4),Vector2(sz.x+6,sz.y+5))
 r(roof,Color("#404e48"));r(Rect2(roof.position+Vector2(3,3),roof.size-Vector2(6,6)),Color("#5f6b60"))
 for x in range(5,int(roof.size.x)-3,5):
  l(roof.position+Vector2(x,3),roof.position+Vector2(x,roof.size.y-4),Color("#7a8270"),.8)
  l(roof.position+Vector2(x+1,3),roof.position+Vector2(x+1,roof.size.y-4),Color("#47564e"),.8)
 for i in range(16):
  var at=roof.position+Vector2(rng.randf_range(6,roof.size.x-9),rng.randf_range(5,roof.size.y-9))
  r(Rect2(at,Vector2(rng.randf_range(2,6),rng.randf_range(2,10))),Color(.37,.25,.15,.3))
 l(roof.position+Vector2(0,roof.size.y),roof.end,Color("#a39473"),2.)
 var hv=roof.position+Vector2(roof.size.x*.71,roof.size.y*.23)
 r(Rect2(hv+Vector2(3,5),Vector2(32,21)),Color("#34423c"));r(Rect2(hv,Vector2(30,21)),Color("#8b8e78"))
 r(Rect2(hv+Vector2(2,2),Vector2(26,15)),Color("#626f60"))
 for i in range(5):l(hv+Vector2(4,4+i*2.5),hv+Vector2(25,4+i*2.5),Color("#34473e"),1.3)
 l(hv+Vector2(0,13),hv-Vector2(22,-13),Color("#999983"),4.)
 for at in [roof.position+Vector2(24,16),roof.position+Vector2(65,32)]:
  oval(at+Vector2(3,4),Vector2(9,6),Color("#34433b"));r(Rect2(at-Vector2(4,10),Vector2(8,11)),Color("#687968"));oval(at-Vector2(0,10),Vector2(8,4),Color("#9c9d82"))
 # Business fascia, intentionally small enough to belong to the facade.
 var sign_at=front+Vector2(9,-2)
 r(Rect2(sign_at,Vector2(sz.x-18,13)),Color("#1f342e"))
 draw_rect(Rect2(sign_at,Vector2(sz.x-18,13)),Color("#9a8a58"),false,.8)
 label(sign_at+Vector2(5,9),title,8,Color("#d4c49a"))
 if main:label(sign_at+Vector2(sz.x-104,9),"REPAIR / PARTS",5,Color("#a7b198"))
 # Local ownership is a faded painted eight on the masonry, not a floating HUD label.
 label(front+Vector2(sz.x-9,h-4),"8",9,Color("#bfaa6e"))
func yard_fence(q: Vector2,sz: Vector2):
 var vertical=sz.y>sz.x;var end=q+(Vector2(0,sz.y) if vertical else Vector2(sz.x,0));var count=maxi(1,int(q.distance_to(end)/6))
 l(q+Vector2(2,2),end+Vector2(2,2),Color(.08,.13,.10,.4),4.)
 l(q,end,Color("#85836b"),3.);l(q-Vector2(0,3),end-Vector2(0,3),Color("#a6a083"),1.)
 for n in range(count):
  var a=q.lerp(end,float(n)/count);var b=q.lerp(end,float(n+1)/count)
  l(a-Vector2(0,17),b-Vector2(0,4),Color("#687264"),.6)
  l(a-Vector2(0,4),b-Vector2(0,17),Color("#687264"),.6)
 for height_value in [4.,18.]:l(q-Vector2(0,height_value),end-Vector2(0,height_value),Color("#a19c7f"),1.)
 for n in range(0,count+1,3):
  var at=q.lerp(end,float(n)/count)
  l(at,at-Vector2(0,21),Color("#3c4c43"),2.);l(at+Vector2(1,0),at+Vector2(1,-20),Color("#a8a68b"),.6)
func container_box(q: Vector2,sz: Vector2):
 shadow(q,sz,9.)
 r(Rect2(q-Vector2(0,30),sz+Vector2(0,30)),Color("#423e30"))
 r(Rect2(q-Vector2(0,30),sz),Color("#777252"))
 r(Rect2(q+Vector2(0,sz.y-30),Vector2(sz.x,30)),Color("#63563a"))
 for x in range(3,int(sz.x)-2,4):l(q+Vector2(x,-27),q+Vector2(x,sz.y-3),Color("#928263"),1.)
 for y in [-27.,sz.y-31.,sz.y-3.]:l(q+Vector2(1,y),q+Vector2(sz.x-1,y),Color("#ad9470"),1.2)
 for x in [5.,sz.x-7.]:l(q+Vector2(x,sz.y-27),q+Vector2(x,sz.y-3),Color("#3a4134"),2.)
 label(q+Vector2(5,sz.y-15),"08",8,Color("#c5b989"));grain(Rect2(q+Vector2(0,sz.y-29),Vector2(sz.x,27)),130,true)
func tire_stack(q: Vector2,sz: Vector2):
 shadow(q,sz,5.)
 for x in [sz.x*.28,sz.x*.73]:
  for k in range(3):
   var at=q+Vector2(x,sz.y*.55-k*3.)
   oval(at+Vector2(0,2),Vector2(6,4),Color("#202b28"));oval(at,Vector2(6,3),Color("#46524a"));oval(at,Vector2(3,1.5),Color("#162521"))
   l(at+Vector2(-4,-1),at+Vector2(-1,-2),Color("#7b8170"),.8)
func compressor(q: Vector2,sz: Vector2):
 shadow(q,sz,6.)
 r(Rect2(q+Vector2(2,0),sz-Vector2(4,0)),Color("#34433c"))
 r(Rect2(q-Vector2(0,14),sz+Vector2(0,10)),Color("#698075"))
 r(Rect2(q+Vector2(2,-13),sz-Vector2(4,0)),Color("#879184"))
 for y in range(-10,int(sz.y)-7,3):l(q+Vector2(4,y),q+Vector2(sz.x-4,y),Color("#455b50"),1.)
 r(Rect2(q+Vector2(2,sz.y-12),Vector2(6,5)),Color("#bb9158"))
func pallets(q: Vector2,sz: Vector2):
 shadow(q,sz,4.)
 for y in range(-1,int(sz.y)+2,4):r(Rect2(q+Vector2(0,y),Vector2(sz.x,2)),Color("#5f543c"))
 r(Rect2(q+Vector2(2,-8),sz-Vector2(4,0)),Color("#8b7953"))
 for x in [4.,sz.x-7.]:l(q+Vector2(x,-7),q+Vector2(x,sz.y-7),Color("#4b4e3d"),2.)
 for y in range(-6,int(sz.y)-7,4):l(q+Vector2(3,y),q+Vector2(sz.x-3,y),Color("#b39b6e"),.8)
func drums(q: Vector2,sz: Vector2):
 shadow(q,sz,5.)
 for dx in [sz.x*.27,sz.x*.74]:
  var at=q+Vector2(dx,sz.y*.6)
  r(Rect2(at-Vector2(4,11),Vector2(8,12)),Color("#677465"));oval(at,Vector2(4,2.4),Color("#4b594c"));oval(at-Vector2(0,11),Vector2(4,2.4),Color("#a8a98b"))
  l(at+Vector2(-4,-4),at+Vector2(4,-4),Color("#333f32"),1.);r(Rect2(at+Vector2(-2,-9),Vector2(2,9)),Color("#909b81"))
  r(Rect2(at+Vector2(1,-7),Vector2(2,3)),Color("#90684b"))
func dumpster(q: Vector2,sz: Vector2):
 shadow(q,sz,6.);r(Rect2(q-Vector2(0,12),sz+Vector2(0,12)),Color("#273c32"))
 r(Rect2(q+Vector2(1,-10),sz+Vector2(-2,7)),Color("#52674b"));r(Rect2(q-Vector2(2,14),Vector2(sz.x+4,sz.y)),Color("#6f7d5c"))
 for x in range(4,int(sz.x)-3,6):l(q+Vector2(x,-12),q+Vector2(x,sz.y-16),Color("#879271"),1.)
 r(Rect2(q+Vector2(5,sz.y-12),Vector2(10,5)),Color("#b2ad82"));label(q+Vector2(6,sz.y-8),"NB",4,Color("#475444"))
 for x in [3.,sz.x-7.]:r(Rect2(q+Vector2(x,sz.y-2),Vector2(4,3)),Color("#1e2a25"))
func bollard(q: Vector2,sz: Vector2):
 r(Rect2(q-Vector2(0,12),sz+Vector2(0,12)),Color("#9b884e"))
 r(Rect2(q+Vector2(0,-6),Vector2(sz.x,3)),Color("#344239"))
func lamp(at: Vector2):
 l(at,at-Vector2(0,47),Color("#2a3831"),2.5);l(at-Vector2(0,47),at+Vector2(11,-47),Color("#5b6757"),2.)
 r(Rect2(at+Vector2(7,-48),Vector2(11,3)),Color("#b7a372"));r(Rect2(at+Vector2(9,-46),Vector2(7,1.5)),Color("#e2c27c"))
