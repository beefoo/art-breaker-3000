shader_type canvas_item;

uniform sampler2D tex;
uniform float time = 0.0;

const float SPEED = 0.5;
const vec3 DISSOLVE_TO_COLOR = vec3(0.04, 0.04, 0.05);

// 0.0 if time==0.0; 1.0 if time > 0.0
float has_started(float t) {
	return min(ceil(t), 1.0);
}

void fragment() {
	vec4 color = texture(tex, UV);
	float brightness = (color.r + color.g + color.b) / 3.0;
	// dissolve in and out, offset by brightness value
	float n = (time + brightness) * SPEED * (1.0 + brightness);
	float ease_in_out = (sin((2.0 * n + 1.5) * PI) + 1.0) / 2.0;
	vec4 dissolve_color = vec4(DISSOLVE_TO_COLOR, 1.0);
	float started = has_started(time);
	COLOR = mix(color, dissolve_color, ease_in_out * started);
}
