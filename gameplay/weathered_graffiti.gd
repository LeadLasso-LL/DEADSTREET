extends Node2D
# Brick-visible paint erosion on the glyph itself; transparent outside the M.
var font: SystemFont
func _ready() -> void:
	font=SystemFont.new()
	font.font_names=PackedStringArray(["Old English Text MT"])
	var shader=Shader.new()
	shader.code="""
shader_type canvas_item;
float noise(vec2 p) { return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453); }
void fragment() {
	vec2 px=UV/TEXTURE_PIXEL_SIZE;
	float chips=noise(floor(px*1.4));
	float density=noise(floor(px*.28));
	float mortar=mix(1.0,0.82,step(mod(px.y,6.0),0.45));
	COLOR.a *= smoothstep(0.035,0.085,chips)*mix(0.80,0.97,density)*mortar;
	COLOR.rgb *= mix(0.91,1.06,density);
}
"""
	var mat=ShaderMaterial.new()
	mat.shader=shader
	material=mat
	queue_redraw()
func _draw() -> void:
	if font==null:return
	var size=font.get_string_size("M",HORIZONTAL_ALIGNMENT_LEFT,-1,48)
	var sc=minf(30/maxf(1,size.x),33/36.)
	draw_set_transform(Vector2((30-size.x*sc)/2,0),0,Vector2.ONE*sc)
	draw_string(font,Vector2.ZERO,"M",HORIZONTAL_ALIGNMENT_LEFT,-1,48,Color("#a0483b"))
	draw_set_transform(Vector2.ZERO)
	for drip in [Vector2(9,-1.8),Vector2(19,-2.4)]:
		draw_line(drip,drip+Vector2(.2,2.2),Color("#75372f"),.48,false)
