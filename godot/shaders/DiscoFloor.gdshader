shader_type canvas_item;

uniform sampler2D tex;
uniform float time = 0.0;
uniform float aspect_ratio = 1.0;

const float ROWS_OR_COLS = 6.0;
const float SATURATION = 0.5;
const float SPEED = 0.1;

// 0.0 if time==0.0; 1.0 if time > 0.0
float has_started(float t) {
	return min(ceil(t), 1.0);
}

float when_gt(float x, float y) {
  return max(sign(x - y), 0.0);
}

void fragment() {
	float started = has_started(time);
	float is_horizontal = when_gt(aspect_ratio, 1.0);
	float cols = mix(ROWS_OR_COLS, ROWS_OR_COLS * aspect_ratio, is_horizontal);
	float rows = mix(ROWS_OR_COLS / aspect_ratio, ROWS_OR_COLS, is_horizontal);
	// get the row and column
	float row_h = 1.0 / rows;
	float col_w = 1.0 / cols;
	float col = floor(UV.x / col_w) + 1.0;
	float row = floor(UV.y / row_h) + 1.0;
	// get color
	vec4 color = texture(tex, UV);
	float sin_value = (sin(time * SPEED) + 1.0) / 2.0;
	float cos_value = (cos(time * SPEED) + 1.0) / 2.0;
	// shift color
	vec4 shifted_color = color;
	shifted_color.r = mod(color.r + sin_value * row * col, 1.0);
	shifted_color.g = mod(color.g + cos_value * row * col, 1.0);
	COLOR = mix(color, shifted_color, SATURATION * started);
}
