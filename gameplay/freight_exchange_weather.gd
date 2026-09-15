extends Node2D
## Map-local night/rain presentation; HUD, tactics and other maps stay independent.
const C=preload("res://battle/geometry/freight_exchange_catalog.gd")
const LIGHTS=[
 [Vector2(25,-2),Color("#ffd296"),1.05,1.7],
 [Vector2(110,-2),Color("#b3d3df"),.82,1.85],
 [Vector2(165,16),Color("#ffd093"),1.12,1.65],
 [Vector2(165,58),Color("#b4d2df"),.92,1.8],
 [Vector2(27,78),Color("#ffd093"),1.05,1.75],
 [Vector2(108,78),Color("#ffd59f"),1.05,1.85],
 [Vector2(141,20),Color("#ffc77e"),.82,1.0],
 [Vector2(70,12),Color("#ffd296"),1.0,1.55],
 [Vector2(96,57),Color("#b6d8e1"),.83,1.45]
]
var view
var tick=0.
var drops=[]
var splashes=[]
var rain: AudioStreamPlayer
var roof: AudioStreamPlayer2D
var lights=[]
var sound_enabled=true
var unit_clear_cells={}
var rng=RandomNumberGenerator.new()
func _ready():
 z_index=90;texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR
 var material_value=CanvasItemMaterial.new();material_value.light_mode=CanvasItemMaterial.LIGHT_MODE_UNSHADED;material=material_value
 var night=CanvasModulate.new();night.color=Color(.38,.46,.56);add_child(night)
 var gradient=Gradient.new();gradient.offsets=PackedFloat32Array([0.,.18,.50,1.]);gradient.colors=PackedColorArray([Color(1,1,1,1),Color(1,1,1,.85),Color(1,1,1,.36),Color(1,1,1,0)])
 var glow=GradientTexture2D.new();glow.gradient=gradient;glow.width=256;glow.height=256;glow.fill=GradientTexture2D.FILL_RADIAL;glow.fill_from=Vector2(.5,.5);glow.fill_to=Vector2(1.,.5)
 for spec in LIGHTS:
  var lamp=PointLight2D.new();lamp.texture=glow;lamp.color=spec[1];lamp.energy=spec[2];lamp.texture_scale=spec[3]
  lamp.position=spec[0]*Vector2(8,6)+Vector2(11,-44) if spec[0].y!=20 else spec[0]*Vector2(8,6)
  lamp.shadow_enabled=true;lamp.shadow_color=Color(.025,.045,.065,.64);lamp.shadow_filter=Light2D.SHADOW_FILTER_PCF5
  add_child(lamp);lights.append(lamp)
 # Physical boxes cast local shadows into the wet lanes. No scene-wide dark overlay.
 for row in C.props():
  if row[2] not in ["boxcar","timber_car","dispatch","shed"]:continue
  var b: Rect2=row[1];var q=b.position*Vector2(8,6);var end=b.end*Vector2(8,6)
  var polygon=OccluderPolygon2D.new();polygon.polygon=PackedVector2Array([q,Vector2(end.x,q.y),end,Vector2(q.x,end.y)])
  var occluder=LightOccluder2D.new();occluder.occluder=polygon;add_child(occluder)
 rng.seed=925523
 for i in range(1050):drops.append([Vector2(rng.randf_range(-120,1460),rng.randf_range(-150,670)),rng.randf_range(270,390),rng.randf_range(10,19),rng.randf_range(.20,.38),1. if i%5 else 1.45])
 for i in range(210):drops.append([Vector2(rng.randf_range(-120,1460),rng.randf_range(-150,670)),rng.randf_range(460,560),rng.randf_range(18,29),rng.randf_range(.10,.20),1.2])
 for i in range(160):splashes.append([Vector2(rng.randf_range(205,1310),rng.randf_range(5,450)),rng.randf()])
 rain=AudioStreamPlayer.new();add_child(rain);rain.stream=loop_stream("res://assets/audio/ambience/freight_rain.wav");rain.volume_db=-13.
 if rain.stream!=null:rain.play()
 roof=AudioStreamPlayer2D.new();add_child(roof);roof.stream=loop_stream("res://assets/audio/ambience/freight_roof_rain.wav");roof.position=Vector2(97,26)*Vector2(8,6);roof.max_distance=1200.;roof.attenuation=.65;roof.volume_db=-21.
 if roof.stream!=null:roof.play()
func loop_stream(path: String) -> AudioStreamWAV:
 if not FileAccess.file_exists(path):return null
 var stream=AudioStreamWAV.load_from_file(path)
 if stream!=null:stream.loop_mode=AudioStreamWAV.LOOP_FORWARD;stream.loop_begin=0;stream.loop_end=int(round(stream.get_length()*stream.mix_rate))
 return stream
func _process(delta):
 tick+=delta
 var active=sound_enabled
 if view!=null and is_instance_valid(view):active=active and view.visible and view.battle_presentation.audio_enabled and view._is_dusk_street() and view._geometry().authored_layout_id==C.ID
 var focus=0.
 if view!=null and is_instance_valid(view):
  var presentation=view.battle_presentation
  if presentation.stage=="arrival":focus=1.-presentation.convoy_radio_battle_mix()
 if rain!=null:rain.volume_db=lerpf(-13.,-19.,focus)
 if roof!=null:roof.volume_db=lerpf(-21.,-26.,focus)
 unit_clear_cells.clear()
 if view!=null and is_instance_valid(view) and view.actor_presenter!=null:
  for node in view.actor_presenter._unit_nodes.values():
   if not is_instance_valid(node) or not node.visible:continue
   var center=to_local(node.global_position)
   var box=Rect2(center+Vector2(-9,-30),Vector2(18,32))
   for y in range(floori(box.position.y/48.),floori(box.end.y/48.)+1):
    for x in range(floori(box.position.x/48.),floori(box.end.x/48.)+1):
     var key=Vector2i(x,y)
     if not unit_clear_cells.has(key):unit_clear_cells[key]=[]
     unit_clear_cells[key].append(box)
 if rain!=null:rain.stream_paused=not active
 if roof!=null:roof.stream_paused=not active
 queue_redraw()
func _draw():
 # Occupied dispatch windows cast a subdued amber glow through dirty glass.
 for at in [Vector2(1024,86),Vector2(1247,86)]:
  draw_rect(Rect2(at,Vector2(21,10)),Color(.72,.51,.23,.42))
  draw_line(at+Vector2(10,0),at+Vector2(10,10),Color(.17,.22,.20,.8),1.)
 # Lamp lenses and restrained wet glints stay luminous within the night canvas.
 for i in range(LIGHTS.size()):
  var spec=LIGHTS[i];var at: Vector2=spec[0]*Vector2(8,6)
  var bulb=at+Vector2(11,-46) if spec[0].y!=20 else at-Vector2(0,10)
  for radius in [9.,5.,2.]:draw_circle(bulb,radius,Color(spec[1],.035 if radius==9. else .10 if radius==5. else .7))
  for n in range(12):
   var y=n*4.;var x=sin(float(n)*4.7+i)*14.
   var shimmer=.045+sin(tick*2.+n)*.015
   draw_line(at+Vector2(x-5,8+y),at+Vector2(x+5+n*.5,8+y),Color(spec[1],shimmer),1.)
 for drop in drops:
  var at: Vector2=drop[0];var speed: float=drop[1]
  at.x=fposmod(at.x+120.-tick*speed*.20,1580.)-120.
  at.y=fposmod(at.y+150.+tick*speed,820.)-150.
  var alpha: float=drop[3]
  # Rain briefly catches a yard lamp as it falls through its cone.
  for lamp in lights:
   if at.distance_squared_to(lamp.position)<9000.:alpha*=1.7;break
  var middle=at+Vector2(-drop[2]*.10,drop[2]*.5)
  for box in unit_clear_cells.get(Vector2i(floori(middle.x/48.),floori(middle.y/48.)),[]):
   if box.has_point(middle):alpha*=.12;break
  draw_line(at,at+Vector2(-drop[2]*.20,drop[2]),Color(.66,.80,.88,alpha),drop[4])
 # Metal roofs catch short bright impacts; ground splashes stay below the bodies.
 for i in range(46):
  var phase=fposmod(tick*1.3+float(i)*.173,1.)
  if phase>.20:continue
  var row=C.props()[4+i%6];var box: Rect2=row[1]
  var at=Vector2(box.position.x+1.+fposmod(float(i)*3.71,box.size.x-2.),box.position.y+1.+fposmod(float(i)*1.31,box.size.y-2.))*Vector2(8,6)-Vector2(0,26)
  draw_line(at,at+Vector2(-2.-phase*6.,-2.-phase*5.),Color(.72,.83,.86,(.20-phase)*1.3),1.)
  draw_line(at,at+Vector2(2.+phase*6.,-1.-phase*4.),Color(.72,.83,.86,(.20-phase)*1.3),1.)
 for splash in splashes:
  var phase=fposmod(tick*.95+float(splash[1]),1.)
  if phase>.40:continue
  var at: Vector2=splash[0]
  draw_arc(at,1.+phase*9.,0,TAU,8,Color(.60,.75,.80,(.40-phase)*.60),1.)
