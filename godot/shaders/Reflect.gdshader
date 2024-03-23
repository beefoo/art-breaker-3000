shader_type canvas_item;

uniform sampler2D tex;
uniform float time = 0.0;

const float BASE_SPEED = 5.0;
const float WAVE_SPEED = 2.0;

// 0.0 if time==0.0; 1.0 if time > 0.0
float has_started(float t) {
	return min(ceil(t), 1.0);
}

void fragment() {
	vec4 tex_color = texture(tex, UV);
	// reflect on X
	vec4 reflect_x_color = texture(tex, vec2(1.0 - UV.x, UV.y));
	float reflect_x_amount = (sin((time + UV.x * WAVE_SPEED) * BASE_SPEED) + 1.0) * 0.5;
	vec4 color_x = mix(tex_color, reflect_x_color, reflect_x_amount);
	// reflect on y
	vec4 reflect_y_color = texture(tex, vec2(UV.x, 1.0 - UV.y));
	float reflect_y_amount = (cos((time + UV.y * WAVE_SPEED) * BASE_SPEED) + 1.0) * 0.5;
	vec4 color_y = mix(color_x, reflect_y_color, reflect_y_amount);
	// take the original color if not yet started
	float started = has_started(time);
	COLOR = mix(tex_color, color_y, started);
}
