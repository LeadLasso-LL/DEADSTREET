extends Node2D
# Arrival-only seated pose. Uses the real unit's head from its current faction
# atlas, with bent limbs and a leather vest rather than a standing actor on a bike.
var head: Texture2D
var passenger=false
var bed=false
var riding=true
var phase=0.
var skin=Color("#bd8c70")
var jacket=Color("#282c2d")
var denim=Color("#333c43")
var heading=1.
func setup(body: AnimatedSprite2D,is_passenger: bool,is_bed: bool):
 passenger=is_passenger;bed=is_bed;texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 var clip="idle_e" if body.sprite_frames.has_animation("idle_e") else body.animation
 var frame=body.sprite_frames.get_frame_texture(clip,0)
 var im=frame.get_image();var bounds=im.get_used_rect()
 # Head is at the top of the actor, independent of weapon length below it.
 var h=maxi(8,roundi(bounds.size.y*.24));var source=Rect2(bounds.position,Vector2(bounds.size.x,h))
 var tex=AtlasTexture.new();tex.atlas=frame;tex.region=source;head=tex
 # Keep faction skin tones through the source artwork; exposed hands use the
 # same warm neutral range, avoiding a second decorative passenger identity.
func _draw():
 var bob=sin(phase*15.)*.16 if riding else 0.
 draw_set_transform(Vector2(0,bob),0,Vector2(heading,1))
 var boot=Color("#151a1d");var edge=Color("#171c1e")
 # Seated hips at origin, knees forward and boots resting on pegs/bed floor.
 var knee=Vector2(4.5,3.);var foot=Vector2(3.5,8.)
 if bed:knee=Vector2(3.5,2.5);foot=Vector2(3.5,6.8)
 limb(Vector2(-1,0),knee,foot,denim,3.2)
 draw_line(foot,foot+Vector2(3.2,.3),boot,2.5)
 var shoulder=Vector2(1.,-8.5)
 draw_colored_polygon(PackedVector2Array([Vector2(-3.,-8.),Vector2(2.4,-9.),Vector2(4.,-1.),Vector2(-2.8,1.)]),jacket)
 draw_line(Vector2(-2.5,-7.5),Vector2(-1.,.2),Color("#5b5b50"),.8)
 draw_rect(Rect2(-1.6,-5.7,2.3,1.4),Color("#b0a18a"))
 var hand=Vector2(9.,-7.) if not passenger and not bed else Vector2(5.,-2.5)
 limb(shoulder,Vector2(5.,-5.),hand,jacket,2.5)
 draw_line(hand-Vector2(.7,0),hand+Vector2(.9,0),skin,1.7)
 if head!=null:
  var sz=head.get_size();var scale=.30
  draw_texture_rect(head,Rect2(Vector2(-sz.x*scale*.5,-15.),sz*scale),false)
func limb(a: Vector2,b: Vector2,c: Vector2,color: Color,width: float):
 draw_line(a,b,Color("#151b1e"),width+1.2);draw_line(b,c,Color("#151b1e"),width+1.2)
 draw_line(a,b,color,width);draw_line(b,c,color,width)
