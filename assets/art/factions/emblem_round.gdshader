shader_type canvas_item;
varying vec4 tint;
void vertex() { tint = COLOR; }
void fragment() {
	COLOR = texture(TEXTURE, UV) * tint;
	COLOR.a *= 1.0 - smoothstep(0.488, 0.5, distance(UV, vec2(0.5)));
}
