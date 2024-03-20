shader_type canvas_item;

uniform sampler2D tex;
uniform float time = 0.0;

const float EDGE = 0.05; // minimum width of hour glass
const float SPLIT = 0.5; // share of pixels between inner and outer
const float SPEED = 1.0;

// 0.0 if time==0.0; 1.0 if time > 0.0
float has_started(float t) {
	return min(ceil(t), 1.0);
}

float when_gt(float x, float y) {
  return max(sign(x - y), 0.0);
}

float when_lt(float x, float y) {
  return max(sign(y - x), 0.0);
}

void fragment() {
	float started = has_started(time);
	// ease in and out Y
	float ease_in_out = (sin((2.0 * UV.y + 1.5) * PI) + 1.0) / 2.0;
	float n = mix(EDGE, 1.0 - EDGE, ease_in_out);
	float outer_width = n * 0.5;
	float inner_width = 1.0 - n;
	
	// calculate left side of hour glass
	float x_left_n = UV.x / outer_width;
	float x_left = mix(0.0, SPLIT * 0.5, x_left_n);
	float is_left = when_lt(UV.x, outer_width);
	// calculate right side of hour glass
	float x_right_n = (UV.x - (outer_width + inner_width)) / outer_width;
	float x_right = mix(1.0 - SPLIT * 0.5, 1.0, x_right_n);
	float is_right = when_gt(UV.x, outer_width + inner_width);
	// calculate center of hour glass
	float x_center_n = (UV.x - outer_width) / (inner_width);
	float x_center = mix(SPLIT * 0.5, 1.0 - SPLIT * 0.5, x_center_n);
	float is_center = (1.0 - is_left) * (1.0 - is_right);
	// determine if we're in the left, center, or right
	float x = x_left * is_left + x_right * is_right + x_center * is_center;
	
	// move inner and outer in different directions
	float y_direction = -2.0 * is_center + 1.0;
	float y = mod(UV.y + time * SPEED * y_direction, 1.0);
	
	// take the original UV if we didn't start yet
	vec2 new_uv = mix(UV, vec2(x, y), started);
	COLOR = texture(tex, new_uv);
}