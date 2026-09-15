shader_type canvas_item;
uniform vec2 center=vec2(0.5);
uniform vec2 source_size=vec2(256.0);
uniform float radius=127.0;
void fragment(){
 float distance_px=length((UV-center)*source_size);
 float aa=max(fwidth(distance_px),0.6);
 COLOR.a*=1.0-smoothstep(radius-aa,radius,distance_px);
}
