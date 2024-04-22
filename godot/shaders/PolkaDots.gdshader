shader_type canvas_item;

uniform sampler2D tex;
uniform float time = 0.0;
uniform float aspect_ratio = 1.0;

const float ROWS_OR_COLS = 5.0;
const float RADIUS_MULTIPLIER = 0.667; // increase for larger dots
const float SCALE_SPEED = 16.0; // increase for faster dot pulsing

float when_gt(float x, float y) {
  return max(sign(x - y), 0.0);
}

// return 0.0 if outside of circle, 1.0 if inside circle
// adapted from: https://godotshaders.com/snippet/circle/
float circle(vec2 position, vec2 center, float radius) {
	return step(radius, length(position - center));
}

float ellipse(vec2 position, vec2 center, float rad_a, float rad_b) {
	float x = position.x - center.x;
    float y = position.y - center.y;
	float dist = pow( x, 2.0 ) / ( rad_a * rad_a ) + pow( y, 2.0 ) / ( rad_b * rad_b );
	return when_gt(dist, 0.1);
}

// 0.0 if time==0.0; 1.0 if time > 0.0
float has_started(float t) {
	return min(ceil(t), 1.0);
}

void fragment() {
	// if we haven't started, image should be shown without dots (i.e. radius = 0)
	float started = has_started(time);
	// dots will be inverted colors
	vec4 color = texture(tex, UV);
	vec4 inv = vec4(1.0-color.r, 1.0-color.g, 1.0-color.b, 1.0);
	// determine number of rows based on cols and aspect ratio
	float is_horizontal = when_gt(aspect_ratio, 1.0);
	float cols = mix(ROWS_OR_COLS, round(ROWS_OR_COLS * aspect_ratio), is_horizontal);
	float rows = mix(round(ROWS_OR_COLS / aspect_ratio), ROWS_OR_COLS, is_horizontal);
	// base radius is based on cell dimensions
	float col_w = 1.0 / cols;
	float row_h = 1.0 / rows;
	// make radius grow and shrink over time; between values 1.0 and 2.0
	float scale_radius = (sin(time * SCALE_SPEED) + 1.0) / 2.0 + 1.0;
	float radius_a = col_w * RADIUS_MULTIPLIER * scale_radius * started;
	float radius_b = row_h * RADIUS_MULTIPLIER * scale_radius * started;
	// center of circle will be the center of the cell
	float center_x = floor(UV.x / col_w) * col_w + col_w * 0.5;
	float center_y = floor(UV.y / row_h) * row_h + row_h * 0.5;
	vec2 center = vec2(center_x, center_y);
	float inside_circle = ellipse(UV, center, radius_a, radius_b);
	COLOR = mix(inv, color, inside_circle);
}
