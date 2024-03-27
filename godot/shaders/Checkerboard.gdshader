shader_type canvas_item;

uniform float aspect_ratio = 1.0;
uniform sampler2D tex;
uniform float time = 0.0;

const float BASE_SPEED = 8.0;
const float ROWS = 6.0;

// 0.0 if time==0.0; 1.0 if time > 0.0
float has_started(float t) {
	return min(ceil(t), 1.0);
}

float when_eq(float x, float y) {
  return 1.0 - abs(sign(x - y));
}

void fragment() {
	// if we haven't started, image should be shown without dots (i.e. radius = 0)
	float started = has_started(time);
	// determine number of columns based on rows and spect ratio
	float cols = round(ROWS * aspect_ratio);
	// determine row and column
	float row_h = 1.0 / ROWS;
	float col_w = 1.0 / cols;
	float col = floor(UV.x / col_w);
	float row = floor(UV.y / row_h);
	// get color and inverted color
	vec4 color = texture(tex, UV);
	vec4 inv = mix(color, vec4(1.0 - color.rgb, 1.0), 0.9);
	// offset time based on position
	float time_offset = time + max(UV.x, UV.y);
	// alternate checker color based on time
	float mix_amount = (sin(time_offset * BASE_SPEED) + 1.0) * 0.5;
	float checker = when_eq(mod(col, 2.0), mod(row, 2.0));
	float checker_amount = mix(checker, 1.0 - checker, round(mix_amount));
	COLOR = mix(color, inv, checker_amount * started);
}
