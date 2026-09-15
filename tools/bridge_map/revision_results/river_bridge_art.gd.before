extends Node2D
## Native authored scenery shares the exact 8×6 ground projection with Harold and units.
const C=preload("res://battle/geometry/river_bridge_catalog.gd")
const Models=preload("res://campaign/vehicles/vehicle_model_catalog.gd")
const INK=Color("#172226")
const GROUND_PATH="res://assets/art/bridge/river_ground.png"
static var ground_plate: Texture2D
var bake_mode=false
var prop: Array=[]
var view
var rng=RandomNumberGenerator.new()
var lettering: SystemFont
var upper_alpha=1.
var timer=0.
func _ready():
 texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 if prop.is_empty() and not bake_mode and ground_plate==null and FileAccess.file_exists(GROUND_PATH):
  var im=Image.new()
  if im.load_png_from_buffer(FileAccess.get_file_as_bytes(GROUND_PATH))==OK:ground_plate=ImageTexture.create_from_image(im)
 lettering=SystemFont.new();lettering.font_names=PackedStringArray(["Arial"]);lettering.font_weight=700
 set_process(not prop.is_empty() and prop[2]=="tower")
func p(at: Vector2) -> Vector2:return at*Vector2(8,6)-position
func r(at: Rect2,c: Color):draw_rect(at,c)
func l(a: Vector2,b: Vector2,c: Color,w=1.):draw_line(a,b,c,w,false)
func poly(points: Array,c: Color):draw_colored_polygon(PackedVector2Array(points),c)
func grain(box: Rect2,n: int):
 for i in range(n):
  var point=box.position+Vector2(rng.randf()*box.size.x,rng.randf()*box.size.y)
  r(Rect2(point,Vector2(1,1)),Color(.64,.65,.59,rng.randf_range(.025,.12)))
func _process(delta):
 timer+=delta
 if timer<.15:return
 timer=0.
 var next=.65 if prop[1].get_center().y>40 else 1.
 if view!=null and is_instance_valid(view):
  var b=view._battle_state()
  if b!=null:
   var base=p(prop[1].get_center())+position
   for unit in b.participants.values():
    if not unit.has_battle_position or not unit.is_alive:continue
    var at=unit.battle_position*Vector2(8,6)
    if absf(at.x-base.x)<23 and at.y<base.y-8 and at.y>base.y-282:next=.18;break
 if not is_equal_approx(next,upper_alpha):upper_alpha=next;queue_redraw()
func _draw():
 rng.seed=20340913
 if prop.is_empty():
  if not bake_mode and ground_plate!=null:
   r(Rect2(-2200,-1200,6000,2600),Color("#26373d"));draw_texture(ground_plate,Vector2(-768,-512))
  else:ground()
  return
 var kind=prop[2]
 if kind=="traffic":
  var texture=Models.sprite(prop[3],prop[4],0.)
  if texture!=null:draw_texture_rect(texture,Rect2(Vector2(-64,-66),Vector2(128,96)),false,Color("#b2b7b0"))
  return
 if kind=="cables":cables(47.7,.48);return
 var box: Rect2=prop[1];var q=p(box.position);var sz=box.size*Vector2(8,6)
 match kind:
  "tower":tower(q,sz,box.get_center().y)
  "cabinet":cabinet(q,sz)
  "barrier":barrier(q,sz)
func ground():
 r(Rect2(-2200,-1200,6000,2600),Color("#26373d"))
 # River depth: broad subdued bands, sparse broken highlights and distant shore haze.
 for i in range(25):r(Rect2(-1200,-340+i*33,3900,34),Color("#30474b").darkened(float(i)*.009))
 for i in range(3700):
  var at=Vector2(rng.randf_range(-800,2250),rng.randf_range(-260,820))
  l(at,at+Vector2(rng.randf_range(2,17),0),Color(.44,.56,.56,rng.randf_range(.025,.15)),1.)
 # Low industrial bank, viewed across the water. Architecture stays quieter than the deck.
 for x in range(-500,2000,75):
  var h=rng.randf_range(20,70);var y=-300+rng.randf_range(-8,5)
  r(Rect2(x,y-h,68,h),Color("#3a4a4e"));r(Rect2(x+4,y-h+5,61,h-5),Color("#405154"))
  for wx in range(7,60,11):
   for wy in range(10,int(h)-5,13):r(Rect2(x+wx,y-h+wy,4,5),Color("#586363"))
  l(Vector2(x,y-h),Vector2(x+68,y-h),Color("#64716f"),1.)
 for spec in [[100.,-297.,85.],[1040.,-300.,65.],[1560.,-294.,75.]]:
  var q=Vector2(spec[0],spec[1]);l(q,q+Vector2(0,-spec[2]),Color("#4a5b5c"),3.)
  l(q+Vector2(-35,-spec[2]),q+Vector2(100,-spec[2]+8),Color("#566465"),3.)
  l(q+Vector2(0,-spec[2]+20),q+Vector2(75,-spec[2]+6),Color("#506061"),1.)
  l(q+Vector2(78,-spec[2]+6),q+Vector2(78,-15),Color("#45585b"),1.)
 # Piers descend from the deck; a dark waterline and broken reflection anchor the span.
 for x in C.TOWERS:
  var px=x*8
  poly([Vector2(px-30,270),Vector2(px+26,270),Vector2(px+38,514),Vector2(px-42,514)],Color("#4c5753"))
  poly([Vector2(px+16,270),Vector2(px+26,270),Vector2(px+38,514),Vector2(px+15,514)],Color("#354441"))
  for y in range(330,508,15):l(Vector2(px-32,y),Vector2(px+28,y),Color("#646a5e"),1.)
  r(Rect2(px-42,495,81,19),Color("#344643"));l(Vector2(px-52,515),Vector2(px+51,515),Color("#71817b"),2.)
  for i in range(35):
   var y=520+i*3;r(Rect2(px-rng.randf_range(14,38),y,rng.randf_range(20,57),1),Color(.17,.23,.23,.25*(1.-float(i)/35.)))
 # The visible front steel edge supports the roadway continuously.
 r(Rect2(-750,52,3000,248),Color("#5b625b"))
 r(Rect2(-750,294,3000,44),Color("#283b3d"));r(Rect2(-750,296,3000,5),Color("#748076"))
 for x in range(-740,2260,42):
  l(Vector2(x,306),Vector2(x+42,331),Color("#4d6060"),3.)
  l(Vector2(x+42,306),Vector2(x,331),Color("#3b5152"),3.)
  l(Vector2(x,302),Vector2(x,336),Color("#6a7770"),2.)
  for y in [304,333]:r(Rect2(x-1,y,2,2),Color("#95a08b"))
 l(Vector2(-750,337),Vector2(2250,337),Color("#182c32"),3.)
 # Four full lanes with the traversable central maintenance strip.
 for band in [Rect2(-750,72,3000,78),Rect2(-750,186,3000,78)]:
  r(band,Color("#303639"));grain(band,8500)
 for band in [Rect2(-750,54,3000,18),Rect2(-750,150,3000,36),Rect2(-750,264,3000,30)]:
  r(band,Color("#6e7167"));grain(band,1700)
  for x in range(-750,2250,18):l(Vector2(x,band.position.y+1),Vector2(x,band.end.y-1),Color("#565f58"),1.)
 for y in [72.,150.,186.,264.]:
  l(Vector2(-750,y),Vector2(2250,y),Color("#9e9e85"),1.)
  l(Vector2(-750,y+1),Vector2(2250,y+1),Color("#202d30"),1.)
 # Worn traffic paint is physically on the asphalt, broken by age rather than huge text.
 for x in range(-700,2240,25):
  for y in [110.,225.]:
   r(Rect2(x,y,12,1),Color("#b5b4a0"))
   if (x+700)%75==0:r(Rect2(x+4,y,2,1),Color("#444948"))
 for y in [77.,145.,191.,259.]:l(Vector2(-750,y),Vector2(2250,y),Color("#a89456"),1.)
 for x in range(-500,1900,185):
  for lane in range(4):arrow(Vector2(x+lane*17,C.LANES[lane]*6),-1 if lane<2 else 1)
 # Expansion joints span the entire deck at the main pylons and intermediate bays.
 for x in [21.,60.,96.,132.,170.]:
  var px=x*8
  r(Rect2(px-1,54,3,240),Color("#242f31"))
  for y in range(54,294,4):l(Vector2(px-2,y),Vector2(px+2,y+2),Color("#79817a"),.7)
 # Shoulder drains, reflectors, scuffs and restrained pieces of abandoned litter.
 for x in range(10,1440,53):
  for y in [68,267]:
   r(Rect2(x,y,7,3),Color("#242f30"))
   for n in range(4):l(Vector2(x+n*2,y),Vector2(x+n*2,y+3),Color("#8a8b7b"),.6)
 for i in range(95):
  var at=Vector2(rng.randf_range(370,1110),[70.,149.,187.,265.][i%4]+rng.randf_range(-1,1))
  poly([at,at+Vector2(1.6,-.5),at+Vector2(2.1,.8),at+Vector2(.4,1)],Color("#a59b80"))
 for x in C.TOWERS:
  for y in [10.3,28.,47.7]:
   var at=Vector2(x*8,y*6)
   poly([at+Vector2(-16,0),at+Vector2(16,0),at+Vector2(48,24),at+Vector2(18,24)],Color(0.07,.12,.13,.26))
 rails(9.,false);rails(49.,true)
 cables(10.3,.88)
 for x in [16.,42.,85.,110.,154.,178.]:
  lamp(Vector2(x*8,56),false)
 # Small real-scale traffic signs, mounted into the deck.
 road_sign(Vector2(1390,267),"BRIDGE", "NO STOPPING")
 road_sign(Vector2(290,62),"KEEP", "RIGHT")
func arrow(q: Vector2,dir: int):
 var c=Color("#92998c")
 l(q-Vector2(6*dir,0),q+Vector2(6*dir,0),c,2.)
 l(q+Vector2(6*dir,0),q+Vector2(2*dir,-3),c,1.)
 l(q+Vector2(6*dir,0),q+Vector2(2*dir,3),c,1.)
func rails(y: float,front: bool):
 var py=y*6;var top=py-7
 r(Rect2(-750,py,3000,3),Color("#909384"));r(Rect2(-750,py+3,3000,3),Color("#4c5c57"))
 for x in range(-750,2250,12):
  l(Vector2(x,py),Vector2(x,top),Color("#4b615f"),1.)
  r(Rect2(x-1,py-1,2,2),Color("#bbc0a5"))
 for d in [0.,3.]:l(Vector2(-750,top+d),Vector2(2250,top+d),Color("#778a7d"),1.)
 if front:l(Vector2(-750,py+6),Vector2(2250,py+6),Color("#152b32"),2.)
func cable_y(x: float,base: float) -> float:
 var a=C.TOWERS[0]*8;var b=C.TOWERS[1]*8
 if x<a:return base-270+(a-x)*.48
 if x>b:return base-270+(x-b)*.48
 var t=(x-a)/(b-a);return base-270+126*4*t*(1-t)
func cables(y: float,alpha: float):
 var base=y*6;var last=Vector2(-270,cable_y(-270,base))
 for x in range(-266,1750,4):
  var next=Vector2(x,cable_y(x,base));l(last,next,Color(.09,.16,.18,alpha),3.4);l(last-Vector2(0,1),next-Vector2(0,1),Color(.58,.64,.56,alpha),1.1);last=next
 for x in range(-220,1710,27):
  var cy=cable_y(x,base)
  if cy>base:continue
  l(Vector2(x,cy+2),Vector2(x,base-3),Color(.37,.46,.44,alpha*.65),.8)
  r(Rect2(x-1,base-3,3,3),Color(.66,.67,.55,alpha))
  r(Rect2(x-1,cy+2,2,4),Color(.55,.61,.54,alpha))
func tower(q: Vector2,sz: Vector2,y: float):
 var c=q+sz*.5;var tall=270.;var top=c-Vector2(0,tall)
 var ink=Color("#24383b");ink.a=upper_alpha
 var mid=Color("#63776f");mid.a=upper_alpha
 var lit=Color("#a1ab92");lit.a=upper_alpha
 poly([c+Vector2(-10,-9),c+Vector2(11,-9),top+Vector2(7,0),top+Vector2(-7,0)],ink)
 poly([c+Vector2(-8,-10),c+Vector2(1,-10),top+Vector2(1,2),top+Vector2(-5,2)],mid)
 l(c+Vector2(-8,-12),top+Vector2(-5,3),lit,1.)
 for n in range(1,13):
  var at=c-Vector2(0,n*20.)
  l(at+Vector2(-7,0),at+Vector2(7,0),mid,2.)
  r(Rect2(at+Vector2(-5,-2),Vector2(1,1)),lit)
  r(Rect2(at+Vector2(5,-2),Vector2(1,1)),lit)
 # Cable saddle and capped crosshead. Ground plinth remains opaque during occlusion fade.
 r(Rect2(top-Vector2(12,2),Vector2(24,8)),ink);l(top+Vector2(-11,-1),top+Vector2(11,-1),lit,1.)
 r(Rect2(top+Vector2(-2,-6),Vector2(4,4)),Color("#c58259"))
 var h=13.
 r(Rect2(q-Vector2(0,h),sz+Vector2(0,h)),Color("#333f3d"))
 r(Rect2(q-Vector2(-1,h-1),sz-Vector2(2,1)),Color("#8b8c7b"))
 r(Rect2(q+Vector2(1,sz.y-h),Vector2(sz.x-2,h-1)),Color("#626e60"))
 l(q+Vector2(0,sz.y-h),q+Vector2(sz.x,sz.y-h),Color("#b1ad90"),1.)
 for i in range(18):
  var at=q+Vector2(rng.randf_range(1,sz.x-1),rng.randf_range(sz.y-h,sz.y-1));r(Rect2(at,Vector2(1,1)),Color(.19,.24,.21,.25))
 for dx in [3.,sz.x-4]:r(Rect2(q+Vector2(dx,sz.y-h+2),Vector2(2,1)),Color("#bbb99f"))
func cabinet(q: Vector2,sz: Vector2):
 var h=12.;r(Rect2(q-Vector2(0,h),sz+Vector2(0,h)),INK)
 r(Rect2(q-Vector2(-1,h-1),sz+Vector2(-2,h-2)),Color("#6d8075"))
 r(Rect2(q-Vector2(-1,h-1),sz-Vector2(2,2)),Color("#8a9786"))
 for i in range(4):l(q+Vector2(2,sz.y-10+i*2),q+Vector2(sz.x-3,sz.y-10+i*2),Color("#3c534c"),1.)
 r(Rect2(q+Vector2(sz.x-4,sz.y-4),Vector2(1,2)),Color("#cad0b4"))
 poly([q+Vector2(4,0),q+Vector2(2,4),q+Vector2(6,4)],Color("#c8b26d"))
func barrier(q: Vector2,sz: Vector2):
 poly([q+Vector2(-1,sz.y),q+Vector2(sz.x+1,sz.y),q+Vector2(sz.x-1,-6),q+Vector2(1,-6)],Color("#8b8d7c"))
 l(q+Vector2(1,-6),q+Vector2(sz.x-1,-6),Color("#d0c8aa"),1.)
 for i in range(3):l(q+Vector2(1,i*6),q+Vector2(sz.x-1,i*6-3),Color("#4e5851"),2.)
func lamp(q: Vector2,front: bool):
 l(q,q-Vector2(0,43),Color("#253a3c"),2.)
 l(q-Vector2(0,43),q+Vector2(10,-43),Color("#8a9a89"),1.)
 r(Rect2(q+Vector2(7,-43),Vector2(8,2)),Color("#ccd0b1"))
 r(Rect2(q+Vector2(-2,-1),Vector2(4,2)),Color("#7c8978"))
func road_sign(q: Vector2,a: String,b: String):
 l(q,q-Vector2(0,28),Color("#8f9b8c"),1.5)
 r(Rect2(q-Vector2(17,36),Vector2(35,15)),Color("#293d38"))
 draw_rect(Rect2(q-Vector2(17,36),Vector2(35,15)),Color("#a5b39b"),false,.7)
 draw_string(lettering,q+Vector2(-15,-30),a,HORIZONTAL_ALIGNMENT_CENTER,31,5,Color("#e0dcc2"))
 draw_string(lettering,q+Vector2(-15,-24),b,HORIZONTAL_ALIGNMENT_CENTER,31,4,Color("#d0d0b6"))
