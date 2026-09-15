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
func yard_ground():
 r(Rect2(PLATE_ORIGIN,Vector2(4096,2304)),Color("#343833"))
 grain(Rect2(PLATE_ORIGIN,Vector2(4096,2304)),65000,true)
 # The district continues well beyond the combat bounds, including the intro view.
 for row in range(-3,5):
  var y=row*190.-70.
  r(Rect2(-1536,y+135,4096,43),Color("#252c2d"))
  for x in range(-1400,2500,175):
   if row==0 and x>-90 and x<790:continue
   var area=Rect2(x+rng.randf_range(-8,8),y,138+rng.randf_range(-10,22),112)
   r(area.grow(7),Color("#4d4b3f"));grain(area,150)
   warehouse(area.position+Vector2(7,10),area.size-Vector2(14,40),row%2==0)
   for n in range(5):
    var at=area.position+Vector2(rng.randf()*area.size.x,area.size.y-12)
    oval(at,Vector2(5,2),Color("#353a2d"))
 # Two street axes, curb strips and drainage. No driveway lip into the road.
 r(Rect2(-1536,282,4096,102),Color("#242c2e"))
 r(Rect2(8,-960,176,1242),Color("#2a3030"))
 grain(Rect2(-1536,282,4096,102),14000)
 grain(Rect2(8,-960,176,1242),5500)
 for x in range(-1520,2550,32):
  if x>0 and x<195:continue
  r(Rect2(x,331,18,1.5),Color("#a18c58"));r(Rect2(x,335,18,1.5),Color("#a18c58"))
 for y in range(-940,273,30):
  r(Rect2(93,y,1.5,16),Color("#a18c58"));r(Rect2(98,y,1.5,16),Color("#a18c58"))
 r(Rect2(-1536,278,1544,4),Color("#8e8871"));r(Rect2(184,-960,5,1227),Color("#89826a"))
 r(Rect2(0,-960,8,1240),Color("#58594d"))
 r(Rect2(208,270,560,12),Color("#716b58"));grain(Rect2(208,270,560,12),900)
 r(Rect2(544,252,112,30),Color("#716b58"))
 for x in range(210,768,22):
  if x>=544 and x<=656:continue
  l(Vector2(x,274),Vector2(x,282),Color("#4e534a"),.7)
 for x in [182.,520.,702.]:
  r(Rect2(x,283,15,5),Color("#151d21"))
  for j in range(2,15,3):l(Vector2(x+j,284),Vector2(x+j,287),Color("#676957"),1.)
 # Cracked concrete yard, old workshop slabs and oily standing water.
 var yard=Rect2(208,30,560,240)
 r(yard,Color("#62614f"));grain(yard,15500)
 for y in range(35,270,24):l(Vector2(212,y),Vector2(761,y),Color(.20,.24,.21,.19),.7)
 for x in range(218,770,32):l(Vector2(x,31),Vector2(x,268),Color(.20,.24,.21,.20),.7)
 for i in range(36):
  var at=Vector2(rng.randf_range(210,761),rng.randf_range(116,269))
  var pts=[at,at+Vector2(6,2),at+Vector2(13,-2),at+Vector2(19,3)]
  for j in range(1,pts.size()):l(pts[j-1],pts[j],Color(.13,.20,.18,.38),.65)
 for spec in [[306.,201.,23.,7.],[507.,217.,29.,5.],[593.,183.,20.,7.],[263.,154.,14.,4.]]:
  var at=Vector2(spec[0],spec[1]);oval(at,Vector2(spec[2],spec[3]),Color("#414b45"))
  l(at+Vector2(-9,-1),at+Vector2(8,-1),Color("#7d7762"),.8)
 # Main gate's apron joins the access street flush; service drive joins the curb.
 r(Rect2(184,156,44,84),Color("#666350"));grain(Rect2(184,156,44,84),350)
 for x in [553.,646.]:l(Vector2(x,251),Vector2(x,281),Color("#aba077"),1.3)
 # Painted work bays stop short of pedestrian routes and gates.
 for x in [300.,412.,575.,680.]:
  for y in [132.,170.]:l(Vector2(x,y),Vector2(x+58,y),Color("#95896b"),1.)
  l(Vector2(x,132),Vector2(x,170),Color("#95896b"),1.)
 label(Vector2(557,268),"KEEP CLEAR",7,Color("#b4a478"))
 # Sparse rubbish, wheel tracks, hose loops and weeds; nothing masquerades as cover.
 for i in range(100):
  var at=Vector2(rng.randf_range(213,758),rng.randf_range(110,266))
  if i%3==0:r(Rect2(at,Vector2(2,1)),Color("#b0a58a"))
  else:l(at,at+Vector2(2,-2),Color("#4d5035"),1.)
 for at in [Vector2(366,138),Vector2(454,225),Vector2(722,177)]:
  draw_arc(at,6,0,TAU,20,Color("#303c38"),1.5,false)
  l(at+Vector2(5,3),at+Vector2(15,7),Color("#303c38"),1.3)
 for y in [192.,199.]:
  l(Vector2(138,y+29),Vector2(215,y),Color(.10,.14,.12,.22),1.5)
 # Sodium pools at working doors and amber street lamps. Subtle, readable ground.
 for spec in [[219.,154.,46.,21.],[606.,138.,53.,24.],[659.,273.,30.,14.],[143.,258.,41.,17.]]:
  for k in range(12,0,-1):oval(Vector2(spec[0],spec[1]),Vector2(spec[2],spec[3])*float(k)/12.,Color(.95,.64,.24,.007))
 # Foreground row establishes the opposite side of the street, with no combat there.
 for x in range(-1300,2500,162):warehouse(Vector2(x,426),Vector2(143,86),x%3==0)
 for at in [Vector2(193,111),Vector2(205,274),Vector2(739,279)]:lamp(at)
 # Attached frontage plaque and low power lines remain scenery at the perimeter.
 for x in range(-1100,2300,185):
  var at=Vector2(x,-30)
  l(at,at-Vector2(0,57),Color("#443d30"),3.)
  l(at+Vector2(-11,-50),at+Vector2(12,-50),Color("#80735c"),2.)
  for j in range(16):
   var t=float(j)/16.;var u=float(j+1)/16.
   l(at+Vector2(t*185,-51+sin(t*PI)*10),at+Vector2(u*185,-51+sin(u*PI)*10),Color("#222c2a"),.8)
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
