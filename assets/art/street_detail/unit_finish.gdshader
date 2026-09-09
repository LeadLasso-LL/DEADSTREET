shader_type canvas_item;
uniform float outline_width = 0.0;
varying vec4 tint;
void vertex(){ tint=COLOR; }
void fragment(){
 vec4 c=texture(TEXTURE,UV);
 vec2 d=TEXTURE_PIXEL_SIZE*outline_width;
 float a=max(max(texture(TEXTURE,UV+vec2(d.x,0)).a,texture(TEXTURE,UV-vec2(d.x,0)).a),max(texture(TEXTURE,UV+vec2(0,d.y)).a,texture(TEXTURE,UV-vec2(0,d.y)).a));
 vec3 toned=c.rgb*vec3(0.89,0.92,0.87);
 toned=mix(toned,floor(toned*9.0+0.5)/9.0,0.25);
 if(c.a<0.1 && a>0.4 && outline_width>0.0) COLOR=vec4(0.055,0.075,0.07,a*0.95)*tint;
 else COLOR=vec4(toned,c.a)*tint;
}