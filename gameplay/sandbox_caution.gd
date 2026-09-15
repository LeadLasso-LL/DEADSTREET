extends Control
## Silent impacts across the sign overlap a slow zoom on the opening music clock.
const HIT_TIMES = [7.2, 7.533333, 7.933333, 8.233333, 8.566667]
const CENTERS = [Vector2(366,256), Vector2(968,366), Vector2(635,391), Vector2(420,463), Vector2(780,535)]
const RADII = [10.5,13.0,15.5,9.0,11.0]
var art: Texture2D
var gloria: Texture2D
var godot: Texture2D
var clock = 0.0
var revealed = 0
var appeared_at: Array[float] = []
var visible_hits = 0

func _ready():
	size=Vector2(1280,720)
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	art=ImageTexture.create_from_image(Image.load_from_file("res://assets/menu/opening/caution_clean.png"))
	gloria=ImageTexture.create_from_image(Image.load_from_file("res://assets/menu/opening/credit_gloria.png"))
	godot=ImageTexture.create_from_image(Image.load_from_file("res://assets/menu/opening/credit_godot.png"))
	hide()

func advance(time: float, _music_volume: float):
	clock=time
	visible=clock<11.8
	visible_hits=0
	for at in HIT_TIMES:
		if clock>=at: visible_hits+=1
	while revealed<5 and clock>=HIT_TIMES[revealed]:
		appeared_at.append(clock)
		print("CAUTION_IMPACT ",revealed+1," ",clock)
		revealed+=1
	if visible:
		queue_redraw()

func ring(center: Vector2, radius: float, variation: float, seed_value: int) -> PackedVector2Array:
	var rng=RandomNumberGenerator.new(); rng.seed=seed_value
	var points=PackedVector2Array()
	for j in range(18):
		var a=TAU*float(j)/18.0
		points.append((center+Vector2(cos(a),sin(a))*radius*rng.randf_range(1.0-variation,1.0+variation)).round())
	return points

func draw_hole(index: int):
	var c: Vector2=CENTERS[index]; var radius: float=RADII[index]
	var rng=RandomNumberGenerator.new(); rng.seed=90215+index*19
	for j in range(7):
		var angle=TAU*float(j)/7.0+rng.randf_range(-0.2,0.2)
		var direction=Vector2(cos(angle),sin(angle))
		var elbow=c+direction*radius*1.5
		var tip=c+direction*radius*rng.randf_range(1.8,2.6)
		draw_line((c+direction*radius).round(),elbow.round(),Color(0.18,0.18,0.18),2.0)
		draw_line(elbow.round(),tip.round(),Color(0.25,0.25,0.25),1.0)
	draw_colored_polygon(ring(c,radius*1.35,0.20,index+27),Color(0.36,0.36,0.36))
	draw_colored_polygon(ring(c,radius*1.18,0.13,index+33),Color(0.81,0.81,0.81))
	draw_colored_polygon(ring(c+Vector2(0,1),radius,0.11,index+45),Color(0.13,0.13,0.13))
	draw_colored_polygon(ring(c,radius*0.83,0.09,index+39),Color.BLACK)
	var age=clock-float(HIT_TIMES[index])
	if age<0.18:
		var strength=1.0-age/0.18
		for j in range(9):
			var angle=TAU*float(j)/9.0+rng.randf_range(-0.25,0.25)
			var direction=Vector2(cos(angle),sin(angle))
			var d=radius+age*rng.randf_range(120,210)
			draw_line((c+direction*d).round(),(c+direction*(d+6*strength)).round(),Color(1,1,1,strength),2.0)
		if age<0.05: draw_circle(c,radius*0.8,Color(1,1,1,0.85*(1-age/0.05)))

func _draw():
	draw_rect(Rect2(0,0,1280,720),Color.BLACK)
	if clock<2.5:
		draw_texture_rect(gloria,Rect2(0,0,1280,720),false,Color(1,1,1,clampf((2.5-clock)/0.5,0,1)))
		return
	if clock<5.5:
		var alpha=clampf((clock-2.5)/0.5,0,1)*clampf((5.5-clock)/0.5,0,1)
		draw_texture_rect(godot,Rect2(0,0,1280,720),false,Color(1,1,1,alpha))
		return
	var view=zoom_view_at(clock)
	var center=Vector2(view.x,view.y)
	draw_set_transform(Vector2(640,360)-center*view.z,0,Vector2.ONE*view.z)
	draw_texture_rect(art,Rect2(0,0,1280,720),false)
	for i in range(visible_hits): draw_hole(i)
	draw_set_transform(Vector2.ZERO)
	var darkness=1.0-clampf((clock-5.5)/0.5,0,1)*clampf((11.8-clock)/0.18,0,1)
	if darkness>0: draw_rect(Rect2(0,0,1280,720),Color(0,0,0,darkness))
func zoom_view_at(time: float) -> Vector3:
	# One smooth camera path: no change of anchor or crop-bound clamp.
	var q=clampf((time-6.85)/4.95,0.0,1.0)
	var ease=q*q*(3.0-2.0*q)
	var zoom=exp(log(14.0)*ease)
	var focus=Vector2(640,504)
	var screen_focus=focus.lerp(Vector2(640,360),ease)
	var center=focus+(Vector2(640,360)-screen_focus)/zoom
	return Vector3(center.x,center.y,zoom)
