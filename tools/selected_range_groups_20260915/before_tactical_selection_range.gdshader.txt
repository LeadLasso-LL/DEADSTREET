shader_type canvas_item;
render_mode unshaded;

uniform vec4 tint : source_color = vec4(0.76, 0.24, 0.23, 1.0);
uniform float softness = 0.018;
uniform vec2 radii = vec2(1.0);
varying vec2 disc_position;

void vertex() {
	// Local geometry coordinates work without a texture or generated UVs.
	disc_position = VERTEX / radii;
}

void fragment() {
	float radius = length(disc_position);
	float interior = 1.0 - smoothstep(1.0 - softness, 1.0, radius);
	float rim = smoothstep(1.0 - softness * 4.0, 1.0 - softness * 2.0, radius) * interior;
	// No pixels beyond the authoritative maximum radius. No hard outline.
	COLOR = vec4(tint.rgb, (0.028 * interior + 0.15 * rim) * COLOR.a);
}
