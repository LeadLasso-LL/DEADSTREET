shader_type canvas_item;
uniform vec3 paint = vec3(0.4,0.45,0.42);
void fragment(){
 vec4 c=texture(TEXTURE,UV);
 if(c.r>c.g*1.25 && c.r>c.b*1.15){
  float value=max(c.r,max(c.g,c.b));
  c.rgb=paint*value*1.7;
 }
 COLOR=c;
}