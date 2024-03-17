shader_type canvas_item;

uniform vec2 pointer_start = vec2(0.5);
uniform vec2 pointer = vec2(0.5);
uniform sampler2D tex;
uniform float time = 0.0;

const float EPSILON = 0.000001;

// 0.0 if time==0.0; 1.0 if time > 0.0
float has_started(float t) {
	return min(ceil(t), 1.0);
}

// when x is less than or equal to y, return 1.0, otherwise, 0.0
float when_lte(float x, float y) {
  return 1.0 - max(sign(x - y), 0.0);
}

void fragment() {
	float started = has_started(time);
	vec2 uv = clamp(UV, vec2(EPSILON), vec2(1.0 - EPSILON));
	vec2 p_uv = clamp(pointer, vec2(EPSILON), vec2(1.0 - EPSILON));
	
	// determine x
	float x_left = uv.x / p_uv.x * pointer_start.x;
	float x_right = (uv.x - p_uv.x) / (1.0 - p_uv.x) * (1.0 - pointer_start.x) + pointer_start.x;
	float x_is_left = when_lte(x_left, pointer_start.x);
	float x = mix(x_right, x_left, x_is_left);
	
	// determine y
	float y_top = uv.y / p_uv.y * pointer_start.y;
	float y_bottom = (uv.y - p_uv.y) / (1.0 - p_uv.y) * (1.0 - pointer_start.y) + pointer_start.y;
	float y_is_top = when_lte(y_top, pointer_start.y);
	float y = mix(y_bottom, y_top, y_is_top);
	
	// take the original UV if we didn't start yet
	vec2 new_uv = mix(UV, vec2(x, y), started);
	COLOR = texture(tex, new_uv);
}