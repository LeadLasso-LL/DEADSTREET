shader_type canvas_item;
// Approved B silhouette, with a sprite-local grid stable across atlas frames.
uniform float outline_width = 2.5;
uniform float pixel_step = 1.0;
varying vec4 tint;
void vertex(){ tint=COLOR; }
void fragment(){
 vec2 grid=TEXTURE_PIXEL_SIZE*pixel_step;
 vec2 uv=(floor(UV/grid)+0.5)*grid;
 vec4 c=texture(TEXTURE,uv);
 vec2 d=TEXTURE_PIXEL_SIZE*outline_width;
 float a=max(max(texture(TEXTURE,uv+vec2(d.x,0)).a,texture(TEXTURE,uv-vec2(d.x,0)).a),max(texture(TEXTURE,uv+vec2(0,d.y)).a,texture(TEXTURE,uv-vec2(0,d.y)).a));
 vec3 toned=c.rgb*vec3(0.89,0.92,0.87);
 // Quantize brightness together to preserve skin, wood and fabric hues.
 float light=max(max(toned.r,toned.g),toned.b);
 float band=floor(light*12.0+0.5)/12.0;
 toned*=band/max(light,0.001);
 vec4 above=texture(TEXTURE,uv-vec2(0,grid.y));
 // A restrained light-facing edge helps dark equipment separate from clothing.
 float edge=step(light+0.16,max(max(above.r,above.g),above.b))*above.a;
 toned+=vec3(0.035,0.04,0.04)*edge*(1.0-step(0.3,light));
 if(c.a<0.1 && a>0.4 && outline_width>0.0) COLOR=vec4(0.055,0.075,0.07,a*0.95)*tint;
 else COLOR=vec4(toned,c.a)*tint;
}