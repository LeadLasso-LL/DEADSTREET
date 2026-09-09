shader_type canvas_item;
// Approved B silhouette, with a sprite-local grid stable across atlas frames.
uniform float outline_width = 3.0;
uniform bool blood_enabled = true;
uniform bool wounded_stain = false;
uniform vec2 stain_center = vec2(64.0,64.0);
uniform float pixel_step = 1.0;
varying vec4 tint;
void vertex(){ tint=COLOR; }
void fragment(){
 vec2 grid=TEXTURE_PIXEL_SIZE*pixel_step;
 vec2 uv=(floor(UV/grid)+0.5)*grid;
 vec4 c=texture(TEXTURE,uv);
 vec2 d=TEXTURE_PIXEL_SIZE*outline_width;
 float a=max(max(texture(TEXTURE,uv+vec2(d.x,0)).a,texture(TEXTURE,uv-vec2(d.x,0)).a),max(texture(TEXTURE,uv+vec2(0,d.y)).a,texture(TEXTURE,uv-vec2(0,d.y)).a));
 vec2 local_pixel=mod(floor(uv/TEXTURE_PIXEL_SIZE),128.0);
 vec2 stain_delta=local_pixel-stain_center;
 float stain=max(step(length(stain_delta/vec2(4.2,3.3)),1.0),step(length((stain_delta-vec2(1.0,3.0))/vec2(2.1,2.5)),1.0));
 float fabric=1.0-step(0.16,max(max(c.r,c.g),c.b)-min(min(c.r,c.g),c.b));
 if(blood_enabled && wounded_stain && c.a>.5 && stain>.5 && fabric>.5) c.rgb=mix(vec3(.28,.06,.08),vec3(.49,.10,.12),step(0.0,stain_delta.x));
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