extends Control
# Screen-pixel badges: prefilter once from source art, then display one texel per pixel.
static var sized_textures={}
var emblem: TextureRect
var selected: bool=false
var diameter: int=24
var source_texture: Texture2D
func _ready() -> void:
 mouse_filter=Control.MOUSE_FILTER_IGNORE
 emblem=TextureRect.new();add_child(emblem);emblem.mouse_filter=Control.MOUSE_FILTER_IGNORE
 emblem.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
 emblem.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
func configure(source: Texture2D,pixels: int) -> void:
 if source==null:return
 if source_texture==source and diameter==pixels:return
 source_texture=source;diameter=pixels
 var key=str(source.get_instance_id())+":"+str(pixels)
 if not sized_textures.has(key):
  var im=source.get_image()
  if im.is_compressed():im.decompress()
  im.resize(pixels,pixels,Image.INTERPOLATE_LANCZOS)
  sized_textures[key]=ImageTexture.create_from_image(im)
 emblem.texture=sized_textures[key];emblem.size=Vector2.ONE*pixels;size=emblem.size
 queue_redraw()
func set_selected(value: bool) -> void:
 if selected==value:return
 selected=value;queue_redraw()
func _draw() -> void:
 var center=Vector2.ONE*float(diameter)*.5
 # A dark separation edge works on both floodlit concrete and deep shadow.
 draw_circle(center,float(diameter)*.5+.7,Color(.025,.035,.04,.88))
 if not selected:return
 for layer in range(4):draw_arc(center,float(diameter)*.5+2.5+layer,0,TAU,64,Color(1.,.84,.27,.18-layer*.04),2.,true)
 draw_arc(center,float(diameter)*.5+1.5,0,TAU,64,Color("#f4d34e"),1.5,true)
