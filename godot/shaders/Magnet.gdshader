shader_type canvas_item;

uniform float aspect_ratio = 1.0;
uniform vec2 pointer = vec2(0.0);
uniform sampler2D tex;
uniform float time = 0.0;

const float ROWS_OR_COLS = 24.0;

// 0.0 if time==0.0; 1.0 if time > 0.0
float has_started(float t) {
	return min(ceil(t), 1.0);
}

float when_gt(float x, float y) {
  return max(sign(x - y), 0.0);
}

vec2 rotate(vec2 uv, vec2 pivot, float angle) {
	mat2 rotation = mat2(vec2(sin(angle), -cos(angle)),
						vec2(cos(angle), sin(angle)));
	uv -= pivot;
	uv = uv * rotation;
	uv += pivot;
	return uv;
}

void fragment() {
	// if we haven't started, image should be shown without dots (i.e. radius = 0)
	float started = has_started(time);
	// determine number of columns based on rows and spect ratio
	float is_horizontal = when_gt(aspect_ratio, 1.0);
	float cols = mix(ROWS_OR_COLS, round(ROWS_OR_COLS * aspect_ratio), is_horizontal);
	float rows = mix(round(ROWS_OR_COLS / aspect_ratio), ROWS_OR_COLS, is_horizontal);
	// determine row and column
	float row_h = 1.0 / rows;
	float col_w = 1.0 / cols;
	float col = floor(UV.x / col_w);
	float row = floor(UV.y / row_h);
	// center of cell
	float center_x = col * col_w + col_w * 0.5;
	float center_y = row * row_h + row_h * 0.5;
	vec2 center = vec2(center_x, center_y);
	// get angle between the center of cell and pointer
	vec2 shift_uv = center - pointer;
	float angle = atan(shift_uv.y, shift_uv.x);
	// rotate by that amount
	vec2 rotated_uv = rotate(UV, center, angle);
	// take the original UV if we didn't start yet
	vec2 new_uv = mix(UV, rotated_uv, started);
	COLOR = texture(tex, new_uv);
}
