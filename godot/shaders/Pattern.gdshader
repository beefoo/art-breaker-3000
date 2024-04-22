shader_type canvas_item;

uniform float aspect_ratio = 1.0;
uniform vec2 pointer = vec2(0.0);
uniform sampler2D tex;
uniform float time = 0.0;

const float SEGMENTS = 4.0;
const float ROWS_OR_COLS = 4.0;
const float SAMPLE_SIZE = 0.20;

// 0.0 if time==0.0; 1.0 if time > 0.0
float has_started(float t) {
	return min(ceil(t), 1.0);
}

float when_gt(float x, float y) {
  return max(sign(x - y), 0.0);
}

// Adapted from: https://danielilett.com/2020-02-19-tut3-8-crazy-kaleidoscopes/
void fragment() {
	float started = has_started(time);
	
	float is_horizontal = when_gt(aspect_ratio, 1.0);
	float cols = mix(ROWS_OR_COLS, round(ROWS_OR_COLS * aspect_ratio), is_horizontal);
	float rows = mix(round(ROWS_OR_COLS / aspect_ratio), ROWS_OR_COLS, is_horizontal);
	
	// get bounds of sample area around pointer
	float top = clamp(pointer.y - SAMPLE_SIZE * 0.5, 0.0, 1.0 - SAMPLE_SIZE);
	float left = clamp(pointer.x - SAMPLE_SIZE * 0.5, 0.0, 1.0 - SAMPLE_SIZE);
	float bottom = top + SAMPLE_SIZE;
	float right = left + SAMPLE_SIZE;
	
	// get the UV of the sample
	float row_h = 1.0 / rows;
	float col_w = 1.0 / cols;
	float x = mix(left, right, mod(UV.x, col_w) / col_w);
	float y = mix(top, bottom, mod(UV.y, row_h) / row_h);
	vec2 sample_uv = vec2(x, y);
	
	// convert to polar coordinates
	vec2 shift_uv = sample_uv - pointer;
	float radius = sqrt(dot(shift_uv, shift_uv));
	float angle = atan(shift_uv.y, shift_uv.x);
	// Calculate segment angle amount
	float segment_angle = 2.0 * PI / SEGMENTS;
	// Calculate which segment this angle is in
	angle -= segment_angle * floor(angle / segment_angle);
	// Each segment contains one reflection.
	angle = min(angle, segment_angle - angle);
	// Convert back to UV coordinates.
	vec2 new_uv = vec2(cos(angle), sin(angle)) * radius + pointer;
	// Reflect outside the inner circle boundary.
	new_uv = max(min(new_uv, 2.0 - new_uv), -new_uv);
	
	// take the original UV if we didn't start yet
	vec2 final_uv = mix(UV, new_uv, started);
	COLOR = texture(tex, final_uv);
}