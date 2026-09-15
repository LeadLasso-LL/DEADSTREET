shader_type canvas_item;
render_mode unshaded;

uniform vec4 tint : source_color = vec4(0.76, 0.24, 0.23, 1.0);
uniform int range_count = 0;
uniform vec4 rings[32]; // Ground-space center.xy and projected radius.zw.
uniform float feathers[32];
varying vec2 ground_position;

void vertex() {
	ground_position = VERTEX;
}

void fragment() {
	float mask = 0.0;
	for (int i = 0; i < 32; i++) {
		if (i >= range_count) { break; }
		float radius = length((ground_position - rings[i].xy) / rings[i].zw);
		float feather = feathers[i];
		float interior = 1.0 - smoothstep(1.0 - feather, 1.0, radius);
		float rim = smoothstep(1.0 - feather * 4.0, 1.0 - feather * 2.0, radius) * interior;
		// One composite: crossing/coincident outlines never add brightness.
		mask = max(mask, rim);
	}
	COLOR = vec4(tint.rgb, 0.105 * mask * COLOR.a);
}
