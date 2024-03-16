shader_type canvas_item;

uniform sampler2D tex;
uniform float time = 0.0;
uniform float aspect_ratio = 1.0;

const float ROWS = 5.0;
const float RADIUS_MULTIPLIER = 0.25; // increase for larger dots
const float SCALE_SPEED = 16.0; // increase for faster dot pulsing

// return 0.0 if outside of circle, 1.0 if inside circle
// adapted from: https://godotshaders.com/snippet/circle/
float circle(vec2 position, vec2 center, float radius) {
	return step(radius, length(position - center));
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
	// determine number of columns based on rows and spect ratio
	float cols = round(ROWS * aspect_ratio);
	// base radius is based on cell dimensions
	float row_h = 1.0 / ROWS;
	float col_w = 1.0 / cols;
	float base_radius = min(row_h * RADIUS_MULTIPLIER, col_w * RADIUS_MULTIPLIER);
	// make radius grow and shrink over time; between values 1.0 and 2.0
	float scale_radius = (sin(time * SCALE_SPEED) + 1.0) / 2.0 + 1.0;
	float radius = base_radius * scale_radius * started;
	// center of circle will be the center of the cell
	float center_x = floor(UV.x / col_w) * col_w + col_w * 0.5;
	float center_y = floor(UV.y / row_h) * row_h + row_h * 0.5;
	vec2 center = vec2(center_x, center_y);
	float inside_circle = circle(UV, center, radius);
	COLOR = mix(inv, color, inside_circle);
}
