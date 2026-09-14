extends RefCounted
## Strict west-facing estate. Elevation rises vertically; the entrance is seen
## in profile. The long side and roof continue beyond the playable east edge.
var a: Node2D
const C=preload("res://battle/geometry/whittaker_estate_catalog.gd")
const RISE=Vector2(0,-1.)
var angled=false
func _init(canvas):a=canvas
func pt(world: Vector2,height: float=0.) -> Vector2:
 return (C.architecture_point(world) if angled else world)*Vector2(8,6)+RISE*height-a.position
func poly(points: Array,color: String):
 var area=0.
 for i in range(points.size()):area+=points[i].cross(points[(i+1)%points.size()])
 if absf(area)>.01:a.draw_colored_polygon(PackedVector2Array(points),Color(color))
func line(p: Vector2,q: Vector2,color: String,w=1.):a.draw_line(p,q,Color(color),w,false)
func face(origin: Vector2,tangent: Vector2,u: float,z: float,width: float,height: float,color: String):
 poly([pt(origin+tangent*u,z),pt(origin+tangent*(u+width),z),pt(origin+tangent*(u+width),z+height),pt(origin+tangent*u,z+height)],color)
func frame(origin: Vector2,tangent: Vector2,u: float,z: float,width: float,height: float):
 face(origin,tangent,u-.18,z-.8,width+.36,height+1.6,"#777f72")
 face(origin,tangent,u,z,width,height,"#263b39")
 face(origin,tangent,u+.16,z+1,width-.32,height-2,"#617874")
 face(origin,tangent,u+.18,z+height*.55,width-.36,height*.32,"#8b9a8c")
 line(pt(origin+tangent*(u+width*.5),z),pt(origin+tangent*(u+width*.5),z+height),"#eeecd9",1.3)
 line(pt(origin+tangent*u,z+height*.5),pt(origin+tangent*(u+width),z+height*.5),"#e5e6d3",1.2)
 face(origin,tangent,u-.28,z-2.,width+.56,2.,"#f1ead5")
 for offset in [-.9,width+.22]:
  face(origin,tangent,u+offset,z,.65,height,"#364e44")
  for h in range(3,int(height)-1,4):line(pt(origin+tangent*(u+offset+.05),z+h),pt(origin+tangent*(u+offset+.60),z+h),"#698070",.8)
func mass(box: Rect2,h: float,roof_h: float,white=true):
 var nw=box.position;var ne=Vector2(box.end.x,box.position.y);var sw=Vector2(box.position.x,box.end.y);var se=box.end
 # Cast and contact shadows, tied to the actual footprint.
 a.draw_colored_polygon(PackedVector2Array([pt(sw),pt(se),pt(se)+Vector2(-20,22),pt(sw)+Vector2(-22,14)]),Color(.08,.12,.08,.25))
 poly([pt(nw),pt(sw),pt(sw,h),pt(nw,h)],"#b8bbab" if white else "#a0a68f")
 poly([pt(sw),pt(se),pt(se,h),pt(sw,h)],"#e3e0ca" if white else "#c0c6ab")
 # Foundation and fine horizontal siding; west face is cooler in shade.
 face(nw,Vector2.DOWN,0,0,box.size.y,6,"#949b8a")
 face(sw,Vector2.RIGHT,0,0,box.size.x,6,"#b9b9a0")
 for height in range(9,int(h)-2,5):
  line(pt(nw,height),pt(sw,height),"#a8b09f",.65)
  line(pt(sw,height),pt(se,height),"#cacfb8",.65)
 face(nw,Vector2.DOWN,0,h-5,box.size.y,5,"#e0e1ce")
 face(sw,Vector2.RIGHT,0,h-5,box.size.x,5,"#f0ecd7")
 # True hipped roof: four pitched planes surrounding a longitudinal ridge.
 var roof=box.grow(.75);nw=roof.position;ne=Vector2(roof.end.x,roof.position.y);sw=Vector2(roof.position.x,roof.end.y);se=roof.end
 var rn=Vector2(box.get_center().x,box.position.y+box.size.x*.40)
 var rs=Vector2(box.get_center().x,box.end.y-box.size.x*.40)
 if rn.y>rs.y:rn.y=box.get_center().y;rs.y=rn.y
 poly([pt(nw,h),pt(ne,h),pt(rn,h+roof_h)],"#66746d")
 poly([pt(ne,h),pt(se,h),pt(rs,h+roof_h),pt(rn,h+roof_h)],"#34463f")
 poly([pt(nw,h),pt(rn,h+roof_h),pt(rs,h+roof_h),pt(sw,h)],"#52665c")
 poly([pt(sw,h),pt(rs,h+roof_h),pt(se,h)],"#758174")
 for i in range(1,9):
  var t=i/9.
  line(pt(nw.lerp(rn,t),h+roof_h*t),pt(sw.lerp(rs,t),h+roof_h*t),"#40584d",1.)
  line(pt(sw.lerp(rs,t),h+roof_h*t),pt(se.lerp(rs,t),h+roof_h*t),"#606f62",1.)
  var first=pt(nw.lerp(rn,t),h+roof_h*t);var last=pt(sw.lerp(rs,t),h+roof_h*t)
  var along=first.direction_to(last);var across=Vector2(-along.y,along.x)
  for step in range(7,int(first.distance_to(last)),11):
   var at=first+along*(step+(i%2)*3);line(at,at+across*4,"#7d8a7c",.65)
 line(pt(nw,h),pt(sw,h),"#d8deca",2.)
 line(pt(sw,h),pt(se,h),"#f2ead6",2.)
 line(pt(rn,h+roof_h),pt(rs,h+roof_h),"#93a18e",2.)
func column(at: Vector2,h: float):
 var b=pt(at);var t=pt(at,h)
 a.draw_line(b+Vector2(2,0),t+Vector2(2,0),Color("#777f70"),7.,false)
 a.draw_line(b,t,Color("#e5e5cf"),6.,false)
 a.draw_line(b-Vector2(2,0),t-Vector2(2,0),Color("#f6efda"),2.,false)
 for z in [2.,h-2.]:
  var q=pt(at,z);poly([q+Vector2(-6,-2),q+Vector2(6,-2),q+Vector2(6,2),q+Vector2(-6,2)],"#e9e6cf")
func mansion(box: Rect2):
 var west=box.position;var south=Vector2(box.position.x,box.end.y)
 mass(box,112,38)
 # South elevation is a side return: windows, not an invented front door.
 for u in range(4,68,7):
  frame(south,Vector2.RIGHT,u,14,2.8,31);frame(south,Vector2.RIGHT,u,65,2.8,31)
 face(south,Vector2.RIGHT,0,54,box.size.x,4,"#f2ecda")
 # Corner pilasters and a limestone base ground the white side elevation.
 for u in [0.,box.size.x-1.2]:face(south,Vector2.RIGHT,u,6,1.2,100,"#f1ecd9")
 # The front door is on the edge-on west wall, correctly occluded from this
 # camera. Show the portico side, canopy, treads and columns, not a false facade.
 var porch=Rect2(139,54,6,18)
 poly([pt(porch.position,4),pt(Vector2(porch.end.x,porch.position.y),4),pt(porch.end,4),pt(Vector2(porch.position.x,porch.end.y),4)],"#bbb9a1")
 for x in range(139,145,2):line(pt(Vector2(x,54),4),pt(Vector2(x,72),4),"#9da58f",.7)
 for i in range(6):
  var x=136.+i*.5
  poly([pt(Vector2(x,59),i*.7),pt(Vector2(x+.5,59),i*.7+.7),pt(Vector2(x+.5,67),i*.7+.7),pt(Vector2(x,67),i*.7)],"#d2cbb2")
  line(pt(Vector2(x,59),i*.7),pt(Vector2(x,67),i*.7),"#eae1c7",1.)
 # Columns stand along the street-facing edge, not across the camera-facing side.
 for y in [55.,59.,67.,71.]:column(Vector2(140,y),101)
 var roof=Rect2(138.4,53.5,7.4,19)
 var nw=roof.position;var sw=Vector2(roof.position.x,roof.end.y);var ne=Vector2(roof.end.x,roof.position.y);var se=roof.end
 var ridge_w=Vector2(roof.position.x,63);var ridge_e=Vector2(roof.end.x,63)
 poly([pt(nw,104),pt(ne,104),pt(ridge_e,122),pt(ridge_w,122)],"#465d50")
 poly([pt(sw,104),pt(ridge_w,122),pt(ridge_e,122),pt(se,104)],"#7f8e7b")
 face(sw,Vector2.RIGHT,0,98,roof.size.x,6,"#f4efdc")
 line(pt(sw,104),pt(se,104),"#fff2dc",2.)
 line(pt(ridge_w,122),pt(ridge_e,122),"#abb29b",2.)
 for at in [Vector2(163,39),Vector2(190,70)]:
  var q=pt(at,139)
  poly([q,q+Vector2(15,0),q+Vector2(15,-30),q+Vector2(0,-30)],"#d1c9b0")
  for y in range(5,29,6):line(q-Vector2(0,y),q+Vector2(15,-y),"#b4aa90",1.)
  line(q+Vector2(-2,-30),q+Vector2(17,-30),"#ebe4cc",4.)
func small_building(box: Rect2,kind: String):
 var h=53. if kind=="wing" else (40. if kind=="gatehouse" else 46.)
 mass(box,h,17.,kind!="garage")
 var west=box.position;var south=Vector2(box.position.x,box.end.y)
 if kind=="wing":
  for u in [3.,9.,15.]:frame(south,Vector2.RIGHT,u,12,2.2,27)
  frame(west,Vector2.DOWN,4.,12,2.2,27)
 elif kind=="gatehouse":
  frame(south,Vector2.RIGHT,1.,12,2.7,20)
  frame(west,Vector2.DOWN,1.2,14,2.7,17)
  face(west,Vector2.DOWN,5,3,2.,29,"#3d5140")
  face(west,Vector2.DOWN,5.2,16,1.6,13,"#87998b")
 else:
  # Garage doors face the south service apron; the west return stays secondary.
  for u in [2.,11.]:
   face(south,Vector2.RIGHT,u,3,6.7,34,"#465f4e")
   for z in range(7,36,6):line(pt(south+Vector2(u,0),z),pt(south+Vector2(u+6.7,0),z),"#82917a",1.)
func render(row: Array):
 angled=C.architectural(row)
 var box: Rect2=row[1]
 if row[2]=="house":mansion(box)
 elif row[2] in ["wing","gatehouse","garage"]:small_building(box,row[2])
 elif row[2]=="step_wall":
  # Continuous solid cheek up to the porch height; not decorative rails.
  var p=box.position;var s=Vector2(p.x,box.end.y)
  poly([pt(p),pt(s),pt(s,10),pt(p,10)],"#a3ad98")
  poly([pt(s),pt(box.end),pt(box.end,10),pt(s,10)],"#c5c8af")
  line(pt(p,10),pt(Vector2(box.end.x,p.y),10),"#eee3c9",3.)
 # Porch columns are drawn with the portico to keep a coherent building volume.
